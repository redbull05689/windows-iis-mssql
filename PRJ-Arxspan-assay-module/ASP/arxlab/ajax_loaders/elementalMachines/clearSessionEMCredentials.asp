<%isAjax=true%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include file="../../_inclds/experiments/common/functions/elementalMachinesApi.asp"-->
<%
session("elementalMachinesUserName") = ""
session("elementalMachinesPassword") = ""
response.write("Cleared")
response.end()
%>
