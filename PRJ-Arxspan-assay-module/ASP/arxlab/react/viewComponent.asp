<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
    sectionId = request.querystring("sid")
    subSectionId = request.querystring("ssid")
%>
<link href="componentFrame.css" rel="stylesheet">

<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->
<iframe class="componentFrame" height="100%" width="100%" src="../../node/<%=request.querystring("url")%>"></iframe>
<!--#include file="../_inclds/footer-tool.asp"--> 
