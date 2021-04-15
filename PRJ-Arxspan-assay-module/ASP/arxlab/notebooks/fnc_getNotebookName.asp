<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
If request.Form <> "" Then
	Set nnRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT name FROM notebooks WHERE id=" &SQLClean(request.Form("notebookId"),"N","N")
	nnRec.open strQuery,connAdm,3,3
	If Not nnRec.eof Then
		NotebookName = nnRec("name")
	End If
	nnRec.close
	Set nnRec = nothing
	connAdm.execute(strQuery)

	response.write(NotebookName)

End if
%>