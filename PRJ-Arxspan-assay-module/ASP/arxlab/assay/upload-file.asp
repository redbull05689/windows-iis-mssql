<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%Server.ScriptTimeout=108000%>
<%
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Expires = -1
%>
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<!-- #include file="../_inclds/misc/functions/fnc_getRandomString.asp"-->
<%
Set Upload = Server.CreateObject("Persits.Upload")
' This is needed to enable the progress indicator
Upload.ProgressID = Request.QueryString("PID")
Upload.OverwriteFiles = False

formId = request.querystring("formId")
fieldId = request.querystring("fieldId")

s = formId&","&fieldId
Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.setOption 2, 13056
http.open "POST",wsBase&"/uploadInit/",True
http.setRequestHeader "Content-Type","text/plain"
http.setRequestHeader "Content-Length",Len(s)
http.send s
http.waitForResponse(60)
path = http.responseText
If path <> "" then
	If Mid(path,Len(path),1) <> "/" And Mid(path,Len(path),1) <> "\" Then
		path = path & "/"
	End if
	Upload.Save(path)

	For Each File in Upload.Files
		filepath = File.Path
	Next

	If filepath <> "" then
		'filename that was saved
		filename = Split(filepath,"\")(UBound(Split(filepath,"\")))
	End If

	fileExtension = Replace(getFileExtension(filename),".","")
	If fileExtension <> "exe" And fileExtension <> "bat" And fileExtension <> "cmd" And fileExtension <> "msi" And fileExtension <> "pif" then
		actualFileName = getRandomString(16) & "." & fileExtension
		set fso = CreateObject("Scripting.FileSystemObject") 
		set file = fso.GetFile(path&filename) 
		file.name = actualFileName 
		set file = nothing 
		set fso = Nothing

		s = formId&","&fieldId&","&actualFileName&","&fileExtension&","&filename&","&path
		Set http = CreateObject("MSXML2.ServerXMLHTTP")
		http.open "POST",wsBase&"/uploadFinish/",True
		http.setRequestHeader "Content-Type","text/plain"
		http.setRequestHeader "Content-Length",Len(s)
		http.setOption 2, 13056
		http.send s
		http.waitForResponse(60)
		r = http.responseText
		If r <> "" Then
			a = Split(r,",")
			fileId = a(0)
			collection = a(1)
			%>
			<script type="text/javascript">
				window.parent.updateValue('<%=formId%>','<%=fieldId%>','<%=fileId%>')
				window.parent.document.getElementById('<%=fieldId%>_frame').src="upload_file_frame.asp?formId=<%=formId%>&fieldId=<%=fieldId%>&fileId=<%=fileId%>&collection=<%=collection%>&connectionId=<%=session("servicesConnectionId")%>"
			</script>
			<%
		End if
	Else
		uploadError = true
		%>
		<script type="text/javascript">
			alert("error");
		</script>
		<%
	End If
End if
%>