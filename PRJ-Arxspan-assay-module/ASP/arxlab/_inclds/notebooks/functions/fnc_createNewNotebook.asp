<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
projectNameInNotebook = checkBoolSettingForCompany("useProjectNameInNotebookName", session("companyId"))
groupNameInNotebook = getCompanySpecificSingleAppConfigSetting("addGroupNameToNotebookName", session("companyId"))
function createNewNotebook(notebookName,notebookDescription,projectId,notebookGroup)
	Set rDict = server.CreateObject("Scripting.Dictionary")
	autoNumberNotebooks = hasAutoNumberNotebooks()
	If canCreateNotebook(false) Then
		efields = ""

		If session("requireProjectLinkForNB") Or projectNameInNotebook Then
			If projectId = "" Then
				errorStr = errorStr & "Link to a project is required."
				efields = efields & "linkProjectId"						
			End if
		End if

		If projectId = "x" Then
			errorStr = errorStr & "This project has tabs. Please select the tab that you would like to link to."
			efields = efields & "linkProjectId"		
		End if

		If Len(notebookDescription) > 500 Then
			errorStr = errorStr & "The maximum length for a notebook description is 500 characters."
			efields = efields & "notebookDescription"
			notebookDescription = Mid(notebookDescription,1,500)
		End If

		singleGroupSelected = False
		'singleGroupId = Trim(request.Form("notebookGroup"))
		singleGroupId = Trim(notebookGroup)

		useGroupFieldForNotebook = checkBoolSettingForCompany("useGroupNameInNotebookName", session("companyId"))
		If useGroupFieldForNotebook Then
			requireGroupFieldForNotebook = checkBoolSettingForCompany("requireGroupNameInNotebookName", session("companyId"))
			If (requireGroupFieldForNotebook Or (autoNumberNotebooks And groupNameInNotebook)) And singleGroupId = "" Then
				efields = efields & "notebookGroup"
				errorStr = errorStr & "You must select a group to create a notebook."
			End If
			If singleGroupId <> "" Then
				Set nRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT groupName FROM groupMembersView WHERE userId="&SQLClean(session("userId"),"N","S") & " AND groupId="&SQLClean(singleGroupId,"N","S")
				nRec.open strQuery,conn,3,3
				If nRec.eof Then
					efields = efields & "notebookGroup"
					errorStr = errorStr & "You cannot select this group."
				Else
					groupName = nRec("groupName")
				End If
				nRec.close
				Set nRec = nothing
			End if
			If efields = "" Then
				If singleGroupId <> "" Then
					singleGroupSelected = True
				End if
			End if
		End if

		If projectNameInNotebook Then
			Set nnRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT name from projects WHERE id="&SQLClean(projectId,"N","S")
			nnRec.open strQuery,connAdm,3,3
			If Not nnRec.eof Then
				projectName = nnRec("name")
			End If
			nnRec.close
			Set nnRec = nothing
		End If

		If Not autoNumberNotebooks then
			If Trim(notebookName) = "" Then
				efields = efields & "notebookName"
				errorStr = errorStr & "No name was provided for notebook."
			End If
			If Len(notebookName) > 150 Then
				errorStr = errorStr & "The maximum length for a notebook name is 150 characters."
				efields = efields & "notebookName"
				notebookName = Mid(notebookName,1,150)
			End If
			
			notebookName = addGroupAndProjectNames(notebookName, groupName, projectName)
	
			requireUniqueNotebookNames = checkBoolSettingForCompany("requireUniqueNotebookNames", session("companyId"))
			If requireUniqueNotebookNames Then
				Set nRec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT id FROM notebookView WHERE name="&SQLClean(notebookName,"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
				nRec2.open strQuery,connAdm,3,3
				If Not nRec2.eof Then
					efields = efields & "notebookName"
					errorStr = errorStr & "This notebook name has already been used."
				End If
			End If
		Else
			Set nRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT autoNotebookNumDigits, autoNotebookStartNumber, autoNotebookPrefix FROM companies WHERE id="&SQLClean(session("companyId"),"N","S")
			nRec.open strQuery,connAdm,3,3
			If Not nRec.eof Then
				prefix = nRec("autoNotebookPrefix")
				startNumber = Int(nRec("autoNotebookStartNumber"))
				numDigits = Int(nRec("autoNotebookNumDigits"))
				
				notebookName = getNotebookName(prefix, groupName, projectName, startNumber, numDigits)
				notebookExists = True
				
				Do While notebookExists
					Set nRec2 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT id FROM notebookView WHERE name="&SQLClean(notebookName,"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
					nRec2.open strQuery,connAdm,3,3
					If nRec2.eof Then
						notebookExists = False
					Else
						startNumber = startNumber + 1
						notebookName = getNotebookName(prefix, groupName, projectName, startNumber, numDigits)
					End if
				Loop
				
				If efields = "" then
					connAdm.execute("UPDATE companies SET autoNotebookStartNumber="&SQLClean(startNumber+1,"N","S")& " WHERE id="&SQLClean(session("companyId"),"N","S"))
				End if
			End If
			nRec.close
			Set nRec = nothing
		End if
		
		If efields = "" Then
			strQuery = "INSERT into notebooks(name,description,userId) output inserted.id as newId values("&SQLClean(notebookName,"T","S")&","&SQLClean(notebookDescription,"T","S")&","&SQLClean(session("userId"),"N","S")&")"
			Set rs = connAdm.execute(strQuery)
			newId = CStr(rs("newId"))
			origNotebookName = notebookName
			notebookName=""
			notebookDescription = ""
			a = logAction(1,newId,"",6)

			'Add a project link if a project was selected
			If projectId <> "" Then
				If canWriteProject(projectId,session("userId")) Then
					If canReadNotebook(newId,session("userId")) then
						Set tRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT id FROM linksProjectNotebooks WHERE notebookId="&SQLClean(newId,"N","S")& " AND projectId="&SQLClean(projectId,"N","S")
						tRec.open strQuery,connAdm,3,3
						If tRec.eof then
							strQuery = "INSERT into linksProjectNotebooks(notebookId,projectId) values(" &_
							SQLClean(newId,"N","S") & "," &_
							SQLClean(projectId,"N","S") & ")"
							connAdm.execute(strQuery)
						End If
						tRec.close
						Set tRec = Nothing
					End if
				End If
			End if

			'START AUTO SHARE TO ADMINS/Group Managers also check do group auto share
			usersTable = getDefaultSingleAppConfigSetting("usersTable")
			Set gaRec=server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT userAdded FROM "&usersTable&" WHERE id="&SQLClean(session("userId"),"N","S") & " AND userAdded is not null and userAdded <> 0"
			gaRec.open strQuery,connAdm,3,3
			If Not gaRec.eof then
				strQuery = "INSERT into notebookInvites(notebookId,sharerId,shareeId,canRead,canWrite,accepted,denied,readOnly) values(" &_
				SQLClean(newId,"N","S") & "," &_ 
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(gaRec("userAdded"),"N","S") & "," &_
				SQLClean("1","N","S") & "," &_
				SQLClean("0","N","S") & ",0,0,1)"
				'DEBUG
				connAdm.execute(strQuery)
				userAdded = gaRec("userAdded")
				title = "Notebook Share Invitation"
				note = "User "&session("firstName") &" "& session("lastName")& " has invited you to share <a href=""show-notebook.asp?id="&newId&""">"&origNotebookName&"</a>"
				a = sendNotification(gaRec("userAdded"),title,note,2)
			End if

			Set gaRec=server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT id FROM usersView WHERE roleNumber=1 AND companyId="&SQLClean(session("companyId"),"N","S") & " AND id<>"&SQLClean(session("userId"),"N","S")
			If userAdded <> "" Then
				strQuery = strQuery & " and id<>"&SQLClean(userAdded,"N","S")
			End if
			gaRec.open strQuery,connAdm,3,3
			Do While Not gaRec.eof
				strQuery = "INSERT into notebookInvites(notebookId,sharerId,shareeId,canRead,canWrite,accepted,denied,readOnly) values(" &_
				SQLClean(newId,"N","S") & "," &_ 
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(gaRec("id"),"N","S") & "," &_
				SQLClean("1","N","S") & "," &_
				SQLClean("0","N","S") & ",1,0,1)"
				'DEBUG
				title = "Notebook Share Invitation"
				note = "User "&session("firstName") &" "& session("lastName")& " has invited you to share <a href=""show-notebook.asp?id="&newId&""">"&origNotebookName&"</a>"
				a = sendNotification(gaRec("id"),title,note,2)
				connAdm.execute(strQuery)
				gaRec.movenext
			Loop
			
			groupField = ""
			groupsToShareWith = ""
			Set gaRec = server.CreateObject("ADODB.RecordSet")
			If Not singleGroupSelected then
				groupField = "groupId"
				strQuery = "SELECT " & groupField & " FROM groupMembers WHERE userId="&SQLClean(session("userId"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
			Else
				groupField = "shareToGroupId"
				strQuery = "SELECT " & groupField & " FROM groupAutoShare WHERE groupId="&SQLClean(singleGroupId,"N","S")
			End If
			gaRec.open strQuery,connAdm,3,3
			groupCount = 0
			Do While Not gaRec.eof
				If singleGroupSelected Then
					groupCount = groupCount + 1
					groupsToShareWith = groupsToShareWith & gaRec(groupField) &","
				End If
				Set gaRec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT shareToGroupId FROM groupAutoShare WHERE groupId="&SQLClean(gaRec(groupField),"N","S")
				gaRec2.open strQuery,connAdm,3,3
				Do While Not gaRec2.eof
					groupCount = groupCount + 1
					groupsToShareWith = groupsToShareWith & gaRec2("shareToGroupId") &","
					gaRec2.movenext
				Loop
				gaRec2.close
				Set gaRec2 = nothing

				gaRec.movenext
			loop

			If groupCount >= 1 Then
				groupsToShareWith = Mid(groupsToShareWith,1,Len(groupsToShareWith)-1)
			End If

			groupsToShareWith = removeDuplicates(groupsToShareWith)			
			groups = Split(groupsToShareWith,",")
			
			For i = 0 To UBound(groups)
				strQuery = "INSERT into groupNotebookInvites(notebookId,sharerId,shareeId,canRead,canWrite,accepted,denied,readOnly) values(" &_
				SQLClean(newId,"N","S") & "," &_ 
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(groups(i),"N","S") & "," &_
				SQLClean("1","N","S") & "," &_
				SQLClean("0","N","S") & ",1,0,1)"
				'DEBUG
				connAdm.execute(strQuery)
			next

			'END AUTO SHARES
			rDict("success") = True
			rDict("newId") = newId
			rDict("newName") = origNotebookName
		Else
			rDict("success") = False
			rDict("errorStr") = errorStr
			rDict("efields") = efields
		End if
	Else
		rDict("success") = False
		rDict("errorStr") = "You are not authorized to create a new notebook"
	End If

	'make the new notebook default
	usrTbl = getDefaultSingleAppConfigSetting("usersTable")
	If usrTbl <> "" Then
		nbuQuery = "UPDATE "&usrTbl&" SET defaultNotebookId="&rDict("newId")&" WHERE id="&SQLClean(session("userId"),"N","S")
		Set rs = connAdm.execute(nbuQuery)
	End If
	session("defaultNotebookId") = rDict("newId")

	Set createNewNotebook = rDict
End Function

Function addGroupAndProjectNames(notebookName, groupName, projectName) 
	If groupNameInNotebook And groupName <> "" Then
		'notebookName = notebookName & getDash(notebookName) & groupName
		notebookName = notebookName & groupName & getDash(groupName) 
	End If
	If projectNameInNotebook And projectName <> "" Then
		notebookName = notebookName & getDash(notebookName) & projectName
	End If
	
	addGroupAndProjectNames = notebookName
End Function

Function getDash(inStr) 
	'get the last character of the incoming string to make sure we don't duplicate commas
	testD = Trim(inStr)
	testD = Right(testD,1)
	
	dash = ""
	If inStr <> "" And Not testD="-" Then
		dash = "-"
	End If
	getDash = dash
End Function

Function getNotebookName(prefix, groupName, projectName, startNumber, numDigits)
	notebookPrefix = prefix
	notebookName = addGroupAndProjectNames(notebookPrefix, groupName, projectName)

	If notebookPrefix <> notebookName Then
		' add dash
		'notebookName = notebookName & getDash(notebookName)
		notebookName = notebookName
	Else
		' do not add dash
		notebookName = notebookPrefix
	End If

	getNotebookName = notebookName & Right(String(numDigits,"0") & CStr(startNumber), numDigits)
End Function
%>