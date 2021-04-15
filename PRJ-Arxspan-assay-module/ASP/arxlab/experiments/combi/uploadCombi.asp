<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=300%>
<%response.buffer = false%>
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include file="../../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<!-- #include file="../../_inclds/common/asp/lib_Jchem.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
chemAxonDatabaseName = getCompanySpecificSingleAppConfigSetting("chemAxonDatabaseName", session("companyId"))
combiEnumeratedMolsTable = getCompanySpecificSingleAppConfigSetting("combiEnumeratedMolsTable", session("companyId"))
combiSdMolsTable = getCompanySpecificSingleAppConfigSetting("combiSdMolsTable", session("companyId"))
Function molHasConnectionPoints(molStr)
	f = false
	lines = split(molStr,vbcrlf)
	For i = 0 To UBound(lines)
		If Mid(lines(i),32,1) = "R" Then
			f = true
		End if
	Next
	molHasConnectionPoints = f
End function

	errFlag = true
	experimentId = request.querystring("experimentId")
	strQuery = "SELECT id, userId, revisionNumber FROM experiments WHERE id="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S")

	If strQuery <> "" then
		Call getconnected
		Set rec = server.CreateObject("ADODB.RecordSet")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			errFlag = False
			path = uploadRoot & "\" & rec("userId") & "\" & rec("id") & "\" & rec("revisionNumber")
			a = recursiveDirectoryCreate(uploadRootRoot,path)
		End if
	End if

	If Not errFlag Then
		Set Upload = Server.CreateObject("Persits.Upload")
		Upload.Save(path)

		For Each File in Upload.Files
			filepath = File.Path
		Next

		set fso = CreateObject("Scripting.FileSystemObject") 
		set file = fso.GetFile(filepath)
		sdFileStr = ""
		Set TextStream = file.OpenAsTextStream(1,-2)
		Do While Not TextStream.AtEndOfStream
			Dim Line
			Line = TextStream.readline
			If Trim(line) = "$$$$" Then
				sdFileStr = sdFileStr & "> <experimentId>"&vbcrlf&experimentId&vbcrlf&vbcrlf
				sdFileStr = sdFileStr & "> <visible>"&vbcrlf&"1"&vbcrlf&vbcrlf
			End if
			sdFileStr = sdFileStr & Line & vbCRLF
		Loop
		set file = nothing 
		set fso = nothing 
		Set TextStream = nothing

		set fso = CreateObject("Scripting.FileSystemObject") 
		set file = fso.GetFile(filepath)
		fn = getRandomString(16)
		actualFileName = fn & ".sdf"
		file.name = actualFileName 
		set file = nothing 
		set fso = nothing 

		Call getconnectedJchem
		strQuery = "UPDATE "&combiSdMolsTable&" SET visible=0 WHERE experimentId="&SQLClean(experimentId,"N","S")
		jchemConn.execute(strQuery)
		strQuery = "UPDATE "&combiEnumeratedMolsTable&" SET visible=0 WHERE experimentId="&SQLClean(experimentId,"N","S")
		jchemConn.execute(strQuery)
		Call disconnectJchem

		Set fieldMappingObj = JSON.parse("{}")
		fieldMappingObj.Set "experimentId", "experimentid"
		fieldMappingObj.Set "reactantNumber", "reactantnumber"
		fieldMappingObj.Set "visible", "visible"
		
		state = "ERROR"
		monitorId = CX_importSdFile(chemAxonDatabaseName, combiSdMolsTable, sdFileStr, fieldMappingObj)
		Do While True
			cxJsonStr = CX_getMonitorStatus(monitorId)
			Set cxJsonObj = JSON.parse(cxJsonStr)
			If Not IsObject(cxJsonObj) Then
				Exit Do
			Else
				If cxJsonObj.Exists("state") Then
					state = cxJsonObj.Get("state")
					If state = "FINISHED" Or state = "FAILED" Or state = "ERROR" Then
						Exit Do
					End If
				End If
			End If
		Loop

		If state <> "FINISHED" Then
			response.write("<div id='resultsDiv'>There was an error processing your SD file.</div>")
			response.end()
		End If
		
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT DISTINCT reactantNumber FROM "&combiSdMolsTable&" WHERE visible=1 AND experimentId="&SQLClean(experimentId,"N","S")
		rec.open strQuery,jchemConn,1,1
		Do While Not rec.eof
			i = rec("reactantNumber")
			sdFileStr = ""
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT cd_id FROM "&combiSdMolsTable&" WHERE visible=1 AND experimentId="&SQLClean(experimentId,"N","S")&" AND reactantNumber="&SQLClean(i,"N","S")
			rec2.open strQuery,jchemConn,0,-1
			Do While Not rec2.eof
				structureData = CX_cdIdSearch(chemAxonDatabaseName,combiSdMolsTable,SQLClean(rec2("cd_id"),"N","S"),"")
				Set structureJson = JSON.parse(structureData)
				Set structureObj = structureJson.Get("structureData")
				molData = structureObj.Get("structure")
				molDataLines = Split(molData,vbcrlf)
				If UBound(molDataLines) = 0 Then
					molDataLines = Split(molData,vbcr)
				End If
				If UBound(molDataLines) = 0 Then
					molDataLines = Split(molData,vblf)
				End If
				If UBound(molDataLines) >= 3 Then
					If Not isInteger(Trim(Left(molDataLines(3),3))) Then
						molData = vbcrlf & molData
					End If
				End if
				sdFileStr = sdFileStr & molData &vbcrlf
				sdFileStr = sdFileStr & "$$$$"&vbcrlf
				rec2.moveNext
			Loop
			rec2.close
			Set rec2 = Nothing
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			set tfile=fs.CreateTextFile("c:\inbox-reactor\" & fn&"-"&i&".sdf")
			tfile.WriteLine(sdFileStr)
			tfile.close
			set tfile=nothing
			set fs=nothing
			rec.moveNext
		Loop
		rec.close
		strQuery = "SELECT cdx FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
		rec.open strQuery,conn,0,-1
		cdxml = Replace(rec("cdx"),"\""","""")
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		set tfile=fs.CreateTextFile("c:\inbox-reactor\" & fn&".cdxml")
		tfile.WriteLine(cdxml)
		tfile.close
		rec.close
		set rec = nothing
		set tfile=nothing
		set fs=nothing	
		
		Set D = JSON.parse("{}")
		D.Set "fileId",fn
		D.Set "experimentId",experimentId
		Set files = JSON.parse("[]")
		files.push(fn&".cdxml")
		For i = 1 To numReactants
			files.push(fn&"-"&i&".sdf")
		Next
		D.Set "files",files

		set fs=Server.CreateObject("Scripting.FileSystemObject")
		set tfile=fs.CreateTextFile("c:\inbox-reactor\" & fn&".json")
		tfile.WriteLine(JSON.stringify(D))
		tfile.close
		set tfile=nothing
		set fs=nothing	

		Do While True And counter < 10
			counter = counter + 1
			sleep = 2
			strQuery = "WAITFOR DELAY '00:00:" & right(clng(sleep),2) & "'" 
			conn.Execute strQuery,,129 
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			If fs.fileExists("c:\inbox-reactor\" & fn&"-out.sdf") Then
				counter = 10000
			End If
			Set fs = nothing
		Loop

		If counter = 10 Then
			response.write("<div id='resultsDiv'>There was an error processing the enumerated products. Please contact support@arxspan.com.</div>")
			response.end()
		End If
		
		outFileName = "c:\inbox-reactor\" & fn&"-out.sdf"
		Set fs=Server.CreateObject("Scripting.FileSystemObject")
		Set outFile = fs.GetFile(outFileName)
		fileLength = outFile.Size
		If fileLength > 1 Then
			Set f=fs.OpenTextFile(outFileName, 1)
			sdFileStr = f.ReadAll
			f.Close
			Set f=Nothing
			
			state = "ERROR"
			monitorId = CX_importSdFile(chemAxonDatabaseName, combiEnumeratedMolsTable, sdFileStr, fieldMappingObj)
			Do While True
				cxJsonStr = CX_getMonitorStatus(monitorId)
				Set cxJsonObj = JSON.parse(cxJsonStr)
				If Not IsObject(cxJsonObj) Then
					Exit Do
				Else
					If cxJsonObj.Exists("state") Then
						state = cxJsonObj.Get("state")
						If state = "FINISHED" Or state = "FAILED" Or state = "ERROR" Then
							Exit Do
						End If
					End If
				End If
			Loop

			If state <> "FINISHED" Then
				response.write("<div id='resultsDiv'>There was an error processing your SD file. " & cxJsonStr & "</div>")
				response.end()
			End If
		End If
		Set outFile = Nothing
		Set fs=Nothing
	End if
response.write("<div id='resultsDiv'>success</div>")
%>