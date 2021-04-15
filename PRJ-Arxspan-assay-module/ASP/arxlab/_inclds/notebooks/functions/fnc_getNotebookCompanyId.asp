<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getNotebookCompanyId(notebookId)
	'get the company id for the specified notebook
	Set geRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT companyId FROM notebookView WHERE id="&SQLClean(notebookId,"N","S")
	geRec.open strQuery,conn,3,3
	If Not geRec.eof Then
		'return the company Id
		getNotebookCompanyId = CStr(geRec("companyId"))
	End If
	geRec.close
	Set geRec = nothing
end function
%>