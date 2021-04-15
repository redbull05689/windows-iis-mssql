<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
response.write(Now())
response.write("<br>")
response.write(getExperimentsICanView())
response.write("<br>")
response.write(Now())
response.end()
%>