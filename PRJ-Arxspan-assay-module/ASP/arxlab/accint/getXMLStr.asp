<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_convertToCDXML.asp"-->

<%

path = uploadRoot & "\workflow_uploads\" & session("userId") & "\"
path = path & request.form("file")

xmlStr = convertToCDXMLFromFilePath(path)
response.write(xmlStr)
%>