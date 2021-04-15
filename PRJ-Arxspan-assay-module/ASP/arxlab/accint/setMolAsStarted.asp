<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getConnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT notebookId FROM accMols WHERE id="&SQLClean(request.querystring("id"),"N","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	If canReadNotebook(rec("notebookId"),session("userId")) then
		strQuery = "UPDATE accMols SET started="&SQLClean(request.querystring("started"),"N","S")&" WHERE id="&SQLClean(request.querystring("id"),"N","S")
		jChemRegConn.execute(strQuery)
	End if
End If
rec.close
Set rec = nothing
Call disconnectJchemReg
%>