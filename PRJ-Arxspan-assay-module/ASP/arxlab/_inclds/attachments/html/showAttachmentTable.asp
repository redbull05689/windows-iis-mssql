<!-- #include file="attachmentTableJS.asp"-->
<!-- #include file="../../security/functions/fnc_checkCoAuthors.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
revisionId = request.querystring("revisionId")
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
ownsExp = ownsExperiment(experimentType, experimentId, session("userId"))

isCollaborator = False
If experimentType = 5 Then
	isCollaborator = checkCoAuthors(experimentId, experimentType,"showAttachmentTable")
End If

canWrite = (ownsExp Or isCollaborator) And revisionId = ""

Dim dicUserName
Set dicUserName = CreateObject("Scripting.Dictionary")
Dim dicCompanyId
Set dicCompanyId = CreateObject("Scripting.Dictionary")
Dim dicFolderInfo
Set dicFolderInfo = CreateObject("Scripting.Dictionary")

'muf
Function getUserName(userId)
	If dicUserName.Exists(userId) Then
		getUserName = dicUserName.Item(userId)
	Else
		Set uuRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT firstName,lastName from users WHERE id="&SQLClean(userId,"N","S")
		uuRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
		If Not uuRec.eof Then
			userName = uuRec("firstName")&" "&uuRec("lastName")
		Else 
			userName = ""
		End if
		dicUserName.Add userId, userName
		getUserName = userName
	End If
End Function

Function getCompanyId(userId)
	If dicCompanyId.Exists(userId) Then
		getCompanyId = dicCompanyId.Item(userId)
	Else
		companyId = getCompanyIdByUser(userId)
		dicCompanyId.Add userId, companyId
		getCompanyId = companyId
	End if
End Function

Function getFilePath(exType, experimentId, revisionNumber, actualFileName, userId)
	'get the attachments file path for a specified attachment, for display inside browser
	if actualFileName = "" Then
		getFilePath = ""
	Else
		getFilePath = uploadRootRoot & "\" & getCompanyId(userId) & "\" & userId & "\" & experimentId & "\" & revisionNumber & "\" & exType & "\" & actualFileName
	End if
end function

function getAttachmentFileExt(fileName)
	getAttachmentFileExt = Replace(getFileExtension(fileName),".","")
End function

Sub getFolderInfo(folderId)
	if folderId & "" <> "" then
		If dicFolderInfo.Exists(folderId) Then
			fName = dicFolderInfo.Item(folderId)
			fullPath = dicFolderInfo.Item(folderId & "_fullPath")
			parentFolderId = dicFolderInfo.Item(folderId & "_parentFolderId")
			folderList = dicFolderInfo.Item(folderId & "_folderList")
		Else
			strQuery = "SELECT folderName, fullPath, parentFolderId FROM attachmentFolders WHERE id="&SQLClean(folderId,"N","S")
			Set rec = server.CreateObject("ADODB.Recordset")
			rec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly,adCmdText
			If Not rec.eof Then
				fName = rec("folderName")
				fullPath = rec("fullPath")
				parentFolderId = rec("parentFolderId")
				folderList = getParentFolderId(parentFolderId, experimentId, experimentType, "")
				
				dicFolderInfo.Add folderId, fName
				dicFolderInfo.Add folderId & "_fullPath", fullPath
				dicFolderInfo.Add folderId & "_parentFolderId", parentFolderId
				dicFolderInfo.Add folderId & "_folderList", folderList
			Else
				dicFolderInfo.Add folderId, ""
				dicFolderInfo.Add folderId & "_fullPath", ""
				dicFolderInfo.Add folderId & "_parentFolderId", ""
				dicFolderInfo.Add folderId & "_folderList", ""
			End If
			rec.close
			Set rec = Nothing
		End If
	end if
End Sub

%>
<script type="text/javascript">
	attachmentJSON = [];
</script>

<div class="tabs elnHead"><h2>Attachments</h2></div>
<table cellpadding="0" cellspacing="0" class="attachmentsIndexTable hideExperimentSectionsInTable" id="sortable">
	<thead>
		<tr>
			<td colspan="7" id="attachmentTableFileUploadRow"> </td>
		</tr>
		<%If experimentType <> 1 Then%>
			<tr class="toggleSectionVisibilityTR">
				<td colspan="7" class="toggleSectionVisibilityTD">
					<div class="toggleSectionVisibilityContainer">
						<input type="checkbox" name="showExperimentSectionsInAttachmentsTable" id="showExperimentSectionsInAttachmentsTable" class="css-checkbox"><label for="showExperimentSectionsInAttachmentsTable" class="css-label checkboxLabel checkboxLabelForShowExperimentSections">Show Experiment Sections To Organize PDF Layout</label>
					</div>
				</td>
			</tr>
		<%End If%>
	
<%
canViewExp = False
If ownsExp Then
	canViewExp = True
Else
	canViewExp = canViewExperiment(experimentType,experimentId,session("userId"))
End If

If canViewExp Then
	prefix = GetPrefix(experimentType)
	experimentTypeName = getAbbreviation(experimentType)
	
	experimentIdCleaned = SQLClean(experimentId,"N","S")
	experimentTypeCleaned = SQLClean(experimentType,"N","S") 
	revisionIdCleaned = SQLClean(revisionId,"N","S")

	Call getconnected
	Set attachmentRec = server.CreateObject("ADODB.Recordset")

	if revisionId = "" Then
		attachmentTable = "attachments"
		attachmentTable = GetFullname(prefix, attachmentTable, true)
		attachmentPresaveTable = "attachments_preSave"
		attachmentPresaveTable = GetFullName(prefix, attachmentPresaveTable, true)
		' Ticket 5076 field description appears twice in the following select, remove one of them.
		' Don't use the exeprimentType from the attachment table in the sub-query becuase it can be NULL.
		If experimentType = 5 Then
				strQuery = "SELECT *, ISNULL(sortOrder, (SELECT MIN(sortOrder) FROM experimentContentSequence WHERE experimentType=" & experimentTypeCleaned & " AND experimentId=" & experimentIdCleaned & " AND attachmentId=unionTable.Id)) AS sOrder" &_
					" FROM (SELECT id, actualFileName, filesize, description, checkedOut, RevisionNumber, filename, userId, dateUploaded, dateUploadedServer, sortOrder, name, folderId, 0 AS pre, hideInPdf, checkedOutUser FROM " & attachmentTable & " a WHERE experimentId=" & experimentIdCleaned &_
					" AND NOT EXISTS (SELECT 1 FROM itemsToRemove r WHERE r.itemId = a.id AND r.itemType='attachment' AND r.experimentId=a.experimentId AND r.experimentType=" & experimentTypeCleaned & " AND r.pre=0)" &_
					" UNION ALL SELECT id, actualFileName, filesize, description, checkedOut, RevisionNumber, filename, userId, dateUploaded, dateUploadedServer, sortOrder, name, folderId, 1 as pre, 0 AS hideInPdf, 0 AS checkedOutUser FROM " & attachmentPresaveTable & " WHERE experimentId=" & experimentIdCleaned &") unionTable" &_
					" WHERE id NOT IN (SELECT attachmentId FROM attachmentsToHide WHERE experimentId=" & experimentIdCleaned &" AND experimentType=" & experimentTypeCleaned &")"
		Else
				strQuery = "SELECT *, ISNULL(sortOrder, (SELECT MIN(sortOrder) FROM experimentContentSequence WHERE experimentType=" & experimentTypeCleaned & " AND experimentId=" & experimentIdCleaned & " AND attachmentId=unionTable.Id)) AS sOrder" &_
					" FROM (SELECT id, actualFileName, filesize, description, checkedOut, RevisionNumber, filename, userId, dateUploaded, dateUploadedServer, sortOrder, name, folderId, 0 AS pre, hideInPdf, 0 AS checkedOutUser FROM " & attachmentTable & " a WHERE experimentId=" & experimentIdCleaned &_
					" AND NOT EXISTS (SELECT 1 FROM itemsToRemove r WHERE r.itemId = a.id AND r.itemType='attachment' AND r.experimentId=a.experimentId AND r.experimentType=" & experimentTypeCleaned & " AND r.pre=0)" &_
					" UNION ALL SELECT id, actualFileName, filesize, description, checkedOut, RevisionNumber, filename, userId, dateUploaded, dateUploadedServer, sortOrder, name, folderId, 1 as pre, 0 AS hideInPdf, 0 AS checkedOutUser FROM " & attachmentPresaveTable & " WHERE experimentId=" & experimentIdCleaned & ") unionTable" &_
					" WHERE id NOT IN (SELECT attachmentId FROM attachmentsToHide WHERE experimentId=" & experimentIdCleaned &" AND experimentType=" & experimentTypeCleaned &")"
		End If
	Else
		attachmentTable = "attachments_history"
		attachmentTable = GetFullName(prefix, attachmentTable, true)
		strQuery = "SELECT id, originalRevisionNumber, actualFileName, filesize, description, RevisionNumber, filename, userId, dateUploaded, dateUploadedServer, sortOrder, name, folderId, 0 AS pre, hideInPdf, 0 AS checkedOutUser," &_
				" ISNULL(sortOrder, (SELECT MIN(sortOrder) FROM experimentContentSequence_history WHERE experimentType=" & experimentTypeCleaned & " AND experimentId=" & experimentIdCleaned & " AND revisionNumber=" & revisionIdCleaned & " AND attachmentId=a.Id)) AS sOrder" &_
				" FROM " & attachmentTable & " a  WHERE experimentId=" & experimentIdCleaned & " AND revisionNumber=" & revisionIdCleaned
	End If

	attachmentRec.CursorLocation = adUseClient
	attachmentRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
	attachmentRec.Sort = "sortOrder,dateUploadedServer DESC"
	numAttachments = 0

	'Grab the draft to make sure we have any draft data
	Set draftRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT experimentJSON from experimentDrafts WHERE experimentId=" & experimentIdCleaned & " AND experimentType=" & experimentTypeCleaned
	draftRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly,adCmdText
	If Not draftRec.eof Then
		set draftExperimentJSON = JSON.parse(draftRec("experimentJSON"))
		draftAuthorUserId = draftExperimentJSON.get("userId")	
	else
		set draftExperimentJSON = JSON.parse("{}")
		draftAuthorUserId = ""
	End If
	draftRec.Close
	Set draftRec = Nothing

	Do While Not attachmentRec.eof
		set fancyTreeJSON = JSON.parse("{}")
		preLabel = ""
		preQS = ""
		If revisionId = "" Then
			If attachmentRec("pre") = 1 Then
				isPre = True
				preLabel = "p_"
				preQS = "&pre=true"
			Else
				isPre = False
			End if
		Else
			isPre = false
		End if
		numAttachments = numAttachments + 1

		ext = getAttachmentFileExt(attachmentRec("filename"))

		If IsObject(experimentJSON) Then
			If IsNull(attachmentRec("sortOrder")) And experimentJSON.Get("file_"&preLabel&attachmentRec("id")&"_sortOrder") = "" then
				sOrder = attachmentRec("sOrder")
			else
				sOrder = draftSet("file_"&preLabel&attachmentRec("id")&"_sortOrder",attachmentRec("sortOrder"))
			end if
		End If
			
		fName = ""
		parentFolderName = ""
		parentFolderId = ""

        if attachmentRec("folderId") <> "" then
			getFolderInfo(attachmentRec("folderId"))
		end if

		'1st td	
		column1val = "<td class=""icons"" valign=""top"" colspan=""2""><span class=""file_"&preLabel&attachmentRec("id")&"_tr_span""><input type=""text"" id=""file_"&preLabel&attachmentRec("id")&"_sortOrder"" name=""file_"&preLabel&attachmentRec("id")&"_sortOrder"" style=""display: none;"" value="""&sOrder&""" class=""sortOrder""><img src="&getAttachmentTableFileTypeIcon(ext)&" border=""0"" class=""png"" style='vertical-align:middle'>"
			
		'2nd td		
		taStr = attachmentRec("description")
		attachmentName = draftSet("file_"&preLabel&attachmentRec("id")&"_name",attachmentRec("name"))
		If attachmentName = "" Then
			attachmentName = "Untitled"
		End if
					
		'column2val = "<td class=""nameDescription"">"	
		column2val = "<span class=""nameDescription"" style=""display: inline-block; padding-left:15px"">"	
		If isPre And canWrite then
			column2val = column2val & "<input type=""text"" name=""file_"&preLabel&attachmentRec("id")&"_name_quick"" id=""file_"&preLabel&attachmentRec("id")&"_name_quick"" value="""&attachmentName&""" style=""display:none;"" class=""attachmentName"" onkeypress=""if (event.keyCode == 13){sendAutoSave('file_"&preLabel&attachmentRec("id")&"_name',this.value);finishEditAttachmentName('file_"&preLabel&attachmentRec("id")&"_name_quick','"&attachmentRec("id")&"');return false;}""><a href=""javascript:void(0)"" onclick=""toggleNodeViewInlineAttachment('file_"&preLabel&attachmentRec("id")&"');return false;"" class=""fileName"" id=""file_"&preLabel&attachmentRec("id")&"_name_quick_link"">"&attachmentName&"</a><a href=""javascript:void(0);"" onclick=""editAttachmentName('file_"&preLabel&attachmentRec("id")&"_name_quick','"&attachmentRec("id")&"');return false;"" id=""file_"&preLabel&attachmentRec("id")&"_name_quick_image_link"" style=""margin-left:5px;""><img border=""0"" src=""images/btn_edit.gif"" id=""file_"&preLabel&attachmentRec("id")&"_name_quick_image""></a>"
			If StrComp(attachmentName,attachmentRec("filename")) <> 0 Then
				column2val = column2val & "<br/>"&attachmentRec("filename")
			End If
		Else
			column2val = column2val & "<a href='javascript:void(0)' class=""fileName"" onclick=""toggleNodeViewInlineAttachment('file_"&preLabel&attachmentRec("id")&"');return false;"" >" & attachmentName& "</a>"
			If Not isPre And revisionId="" And canWrite then
				' fancytreeShowAttachment sets up the CK EDTOR (and loads the actual attachment)
				column2val = column2val & "<a href=""javascript:void(0);"" onclick=""fancytreeShowAttachment('file_" & attachmentRec("id") & "');showPopup('fileDescription_"&preLabel & attachmentRec("id") & "');return false;"" style=""margin-left:5px;""><img border=""0"" src=""images/btn_edit.gif"" ></a>"
			End If
			If StrComp(attachmentName,attachmentRec("filename")) <> 0 Then
				column2val = column2val & "<br/>"&attachmentRec("filename")
			End If
		End if
            
        'muf
		If session("hasMUFExperiment") And experimentType="3" then
			column2val = column2val & "<br/>User: "&getUserName(attachmentRec("userId"))
		End if
		
		column2val = column2val & "</span></span>"
		column2val = column2val & "</td>"

		'3rd TD
		col3id = "file_"&attachmentRec("id")&"_TD"
		If isPre Then
			col3id = "file_"&preLabel&attachmentRec("id")&"_TD"
		End If
		%>
		<script>
		attachmentTableTimeStamps.push({"id":"<%=col3id%>","date":"<%=attachmentRec("dateUploaded")%>","displayUTC":<%If session("useGMT") Then%>true<%else%>false<%end if %>});
		</script>
		<%
		column3val = "<td id="""&col3id&""" class=""uploadDate""></td>"
		'4th TD
		column4val = "<td class=""filesSize"">"&attachmentRec("filesize")&"<img src=""../../../arxlab/images/loading.gif"" align=""middle"" id=""Loading_"&attachmentRec("id")&""" style=""display:none;""></td>"
		'5th TD
		'column5val = "<td><a href='javascript:void(0)' onclick=""showPopup('fileDescription_"&preLabel & attachmentRec("id") & "');return false;"" class='littleButton'>Edit Details</a></td>"
		'6th TD
		column6val = "<td class=""uploadButtons"" style=""white-space: nowrap;"">"
		If revisionId = "" then
			If (ownsExp or isCollaborator) and canWrite then
				canRemove = True
				If (session("hasMUFExperiment") And session("hideNonCollabExperiments") And Not session("canDelete")) Or (draftAuthorUserId <> "" And draftAuthorUserId <> session("userId")) Then
					canRemove = False
				End if
				If canRemove then
					column6val = column6val & "<a href=""javascript:void(0);"" onclick=""return removeTableItem('"&mainAppPath&"/experiments/ajax/do/removeAttachment.asp?experimentType="&experimentType&"&experimentId="&experimentId&"&attachmentId="&attachmentRec("id")&preQS&"','file_"&preLabel&attachmentRec("id")&"_tr')"" class=""littleButton"">"&removeLabel&"</a>"
				End if
				If Not isPre And revisionId="" then
					'this section does not have any 'pre' labeling
					'for session with live edit Added below buttons					
					
					If attachmentRec("checkedOut")=1 then 
						If experimentType = 5 And (attachmentRec("checkedOutUser") <> session("userId") Or (draftAuthorUserId <> "" And draftAuthorUserId <> session("userId"))) Then
							s1 = "display:none;"
						Else
							s1 = "display:inline;" 
						End If
					else 
						s1 = "display:none;" 
					End if 
						
					If IsNull(attachmentRec("checkedOut")) Or attachmentRec("checkedOut")=0 then 						
						If draftAuthorUserId <> "" And draftAuthorUserId <> session("userId") Then
							s2 = "display:none;" 
						Else
							s2 = "display:inline;" 
						End If
					else 
						s2 = "display:none;" 
					End if

					'Has live edit buttons
					if attachmentRec("description") = "" then
						Adescription = ""
					else  
						Adescription = Base64Encode(attachmentRec("description"))								
					end if

					attachmentFilePath = getFilePath(experimentTypeName, experimentId, attachmentRec("RevisionNumber"), attachmentRec("actualFileName"), attachmentRec("userId"))
					fileExt = getFileExtension(attachmentFilePath)		

					column6val = column6val & "<span class=""liveEdit""><a href=""javascript:void(0)"" onclick=""attachmentCheckIn('"&experimentId&"', '"&experimentType&"', '"&attachmentRec("id")&"', '"&SQLClean(attachmentRec("filename"),"JS","")&"', '"&SQLClean(attachmentRec("name"),"JS","")&"', '"&Adescription&"', '"&attachmentRec("sortOrder")&"', '"&attachmentRec("folderId")&"', '"&fileExt&"');"" id=""checkInChrome_"&attachmentRec("id")&""" class=""littleButton checkButton"" style="&s1&">Check In</a>"&_
						"<a href=""javascript:void(0)"" onclick=""swal({title: 'Are you sure?', text: 'This will permanently remove any unsaved changes to this file. This cannot be undone.',type: 'warning', showCancelButton: true, confirmButtonColor: '#DD6B55', confirmButtonText: 'Yes, Discard Check-Out', closeOnConfirm: true},function(){ window.postMessage({ message_type: 'delete', file:'" & experimentType & "-" & attachmentRec("id") & fileExt &"'}, '*');doDiscard_chrome(''+"&attachmentRec("id")&", ''+"&experimentType&");});"" id=""discardChrome_"&attachmentRec("id")&""" class=""littleButton checkButton"" style="&s1&">Discard Check-Out</a>"&_
						"<a href=""javascript:void(0)"" onclick=""attachmentCheckOut('"&attachmentRec("id")&"', '"&experimentType&"', '"&fileExt&"','"&experimentId&"')"" id=""checkOutChrome_"&attachmentRec("id")&""" class=""littleButton checkButton"" style='"&s2&"'>Check Out</a></span>"
						
					'Does not have live edit buttons
					column6val = column6val & "<a href=""javascript:void(0)"" onclick=""showPopup('addFileDiv_" & preLabel&attachmentRec("id") & "'); return false;"" class=""littleButton noLiveEdit"">"&replaceLabel&"</a>"

					If bCheck <> "IE 8.0" And canDisplayInBrowser(attachmentRec("filename")) then
						column6val = column6val & "<a href=""javascript:void(0)"" onclick=""newSketch("&attachmentRec("id")&",false);return false;"" class=""littleButton"">"&annotateLabel&"</a>"
					End if

					If experimentType = 5 And attachmentRec("checkedOut") = 1 Then
						If Not IsNull(attachmentRec("checkedOutUser")) And attachmentRec("checkedOutUser") <> session("userId") Then
							column6val = column6val & "File checked out by " & getUserName(attachmentRec("checkedOutUser")) & "."								
						Else
							column6val = column6val & "File checked out for changes."
						End If
					End If
				End if
			End if
			column6val = column6val & "<a href="""&mainAppPath&"/experiments/ajax/load/getSourceFile.asp?id="&attachmentRec("id")&"&experimentType="&experimentType&preQS&""" class=""littleButton"">"&downloadLabel&"</a>"
		else
			column6val = column6val & "<a href="""&mainAppPath&"/experiments/ajax/load/getSourceFile.asp?id="&attachmentRec("id")&"&experimentType="&experimentType&"&history=true"" class=""littleButton"">"&downloadLabel&"</a>"
		End if

		hideId = "file_" & attachmentRec("id") & "_hide"
		%>
		<script>
			var fileKey = "file_<%=attachmentRec("id")%>_hideInPdf";
			var hideFile = "<%=attachmentRec("hideInPdf")%>";
			//experimentJSON[fileKey] = "<%=attachmentRec("hideInPdf")%>" == "1";

			<% If request.querystring("revisionId") = "" And (ownsExp or isCollaborator) then
				if draftExperimentJSON.get(hideId & "InPdf") <> "" then %>
					experimentJSON[fileKey] = <%=draftExperimentJSON.get(hideId & "InPdf")%>;
				<% else %>
					experimentJSON[fileKey] = "<%=attachmentRec("hideInPdf")%>" == "1";
				<% end if				
			End if %>
		</script>
		<%
		if not isPre and revisionId = "" and (ownsExp or isCollaborator) and Not (draftAuthorUserId <> "" And draftAuthorUserId <> session("userId")) then
			column6val = column6val & "<br><div class='PDFHideDiv'><input type='checkbox' id='" & hideId & "'{isChecked} onchange='saveHiddenVal(""" & hideId & """)'}'><label for='" & hideId & "' class='PDFHideLabel'>Hide in PDF</label></div>"

			'draft logic
			if draftExperimentJSON.get(hideId & "InPdf") <> "" then
				if draftExperimentJSON.get(hideId & "InPdf") = "true" then
					column6val = Replace(column6Val, "{isChecked}", " checked")
				else
					column6val = Replace(column6Val, "{isChecked}", "")
				end if
			else
				if attachmentRec("hideInPdf") = "1" then
					column6val = Replace(column6Val, "{isChecked}", " checked")
				else
					column6val = Replace(column6Val, "{isChecked}", "")
				end if
			end if
		end if

		column6val = column6val & "</td>"

		If (ownsExp Or isCollaborator) and Not (draftAuthorUserId <> "" And draftAuthorUserId <> session("userId")) then
			column7val = "<td class=""grabBars""><img src=""images/reorderGrabBars.png"" border=""0"" class=""png""></td>"
		End if

		fancyTreeJSON.set "trVal", column1val&column2val&column3val&column4val&column5val&column6val&column7val
		fancyTreeJSON.set "trId", "file_"&preLabel&attachmentRec("id")&"_tr"
		fancyTreeJSON.set "trClass", "attRow"
		fancyTreeJSON.set "folderName", fName
		fId = attachmentRec("folderId")
		aId = attachmentRec("id")
		fancyTreeJSON.set "folderId", fId
		fancyTreeJSON.set "attachmentId", aId
		fancyTreeJSON.set "fullPath", fullPath
		fancyTreeJSON.set "parentFolderId", parentFolderId
		fancyTreeJSON.set "parentFolderName", parentFolderName
		fancyTreeJSON.set "title", column2val
		'order in which attachments has to display
		fancyTreeJSON.set "sortOrder", sOrder
		desc = attachmentRec("description")
		fancyTreeJSON.set "description", desc
		%>
		<script type="text/javascript">
            //Constructing a JSON object and adding new elements
			// This block used to live outside the big if statement for some reason,
			// but if we're not showing an object, why bother adding it to the attachmentJSON?
			attachmentJSON.push(<%=JSON.stringify(fancyTreeJSON) %>);
			attachmentJSON.push(<%=folderList %>);
        </script>
		<%
		'View attachment details
		bOfficeDoc = isOfficeDoc(attachmentRec("filename"))
		bPdf = isPdf(attachmentRec("filename"))
		bChemicalFile = isChemicalFile(attachmentRec("filename"))
		bTextFile = isTextFile(attachmentRec("filename")) 
		%>
		<tr id="file_<%=preLabel%><%=attachmentRec("id")%>_trExpanded" class="expandedRow" style="display:none;">
			<td colspan="6" class="inlineAttachmentView" id="file_<%=preLabel%><%=attachmentRec("id")%>_td">
				<div id="file_<%=preLabel%><%=attachmentRec("id")%>" style="display:none;">
				<div class="popupFormHeader"><%=attachmentRec("filename")%></div>
					<%If revisionId = "" then
						If Not bOfficeDoc And Not bPdf And Not bChemicalFile And Not bTextFile Then
							If canDisplayInBrowser(attachmentRec("filename")) Then%>
							<div style="width: 780px">
								<img src="images/loading.gif" style="display:block;margin:auto;" id="file_<%=preLabel%><%=attachmentRec("id")%>_att" />
							</div>
							<span style="display:none;" id="file_<%=preLabel%><%=attachmentRec("id")%>_src"><%=mainAppPath%>/experiments/ajax/load/getImage.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%><%=preQS%></span>
							<%else%>
							<div class="inviteDiv" style="border:5px solid black;">
								<span style="display:block;">We are unable to display this file in your browser.  Would you like to download it?</span>
								<a href="<%=mainAppPath%>/experiments/ajax/load/getSourceFile.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%><%=preQS%>" class="downloadButton">Download</a>
							</div>
							<%End if
						else
							If Not (bChemicalFile AND session("noChemDraw")) Then
								If session("noPdf") then
								else%>
									<iframe src="<%=mainAppPath%>/static/loading.html" width="100%" height="600" style="border:none;" class="officeFrame" id="file_<%=preLabel%><%=attachmentRec("id")%>_att"></iframe>
								<%End if
							End if
							If Not bChemicalFile Then
								If session("noPdf") then%>
									<div class="inviteDiv" style="border:5px solid black;">
										<span style="display:block;">We are unable to display this file in your browser, because your pdf viewer is too old.  Download?</span>
										<a href="<%=mainAppPath%>/experiments/ajax/load/getSourceFile.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%><%=preQS%>" class="downloadButton">Download</a>
									</div>
								<%else
									If bOfficeDoc or bPdf Then
										iod = "1"
									Else
										iod = "0"
									End if
									%>
								<span style="display:none;" id="file_<%=preLabel%><%=attachmentRec("id")%>_src"><%=mainAppPath%>/experiments/waitPreview.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%>&isOfficeDoc=<%=iod%><%=preQS%></span>
								<%End if
							else
								If Not session("noChemDraw") then%>
									<span style="display:none;" id="file_<%=preLabel%><%=attachmentRec("id")%>_src"><%=mainAppPath%>/experiments/ajax/load/chemDisplay.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%><%=preQS%></span>
								<%Else
									justFileName = Replace(attachmentRec("actualFileName"),getFileExtension(attachmentRec("actualFileName")),"")
									imageFileName = uploadRootRoot&"\"&getCompanyId(session("userId"))&"\"&attachmentRec("userId")&"\"&experimentId&"\"&attachmentRec("RevisionNumber")&"\"&experimentTypeName&"\" & justFileName & "_image.gif"
									%>
									<div id="<%=justFileName%>"></div>
									<script type="text/javascript">
										window.<%="file_"&preLabel&attachmentRec("id")&"_getChemImage"%> = function() {
											return new Promise(function(resolve, reject) {
												$.get("<%=mainAppPath%>/experiments/ajax/load/getChemAttachmentImagePNG.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&justFileName=<%=justFileName%><%=preQS%>", function( data ) {
													var img = $('<img id="width:100%">');
													img.attr('src', data);
													$('#<%=justFileName%>').html(img);
													resolve(true);
												});
											});
										}
									</script>	
									<%
									Set fs = nothing
								End if
							End if
						End if
					Else
						If Not bOfficeDoc And Not bPdf And Not bChemicalFile And Not bTextFile Then
							If canDisplayInBrowser(attachmentRec("filename")) Then%>	
							<div style="width: 780px">
								<img src="images/loading.gif" style="display:block;margin:auto;" id="file_<%=preLabel%><%=attachmentRec("id")%>_att" />
							</div>								
							<span style="display:none;" id="file_<%=preLabel%><%=attachmentRec("id")%>_src"><%=mainAppPath%>/experiments/ajax/load/getImage.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%>&history=true<%=preQS%></span>
							<%Else%>
							<div class="inviteDiv" style="border:5px solid black;">
								<span style="display:block;">We are unable to display this file in your browser.  Would you like to download it?</span>
								<a href="<%=mainAppPath%>/experiments/ajax/load/getSourceFile.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%>&history=true<%=preQS%>" class="downloadButton">Download</a>
							</div>
							<%End if
						Else
							If Not (bChemicalFile AND session("noChemDraw")) Then
								If session("noPdf") Then
								Else%>
									<iframe src="<%=mainAppPath%>/static/loading.html" width="100%" height="600" style="border:none;" class="officeFrame" id="file_<%=preLabel%><%=attachmentRec("id")%>_att"></iframe>
								<%End if
							End if
							If Not bChemicalFile Then
								If session("noPdf") Then%>
									<div class="inviteDiv" style="border:5px solid black;">
										<span style="display:block;">We are unable to display this file in your browser, because your pdf viewer is too old.  Download?</span>
										<a href="<%=mainAppPath%>/experiments/ajax/load/getSourceFile.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%>&history=true<%=preQS%>" class="downloadButton">Download</a>
									</div>
								<%Else
									If bOfficeDoc or bPdf Then
										iod = "1"
									Else
										iod = "0"
									End if
									%>
									<span style="display:none;" id="file_<%=preLabel%><%=attachmentRec("id")%>_src"><%=mainAppPath%>/experiments/waitPreview.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%>&history=true&isOfficeDoc=<%=iod%><%=preQS%></span>
								<%End if
							Else
								If Not session("noChemDraw") Then%>
									<span style="display:none;" id="file_<%=preLabel%><%=attachmentRec("id")%>_src"><%=mainAppPath%>/experiments/ajax/load/chemDisplay.asp?id=<%=attachmentRec("id")%>&experimentType=<%=experimentType%>&history=true<%=preQS%></span>
								<%Else
									set fs=Server.CreateObject("Scripting.FileSystemObject")
									imageFileName = uploadRootRoot&"\"&getCompanyId(session("userId"))&"\"&attachmentRec("userId")&"\"&experimentId&"\"&attachmentRec("originalRevisionNumber")&"\"&experimentTypeName&"\"&Replace(attachmentRec("actualFileName"),getFileExtension(attachmentRec("actualFileName")),"_image.gif")
									If fs.FileExists(imageFileName)=true Then %>
										<img src="<%=mainAppPath%>/experiments/ajax/load/getChemAttachmentImage.asp?imagefilename=<%=imageFileName%>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%><%=preQS%>" width="760">
									<% else 
									justFileName = Replace(attachmentRec("actualFileName"),getFileExtension(attachmentRec("actualFileName")),"")
									%>
									<div id="<%=justFileName%>"></div>
									<script>
										function <%="file_"&preLabel&attachmentRec("id")&"_getChemImage"%>() {
											return new Promise(function(resolve, reject) {
												$.get("<%=mainAppPath%>/experiments/ajax/load/getChemAttachmentImagePNG.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&justFileName=<%=justFileName%><%=preQS%>", function( data ) {
													var img = $('<img id="width:100%">');
													img.attr('src', data);
													$('#<%=justFileName%>').html(img);
													resolve(true);
												});
											});
										}
									</script>		
									<% End If
									Set fs = nothing
								End if
							End if
						End if
					End if%>
				</div>
			</td>
		</tr>
		<%'Edit attachment name gray screen issue ELN - 1369
		%>
		<div id="fileDescription_<%=preLabel%><%=attachmentRec("id")%>" class="popupDiv popupBox">
			<div class="popupFormHeader"><%=attachmentRec("filename")%></div>
			<div class="attachDescriptionTitle">Name</div>
			<input type="text" name="file_<%=preLabel%><%=attachmentRec("id")%>_folderId" id="file_<%=preLabel%><%=attachmentRec("id")%>_folderId" style="display: none;" value="<%=draftSet("file_"&preLabel&attachmentRec("id")&"_folderId",attachmentRec("folderId"))%>" class="attachmentFolderIdTextBox">
			<%If revisionId = "" then%>
				<input type="text" name="file_<%=preLabel%><%=attachmentRec("id")%>_name" id="file_<%=preLabel%><%=attachmentRec("id")%>_name" value="<%=draftSet("file_"&preLabel&attachmentRec("id")&"_name",attachmentRec("name"))%>" class="attachmentNameTextBox">
			<%else%>
				<%="<p>"&attachmentRec("name")&"</p>"%>
			<%End if%>
			<div class="attachDescriptionTitle">Description</div>
			<%taStr = attachmentRec("description")%>
			<%If revisionId = "" and (ownsExp Or isCollaborator) then%>
				<textarea style="width:800px;height:150px;" name="file_<%=preLabel%><%=attachmentRec("id")%>_description" id="file_<%=preLabel%><%=attachmentRec("id")%>_description"> <%=draftSet("file_"&preLabel&attachmentRec("id")&"_description",attachmentRec("description"))%> </textarea>
				<input type="hidden" name="file_<%=preLabel%><%=attachmentRec("id")%>_description_loaded" id="file_<%=preLabel%><%=attachmentRec("id")%>_description_loaded" value="0">
			<%else%>
				<%=taStr%>
			<%End if
			If (ownsExp Or isCollaborator) And revisionId="" then%>
				<div class="attachmentTableButtons">
					<a class="createLink" onclick="clickSave();" href="javascript:void(0);">Save</a>
				</div>
			<%End if%>
		</div>
	<%	
		' When an experiment contains many attachments, we got "Response Buffer Limit Exceeded" error. Avoid this by doing Response.Flush after each attachment record.
		Response.Flush

		attachmentRec.movenext
	Loop
	attachmentRec.close
	Set attachmentRec = nothing
	%>
	</thead>
	<tbody>
	<%'This empty tr is needed for fancytree%>
	<tr>
	<td></td>
	<td></td>
	<td></td>
	<td></td>
	<td></td>
	<!-- <td></td> -->
	<%If ownsExp then%>
		<td></td>
	<%end if%>
	</tr>
	<%
	
	' The order of everything is already right on the server, except the sections are missing from the queries done above, so we have to grab them from one of these places:
	' 1. Hardcoded here because the user hasn't uploaded or dragged around any files ever, OR because the experiment hasn't been run with this new code before so there were no sections found in the experiment JSON and nothing in either of the experimentContentSequence tables
	' 2. The experiment JSON, because there is no revisionId and it exists, which means it's the most recent sort order
	' 3. The "experimentContentSequence" table because there is no revisionId and no experiment JSON to overrule what's in the table
	' 4. The "experimentContentSequence_history" table because there's a revisionId
	' All along, the DB sortOrder values & experiment JSON sortOrder values should be in sync because saveDrafts runs every time a file is uploaded or rows are reordered, which updates the experiment JSON and all the attachment tables have values saved based on that
	Function addExperimentFieldToAttachmentsTable(experimentFieldName, fieldSortOrder)
		addExperimentFieldToAttachmentsTable = "<td colspan=""7"" class=""expSectionCell""><input type=""text"" id=""section_" & experimentFieldName & "_sortOrder"" name=""section_" & experimentFieldName & "_sortOrder"" value=""" & fieldSortOrder & """ style=""display:none;"" class=""sortOrder""><div class=""expSectionLabel"">[SECTION]</div><div class=""expSectionTitle"">" & experimentFieldName & "</div>"
		
		' hide the reorder button if there is a draft by another user
		If Not (draftAuthorUserId <> "" And draftAuthorUserId <> session("userId")) Then
			addExperimentFieldToAttachmentsTable = addExperimentFieldToAttachmentsTable + "<img src=""images/reorderGrabBars_light.png"" border=""0"" class=""png expSectionGrabBars"">"
		End If
		addExperimentFieldToAttachmentsTable = addExperimentFieldToAttachmentsTable + "</td>"
		 
		set fancyTreeJSON = JSON.parse("{}")
		fancyTreeJSON.set "trVal", addExperimentFieldToAttachmentsTable
		fancyTreeJSON.set "extraClasses", "attRow expSectionRow COMESFROMCONTENTSEQUENCETABLE"
		fancyTreeJSON.set "trExperimentFieldName", experimentFieldName
		fancyTreeJSON.set "type", "expSectionRow"
		fancyTreeJSON.set "sortOrder", Int(fieldSortOrder)
		
		%>
		<script type="text/javascript">
			//Constructing a JSON object and adding new elements
			attachmentJSON.push(<%=JSON.stringify(fancyTreeJSON) %>);
        </script>
		<%
	End Function

	noSectionSortOrderDataExists = True

	Set contentSequenceRec = server.CreateObject("ADODB.Recordset")
	contentSequenceRec.CursorLocation = adUseClient
	If revisionId <> "" Then
		' if there is a revision ID
		strQuery = "SELECT sortOrder, experimentFieldName FROM experimentContentSequence_history WHERE experimentId=" & experimentIdCleaned &" AND experimentType=" & experimentTypeCleaned & " AND revisionNumber=" & revisionIdCleaned & " AND experimentFieldName IS NOT NULL"
		
		contentSequenceRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
		contentSequenceRec.Sort = "sortOrder DESC"
		Do While Not contentSequenceRec.eof
			noSectionSortOrderDataExists = False
			Call addExperimentFieldToAttachmentsTable(contentSequenceRec("experimentFieldName"), contentSequenceRec("sortOrder"))
			contentSequenceRec.movenext
		Loop
		contentSequenceRec.close
		Set contentSequenceRec = nothing
	Else
		'use the sort order from the drafts is they exist
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT experimentJSON from experimentDrafts WHERE experimentId=" & experimentIdCleaned & " AND experimentType=" & experimentTypeCleaned
		rec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly,adCmdText
		If Not rec.eof Then
			set experimentJSON = JSON.parse(rec("experimentJSON"))
			For Each fieldNameFromJSON In experimentJSON.keys()
				If InStr(1, fieldNameFromJSON, "section_") = 1 Then
					noSectionSortOrderDataExists = False
					experimentFieldName = Replace(fieldNameFromJSON,"section_","")
					experimentFieldName = Replace(experimentFieldName,"_sortOrder","")
					sectionSortOrderVal = experimentJSON.get(fieldNameFromJSON)
					Call addExperimentFieldToAttachmentsTable(experimentFieldName, sectionSortOrderVal)
				End If
			Next
		End If
		rec.close
		Set rec = nothing

		'Update the sort order from the contentSequence if there are no drafts
		if noSectionSortOrderDataExists then
			strQuery = "SELECT sortOrder, experimentFieldName FROM experimentContentSequence WHERE experimentId=" & experimentIdCleaned & " AND experimentType=" & experimentTypeCleaned & " AND experimentFieldName IS NOT NULL"
			contentSequenceRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
			contentSequenceRec.Sort = "sortOrder DESC"
			Do While Not contentSequenceRec.eof
				noSectionSortOrderDataExists = False
				Call addExperimentFieldToAttachmentsTable(contentSequenceRec("experimentFieldName"), contentSequenceRec("sortOrder"))
				contentSequenceRec.movenext
			Loop
			contentSequenceRec.close
			Set contentSequenceRec = nothing
		End if
	End If

	If noSectionSortOrderDataExists = True Then
		' Bio, Free and Anal experiments have unique fields to them, so they have this little select case block here.
		Select Case experimentType
			Case "2"
				Call addExperimentFieldToAttachmentsTable("Protocol","-7")
				Call addExperimentFieldToAttachmentsTable("Summary","-6")
			Case "3"
				Call addExperimentFieldToAttachmentsTable("Description","-6")
			Case "4"
				Call addExperimentFieldToAttachmentsTable("Objective","-7")
				Call addExperimentFieldToAttachmentsTable("Summary","-6")
			Case "5"
				Call addExperimentFieldToAttachmentsTable("Request", "-6")
		End select
		
		' These fields are common to all experiment types though.
		Call addExperimentFieldToAttachmentsTable("Request Links","-5")
		Call addExperimentFieldToAttachmentsTable("Experiment Links","-4")
		Call addExperimentFieldToAttachmentsTable("Registration Links","-3")
		Call addExperimentFieldToAttachmentsTable("Projects","-2")
		Call addExperimentFieldToAttachmentsTable("Notes","-1")
	End If
End if

dicUserName.RemoveAll()
Set dicUserName = Nothing
dicCompanyId.RemoveAll()
Set dicCompanyId = Nothing
dicFolderInfo.RemoveAll()
Set dicFolderInfo = Nothing
%>

<script type="text/javascript">
$(document).ready(function(){
	// File attachments that have just been uploaded will come back with a blank or 0 sortOrder, and we want them at the bottom of the table, so we're assigning them a big sortOrder value - afterwards, calling sortOrder() brings the numbers back down to earth
	var tempAttachmentSortOrderVal = 500;
	$("#sortable tbody tr td input[type='text'].sortOrder").each(function(){
		if($(this).val() == "" || $(this).val() == "0"){
			$(this).val(tempAttachmentSortOrderVal);
			tempAttachmentSortOrderVal++;
		}
	})
	
	//sortTable();
	
	//**fancy tree starts from here**//
	var folderList = [];
	var fancyTreeSource = [];
	var nodeObjects = [];
	var updateFolderId , updateAttachmentId;
	
	console.log("attachmentJSON :: ", attachmentJSON)
	console.log("attachmentJSON Length :: ", attachmentJSON.length)
	
	//Get the all the folderIds 
	for (var i = 0; i < attachmentJSON.length; i++){
		var obj = (attachmentJSON[i]);
		for (var key in obj){
			if (key == "folderId" && obj[key] != "" && obj[key] != "undefined" && obj[key] != null) {
				folderList.push(parseInt(obj[key]));
			}
			
		}
	}
	
	//find the unique folders
	folderList = uniqueArray(folderList);
	console.log ("UNIQUE FOLDER LIST :: ",folderList);
	
	var folderSortId = 0;
	var tempAttachmentSortOrderVal = 500;

	//walk through the attachmentJSON object and create a new object with parent and children in the fancy tree format
	for (var i=0; i<folderList.length; i++){
		var folderListChildren = [];
		var count = 0;
		for (var j = 0; j < attachmentJSON.length; j++){
			var obj = (attachmentJSON[j]);
            // File attachments that have just been uploaded will come back with a blank or 0 sortOrder, and we want them at the bottom of the table, so we're assigning them a big sortOrder value - afterwards, calling sortOrder() brings the numbers back down to earth
			if(obj["sortOrder"] == "" || obj["sortOrder"] == "0") {
				obj["sortOrder"] = tempAttachmentSortOrderVal;
				tempAttachmentSortOrderVal++;
			}
			
			if (obj["folderId"] == folderList[i]) {
				if (count == 0){
					//first attachment sort order is assigned to the folder sortId to keep track of the order
					folderSortId = obj["sortOrder"]
				}
				if (obj["attachmentId"]) {
					folderListChildren.push(obj);
				}
				folderId = obj["folderId"]
				folderName = obj["folderName"]
				parentFolderId = obj["parentFolderId"]
				parentFolderName = obj["parentFolderName"]
				count = 1;
			}
			
			if (j == attachmentJSON.length-1){

				var str = {
					title: "<img src='images/folder.png' width='48' height='48' border='0' class='png' style='vertical-align:middle'>"+folderName,
					folder: true,
					expanded: true,
					folderId: folderId,
					parentFolderId: parentFolderId,
					children: folderListChildren,
					sortOrder: folderSortId
				};
				nodeObjects.push(str);
			}
		}
	}
	
	sortByKey(attachmentJSON, "sortOrder");
	
	for (var i = nodeObjects.length - 1; i >= 0; i--) {
		var currentNode = nodeObjects[i];
		if (currentNode) {
			//Skip over root node.
			if (currentNode.parentFolderId == "") {
				currentNode.folder=true;
				currentNode.expanded=true;
				continue;
			}
			
			while ((child = getChild(currentNode, nodeObjects, null)) != null) {
				var parent = getParent(child, nodeObjects);
				if (parent == null) {
					continue;
				}
				parent.children.push(child);
				popChild(child, nodeObjects)
			};
			
			var parent = getParent(currentNode, nodeObjects);
			if (parent == null) {
				continue;
			}

			parent.children.push(currentNode);
			popChild(currentNode, nodeObjects)
		}
	}
	
	//What remains in nodeObjects will be the root nodes.
	//Form the final object - with adding the files without the folders
	for (var i = 0; i < attachmentJSON.length; i++){
		var obj = (attachmentJSON[i]);
		var alreadyExists = false;
		//if (key == "folderId" && obj[key] != "" && obj[key] != "undefined" && obj[key] != null && parseInt(obj[key]) > 0) {
		if (parseInt(obj["folderId"]) > 0){
			for(var j=0; j<nodeObjects.length; j++){
				if(obj["folderId"] == nodeObjects[j]["folderId"]) {
					if(fancyTreeSource.length == 0){
						fancyTreeSource.push(nodeObjects[j]);
					}
					else {
						for (var k = 0; k<fancyTreeSource.length ; k++){
							if(fancyTreeSource[k]["folderId"] == obj["folderId"]){
								alreadyExists = true
							}
							if(k == fancyTreeSource.length-1 && alreadyExists == false){
								fancyTreeSource.push(nodeObjects[j]);
								/*for (var l = 0; l < fancyTreeSource.length; l++){
									var objExist = (fancyTreeSource[l]);
									//console.log("EXP SEC WITHOUT FOLDER ::: " + objExist["sortOrder"] +" == "+ nodeObjects[j]["sortOrder"]);
									if (parseInt(objExist["sortOrder"]) > nodeObjects[j]["sortOrder"]){
										fancyTreeSource.splice(l, 0, nodeObjects[j]);
										break;
									}
									if(l == fancyTreeSource.length-1){
										fancyTreeSource.push(nodeObjects[j]);
										break;
									}
								}*/
							}
						}
					}
				}
			}
		}
		else {	// its file without a folder
			if (fancyTreeSource.length == 0){
				fancyTreeSource.push(obj)
			}
			else{
				for (var m = 0; m < fancyTreeSource.length; m++){
					var objExist = (fancyTreeSource[m]);
					if (parseInt(objExist["sortOrder"]) > obj["sortOrder"]){
						fancyTreeSource.splice(m, 0, obj);
						break;
					}
					if(m == fancyTreeSource.length-1){
						fancyTreeSource.push(obj);
						break;
					}
				}
	
			}
		}
	}
	
	console.log("fancyTreeSource :: ", fancyTreeSource);
	
	<%If ownsExp Or canViewExp then%>
		//populate the folder table
		var SOURCE = fancyTreeSource,
		CLIPBOARD = null;
		
		$("#sortable").fancytree({
			//titlesTabbable: true,     // Add all node titles to TAB chain
			quicksearch: true,        	// Jump to nodes when pressing first character
			source: SOURCE,
			icon:false,
			generateIds: true, 			// Generate id attributes like <span id='fancytree-id-KEY'>
            idPrefix: "file_",
			
			extensions: ["edit", "dnd", "table", "gridnav"],
			table: {
				indentation: 16        // indent every node level by 16px
			},
			dnd: {
				preventVoidMoves: true, // Prevent dropping nodes 'before self', etc.
				preventRecursiveMoves: true, // Prevent dropping nodes on own descendants
				focusOnClick: true,
				autoExpandMS: 400,
				dragStart: function(node, data) {
					return true;
				},
				dragEnter: function(node, data) {
					// return ["before", "after"];
					return true;
				},
				<%If ownsExp Or isCollaborator then %>
					dragDrop: function(node, data) {
						if (data.hitMode != "over"){
							data.otherNode.moveTo(node, data.hitMode);
							console.log("NODE DATA :: ", data.otherNode);
							if (node.getParent() !== null){
								updateFolderId = (node.getParent()).data.folderId;
								if ((node.getParent()).data.folderId == undefined) {
									updateFolderId = "";
								}
							}
							else {
								updateFolderId = "";
							}
							
							if(data.otherNode.folder == true){
								folderId = data.otherNode.data.folderId;
							}
							else {
								folderId = "";
								updateAttachmentId = data.otherNode.data.attachmentId;
								$("#file_"+updateAttachmentId+"_folderId").val(updateFolderId);
								unsavedChanges = true;
								sendAutoSave(("file_"+updateAttachmentId+"_folderId"), updateFolderId);
							}
							
							//$( "#sortable tbody" ).sortable( "refreshPositions" );
							var sortVal = 0;
							//$("#sortable tbody tr.attRow input[type='text'].sortOrder").each(function () {
							$("#sortable input[type='text'].sortOrder").each(function () {
								sortVal += 1;
								$(this).val(sortVal)
								unsavedChanges = true;
								sendAutoSave($(this).attr("id"), sortVal);
							});
							
							/*$("#sortable tbody tr.attRow td span input[type='text'].sortOrder").each(function () {
								sortVal += 1;
								$(this).val(sortVal)
								unsavedChanges = true;
								sendAutoSave($(this).attr("id"), sortVal);
							});
							*/
							
							$("."+data.otherNode.data.trId+"_span").css("padding-left", (parseInt(data.otherNode.getLevel())-1)*16);
							$("."+data.otherNode.data.trId+"_span_description").css("padding-left", (parseInt(data.otherNode.getLevel())-1)*16 + 6);

							console.log("dragDrop updateAttachmentId :: "+ updateAttachmentId );
							console.log("dragDrop folderId :: "+ folderId );
							console.log("dragDrop updateFolderId :: "+ updateFolderId );
							if (folderId != "" && updateFolderId != "") {
								//send an ajax request to update the database
								url = "<%=mainAppPath%>/ajax_doers/updateAttachmentTableWithFolderId.asp?attachmentId="+updateAttachmentId+"&parentFolderId="+updateFolderId+"&folderId="+folderId+"&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>";
								var update = postDataToFile(url);
								if(update=="success"){
									console.log("success");
								}
							}
						}
					
					}
				<%end if%>
			},
			edit: {
				triggerStart: ["f2", "shift+click", "mac+enter"],
				close: function(event, data) {
					if( data.save && data.isNew ){
						// Quick-enter: add new nodes until we hit [enter] on an empty title
						$("#sortable").trigger("nodeCommand", {cmd: "addSibling"});
					}
				}
			},
			gridnav: {
				autofocusInput: false,
				handleCursorKeys: true
			},
			createNode: function(event, data) {
				var node = data.node
				if( node.isFolder() ) {
					$tdList = $(node.tr).find(">td");
					<%If ownsExp Or isCollaborator then%>
						var numCols = 4;
						var lastCol = 2;
						$tdList.eq(1).html("<a href='javascript:void(0);removeFolder(" + node.data.folderId + ");' class='littleButton'>Remove</a>");
						$tdList.eq(2).html("<img src='images/reorderGrabBars.png' border='0' class='png'>");
						$tdList.eq(2).addClass("grabBars");
					<%else%>
						var numCols = 6;
						var lastCol = 0;
					<%end if%>
					$tdList.eq(0).prop("colspan", numCols);
					$tdList.eq(lastCol).nextAll().remove();
				}
			},
			renderColumns: function(event, data) {
				var node = data.node
				if (node.data.description != "undefined" && (node.data.description) != undefined){
					if((node.data.description).length > 0){
						$(node.tr).html("<td colspan='6'><table class='hasDescription'><tr>"+node.data.trVal+"</tr><tr><td colspan='6'><span class='"+node.data.trId+"_span_description'>"+$("<div>" + htmlDecode(node.data.description) + "</div>").text()+"</span></td></tr></table></td>");
					}
					else {
						$(node.tr).html(node.data.trVal);
					}
				}
				else {
					$(node.tr).html(node.data.trVal);
				}
				$("."+node.data.trId+"_span").css("padding-left", (parseInt(node.getLevel())-1)*16);
				$("."+node.data.trId+"_span_description").css("padding-left", (parseInt(node.getLevel())-1)*16 + 6);
				
				$(node.tr).addClass(node.data.trClass);
				$(node.title).html(node.data.title);
                $(node.tr).attr("experimentfieldname", node.data.trExperimentFieldName);
				if( !node.isFolder() ) {
					$(node.tr).attr("id", node.data.trId)
				}
			}
		}).on("nodeCommand", function(event, data){
			var refNode, moveMode,
			tree = $(this).fancytree("getTree"),
			node = tree.getActiveNode();

			switch( data.cmd ) {
				case "moveUp":
					refNode = node.getPrevSibling();
					if( refNode ) {
						node.moveTo(refNode, "before");
						node.setActive();
					}
				break;
				case "moveDown":
					refNode = node.getNextSibling();
					if( refNode ) {
						node.moveTo(refNode, "after");
						node.setActive();
					}
				break;
				case "indent":
					refNode = node.getPrevSibling();
					if( refNode ) {
						node.moveTo(refNode, "child");
						refNode.setExpanded();
						node.setActive();
					}
				break;
				case "outdent":
					if( !node.isTopLevel() ) {
						node.moveTo(node.getParent(), "after");
						node.setActive();
					}
				break;
			}
		});
	function htmlDecode(input)
	{
	var doc = new DOMParser().parseFromString(input, "text/html");
	return doc.documentElement.textContent;
	}
	<%end if%>
	
	function sortTable(){
		console.log("Inside sortTable");
		//var rows = $("#tree tbody  tr").get();
		//var A = $(a).children("td").eq(n).text().toUpperCase();
		//var B = $(b).children("td").eq(n).text().toUpperCase();
		
		var rows = $("#tree tbody  tr.attRow").get();
		rows.sort(function(a, b) {
			if($(a).find(".sortOrder").val()==""){
				$(a).find(".sortOrder").val("-1")
			}
			if($(b).find(".sortOrder").val()==""){
				$(b).find(".sortOrder").val("-1")
			}
			var A = parseInt($(a).find(".sortOrder").val());
			var B = parseInt($(b).find(".sortOrder").val());
			//fix chrome bug where chrome stops sorting if it encounters a Nan
			if (isNaN(A)){
				A=-9999;
			}
			if (isNaN(B)){
				B=9999;
			}

			if(A < B) {
				return -1;
			}
			if(A > B) {
				return 1;
			}
			return 0;
		});

		$.each(rows, function(index, row) {
			$("#tree").children("tbody").append(row);
			row2 = $("#"+$(row).attr("id")+"Expanded");
			$("#tree").children("tbody").append(row2);
		});
		var sortVal = 0;
		$("#tree tbody tr.attRow .sortOrder").each(function () {
			sortVal += 1;
			$(this).val(sortVal);
			if(typeof sendAutoSave !== "undefined"){
				sendAutoSave($(this).attr("id"), sortVal);
			}
		});
	}

	$.each($(".fileName"), function(i, fileName) {
		var fileSelector = $(fileName);
		var fileText = fileSelector.text();
		fileSelector.text(fileText.substring(0, 40));
	});

    $.each(attachmentTableTimeStamps, function (idx, item) {
        setElementContentToDateString(item["id"], item["date"], item["displayUTC"]);
    });
});

liveEditor.addInstalledCallback(function(args) {
		console.log("btnDisplayCheck...");
		$(".liveEdit").addClass("makeVisible");
		$(".noLiveEdit").hide();
		return true;
	}, {});

addAttachmentsCount(<%=numAttachments%>);
</script>
</tbody>
</table>

