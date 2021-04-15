<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getChildInvites(notebookId,sharerId)
	invitesStr = ""
	Set gciRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id, shareeId FROM notebookInvites WHERE sharerId="&SQLClean(sharerId,"N","S")& " AND notebookId="&SQLClean(notebookId,"N","S")& " AND readOnly <> 1"
	gciRec.open strQuery,conn,3,3
	Do While Not gciRec.eof
		invitesStr = invitesStr & gciRec("id")
		children = getChildInvites(notebookId,gciRec("shareeId"))
		If children <> "" Then
			invitesStr = invitesStr & "," & children
		End if
		gciRec.moveNext
		If Not gciRec.eof Then
			invitesStr = invitesStr & ","
		End if
	Loop
	gciRec.close
	Set gciRec = nothing
	getChildInvites = invitesStr
end Function
%>