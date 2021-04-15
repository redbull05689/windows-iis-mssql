<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If canViewExperiment(experimentType,experimentId,session("userId")) Or ownsExp Then
	function getExperimentLink(experimentType,experimentId)
		prefix = GetPrefix(CStr(experimentType))
		experimentPage = GetExperimentPage(prefix)
		getExperimentLink = experimentPage&"?id="&experimentId
	end function
end If
%>