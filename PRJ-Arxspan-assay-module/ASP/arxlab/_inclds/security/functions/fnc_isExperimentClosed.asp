<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function isExperimentClosed(experimentType,experimentId)
	isExperimentClosed = true
	prefix = GetPrefix(CStr(experimentType))
	experimentTable = GetFullName(prefix, "experiments", true)
	Set cveRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT statusId from "&experimentTable&" WHERE id="&SQLClean(experimentId,"N","S")
	cveRec.open strQuery,conn,0,-1
	If Not cveRec.eof Then
		'5 - signed - closed, 6 - witnessed, 10 - pending abandonment, 11 - abandoned
		If cveRec("statusId") = 5 Or cveRec("statusId") = 6 Or cveRec("statusId") = 10 Or cveRec("statusId") = 11 Then
			isExperimentClosed = true		
		Else
			isExperimentClosed = false
		End if
	End if

end function
%>