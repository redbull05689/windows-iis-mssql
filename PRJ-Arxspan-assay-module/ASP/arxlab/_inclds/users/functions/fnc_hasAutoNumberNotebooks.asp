<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function hasAutoNumberNotebooks()
	autoNumberNotebooks = False
	Set nRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT autoNotebookNumber FROM companies WHERE id="&SQLClean(session("companyId"),"N","S")
	nRec.open strQuery,conn,3,3
	If Not nRec.eof then
		autoNumberNotebooks = nRec("autoNotebookNumber") = 1
	End if
	nRec.close
	Set nRec = nothing
	hasAutoNumberNotebooks = autoNumberNotebooks
End Function
%>