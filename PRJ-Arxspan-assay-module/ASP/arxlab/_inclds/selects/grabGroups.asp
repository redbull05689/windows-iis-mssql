
 <!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../globals.asp"-->

<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<!-- #include virtual="/arxlab/_inclds/selects/fnc_groupSelectQuery.asp" -->

	<%
    Response.write(getGroups())
    response.end
	%>