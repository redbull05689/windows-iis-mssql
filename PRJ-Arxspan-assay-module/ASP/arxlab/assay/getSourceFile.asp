<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<%
fileId = request.querystring("fileId")
collection = request.querystring("collection")
connectionId = request.querystring("connectionId")

s = connectionId&","&fileId&","&collection
Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.open "POST",wsBase&"/getFileInfo/",True
http.setRequestHeader "Content-Type","text/plain"
http.setRequestHeader "Content-Length",Len(s)
http.send s
http.waitForResponse(60)
r = http.responseText
If r <> "" Then
	a = Split(r,",")
	filename = a(0)
	fileExtension = a(1)
	displayFilename = a(2)
	uploadPath = a(3)
	filepath = uploadPath&filename
	extension = getFileExtension(filepath)
	t = Split(filepath,"\")
	filename = t(UBound(t))
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	if fs.FileExists(filepath) Then
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
		
		response.addheader "Content-Disposition", "attachment; " & "filename=""" & displayFileName &""""

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
	Else
		response.write("file does not exist")
		response.end
	End if
End if
%>