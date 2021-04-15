<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
'loop through for manually adding a result set for custom workflow with run id
response.redirect("index.asp?action=setAssayRunId&"&request.servervariables("QUERY_STRING"))
%>