 <!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../globals.asp"-->

<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<!-- #include virtual="/arxlab/_inclds/selects/fnc_configToLoadDefaultExperiments.asp" -->

<%
    Response.write(configsForExperimentTypes())
    response.end
%>