<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->

<%
Response.CodePage = 65001
Response.CharSet = "UTF-8"

apiEndpoint = "/requesttypes"
apiEndpoint = apiEndpoint & "?includeDisabled=true"
apiEndpoint = apiEndpoint &  "&appName=ELN"
apiEndpoint = apiEndpoint & "&intents="
apiEndpoint = apiEndpoint & "&forcedGroupIds="
apiEndpoint = apiEndpoint & "&AsOfDate="

a = configGet(apiEndpoint)

response.write(a)
response.end

%>