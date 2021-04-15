<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=True%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->

<%
projectId = request.querystring("projectId")
cd_id = request.querystring("cd_id")

call getconnectedAdm
if ownsProject(projectId) Or canWriteProject(projectId,session("userId")) then
	Call removeRegIdFromProject(connAdm, cd_id, projectId)
end if

'Set tRec = server.CreateObject("ADODB.RecordSet")
'strQuery = "SELECT * FROM projects WHERE id=" & SQLClean(projectId,"N","S")
'tRec.open strQuery,connAdm,3,3
'If Not tRec.eof then
'	If Not IsNull(tRec("parentProjectId")) Then
'		response.redirect(mainAppPath&"/show-project.asp?id="&tRec("parentProjectId")&"&inframe=true")
'	Else
'		response.redirect(mainAppPath&"/show-project.asp?id="&projectId)
'	End if
'End If
call disconnectAdm
%>