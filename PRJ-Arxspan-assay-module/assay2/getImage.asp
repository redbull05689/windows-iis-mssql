<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
'streams an image by file id
%>
<!-- #include file="_inclds/globals.asp"-->
<script language="JScript" src="/arxlab/js/json2.asp" runat="server"></script>
<%
fileId = request.querystring("fileId")

'load form by image id
Set D = JSON.parse("{}")
D.Set "id",fileId
D.Set "connectionId", session("servicesConnectionId")
Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.setOption 2, 13056
http.open "POST",wsBase&"/loadForm/",True
http.setRequestHeader "Content-Type","text/plain"
http.setRequestHeader "Content-Length",Len(JSON.stringify(D))
http.send JSON.stringify(D)
	http.waitForResponse(60)
Set r = JSON.parse(http.responseText)

If r <> "" Then
	'generate image path with form data
	Set r = r.Get("form")
	filename = r.Get("actualFilename")
	fileExtension = r.Get("fileExtension")
	displayFilename = r.Get("filename")
	uPath = r.Get("path")
	filepath = uploadPath & "\" & session("companyId")&"\"&uPath&"\"&filename

	'stream image if it exists
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