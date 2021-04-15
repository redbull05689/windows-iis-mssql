<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
	monitorId = request("key")
	response.write(CX_getMonitorStatus(monitorId))
%>