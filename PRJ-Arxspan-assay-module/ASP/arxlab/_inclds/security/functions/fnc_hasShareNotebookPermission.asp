<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function hasShareNotebookPermission(userId)
	hasShareNotebookPermission = false
	'return true if user role permits sharing of notebooks
	if userId <> False then
		Set cwRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM usersView WHERE id="&SQLClean(userId,"N","S") & " AND roleNumber <= 10"
		cwRec.open strQuery,conn,3,3
		If Not cwRec.eof Then
			hasShareNotebookPermission = true
		End If
		cwRec.close
		Set cwRec = nothing
	Else
		'if user id not supplied use session userId
		if session("roleNumber") <= 10 then
			hasShareNotebookPermission = true
		end if
	end if
end function
%>