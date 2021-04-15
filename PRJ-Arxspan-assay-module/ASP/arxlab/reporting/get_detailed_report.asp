<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="functions/fnc_get_detailed_report_query.asp"-->
<%
response.ContentType="text/plain"

set inputData = JSON.parse(request.form("data"))

expType = CStr(inputData.get("exp"))
reqType = ""
reqName = ""

expTypeDim = Split(expType, "_")

if UBound(expTypeDim) > 0 then
	expType = SQLClean(expTypeDim(0), "T", "T")
	reqType = SQLClean(expTypeDim(1), "T", "T")
	reqName = expTypeDim(2)
end if

' get the current user id
idStr = CSTR(inputData.get("id").join("-"))
userIds = Split(idStr, "-")
For i=0 to UBound(userIds)
	userIds(i) = SQLClean(userIds(i), "N", "N")
Next

If UBound(userIds) >= 1 Or idStr = "" Then
	currUserId = ""
Else
	currUserId = userIds(0)
End If

' By default, we're going to get results for Chemistry experiments
prefix = GetPrefix(expType)
expViewTable = GetExperimentView(prefix)
expHistoryView = GetFullName(prefix, "experimentHistoryView", true)
typeStr = IIF(reqType = "", GetFullExpType(expType, null), reqName)
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
strRptQuery = getDetailedReportQuery(expViewTable, expHistoryView, notesHistory, expType, userIds, currUserId, statusArray, reqType, groups, dateType, dateBefore, dateAfter)
strQuery = "{strRptQuery} ORDER BY t.lastName, t.id;"
strQuery = Replace(strQuery, "{strRptQuery}", strRptQuery)

' fetch the data from the DB
Set rec = server.CreateObject("ADODB.RecordSet")
' 5515 - Making sure the query has enough time to complete.
rec.open strQuery,connNoTimeout,0,-1
Do While Not rec.eof
	lastName = rec("lastName")
	firstName = rec("firstName")
	userEmail = rec("email")
	notebookNumber = rec("notebookNumber")
	noteboookDescription = rec("notebookDescription")
	experimentNumber = rec("experimentNumber")
	expStatus = rec("status")
	reopened = rec("reopened")
	expName = rec("name")
	expDesc = rec("experimentDesc")
	expNote = rec("expNote")
	witnessee = rec("witnessee")
	noteParentProjName = rec("NotebookParentProjectName")
	noteParentProjDesc = rec("NotebookParentProjectDescription")
	noteProjName = rec("NotebookProjectName")
	noteProjDesc = rec("NotebookProjectDescription")
	projName = rec("projectName")
	projDesc = rec("projectDescription")
	parentProjName = rec("parentProjectName")
	parentProjDesc = rec("parentProjectDescription")
	dateCreated = rec("Date_Created")
	lastModified = rec("Date_Last_Modified")
	signClose = rec("SignCloseDate")
	witnessed = rec("WitnessedDate")
	dateCreated = IIF(IsNull(dateCreated), "", dateCreated)
	lastModified = IIF(IsNull(lastModified), "", lastModified)
	signClose = IIF(IsNull(signClose), "", signClose)
	witnessed = IIF(IsNull(witnessed), "", witnessed)
	
	expId = rec("id")
	noteId = rec("notebookId")
	projectId = rec("projectId")
	parentProjectId = rec("parentProjectId")
	notebookProjectId = rec("notebookProjectId")
	notebookParentProjectId = rec("notebookParentProjectId")

	noteLink = makeLink(noteId, notebookNumber, mainAppPath, notebookUrl)
	expLink = makeLink(expId, experimentNumber, mainAppPath, expUrl)
	noteParProjLink = makeLink(notebookParentProjectId, noteParentProjName, mainAppPath, projUrl)
	noteProjLink = makeLink(notebookProjectId, noteProjName, mainAppPath, projUrl)
	projLink = makeLink(projectId, projName, mainAppPath, projUrl)
	parProjLink = makeLink(parentProjectId, parentProjName, mainApppath, projUrl)

	IF not IsNull(expNote) THEN
		expNote = Replace(expNote, """", "'")
	END IF
	response.write(expType & ":::" &_
		typeStr & ":::" &_
		lastName & ":::" &_
		firstName & ":::" &_
		userEmail & ":::" &_
		noteLink & ":::" &_
		notebookDescription & ":::" &_
		expLink & ":::" &_
		expDesc & ":::" &_
		expStatus & ":::" &_
		reopened & ":::" &_
		witnessee & ":::" &_
		expName & ":::" &_
		expNote & ":::" &_
		noteParProjLink & ":::" &_
		noteParentProjDesc & ":::" &_
		noteProjLink & ":::" &_
		noteProjDesc & ":::" &_
		projLink & ":::" &_
		projDesc & ":::" &_
		parProjLink & ":::" &_
		ParentProjDesc & ":::" &_
		dateCreated & ":::" &_
		lastModified & ":::" &_
		signClose & ":::" &_
		witnessed & ";;;")
	rec.movenext
loop
rec.close

Function makeLink(id, name, mainPath, urlPath) 
	makeLink = IIF((Not IsNull(id) OR Not IsNull(name)), "<a href='" & mainPath & urlPath & id & "'>" & name & "</a>", "")
End Function
%>
