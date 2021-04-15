<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
call getconnected
notebookId = request.querystring("notebookId")
If canWriteNotebook(notebookId)
	Set neRec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT name from notebooks WHERE id="&SQLClean(notebookId,"N","S")
	neRec2.open strQuery,conn,3,3
	If Not neRec2.eof Then
		experimentName = neRec2("name")
	End If

	experimentCount = 1

	Set neRec = server.CreateObject("ADODB.Recordset")
	strQuery = "SELECT id From notebookIndex WHERE notebookId="&SQLClean(request.querystring("notebookId"),"N","S")
	neRec.open strQuery,conn,3,3
	If Not neRec.eof then	
		experimentCount = neRec.recordCount + experimentCount
	End If
	experimentCount = CInt(experimentCount)
	If experimentCount < 10 Then
		experimentCount = "00" + CStr(experimentCount)
	Else
		If experimentCount < 100 Then
			experimentCount = "0" + CStr(experimentCount)
		Else
			If experimentCount < 1000 Then
				experimentCount = CStr(experimentCount)
			End if
		End if
	End if
	response.write(experimentName&" - "&experimentCount)
End if
%>