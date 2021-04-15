<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->

<%

    groupId = request.querystring("groupId")
    
    minDate = request.querystring("min")
    minFilter = ""
    if minDate <> "" then
        minFilter = "AND searchDate >= " & SQLClean(minDate, "T", "S") & " "
    end if

    maxDate = request.querystring("max")
    maxFilter = ""
    if maxDate <> "" then
        maxFilter = "AND searchDate < DATEADD(d, 1, " & SQLClean(maxDate, "T", "S") & ") "
    end if

    if groupId <> "" then

        ' If we don't have a comma in the groupId string, then we have just one item so we should sqlclean it.
        if inStr(groupId, ",") = 0 then
            groupId = SQLClean(groupId, "N", "S")
        end if
        
        usersToFilter = "SELECT userId FROM groupMembers WHERE groupId IN (" & groupId & ")"
    else
        usersToFilter = getPeersAndBelow()
    end if

    Call getConnectedAdm
    searchQuery = "SELECT " &_
            "ROW_NUMBER() OVER (ORDER BY s.userId) AS row, " &_
            "s.userId, " &_
            "s.companyId, " &_
            "COUNT(CASE WHEN searchTypeCode=1 then 1 else null END) AS structureSearchCount, " &_
            "COUNT(CASE WHEN searchTypeCode=2 then 1 else null END) AS textSearchCount, " &_
            "COUNT(CASE WHEN searchTypeCode=3 then 1 else null END) AS multiParamSearchCount, " &_
            "COUNT(searchTypeCode) AS totalCount, " &_
            "(SELECT groupId " &_
			"FROM groupMembers gm " &_
			"WHERE gm.userId=s.userId " &_
			"FOR JSON AUTO " &_
			") AS groupList " &_
        "FROM savedUserSearchQueries s " &_
        "WHERE s.userId IN (" & usersToFilter & ") " &_
        "AND s.companyId=" & SQLClean(session("companyId"), "N", "S") & " " &_
        "AND searchTypeCode > 0 " &_
        minFilter &_
        maxFilter &_
        "GROUP BY s.companyId, s.userId " &_
        "ORDER BY s.userId " &_
        "FOR JSON AUTO"

    set searchRec = server.CreateObject("ADODB.RecordSet")
    searchRec.open searchQuery, connAdm

    do while not searchRec.eof
        response.write searchRec.Fields.Item(0)
        searchRec.movenext
    loop
    searchRec.close
    set searchRec = nothing
    response.end
%>