<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function unsavedChanges(experimentType,experimentId)
	'return true if the database row for the specified experiment has the unsavedChanges column set to 1
	unsavedChanges = false
	Set psiRec = server.CreateObject("ADODB.RecordSet")
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "experiments", true)
	strQuery = "SELECT id FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S") & " AND unsavedChanges=1"
	psiRec.open strQuery,conn,3,3
	If Not psiRec.eof Then
		unsavedChanges = true
	End If
	psiRec.close
	Set psiRec = Nothing
end function
%>