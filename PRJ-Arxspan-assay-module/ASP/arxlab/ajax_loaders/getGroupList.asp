<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
	userFilter = SQLClean(session("userId"), "N", "S")
	usersICanSeeList = getPeersAndBelow()
	if usersICanSeeList <> "" then
		userFilter = userFilter & "," & usersICanSeeList
	end if

    call getconnectedadm
    ' This query filters down to groups that the current user can see based on the list of users that they can see.
    groupQuery = "SELECT DISTINCT " &_
            "g.id, " &_
            "g.name, " &_
            "gm.userId " &_
        "FROM groupMembers gm " &_
        "JOIN groups g " &_
            "ON gm.groupId=g.id " &_
        "WHERE gm.companyId=" & SQLClean(session("companyId"), "N", "S") & " " &_
		"AND gm.userId IN (" & userFilter & ") " &_
        "ORDER BY g.id " &_
        "FOR JSON AUTO"
        
    set groupRec = server.CreateObject("ADODB.RecordSet")
    groupRec.open groupQuery, connAdm

    do while not groupRec.eof
        response.write groupRec.Fields.Item(0)
        groupRec.movenext
    loop

    groupRec.close
    set groupRec = nothing
    response.end
%>	