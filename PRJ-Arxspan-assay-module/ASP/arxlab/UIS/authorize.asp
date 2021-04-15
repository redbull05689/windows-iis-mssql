<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%response.buffer = false%>
<%Server.ScriptTimeout = 285%>
<!-- #include file="../_inclds/globals.asp" -->
<!-- #include file="../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_requestWitness.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
inboxPath = getCompanySpecificSingleAppConfigSetting("dispatchInboxDirectory", session("companyId"))

pdfFooterOptions = getCompanySpecificSingleAppConfigSetting("pdfFooterOptions", session("companyId"))
pdfHeaderOptions = getCompanySpecificSingleAppConfigSetting("pdfHeaderOptions", session("companyId"))
pdfFooterOptionsRight = getCompanySpecificSingleAppConfigSetting("pdfFooterOptionsRight", session("companyId"))
function getOtherPDFInfo(experimentId,experimentType,witnessName)
	prefix = GetPrefix(experimentType)
	tableName = GetExperimentView(prefix)
	Set expRec = server.CreateObject("ADODB.recordSet")
	strQuery = "SELECT * FROM "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")
	expRec.open strQuery,connAdm,0,-1
	str = "{"
	str = str & "'experimentName' : '" & pEscape(expRec("name")) & "'"
	If pdfHeaderOptions <> "" Then
		str = str & ",'headerOptions':"&pdfHeaderOptions
	Else
		str = str & ",'headerOptions':[]"
	End if
	If pdfFooterOptions <> "" Then
		str = str & ",'footerOptions':"&pdfFooterOptions
	Else
		str = str & ",'footerOptions':[]"
	End If
	If pdfFooterOptionsRight <> "" Then
		str = str & ",'footerOptionsRight':"&pdfFooterOptionsRight
	Else
		str = str & ",'footerOptionsRight':[]"
	End if
	str = str & ",'signerName':'"&pEscape(expRec("firstName")&" "&expRec("lastName"))&"'"
	str = str & ",'ownerName':'"&pEscape(expRec("firstName")&" "&expRec("lastName"))&"'"
	str = str & ",'witnessName':''"
	str = str & ",'companyId':"&session("companyId")
	str = str & ",'experimentStatus':'"&pEscape(expRec("status"))&"'}"
	expRec.close
	Set expRec = nothing
	getOtherPDFInfo = str
end function

function getXMLTag(tagName,inString)
	instring = Replace(instring,vbcrlf,"$$$%%%^%^$%^$%^$%$%^45")
	instring = Replace(instring,vbcr,"$$$%%%^%^$%^$%^$%$%^45")
	instring = Replace(instring,vblf,"$$$%%%^%^$%^$%^$%$%^45")
	Set re = new RegExp
	re.IgnoreCase = true
	re.Global = true

	re.Pattern = "<"&tagName&">(.*?)</"&tagName&">"
	re.multiline = true
	Set Matches = re.execute(inString)
	If Matches.count > 0 Then
		m = Matches.Item(0).subMatches(0)
		m = Replace(m,"$$$%%%^%^$%^$%^$%$%^45",vbcrlf)
		getXMLTag = m
	else
		getXMLTag = "error"
	End If
	set re = nothing
end function

function decodeBase64(base64)
  dim DM, EL
  Set DM = CreateObject("Microsoft.XMLDOM")
  ' Create temporary node with Base64 data type
  Set EL = DM.createElement("tmp")
  EL.DataType = "bin.base64"
  ' Set encoded String, get bytes
  EL.Text = base64
  decodeBase64 = EL.NodeTypedValue
end function
 
Sub writeBytes(file, bytes)
  Dim binaryStream
  Set binaryStream = CreateObject("ADODB.Stream")
  binaryStream.Type = 1
  'Open the stream and write binary data
  binaryStream.Open
  binaryStream.Write bytes
  'Save binary data to disk
  binaryStream.SaveToFile file, 2
End Sub

If session("companyId") = "1" then
	For Each sItem In Request.Form
	Response.Write(sItem)
	Response.Write(" - [" & Request.Form(sItem) & "]" & strLineBreak)
	Next
End if

If request.Form("code") = "" Then
	state = request.Form("state")
	'response.write("STATE: "&state)
	experimentType = Split(state,"_")(1)
	experimentId = Split(state,"_")(2)
	revisionNumber = Split(state,"_")(3)
	userId = Split(state,"_")(4)
	witness = Split(state,"_")(5)
	addStr = mainAppPath&"/signed.asp?id="&experimentId&"&experimentType="&experimentType&"&revisionNumber="&revisionNumber&"&credError=1"
	If witness = "0" Then
		addStr = addStr & "&safeVersion=False&fromSign=true"
	End if
	%>
	<script type="text/javascript">
		window.parent.location = "<%=addStr%>";
	</script>
	<%
End if

If request.Form("code") <> "" Then
	%>processing<img src="<%=mainAppPath%>/images/ajax-loader.gif"><%
	code = request.Form("code")
	state = request.Form("state")
	safeUserId = request.Form("userId")
	'response.write("STATE: "&state)
	experimentType = Split(state,"_")(1)
	experimentId = Split(state,"_")(2)
	revisionNumber = Split(state,"_")(3)
	userId = Split(state,"_")(4)
	witness = Split(state,"_")(5)
	keepOpen = Split(state,"_")(6)
	requesteeId = Split(state,"_")(7)
	If witness="1" Then
		witness = True
	Else
		If keepOpen = "1" Then
			keepOpen = True
		Else
			keepOpen = False
		End if
		witness = False
	End if
	prefix = GetPrefix(experimentType)
	folderName = GetAbbreviation(experimentType)
	experimentTableName = GetFullName(prefix, "experiments", true)
	experimentHistoryTableName = GetFullName(prefix, "experimentHistoryView", true)
	'response.write("experiment type: "&experimentType&"<br/>")
	'response.write("experiment id: "&experimentId&"<br/>")
	'response.write("revisionNumber: "&revisionNumber&"<br/>")
	'response.write("user id: "&userId&"<br/>")

	If CStr(userId) = CStr(session("userId")) Then
		Call getconnectedAdm
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM witnessRequests WHERE accepted=0 and denied=0 and requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S")
		rec.open strQuery,connAdm,3,3
		If Not rec.eof Then
			canWitnessThis = True
		Else
			canWitnessThis = False
		End If
		If (ownsExperiment(experimentType,experimentId,session("userId")) And Not witness) Or (canWitnessThis And witness) Then
			maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
			If CInt(maxRevisionNumber) <> CInt(revisionNumber) Then
				response.write("ERROR: There is a newer version of this experiment...<br/>")
				response.end
			End If
			If Not witness then
				set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM "&experimentHistoryTableName&" WHERE "&_
					"experimentId="&SQLClean(experimentId,"N","S") & " AND " &_
					"experimentType="&SQLClean(experimentType,"N","S") & " AND " &_
					"revisionNumber="&SQLClean(maxRevisionNumber,"N","S") & " AND (statusId=5 or statusId=6)"
				rec2.open strQuery,conn,3,3
				If Not rec2.eof Then
					response.write("ERROR: Experiment already signed.<br/>")
					response.end
				End If
				rec2.close
				Set rec2 = Nothing
			Else
				set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM "&experimentHistoryTableName&" WHERE "&_
					"experimentId="&SQLClean(experimentId,"N","S") & " AND " &_
					"experimentType="&SQLClean(experimentType,"N","S") & " AND " &_
					"revisionNumber="&SQLClean(maxRevisionNumber,"N","S") & " AND (statusId=6)"
				rec2.open strQuery,conn,3,3
				If Not rec2.eof Then
					response.write("ERROR: Experiment already witnessed.<br/>")
					response.end
				End If
				rec2.close
				Set rec2 = Nothing
			End if

			set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT userId FROM "&experimentHistoryTableName&" WHERE "&_
				"experimentId="&SQLClean(experimentId,"N","S") & " AND " &_
				"experimentType="&SQLClean(experimentType,"N","S") & " AND " &_
				"revisionNumber="&SQLClean(maxRevisionNumber,"N","S")
			rec2.open strQuery,conn,3,3
			experimentUserId = rec2("userId")
			rec2.close
			Set rec2 = Nothing
			
			'this pdf path should probably change to grab the page numbered pdf for companies that desire this
			pdfPath = uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber&"\"&folderName&"\sign.pdf"
			'response.write(pdfPath)

			set fs=Server.CreateObject("Scripting.FileSystemObject")
			if fs.FileExists(pdfPath) Then
				Set adoStream = CreateObject("ADODB.Stream")  
				adoStream.Open()  
				adoStream.Type = 1  
				adoStream.LoadFromFile(pdfPath)
				Set objXML = CreateObject("MSXml2.DOMDocument")
				Set objDocElem = objXML.createElement("Base64Data")
				objDocElem.dataType = "bin.base64"
				objDocElem.nodeTypedValue = adoStream.Read()
				randomize
				pdf64 = objDocElem.text
				Set objDocElem = nothing
			End if

			formData = ""
			formData = formData & "&grant_type=authorization_code"
			formData = formData & "&code="&code
			If whichServer = "PROD" then
				formData = formData & "&client_id=OrIsgf7p8sSRaVbxqVrnWkIV3PaqrjUO"
				formData = formData & "&client_secret=YRxxv7iDV0eLx4dG"
			else
				formData = formData & "&client_id=B1OzrLpI31ANfDv9MiM6SojG658OoOCG"
				formData = formData & "&client_secret=R9GuaLY2xzGCK9FO"
			End if
			set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
			xmlhttp.Open "POST","https://api.universalid.icsl.net/oauth20/token",True
			xmlhttp.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
			'xmlhttp.SetTimeouts 120000,120000,120000,120000
			xmlhttp.send formData
			xmlhttp.waitForResponse(60)
			xmlStr = xmlhttp.responsexml.xml 'html decode needed?
			'response.write(xmlhttp.status)
			'response.write("c"&xmlStr&"c<br/>")
			token = getXMLTag("token",xmlStr)

			
			' outFilename = uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber+1&"\"&folderName&"\"
			' failedWitness = outFilename & "\fail.bad"
			' outFilename = outFilename&"\sign.pdf"
			'Set signRec = server.CreateObject("ADODB.RecordSet")

			' Call getconnectedAdm
			' strQuery = "INSERT INTO pdfProcQueue " &_
			' 			"(serverName, companyId, userId, experimentId, revisionNumber, fileType, experimentType, jsonBody, dateCreated, status) " &_
			' 			"VALUES ('" & whichServer & "'," & session("companyId") & "," & experimentUserId & "," & experimentId & "," & revisionNumber + 1 & "," & "'SAFE'" & ",'" & folderName & "'," &_
			' 			"'{""safeUserId"": """ & safeUserId & """, ""token"": """ & token & """}'" & "," & "GETDATE(), 'NEW')"
			' connAdm.execute(strQuery)

			
			baseFilename = token&"_"&safeUserId
			dim fs
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			'response.write("<br/>"&pdfPath&"<br/>"&inboxPath&"\"&baseFilename&".pdf")
			fs.CopyFile pdfPath,inboxPath&"\"&baseFilename&".pdf"
			set fs=nothing

			outFilename = uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber+1&"\"&folderName&"\"
			a = recursiveDirectoryCreate(uploadRoot,outFilename)
			outFilename = outFilename&"\sign.pdf"

			dim tfile
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			set tfile=fs.CreateTextFile(inboxPath&"\"&baseFilename&".safe")
			tfile.WriteLine(safeUserId)
			tfile.WriteLine(token)
			tfile.WriteLine(outFilename)
			tfile.close
			set tfile=nothing
			set fs=nothing

			signFailed = False
			counter = 0
			Do While True And counter < 60
				sleep = 5
				strQuery = "WAITFOR DELAY '00:00:" & right(clng(sleep),2) & "'" 
				connAdm.Execute strQuery,,129 
				set fs=Server.CreateObject("Scripting.FileSystemObject")
				If fs.fileExists(outFilename) Then
					set f=fs.GetFile(outFilename)
					If f.Size <> 0 then
						counter = 1000
					End If
					set f=nothing
				End if
				set fs=Nothing
				counter = counter + 1
			Loop
			If counter <> 1001 Then
				signFailed = True
			End if

			prefix = GetPrefix(experimentType)
			pageName = mainAppPath & "/" & GetExperimentPage(prefix) & "?id="&experimentId

			If Not signFailed then
				strQuery = "UPDATE "&experimentTableName&" set softSigned=1 WHERE id="&SQLClean(experimentId,"N","S")
				connAdm.execute(strQuery)
				If witness then
					a = duplicateAndChangeStatus(experimentType,experimentId,"6",true)
					strQuery = "UPDATE witnessRequests SET accepted=1,dateWitnessed=GETUTCDATE(),dateWitnessedServer=GETDATE() WHERE requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S") & " AND experimentTypeId="&SQLClean(experimentType,"N","S")
					connAdm.execute(strQuery)
				Else
					If keepOpen Then
						a = duplicateAndChangeStatus(experimentType,experimentId,"3",true)					
					else
						a = duplicateAndChangeStatus(experimentType,experimentId,"5",true)
					End if
				End If

				If experimentType = "4" then
					notExactlyExperimentType = "6"
				Else
					notExactlyExperimentType = experimentType + 1
				End if
				a = logAction(notExactlyExperimentType,experimentId,"",19)

				If Not witness And requesteeId <> "0" then
					errorStr = requestWitness(experimentType,experimentId,requesteeId)
					title = "Witness Request"
					prefix = GetPrefix(experimentType)
					tableName = GetFullName(prefix, "experiments", true)
					page = GetExperimentPage(prefix)
					Set rec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S")
					rec.open strQuery,conn,3,3
					If Not rec.eof Then
						experimentName = rec("name")
					End if
					note = "The user "&session("firstName") & " " & session("lastName") & " has requested that you witness <a href=""" & page & "?id="&experimentId&""">"&experimentName&"</a>"

					a = sendNotification(requesteeId,title,note,7)
				End if
			End If
			%>
			<script type="text/javascript">
				window.parent.location = '<%=pageName%>'
			</script>
			<%
		End if
	End if
End if


%>