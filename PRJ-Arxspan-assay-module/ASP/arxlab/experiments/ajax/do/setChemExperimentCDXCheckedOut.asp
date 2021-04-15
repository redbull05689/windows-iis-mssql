<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%'412015%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
'set checked out flag for chemistry cdx file
experimentId = request.querystring("experimentId")
state = CStr(request.querystring("state"))
experimentType = request.querystring("experimentType")

Call getconnectedAdm

'update flag if the user owns the experiment
If ownsExperiment(experimentType,experimentId,session("userId")) Then
	if state = "0" then
		strQuery = "UPDATE experiments SET checkedOut = NULL WHERE id="&SQLClean(experimentId,"N","S")
	else
		strQuery = "UPDATE experiments SET checkedOut= "&SQLClean(state,"T","S")&" WHERE id="&SQLClean(experimentId,"N","S")
	end if
	connAdm.execute(strQuery)
End if

Call disconnectAdm

%>
<%'/412015%>