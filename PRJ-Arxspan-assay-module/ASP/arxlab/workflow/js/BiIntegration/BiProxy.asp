<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
BIProxyUrl = getCompanySpecificSingleAppConfigSetting("BIProxyEndpointUrl", session("companyId"))
    isApiPage = true
    server.scriptTimeout=300
    Response.CodePage = 65001
    Response.CharSet = "UTF-8"
%>
<!-- #include file="../../_inclds/globals.asp"-->
<%
    contentType = "application/json"

    Set http = CreateObject("MSXML2.ServerXMLHTTP")
    ' ignore ssl cert errors
    http.setOption 2, 13056
    http.open "POST", BIProxyUrl, True

    http.setRequestHeader "Accept", contentType
    http.setRequestHeader "Content-Type",contentType
    http.setRequestHeader "Content-Length",Len(request.Form("data"))
    http.setRequestHeader "Authorization", "Basic YTlkMDVjNTktMWRlYS00ZDc2LWE1ZGUtM2ViMmYxNzQ2MTU0OmUxZWQ4OWQzLWJhZjktNGNjMC05MjlmLWQ5Zjg3NGM4NWEzMg=="

    http.send request.Form("data")
    http.waitForResponse(180)

    'write the response in 1mb chunks - I was getting a buffer overrun in cases where trying to return a lot of data
    chunkId = 0
    chunkSize = 1000000
    responseLen = Len(http.responseText)

    If responseLen >= chunkSize Then
        Do While chunkId * chunkSize < responseLen
            response.write(Mid(http.responseText, (chunkId * chunkSize) + 1, chunkSize))
            response.flush()
            chunkId = chunkId + 1
        Loop
    Else
        response.write(http.responseText)
    End If

    response.end()
%>