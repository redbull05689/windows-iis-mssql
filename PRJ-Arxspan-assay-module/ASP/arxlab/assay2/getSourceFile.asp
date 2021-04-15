<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
'stream file from file id
%>

<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<script language="JScript" src="/arxlab/js/json2.asp" runat="server"></script>
<%
fileId = request.querystring("fileId")

'load form of associated id
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
	'generate image path from form data
	Set r = r.Get("form")
	filename = r.Get("actualFilename")
	fileExtension = r.Get("fileExtension")
	displayFilename = r.Get("filename")
	fPath = r.Get("path")
	filepath = uploadPath&"\"&session("companyId")&"\"&fPath&"\"&filename
	extension = getFileExtension(filepath)
	t = Split(filepath,"\")
	filename = t(UBound(t))

	'stream file if it exists
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	if fs.FileExists(filepath) Then
		Set adoStream = CreateObject("ADODB.Stream")
		adoStream.Open()
		'set file type specific mime types
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

		'stream file
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