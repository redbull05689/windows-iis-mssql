<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../globals.asp"-->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
chemAxonRootUrl = getCompanySpecificSingleAppConfigSetting("chemAxonEndpointUrl", session("companyId"))
''' This is used to allow the Marvin JS plugin to talk to the jchem backend '''

Response.CodePage = 65001
Response.CharSet = "UTF-8"

Set list = CreateObject("Scripting.Dictionary")
list.Add "util/detail", True
list.Add "util/convert/clean", True
list.Add "util/calculate/molExport", True
list.Add "util/calculate/cipStereoInfo", True
list.Add "util/calculate/reactionExport", True
list.Add "util/convert/hydrogenizer", True
list.Add "util/convert/reactionConverter", True

Dim objXmlHttp

reqURL = request.querystring("searchtype")
If list.Exists(reqURL) Then
    bytecount = Request.TotalBytes
    bytes = Request.BinaryRead(bytecount)

    Set stream = Server.CreateObject("ADODB.Stream")
        stream.Type = 1 'adTypeBinary              
        stream.Open()                                   
            stream.Write(bytes)
            stream.Position = 0                             
            stream.Type = 2 'adTypeText                
            stream.Charset = "utf-8"                      
            body = stream.ReadText() 'here is your json as a string                
        stream.Close()
    Set stream = nothing
    Set objXmlHttp = Server.CreateObject("MSXML2.ServerXMLHTTP")
    objXmlHttp.open "POST", chemAxonRootUrl & reqURL, true
    objXmlHttp.SetRequestHeader "Content-Type", "application/json"
  '  objXmlHttp.send URLDecode(body)
    objXmlHttp.send body

	objXmlHttp.waitForResponse(600)
	
    response.status = objXmlHttp.status   
    'response.status = 200  
    response.write objXmlHttp.responseText
    Set objXmlHttp = Nothing
	response.End()
Else
    response.Status = "403 Forbidden"
End If

Function RegExTest(str,patrn)
    Dim regEx
    Set regEx = New RegExp
    regEx.IgnoreCase = True
    regEx.Pattern = patrn
    RegExTest = regEx.Test(str)
End Function

'THIS IS SLOW!!!
Function URLDecode(sStr)
    Dim str,code,a0
    str=""
    code=sStr
    code=Replace(code,"+"," ")
    While len(code)>0
        If InStr(code,"%")>0 Then
            str = str & Mid(code,1,InStr(code,"%")-1)
            code = Mid(code,InStr(code,"%"))
            a0 = UCase(Mid(code,2,1))
            If a0="U" And RegExTest(code,"^%u[0-9A-F]{4}") Then
                str = str & ChrW((Int("&H" & Mid(code,3,4))))
                code = Mid(code,7)
            ElseIf a0="E" And RegExTest(code,"^(%[0-9A-F]{2}){3}") Then
                str = str & ChrW((Int("&H" & Mid(code,2,2)) And 15) * 4096 + (Int("&H" & Mid(code,5,2)) And 63) * 64 + (Int("&H" & Mid(code,8,2)) And 63))
                code = Mid(code,10)
            ElseIf a0>="C" And a0<="D" And RegExTest(code,"^(%[0-9A-F]{2}){2}") Then
                str = str & ChrW((Int("&H" & Mid(code,2,2)) And 3) * 64 + (Int("&H" & Mid(code,5,2)) And 63))
                code = Mid(code,7)
            ElseIf (a0<="B" Or a0="F") And RegExTest(code,"^%[0-9A-F]{2}") Then
                str = str & Chr(Int("&H" & Mid(code,2,2)))
                code = Mid(code,4)
            Else
                str = str & "%"
                code = Mid(code,2)
            End If
        Else
            str = str & code
            code = ""
        End If
    Wend
    URLDecode = str
End Function

%>