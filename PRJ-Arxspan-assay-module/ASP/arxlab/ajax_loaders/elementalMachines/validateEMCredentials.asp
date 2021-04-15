<%isAjax=true%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include file="../../_inclds/experiments/common/functions/elementalMachinesApi.asp"-->
<%
session("elementalMachinesUserName") = request.form("userName")
session("elementalMachinesPassword") = request.form("password")

response.write(getAccessToken())
response.end()
%>
