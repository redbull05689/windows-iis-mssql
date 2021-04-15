<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function isExperimentClosedByStatus(status)
	isExperimentClosedByStatus = true
	'5 - signed - closed, 6 - witnessed, 10 - pending abandonment, 11 - abandoned
	If status = 5 Or status = 6 Or status = 10 Or status = 11 Then
		isExperimentClosedByStatus = true		
	Else
		isExperimentClosedByStatus = false
	End if
end function
%>