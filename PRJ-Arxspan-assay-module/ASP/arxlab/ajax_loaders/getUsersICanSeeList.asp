<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
	usersTable = getDefaultSingleAppConfigSetting("usersTable")

	userFilter = SQLClean(session("userId"), "N", "S")
	usersICanSeeList = getPeersAndBelow()
	if usersICanSeeList <> "" then
		userFilter = userFilter & "," & usersICanSeeList
	end if

	call getconnectedadm
	userQuery = "SELECT " &_
			"id, " &_
			"firstName + ' ' + lastName AS name, " &_
			"email " &_
		"FROM " & usersTable & " " &_
		"WHERE companyId=" & SQLClean(session("companyId"), "N", "S") & " " &_
		"AND id IN (" & userFilter & ") " &_
		"ORDER BY name " &_
		"FOR JSON AUTO"

    set userRec = server.CreateObject("ADODB.RecordSet")
    userRec.open userQuery, connAdm

    do while not userRec.eof
        response.write userRec.Fields.Item(0)
        userRec.movenext
    loop
	
	userRec.close
	set userRec = nothing
    response.end
%>