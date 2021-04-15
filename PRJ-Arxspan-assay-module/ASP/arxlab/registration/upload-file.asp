<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled = true%>
<%Server.ScriptTimeout=108000%>
<%
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Expires = -1
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/escape_and_filter/functions/fnc_decodeBase64.asp"-->
<!-- #include file="../_inclds/common/functions/sub_writeBytes.asp"-->
<!-- #include file="../_inclds/file_system/functions/fnc_recursiveDirectoryCreate.asp"-->
<%

Function ReadBinaryFile(FileName)
  Const adTypeBinary = 1
  
  'Create Stream object
  Dim BinaryStream
  Set BinaryStream = CreateObject("ADODB.Stream")
  
  'Specify stream type - we want To get binary data.
  BinaryStream.Type = adTypeBinary
  
  'Open the stream
  BinaryStream.Open
  
  'Load the file data from disk To stream object
  BinaryStream.LoadFromFile FileName
  
  'Open the stream And get binary data from the object
  ReadBinaryFile = BinaryStream.Read
End Function

Function SaveBinaryData(FileName, ByteArray)
  Const adTypeBinary = 1
  Const adSaveCreateOverWrite = 2
  
  'Create Stream object
  Dim BinaryStream
  Set BinaryStream = CreateObject("ADODB.Stream")
  
  'Specify stream type - we want To save binary data.
  BinaryStream.Type = adTypeBinary
  
  'Open the stream And write binary data To the object
  BinaryStream.Open
  BinaryStream.Write ByteArray
  
  'Save binary data To disk
  BinaryStream.SaveToFile FileName, adSaveCreateOverWrite
End Function


Function makeDirIfNotExists(path)
	dim fs
	set fs=Server.CreateObject("Scripting.FileSystemObject")

	' 6129 - Update to make this recursive
	if fs.FolderExists(path)<>true then
		result = recursiveDirectoryCreate(uploadRootRoot,path)
	end if
	
	set fs=nothing
End function
%>

<%
Call getconnectedJchemReg

Set Upload = Server.CreateObject("Persits.Upload")
' This is needed to enable the progress indicator
Upload.ProgressID = Request.QueryString("PID")
Upload.OverwriteFiles = False

formName = request.querystring("formName")

path = uploadRootReg &"\"
makeDirIfNotExists(path)

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
	exists = True
	Do While exists
		actualFileName = getRandomString(16) & "." & fileExtension
		Set fRec1 = server.CreateObject("ADODB.Recordset")
		strQuery1 = "SELECT * FROM fileAttachments WHERE actualFileName="&SQLClean(actualFileName,"T","S")
		fRec1.open strQuery1,jchemRegConn,3,3
		If fRec1.eof Then
			exists = False
		End if
	loop
	set fso = CreateObject("Scripting.FileSystemObject") 
	set file = fso.GetFile(path&filename) 
	file.name = actualFileName 
	set file = nothing 
	set fso = nothing 

	strQuery = "INSERT INTO fileAttachments(filename,actualFilename,fileExtension,dateUploaded) output inserted.id as newId VALUES("&_
				SQLClean(filename,"T","S") & "," &_
				SQLClean(actualFilename,"T","S") & "," &_
				SQLClean(fileExtension,"T","S") & ",GETDATE()"& ")"
	Set rs = jchemRegConn.execute(strQuery)
	newId = CStr(rs("newId"))

	'set fs=Server.CreateObject("Scripting.FileSystemObject")
	'set f=fs.GetFile(path&actualFileName)
	'totalBytes = CStr(f.size)
	'fileSize = bytesToK(f.Size)
	'set f=nothing
	'set fs=Nothing

	'If isOfficeDoc(actualFileName) Then
	'	dim fs
	'	set fs=Server.CreateObject("Scripting.FileSystemObject")
	'	fs.CopyFile path&"\"&actualFileName,inboxPath&"\"&whichServer&"_"&getCompanyIdByUser(session("userId"))&"_"&session("userId")&"_"&experimentId&"_"&revisionNumber&"_"&typeFolder&"_"&actualFileName
	'	set fs=nothing
	'End if
Else
	uploadError = true
	%>
	<script type="text/javascript">
		alert("error");
	</script>
	<%
End If
Call disconnectJchemReg
%>
<script type="text/javascript">
parent.document.getElementById("<%=formName%>").value = '<%=newId%>';
parent.document.getElementById("<%=formName%>_fn").innerHTML = '<%=filename%>';
parent.document.getElementById("<%=formName%>_download_button").href = 'getSourceFile.asp?id=<%=newId%>';
parent.document.getElementById("<%=formName%>_download_button").style.display = "inline";
parent.document.getElementById("<%=formName%>_remove_img").style.display = "block";
<%If canDisplayInBrowser(filename) then%>
	parent.document.getElementById("<%=formName%>_img").src = 'getImage.asp?id=<%=newId%>';
	parent.document.getElementById("<%=formName%>_img").style.display = "block";
	parent.document.getElementById("<%=formName%>_img_hide").style.display = "block";
	parent.document.getElementById("<%=formName%>_img_show").style.display = "none";
	parent.document.getElementById("<%=formName%>_img_holder").style.display = "block";
<%else%>
	parent.document.getElementById("<%=formName%>_img_holder").style.display = "none";
<%End if%>
window.location='upload-file_frame.asp?formName=<%=formName%>'
</script>