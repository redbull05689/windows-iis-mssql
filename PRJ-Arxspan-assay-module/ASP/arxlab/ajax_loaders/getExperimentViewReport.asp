<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->

<%
    Response.CodePage = 65001
    Response.CharSet = "UTF-8"

    offset = request.querystring("$skip")
    if offset = "" then
        offset = 0
    end if

    pageSize = request.querystring("$top")
    extraFilters = request.querystring("$filter")

    orderByCol = request.querystring("$orderby")
    if orderByCol = "" then
        orderByCol = "row"
    end if

    minDate = request.querystring("min")
    minFilter = ""
    if minDate <> "" then
        minFilter = "AND dateSubmitted >= " & SQLClean(minDate, "T", "S") & " "
    end if

    maxDate = request.querystring("max")
    maxFilter = ""
    if maxDate <> "" then
        maxFilter = "AND dateSubmitted < DATEADD(d, 1, " & SQLClean(maxDate, "T", "S") & ") "
    end if

    groupId = request.querystring("groupId")
    if groupId <> "" then
        ' If we don't have a comma in the groupId string, then we have just one item so we should sqlclean it.
        if inStr(groupId, ",") = 0 then
            groupId = SQLClean(groupId, "N", "S")
        end if
        usersToFilter = "SELECT userId FROM groupMembers WHERE groupId IN (" & groupId & ")"
    else
        usersToFilter = getUsersICanSee()
    end if

    visibleExperiments = getExperimentsICanView()
    visibleExperiments = Replace(visibleExperiments, "[", "")
    visibleExperiments = Replace(visibleExperiments, "]", "")
    visibleExperiments = Replace(visibleExperiments, """", "'")
    experimentFilter = ""
    if visibleExperiments <> "" then
        experimentFilter = "AND a.id IN (" & visibleExperiments & ")"
    end if

    ' Figure out if we need to filter out any requests.
    requestFilter = ""

    ' Start by getting the list of collaborator IDs from the querystring.
    collaboratorIds = request.querystring("cid")
    if collaboratorIds <> "" then
        ' If we have any, then get the list of requests from the appSvc.
        requestResponse = getRequestListFromCollaborators(collaboratorIds)

        ' Parse the data and strip out brackets from the response's data key.
        set requestJson = JSON.parse(requestResponse)
        requestListStr = requestJson.get("data")
        requestListStr = Replace(requestListStr, "[", "")
        requestListStr = Replace(requestListStr, "]", "")

        ' If we have an empty string left, then make sure no results will come back
        ' in the SQL query.
        if requestListStr = "" then
            requestListStr = "-1"
        end if

        ' Build the actual filter line.
        requestFilter = "AND c.requestId IN ({idList}) "
        requestFilter = Replace(requestFilter, "{idList}", requestListStr)
    end if

    logTable = getlogTableName()

    Call getconnected
    Set rec = server.CreateObject("ADODB.RecordSet")

    set experimentPageList = CreateObject("System.Collections.ArrayList")
    experimentPageList.add "'/arxlab/experiment.asp'"
    experimentPageList.add "'/arxlab/experiment_no_chemdraw.asp'"
    experimentPageList.add "'/arxlab/bio-experiment.asp'"
    experimentPageList.add "'/arxlab/free-experiment.asp'"
    experimentPageList.add "'/arxlab/anal-experiment.asp'"
    experimentPageList.add "'/arxlab/cust-experiment.asp'"

    joinedPages = Join(experimentPageList.ToArray, ",")
    strQuery = "DROP TABLE IF EXISTS #tempLogs; "
    strQuery = strQuery & "SET NOCOUNT ON; "
    strQuery = strQuery & "SELECT " &_
                    "DISTINCT " &_
                    "agg.experimentId, " &_
                    "agg.extraTypeId, " &_
                    "agg.experimentTypeId, " &_
                    "agg.pageName, " &_
                    "agg.numOpens, " &_
                    "agg.lastViewDate, " &_
                    "d.userId AS lastUser " &_
                "INTO #tempLogs " &_
                "FROM ( " &_
                    "SELECT  " &_
                        "extraId AS experimentId,  " &_
                        "extraTypeId, " &_
                        "CASE " &_
                            "WHEN extraTypeId = 2 THEN 1 " &_
                            "WHEN extraTypeId = 3 THEN 2 " &_
                            "WHEN extraTypeId = 4 THEN 3 " &_
                            "WHEN extraTypeId = 6 THEN 4 " &_
                            "WHEN extraTypeId = 0 THEN 5 " &_
                        "END AS experimentTypeId, " &_
                        "pageName,  " &_
                        "1 AS numOpens, " &_
                        "dateSubmitted AS lastViewDate " &_
                    "FROM [LOGS].[dbo]." & logTable & " " &_
                    "WHERE actionId = 29 " &_
                        "and companyId = " & session("companyId") & " " &_
                        "and extraId > 0  " &_
                        "and pageName in (" & joinedPages & ") " &_
                        minFilter &_
                        maxFilter &_
                ") agg " &_
                "JOIN [LOGS].[dbo]." & logTable & " d " &_
                    "ON agg.experimentId=d.extraId " &_
                    "AND agg.extraTypeId=d.extraTypeId " &_
                "ORDER BY lastViewDate DESC; "
    
    strQuery = strQuery & "SELECT *, COUNT(*) OVER () AS totalCount FROM (SELECT " &_
            "ROW_NUMBER() OVER (ORDER BY lastViewDate desc) AS row, " &_
            "t.experimentId AS experimentId, " &_
            "t.extraTypeId AS extraTypeId, " &_
            "CASE " &_
                "WHEN t.experimentTypeId <> 5 THEN t.experimentTypeId " &_
                "WHEN t.experimentTypeId = 5 THEN a.requestTypeId + 5000 " &_
            "END AS experimentTypeId, " &_
            "eT.type AS experimentType, " &_
            "t.pageName AS pageName, " &_
            "t.numOpens AS numOpens, " &_
            "t.lastViewDate AS lastViewDate, " &_
            "vu.firstName + ' ' + vu.lastName AS lastUser, " &_
            "vu.id AS lastUserId, " &_
            "a.name AS name, " &_
            "CASE " &_
                "WHEN c.requestId = 0 THEN null " &_
                "WHEN t.experimentTypeId <> 5 THEN null " &_
                "WHEN t.experimentTypeId = 5 THEN c.requestId " &_
            "END AS requestId, " &_
            "a.requestTypeId AS requestTypeId, " &_
            "ou.firstName + ' ' + ou.lastName AS ownerName " &_
        "FROM #tempLogs t " &_
        "JOIN allExperiments a " &_
            "ON t.experimentId=a.legacyId " &_
            "AND t.experimentTypeId=a.experimentType " &_
        "JOIN users ou " &_
            "ON a.userId=ou.id " &_
        "JOIN users vu " &_
            "ON t.lastUser=vu.id " &_
        "JOIN experimentTypes eT " &_
            "ON t.experimentTypeId=eT.id " &_
        "LEFT JOIN custExperiments c " &_
            "ON a.legacyId = c.id " &_
        "WHERE a.companyId=" & session("companyId") & " " &_
        "AND vu.id IN (" & usersToFilter & ")" &_
        experimentFilter &_
        requestFilter &_
        ") a "

    if extraFilters <> "" then
        extraFilters = REPLACE(extraFilters, "eq", "=")
        extraFilters = REPLACE(extraFilters, "tolower", "LOWER")
        extraFilters = REPLACE(extraFilters, "substringof", "CHARINDEX")
        extraFilters = REPLACE(extraFilters, " ne ", "<>")
        extraFilters = REPLACE(extraFilters, " gt ", ">")
        extraFilters = REPLACE(extraFilters, " ge ", ">=")
        extraFilters = REPLACE(extraFilters, " lt ", "<")
        extraFilters = REPLACE(extraFilters, " le ", "<=")
        strQuery = strQuery & "WHERE " & extraFilters & " "
    end if

    orderByCol = REPLACE(orderByCol, "experimentTypeId", "experimentType")

    strQuery = strQuery & "ORDER BY " & orderByCol & " "
    strQuery = strQuery & "OFFSET " & offset & " ROWS "

    if pageSize <> "" then
        strQuery = strQuery & "FETCH NEXT " & pageSize & " ROWS ONLY "
    end if

    'strQuery = strQuery & "FOR JSON AUTO "
    strQuery = strQuery & ";DROP TABLE #tempLogs; "

    ' Note: to use the for json auto you need to setup your cursor like this with -1 and 1
    ' -1 = adLockUnspecified
    ' 1 = adCmdText
    ' you can find the deffs here: https://www.w3schools.com/asp/met_rs_open.asp#CursorTypeEnum
    rec.open strQuery, connAdm, -1, 1

    ' Note: The json is split up into many rows depending on the size. so you need to loop the result
    
    set out = JSON.parse("{}")
    set rows = JSON.parse("[]")
    totalCount = 0
    Do While Not rec.eof
        set row = JSON.parse("{}")

        for each field in rec.fields
            row.set field.name, field.value
        next

        row.set "lastViewDate", CSTR(rec("lastViewDate"))

        if totalCount = 0 then
            totalCount = rec("totalCount")
        end if

        rows.push(row)
        rec.movenext
    loop

    out.set "result", rows
    out.set "count", totalCount
    rec.close
    set rec = nothing
    response.write JSON.stringify(out)
    response.end
%>
