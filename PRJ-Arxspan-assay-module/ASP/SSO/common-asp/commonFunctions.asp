<!-- #include virtual="/arxlab/_inclds/common/functions/fnc_base64Encode.asp"-->
<%
isArxLoginScript = True

'For Each item In Request.Form
    'Response.Write "Key: " & item & " - Value: " & Request.Form(item) & "<BR />"
'Next
'response.write(request.servervariables("QUERY_STRING"))
%>

<%
'#########  TO ENTER MAINTENANCE MODE #########################################
<!-- #include file="arxlab/_inclds/maintenance.asp"-->
if Maintenance = true then
	response.write("Arxspan ELN is down for planned maintanence")
	response.end
end if 
'##############################################################################

Function checkEmailsMatch
	if LCase(email) <> LCase(session("email")) Then
		showError("Email address mismatch. Please contact support@arxspan.com reference error SSO_MATCH.")
	end if
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

Function getOAuthClientData(ByVal companyId)
	getOAuthClientData = "{""clientId"":"""",""clientSecret"":""""}"
	
	' Get the clientId and clientSecret from the database
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT configJson FROM ssoConfigs WHERE companyId=" & SQLClean(companyId,"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		Set configParams = JSON.parse(rec("configJson"))
		If isObject(configParams) Then
			getOAuthClientData = "{""clientId"":""" & configParams.get("clientId") & """,""clientSecret"":""" & configParams.get("clientSecret") & """}"
		End If
	End If
	rec.close
	Set rec = Nothing
End Function
%>