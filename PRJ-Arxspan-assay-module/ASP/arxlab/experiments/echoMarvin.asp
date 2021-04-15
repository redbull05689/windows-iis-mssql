<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/database/functions/fnc_callStoredProcedure.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_convertToCDXML.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
'this is the uploader for chemistry data from a chemistry experiment

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

logEventsToFile = False
If logEventsToFile Then
	logpath = "C:/Temp/echoLog.txt"
	set logfs=Server.CreateObject("Scripting.FileSystemObject")
	set logfile = Nothing

	With (logfs)
	  If .FileExists(logpath) Then
		Set logfile = logfs.OpenTextFile(logpath, 8)
	  Else 
		Set logfile = logfs.CreateTextFile(logpath)
	  End If 
	End With

	logfile.WriteLine(Now & ": enter echo.asp")
End If

Call disconnectadm

'log chemistry uploaded
a = logAction(2,experimentId,"",26)

errFlag = true
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")


strQuery = "SELECT userId, id FROM experiments WHERE id="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S")

If strQuery <> "" Then
	'create experiment path if it does not exist
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		errFlag = False
		path = uploadRoot & "\" & rec("userId") & "\" & rec("id")
		a = recursiveDirectoryCreate(uploadRootRoot,path)
	End if
End if

'proceed if no error
If Not errFlag Then
	xmlStr = ""
	
	'upload/save file
	Set Upload = Server.CreateObject("Persits.Upload")
	Upload.Save(path)
	For Each File in Upload.Files
		filepath = File.Path
	Next

	On Error Resume Next
	'get cdxml data
	
	xmlStr = convertToCDXMLFromFilePath(filePath)
	
	If logEventsToFile Then
		logfile.WriteLine(Now & ": got cdxml")' & xmlStr)
	End If	

	'detect multi step reaction in chemdraw
	Set re = new RegExp
	re.IgnoreCase = true
	re.Global = true
	re.Pattern = "<step[^A-Za-z]"
	re.multiline = true
	Set Matches = re.execute(xmlStr)
	stepCount = Matches.count
	set re = nothing
	cdx.quit()
	On Error goto 0
	If stepCount > 1 Then
		'if there are multiple steps in the cdxml data, throw error
		errFlag = True
		errString = "Multi-step reactions are not supported."
	End If

	'proceed if no errors
	If Not errFlag then
		'open the chemistry file we saved/uploaded
		cdxData = xmlStr
		If cdxData = "" Then
			If logEventsToFile Then
				logfile.WriteLine(Now & ": getting cdxData")
			End If
			
			On Error Resume Next
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			Set TextStream = fs.OpenTextFile(filepath, 1, False, -2)
			cdxData = TextStream.ReadAll
			TextStream.close
			Set TextStream = nothing
			On Error GoTo 0
			
			If logEventsToFile Then
				logfile.WriteLine(Now & ": cdxData = " & cdxData)
			End If
		Else
			cdxData = Replace(Replace(cdxData,"HeightPages=""1""","HeightPages=""5"""),"WidthPages=""1""","WidthPages=""5""")
		End If

		session("chemdrawWasChanged") = True
		'ELN-1331 adding a key value pair to expJson to keep track of the image status when it gets uploaded with upload reaction or live edit
		a = draftSet("forceChemistryProcessing","1")

	End if
End if
If errFlag Then
	If logEventsToFile Then
		logfile.WriteLine(Now & ": error")
	End If
	'if error display error
	Set d = JSON.parse("{}")
	d.Set "error", errString
	data = JSON.stringify(d)
	Response.Status = "500"
	response.write(data)
Else
	If logEventsToFile Then
		logfile.WriteLine(Now & ": success")
	End If
	'return data
	Set d = JSON.parse("{}")
	d.Set "fileExtension", Replace(getFileExtension(filepath),".","")
	d.Set "experimentType", experimentType
	d.Set "experimentCDX", cdxData
	d.Set "experimentId", experimentId
	d.Set "filename", Split(filepath,"\")
	data = JSON.stringify(d)
	Response.Status = "200"
	response.write(data)
End If

'log action
a = logAction(2,experimentId,"",27)
If logEventsToFile Then
	logfile.WriteLine(Now & ": exit echo.asp")
	logfile.close
	set logfile=nothing
	set logfs=nothing
End If
%>