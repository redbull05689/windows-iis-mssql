<%isAjax=true%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include file="../../_inclds/experiments/common/functions/elementalMachinesApi.asp"-->
<%
machineList = getListOfMachines()
response.write(machineList)
response.end()
%>
