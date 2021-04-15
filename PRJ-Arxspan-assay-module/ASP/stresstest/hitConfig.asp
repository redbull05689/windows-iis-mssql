<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
    usersTable = getDefaultSingleAppConfigSetting("usersTable")
    response.write(usersTable)
%>