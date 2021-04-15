<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../globals.asp"-->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/selects/fnc_configsForExperimentTypes.asp" -->


<%
    ' sends out the result of calling the getProjects fnc within the projectSelectQuery fnc
    Response.write(configsForExperimentTypes())
    Response.end
%>