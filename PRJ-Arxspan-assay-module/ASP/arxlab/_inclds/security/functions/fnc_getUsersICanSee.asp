<%
function getUsersICanSee()
	getUsersICanSeeValue = getVisibleUsers(true, true, true)
	session("usersICanSee") = getUsersICanSeeValue
	getUsersICanSee = getUsersICanSeeValue
end function

function getPeersAndBelow()
	getPeersAndBelow = getVisibleUsers(false, false, true)
end function

' Get myself without siblings and if manager, include the people I manage
function getMyselfAndPeopleIManage() 
	getMyselfAndPeopleIManage = getVisibleUsers(false, false, false)
end function

function getVisibleUsers(includeAdmins, includeManager, includeSiblings)
	logEventsToFile = False
	If 1=2 And session("email") = "add_user_email_here_to_debug" Then
		logEventsToFile = True
		session("usersICanSee") = ""
	End If
	If logEventsToFile Then
		logpath = "C:/Temp/getUsersICanSee-log.txt"
		set logfs=Server.CreateObject("Scripting.FileSystemObject")
		set logfile = Nothing

		With (logfs)
		  If .FileExists(logpath) Then
			Set logfile = logfs.OpenTextFile(logpath, 8)
		  Else 
			Set logfile = logfs.CreateTextFile(logpath)
		  End If 
		End With

		logfile.WriteLine(Now & ": enter getUsersICanSee.asp")
	End If
	
	If logEventsToFile Then
		logfile.WriteLine(Now & ": session value " & session("usersICanSee"))
	End If
	
	'get all the users that a the user can see
	userString = ""
	userCount = 0
	usersTable = getDefaultSingleAppConfigSetting("usersTable")
	Set grnRec = server.CreateObject("ADODB.RecordSet")
	If session("role") = "Admin" Or session("canViewEveryone") then
		strQuery = "select distinct id from "&usersTable&" WHERE companyId="&SQLClean(session("companyId"),"N","S")
		grnRec.open strQuery,conn,3,3
		'admins and canViewEveryone can see all users
		Do While Not grnRec.eof
			theId = grnRec("id")
			If (Not IsNull(theId)) And theId <> "" Then
				userCount = userCount + 1
				userString = userString & theId & ","
			End If
			grnRec.movenext
		Loop
		grnRec.close
	else
		' Users who have the current user set as their manager
		strQuery = "select distinct id from "&usersTable&" WHERE (userAdded="&SQLClean(session("userId"),"N","S")

		if includeAdmins then
			strQuery = strQuery & " OR roleId = 1"
		end if

		strQuery = strQuery & ")"

		' If user is not a manager, set managerId to 0
		If IsNull(session("managerId")) Or session("managerId") = "" Or session("managerId") = "-1" Then
			managerId = "0"
		Else
			managerId = session("managerId")
			If (Not IsNull(theId)) And managerId <> "" Then

				if includeManager then
					userCount = userCount + 1
					userString = userString & managerId & ","
				end if
				
				If session("canViewSiblings") and includeSiblings Then
					' Users who have the same manager as the current user
					strQuery = strQuery & " OR userAdded="&SQLClean(managerId,"N","S")
				End If
			End If
		End If

		'Users this user can see
		grnRec.open strQuery,conn,3,3
		Do While Not grnRec.eof
			theId = grnRec("id")
			If (Not IsNull(theId)) And theId <> "" Then
				userCount = userCount + 1
				userString = userString & theId & ","
			End If
			grnRec.movenext
		Loop
		grnRec.close
		Set grnRec = Nothing

		' 5506 - If the current user can view siblings, figure out who is in their groups. "Siblings" encompasses users who
		' have the same manager and users who are in the same group.
		If session("canViewSiblings") and includeSiblings Then
			Set gaRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT distinct userId " &_ 
				"FROM groupMembers " &_
				"WHERE groupId IN " &_
					"(SELECT distinct groupId " &_
					"FROM groupMembers " &_
					"WHERE userId="&SQLClean(session("userId"),"N","S") &_
					" AND companyId="&SQLClean(session("companyId"),"N","S") &_
				")"
				
			if includeAdmins or includeManager then
				strQuery = strQuery &_
				" OR userId IN " &_
					"(SELECT id " &_
					"FROM users " &_
					"WHERE companyId=" & SQLClean(session("companyId"),"N","S") & " " &_
					"AND ("
				
				higherUserFilter = ""
				if includeAdmins then
					higherUserFilter = "roleId=1"
				end if

				if includeManager then
					if higherUserFilter <> "" then
						higherUserFilter = higherUserFilter & " OR "
					end if
					higherUserFilter = higherUserFilter & "userAdded=" & SQLClean(session("userId"), "N", "S")
				end if

				strQuery = strQuery & higherUserFilter & "))"
			end if

			' response.write strQuery
			' response.end

			gaRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
			Do While Not gaRec.eof
				theId = gaRec("userId")
				If (Not IsNull(theId)) And theId <> "" Then
					userCount = userCount + 1
					userString = userString & theId & ","
				End If
				gaRec.movenext
			loop
			gaRec.close
			Set gaRec=Nothing
		End if
	End if

	If logEventsToFile Then
		logfile.WriteLine(Now & ": before removing duplicates " & userString)
	End If
	
	'remove the trailing comma if the string is not empty
	If userCount >= 1 Then
		userString = Mid(userString,1,Len(userString)-1)
	End If
	Set grnRec = Nothing
	If userString = "" Then
		getVisibleUsers ="0"
	Else
		'return the list of read notebooks 'nxq is this list complete?
		getVisibleUsers = removeDuplicates(userString)
	End If
	If logEventsToFile Then
		logfile.WriteLine(Now & ": returning: " & getVisibleUsers)
		logfile.WriteLine(Now & ": exit getUsersICanSee.asp")
		logfile.close
		set logfile=nothing
		set logfs=nothing
	End If
		
end function
%>