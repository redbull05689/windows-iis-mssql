<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%'upload an attachment to an experiment%>
<%Server.ScriptTimeout=108000%>
<%
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Expires = -1
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/escape_and_filter/functions/fnc_decodeBase64.asp"-->
<!-- #include file="../_inclds/common/functions/sub_writeBytes.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
inboxPath = getCompanySpecificSingleAppConfigSetting("dispatchInboxDirectory", session("companyId"))
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
	
	if fs.FolderExists(path)<>true then
		on error resume next
		set f=fs.CreateFolder(path)
		If Err.number <> 0 Then
			Err.Clear
		End If
		On Error goto 0
	end if
	
	set fs=nothing
End function
%>

<%
Call getconnected



'get querystring vars
experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")
attachmentId = request.querystring("attachmentId")
pre = request.querystring("pre")
'if experiment type and id are not present in the querystring, look in the form.
If experimentType = "" And experimentId = "" Then
	experimentType = request.form("experimentType")
	experimentId = request.form("experimentId")
End if

'can only add experiment if you own the experiment
If ownsExperiment(experimentType,experimentId,session("userId")) or checkCoAuthors(experimentId, experimentType, "uploadFile") then
	'get form name of attachment file
	formName = "file1"
	If attachmentId <> "" Then
		'if there is an attachment id (e.g. on replace attachment form) form names will be suffixed with the attachment id
		If pre = "" Then
			formName = formName & "_" & attachmentId
		Else
			formName = formName & "_p" & attachmentId	
		End if
	End if

	'get path names and database tables
	prefix = GetPrefix(experimentType)
	typeFolder = GetAbbreviation(experimentType)
	experimentHistoryTable = GetFullName(prefix, "experiments_history", true)
	attachmentsTable = GetFullName(prefix, "attachments", true)
	attachmentsPreSaveTable = GetFullName(prefix, "attachments_preSave", true)
	
	'get new revision number
	Set rs = Server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM "&experimentHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
	rs.open strQuery,conn,3,3
	revisionNumber = rs.recordCount + 1

	'if the file is not being uploaded by base 64 string initialize persits with progress bar
	If request.querystring("base64") = "" then
		Set Upload = Server.CreateObject("Persits.Upload")
		' This is needed to enable the progress indicator
		Upload.ProgressID = Request.QueryString("PID")
		Upload.OverwriteFiles = False
	End If
	
	'generate paths make upload tree if it does not exist
	path = uploadRootRoot & "\"&session("companyId")
	makeDirIfNotExists(path)
	path = uploadRoot & "\" & session("userId")&"\"
	makeDirIfNotExists(path)

	path = path & experimentId & "\"
	makeDirIfNotExists(path)

	path = path & revisionNumber & "\"
	makeDirIfNotExists(path)

	path = path & typeFolder & "\"
	makeDirIfNotExists(path)

	If request.querystring("base64") = "" Then
		'if we are uploading a real file, upload it
		Upload.Save(path&actualFileName)

		fileLabel = upload.Form("fileName")
		description = upload.Form("fileDescription")
		sortOrder = upload.Form("sortOrder")
		folderId = upload.Form("folderId")
		 
		 
		 	
		if request.querystring("FolUp") = 1 then
			
			filepath = request.querystring("filename")

		else 
			For Each File in Upload.Files
				filepath = File.Path
			Next
		End if

		If filepath <> "" then
			'filename that was saved
			filename = Split(filepath,"\")(UBound(Split(filepath,"\")))
		End If
	Else
		'save file if uploading base 64 string (e.g. via sketch or CK editor)

		'if upload is from CK get the Id of the CK editor
		If request.Form("base64FileCKEditorId") <> "" Then
			fromCK = True
			ckId = request.Form("base64FileCKEditorId")
		End If
		
		
		


		'generate filename and path
		fileLabel = request.Form("fileName")
		theCleanFileName = cleanFileName(fileLabel)
		description = request.Form("fileDescription")
		sortOrder = request.Form("sortOrder")

		If theCleanFileName = "" Then
			theCleanFileName = "Untitled"
		End If
		theCleanFileName = theCleanFileName &"."&request.Form("base64FileExtension")
		filepath = path&theCleanFileName
		filename = theCleanFileName

		'decode base64 string and save as binary
		base64Decoded = decodeBase64(request.Form("base64File"))
		writeBytes filepath, base64Decoded
	End if

	
			

	fileExtension = Replace(getFileExtension(filename),".","")
	If fileExtension <> "exe" And fileExtension <> "bat" And fileExtension <> "cmd" And fileExtension <> "msi" And fileExtension <> "pif" Then
		'blacklist exe,bat,cmd,msi, and pif files

		'create a unique filename.  loop until you have selected one that does not already exist
		exists = True
		Do While exists
			actualFileName = CreateGUID() & "." & fileExtension
			Set fRec1 = server.CreateObject("ADODB.Recordset")
			strQuery1 = "SELECT id FROM allExperimentFiles_history WHERE actualFileName="&SQLClean(actualFileName,"T","S")
			fRec1.open strQuery1,conn,3,3
			If fRec1.eof Then
				exists = False
			End if
			fRec1.close
			Set fRec1 = Nothing
		Loop
		
		'change filename to random UUID name
		set fso = CreateObject("Scripting.FileSystemObject") 
		set file = fso.GetFile(path&filename) 
		file.name = actualFileName 
		set file = nothing 
		set fso = nothing 

		'get file sizes
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		set f=fs.GetFile(path&actualFileName)
		totalBytes = CStr(f.size)
		fileSize = bytesToK(f.Size)
		set f=nothing
		set fs=Nothing

		'if the file is an office doc copy it to the inbox so that Python can make a PDF preview of it
		'If isOfficeDoc(actualFileName) Then
		'	dim fs
		'	set fs=Server.CreateObject("Scripting.FileSystemObject")
		'	fs.CopyFile path&"\"&actualFileName,inboxPath&"\"&whichServer&"_"&getCompanyIdByUser(session("userId"))&"_"&session("userId")&"_"&experimentId&"_"&revisionNumber&"_"&typeFolder&"_"&actualFileName
		'	set fs=nothing
		'End if

		'Add a record in the pdfProdQueue table so that Python will generate a preview.
		Call getconnectedadm		
		strQuery = "INSERT INTO [pdfProcQueue] (serverName, companyId, userId, experimentId, revisionNumber, fileType, experimentType, filePath, fileName, dateCreated, status) VALUES (" & SQLClean(whichServer,"T","S") & ", " & SQLClean(getCompanyIdByUser(session("userId")),"N","S") & ", " &SQLClean(session("userId"),"N","S") & ", " & SQLClean(experimentId,"N","S") & ", " & SQLClean(revisionNumber,"N","S") & ", " & SQLClean(fileExtension, "T", "S") &  ", " & SQLClean(typeFolder,"T","S")&  ", " & SQLClean(path,"T","S") &  ", " &  SQLClean(Replace(actualFileName,getFileExtension(actualFileName),""),"T","S") & ", SYSDATETIME(), 'NEW')" 
		connAdm.execute(strQuery)

		'we want to generated a preview image for chemistry file attachments
		If isChemicalFile(actualFileName) Then
			'get experiment type file path name
			experimentTypeName = GetAbbreviation(experimentType)
						
			'open file
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			Set TextStream = fs.OpenTextFile(path&"\"&actualFileName, 1, False, -2)
			cdxData = TextStream.ReadAll
			TextStream.close
			Set TextStream = nothing
			
			firstThree = Left(cdxData,3)
			
			'save file to inbox for preview generation
			If Left(cdxData,3) = "VjC" Or (asc(Mid(firstThree,1,1)) = 1 And asc(Mid(firstThree,2,1)) = 3 And asc(Mid(firstThree,3,1))=0) then
				'save binary file
				fn = "c:\inbox\"&whichServer&"_"&getCompanyIdByUser(session("userId"))&"_"&session("userId")&"_"&experimentId&"_"&revisionNumber&"_"&experimentTypeName&"_"&actualFileName&".atrxn"
				a = SaveBinaryData(fn,ReadBinaryFile(path&"\"&actualFileName))
			Else
				'save text file
				Set tfile=fs.CreateTextFile("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(session("userId"))&"_"&session("userId")&"_"&experimentId&"_"&revisionNumber&"_"&experimentTypeName&"_"&actualFileName&".atrxn")
				tfile.WriteLine(Replace(Replace(cdxData,"HeightPages=""1""","HeightPages=""5"""),"WidthPages=""1""","WidthPages=""5"""))
				tfile.close
				set tfile=nothing
				set fs=nothing	
			End if

		End if


		If request.querystring("jqfu")="1" Then
			theFilename = request.querystring("filename")
			theRelativePath = request.querystring("path")
		Else
			theFilename = filename
		End if

		
		'if file was uploaded via persits get the filename and description from the form
		'otherwise we already have it from the querystring
		If request.querystring("base64") = "" then
			If upload.Form("fileLabel") <> "" Or upload.Form("description") <> "" Then
				fileLabel = upload.Form("fileLabel")
				description = upload.Form("description")
				sortOrder = upload.Form("sortOrder")
				theRelativePath = upload.Form("path")
			End If
		End If

		'if we were not given a sort order, set it big so the attachment is at the bottom.
		if sortOrder = None then
			' sortOrder = 2147483647 'just set it to max int and be done with it.
			sortOrderQuery = "SELECT max(sortOrder) as newMax FROM experimentContentSequence WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S") & "and experimentFieldName is not null"
			Set fRec1 = server.CreateObject("ADODB.Recordset")
			fRec1.open sortOrderQuery,conn,3,3
			If not fRec1.eof Then
				sortOrder = fRec1("newMax")
			End if
			fRec1.close
			Set fRec1 = Nothing
		end if

		'make preview text for long filenames
		If fileLabel = "" then
			fileLabel = maxChars(theFileName,40)
			If Len(theFileName) >40 Then
				fileLabel = fileLabel & "..."
			End If
		End If
		
		'insert into folders table when there is a given relative path if its not exist in the table
		If theRelativePath <> "" Then
			s = Split(theRelativePath, "/")
			For i=0 to ubound(s)-1
				fullPath = ""
				For j=0 to i
					fullPath =  fullPath&s(j)&"/"
				Next

				' This will insert if the record doesn't exist, if it does, it does nothing
				'insert into MyTable (Field1, Field2, Field3)
				'select @Var1, @Var2, @Var3
				'where not exists (select 1 from MyTable where Field1 = @Var1 and Field2 = @Var2 and Field3 = @Var3)
				strFolderQuery = "INSERT into attachmentFolders (folderName,experimentType,experimentId,fullPath,parentFolderId) " &_
					"select " &_
					SQLClean(s(i),"T","S") & "," &_
					SQLClean(experimentType,"N","S") & "," &_
					SQLClean(experimentId,"N","S") & "," &_
					SQLClean(fullPath,"T","S") & "," &_
					SQLClean(NULL,"N","S")&" " &_
					"WHERE NOT EXISTS (SELECT 1 FROM attachmentFolders WHERE folderName="& SQLClean(s(i),"T","S") &" AND fullPath="& SQLClean(fullPath,"T","S") &" AND experimentType="& SQLClean(experimentType,"N","S") & " AND experimentId="& SQLClean(experimentId,"N","S") & ")"
				connAdm.execute(strFolderQuery)

				' Grab the id of the record we (might have) just inserted. (I should be able to get this ID from the insert, but ASP was giving me a hard time) 
				Set rRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT id FROM attachmentFolders WHERE folderName="& SQLClean(s(i),"T","S") &" AND fullPath="& SQLClean(fullPath,"T","S") &" AND experimentType="& SQLClean(experimentType,"N","S") & " AND experimentId="& SQLClean(experimentId,"N","S")
				rRec.open strQuery,connAdm,3,3
				folderId = CStr(rRec("id"))

			Next
			
		End If
		
		'insert into attachments presave table
		strQuery = "INSERT into "&attachmentsPreSaveTable&"(userId,experimentId,name,filename,actualFileName,description,revisionNumber,filesize,sortOrder,folderId,totalBytes,dateUploaded,dateUploadedServer) output inserted.id as newId values(" &_
					SQLClean(session("userId"),"N","S") & "," &_
					SQLClean(experimentId,"N","S") & "," &_
					SQLClean(fileLabel,"T","S") & "," &_
					SQLClean(theFilename,"T","S") & "," &_
					SQLClean(actualFileName,"T","S") & "," &_
					SQLClean(description,"T","S") & "," &_
					SQLClean(revisionNumber,"N","S")& "," &_
					SQLClean(fileSize,"T","S")&","&_
					SQLClean(sortOrder,"N","S")&","&_
					SQLClean(folderId,"N","S")&","&_
					SQLClean(totalBytes,"N","S")&",GETUTCDATE(),GETDATE())"
		Set rs = connAdm.execute(strQuery)
		newAttachmentId = CStr(rs("newId"))
		If attachmentId <> "" Then
			'if we are replacing an attachment add the attachment that we are replacing to the hide table
			strQuery = "INSERT INTO attachmentsToHide(experimentType,experimentId,attachmentId) values(" &_
						SQLClean(experimentType,"N","S") & "," &_
						SQLClean(experimentId,"N","S") & "," &_
   						SQLClean(attachmentId,"N","S") & ")"
			connAdm.execute(strQuery)
		End if

	End If
	'send attachment added notifications
	%><!-- #include file="../_inclds/experiments/common/asp/attachmentAddedNotifications.asp"--><%	
	If session("hasMUFExperiment") Then
		'if this company has collaboration experiment enabled then notifications need to be sent out to everyone that say an attachment was added or changed to the experiment
		'since the attachment could have been added by anyone it also needs to say who added it.

		'make experiment link
		Set recN = server.CreateObject("ADODB.RecordSet")

		requestTypeId = 0

		if (cstr(experimentType) = "5") then
			Set reqTypeRec = server.CreateObject("ADODB.RecordSet")
			reqQuery = "SELECT requestTypeId FROM custExperiments WHERE id=" & SQLClean(experimentId, "N", "S")
			reqTypeRec.open reqQuery, connAdm, 3, 3
			if not reqTypeRec.eof then
				requestTypeId = reqTypeRec("requestTypeId")
			end if
			reqTypeRec.close
			set reqTypeRec = Nothing
		end if
		
		prefix = getPrefix(cstr(experimentType))
		table = getFullName(prefix, "experiments", true)

		if cstr(experimentType) = "5" then
			table = "custExperiments"
		end if

		expPage = getExperimentPage(prefix)

		strQuery = "SELECT name FROM " & table & " WHERE id=" & SQLClean(experimentId,"N","S")
		recN.open strQuery,conn,adOpenStatic,adLockReadOnly
		theLink = "<a href="""&mainAppPath&"/"& expPage &"?id="&Trim(experimentId)&""">"&recN("name")&"</a>"
		recN.close
		Set recN = Nothing
		
		If fileLabel = "" Then
			fileLabel = filename
		End If

		If attachmentId = "" Then
			'attachment added notification

			'generate notification
			title = "Attachment Added"
			message = "User "&session("firstName")&" "&session("lastName")&" has added a file """&fileLabel&""" to "&theLink

			'send to all users that can view the experiment
			a = usersWhoCanViewExperiment(experimentType,experimentId)
			users = Split(a,",")
			For q = 0 To ubound(users)
				If CStr(users(q)) <> CStr(session("userId")) then
					a = sendNotification(users(q),title,message,13)
				End if
			Next
		Else
			'attachment changed notification

			'generate notification
			title = "Attachment Changed"
			message = "User "&session("firstName")&" "&session("lastName")&" has changed file """&fileLabel&""" on "&theLink

			'send to all users who can view the experiments
			a = usersWhoCanViewExperiment(experimentType,experimentId)
			users = Split(a,",")
			For q = 0 To ubound(users)
				If CStr(users(q)) <> CStr(session("userId")) then
					a = sendNotification(users(q),title,message,14)
				End if
			Next
		End if
	End if
End if
%>
<%
'return status
'if the source was CK add URL to access the uploaded image
%>
<%If request.querystring("jqfu")<>"1" then%>
<div id="resultsDiv">success<%If fromCK then%>|<%=ckId%>|<%=mainAppPath%>/experiments/ajax/load/getImage.asp?id=<%=newAttachmentId%>&experimentType=<%=experimentType%>&pre=true<%End if%></div>
<%else%>
{"files": [
  {
    "name": "<%=fileName%>",
    "size": <%=totalBytes%>,
    "url": "javascript:void(0);"
  }
]}
<%End if%>
<%
'log attachment uploaded with correct translation of experiment type
Select Case experimentType
	Case "1"
		theType = "2"
	Case "2"
		theType = "3"
	Case "3"
		theType = "4"
	Case "4"
		theType = "6"
	Case "5"
		theType = "6"
End select
a = logAction(theType,experimentId,filename,24)

Function CreateGUID
  Dim TypeLib
  Set TypeLib = CreateObject("Scriptlet.TypeLib")
  CreateGUID = Mid(TypeLib.Guid, 2, 36)
End Function
%>