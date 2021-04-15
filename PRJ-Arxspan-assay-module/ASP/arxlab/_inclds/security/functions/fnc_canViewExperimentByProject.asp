<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function canViewExperimentByProject(experimentType,experimentId,userId)
	'determins whether or not the experiment is linked to a project that the user has read access to
	'view permission to a experiment are inherited through project permissions
	
	'get the projects that the experiment is linked to
	Set ttRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT projectId FROM linksProjectExperiments WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType="&SQLClean(experimentType,"N","S")
	ttRec.open strQuery,conn,3,3
	'loop through all the projects that the experiment is linked to 
	Do While Not ttRec.eof 
		'get the top level project id because that is where the permission are on 
		'the tabs are also project with a parentprojectid of the actual project
		Set tttRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT parentProjectId FROM projects WHERE id="&SQLClean(ttRec("projectId"),"N","S")
		tttRec.open strQuery,conn,3,3
		If Not tttRec.eof Then
			If Not IsNull(tttRec("parentProjectId")) then
				ppId = tttRec("parentProjectId")
			Else
				ppId = 0
			End if
		Else
			ppId = 0
		End If
		tttRec.close
		Set tttRec = nothing
		
		Set cgRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM projectInvitesView WHERE (projectId="&SQLClean(ttRec("projectId"),"N","S") & " or projectId="&SQLClean(ppId,"N","S")&") AND canRead=1 and shareeId=" & SQLClean(userId,"N","S")
		cgRec.open strQuery,conn,3,3
		If Not cgRec.eof Then
			'if the user has a usershare invute to the top level project then they can see the experiment
			canViewExperimentByProject = True
		End if
		cgRec.close
		Set cgRec = Nothing

		Set cgRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM projects WHERE (id="&SQLClean(ttRec("projectId"),"N","S") & " or id="&SQLClean(ppId,"N","S")&") AND userId=" & SQLClean(userId,"N","S")
		cgRec.open strQuery,conn,3,3
		If Not cgRec.eof Then
			'if the user owns the project they can see the experiment
			canViewExperimentByProject = True
		End if
		cgRec.close
		Set cgRec = Nothing
		
		Set cgRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM groupProjectPermView WHERE (projectId="&SQLClean(ttRec("projectId"),"N","S") & " or projectId="&SQLClean(ppId,"N","S")&") AND canRead=1 and userId=" & SQLClean(userId,"N","S")
		cgRec.open strQuery,conn,3,3
		If Not cgRec.eof Then
			'if the user is a member of a group that has a read invite to the project hen the user can see the experiment
			canViewExperimentByProject = True
		End if
		cgRec.close
		Set cgRec = nothing
		ttRec.movenext
	loop
end function
%>