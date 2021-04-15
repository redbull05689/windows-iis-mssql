<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function canCreateNotebook(userId)
	'returns true if userId can create a notebook
	if userId <> False then
		Set cwRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM usersView WHERE id="&SQLClean(userId,"N","S") & " AND roleNumber <= 20"
		cwRec.open strQuery,conn,3,3
		If Not cwRec.eof Then
			canCreateNotebook = true
		End If
		cwRec.close
		Set cwRec = nothing
	Else
		'if user id is blank then use the session role number to determine result
		if session("roleNumber") <= 20 then
			canCreateNotebook = true
		end if
	end if
end function
%>