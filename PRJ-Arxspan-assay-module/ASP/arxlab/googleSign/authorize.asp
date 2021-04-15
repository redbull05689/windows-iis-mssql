<%response.buffer = false%>
<%Server.ScriptTimeout = 600%>
<!-- #include file="../_inclds/globals.asp" -->
<!-- #include file="../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_requestWitness.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%

pdfFooterOptions = getCompanySpecificSingleAppConfigSetting("pdfFooterOptions", session("companyId"))
pdfHeaderOptions = getCompanySpecificSingleAppConfigSetting("pdfHeaderOptions", session("companyId"))
pdfFooterOptionsRight = getCompanySpecificSingleAppConfigSetting("pdfFooterOptionsRight", session("companyId"))
rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
function getOtherPDFInfo(experimentId,experimentType,witnessName)
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "experimentHistoryView", true)
	Set expRec = server.CreateObject("ADODB.recordSet")
	strQuery = "SELECT * FROM "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")
	expRec.open strQuery,connAdm,0,-1
	str = ""
	str = str & ",'experimentName' : '" & pEscape(expRec("name")) & "'"
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
	str = str & ",'experimentStatus':'"&pEscape(expRec("status"))&"'"
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

Function decodeBase64(ByVal base64String)
  'rfc1521
  '1999 Antonin Foller, Motobit Software, http://Motobit.cz
  Const Base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  Dim dataLength, sOut, groupBegin
  
  'remove white spaces, If any
  base64String = Replace(base64String, vbCrLf, "")
  base64String = Replace(base64String, vbTab, "")
  base64String = Replace(base64String, " ", "")
  
  'The source must consists from groups with Len of 4 chars
  dataLength = Len(base64String)
  If dataLength Mod 4 <> 0 Then
    Err.Raise 1, "Base64Decode", "Bad Base64 string."
    Exit Function
  End If

  
  ' Now decode each group:
  For groupBegin = 1 To dataLength Step 4
    Dim numDataBytes, CharCounter, thisChar, thisData, nGroup, pOut
    ' Each data group encodes up To 3 actual bytes.
    numDataBytes = 3
    nGroup = 0

    For CharCounter = 0 To 3
      ' Convert each character into 6 bits of data, And add it To
      ' an integer For temporary storage.  If a character is a '=', there
      ' is one fewer data byte.  (There can only be a maximum of 2 '=' In
      ' the whole string.)

      thisChar = Mid(base64String, groupBegin + CharCounter, 1)

      If thisChar = "=" Then
        numDataBytes = numDataBytes - 1
        thisData = 0
      Else
        thisData = InStr(1, Base64, thisChar, vbBinaryCompare) - 1
      End If
      If thisData = -1 Then
        Err.Raise 2, "Base64Decode", "Bad character In Base64 string."
        Exit Function
      End If

      nGroup = 64 * nGroup + thisData
    Next
    
    'Hex splits the long To 6 groups with 4 bits
    nGroup = Hex(nGroup)
    
    'Add leading zeros
    nGroup = String(6 - Len(nGroup), "0") & nGroup
    
    'Convert the 3 byte hex integer (6 chars) To 3 characters
    pOut = Chr(CByte("&H" & Mid(nGroup, 1, 2))) + _
      Chr(CByte("&H" & Mid(nGroup, 3, 2))) + _
      Chr(CByte("&H" & Mid(nGroup, 5, 2)))
    
    'add numDataBytes characters To out string
    sOut = sOut & Left(pOut, numDataBytes)
  Next

  decodeBase64 = sOut
End Function
 
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
	For Each sItem In request.querystring
	Response.Write(sItem)
	Response.Write(" - [" & request.querystring(sItem) & "]" & strLineBreak)
	Next
End If
%>
<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->
<%
If request.querystring("code") <> "" Then
	code = request.querystring("code")
	%>processing...<%
	state = request.querystring("state")
	experimentType = Split(state,"_")(1)
	experimentId = Split(state,"_")(2)
	revisionNumber = Split(state,"_")(3)
	userId = Split(state,"_")(4)
	witness = Split(state,"_")(5)
	keepOpen = Split(state,"_")(6)
	requesteeId = Split(state,"_")(7)
	
	formData = ""
	formData = formData & "code="&server.urlencode(code)
	formData = formData & "&client_id="&server.urlencode("819343142027-dgdnuapm9s9kn378siln34f3fecmmrca.apps.googleusercontent.com")
	formData = formData & "&client_secret="&server.urlencode("BDoCvcLZRfhtdiMD_41lQYWp")
	formData = formData & "&grant_type="&server.urlencode("authorization_code")
	formData = formData & "&redirect_uri="&server.urlencode("https://"&rootAppServerHostName&"/arxlab/googleSign/authorize.asp")
	set http = server.Createobject("MSXML2.ServerXMLHTTP")
	http.Open "POST","https://www.googleapis.com/oauth2/v3/token",True
	http.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
	'xmlhttp.SetTimeouts 120000,120000,120000,120000
	http.send formData
	http.waitForResponse(60)
	jsonStr = http.responseText
	Set r = JSON.parse(jsonStr)
	jwtStr = Split(r.Get("id_token"),".")(1)
	Do While Not Len(jwtStr) Mod 4 = 0
		jwtStr = jwtStr & "="
	loop
	jwtStr = decodeBase64(jwtStr)
	Set jwt = JSON.parse(jwtStr)
	email = jwt.Get("email")
	emailVerified = jwt.Get("email_verified")
	If email <> session("email") Then
		response.write("<br/><br/>Email address incorrect")
		response.end
	End if

	witness = witness="1"

	If not witness Then
		keepOpen = keepOpen = "1"
	End If

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
		canWitnessThis = Not rec.eof
		If (ownsExperiment(experimentType,experimentId,session("userId")) And Not witness) Or (canWitnessThis And witness) Then
			maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
			If CInt(maxRevisionNumber) <> CInt(revisionNumber) Then
				response.write("<br/><br/>ERROR: There is a newer version of this experiment...<br/>")
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
					response.write("<br/><br/>ERROR: Experiment already signed.<br/>")
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
					response.write("<br/><br/>ERROR: Experiment already witnessed.<br/>")
					response.end
				End If
				rec2.close
				Set rec2 = Nothing
			End if

			prefix = GetPrefix(experimentType)
			page = GetExperimentPage(prefix)
			pageName = mainAppPath & "/" & page & "?id="&experimentId
			'redirect to dashboard instead of experiment page
			pageName = mainAppPath & "/dashboard.asp?id="&experimentId&"&experimentType="&experimentType&"&revisionNumber="&(revisionNumber+1)
			If witness Then
				pageName = pageName & "&witness=1"
			End if

			If Not signFailed then
				If witness Then
					newStatusId="6"
					oldRevisionNumber = duplicateAndChangeStatus(experimentType,experimentId,newStatusId,true)
					If session("useGMT") Then
						set timeRec = server.createobject("ADODB.RecordSet")
						strQuery = "SELECT GETUTCDATE() as theDate"
						timeRec.open strQuery,connAdm,0,-1
						theDate = timeRec("theDate")&" (GMT)"
						timeRec.close
						set timeRec = Nothing
					Else
						theDate = Date() & " " & Time() &" (EST)"
					End if
					signTable = "<table width='250'>"
					signTable = signTable & "<tr><td style='font-weight:bold;font-size:18px;' colspan='2'>Witness Information</td></tr>"
					signTable = signTable & "<tr><td style='font-weight:bold;'>Name</td><td>"&session("firstName") & " " & session("lastName")&"</td></tr>"
					signTable = signTable & "<tr><td style='font-weight:bold;'>User Id</td><td>"&session("userId")&"</td></tr>"
					signTable = signTable & "<tr><td style='font-weight:bold;'>Email</td><td>"&session("email")&"</td></tr>"
					signTable = signTable & "<tr><td style='font-weight:bold;'>Date</td><td>"&theDate&"</td></tr>"
					signTable = signTable & "</table>"

					pythonD = "{'signTable' : '"&Replace(signTable,"'","\'")&"'"&getOtherPDFInfo(experimentId,experimentType,session("firstName") & " " & session("lastName"))&"}"

					prefix = GetPrefix(experimentType)
					tableName = GetFullName(prefix, "experiments", true)
					suffix = GetAbbreviation(experimentType)

					Set uRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * FROM "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")
					uRec.open strQuery,connAdm,3,3
					userId = uRec("userId")
					experimentName = uRec("name")
					If newStatusId = "6" and oldRevisionNumber <> "0" then
										
						'Create a record in the pdfProcQueue table for the witness report		
						strQuery = "INSERT INTO [pdfProcQueue] (serverName, companyId, userId, experimentId, revisionNumber, experimentType, fileType, jsonBODY, dateCreated, status) VALUES (" & SQLClean(whichServer,"T","S") & ", " & SQLClean(getCompanyIdByUser(userId),"N","S") & ", " &SQLClean(userId,"N","S") & ", " & SQLClean(experimentId,"N","S") & ", " & SQLClean(oldRevisionNumber,"N","S") & ", " & SQLClean(suffix, "T", "S") &  ", " &	SQLClean("witness","T","S") & ", " &	SQLClean(pythonD,"T","S") & ", SYSDATETIME(), 'NEW')" 
						connAdm.execute(strQuery)
							
							'set fs=Server.CreateObject("Scripting.FileSystemObject")
							'set tfile=fs.CreateTextFile("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(userId)&"_"&userId&"_"&experimentId&"_"&oldRevisionNumber&"_"&suffix&".witness")
							'tfile.WriteLine(pythonD)
							'tfile.close
							'set tfile=nothing
							'set fs=nothing
					End If
					strQuery = "UPDATE witnessRequests SET accepted=1,dateWitnessed=GETUTCDATE(),dateWitnessedServer=GETDATE() WHERE requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S") & " AND experimentTypeId="&SQLClean(experimentType,"N","S")
					connAdm.execute(strQuery)

					title = "Experiment Witnessed"
					note = "User "&session("firstName") &" "& session("lastName")& " has witnessed <a href=""anal-experiment.asp?id="&experimentId&""">"&experimentName&"</a>"

					a = sendNotification(requesterId,title,note,9)	
					a = logAction(3,experimentId,"",8)
				Else
					If keepOpen Then
						a = duplicateAndChangeStatus(experimentType,experimentId,"3",true)					
					Else
						a = duplicateAndChangeStatus(experimentType,experimentId,"5",true)
						a = savePDF(experimentType,experimentId,revisionNumber+1,true,false,false)	
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
<!--#include file="../_inclds/footer-tool.asp"-->