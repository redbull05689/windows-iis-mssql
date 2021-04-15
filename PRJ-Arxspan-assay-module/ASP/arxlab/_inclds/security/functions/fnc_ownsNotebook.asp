<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function ownsNotebook(cNotebookId)
	'returns true if the session user owns the specified notebook
	If cNotebookId <> "" then
		ownsNotebook = False
		Call getconnected
		Set crnRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM notebooks WHERE userId="&SQLClean(session("userId"),"N","S") & " AND id="&SQLClean(cNotebookId,"N","S")
		crnRec.open strQuery,conn,3,3
		If Not crnRec.eof Then
			ownsNotebook = True
		End if
	Else
		ownsNotebook = False
	End if
end Function
%>