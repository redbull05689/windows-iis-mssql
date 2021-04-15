<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%session.abandon%>
<%
response.charset = "UTF-8"
response.codePage = 65001
projectId = request.querystring("projectId")
cdId = request.querystring("cdId")
%>
<%isApiPage=True%>
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include file="../_inclds/projects/functions/fnc_addProjectRegLink.asp"-->
<%
call getconnected
call getconnectedAdm
a = addProjectRegLink(cdId,projectId)
call disconnectAdm
call disconnect
%>
