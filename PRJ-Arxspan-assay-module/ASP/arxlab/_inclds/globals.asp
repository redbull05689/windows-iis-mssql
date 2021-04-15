<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%st = timer()%>
<%response.charset = "ISO-8859-1"%>
<%
'Dim Conn, ConnCust, ConnAdm, jchemRegConn,ConnLog
Dim connAdmTrans
%>

<!-- #include file="__whichServer.asp"-->

<!-- #include file="security/functions/fnc_loginUser.asp"-->
<!-- #include file="security/functions/fnc_isAdminUser.asp"-->
<!-- #include file="security/functions/fnc_companyUsesSso.asp"-->
<!-- #include file="security/functions/fnc_usersWhoCanViewExperiment.asp"-->
<!-- #include file="security/functions/fnc_getUsersICanSee.asp"-->
<!-- #include file="security/functions/fnc_canReadNotebookByProject.asp"-->
<!-- #include file="security/functions/fnc_canReadNotebook.asp"-->
<!-- #include file="security/functions/fnc_canViewProject.asp"-->
<!-- #include file="security/functions/fnc_canWriteProject.asp"-->
<!-- #include file="security/functions/fnc_canWriteNotebook.asp"-->
<!-- #include file="security/functions/fnc_ownsNotebook.asp"-->
<!-- #include file="security/functions/fnc_ownsProject.asp"-->
<!-- #include file="security/functions/fnc_hasNotebookInvite.asp"-->
<!-- #include file="security/functions/fnc_hasNotebookInviteRead.asp"-->
<!-- #include file="security/functions/fnc_hasNotebookInviteWrite.asp"-->
<!-- #include file="security/functions/fnc_canViewExperimentByProject.asp"-->
<!-- #include file="security/functions/fnc_canViewExperiment.asp"-->
<!-- #include file="security/functions/fnc_canWitness.asp"-->
<!-- #include file="security/functions/fnc_canCreateExperiment.asp"-->
<!-- #include file="security/functions/fnc_canCreateNotebook.asp"-->
<!-- #include file="security/functions/fnc_hasShareNotebookPermission.asp"-->
<!-- #include file="security/functions/fnc_canShareNotebook.asp"-->
<!-- #include file="security/functions/fnc_canShareShareNotebook.asp"-->
<!-- #include file="security/functions/fnc_ownsExperiment.asp"-->
<!-- #include file="security/functions/fnc_getReadNotebooks.asp"-->
<!-- #include file="security/functions/fnc_isExperimentClosed.asp"-->
<!-- #include file="security/functions/fnc_isExperimentClosedByStatus.asp"-->
<!-- #include file="security/functions/fnc_toolTip.asp"-->
<!-- #include file="security/functions/fnc_experimentStatusImg.asp"-->
<!-- #include file="security/functions/fnc_getExperimentsICanView.asp"-->
<!-- #include file="security/functions/fnc_getExperimentStructureSearch.asp"-->
<!-- #include file="security/functions/fnc_checkCoAuthors.asp"-->
<!-- #include file="security/functions/fnc_setUpCfgData.asp"-->

<!-- #include file="recently_viewed/functions/fnc_addToRecentlyViewed.asp"-->
<!-- #include file="recently_viewed/functions/fnc_addToRecentlyViewedNotebooks.asp"-->
<!-- #include file="recently_viewed/functions/fnc_addToRecentlyViewedProjects.asp"-->

<!-- #include file="escape_and_filter/functions/fnc_aspJsonStringify.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_maxChars.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_textToHTML.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_cleanFileName.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_HTMLDecode.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_SQLClean.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_removeTags.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_removeLineBreaks.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_pEscape.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_cleanWhitespace.asp"-->
<!-- #include file="escape_and_filter/functions/fnc_padWithZeros.asp"-->

<!-- #include file="attachments/functions/fnc_getAttachmentTableFileTypeIcon.asp"-->
<!-- #include file="attachments/functions/fnc_copyAttachmentFiles.asp"-->
<!-- #include file="attachments/functions/fnc_getAttachmentDisplayFileName.asp"-->
<!-- #include file="attachments/functions/fnc_getAttachmentExperimentId.asp"-->
<!-- #include file="attachments/functions/fnc_getAttachmentFilePath.asp"-->
<!-- #include file="attachments/functions/fnc_getListOfCheckedOutFiles.asp"-->

<!-- #include file="experiments/common/functions/fnc_addNoteToExperiment.asp"-->
<!-- #include file="experiments/common/functions/fnc_addNoteToExperimentPreSave.asp"-->
<!-- #include file="experiments/common/functions/fnc_getExperimentRevisionNumber.asp"-->
<!-- #include file="experiments/common/functions/fnc_getExperimentCompanyId.asp"-->
<!-- #include file="experiments/common/functions/fnc_isExperimentVisible.asp"-->
<!-- #include file="experiments/common/functions/fnc_getNotebookId.asp"-->
<!-- #include file="experiments/common/functions/fnc_copyExperiment.asp"-->
<!-- #include file="experiments/common/functions/fnc_experimentHasAttachments.asp"-->
<!-- #include file="experiments/common/functions/fnc_experimentHasNotes.asp"-->
<!-- #include file="experiments/common/functions/fnc_experimentHasElementalMachinesData.asp"-->
<!-- #include file="experiments/common/functions/fnc_preSaveItems.asp"-->
<!-- #include file="experiments/common/functions/fnc_unsavedChanges.asp"-->
<!-- #include file="experiments/common/functions/fnc_htmlSpecialChars.asp"-->
<!-- #include file="experiments/common/functions/fnc_getParentFolderIdForAttachment.asp"-->
<!-- #include file="experiments/common/functions/fnc_updateAttachmentParentFolderId.asp"-->
<!-- #include file="experiments/common/functions/fnc_getPrefix.asp"-->
<!-- #include file="experiments/common/functions/fnc_getCoAuthors.asp"-->
<!-- #include file="experiments/common/functions/fnc_addSigners.asp"-->
<!-- #include file="experiments/common/functions/fnc_fetchWorkflowData.asp"-->
<!-- #include file="experiments/common/functions/fnc_getUsersWhoCollaborated.asp"-->
<!-- #include file="experiments/common/functions/fnc_notifyUsersOfComments.asp"-->
<!-- #include file="experiments/common/functions/fnc_getAllExperimentsId.asp"-->

<!-- #include file="experiments/chem/functions/fnc_getObjectForm.asp"-->

<!-- #include file="notebooks/functions/fnc_isNotebookShared.asp"-->
<!-- #include file="notebooks/functions/fnc_isNotebookVisible.asp"-->
<!-- #include file="notebooks/functions/fnc_getChildInvites.asp"-->
<!-- #include file="notebooks/functions/fnc_getManagerNotebooks.asp"-->
<!-- #include file="notebooks/functions/fnc_getNextExperimentName.asp"-->
<!-- #include file="notebooks/functions/fnc_getNotebookCompanyId.asp"-->

<!-- #include file="users/functions/fnc_getCompanyIdByUser.asp"-->
<!-- #include file="users/functions/fnc_emailUser.asp"-->
<!-- #include file="users/functions/fnc_saveUserOptions.asp"-->
<!-- #include file="users/functions/fnc_logAction.asp"-->
<!-- #include file="users/functions/fnc_sendNotification.asp"-->

<!-- #include file="backup_and_pdf/functions/fnc_getBackupList.asp"-->
<!-- #include file="backup_and_pdf/functions/fnc_backupExperiment.asp"-->
<!-- #include file="backup_and_pdf/functions/fnc_savePDF.asp"-->
<!-- #include file="backup_and_pdf/functions/fnc_addSignature.asp"-->

<!-- #include file="file_system/functions/fnc_bytesToK.asp"-->
<!-- #include file="file_system/functions/fnc_getFileExtension.asp"-->
<!-- #include file="file_system/functions/fnc_recursiveDirectoryCreate.asp"-->

<!-- #include file="file_types/functions/fnc_isOfficeDoc.asp"-->
<!-- #include file="file_types/functions/fnc_isD2SDoc.asp"-->
<!-- #include file="file_types/functions/fnc_isTextFile.asp"-->
<!-- #include file="file_types/functions/fnc_isChemicalFile.asp"-->
<!-- #include file="file_types/functions/fnc_isPdf.asp"-->
<!-- #include file="file_types/functions/fnc_canDisplayInBrowser.asp"-->

<!-- #include file="parse/functions/fnc_cdXMLGetParam.asp"-->
<!-- #include file="parse/functions/fnc_getXMLTag.asp"-->

<!-- #include file="projects/functions/fnc_getProjectCompanyId.asp"-->
<!-- #include file="projects/functions/fnc_isProjectVisible.asp"-->
<!-- #include file="projects/functions/fnc_sendProjectInvites.asp"-->

<!-- #include file="data_types/functions/fnc_inList.asp"-->
<!-- #include file="data_types/functions/fnc_isInteger.asp"-->
<!-- #include file="data_types/functions/fnc_removeDuplicates.asp"-->
<!-- #include file="data_types/classes/class_LD.asp"-->
<%
Response.LCID = 1033 ' Required for jsonObject class (this is the "English - United States" LCID)
%>
<!-- #include file="data_types/classes/jsonObject.class.asp"-->

<!-- #include file="misc/functions/fnc_getRandomString.asp"-->

<!-- #include file="database/functions/fnc_columnExists.asp"-->
<!-- #include file="misc/functions/fnc_getLastNotificationId.asp"-->
<!-- #include file="misc/functions/fnc_iif.asp"-->
<!-- #include file="util/functions/fnc_datetime.asp"-->
<%

regInboxPath = "c:\INBOX-REG\"
regInboxLogPath = "c:\INBOX-REG-LOG\"

saltsInImports = True

experimentAccessString = ""

set allowedQueryStringParams = CreateObject("System.Collections.ArrayList")
allowedQueryStringParams.add "type"
allowedQueryStringParams.add "random"
allowedQueryStringParams.add "pid"
allowedQueryStringParams.add "b"
allowedQueryStringParams.add "pre"
allowedQueryStringParams.add "history"
allowedQueryStringParams.add "filename"
allowedQueryStringParams.add "debug"
allowedQueryStringParams.add "tab"
allowedQueryStringParams.add "qs"
allowedQueryStringParams.add "o"
allowedQueryStringParams.add "prevUrl"
allowedQueryStringParams.add "strsearch"
allowedQueryStringParams.add "notebookname"
allowedQueryStringParams.add "rand"
allowedQueryStringParams.add "stateid"
allowedQueryStringParams.add "q"
allowedQueryStringParams.add "inframe"
allowedQueryStringParams.add "experimentid"
allowedQueryStringParams.add "override"
allowedQueryStringParams.add "o"
allowedQueryStringParams.add "s"
allowedQueryStringParams.add "d"
allowedQueryStringParams.add "sent"
allowedQueryStringParams.add "from"
allowedQueryStringParams.add "managername"
allowedQueryStringParams.add "p"
allowedQueryStringParams.add "comments"
allowedQueryStringParams.add "comment"
allowedQueryStringParams.add "numreactants"
allowedQueryStringParams.add "numreagents"
allowedQueryStringParams.add "numproducts"
allowedQueryStringParams.add "framebg"
allowedQueryStringParams.add "cas"
allowedQueryStringParams.add "name"
allowedQueryStringParams.add "fromchemdraw"
allowedQueryStringParams.add "reopen"
allowedQueryStringParams.add "attachment"
allowedQueryStringParams.add "reload"
allowedQueryStringParams.add "searchterm"
allowedQueryStringParams.add "toplevel"
allowedQueryStringParams.add "casid"
allowedQueryStringParams.add "newnotebookid"
allowedQueryStringParams.add "regnumber"
allowedQueryStringParams.add "batchnumber"
allowedQueryStringParams.add "inframe"
allowedQueryStringParams.add "imagefilename"
allowedQueryStringParams.add "makebatches"
allowedQueryStringParams.add "needspurification"
allowedQueryStringParams.add "replacekey"
allowedQueryStringParams.add "originalfilename"
allowedQueryStringParams.add "source"
allowedQueryStringParams.add "pdfkey"
allowedQueryStringParams.add "username"
allowedQueryStringParams.add "safeversion"
allowedQueryStringParams.add "makesafeversion"
allowedQueryStringParams.add "clear"
allowedQueryStringParams.add "message"
allowedQueryStringParams.add "title"
allowedQueryStringParams.add "copyattachments"
allowedQueryStringParams.add "copynotes"
allowedQueryStringParams.add "all"
allowedQueryStringParams.add "m"
allowedQueryStringParams.add "fid"
allowedQueryStringParams.add "fromsign"
allowedQueryStringParams.add "rfid"
allowedQueryStringParams.add "expview"
allowedQueryStringParams.add "base64"
allowedQueryStringParams.add "formname"
allowedQueryStringParams.add "c"
allowedQueryStringParams.add "pc"
allowedQueryStringParams.add "view"
allowedQueryStringParams.add "list"
allowedQueryStringParams.add "inapiframe"
allowedQueryStringParams.add "searchkey"
allowedQueryStringParams.add "subsectionid"
allowedQueryStringParams.add "myexperimentsmoreflag"
allowedQueryStringParams.add "sharedexperimentsmoreflag"
allowedQueryStringParams.add "recentexperimentsflag"
allowedQueryStringParams.add "data"
allowedQueryStringParams.add "description"
allowedQueryStringParams.add "regexperimentname"
allowedQueryStringParams.add "newssection"
allowedQueryStringParams.add "drafthasunsavedchanges"
allowedQueryStringParams.add "onlynoncompleted"
allowedQueryStringParams.add "hss"
allowedQueryStringParams.add "actionids"
allowedQueryStringParams.add "axcnum"
allowedQueryStringParams.add "fields"
allowedQueryStringParams.add "fieldstoshow"
allowedQueryStringParams.add "tablelinkfield"
allowedQueryStringParams.add "sfirstname"
allowedQueryStringParams.add "slastname"
allowedQueryStringParams.add "semail"
allowedQueryStringParams.add "stitle"
allowedQueryStringParams.add "amount"
allowedQueryStringParams.add "justfilename"
allowedQueryStringParams.add "regfieldid"
allowedQueryStringParams.add "regid"
allowedQueryStringParams.add "links"
allowedQueryStringParams.add "state"
allowedQueryStringParams.add "code"
allowedQueryStringParams.add "hd"
allowedQueryStringParams.add "session_state"
allowedQueryStringParams.add "prompt"
allowedQueryStringParams.add "idstried"
allowedQueryStringParams.add "autofillfields"
allowedQueryStringParams.add "startdate"
allowedQueryStringParams.add "enddate"
allowedQueryStringParams.add "keypath"
allowedQueryStringParams.add "barcodechooser"
allowedQueryStringParams.add "prefix"
allowedQueryStringParams.add "structuredata"
allowedQueryStringParams.add "lite"
allowedQueryStringParams.add "textinfile"
allowedQueryStringParams.add "attachmentfilename"
allowedQueryStringParams.add "attachmentid"
allowedQueryStringParams.add "moldata"
allowedQueryStringParams.add "searchtype"
allowedQueryStringParams.add "key"
allowedQueryStringParams.add "mode"
allowedQueryStringParams.add "type"
allowedQueryStringParams.add "clientid"
allowedQueryStringParams.add "clientsecret"
allowedQueryStringParams.add "newstyles"
allowedQueryStringParams.add "path"
allowedQueryStringParams.add "folderId"
allowedQueryStringParams.add "folderid"
allowedQueryStringParams.add "casname"
allowedQueryStringParams.add "molstr"
allowedQueryStringParams.add "userid"
allowedQueryStringParams.add "companyid"
allowedQueryStringParams.add "functionname"
allowedQueryStringParams.add "p1"
allowedQueryStringParams.add "p2"
allowedQueryStringParams.add "p3"
allowedQueryStringParams.add "p4"
allowedQueryStringParams.add "p5"
allowedQueryStringParams.add "p6"
allowedQueryStringParams.add "p7"
allowedQueryStringParams.add "p8"
allowedQueryStringParams.add "p9"
allowedQueryStringParams.add "p10"
allowedQueryStringParams.add "userprinter"
allowedQueryStringParams.add "printerlist"
allowedQueryStringParams.add "printername"
allowedQueryStringParams.add "updatedprintername"
allowedQueryStringParams.add "r"
allowedQueryStringParams.add "userenteredfields"
allowedQueryStringParams.add "firstload"
allowedQueryStringParams.add "onsave"
allowedQueryStringParams.add "tagid"
allowedQueryStringParams.add "jwt"
allowedQueryStringParams.add "url"
allowedQueryStringParams.add "title"
allowedQueryStringParams.add "sid"
allowedQueryStringParams.add "ssid"
allowedQueryStringParams.add "groupid"
allowedQueryStringParams.add "$inlinecount"
allowedQueryStringParams.add "$skip"
allowedQueryStringParams.add "$top"
allowedQueryStringParams.add "$filter"
allowedQueryStringParams.add "$orderby"
allowedQueryStringParams.add "$count"
allowedQueryStringParams.add "$apply"
allowedQueryStringParams.add "min"
allowedQueryStringParams.add "max"
allowedQueryStringParams.add "cid"
allowedQueryStringParams.add "fileId"
allowedQueryStringParams.add "ownerId"

If sectionId <> "login" And sectionId <> "logout" And sectionId <> "home" And request.servervariables("SCRIPT_NAME") <> mainAppPath&"/exports/checkExport.asp" And request.servervariables("SCRIPT_NAME") <> mainAppPath&"/ajax_checkers/getHeaderNotifications.asp" And sectionId <> "header-notifications" And sectionId <> "hungSave" And Not isAjax then
	If Not InStr(request.servervariables("SCRIPT_NAME"),"404") > 0 then
		session("prevUrl") = request.servervariables("SCRIPT_NAME")&"?"&request.servervariables("QUERY_STRING")
		If request.querystring("newsSection") <> "" Then
			session("prevUrl") = request.servervariables("SCRIPT_NAME")&"#"&request.querystring("newsSection")
			If session("userId") <> "" Then
				response.redirect(session("prevUrl"))
			End if
		End if
	End if
End If
If session("unAuthorized") Then
	session("prevUrl") = ""
	session("unAuthorized") = False
End If

If sectionId <> "home" And sectionId <> "logout" And sectionId <> "autolog" And sectionId <> "test" And sectionId <> "safe-pdf" And Not isApiPage And sectionId <> "hungSave" then
	If session("userId") = "" Then
		response.redirect(loginScriptName)
	End If

'	response.write("F"&sectionId&"U"&subsectionId&"FU"&session("userId"))

	'QQQ START This is not needed for H3 Reg
	If sectionId <> "reg" And Not session("hasELN") Then
		If Not regEnabled then
			If Not (sectionId = "dashboard" Or subSectionId = "my-profile" Or subSectionId = "force-change-password" Or sectionId = "error" Or sectionId = "header-notifications") then
				If whichServer = "PROD" then
					session("prevUrl") = ""
					response.redirect(mainAppPath&"/logout.asp")
				Else
					session("prevUrl") = ""
					response.redirect(mainAppPath&"/logout.asp")
				End If
			End if
		End if
	End if
	'QQQ END This is not needed for H3 Reg

End if

'QQQ START This is not needed for H3 Reg
If sectionId = "reg" And Not session("hasReg") Then
	session("prevUrl") = ""
	response.redirect(loginScriptName)
End if
'QQQ END This is not needed for H3 Reg

If sectionId <> "test" then
qsPairs = Split(request.servervariables("QUERY_STRING"),"&")
For Each pair In qsPairs
	If pair <> "" then
		name = LCase(Split(pair,"=")(0))
		If UBound(Split(pair,"=")) > 0 then
			value = Split(pair,"=")(1)
		Else
			value = ""
		End if
		If Not isInteger(value) And value <> "" And not allowedQueryStringParams.contains(name) Then
			If Not whiteListOverride then
				response.redirect(mainAppPath&"/static/error.asp?qs="&name)
			End if
		End If
		'QQQ START not needed for H3
		If name = "experimentType" Then
			If value <> "1" And value <> "2" And value <> "3" Then
				response.redirect(mainAppPath&"/static/error.asp?")
			End if
		End if
		'QQQ END not needed for H3
	End if
Next
End If

If LCase(request.querystring("debug")) = "true" Then
	session("debug") = True
End If

If LCase(request.querystring("debug")) = "false" Then
	session("debug") = False
End if

' After we initialize the session (and only after) we need to re-check whether the user needs to change their password
checkPasswordChangeRequired()
If session("mustChangePassword") = 1 And subSectionId <> "force-change-password" And sectionId <> "logout" Then
	response.redirect(mainAppPath&"/users/force-change-password.asp")
End If

If sectionId = "logout" then
	session("mustChangePassword") = 0
End if
Call getconnected

If Not session("loadedRegRestrictedGroups") then
	If session("hasReg") Then
		If session("role")="Super Admin" or session("role")="Admin" Or (session("regRegistrar") And not session("regRegistrarRestricted")) Then
			session("regRestrictedGroups") = ""
		else
			Call getconnectedJchemReg
			'make a string list of all the custom field groups the user is not allowed to see
			Set gRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT id, restrictUserIds, restrictGroupIds FROM groupCustomFields WHERE restrictAccess=1"
			gRec.open strQuery,jchemRegConn,0,-1
			restrictedGroupStr = ""
			myGroups = Split(session("groupIds"),",")
			Do While Not gRec.eof
				canAccessThisGroup = False
				If Not IsNull(gRec("restrictUserIds")) Then
					theseUserIds = Split(gRec("restrictUserIds"),",")
					For i = 0 To UBound(theseUserIds)
						If CStr(theseUserIds(i)) = CStr(session("userId")) Then
							canAccessThisGroup = True
						End if
					next
				End If
				If Not IsNull(gRec("restrictGroupIds")) Then
					theseGroupIds = Split(gRec("restrictGroupIds"),",")
					myGroupIds = Split(session("groupIds"),",")
					For i = 0 To UBound(theseGroupIds)
						For j = 0 To UBound(myGroupIds)
							If CStr(theseGroupIds(i)) = CStr(myGroupIds(j)) Then
								canAccessThisGroup = True
							End If
						next
					next
				End If
				If Not canAccessThisGroup Then
					restrictedGroupStr = restrictedGroupStr & gRec("id") & ","
				End If
				gRec.movenext()
			Loop
			If Len(restrictedGroupStr) > 0 then
				restrictedGroupStr = Left(restrictedGroupStr,Len(restrictedGroupStr)-1)
			End If
			session("regRestrictedGroups") = restrictedGroupStr
			gRec.close
			Set gRec = nothing
			Call disconnectJchemReg
		End if
	End if
	session("loadedRegRestrictedGroups") = True
End if
%>