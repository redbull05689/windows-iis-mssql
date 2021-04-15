<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%
collection = request.querystring("c")
cdId = request.querystring("cdId")
size = request.querystring("size")

filepath = uploadPath & "/" & collection & "/" & cdId & "_" & size&".png"
set fs=Server.CreateObject("Scripting.FileSystemObject")
if fs.FileExists(filepath) Then
	response.ContentType="image/PNG"
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
%>