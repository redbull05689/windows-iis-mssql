<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getNotebookId(experimentId,experimentType)
	'get the notebook id of the specified experiment
	getNotebookId = "0"
	call getconnected
	Set gnRec = server.CreateObject("ADODB.RecordSet")
	prefix = GetPrefix(experimentType)
	tableName = GetFullname(prefix, "experiments", true)
	strQuery = "SELECT notebookId FROM " & tableName & " WHERE id=" & SQLClean(experimentId,"N","S")
	gnRec.open strQuery,conn,3,3
	If Not gnRec.eof Then
		getNotebookId = CStr(gnRec("notebookId"))
	End if
end function
%>