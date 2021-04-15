<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
response.redirect("index.asp?action=setAssayRunId&"&request.servervariables("QUERY_STRING"))
%>