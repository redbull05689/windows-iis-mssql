<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True

For Each item In Request.Form
    'Response.Write "Key: " & item & " - Value: " & Request.Form(item) & "<BR />"
Next
'response.write(request.servervariables("QUERY_STRING"))
%>

<%
'#########  TO ENTER MAINTENANCE MODE UN REMARK THE NEXT TWO LINES / REMARK TO ENABLE MSKCC LOGINS  ##################

'response.write("Arxlab is down for planned maintanence")
'response.end

'##############################################################################

Function Base64Encode(inData)
  'rfc1521
  '2001 Antonin Foller, Motobit Software, http://Motobit.cz
  Const Base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  Dim cOut, sOut, I
  
  'For each group of 3 bytes
  For I = 1 To Len(inData) Step 3
    Dim nGroup, pOut, sGroup
    
    'Create one long from this 3 bytes.
    nGroup = &H10000 * Asc(Mid(inData, I, 1)) + _
      &H100 * MyASC(Mid(inData, I + 1, 1)) + MyASC(Mid(inData, I + 2, 1))
    
    'Oct splits the long To 8 groups with 3 bits
    nGroup = Oct(nGroup)
    
    'Add leading zeros
    nGroup = String(8 - Len(nGroup), "0") & nGroup
    
    'Convert To base64
    pOut = Mid(Base64, CLng("&o" & Mid(nGroup, 1, 2)) + 1, 1) + _
      Mid(Base64, CLng("&o" & Mid(nGroup, 3, 2)) + 1, 1) + _
      Mid(Base64, CLng("&o" & Mid(nGroup, 5, 2)) + 1, 1) + _
      Mid(Base64, CLng("&o" & Mid(nGroup, 7, 2)) + 1, 1)
    
    'Add the part To OutPut string
    sOut = sOut + pOut
    
    'Add a new line For Each 76 chars In dest (76*3/4 = 57)
    'If (I + 2) Mod 57 = 0 Then sOut = sOut + vbCrLf
  Next
  Select Case Len(inData) Mod 3
    Case 1: '8 bit final
      sOut = Left(sOut, Len(sOut) - 2) + "=="
    Case 2: '16 bit final
      sOut = Left(sOut, Len(sOut) - 1) + "="
  End Select
  Base64Encode = sOut
End Function

Function MyASC(OneChar)
  If OneChar = "" Then MyASC = 0 Else MyASC = Asc(OneChar)
End Function

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

sectionId="autolog"
whiteListOverride = true
%>
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<!-- #include file="../../arxlab/_inclds/misc/functions/fnc_ipsFromRange_local.asp"-->
<%

authError = False
code = request.querystring("code")
If code <> "" And request.querystring("state") = session("state") Then
	formData = ""
	formData = formData & "grant_type="&server.urlencode("authorization_code")
	formData = formData & "&code="&server.urlencode(code)
	formData = formData & "&redirect_uri="&server.urlencode(session("redirectURI"))
	formData = formData & "&scope="&server.urlencode(session("scope"))

	set http = server.Createobject("MSXML2.ServerXMLHTTP")
	http.Open "POST", session("baseAuthURL")&"/GetToken",False
	http.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
	s =  Base64Encode(CStr(session("clientId"))&":"&CStr(session("clientSecret")))
	http.setRequestHeader "Authorization", "Basic "&s
	http.send formData
	jsonStr = http.responseText
	Set r = JSON.parse(jsonStr)
	jwtArr = Split(r.Get("id_token"),".")
	If UBound(jwtArr)<1 Then
		authError = true
	Else
		jwtStr = jwtArr(1)
		Do While Not Len(jwtStr) Mod 4 = 0
			jwtStr = jwtStr & "="
		loop
		jwtStr = decodeBase64(jwtStr)
		Set jwt = JSON.parse(jwtStr)
		
		atoke = r.Get("access_token")
		formData = ""
		formData = formData & "scope="&server.urlencode(session("scope"))

		set http = server.Createobject("MSXML2.ServerXMLHTTP")
		http.Open "POST", session("baseAuthURL")&"/UserInfo",False
		http.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
		http.setRequestHeader "Authorization", "Bearer "&atoke
		http.send formData
		jsonStr = http.responseText
		Set uInfo = JSON.parse(jsonStr)
		email = uInfo.Get("email")
		emailVerified = uInfo.Get("email_verified")
	End if

Else
	authError = true
End if

'to turn off email verification requirement comment out these lines
If Not emailVerified Then
	authError = true
	emailNotVerified = true
End if

'If email="support@arxspan.com" Then
	'login as this user
	'email = support@arxspan.com
'End if

If Not authError then
	Call getconnected
	Call getconnectedadm
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM companies WHERE id="&SQLClean(session("authCompanyId"),"N","S")&" AND (datediff(day,getdate(), expirationDate) > 0 or expirationDate is null or expirationDate='1/1/1900') and (disabled=0 or disabled is null)"
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM users WHERE enabled=1 AND (companyId="&SQLClean(session("authCompanyId"),"N","S")&") AND email="&SQLClean(email,"T","S")
		rec2.open strQuery,conn,3,3
		If Not rec2.eof Then

			ipBlocked = false
			Set rec3 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM usersView WHERE ipBlock=1 and ipBlockMe=1 and id="&SQLClean(rec2("id"),"N","S")
			rec3.open strQuery,conn,3,3
			If Not rec3.eof Then
				ipBlocked = True
				ipStr = rec3("ipRanges")
				If ipStr <> "" Then
					ipStr = ipStr & ",100.0.175.27,8.20.189.20,108.7.43.41,8.20.189.16,8.20.189.168,8.20.189.170"
				Else
					ipStr = "100.0.175.27,8.20.189.20,8.20.189.168,8.20.189.170"
				End if
				ipArray = Split(ipsFromRange(ipStr),",")
				For q = 0 To UBound(ipArray)
					If ipArray(q) = request.servervariables("REMOTE_ADDR") Then
						ipBlocked = false
					End if
				Next
			End If
			If ipBlocked Then
				message = "There was an error logging you in.  Please contact support@arxspan.com"
				showError(message)
			Else
				loginUser(rec2("id"))
				response.redirect(mainAppPath&"/dashboard.asp")
			End if
		Else
			message = "There was an error logging you in. " & email & " does not have an account.  Please contact support@arxspan.com"
			showError(message)
		End if
	Else
		message = "There was an error logging you in.  Please contact support@arxspan.com  Reference error: GUITAR." ' Just a random searchable word so the error message doesn't need to say "You guys forgot to pay"
		showError(message)
	end if
Else
	if emailNotVerified then
		message = "There was an error logging you in.  Your email address has not been verified"
		showError(message)
	else
		message = "There was an error logging you in.  Please contact support@arxspan.com"
		showError(message)
	end if
End if

sub showError(str)
	response.write(str&"<br/>")
	If request.querystring("error") <> "" Then
		response.write(request.querystring("error")&"<br/>")
	End If
	If request.querystring("error_description") <> "" Then
		response.write(request.querystring("error_description")&"<br/>")
	End if
	response.end
End sub
%>