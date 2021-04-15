<%
Function getDetailedReportQuery(expViewTable, expHistoryView, notesHistory, expType, userIds, currUserId, statusArray, reqType, groups, dateType, dateBefore, dateAfter)

    ' SQL used to select the SignCloseDate
    ' 10092: Optimize the following sub-query. It timed out for company Arvinas with the original query and now takes less than a few seconds.
    signCloseDateSql = "(SELECT CASE WHEN t.statusId = 5 AND t.dateUpdated > a.dateSubmitted THEN t.dateUpdated ELSE a.dateSubmitted END " &_
				       "FROM (SELECT MAX(dateSubmitted) AS dateSubmitted FROM {expHistoryView} ehv WHERE ehv.experimentId = t.id AND ehv.statusid = 5 AND ehv.visible = 1) AS a" &_
                       ")"
    signCloseDateSql = Replace(signCloseDateSql, "{expHistoryView}", expHistoryView)

    ' SQL used to select the WitnessedDate
    ' 10092: Optimize the following sub-query. It timed out for company Arvinas with the original query and now takes less than a few seconds.
    witnessedDateSql = "(SELECT CASE WHEN t.statusId = 6 AND t.dateUpdated > a.dateSubmitted THEN t.dateUpdated ELSE a.dateSubmitted END " &_
				       "FROM (SELECT MAX(dateSubmitted) AS dateSubmitted FROM {expHistoryView} ehv WHERE ehv.experimentId = t.id AND ehv.statusid = 6 AND ehv.visible = 1) AS a" &_
                       ")"
    witnessedDateSql = Replace(witnessedDateSql, "{expHistoryView}", expHistoryView)

    ' construct the SQL filter for status
    ' EX: "AND t.status in ('created','saved','signed - open','signed - closed','witnessed','rejected','regulatory check')"

    ' status types: (note, these are the values from the UI)
    '   1 => Created
    '   2 => Saved
    '   3 => Signed - Open
    '   4 => Signed - Closed
    '   5 => Witnessed
    '   6 => Rejected
    '   7 => Regulatory Check

    commaSeparatedStatuses = ""
    For i=0 to statusArray.length
	    curStat = CSTR(statusArray.get(i))

	    ' check to see if we need a comma before this status
	    commaSeparator = ""
        If commaSeparatedStatuses <> "" Then
            commaSeparator = ","
        End If

        If curStat = "1" OR curStat = "'1" OR curStat = "1'" OR curStat = "'1'" Then
		    commaSeparatedStatuses = commaSeparatedStatuses & commaSeparator & "'created'"
	    ElseIf curStat = "2" OR curStat = "'2" OR curStat = "2'" OR curStat = "'2'" Then
		    commaSeparatedStatuses = commaSeparatedStatuses & commaSeparator & "'saved'"
	    ElseIf curStat = "3" OR curStat = "'3" OR curStat = "3'" OR curStat = "'3'" Then
		    commaSeparatedStatuses = commaSeparatedStatuses & commaSeparator & "'signed - open'"
	    ElseIf curStat = "4" OR curStat = "'4" OR curStat = "4'" OR curStat = "'4'" Then
		    commaSeparatedStatuses = commaSeparatedStatuses & commaSeparator & "'signed - closed'"
	    ElseIf curStat = "5" OR curStat = "'5" OR curStat = "5'" OR curStat = "'5'" Then
		    commaSeparatedStatuses = commaSeparatedStatuses & commaSeparator & "'witnessed'"
	    ElseIf curStat = "6" OR curStat = "'6" OR curStat = "6'" OR curStat = "'6'" Then
		    commaSeparatedStatuses = commaSeparatedStatuses & commaSeparator & "'rejected'"
	    ElseIf curStat = "7" OR curStat = "'7" OR curStat = "7'" OR curStat = "'7'" Then
		    commaSeparatedStatuses = commaSeparatedStatuses & commaSeparator & "'regulatory check'"
	    End If
    next

    ' if we have statuses then apply the filter
    statusStr = ""
    If commaSeparatedStatuses <> "" Then
        statusStr = "AND t.status in (" & commaSeparatedStatuses & ") "
    End If


    ' figure out which date column to use in the date filter
    '   dateTypes:
    '   1 => Date Created
    '   2 => Date Updated
    '   3 => Sign Close Date
    '   4 => Date Witnessed
	dateColumn = "t.dateSubmitted"
	Select Case dateType
		Case "'2'"
			dateColumn = "t.dateUpdated"
		Case "'3'"
			dateColumn = signCloseDateSql
		Case "'4'"
			dateColumn = witnessedDateSql
	End Select

    ' construct the date filter
	dateFilter = "AND " & dateColumn

	IF dateBefore = "''" and dateAfter = "''" THEN
		dateFilter = ""
	ELSEIF dateBefore = "''" THEN
		dateFilter = dateFilter & " > " & dateAfter
	ELSEIF dateAfter = "''" THEN
		dateFilter = dateFilter & " < " & dateBefore
	ELSE
		dateFilter = dateFilter & " BETWEEN " & dateAfter & " AND " & dateBefore
	END IF

	dateFilter = dateFilter & " "

    ' construct the query
	strQuery = "SELECT DISTINCT " &_
        " t.id," &_
        " t.lastName," &_
        " t.firstName," &_
        " t.email," &_
        " t.notebookId as notebookId," &_
        " t.notebookName as notebookNumber," &_
        " nn.description as notebookDescription," &_
        " t.name as experimentNumber," &_
        " t.details as experimentDesc," &_
        " t.status," &_
        " CASE b.statusId WHEN 8 THEN 'Yes' ELSE 'No' END as Reopened," &_
        " u2.fullName as witnessee," &_
        " n.name," &_
        " n.note as ExpNote," &_
        " ng.NotebookParentProjectName," &_
        " ng.NotebookParentProjectDescription," &_
        " ng.NotebookProjectName," &_
        " ng.NotebookProjectDescription," &_
        " ng.projectId AS notebookProjectId," &_
        " ng.parentProjectId AS notebookParentProjectId," &_
        " p1.name AS projectName," &_
        " p1.description AS projectDescription," &_
        " p2.name AS parentProjectName," &_
        " p2.description AS parentProjectDescription," &_
        " l.projectId," &_
        " p1.parentProjectId," &_
        " t.dateSubmitted as Date_Created," &_
        " t.dateUpdated as Date_Last_Modified," &_
        " {signCloseDateSql} AS SignCloseDate," &_
        " {witnessedDateSql} AS WitnessedDate" &_

        " FROM {expViewTable} t WITH (NOLOCK)" &_
        " LEFT JOIN (SELECT statusId, experimentId FROM {expHistoryView} WITH (NOLOCK) WHERE statusID = 8 AND companyid = {companyId}) AS b" &_
            " ON t.id = b.experimentId" &_
            " AND t.email LIKE '%@{filterData}%'" &_
        " LEFT JOIN notebooks nn WITH (NOLOCK) ON t.notebookId = nn.id" &_
	    " LEFT JOIN (SELECT TOP 1 experimentId, name, note, dateAdded FROM {notesHistory} WITH (NOLOCK) WHERE Name like '%reop%' or note like '%reop%' ) AS n" &_
            " ON t.id = n.experimentId" &_
        " LEFT JOIN (SELECT np.notebookId, npp.name as NotebookProjectName, npp.description as NotebookProjectDescription ,nppp.name as NotebookParentProjectName, nppp.description as NotebookParentProjectDescription, np.projectId, npp.parentProjectId" &_
                   " FROM linksProjectNotebooks np WITH (NOLOCK)" &_
                   " LEFT JOIN projectView npp WITH (NOLOCK) ON np.projectId = npp.id" &_
                   " LEFT JOIN projectView nppp WITH (NOLOCK) ON npp.parentProjectId = nppp.id) as ng" &_
            " ON nn.id = ng.notebookId" &_
	    " LEFT JOIN (SELECT TOP 1 p.experimentId, p.experimentType, pp.id as projectId, pp.name as projectName, pp.description as projectDescription, pp.parentProjectId, ppp.name as parentProjectName, ppp.description as parentProjectDescription" &_
                   " FROM projectExperimentPermView p WITH (NOLOCK)" &_
                   " LEFT JOIN projectView pp WITH (NOLOCK) ON p.projectId = pp.id" &_
                   " LEFT JOIN projectView ppp WITH (NOLOCK) ON pp.parentProjectId = ppp.id) as g" &_
            " ON t.id = g.experimentId AND g.experimentType = {expType}" &_
        " JOIN users u ON u.email = t.email" &_
        " LEFT JOIN linksProjectExperiments l ON t.id=l.experimentId AND l.experimentType={expType}" &_
        " LEFT JOIN projects p1 ON p1.id=l.projectId" &_
        " LEFT JOIN projects p2 ON p2.id=p1.parentProjectId" &_
        " LEFT JOIN witnessRequests r ON r.experimentId=t.id AND r.experimentTypeId=" & expType &_
        " LEFT JOIN usersView u2 ON r.requesteeId=u2.id" &_
        " WHERE t.companyId = {companyId}" &_
        " AND t.firstname != 'arxspan'" &_
        " AND t.visible = 1" &_
        " {userFilter}" &_
        " {dateFilter}" &_
        " {statusFilter}" &_
        " {reqFilter}" &_
        " AND u.email LIKE '%@{filterData}%'" &_
        " AND u.email <> 'support@arxspan.com'"
	
	' The userID stuff gets figured out in report_activity_detail.asp.
	userFilter = IIF(currUserId = "" AND UBound(userIds) < 1, "", "AND (u.id IN ({userId}) {groupFilter})")
	reqFilter = IIF(reqType <> "", "AND t.requestTypeId = " & reqType, "")
	groupFilter = IIF(groups.length > 0, "AND u.id IN (SELECT userId FROM groupMembers WHERE groupId in ({groupIds}))", "")
	groupFilter = Replace(groupFilter, "{groupIds}", groups.join(","))

    ' format the final query
    strQuery = Replace(strQuery, "{signCloseDateSql}", signCloseDateSql)
    strQuery = Replace(strQuery, "{witnessedDateSql}", witnessedDateSql)
	strQuery = Replace(strQuery, "{companyId}", SQLClean(session("companyId"), "T", "T"))
	strQuery = Replace(strQuery, "{userFilter}", userFilter)
	strQuery = Replace(strQuery, "{groupFilter}", groupFilter)
	strQuery = Replace(strQuery, "{userId}", IIF(UBound(userIds) < 1, currUserId, Join(userIds, ",")))
	strQuery = Replace(strQuery, "{filterData}", session("opReportFilter"))
	strQuery = Replace(strQuery, "{expViewTable}", expViewTable)
	strQuery = Replace(strQuery, "{expHistoryView}", expHistoryView)
	strQuery = Replace(strQuery, "{notesHistory}", notesHistory)
	strQuery = Replace(strQuery, "{dateFilter}", dateFilter)
	strQuery = Replace(strQuery, "{statusFilter}", statusStr)
	strQuery = Replace(strQuery, "{reqFilter}", reqFilter)
	strQuery = Replace(strQuery, "{expType}", expType)

	getDetailedReportQuery = strQuery
End Function
%>