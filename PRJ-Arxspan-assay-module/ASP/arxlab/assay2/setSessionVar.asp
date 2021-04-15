<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
Response.ContentType = "text/html"
Response.AddHeader "Content-Type", "text/html;charset=UTF-8"
Response.CodePage = 65001
Response.CharSet = "UTF-8"
%>
<%
session(request.querystring("key")) = request.querystring("value")
%>