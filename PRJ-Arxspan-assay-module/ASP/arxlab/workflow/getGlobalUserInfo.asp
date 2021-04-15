<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
    whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
    userId = session("userId")
    userGroups = "["

    groupQuery = "SELECT groupId FROM groupMembers WHERE userId=" & userId

    Set groupRec = server.CreateObject("ADODB.RecordSet")

    groupRec.open groupQuery, connAdm, 3, 3

    do while not groupRec.eof
        userGroups = userGroups & groupRec("groupId") & ","
        groupRec.movenext
    loop

    if LEN(userGroups) > 1 then
        userGroups = LEFT(userGroups, LEN(userGroups) - 1)
    end if
    
    userGroups = userGroups & "]"

    userInfo = "{""companyId"": " & session("companyId") & ", " &_
                """loggedIn"": true, " &_
                """userGroups"": " & userGroups & ", " &_
                """userId"": " & userId & ", " &_
                """whichClient"": """ & whichClient & """}"
%>