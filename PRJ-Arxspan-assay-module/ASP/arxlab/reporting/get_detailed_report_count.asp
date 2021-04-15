<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="functions/fnc_get_detailed_report_query.asp"-->
<%
' Count how many results there are for the current request.

set inputData = JSON.parse(request.form("data"))

set expTypes = inputData.get("expTypes")

' get the current user id
idStr = CSTR(inputData.get("userIds").join("-"))
userIds = Split(idStr, "-")
For i=0 to UBound(userIds)
	userIds(i) = SQLClean(userIds(i), "N", "N")
Next

If UBound(userIds) >= 1 Or idStr = "" Then
	currUserId = ""
Else
	currUserId = userIds(0)
End If

' hack to get this to cooperate with me and go through the experiment
dim expTypesDim
redim expTypesDim(expTypes.length - 1)
for i=0 to expTypes.length - 1
	expTypesDim(i) = expTypes.get(i)
next

rowCount = 0

for each expType in expTypesDim
	thisExpType = CSTR(expType)
	thisReqType = ""

	thisExpTypeDim = Split(thisExpType, "_")
	if Ubound(thisExpTypeDim) > 0 Then
		thisExpType = thisExpTypeDim(0)
		thisReqType = thisExpTypeDim(1)
	end if

	' By default, we're going to get results for Chemistry experiments
	prefix = GetPrefix(thisExpType)
	expViewTable = GetExperimentView(prefix)
	expHistoryView = GetFullName(prefix, "experimentHistoryView", true)
	notesHistory = GetFullName(prefix, "notes_history", true)
	expUrl = "/" & GetExperimentPage(prefix) & "?id="
	notebookUrl = "/show-notebook.asp?id="
	projUrl = "/show-project.asp?id="

    ' get some values from the input data
    set groups = inputData.get("groups")
    set statusArray = inputData.get("status")
    dateType = SQLClean(inputData.get("typeDate"), "T", "T")
    dateBefore = SQLClean(inputData.get("dateBefore"), "T", "T")
    dateAfter = SQLClean(inputData.get("dateAfter"), "T", "T")

    ' construct the query by taking the query used for the actual data fetching and then wrapping it in a select count(*)
    strRptQuery = getDetailedReportQuery(expViewTable, expHistoryView, notesHistory, thisExpType, userIds, currUserId, statusArray, thisReqType, groups, dateType, dateBefore, dateAfter)
    strCountQuery = "SELECT COUNT(*) as count FROM ({strRptQuery}) A;"
    strCountQuery = Replace(strCountQuery, "{strRptQuery}", strRptQuery)

    ' fetch the data from the DB
	Set rec = server.CreateObject("ADODB.RecordSet")
	' 5515 - Making sure the query has enough time to complete.
	rec.open strCountQuery,connNoTimeout,0,-1
	currRowCount = IIF(rec.eof, 0, rec("count"))
	rec.close

	rowCount = rowCount + currRowCount
next
response.write(rowCount)
%>