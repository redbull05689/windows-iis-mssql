<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp" -->
<%
numResults = request.querystring("numResults")
notebookId = request.querystring("notebookId")
If ((numResults >= 10 And numResults <=100) Or numResults=10000) And notebookId<>"" Then
	Call getconnectedAdm
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM notebookResults WHERE userId="&SQLClean(session("userId"),"N","S") & " AND notebookId="&SQLClean(notebookId,"N","S")
	rec.open strQuery,connAdm,3,3
	If rec.eof Then
		connAdm.execute("INSERT into notebookResults(userId,notebookId,numResults) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(notebookId,"N","S")&","&SQLClean(numResults,"N","S")&")")
	Else
		connAdm.execute("UPDATE notebookResults SET numResults="&SQLClean(numResults,"N","S") & " WHERE notebookId="&SQLClean(notebookId,"N","S")& " AND userId="&SQLClean(session("userId"),"N","S"))
	End if
	Call disconnectAdm
Else
	If numResults = 0 Then
		Call getconnectedAdm
		connAdm.execute("DELETE FROM notebookResults WHERE notebookId="&SQLClean(notebookId,"N","S")& " AND userId="&SQLClean(session("userId"),"N","S"))
		Call disconnectAdm
	End If
End if
%>