<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../../../_inclds/globals.asp" -->
<%
call getconnectedadm
	projectId = request.querystring("tabId")
	If errStr = "" Then
		Call getconnected
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM linksProjectExperiments WHERE projectId="&SQLClean(projectId,"N","S")
		rec.open strQuery,conn,3,3
		If not rec.eof Then
			errStr = errStr & "You cannot delete this subproject because it contains experiments.  Please remove experiments from the subproject and try again."&vbcrlf
		End If
		rec.close
		Set rec = Nothing

		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM linksProjectNotebooks WHERE projectId="&SQLClean(projectId,"N","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			errStr = errStr & "You cannot delete this subproject because it contains notebooks.  Please remove notebooks from the subproject and try again."&vbcrlf
		End If
		rec.close
		Set rec = Nothing

		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM linksProjectReg WHERE projectId="&SQLClean(projectId,"N","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			errStr = errStr & "You cannot delete this subproject because it contains registration items.  Please remove registration items from the subproject and try again."&vbcrlf
		End If
		rec.close
		Set rec = Nothing
		

		Call disconnect
	End if
If errStr = "" then
	tabId = request.querystring("tabId")
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM projects WHERE parentProjectId is not null and id="&SQLClean(tabId,"N","S")
	rec.open strQuery,connAdm,3,3
	If Not rec.eof Then
		If ownsProject(rec("parentProjectId")) or (session("canDelete") and session("role")="Admin") Then
			strQuery = "DELETE FROM projects WHERE id="&SQLClean(tabId,"N","S")
			connAdm.execute(strQuery)
		End if
	End if
Else
	response.write(errStr)
End if
call disconnectadm
%>