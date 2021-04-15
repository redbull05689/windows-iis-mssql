<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function canCreateExperiment(userId)
	'returns true if user can create an experiment
	if userId <> False then
		Set cwRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM usersView WHERE id="&SQLClean(userId,"N","S") & " AND roleNumber <= 30"
		cwRec.open strQuery,conn,3,3
		If Not cwRec.eof Then
			canCreateExperiment = true
		End If
		cwRec.close
		Set cwRec = nothing
	Else
		'if userId is false use the session role to determine result
		if session("roleNumber") <= 30 then
			canCreateExperiment = true
		end if
	end if
end function
%>