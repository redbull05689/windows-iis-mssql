<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%Server.ScriptTimeout=108000%>
<%
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Expires = -1
Response.CodePage = 65001
Response.CharSet = "UTF-8"
%>
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<!-- #include file="../_inclds/file_system/functions/fnc_recursiveDirectoryCreate.asp"-->
<!-- #include file="../_inclds/misc/functions/fnc_getRandomString.asp"-->
<%
Set Upload = Server.CreateObject("Persits.Upload")
Upload.CodePage = 65001
' This is needed to enable the progress indicator
Upload.ProgressID = Request.QueryString("PID")
Upload.OverwriteFiles = False

formId = request.querystring("formId")
fieldId = request.querystring("fieldId")

path = "assayFiles"
uPath = uploadPath&"\"&session("companyId")&"\"&path
a = recursiveDirectoryCreate(uploadPath,uPath)
If path <> "" then
	If Mid(uPath,Len(uPath),1) <> "/" And Mid(uPath,Len(uPath),1) <> "\" Then
		uPath = uPath & "/"
	End if
	Upload.Save(uPath)

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
		set file = fso.GetFile(uPath&"\"&filename) 
		file.name = actualFileName 
		set file = nothing 
		set fso = Nothing	

		'fileStr = "{" & """" & "actualFilename" & """" & ":" & """" & actualFilename & """" 
		'fileStr = fileStr & "," & """" & "fileExtension" & """" & ":" & """" & fileExtension & """"
		'fileStr = fileStr & "," & """" & "filename" & """" & ":" & """" & filename & """"
		'fileStr = fileStr & "," & """" & "path" & """" & ":" & """" & path & """"
		'fileStr = fileStr & "," & """" & "typeId" & """" & ": 99}" 

	    'response.contentType = "application/json charset=utf-8"
        'response.write(fileStr)


        %>
			<input type="text" value="" id="theFileId" style="display:none;">
			<script type="text/javascript">
				D = {'actualFilename':'<%=actualFilename%>',
					'fileExtension':'<%=fileExtension%>',
					'filename':'<%=filename%>',
					'path':'<%=path%>',
					'typeId':99
					}
				newId = window.parent.saveNew(D);
				document.getElementById("theFileId").value = newId
				window.frameElement.onchange();
				window.frameElement.src="upload_file_frame.asp?fileId="+newId;
			</script>

		<%
		
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