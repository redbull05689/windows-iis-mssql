<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->

<%
If session("canDelete") then
	projectId = request("projectId")
	errStr = ""
	If Not ownsProject(projectId) and Not (session("canDelete") and session("role")="Admin") Then
		errStr = "You cannot delete this project because you do not own it"
	End If

	If session("role") = "Admin" And session("canDelete") Then
		errStr = ""
		Call getconnected
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM projectsView WHERE id="&SQLClean(projectId,"N","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
		rec.open strQuery,conn,3,3
		If rec.eof Then
			errStr = "You cannot delete this project"
		End if
		Call disconnect
	End if
	If errStr = "" Then
		hasExpLinks = false
		Call getconnected
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM linksProjectExperiments WHERE projectId="&SQLClean(projectId,"N","S")
		rec.open strQuery,conn,3,3
		Do While Not rec.eof
			experimentType = rec("experimentType")
			experimentId = rec("experimentId")
			prefix = GetPrefix(experimentType)
			experimentTable = GetFullName(prefix, "experiments", true)
			Set subrec = server.CreateObject("ADODB.RecordSet")
			substrQuery = "SELECT * FROM " + experimentTable + " WHERE id="&SQLClean(experimentId,"N","S")
			subrec.open substrQuery,conn,3,3
			Do While Not subrec.eof
				visible = subrec("visible")
				if visible = 1 then
					hasExpLinks = true
				end if
				subrec.movenext
			loop
			subrec.close
			Set subrec = Nothing
			rec.movenext
		Loop				
		if hasExpLinks = true then
			errStr = errStr & "You cannot delete this project because it contains experiments.  Please remove experiments from the project and try again."&vbcrlf
		end if
		rec.close
		Set rec = Nothing
		
		hasNBLinks = false
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM linksProjectNotebooks WHERE projectId="&SQLClean(projectId,"N","S")
		rec.open strQuery,conn,3,3
		Do While Not rec.eof
			notebookId = rec("notebookId")
			Set subrec = server.CreateObject("ADODB.RecordSet")
			substrQuery = "SELECT * FROM notebooks WHERE id="&SQLClean(notebookId,"N","S")
			subrec.open substrQuery,conn,3,3
			Do While Not subrec.eof
				visible = subrec("visible")
				if visible = 1 then
					hasNBLinks = true
				end if
				subrec.movenext
			loop
			subrec.close
			Set subrec = Nothing
			
			rec.movenext
		loop
		rec.close
		Set rec = Nothing
		if hasNBLinks = true then
			errStr = errStr & "You cannot delete this project because it contains notebooks.  Please remove notebooks from the project and try again."&vbcrlf
		end if


		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM linksProjectReg WHERE projectId="&SQLClean(projectId,"N","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			errStr = errStr & "You cannot delete this project because it contains registration items.  Please remove registration items from the project and try again."&vbcrlf
		End If
		rec.close
		Set rec = Nothing
		

		Call disconnect
	End if
	'If isNotebookShared(notebookId) Then
	'	errStr = "You cannot delete this project because it is currently shared"
	'End If

	If errStr = "" then
		Call getconnectedadm
		strQuery = "UPDATE projects SET visible=0 WHERE id="&SQLClean(projectId,"N","S")
		connAdm.execute(strQuery)
		strQuery = "DELETE FROM projectInvites WHERE projectId="&SQLClean(projectId,"N","S")
		connAdm.execute(strQuery)
		strQuery = "DELETE FROM groupProjectInvites WHERE projectId="&SQLClean(projectId,"N","S")
		connAdm.execute(strQuery)
	Else
		response.write(errStr)
	End If
End if
%>