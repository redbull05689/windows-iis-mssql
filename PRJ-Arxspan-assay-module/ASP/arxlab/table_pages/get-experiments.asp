<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
yMeansShowMyExperiments = request.Form("yMeansShowMyExperiments")
sortOrder = request.Form("sortOrder")
startRecord = request.Form("iDisplayStart")
numRecords = request.Form("iDisplayLength")
sEcho = request.Form("sEcho")
sSearch = request.Form("sSearch")

Function GetStringFromValue(value)
	If IsNull(value) Then
		GetStringFromValue = ""
	Else
		GetStringFromValue = CStr(value)
	End If    
End Function

filterQuery = "WHERE e.userId = {uId} "
If yMeansShowMyExperiments <> "y" Then
	filterQuery = "WHERE e.userId <> {uId} "
End If

strQuery = "select e.*, s.name as status, n.name as notebookName, t.type, u.firstName + ' ' + u.lastName as fullName from " &_
		   "(select v.experimentId, a.name, a.userId, a.notebookId, v.experimentType as typeId, a.dateSubmitted, v.theDate, LEFT(a.details, 1000) as details, a.userExperimentName, a.requestTypeId, a.statusId from (select * from recentlyViewedExperiments where userId={uId}) v INNER JOIN allExperiments a on a.legacyId=v.experimentId and v.experimentType=a.experimentType where visible=1) e " &_
		   "INNER JOIN statuses s on e.statusId=s.id " &_
		   "INNER JOIN notebooks n on e.notebookId=n.id " &_
		   "INNER JOIN experimentTypes t on e.typeId=t.id " &_
		   "INNER JOIN users u on e.userId=u.id " &_
		   filterQuery

strQuery = Replace(strQuery, "{cId}", SQLClean(session("companyId"),"N","S"))
strQuery = Replace(strQuery, "{uId}", SQLClean(session("userId"),"N","S"))

Set rec99 = server.CreateObject("ADODB.RecordSet")
rec99.CursorLocation = adUseClient
rec99.open strQuery, conn, adOpenStatic, adLockReadOnly, adCmdText

Set jsonOut = JSON.parse("{}")
jsonOut.Set "sEcho", CInt(sEcho)
jsonOut.Set "iTotalRecords", rec99.recordCount

If sSearch <> "" Then
	filterStr = "status like '*{sSearch}*' or notebookName like '*{sSearch}*' or fullName like '*{sSearch}*' or type like '*{sSearch}*' or details like '*{sSearch}*' or userExperimentName like '*{sSearch}*' or name like '*{sSearch}*'"
	rec99.Filter = Replace(filterStr, "{sSearch}", sSearch)
End If

If sortOrder <> "" Then
	rec99.Sort = sortOrder
End If

If startRecord > 0 Then
	rec99.move startRecord
End If

numRows = rec99.recordCount
'set the number of hits (filtered results) in the return value
jsonOut.Set "iTotalDisplayRecords", numRows

If numRecords <> "" And numRecords <> "-1" Then
	numRows = numRecords
End If
	
recordsProcessed = 0
numRows = CInt(numRows)
Set aaData = JSON.parse("[]")
Do While recordsProcessed < numRows
	If rec99.eof Then
		Exit Do
	End If
	recordsProcessed = recordsProcessed + 1
	
    name = rec99("name")
    expId= rec99("experimentId")
    notebook = rec99("notebookName")
    status = rec99("status")
    expType = rec99("type")
    typeId = rec99("typeId")
    creator = rec99("fullName")
    created = rec99("dateSubmitted")
    lastViewed = rec99("theDate")
    notebookId = rec99("notebookId")
    desc = rec99("details")
    expUserName = rec99("userExperimentName")
	requestTypeId = rec99("requestTypeId")

    prefix = GetPrefix(typeId)
    expPage = GetExperimentPage(prefix)
    
    expPage = expPage & "?id=" & expId
    
	Set aa = JSON.parse("[]")
	aa.push("<a href=" & mainAppPath & "/" & expPage & "> " & name & "</a><br><i>" & expUserName & "</i>")
	aa.push(GetStringFromValue(desc))	
	aa.push("<a href=" & mainAppPath & "/show-notebook.asp?id=" & notebookId & "> " & notebook & "</a>")	
	aa.push(GetStringFromValue(status))	
	aa.push(expType)	
	aa.push(GetStringFromValue(creator))	
	aa.push(GetStringFromValue(created))
	aa.push(GetStringFromValue(lastViewed))	
	aa.push(typeId)
	aa.push(expId)
	aa.push(requestTypeId)
	aaData.push(aa)

	rec99.movenext
loop
rec99.close
Set rec99 = Nothing

jsonOut.Set "aaData", aaData
jsonResp = JSON.Stringify(jsonOut)

'write the response in 1mb chunks - I was getting a buffer overrun in cases where trying to return a lot of data
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