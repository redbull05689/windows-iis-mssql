
<!--#include file="./aspJSON.asp"-->
<%
Function setJWT(userId, companyId)
	' 1/10/19 - create JWT security token 
	' get the signing key from the admin service using the ELN appName (does not matter since all our apps use the same signing key)
  ' also make sure we have the adminSvcEndpointUrl to begin with.
  adminServiceEndpointUrl = getAdminSvcEndpoint()

	targetURL = adminServiceEndpointUrl & "/appconfig/signing-key?appName=ELN"
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "GET",targetURL,false
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	sKeyText = xmlhttp.responsetext
	sKey = JSON.Parse(sKeyText)
	Set xmlhttp = Nothing

	Set dAttributes=Server.CreateObject("Scripting.Dictionary")
	dAttributes.Add "userId", CLng(userId)
	dAttributes.Add "companyId", CInt(companyId)
	dAttributes.Add "sessionId", session.sessionId
	session("jwtToken") = JWTEncode(dAttributes, sKey)
End Function

' Accepts an ASP dictionary of key/value pairs and a secret and
' returns a signed JSON Web Token
Function JWTEncode(dPayload, sSecret)
  Dim sPayload, sHeader, sBase64Payload, sBase64Header
  Dim sSignature, sToken
  sPayload = DictionaryToJSONString(dPayload)
  sHeader  = JWTHeaderDictionary()
  sBase64Payload = SafeBase64Encode(sPayload)
  sBase64Header  = SafeBase64Encode(sHeader)
  sPayload       = sBase64Header & "." & sBase64Payload
  sSignature     = SHA256SignAndEncode(sPayload, sSecret)
  sToken         = sPayload & "." & sSignature
  JWTEncode = sToken
End Function

' SHA256 HMAC
Function SHA256SignAndEncode(sIn, sKey)
  Dim sSignature
  'Open WSC object to access the encryption function
  Set sha256 = GetObject("script:"&Server.MapPath("\arxlab\_inclds\security\functions\sha256.wsc"))
  'SHA256 sign data
  sSignature = sha256.b64_hmac_sha256(sKey, sIn)
  sSignature = Base64ToSafeBase64(sSignature)
  SHA256SignAndEncode = sSignature
End Function

' Returns a static JWT header dictionary
Function JWTHeaderDictionary()
  Dim dOut
  Set dOut = Server.CreateObject("Scripting.Dictionary")
  dOut.Add "typ", "JWT"
  dOut.Add "alg", "HS256"
  JWTHeaderDictionary = DictionaryToJSONString(dOut)
End Function

' Converts an ASP dictionary to a JSON string
Function DictionaryToJSONString(dDictionary)
  Set oJSONpayload = New aspJSON
  
  Dim i, aKeys
  aKeys = dDictionary.keys
  
  For i = 0 to dDictionary.Count-1
    oJSONpayload.data (aKeys(i))= dDictionary(aKeys(i))
  Next
  DictionaryToJSONString = oJSONpayload.JSONoutput()
End Function

Function SafeBase64Encode(sIn)
  sOut = Base64Encode(sIn)
  sOut = Base64ToSafeBase64(sOut)
  SafeBase64Encode = sOut
End Function

' Strips unsafe characters from a Base64 encoded string
Function Base64ToSafeBase64(sIn)
  sOut = Replace(sIn,"+","-")
  sOut = Replace(sOut,"/","_")
  sOut = Replace(sOut,"\r","")
  sOut = Replace(sOut,"\n","")
  sOut = Replace(sOut,"=","")
  Base64ToSafeBase64 = sOut
End Function

Function Base64Encode(inData)
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
  Function Base64Decode(ByVal base64String)
  'rfc1521

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
  ' an integer For temporary storage. If a character is a '=', there
  ' is one fewer data byte. (There can only be a maximum of 2 '=' In
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
  Base64Decode = sOut
End Function
%>