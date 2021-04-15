<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->
<%
projectId = request.Form("projectId")
tabName = request.Form("tabName")
Call addTabToProject(projectId, tabName, "", Null)
response.redirect(mainAppPath&"/show-project.asp?id="&projectId)
%>