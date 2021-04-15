
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
Server.ScriptTimeout=108000
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
bulkRegEndpointUrl = getCompanySpecificSingleAppConfigSetting("bulkRegEndpointUrl", session("companyId"))
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, fid, newUploadId, userName, sdFilename, (SELECT COUNT(1) FROM " & regMoleculesTable & " WHERE arxspan_sd_source_id = sdImports.id) AS rowcnt FROM sdImports ORDER BY id DESC"
rec.open strQuery,jchemRegConn

numRows = 0
Set retValData = JSON.Parse("[]")
Do While Not rec.eof
	numRows = numRows + 1
	Set thisRow = JSON.Parse("[]")
	thisRow.push CStr(rec("userName"))
	thisRow.push "<a href=importProgress.asp?fid="&rec("fid")&">"&rec("sdFilename")&"</a>"
	
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.open "GET", bulkRegEndpointUrl&"/getUploadStatus?uploadId="&rec("newUploadId"), True
	http.SetTimeouts 180000,180000,180000,180000
	' ignore ssl cert errors
	http.setOption 2, 13056
	http.send
	http.waitForResponse(180)
	
	Set uploadStatus = JSON.Parse(http.responseText)
	If uploadStatus.Exists("status") Then
		thisRow.push uploadStatus.Get("status")
	Else
		thisRow.push ""
	End If
	
	If uploadStatus.Exists("items") Then
		Set uploadItems = uploadStatus.Get("items")
		thisRow.push uploadItems.Get("rowCount")
		thisRow.push uploadItems.Get("errorCount")
		
		If uploadItems.Exists("percentComplete") And CStr(uploadItems.Get("percentComplete")) = "100" Then
			thisRow.push "<a href=services/get-upload-report-file.asp?fid="&rec("fid")&" class=littleButton>Download</a>"
			If session("regRegistrar") Then
				actionLinks = ""
				If uploadStatus.Get("makeBatches") = "DONT_MAKE_BATCHES" Then
					' Get the row count from the reg table. That is more acurate than the row count from the upload table
					' rowCount = uploadItems.Get("rowCount")
					rowCount = rec("rowCnt")
					If rowCount > 0 Then
						actionLinks = "<a href=SDRollbackStart.asp?id="&rec("id")&"&compounds=1&batches=0>Compounds ("&rowCount&")</a>"
					Else
						actionLinks = "No Records Created"
					End If
				End If
				If uploadStatus.Get("makeBatches") = "MAKE_BATCHES" Then
					' Get the row count from the reg table. That is more acurate than the row count from the upload table
					' rowCount = uploadItems.Get("rowCount")
					rowCount = rec("rowCnt")
					If rowCount > 0 Then
						actionLinks = "<a href=SDRollbackStart.asp?id="&rec("id")&"&compounds=0&batches=1>Batches ("&rowCount&")</a>"
					Else
						actionLinks = "No Records Created"
					End If
				End If
				if actionLinks = "" Then
					actionLinks = "Not Available For Updates"
				End If
				thisRow.push actionLinks
			End If
		Else
			thisRow.push "Not Available"
			If session("regRegistrar") Then
				thisRow.push "Upload Incompleted"
			End If
		End If
	Else
		thisRow.push 0
		thisRow.push 0
		thisRow.push "Not Available"
		If session("regRegistrar") Then
			thisRow.push "Upload Failed"
		End If
	End If
	
	If uploadStatus.Exists("dateUploaded") Then
		dateUploadedUTC = uploadStatus.Get("dateUploaded")
		If session("useGMT") Then
			dateUploaded = dateUploadedUTC
		Else
			dateUploaded = ConvertUTCToLocal(dateUploadedUTC)
		End If

		thisRow.push dateUploaded & ""
	Else
		thisRow.push ""
	End If
	
	If uploadStatus.Exists("dateProcessed") Then
		dateProcessedUTC = uploadStatus.Get("dateProcessed")
		If session("useGMT") Then
			dateProcessed = dateProcessedUTC
		Else
			dateProcessed = ConvertUTCToLocal(dateProcessedUTC)
		End If

		thisRow.push dateProcessed & "" 
	Else
		thisRow.push ""
	End If
	
	retValData.push thisRow
	rec.movenext
Loop
rec.close
Set rec = Nothing
Call disconnectJchemReg

Set retVal = JSON.Parse("{}")
retVal.Set "sEcho", 1
retVal.Set "iTotalRecords", numRows
retVal.Set "iTotalDisplayRecords", numRows
retVal.Set "aaData", retValData

jsonResp = JSON.Stringify(retVal)

'write the response in 1mb chunks - I was getting a buffer overrun in cases where trying to return a lot of data
chunkId = 0
chunkSize = 1000000
responseLen = Len(jsonResp)
Do While chunkId * chunkSize < responseLen
	response.write(Mid(jsonResp, (chunkId * chunkSize) + 1, chunkSize))
	response.flush()
	chunkId = chunkId + 1
Loop

response.end
%>
