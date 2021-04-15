<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%
Set rec = server.CreateObject("ADODB.RecordSet")
rec.CursorLocation = adUseClient

set fs = Server.CreateObject("Scripting.FileSystemObject")
notebookId = request.Form("notebookId")
sortOrder = request.Form("sortOrder")
startRecord = request.Form("iDisplayStart")
numRecords = request.Form("iDisplayLength")
sEcho = request.Form("sEcho")
sSearch = request.Form("sSearch")

' Set up the main query for the allExperiments table. We're essentially running this query twice,
' but once is filtered against the list of visible experiments and the other is the list of experiments
' that the current user owns.
baseQuery = "SELECT " &_
                "a.name, " &_
                "s.name AS status, " &_
                "e.type AS type, " &_
                "a.requestTypeId, " &_
                "u.firstName + ' ' + u.lastName AS creator, " &_
                "a.dateSubmittedServer, " &_
                "a.dateUpdatedServer, " &_
                "a.legacyId, " &_
                "a.experimentType AS typeId, " &_
                "a.revisionNumber, " &_
                "a.description, " &_
                "a.details, " &_
                "a.userId AS creatorId, " &_
                "a.userExperimentName " &_
            "FROM allExperiments a " &_
            "{tempJoin} " &_
            "JOIN statuses s ON a.statusId=s.id " &_
            "JOIN experimentTypes e ON a.experimentType=e.id " &_
            "JOIN users u ON a.userId=u.id " &_
            "WHERE a.notebookId=? " &_
            "AND a.visible=1 "

' Get the list of visible experiments by running the stored procedure to fetch visible experiments,
' then store the results in a temp table. Run the baseQuery once, joining allExperiments on the tempTable
' to quickly get a list of visible experiments in this notebook, then run the query again to get everything
' the user owns and union the two result sets.
notebookQuery = "DROP TABLE IF EXISTS #T; " &_
                "SET NOCOUNT ON; " &_
                "CREATE TABLE #T (uniqueId int, " &_
                    "experimentId int, " &_
                    "experimentType int); " &_
                "INSERT #T EXEC elnGetVisibleExperiments @userId=?, @companyId=?; " &_
                Replace(baseQuery, "{tempJoin}", "INNER JOIN #T t on a.id=t.uniqueId") &_
                "UNION " &_
                Replace(baseQuery, "{tempJoin}", "") &_
                "AND a.userId=?;" &_
                "DROP TABLE #T; "

Set rec = server.createobject("ADODB.RecordSet")
rec.CursorLocation = adUseClient
rec.CursorType = adOpenStatic

Set cmd = server.createobject("ADODB.Command")
cmd.ActiveConnection = connAdm
cmd.CommandText = notebookQuery
cmd.CommandType = adCmdText

cmd.Parameters.Append(cmd.CreateParameter("@userId1", adInteger, adParamInput, len(session("userId")), session("userId")))
cmd.Parameters.Append(cmd.CreateParameter("@companyId", adInteger, adParamInput, len(session("companyId")), session("companyId")))
cmd.Parameters.Append(cmd.CreateParameter("@notebookId1", adInteger, adParamInput, len(notebookId), notebookId))
cmd.Parameters.Append(cmd.CreateParameter("@notebookId2", adInteger, adParamInput, len(notebookId), notebookId))
cmd.Parameters.Append(cmd.CreateParameter("@userId2", adInteger, adParamInput, len(session("userId")), session("userId")))

' 10120 - Doing rec.open here instead of cmd.execute to have the cursor be client-side,
' which allows us to do rec.Filter, rec.sort, etc. The second parameter, the db connection, is blank
' because we cannot set a connection with rec.open if the base object is an ADODB.Command that
' already has one.
rec.open cmd, , adOpenStatic, adLockReadOnly, adCmdText

' set the total number of available records in the return value
Set jsonOut = JSON.parse("{}")
jsonOut.Set "sEcho", CInt(sEcho)
jsonOut.Set "iTotalRecords", rec.recordCount

If sSearch <> "" Then
    filterString = "name like '*{sSearch}*' or type like '*{sSearch}*' or creator like '*{sSearch}*' or description like '*{sSearch}*' or details like '*{sSearch}*' or userExperimentName like '*{sSearch}*'"
	rec.Filter = Replace(filterString, "{sSearch}", sSearch)
End If

If sortOrder <> "" Then
	rec.Sort = sortOrder
End If

If startRecord > 0 Then
	rec.move startRecord
End If

numRows = rec.recordCount
'set the number of hits (filtered results) in the return value
jsonOut.Set "iTotalDisplayRecords", numRows

If numRecords <> "" And numRecords <> "-1" Then
	numRows = numRecords
End If

recordsProcessed = 0
numRows = CInt(numRows)
Set aaData = JSON.parse("[]")
Do While recordsProcessed < numRows
	If rec.eof Then
		Exit Do
	End If
	recordsProcessed = recordsProcessed + 1
    name = rec("name")
    status = rec("status")
    expId = rec("legacyId")
    eType = rec("type")   
    creator = rec("creator")
    creatorId = rec("creatorId")
    created = rec("dateSubmittedServer")
    updated = rec("dateUpdatedServer")
    typeId = rec("typeId")
    revNum = rec("revisionNumber")
    expUserName = rec("userExperimentName")
    desc = rec("details")
	requestTypeId = rec("requestTypeId")

    if IsNull(desc) Then
        desc = ""
    End if

    prefix = GetPrefix(typeId)
    expPage = GetExperimentPage(prefix)
    
    expPage = expPage & "?id=" & expId
	If eType="Custom" and status = "created" Then
		expPage = expPage & "&r=" & requestTypeId
	End If

    abbrv = LCase(Left(eType, substrLen))

    if abbrv = "conc" then
        abbrv = "free"
    end if

    pdfLoc = uploadRoot & "\" & creatorId & "\" & expId & "\" & revNum & "\" & abbrv & "\"
    regPdf = pdfLoc & "sign.pdf"
    pdfLink = "<a href=" & mainAppPath & "/experiments/makePDFVersion.asp?experimentId=" & expId & "&experimentType=" & typeId & "&revisionNumber=" & revNum & " class='littleButton'>PDF</a>"
    

    If fs.fileExists(regPdf) then
        pdfLink = Replace(pdfLink, "experiments/makePDFVersion.asp?experimentI", "signed.asp?i")
    end if

    if session("hasShortPdf") = true then    
        shortPdfLink = "<a href=" & mainAppPath & "/experiments/makePDFVersion.asp?experimentId=" & expId & "&experimentType=" & typeId & "&revisionNumber=" & revNum & "&short=1" & " class='littleButton'>Short PDF</a>"

        shortPdf = pdfLoc & "sign-short.pdf"
        If fs.fileExists(shortPdf) then
            shortPdfLink = Replace(shortPdfLink, "experiments/makePDFVersion.asp?experimentI", "signed.asp?i")
        end if

        pdfLink = pdfLink & shortPdfLink
    end if

    if expUserName <> "" then
     name = name & ": " & expUserName
    end if

	Set aa = JSON.parse("[]")
	aa.push("<a href=" & mainAppPath & "/" & expPage & "> " & name & "</a>")
	aa.push(status)
	aa.push(eType)
	aa.push(creator)
	aa.push(CStr(created))
	aa.push(CStr(updated))
	aa.push(pdfLink)
	aa.push(CStr(desc))
	aa.push(typeId)
	aa.push(expId)
	aa.push(requestTypeId)
	aaData.push(aa)
	
	rec.movenext
loop
rec.close
Set rec = Nothing

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
