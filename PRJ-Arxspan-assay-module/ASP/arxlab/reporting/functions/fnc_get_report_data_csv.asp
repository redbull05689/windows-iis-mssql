<!-- #include file="fnc_get_detailed_report_query.asp"-->
<%
Response.CodePage = 65001    
Response.CharSet = "utf-8"

Function getReportData(expType, idStr, reqType, statusArray, reqName, groups, dateType, dateBefore, dateAfter)
userIds = Split(idStr, "-")
For i=0 to UBound(userIds)
	userIds(i) = SQLClean(userIds(i), "N", "N")
Next

expType = SQLClean(expType, "T", "T")

If UBound(userIds) >= 1 Or idStr = "" Then
	currUserId = ""
Else
	currUserId = userIds(0)
End If

prefix = GetPrefix(expType)

If prefix <> "" Then
	expViewTable = prefix & "ExperimentsView"
Else
	expViewTable = "experimentView"
End iF
expHistoryView = GetFullName(prefix, "experimentHistoryView", true)
notesHistory = GetFullName(prefix, "notes_history", true)
typeStr = IIF(reqType = "", GetFullExpType(expType, null), reqName)

' construct the query by taking the query used for the actual data fetching and then wrapping it in a select count(*)
strRptQuery = getDetailedReportQuery(expViewTable, expHistoryView, notesHistory, expType, userIds, currUserId, statusArray, reqType, groups, dateType, dateBefore, dateAfter)
strQuery = "{strRptQuery} ORDER BY t.lastName, t.id;"
strQuery = Replace(strQuery, "{strRptQuery}", strRptQuery)

Set rec = server.CreateObject("ADODB.RecordSet")
rec.open strQuery,conn,0,-1

dim doubleByteRegExp
Set doubleByteRegExp = New RegExp
doubleByteRegExp.IgnoreCase = True
doubleByteRegExp.Global = False
doubleByteRegExp.Pattern = "&#[0-9]{1,};"

Do While Not rec.eof
	lastName = CleanAndDecodeData(doubleByteRegExp, rec("lastName"),"CSV","")
	firstName = CleanAndDecodeData(doubleByteRegExp, rec("firstName"),"CSV","")
	userEmail = SQLClean(rec("email"),"CSV","")
	notebookNumber = CleanAndDecodeData(doubleByteRegExp, rec("notebookNumber"),"CSV","")
	noteboookDescription = CleanAndDecodeData(doubleByteRegExp, rec("notebookDescription"),"CSV","")
	experimentNumber = CleanAndDecodeData(doubleByteRegExp, rec("experimentNumber"),"CSV","")
    experimentDesc = CleanAndDecodeData(doubleByteRegExp, rec("experimentDesc"),"CSV","")
	expStatus = SQLClean(rec("status"),"CSV","")
	reopened = SQLClean(rec("reopened"),"CSV","")
	witnessee = rec("witnessee")
	expName = CleanAndDecodeData(doubleByteRegExp, rec("name"),"CSV","")
	expNote = CleanAndDecodeData(doubleByteRegExp, rec("expNote"),"CSV","")
	noteParentProjName = CleanAndDecodeData(doubleByteRegExp, rec("NotebookParentProjectName"),"CSV","")
	noteParentProjDesc = CleanAndDecodeData(doubleByteRegExp, rec("NotebookParentProjectDescription"),"CSV","")
	noteProjName = CleanAndDecodeData(doubleByteRegExp, rec("NotebookProjectName"),"CSV","")
	noteProjDesc = CleanAndDecodeData(doubleByteRegExp, rec("NotebookProjectDescription"),"CSV","")
	projName = CleanAndDecodeData(doubleByteRegExp, rec("projectName"),"CSV","")
	projDesc = CleanAndDecodeData(doubleByteRegExp, rec("projectDescription"),"CSV","")
	parentProjName = CleanAndDecodeData(doubleByteRegExp, rec("parentProjectName"),"CSV","")
	parentProjDesc = CleanAndDecodeData(doubleByteRegExp, rec("parentProjectDescription"),"CSV","")
	dateCreated = SQLClean(rec("Date_Created"),"CSV","")
	dateCreated = SQLClean(IIF(IsNull(dateCreated), "", dateCreated),"CSV","")
	lastModified = SQLClean(rec("Date_Last_Modified"),"CSV","")
	lastModified = SQLClean(IIF(IsNull(lastModified), "", lastModified),"CSV","")
	signClose = SQLClean(rec("SignCloseDate"),"CSV","")
	signClose = SQLClean(IIF(IsNull(signClose), "", signClose),"CSV","")
	witnessed = SQLClean(rec("WitnessedDate"),"CSV","")
	witnessed = SQLClean(IIF(IsNull(witnessed), "", witnessed),"CSV","")

	response.write(typeStr & "," &_
			lastName & "," &_
			firstName & "," &_
			userEmail & "," &_
			notebookNumber & "," &_
			notebookDescription & "," &_
			experimentNumber & "," &_
			experimentDesc & "," &_
			expStatus & "," &_
			reop & "," &_
			witnessee & "," &_
			expName & "," &_
			expNote & "," &_
			noteParentProjName & "," &_
			noteParentProjDesc & "," &_
			noteProjName & "," &_
			noteProjDesc & "," &_
			projName & "," &_
			projDesc & "," &_
			parentProjName & "," &_
			parentProjDesc & "," &_
			dateCreated & "," &_
			lastModified & "," &_
			signClose & "," &_
			witnessed & "," &_
			vbCrLf)
	rec.movenext
loop
rec.close
End Function
%>