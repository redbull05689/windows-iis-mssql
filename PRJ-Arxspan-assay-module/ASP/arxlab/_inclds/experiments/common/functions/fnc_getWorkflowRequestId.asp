<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function getWorkflowRequestId(experimentType, experimentId)
	getWorkflowRequestId = """"""
	If experimentType = 5 Or experimentType = "5" Then
		Call getConnected
		Set pRec = server.CreateObject("ADODB.Recordset")
		pStrQuery = "SELECT requestId FROM custExperiments WHERE id="&SQLClean(experimentId,"N","S")
		pRec.open pStrQuery,conn,3,3
		If Not pRec.eof Then
			getWorkflowRequestId = pRec("requestId")
		End If
		pRec.close
		Set pRec = Nothing
		Call disconnect
	End If
End Function
%>