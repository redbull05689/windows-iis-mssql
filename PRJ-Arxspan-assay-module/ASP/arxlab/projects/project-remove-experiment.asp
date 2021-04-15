<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->

<%
projectId = request.querystring("projectId")
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
inframe = request.querystring("inframe")
rpp = request.querystring("rpp")
frameBG = request.querystring("frameBG")
fromExperiment = request.querystring("fromExperiment")

linkError = False
If session("requireProjectLink") Then
	notebookId = getNotebookId(experimentId,experimentType)
	numLinks = 0
	Set lRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT count(*) as count FROM linksProjectExperimentsView WHERE experimentId="&SQLClean(experimentId,"N","S")& " AND typeId="&SQLClean(experimentType,"N","S")
	lRec.open strQuery,conn,3,3,1
	numLinks = numLinks + lRec("count")
	lRec.close
	Set lRec = nothing
	Set lRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT count(*) as count FROM linksProjectNotebooksView WHERE notebookId="&SQLClean(notebookId,"N","S")
	lRec.open strQuery,conn,3,3,1
	numLinks = numLinks + lRec("count")
	Call disconnect
	If numLinks <= 1 Then
		linkError = True
	End If
End if

closedError = false
'If isExperimentClosed(experimentType,experimentId) Then
	'closedError = True
'End if

call getconnectedAdm
if (ownsProject(projectId) Or canWriteProject(projectId,session("userId"))) And Not linkError And Not closedError then
	Call removeExperimentFromProject(connAdm, experimentType, experimentId, projectId)
end if

Set tRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT parentProjectId FROM projects WHERE id=" & SQLClean(projectId,"N","S")
tRec.open strQuery,connAdm,3,3
If Not tRec.eof Then
	If fromExperiment = "1" Then
		If linkError then
			%>
			<script type="text/javascript">
				try{
					window.parent.document.getElementById("projectList_<%=projectId%>").style.display = "block";
				}catch(err){}
				window.parent.alert("Experiment is required to have at least one project link.")
				window.parent.reloadSubmitFrame();
			</script>
			<%
		End if
	else
		If linkError Then
			message = "&message="&server.urlEncode("Experiment is required to have at least one project link.")
		End if
		If closedError Then
			message = "&message="&server.urlEncode("Cannot remove link from closed experiment.")
		End if
		If inframe = "true" Then
			response.redirect(mainAppPath&"/table_pages/frame-show-experiments.asp?id="&projectId&"&inframe=true&rpp="&rpp&"&frameBG="&frameBG&message)
		End if
		If Not IsNull(tRec("parentProjectId")) Then
			response.redirect(mainAppPath&"/show-project.asp?id="&tRec("parentProjectId")&"&inframe=true"&message)
		Else
			response.redirect(mainAppPath&"/show-project.asp?id="&projectId&message)
		End if
	End if
End If
call disconnectAdm
%>