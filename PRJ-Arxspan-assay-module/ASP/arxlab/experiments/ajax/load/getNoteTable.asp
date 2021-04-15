<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../../../_inclds/globals.asp" -->
<!-- #include file="../../../_inclds/security/functions/fnc_checkCoAuthors.asp"-->
<%
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
revisionId = request.querystring("revisionId")
ownsExp = ownsExperiment(experimentType, experimentId, session("userId"))

isCollaborator = False
If experimentType = 5 Then
	isCollaborator = checkCoAuthors(experimentId, experimentType,"getNoteTable")
End If

canWrite = (ownsExp or isCollaborator) And revisionId = ""
canView = canViewExperiment(experimentType,experimentId,session("userId"))
%>
<!-- #include file="../../../_inclds/experiments/common/asp/getExperimentJSON.asp"-->

<table cellpadding="0" cellspacing="0" class="attachmentsIndexTable">
<tr>
<th>Note</th>
<th>Date Added(<span id="tz1"><%If session("useGMT") then%><%="GMT"%><%End if%></span><%If Not session("useGMT") then%><script type="text/javascript">document.getElementById("tz1").innerHTML = (new Date()).format("Z");</script><%End if%>)</th>
<th>Date Updated(<span id="tz2"><%If session("useGMT") then%><%="GMT"%><%End if%></span><%If Not session("useGMT") then%><script type="text/javascript">document.getElementById("tz2").innerHTML = (new Date()).format("Z");</script><%End if%>)</th>
<th>Actions</th>
</tr>
<%
If canView then
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "notes", true)
	historyTableName = GetFullName(prefix, "notes_history", true)
	preSaveTableName = GetFullName(prefix, "notes_preSave", true)

	If revisionId = "" then
		Set attachmentRec = server.CreateObject("ADODB.Recordset")
		' Don't use exeprimentType from the preSave table in the sub-query becuase it can be NULL.
		strQuery = "SELECT id, note, name, dateAdded, dateUpdated from " & preSaveTableName & " a WHERE experimentId="&SQLClean(experimentId,"N","S") &_
				" AND NOT EXISTS (SELECT 1 FROM itemsToRemove r WHERE r.itemId = a.id AND r.itemType='note' AND r.experimentId=a.experimentId AND r.experimentType=" & SQLClean(experimentType,"N","S") & " AND r.pre=1) ORDER BY dateAddedServer DESC"
		attachmentRec.open strQuery,conn,3,3
		counter = 0
		Do While Not attachmentRec.eof
			counter = counter + 1
			%>
				<tr id="note_p_<%=attachmentRec("id")%>_tr">
				<%note = HTMLDecode(attachmentRec("note"))%>
				<%
				If Trim(attachmentRec("name")) = "" Then
					noteName = "Untitled"
				Else
					noteName = attachmentRec("name")
				End if
				%>
				<td><a href="javascript:void(0)" onclick="toggleNote('note_p_<%=attachmentRec("id")%>');return false;" id="note_p_<%=attachmentRec("id")%>_a"><%=maxChars(noteName,40)%></a><br><span id="note_p_<%=attachmentRec("id")%>_description_preview"><%=maxChars(note,40)%></span><%If Len(note) >40 then%>...<%End if%></td>
				<td id="note_p_<%=attachmentRec("id")%>_date_added">
				<script>setElementContentToDateString("<%="note_p_"&attachmentRec("id")&"_date_added"%>", "<%=attachmentRec("dateAdded")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
				</td>
				<td id="note_p_<%=attachmentRec("id")%>_date_updated">
				<script>setElementContentToDateString("<%="note_p_"&attachmentRec("id")&"_date_updated"%>", "<%=attachmentRec("dateUpdated")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
				</td>
				<td class="uploadButtons">
					<%If revisionId = "" And (ownsExp or isCollaborator) then%>
						<a href="javascript:void(0);" onclick="return removeTableItem('<%=mainAppPath%>/experiments/ajax/do/removeNote.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&noteId=<%=attachmentRec("id")%>&pre=true','note_p_<%=attachmentRec("id")%>_tr')" class="littleButton">Remove</a>
					<%End if%>
				</td>
				</tr>
				<tr>
					<td height="1px" style="height:1px;line-height:1px;" colspan="4" id="note_p_<%=attachmentRec("id")%>_td">
						<div id="note_p_<%=attachmentRec("id")%>" style="display:none;">
						<%taStr = attachmentRec("note")%>
						<%If revisionId = "" and canWrite then%>
							<div class="attachDescriptionTitle">Name</div>
							<input type="text" name="note_p_<%=attachmentRec("id")%>_name" id="note_p_<%=attachmentRec("id")%>_name" value="<%=draftSet("note_p_"&attachmentRec("id")&"_name",attachmentRec("name"))%>" class="attachmentNameTextBox" onkeydown='setNoteName("note_p_<%=attachmentRec("id")%>_name")'>
							<div class="attachDescriptionTitle">Description</div>
							<textarea style="width:780px;height:100px;" name="note_p_<%=attachmentRec("id")%>_description" id="note_p_<%=attachmentRec("id")%>_description"><%=draftSet("note_p_"&attachmentRec("id")&"_description",taStr)%></textarea>
							<input type="hidden" name="note_p_<%=attachmentRec("id")%>_description_loaded" id="note_p_<%=attachmentRec("id")%>_description_loaded" value="0">
							<script type="text/javascript">//CKEDITOR.replace('note_p_<%=attachmentRec("id")%>_description',{toolbar : 'arxspanToolbar'});//CKEDITOR.instances['note_p_<%=attachmentRec("id")%>_description'].on('change',function(e){unsavedChanges=true;})</script>
							<div class="attachmentTableButtons">
							<a class="createLink" onclick="clickSave();" href="javascript:void(0);">Save</a><a class="createLink" onclick="toggleNote('note_p_<%=attachmentRec("id")%>');return false;" href="javascript:void(0);">Close</a>
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
		strQuery = "SELECT id, note, name, dateAdded, dateUpdated, readOnly from " & tableName & " a WHERE experimentId="&SQLClean(experimentId,"N","S") &_
				" AND NOT EXISTS (SELECT 1 FROM itemsToRemove r WHERE r.itemId = a.id AND r.itemType='note' AND r.experimentId=a.experimentId AND r.experimentType=" & SQLClean(experimentType,"N","S") & " AND r.pre=0) ORDER BY dateAddedServer DESC"
	Else
		strQuery = "SELECT id, note, name, dateAdded, dateUpdated, readOnly from " & historyTableName & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionId,"N","S") & " ORDER BY dateAddedServer DESC"
	End If
	Set attachmentRec = server.CreateObject("ADODB.Recordset")
	attachmentRec.open strQuery,conn,3,3
	counter = 0
	Do While Not attachmentRec.eof
		counter = counter + 1
		%>
			<tr id="note_<%=attachmentRec("id")%>_tr">
				<%note = HTMLDecode(attachmentRec("note"))%>
				<%
				If attachmentRec("name") = "" Then
					noteName = "Untitled"
				Else
					noteName = attachmentRec("name")
				End if
				%>
				<td><a href="javascript:void(0)" onclick="toggleNote('note_<%=attachmentRec("id")%>');return false;" id="note_<%=attachmentRec("id")%>_a"><%=maxChars(noteName,40)%></a><br><span id="note_<%=attachmentRec("id")%>_description_preview"><%=maxChars(removeTags(note),50)%></span><%If Len(note) >50 then%>...<%End if%></td>
				<td id="note_<%=attachmentRec("id")%>_date_added">
				<script>setElementContentToDateString("<%="note_"&attachmentRec("id")&"_date_added"%>", "<%=attachmentRec("dateAdded")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
				</td>
				<td id="note_<%=attachmentRec("id")%>_date_updated">
				<script>setElementContentToDateString("<%="note_"&attachmentRec("id")&"_date_updated"%>", "<%=attachmentRec("dateUpdated")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
				</td>
				<td class="uploadButtons">
					<%If revisionId = "" And (ownsExp or isCollaborator) then%>
						<%If attachmentRec("readOnly") = 0 then%>
							<a href="javascript:void(0);" onclick = "return removeTableItem('<%=mainAppPath%>/experiments/ajax/do/removeNote.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&noteId=<%=attachmentRec("id")%>','note_<%=attachmentRec("id")%>_tr')" class="littleButton">Remove</a>
						<%End if%>
					<%End if%>
				</td>
			</tr>
			<tr>
				<td height="1px" style="height:1px;line-height:1px;" colspan="4" id="note_<%=attachmentRec("id")%>_td">
					<div id="note_<%=attachmentRec("id")%>" style="display:none;">
					<%taStr = attachmentRec("note")%>
					<%If revisionId = "" and canWrite And attachmentRec("readOnly") = 0 then%>
						<div class="attachDescriptionTitle">Name</div>
						<input type="text" name="note_<%=attachmentRec("id")%>_name" id="note_<%=attachmentRec("id")%>_name" value="<%=draftSet("note_"&attachmentRec("id")&"_name",attachmentRec("name"))%>" class="attachmentNameTextBox" onkeydown='setNoteName("note_<%=attachmentRec("id")%>_name")'>
						<div class="attachDescriptionTitle">Description</div>
						<textarea style="width:780px;height:100px;" name="note_<%=attachmentRec("id")%>_description" id="note_<%=attachmentRec("id")%>_description"><%=draftSet("note_"&attachmentRec("id")&"_description",taStr)%></textarea>
						<input type="hidden" name="note_<%=attachmentRec("id")%>_description_loaded" id="note_<%=attachmentRec("id")%>_description_loaded" value="0">
						<script type="text/javascript">//CKEDITOR.replace('note_<%=attachmentRec("id")%>_description',{toolbar : 'arxspanToolbar'});//CKEDITOR.instances['note_<%=attachmentRec("id")%>_description'].on('change',function(e){unsavedChanges=true;})</script>
						<div class="attachmentTableButtons">
						<a class="createLink" onclick="clickSave();" href="javascript:void(0);">Save</a><a class="createLink" onclick="toggleNote('note_<%=attachmentRec("id")%>');return false;" href="javascript:void(0);">Close</a>
						</div>
					<%else%>
						<%If attachmentRec("readOnly") = 0 then%>
						<%=HTMLDecode(taStr)%>
						<%else%>
						<input type="hidden" name="note_<%=attachmentRec("id")%>_name" id="note_<%=attachmentRec("id")%>_name" value="<%=attachmentRec("name")%>">
						<textarea style="display:none;" name="note_<%=attachmentRec("id")%>_description" id="note_<%=attachmentRec("id")%>_description"><%=taStr%></textarea>
						<%=taStr%>
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
<script type="text/javascript">
	attachEdits(document.getElementById("noteTable"))
</script>
</table>
<!-- #include file="../../../_inclds/experiments/common/asp/saveExperimentJSON.asp"-->