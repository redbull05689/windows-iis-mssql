<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp" -->
<%
Call getconnected
topLevel = request.querystring("topLevel")
searchTerm = request.querystring("searchTerm")
response.write(getBackupList(topLevel,searchTerm,"jsString"))
%>