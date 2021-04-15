<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
'switches chemistry experiment to no chemdraw version
'used when user does not have chemdraw installed or accessible
Do While session("noChemDraw") <> true
	session("noChemDraw") = true
	session("expPage") = "experiment_no_chemdraw.asp"
	session.Save()
Loop
%>
{}