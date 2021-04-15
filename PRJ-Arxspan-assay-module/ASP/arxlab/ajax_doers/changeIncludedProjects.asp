<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->
<%
userId = session("userId")
projectId = request.querystring("id")
If ownsProject(projectId) Then
	' Disable all included Projects
	Call getconnectedAdm
	strUpdate = "UPDATE projectAutoLinks SET disabled=1 WHERE toProjectId=" & SQLClean(projectId,"N","S")
	connAdm.execute(strUpdate)

	' Detach all of the subprojects
	Set nRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM projects WHERE parentProjectId=" & SQLClean(projectId,"N","S")
	nRec.open strQuery,connAdm,3,3
	Do While Not nRec.eof
		strUpdate = "UPDATE projects SET includedFromProjectId=NULL where parentProjectId=" & SQLClean(projectId,"N","S") & " AND includedFromProjectId=" & SQLClean(nRec("id"),"N","S")
		nRec.movenext
	Loop
	nRec.close

	' Enable the ones we got from the client
	projectList = Split(request.querystring("data"), ",")
	for each project in projectList
		strQuery = "SELECT id, disabled FROM projectAutoLinks WHERE toProjectId=" & SQLClean(projectId,"N","S") & " AND fromProjectId=" & SQLClean(project,"N","S")
		nRec.open strQuery,connAdm,3,3
		If nRec.eof Then
			' If there is no record for this link yet, then insert one
			strInsert = "INSERT INTO projectAutoLinks (createdByUserId, fromProjectId, toProjectId, disabled) VALUES ("&SQLClean(userId,"N","S")&","&SQLClean(project,"T","S")&","&SQLClean(projectId,"N","S")&", 0)"
			connAdm.execute(strInsert)
		Else
			' There is already a link between these two projects in the database
			' If it is already enabled, don't do anything just leave it alone
			If nRec("disabled") = 1 Then
				' The existing record is disabled, so just re-enable it
				strUpdate = "UPDATE projectAutoLinks SET disabled=0 WHERE id=" & nRec("id")
				connAdm.execute(strUpdate)
			End If
		End If
		nRec.close
		
		'Pull in all of the records of the included project into this project
		Call initializeIncludedProject(projectId, project)
	next
	Call disconnectadm
	
	'This process can involve substantial changes to page content, so reload instead of ajax if we added projects into this one
	If UBound(projectList) > 0 Then
		response.redirect("../show-project.asp?id="&request.querystring("id"))
	Else
		response.write("success")
	End If
Else
	response.write("An error occurred updating included projects.")
End If
%>