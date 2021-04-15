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

Upload.Save(uploadPath&"/importFiles")

For Each File in Upload.Files
	filepath = File.Path
Next

If filepath <> "" then
	'filename that was saved
	filename = Split(filepath,"\")(UBound(Split(filepath,"\")))
End If

fileExtension = Replace(getFileExtension(filename),".","")
If fileExtension = "sdf" then
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
			window.parent.document.getElementById('<%=fieldId%>_frame').src="upload_file_frame.asp?formId=<%=formId%>&fieldId=<%=fieldId%>&fileId=<%=fileId%>&collection=<%=collection%>&connectionId=<%=request.querystring("connectionId")%>"
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
%>