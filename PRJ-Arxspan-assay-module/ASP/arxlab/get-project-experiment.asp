<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"--><%
Set recExp = server.CreateObject("ADODB.RecordSet")

projId = request.form("projId")
projectOwner = request.form("projectOwner")

sortOrder = request.Form("sortOrder")
startRecord = request.Form("iDisplayStart")
numRecords = request.Form("iDisplayLength")
sEcho = request.Form("sEcho")
sSearch = request.Form("sSearch")

Set aaData = JSON.parse("[]")
Set jsonOut = JSON.parse("{}")

SQLQuery = "EXEC dbo.elnGetProjectExperiments @userId={userId}, @companyId={companyId}, @projectId={projectId}"

If sSearch <> "" Then	
	SQLQuery = SQLQuery & ",@searchString='{sSearch}'"	
	SQLQuery = Replace(SQLQuery, "{sSearch}", sSearch)	
End If

If sortOrder <> "" AND numRecords <> 0 Then
	SQLQuery = SQLQuery & ",@offset={startRecord},@numRecords={numRecords},@sortOrder='{sortOrder}'"	
end if

SQLQuery = Replace(SQLQuery, "{userId}", SQLClean(session("userId"),"N","S"))
SQLQuery = Replace(SQLQuery, "{companyId}", SQLClean(session("companyId"),"N","S"))
SQLQuery = Replace(SQLQuery, "{projectId}", SQLClean(projId,"N","S"))
SQLQuery = Replace(SQLQuery, "{sortOrder}", sortOrder)
SQLQuery = Replace(SQLQuery, "{numRecords}", SQLClean(numRecords,"N","S"))
SQLQuery = Replace(SQLQuery, "{startRecord}", SQLClean(startRecord,"N","S"))

recExp.open SQLQuery, connAdm, 0, 1

jsonOut.Set "sEcho", CInt(sEcho)

totalCount = 0

Do While Not recExp.eof
	expId = recExp("experimentId")
	expName = recExp("name")
	userExpName = recExp("description")
	expType = recExp("type")
	typeId = recExp("experimenttype")
	status = recExp("status")
	dateSub = recExp("dateSubmitted")
	requestTypeId = recExp("requestTypeId")
	desc = recExp("details")
	owner = recExp("firstName") & " " & recExp("lastName")
	requestTypeId = recExp("requestTypeId")
	totalCount = recExp("TotalCount")  ' we only need this one, but its on every record

	prefix = GetPrefix(typeId)
	expPage = GetExperimentPage(prefix) & "?id=" & expId

	delButton = ""

	If projectOwner or (session("canDelete") and session("role")="Admin") Then
		delButton = "<a href='javascript:void(0);' onclick='deleteProjectExperiment(" & Replace(expId, " ", "") & ", " & typeId & ", " & projId & ")'> <img src='" & mainAppPath & "/images/cross_2_1x.png' class='png' height='12' width='12' border='0'></a>"
	End If

	Set aa = JSON.parse("[]")
	aa.push("<a href=" & mainAppPath & "/" & expPage & "> " & expName & "</a>")
	if desc <> Empty then
		aa.push(CStr(desc))
	else
		aa.push("")
	end if
	aa.push(status)
	aa.push(expType)
	aa.push(owner)
	aa.push(CStr(dateSub))
	aa.push(delButton)
	aa.push(typeId)
	aa.push(expId)
	aa.push(requestTypeId)
	aaData.push(aa)
	
	recExp.movenext
loop
recExp.close
Set recExp = Nothing

jsonOut.Set "iTotalDisplayRecords", totalCount

' If we are searching, we want the total without the search terms, I am not a fan of this
If sSearch <> "" Then
	Set recCount = server.CreateObject("ADODB.RecordSet")

	SQLQueryCount = "SELECT count(*) as count " &_ 
	"FROM linksprojectexperimentsview v " &_ 
	"WHERE  v.projectid = {projectId} " &_ 
	"AND (v.visible = 1 OR v.visible IS NULL) "

	SQLQueryCount = Replace(SQLQueryCount, "{projectId}", SQLClean(projId,"N","S"))

	recCount.open SQLQueryCount, connAdm, 3, 3
	if Not recCount.eof Then
		jsonOut.Set "iTotalRecords", cLng(recCount("count"))
	else
		jsonOut.Set "iTotalRecords", 0
	end if
	recCount.close
	set recCount = Nothing
else
	jsonOut.Set "iTotalRecords", totalCount
end if

jsonOut.Set "aaData", aaData
jsonResp = JSON.Stringify(jsonOut)

'write the response in 1mb chunks
chunkId = 0
chunkSize = 1000000
responseLen = Len(jsonResp)
Do While chunkId * chunkSize < responseLen
	response.write(Mid(jsonResp, (chunkId * chunkSize) + 1, chunkSize))
	response.flush()
	chunkId = chunkId + 1
Loop

response.end()
%>
