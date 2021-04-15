<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function isNotebookVisible(notebookId)
	'returns true if the notebook is visible
	Set insRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM notebooks WHERE id="&SQLClean(notebookId,"N","S") & " AND visible=1"
	insRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
	isNotebookVisible = Not insRec.eof
end function
%>