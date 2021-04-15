<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->

<%
If session("canDelete") Or session("role")="Admin" then
notebookId = request.Form("notebookId")
errStr = ""
If Not ownsNotebook(notebookId) Then
	errStr = "You cannot delete this notebook because you do not own it"
End If
If session("role") = "Admin" And session("canDelete") Then
	errStr = ""
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM notebookView WHERE id="&SQLClean(notebookId,"N","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
	rec.open strQuery,conn,3,3
	If rec.eof Then
		errStr = "You cannot delete this notebook"
	End if
	Call disconnect
End if
'If isNotebookShared(notebookId) Then
'	errStr = "You cannot delete this notebook because it is currently shared"
'End If

If errStr = "" then
	Call getconnectedadm
	strQuery = "UPDATE notebooks SET visible=0 WHERE id="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE notebookIndex SET visible=0 WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE experiments SET visible=0 WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE experiments_history SET visible=0 WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE bioExperiments SET visible=0 WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE bioExperiments_history SET visible=0 WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE freeExperiments SET visible=0 WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE freeExperiments_history SET visible=0 WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE analExperiments SET visible=0 WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE analExperiments_history SET visible=0 WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE FROM notebookInvites WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE FROM groupNotebookInvites WHERE notebookId="&SQLClean(notebookId,"N","S")
	connAdm.execute(strQuery)
End if

If errStr = "" Then
	errStr = "success"
End if
%>
<div id="resultsDiv"><%=errStr%></div>
<%else%>
<div id="resultsDiv">Not Authorized</div>
<%End if%>