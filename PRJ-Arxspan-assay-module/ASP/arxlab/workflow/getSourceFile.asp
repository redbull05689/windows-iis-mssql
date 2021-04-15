<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_fetchWorkflowData.asp"-->
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<%
fileId = request.querystring("fileId")

result = getRequestFileMetadata(fileId, "Workflow")
set fileJson = JSON.parse(result)

result = fileJson.get("result")

if result = "success" then
	dataStr = fileJson.get("data")
	set dataJson = JSON.parse(dataStr)

	set fs=Server.CreateObject("Scripting.FileSystemObject")

	fileLocation = "{uploadRoot}\workflow_uploads\{userId}\{actualFilename}"
	fileLocation = Replace(fileLocation, "{uploadRoot}", uploadRoot)
	fileLocation = Replace(fileLocation, "{userId}", dataJson.get("userId"))
	fileLocation = Replace(fileLocation, "{actualFilename}", dataJson.get("actualFileName"))

	' response.write fileLocation
	' response.end
	
	if fs.FileExists(fileLocation) Then

		Set adoStream = CreateObject("ADODB.Stream")
		adoStream.Open()
		If extension = "pdf" then
			response.contenttype="application/pdf"
			response.addheader "contenttype","application/pdf"
		Else
			response.contenttype="application/octet-stream"
			response.addheader "contenttype","application/octet-stream"
		End If
		If doStream Then
			response.contenttype="text/plain"
			response.addheader "contenttype","text/plain"
		End If
		
		response.addheader "Content-Disposition", "attachment; " & "filename=""" & dataJson.get("fileName") &""""

		adoStream.Type = 1  
		adoStream.LoadFromFile(fileLocation)  

		Set fs=Server.CreateObject("Scripting.FileSystemObject")
		Set f=fs.GetFile(fileLocation)
		dataSize = f.size
		Set f = nothing
		Set fs = Nothing
		
		dataPosition = 0
		chunkSize = 1024*1024*4
		do while dataPosition < dataSize
			Response.BinaryWrite adoStream.Read(chunkSize)
			Response.flush
			dataPosition = dataPosition + chunkSize
		loop

		adoStream.Close: Set adoStream = Nothing  
		Response.End  
	Else
		response.write("file does not exist")
		response.end
	End if
End if
%>