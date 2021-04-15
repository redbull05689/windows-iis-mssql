<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function canWitness(userId)
	'return true if the users role permits them to witness experiments
	if userId <> False then
		Set cwRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM usersView WHERE id="&SQLClean(userId,"N","S") & " AND roleNumber <= 40"
		cwRec.open strQuery,conn,3,3
		If Not cwRec.eof Then
			canWitness = true
		End If
		cwRec.close
		Set cwRec = nothing
	Else
		'if user id is not given to function then user the session user id
		if session("roleNumber") <= 40 then
			canWitness = true
		end if
	end if
end function
%>