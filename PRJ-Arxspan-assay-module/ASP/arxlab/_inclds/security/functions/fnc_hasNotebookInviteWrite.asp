<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function hasNotebookInviteWrite(cNotebookId,userId)
	'check if the specified user has an unaccepted and undenied write invitation to the specified notebook id
	userId = CStr(userId)
	hasNotebookInviteWrite = False
	Call getconnected
	Set crnRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM notebookInvites WHERE shareeId="&SQLClean(userId,"N","S") & " AND notebookId="&SQLClean(cNotebookId,"N","S") & " AND accepted=0 and denied=0 and canWrite=1"
	crnRec.open strQuery,conn,3,3
	If Not crnRec.eof Then
		hasNotebookInviteWrite = True
	End if
end Function
%>