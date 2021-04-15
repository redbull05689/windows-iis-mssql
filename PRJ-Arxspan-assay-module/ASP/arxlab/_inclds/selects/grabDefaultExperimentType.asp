<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../globals.asp"-->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<%
    Response.write(session("defaultExperimentType"))
    Response.end
%>