<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../globals.asp"-->
<!-- #include file="../../security/functions/fnc_checkCoAuthors.asp"-->

<table cellpadding="0" cellspacing="0" class="attachmentsIndexTable">
<tr>
<th>Note</th>
<th>Date Added</th>
<th>Date Updated</th>
<th>Actions</th>
</tr>
<%
revisionId = request.querystring("revisionId")
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")

isCollaborator = False
If experimentType = 5 Then
	isCollaborator = checkCoAuthors(experimentId, experimentType,"showNoteTable")
End If

ownsExp = ownsExperiment(experimentType, experimentId, session("userId"))
canWrite = (ownsExp or isCollaborator) And revisionId = ""
	
prefix = GetPrefix(experimentType)
notesTable = GetFullName(prefix, "notes", true)
notesHistoryTable = GetFullName(prefix, "notes_history", true)
notesPreSaveTable = GetFullName(prefix, "notes_preSave", true)

'Grab the draft to make sure we have any draft data
Set draftRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT experimentJSON from experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
draftRec.open strQuery,connAdm,3,3	
If Not draftRec.eof Then
	set experimentJSON = JSON.parse(draftRec("experimentJSON"))
	isDraft = true	
else
	set experimentJSON = JSON.parse("{}")
	isDraft = false
End If

' This function needs to be put in here as calling "include" on ASP scripts that have this function
' fail to implement it.  Something overrides the include and makes this whole script fail otherwise.
Function draftSet(theKey,theVal)	
	If Not (ownsExp Or isCollaborator) Then
		draftSet = theVal
	Else		
		If isDraft Then
			If experimentJSON.exists(theKey) then
				draftSet = experimentJSON.Get(theKey)
			Else
				experimentJSON.Set theKey, theVal
				draftSet = theVal
			End if
		Else
			experimentJSON.Set theKey, theVal
			draftSet = theVal
		End if
	End if
End Function

If experimentId <> "" then
	Call getconnected
	If revisionId = "" then
		Set attachmentRec = server.CreateObject("ADODB.Recordset")
		' Don't use the exeprimentType from the preSave table in the sub-query becuase it can be NULL.
		strQuery = "SELECT id, name, note, dateAdded, dateUpdated from " & notesPreSaveTable & " a WHERE experimentId="&SQLClean(experimentId,"N","S") &_
				" AND NOT EXISTS (SELECT 1 FROM itemsToRemove r WHERE r.itemId = a.id AND r.itemType='note' AND r.experimentId=a.experimentId AND r.experimentType=" & SQLClean(experimentType,"N","S") & " AND r.pre=1) ORDER BY dateAddedServer DESC"
		attachmentRec.open strQuery,conn,3,3
		counter = 0
		Do While Not attachmentRec.eof
			counter = counter + 1
			%>
				<tr id="note_p_<%=attachmentRec("id")%>_tr">
				<%note = removeTags(HTMLDecode(attachmentRec("note")))%>
				<%
				noteName = draftSet("note_p_"&attachmentRec("id")&"_name",attachmentRec("name"))
				If noteName = "" Then
					noteName = "Untitled"
				End if
				%>
				<td><a href="javascript:void(0)" onclick="toggleNote('note_p_<%=attachmentRec("id")%>');return false;"><%=maxChars(noteName,40)%></a><br><%=maxChars(note,40)%><%If Len(note) >40 then%>...<%End if%></td>
				<td id="note_p_date_added_<%=attachmentRec("id")%>"><script>setElementContentToDateString("note_p_date_added_<%=attachmentRec("id")%>","<%=attachmentRec("dateAdded")%>",<%If session("useGMT") Then%>true<%else%>false<%end if%>);</script></td>
				<td id="note_p_date_updated_<%=attachmentRec("id")%>"><script>setElementContentToDateString("note_p_date_updated_<%=attachmentRec("id")%>","<%=attachmentRec("dateUpdated")%>",<%If session("useGMT") Then%>true<%else%>false<%end if%>);</script></td>
				<td class="uploadButtons">
					<%If revisionId = "" And (ownsExp or isCollaborator) then%>
						<a href="javascript:void(0);" onclick="return removeTableItem('<%=mainAppPath%>/experiments/ajax/do/removeNote.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&noteId=<%=attachmentRec("id")%>&pre=true','note_p_<%=attachmentRec("id")%>_tr');return false;" class="littleButton">Remove</a>
					<%End if%>
				</td>
				</tr>
				<tr>
					<td height="1px" style="height:1px;line-height:1px;" colspan="4" id="note_p_<%=attachmentRec("id")%>_td">
						<div id="note_p_<%=attachmentRec("id")%>" style="display:none;">
						<%taStr = attachmentRec("note")%>
						<%If revisionId = "" and canWrite then%>
							<div class="attachDescriptionTitle">Name</div>
							<input type="text" name="note_p_<%=attachmentRec("id")%>_name" id="note_p_<%=attachmentRec("id")%>_name" value="<%=draftSet("note_p_"&attachmentRec("id")&"_name",attachmentRec("name"))%>" class="attachmentNameTextBox">
							<div class="attachDescriptionTitle">Description</div>
							<textarea style="width:780px;height:100px;" name="note_p_<%=attachmentRec("id")%>_description" id="note_p_<%=attachmentRec("id")%>_description"><%=draftSet("note_p_"&attachmentRec("id")&"_description",taStr)%></textarea>
							<input type="hidden" name="note_p_<%=attachmentRec("id")%>_description_loaded" id="note_p_<%=attachmentRec("id")%>_description_loaded" value="0">
							<script type="text/javascript">
								//CKEDITOR.replace('note_p_<%=attachmentRec("id")%>_description',{toolbar : 'arxspanToolbar'});
								//CKEDITOR.instances['note_p_<%=attachmentRec("id")%>_description'].on('change',function(e){unsavedChanges=true;})
							</script>
							<div class="attachmentTableButtons">
							<a class="createLink" onclick="clickSave()" href="javascript:void(0);">Save</a><a class="createLink" onclick="toggleNote('note_p_<%=attachmentRec("id")%>');return false;" href="javascript:void(0);">Close</a>
							</div>
						<%else%>
							<%=taStr%>
						<%End if%>
						</div>
					</td>
				</tr>
			<%
			attachmentRec.movenext
		Loop
		attachmentRec.close
		Set attachmentRec = Nothing
	End If

	If revisionId = "" Then
		' Don't use the exeprimentType from the notes table in the sub-query becuase it can be NULL.
		revisionQuery = " AND NOT EXISTS (SELECT 1 FROM itemsToRemove r WHERE r.itemId = a.id AND r.itemType='note' AND r.experimentId=a.experimentId AND r.experimentType=" & SQLClean(experimentType,"N","S") & " AND r.pre=0)"
	Else
		notesTable = notesHistoryTable
		revisionQuery = " AND revisionNumber="&SQLClean(revisionId,"N","S")
	End If
	
	strQuery = "SELECT id, name, note, dateAdded, dateUpdated, readOnly from " & notesTable & " a WHERE experimentId="&SQLClean(experimentId,"N","S") & revisionQuery & " ORDER BY dateAddedServer DESC"
		
	Set attachmentRec = server.CreateObject("ADODB.Recordset")
	attachmentRec.open strQuery,conn,3,3
	counter = 0
	Do While Not attachmentRec.eof
		counter = counter + 1
		
		'' we need to check whether the note is of the old format or new format
		If InStr(attachmentRec("note"), "<") = 1 Then
			note = removeTags(attachmentRec("note"))
		Else
			note = removeTags(HTMLDecode(attachmentRec("note")))
		End If	
		%>
			<tr id="note_<%=attachmentRec("id")%>_tr">									
				<%
				noteName = draftSet("note_"&attachmentRec("id")&"_name",attachmentRec("name"))
				If noteName = "" Then
					noteName = "Untitled"
				End if
				%>
				<td><a href="javascript:void(0)" onclick="toggleNote('note_<%=attachmentRec("id")%>');return false;"><%=maxChars(noteName,40)%></a><br><%=maxChars(note,50)%><%If Len(note) >50 then%>...<%End if%></td>
				<td id="note_date_added_<%=attachmentRec("id")%>"><script>setElementContentToDateString("note_date_added_<%=attachmentRec("id")%>","<%=attachmentRec("dateAdded")%>",<%If session("useGMT") Then%>true<%else%>false<%end if%>);</script></td>
				<td id="note_date_updated_<%=attachmentRec("id")%>"><script>setElementContentToDateString("note_date_updated_<%=attachmentRec("id")%>","<%=attachmentRec("dateUpdated")%>",<%If session("useGMT") Then%>true<%else%>false<%end if%>);</script></td>
				<td class="uploadButtons">
					<%If revisionId = "" And (ownsExp or isCollaborator) then%>
						<%If attachmentRec("readOnly") = 0 then%><a href="javascript:void(0);" onclick="return removeTableItem('<%=mainAppPath%>/experiments/ajax/do/removeNote.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&noteId=<%=attachmentRec("id")%>','note_<%=attachmentRec("id")%>_tr')" class="littleButton">Remove</a><%End if%>
					<%End if%>
				</td>
			</tr>
			<tr>
				<td height="1px" style="height:1px;line-height:1px;" colspan="4" id="note_<%=attachmentRec("id")%>_td">
					<div id="note_<%=attachmentRec("id")%>" style="display:none;">
					<%taStr = attachmentRec("note")%>
					<%If revisionId = "" and canWrite And attachmentRec("readOnly") = 0 then%>
						<div class="attachDescriptionTitle">Name</div>
						<input type="text" name="note_<%=attachmentRec("id")%>_name" id="note_<%=attachmentRec("id")%>_name" value="<%=draftSet("note_"&attachmentRec("id")&"_name",attachmentRec("name"))%>" class="attachmentNameTextBox">						
						<div class="attachDescriptionTitle">Description</div>
						<textarea style="width:780px;height:100px;" name="note_<%=attachmentRec("id")%>_description" id="note_<%=attachmentRec("id")%>_description"><%=draftSet("note_"&attachmentRec("id")&"_description",taStr)%></textarea>
						<input type="hidden" name="note_<%=attachmentRec("id")%>_description_loaded" id="note_<%=attachmentRec("id")%>_description_loaded" value="0">
						<script type="text/javascript">
							//CKEDITOR.replace('note_<%=attachmentRec("id")%>_description',{toolbar : 'arxspanToolbar'});
							//CKEDITOR.instances['note_<%=attachmentRec("id")%>_description'].on('change',function(e){unsavedChanges=true;})
						</script>
						<div class="attachmentTableButtons">
						<a class="createLink" onclick="clickSave()" href="javascript:void(0);">Save</a><a class="createLink" onclick="toggleNote('note_<%=attachmentRec("id")%>');return false;" href="javascript:void(0);">Close</a>
						</div>
					<%else%>
						<%If attachmentRec("readOnly") = 0 then%>
							<%=HTMLDecode(taStr)%>
						<%else%>
							<input type="hidden" name="note_<%=attachmentRec("id")%>_name" id="note_<%=attachmentRec("id")%>_name" value="<%=attachmentRec("name")%>">
							<textarea style="display:none;" name="note_<%=attachmentRec("id")%>_description" id="note_<%=attachmentRec("id")%>_description"><%=taStr%></textarea>
							<%=note%>
						<%End if%>
					<%End if%>
					</div>
				</td>
			</tr>
		<%
		attachmentRec.movenext
	Loop
	attachmentRec.close
	Set attachmentRec = Nothing
End if
%>
</table>