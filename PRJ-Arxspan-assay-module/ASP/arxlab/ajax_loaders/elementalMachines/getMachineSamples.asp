<%isAjax=true%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include file="../../_inclds/experiments/common/functions/elementalMachinesApi.asp"-->
<%
machineUuid = request.Form("uuid")
startEpoch = request.Form("startEpoch")
endEpoch = request.Form("endEpoch")
response.write(getListOfSamplesFromMachine(machineUuid, startEpoch, endEpoch))
response.end()
%>
