<%
    userId = session("userId")
    companyId = session("companyId")
    userArray = "["

    userQuery = "SELECT id, firstName, lastName, email, roleid FROM users WHERE companyId=" & companyId & " AND enabled=1"
    Set userRec = server.CreateObject("ADODB.RecordSet")
    userRec.open userQuery, connAdm, 3, 3
    
    do while not userRec.eof
        userData = "{""id"": " & userRec("id") & ", " &_
                    """firstName"": """ & userRec("firstName") & """, " &_
                    """lastName"": """ & userRec("lastName") & """, " &_
                    """fullName"": """ & userRec("firstName") & " " & userRec("lastName") & """, " &_
                    """email"": """ & userRec("email") & """, " &_
                    """roleid"": " & userRec("roleid") & "},"
        userArray = userArray & userData
        userRec.movenext
    loop

    if len(userArray) > 1 then
        userArray = Left(userArray, Len(userArray) - 1)
    end if

    userArray = userArray & "]"
    groupArray = "["

    groupQuery = "SELECT id, name FROM groups WHERE companyId=" & companyId & " ORDER BY name"
    Set groupRec = server.CreateObject("ADODB.RecordSet")
    groupRec.open groupQuery, connAdm, 3, 3

    do while not groupRec.eof
        groupInfo = "{""id"": " & groupRec("id") & ", " &_
                    """name"": """ & groupRec("name") & """},"
        groupArray = groupArray & groupInfo
        groupRec.movenext
    loop

    if len(groupArray) > 1 then
        groupArray = Left(groupArray, Len(groupArray) - 1)
    end if

    groupArray = groupArray & "]"
%>