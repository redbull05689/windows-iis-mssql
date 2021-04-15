<%response.buffer = false%>
<%Server.ScriptTimeout = 600%>
<%sectionId="autolog"%>
<!-- #include file="../../_inclds/globals.asp" -->
<%

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
  response.write("X"&dataLength)
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
If 1=2 then
	For Each sItem In Request.querystring
	Response.Write(sItem)
	Response.Write(" - [" & Request.querystring(sItem) & "]" & "<br/>")
	Next
code = request.querystring("code")
If code <> "" And request.querystring("state") = session("state") Then
	formData = ""
	formData = formData & "code="&server.urlencode(code)
	formData = formData & "&client_id="&server.urlencode("819343142027-dgdnuapm9s9kn378siln34f3fecmmrca.apps.googleusercontent.com")
	formData = formData & "&client_secret="&server.urlencode("BDoCvcLZRfhtdiMD_41lQYWp")
	formData = formData & "&grant_type="&server.urlencode("authorization_code")
	formData = formData & "&redirect_uri="&server.urlencode("https://dev.arxspan.com/arxlab/auth/google/auth.asp")
	set http = server.Createobject("MSXML2.ServerXMLHTTP")
	http.Open "POST","https://www.googleapis.com/oauth2/v3/token",True
	http.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
	'xmlhttp.SetTimeouts 120000,120000,120000,120000
	http.send formData
	http.waitForResponse(60)
	jsonStr = http.responseText
	Set r = JSON.parse(jsonStr)
	response.write("AA"&jsonStr&"BB")
	response.write(r.Get("access_token"))
	jwtStr = Split(r.Get("id_token"),".")(1)
	Do While Not Len(jwtStr) Mod 4 = 0
		jwtStr = jwtStr & "="
	loop
	jwtStr = decodeBase64(jwtStr)
	response.write(jwtStr)
	Set jwt = JSON.parse(jwtStr)
End if

End if
%>