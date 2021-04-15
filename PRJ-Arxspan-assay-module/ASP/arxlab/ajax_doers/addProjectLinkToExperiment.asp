<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->
<%
'add a project link to an experiment
errorText = ""
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
projectId = request.querystring("projectId")

'get permissions flags
ownsExp = ownsExperiment(experimentType,experimentId,session("userId"))
experimentVisible = isExperimentVisible(experimentType,experimentId)
canWrite = canWriteProject(projectId,session("userId"))

If ownsExp And experimentVisible Then
	Call getConnectedAdm
	errorText = addExperimentToProject(connAdm, experimentType, experimentId, projectId, null, null)
	Call disconnectAdm
	If errorText = "" Then
		response.write("success")
	Else 
		response.write(errorText)
	End If 
Else
	'return no permission error
	response.write("An error occurred adding link to project.")
End If
%>
