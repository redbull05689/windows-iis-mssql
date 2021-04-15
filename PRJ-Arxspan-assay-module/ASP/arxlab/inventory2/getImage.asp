<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%
fileId = request.querystring("fileId")
collection = request.querystring("collection")
connectionId = request.querystring("connectionId")

s = connectionId&"!#!"&fileId&"!#!"&collection
Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.open "POST",wsBase&"/getFileInfo/",True
http.setOption 2, 13056
http.setRequestHeader "Content-Type","text/plain"
http.setRequestHeader "Content-Length",Len(s)
http.send s
http.waitForResponse(60)
r = http.responseText
If r <> "" Then
	a = Split(r,"!#!")
	filename = a(0)
	fileExtension = a(1)
	displayFilename = a(2)
	uploadPath = a(3)
	filepath = uploadPath & filename
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	if fs.FileExists(filepath) Then
		response.ContentType="image/JPEG"
		Set adoStream = CreateObject("ADODB.Stream")  
		adoStream.Open()  
			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)  
			Set fs=Server.CreateObject("Scripting.FileSystemObject")
			Set f=fs.GetFile(filepath)
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
	End if
End if
%>