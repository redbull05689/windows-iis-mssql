<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getConnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM accMols WHERE id="&SQLClean(request.querystring("id"),"N","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	If ownsNotebook(rec("notebookId")) then
		strQuery = "UPDATE accMols SET cancelled="&SQLClean(request.querystring("cancelled"),"N","S")&" WHERE id="&SQLClean(request.querystring("id"),"N","S")
		jChemRegConn.execute(strQuery)
	End if
End If
rec.close
Set rec = nothing
Call disconnectJchemReg
%>