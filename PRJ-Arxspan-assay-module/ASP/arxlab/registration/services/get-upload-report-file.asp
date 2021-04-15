<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
server.scripttimeout = 60000
response.charset = "UTF-8"
response.codePage = 65001
fid = request.querystring("fid")
bulkRegEndpointUrl = getCompanySpecificSingleAppConfigSetting("bulkRegEndpointUrl", session("companyId"))

Set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT newUploadId FROM sdImports WHERE fid="&SQLClean(fid,"T","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.open "GET", bulkRegEndpointUrl&"/getUploadReportFile?uploadId="&rec("newUploadId"), True
	http.SetTimeouts 180000,180000,180000,180000
	' ignore ssl cert errors
	http.setOption 2, 13056
	http.send
	http.waitForResponse(180)

	Set uploadStatus = JSON.Parse(http.responseText)
	If uploadStatus.Exists("filePath") Then
		Set rec = server.CreateObject("ADODB.RecordSet")
		filepath = uploadStatus.Get("filePath")
		extension = getFileExtension(filepath)
		If filepath <> "" Then
			t = Split(filepath,"\")
			filename = t(UBound(t))
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			if fs.FileExists(filepath) Then
				Set adoStream = CreateObject("ADODB.Stream")
				adoStream.Open()
				If extension = "xls" Or extension = "xlsx" then
					response.contenttype="application/vnd.ms-excel"
					response.addheader "contenttype","application/vnd.ms-excel"
				ElseIf extension = "csv" Then
					response.contenttype="text/csv"
					response.addheader "contenttype","text/csv"
				Else
					response.contenttype="text/plain"
					response.addheader "contenttype","text/plain"
				End If
				
				response.addheader "Content-Disposition", "attachment; " & "filename=""" & filename &""""

				adoStream.Type = 1  
				adoStream.LoadFromFile(filepath)  

				Set fs=Server.CreateObject("Scripting.FileSystemObject")
				Set f=fs.GetFile(filepath)
				dataSize = f.size
				Set f = Nothing
				Set fs = Nothing
				Response.AddHeader "Content-Length", dataSize
				
				dataPosition = 0
				chunkSize = 1024*1024*4
				Do While dataPosition < dataSize
					Response.BinaryWrite adoStream.Read(chunkSize)
					Response.flush
					dataPosition = dataPosition + chunkSize
				Loop

				adoStream.Close: Set adoStream = Nothing  
				Response.End  
			Else
				response.write("file not found")
				response.end
			End if
		End if
	End If
End If
rec.close
Set rec = Nothing
%>