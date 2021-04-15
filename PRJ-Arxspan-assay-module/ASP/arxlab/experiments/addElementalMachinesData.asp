<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<!-- #include file="../_inclds/globals.asp"-->
<%
experimentId = Request.Form("experimentId")
experimentType = Request.Form("experimentType")
machineGuid = Request.Form("elementalMachineGuid")
machineName = Request.Form("elementalMachineName")
startTime = Request.Form("startTimeEpoch")
endTime = Request.Form("endTimeEpoch")
data = Request.Form("data")

If experimentId = "" Or experimentType = "" Or machineGuid = "-1" Or startTime = "" Or endTime = "" Then
	response.Status = "403 All form fields are required. Changes will not be saved."
	response.end()
End If

Call getconnectedadm
strQuery = "SELECT id from elementalMachinesData where experimentId="&SQLClean(experimentId,"N","S")&" and experimentType="&SQLClean(experimentType,"N","S")&" and machineGuid="&SQLClean(machineGuid,"T","S")&" and startTime="&SQLClean(startTime,"N","S")&" and endTime="&SQLClean(endTime,"N","S") & " and data='" & data & "'"
Set rec = server.CreateObject("ADODB.RecordSet")
rec.open strQuery,conn,3,3
If Not rec.eof Then
	response.Status = "403 This machine has already been added for this time range."
	response.end()
Else
	revisionNumber = 1 + getExperimentRevisionNumber(experimentType, experimentId)
	strQuery = "INSERT into elementalMachinesData(companyId,userId,experimentType,experimentId,revisionNumber,machineGuid,machineName,startTime,endTime,data) values(" &_
	SQLClean(session("companyId"),"N","S") & "," &_
	SQLClean(session("userId"),"N","S") & "," &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(experimentId,"N","S") & "," &_
	SQLClean(revisionNumber,"N","S") & "," &_
	SQLClean(machineGuid,"T","S") & "," &_
	SQLClean(machineName,"T","S") & "," &_
	SQLClean(startTime,"N","S") & "," &_
	SQLClean(endTime,"N","S") & ",'" &_ 
	data & "')" 
	connAdm.execute(strQuery)
End If
Call disconnectAdm

response.write("{}")
response.end()
%>