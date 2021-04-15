<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%

''' Stolen from here: https://stackoverflow.com/a/31453654/3009411 '''

' These can be used as follows:

' bytesToHex(md5hashBytes(GetBytes(sPath))) 

' BytesToBase64(md5hashBytes(stringToUTFBytes("Hello World")))
' Produces: sQqNsWTgdUEFt6mb5y4/5Q==

' bytesToHex(md5hashBytes(stringToUTFBytes("Hello World")))
' Produces: B10A8DB164E0754105B7A99BE72E3FE5

' For SHA1:

' bytesToHex(sha1hashBytes(stringToUTFBytes("Hello World")))
' Produces: 0A4D55A8D778E5022FAB701977C5D840BBC486D0

' For SHA256:

' bytesToHex(sha256hashBytes(stringToUTFBytes("Hello World")))
' Produces: A591A6D40BF420404A011733CFB7B190D62C65BF0BCDA32B57B277D9AD9F146E

' To get the MD5 of a file (useful for Amazon S3 MD5 checking):

' BytesToBase64(md5hashBytes(GetBytes(sPath)))
' Where sPath is the path to the local file.

' And finally, to create a JWT:

' 'define the JWT header, needs to be converted to UTF bytes:
' aHead=stringToUTFBytes("{""alg"":""HS256"",""typ"":""JWT""}")

' 'define the JWT payload, again needs to be converted to UTF Bytes.
' aPayload=stringToUTFBytes("{""sub"":""1234567890"",""name"":""John Doe"",""admin"":true}") 

' 'Your shared key.
' theKey="mySuperSecret"

' aSigSource=stringToUTFBytes(BytesToBase64UrlEncode(aHead) & "." & BytesToBase64UrlEncode(aPayload))

' 'The full JWT correctly Base 64 URL encoded.
' aJWT=BytesToBase64UrlEncode(aHead) & "." & BytesToBase64UrlEncode(aPayload) & "." & BytesToBase64UrlEncode(sha256HMACBytes(aSigSource,stringToUTFBytes(theKey)))
' Which will produce the following valid JWT: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.7ofvtkn0z_pTl6WcqRTxw-4eSE3NqcEq9_3ax0YcuIQ


function md5hashBytes(aBytes)
    Dim MD5
    set MD5 = CreateObject("System.Security.Cryptography.MD5CryptoServiceProvider")

    MD5.Initialize()
    'Note you MUST use computehash_2 to get the correct version of this method, and the bytes MUST be double wrapped in brackets to ensure they get passed in correctly.
    md5hashBytes = MD5.ComputeHash_2( (aBytes) )
end function

function sha1hashBytes(aBytes)
    Dim sha1
    set sha1 = CreateObject("System.Security.Cryptography.SHA1Managed")

    sha1.Initialize()
    'Note you MUST use computehash_2 to get the correct version of this method, and the bytes MUST be double wrapped in brackets to ensure they get passed in correctly.
    sha1hashBytes = sha1.ComputeHash_2( (aBytes) )
end function

function sha256hashBytes(aBytes)
    Dim sha256
    set sha256 = CreateObject("System.Security.Cryptography.SHA256Managed")

    sha256.Initialize()
    'Note you MUST use computehash_2 to get the correct version of this method, and the bytes MUST be double wrapped in brackets to ensure they get passed in correctly.
    sha256hashBytes = sha256.ComputeHash_2( (aBytes) )
end function

function sha256HMACBytes(aBytes, aKey)
    Dim sha256
    set sha256 = CreateObject("System.Security.Cryptography.HMACSHA256")

    sha256.Initialize()
    sha256.key=aKey
    'Note you MUST use computehash_2 to get the correct version of this method, and the bytes MUST be double wrapped in brackets to ensure they get passed in correctly.
    sha256HMACBytes = sha256.ComputeHash_2( (aBytes) )
end function

function stringToUTFBytes(aString)
    Dim UTF8
    Set UTF8 = CreateObject("System.Text.UTF8Encoding")
    stringToUTFBytes = UTF8.GetBytes_4(aString)
end function

function bytesToHex(aBytes)
    dim hexStr, x
    for x=1 to lenb(aBytes)
        hexStr= hex(ascb(midb( (aBytes),x,1)))
        if len(hexStr)=1 then hexStr="0" & hexStr
        bytesToHex=bytesToHex & hexStr
    next
end function

Function BytesToBase64(varBytes)
    With CreateObject("MSXML2.DomDocument").CreateElement("b64")
        .dataType = "bin.base64"
        .nodeTypedValue = varBytes
        BytesToBase64 = .Text
    End With
End Function

'Special version that produces the URLEncoded variant of Base64 used in JWTs.
Function BytesToBase64UrlEncode(varBytes)
    With CreateObject("MSXML2.DomDocument").CreateElement("b64")
        .dataType = "bin.base64"
        .nodeTypedValue = varBytes
        BytesToBase64UrlEncode = replace(replace(replace(replace(replace(.Text,chr(13),""),chr(10),""),"+", "-"),"/", "_"),"=", "")
    End With
End Function

Function GetBytes(sPath)
    With CreateObject("Adodb.Stream")
        .Type = 1 ' adTypeBinary
        .Open
        .LoadFromFile sPath
        .Position = 0
        GetBytes = .Read
        .Close
    End With
End Function
%>