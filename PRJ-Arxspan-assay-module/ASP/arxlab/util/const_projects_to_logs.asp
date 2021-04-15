<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%Server.ScriptTimeout=108000%>
<%
response.buffer = false
if session("userId") = "2" And 1=1 then

	call getconnected
	Call getconnectedlog

	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM prodLogsView WHERE companyId=9 and actionId=1"
	rec.open strQuery,connLog,3,3
	Do While Not rec.eof
		projectStr = ""
		Select Case rec("extraTypeId")
			Case 2
				experimentType = 1
			Case 3
				experimentType = 2
			Case 4
				experimentType = 3
			Case 5
				experimentType = 4
		End Select
		experimentId = rec("extraId")
		notebookId = rec("notebookId")
		Set lRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM linksProjectExperimentsView WHERE experimentId="&SQLClean(experimentId,"N","S")& " AND typeId="&SQLClean(experimentType,"N","S")
		lRec.open strQuery,connNoTimeout
		Do While Not lRec.eof
			projectName = lRec("projectName")
			If Not IsNull(lRec("parentProjectId")) Then
				Set lRec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM projects WHERE id="&SQLClean(lRec("parentProjectId"),"N","S")
				lRec2.open strQuery,connNoTimeout
				If Not lRec2.eof Then
					projectName = lRec2("name")
				End If
			End if
			projectStr = projectStr & projectName &","
			lRec.movenext
		Loop
		Set lRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM linksProjectNotebooksView WHERE notebookId="&SQLClean(notebookId,"N","S")
		lRec.open strQuery,connNoTimeout
		Do While Not lRec.eof
			projectName = lRec("projectName")
			If Not IsNull(lRec("parentProjectId")) Then
				Set lRec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM projects WHERE id="&SQLClean(lRec("parentProjectId"),"N","S")
				lRec2.open strQuery,connNoTimeout
				If Not lRec2.eof Then
					projectName = lRec2("name")
				End If
			End if
			projectStr = projectStr & projectName &","
			lRec.movenext
		Loop		
		If Len(projectStr) > 1 Then
			projectStr = Mid(projectStr,1,Len(projectStr)-1)
		End If
		strQuery = "UPDATE prodLogs SET projectName="&SQLClean(projectStr,"T","S")&" WHERE id="&SQLClean(rec("id"),"N","S")
		response.write(strQuery&";<br/>")
		''connLog.execute(strQuery)
		rec.movenext
	loop

	Call disconnectlog
	call disconnect
end If
%>