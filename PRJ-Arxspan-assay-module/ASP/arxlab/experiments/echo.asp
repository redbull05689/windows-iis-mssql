<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/database/functions/fnc_callStoredProcedure.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_convertToCDXML.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_applyChemDrawStyles.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
'this is the uploader for chemistry data from a chemistry experiment

'send cdxml to normalize service to add <steps>  if needed
Function SubmitCDXMLForStepsUpdate(cdxml)

	Dim xmlhttp  
	Dim xmlDoc 

	CDXConvertUrl = getCompanySpecificSingleAppConfigSetting("cdxmlServiceEndpointUrl", session("companyId"))

	Set xmlDoc = Server.CreateObject("Msxml2.DOMDocument.6.0")
	xmlDoc.Async = False
	xmlDoc.ValidateOnParse = False
	xmlLoadSuccess = xmlDoc.LoadXML(cdxml)

	Set xmlhttp = CreateObject("MSXML2.ServerXMLHTTP")
	xmlhttp.setOption 2, 13056
	xmlhttp.Open "POST",CDXConvertUrl & "/cdxmlnormalize",False

	xmlhttp.setRequestHeader "Authorization", session("jwtToken")
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.setRequestHeader "Accept", "text/xml"
	xmlhttp.send "{""appName"":""ELN"", ""cdxml"":"""&Replace(cdxml,"""","\""")&"""}"
	xmlhttp.waitForResponse(60)

	Set inputMolData = JSON.Parse(xmlhttp.responseText)
	
	rez = ""
	
	If IsObject(inputMolData) Then
		 rez = inputMolData.Get("data")	
	End If
	
'	return updated cdxml if available, and initial cdxml  
	If rez <> "" Then
		SubmitCDXMLForStepsUpdate =  rez
	else
		SubmitCDXMLForStepsUpdate =  cdxml
	End If
	
 
End Function

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

Function Base64Encode(bText)
    Dim oXML, oNode

    Set oXML = CreateObject("Msxml2.DOMDocument.3.0")
    Set oNode = oXML.CreateElement("base64")
    oNode.dataType = "bin.base64"
    oNode.nodeTypedValue =bText
    Base64Encode = oNode.text
    Set oNode = Nothing
    Set oXML = Nothing
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

keepGoing = True
serialsQuery = "select id from serialsAck where serial="&SQLClean(request.querystring("serial"),"T","S")
Set serialsRec = server.CreateObject("ADODB.RecordSet")
serialsRec.open serialsQuery,conn,3,3
keepGoing = serialsRec.eof
serialsRec.close
Set serialsRec = Nothing

If keepGoing Then
	'if we have already received a request for this do not process it
	strQuery = "begin tran;" &_
			   "INSERT into experimentLoading(experimentId,dateSubmitted,cleared) values("&SQLClean(request.querystring("experimentId"),"N","S")&",GETDATE(),0);" &_
			   "if not exists (select id from serialsAck with (updlock, rowlock, holdlock) where serial="&SQLClean(request.querystring("serial"),"T","S")&")"&_
					"insert into serialsAck (serial) values("&SQLClean(request.querystring("serial"),"T","S")&");"&_
			   "else " &_
					serialsQuery&";"&_
			   "commit;"
	Call getconnectedadmTrans
	connAdmTrans.beginTrans
	Set rec = connAdmTrans.execute(strQuery)
	If rec.state <> 0 Then
		If Not rec.eof Then
			keepGoing = False
			connAdmTrans.rollbackTrans
		End If
		rec.close
	End if
	Set rec = Nothing
End If

If Not keepGoing Then
	response.write("<div id='errorDiv'>"&errString&"</div>")
	response.write("<div id='filenameDiv'>something</div>")
	response.end()
End If

	'log chemistry uploaded
	a = logAction(2,experimentId,"",26)

	errFlag = true
	experimentId = request.querystring("experimentId")
	experimentType = request.querystring("experimentType")
	fromChemDraw = request.querystring("fromChemDraw")

	'this can probably be deleted.  There is not reason to have any other type of experiment use this uploader
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "experiments", true)
	strQuery = "SELECT userId, id FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S")

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
		'fromChemdraw does not appear to be used anymore.
		If fromChemDraw <> "yes" Then
			If logEventsToFile Then
				logfile.WriteLine(Now & ": fromChemDraw is NOT yes")
			End If
			
			'upload/save file
			Set Upload = Server.CreateObject("Persits.Upload")
			Upload.Save(path)
			For Each File in Upload.Files
				filepath = File.Path
			Next

			On Error Resume Next

			originCDXML = convertToCDXMLFromFilePath(filePath)

			' Apply stylesheet
			templateName = getCompanySpecificSingleAppConfigSetting("blankCdxName", session("companyId"))
			xmlStr = applyStyles(originCDXML, templateName, "")
			
			'Check for error
			if InStr(1, xmlStr, "<error>", 1) = 1 then
				errFlag = True
				errString = xmlStr ' TODO rip out the XML
			end if

			'detect multi step reaction in chemdraw
			Set re = new RegExp
			re.IgnoreCase = true
			re.Global = true
			re.Pattern = "<step[^A-Za-z]"
			re.multiline = true
			Set Matches = re.execute(xmlStr)
			stepCount = Matches.count
			set re = Nothing
			

			On Error goto 0
			If stepCount > 1 Then
				'if there are multiple steps in the cdxml data, throw error
				errFlag = True
				errString = "Multi-step reactions are not supported."
			End If

		Else
			If logEventsToFile Then
				logfile.WriteLine(Now & ": fromChemDraw is yes")
			End If

			'save sent chemdata string as file
			filepath = path&"\chemData_"&Replace(Replace(Replace(Now(),"/","-"),":","-")," ","-")&".cdxml"
			
			If logEventsToFile Then
				logfile.WriteLine(Now & ": filepath = " & filepath)
			End If

			set fs=Server.CreateObject("Scripting.FileSystemObject")
			set tfile=fs.CreateTextFile(filepath)
			tfile.WriteLine(request.Form("chemdata"))
			tfile.close
			set tfile=nothing
			set fs=nothing
		End if

		'proceed if no errors
		If errFlag then
			'remove experiment from experimentLoading so that ASP can tell when Python is done processing chemistry data
			strQuery = "DELETE FROM experimentLoading WHERE experimentId = "&SQLClean(experimentId,"N","S")
			connAdmTrans.execute(strQuery)
		else
			'open the chemistry file we saved/uploaded
			
			'response.write("xmlStr: " & xmlStr)
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
				'We will now be calculating actual cdxml  dimensions on style application
				'cdxData = Replace(Replace(cdxData,"HeightPages=""1""","HeightPages=""5"""),"WidthPages=""1""","WidthPages=""5""")
			End If


			cdxData = SubmitCDXMLForStepsUpdate(cdxData)

			'!!!!!!!!!!!!!!! CALL STORED PROCEDURE !!!!!!!!!!!!!!!!!!!!
			Set args = JSON.parse("{}")
			Call addStoredProcedureArgument(args, "experimentId", adBigInt, SQLClean(experimentId,"N","S"))
			Call addStoredProcedureArgument(args, "experimentType", adInteger, SQLClean(experimentType,"N","S"))
			Call addStoredProcedureArgument(args, "cdx", adLongVarChar, SQLClean(replace(cdxData,"\\""","\"""),"T-PROC","S"))
			Call addStoredProcedureArgument(args, "statusId", adInteger, SQLClean(2,"N","N"))

			revisionNumber = -1
			revisionNumber = callStoredProcedure("elnUpdateExperimentCdx", args, True)

			If cdxData <> "" And revisionNumber > 0 Then
				session("chemdrawWasChanged") = True
				'ELN-1331 adding a key value pair to expJson to keep track of the image status when it gets uploaded with upload reaction or live edit
				a = draftSet("forceChemistryProcessing","1")
							
				'remove all grid molecules for experiment
				Set rec = server.CreateObject("ADODB.RecordSet")
				'get the draft
				strQuery = "SELECT experimentJSON FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean("1","N","S")
				rec.open strQuery,conn,3,3
				If Not rec.eof Then
					'load draft json
					Set experimentJSON = JSON.parse(rec("experimentJSON"))
					Set regExp = New RegExp
					regExp.Global = True
					regExp.IgnoreCase = True
					'delete any key starting with a molecule tab prefix r(x)_ , p(x)_ , etc...
					For each key In experimentJSON.keys()
						  regExp.Pattern = "^(p|r|rg|s)[0-9]{1,2}_"
						  set match = regExp.Execute(key)
						  response.write(key&" "&match.count&"<br/>")
						  If match.count > 0 Then
							experimentJSON.purge(key)
						  End If
					Next
					'ELN-1331 adding a key value pair to expJson to keep track of the image status when it gets uploaded with upload reaction or live edit
					experimentJSON.Set "forceChemistryProcessing", "1"
					experimentJSON.Set "thisRevisionNumber", revisionNumber
					Set regExp = Nothing
					'save new JSON with molecules removed to experiment draft
					strQuery = "UPDATE experimentDrafts SET experimentJSON="&SQLClean(JSON.stringify(experimentJSON),"T","S")&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType=1"
					connAdmTrans.execute(strQuery)
				End if
				rec.close
				Set rec = Nothing
				connAdmTrans.commitTrans

				'return data
				response.write("<div id='fileExtensionDiv'>"&Replace(getFileExtension(filepath),".","")&"</div>")
				response.write("<div id='experimentTypeDiv'>"&experimentType&"</div>")
				response.write("<div id='experimentIdDiv'>"&experimentId&"</div>")

				response.write("<div id='filenameDiv'>")
				fs = Split(filepath,"\")
				If UBound(fs) > 0 Then
					filename = fs(UBound(fs))
					response.write(filename)
				End If
				response.write("</div>")

				firstThree = Left(cdxData,3)
				'attempt to detect a binary file (esp cdx) and save as binary for a binary file and as text otherwise
				If Left(cdxData,3) = "VjC" Or (asc(Mid(firstThree,1,1)) = 1 And asc(Mid(firstThree,2,1)) = 3 And asc(Mid(firstThree,3,1))=0) then
					fn = "c:\inbox\"&whichServer&"_"&getCompanyIdByUser(session("userId"))&"_"&session("userId")&"_"&experimentId&"_"&revisionNumber&"_"&Abs(session("hasCompoundTracking"))&"_new_rxn.rxn"
					If logEventsToFile Then
						logfile.WriteLine(Now & ": binary fn = " & fn)
					End If
					a = SaveBinaryData(fn,ReadBinaryFile(filepath))
				else
					fn = "c:\inbox\"&whichServer&"_"&getCompanyIdByUser(session("userId"))&"_"&session("userId")&"_"&experimentId&"_"&revisionNumber&"_"&Abs(session("hasCompoundTracking"))&"_new_rxn.rxn"
					If logEventsToFile Then
						logfile.WriteLine(Now & ": text fn = " & fn)
					End If
					set fs=Server.CreateObject("Scripting.FileSystemObject")
					set tfile=fs.CreateTextFile(fn)
					tfile.WriteLine(cdxData)
					tfile.close
					set tfile=nothing
					set fs=nothing	
				End If
			End If
			
			' response.write("Left(cdxData,3): " & Left(cdxData,3))			
			' response.end()


			session("chemdrawWasChanged") = True
			'ELN-1331 adding a key value pair to expJson to keep track of the image status when it gets uploaded with upload reaction or live edit
			a = draftSet("forceChemistryProcessing","1")
						
			'remove all grid molecules for experiment
			Set rec = server.CreateObject("ADODB.RecordSet")
			'get the draft
			strQuery = "SELECT experimentJSON FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean("1","N","S")
			rec.open strQuery,connAdm,3,3
			If Not rec.eof Then
				'load draft json
				Set experimentJSON = JSON.parse(rec("experimentJSON"))
				Set regExp = New RegExp
				regExp.Global = True
				regExp.IgnoreCase = True
				'delete any key starting with a molecule tab prefix r(x)_ , p(x)_ , etc...
				For each key In experimentJSON.keys()
					  regExp.Pattern = "^(p|r|rg|s)[0-9]{1,2}_"
					  set match = regExp.Execute(key)
					  response.write(key&" "&match.count&"<br/>")
					  If match.count > 0 Then
						experimentJSON.purge(key)
					  End If
				Next
				'ELN-1331 adding a key value pair to expJson to keep track of the image status when it gets uploaded with upload reaction or live edit
				experimentJSON.Set "forceChemistryProcessing", "1"
				Set regExp = Nothing
				'save new JSON with molecules removed to experiment draft
				strQuery = "UPDATE experimentDrafts SET experimentJSON="&SQLClean(JSON.stringify(experimentJSON),"T","S")&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType=1"
				connAdm.execute(strQuery)
			End if
			'return data
			response.write("<div id='fileExtensionDiv'>"&Replace(getFileExtension(filepath),".","")&"</div>")
			response.write("<div id='experimentTypeDiv'>"&experimentType&"</div>")
			response.write("<div id='experimentIdDiv'>"&experimentId&"</div>")

			response.write("<div id='filenameDiv'>")
			fs = Split(filepath,"\")
			If UBound(fs) > 0 Then
				filename = fs(UBound(fs))
				response.write(filename)
			End If
			response.write("</div>")
		End if
	End if
	If request.querystring("reload") = "false" Then
		If logEventsToFile Then
			logfile.WriteLine(Now & ": success")
		End If
		'page will not be reloaded when success is return
		response.write("<div id='resultsDiv'>success</div>")
	Else
		If logEventsToFile Then
			logfile.WriteLine(Now & ": checking redirect")
		End If
		'this is not used anymore, but if the data was sent as a string from chemdraw, it redirected to the last page
		If request.querystring("fromChemDraw") = "yes" Then
			If logEventsToFile Then
				logfile.WriteLine(Now & ": redirect")
			End If
			response.redirect(request.servervariables("HTTP_REFERER"))
		End If
	End If
	If errFlag Then
		If logEventsToFile Then
			logfile.WriteLine(Now & ": error")
		End If
		'if error display error
		response.write("<div id='errorDiv'>"&errString&"</div>")
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