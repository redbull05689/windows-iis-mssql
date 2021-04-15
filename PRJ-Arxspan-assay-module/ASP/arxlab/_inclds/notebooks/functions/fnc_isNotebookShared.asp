<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function isNotebookShared(notebookId)
	'return true if the notebook is shared via a user invite
	'used to prevent notebook from being deleted if it is shared
	'nxq i think this function is circumvented in clear user data
	'nxq should include group shares too
	Set insRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM notebookInvites WHERE notebookId="&SQLClean(notebookId,"N","S") & " AND readOnly=0"
	insRec.open strQuery,conn,3,3
	isNotebookShared = Not insRec.eof
	
end function
%>