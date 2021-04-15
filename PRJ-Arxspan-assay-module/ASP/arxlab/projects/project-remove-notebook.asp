<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->

<%
projectId = request.querystring("projectId")
notebookId = request.querystring("notebookId")

call getconnectedAdm
if ownsProject(projectId) Or canWriteProject(projectId,session("userId")) then
	Call removeNotebookFromProject(connAdm, notebookId, projectId)
end if

Set tRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT parentProjectId FROM projects WHERE id=" & SQLClean(projectId,"N","S")
tRec.open strQuery,connAdm,3,3
If Not tRec.eof then
	If Not IsNull(tRec("parentProjectId")) Then
		response.redirect(mainAppPath&"/show-project.asp?id="&tRec("parentProjectId"))
	Else
		response.redirect(mainAppPath&"/show-project.asp?id="&projectId)
	End if
End If
call disconnectAdm
%>