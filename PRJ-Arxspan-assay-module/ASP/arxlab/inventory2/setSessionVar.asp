<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
session(request.querystring("key")) = request.querystring("value")
%>