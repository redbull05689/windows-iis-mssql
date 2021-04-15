<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
' This was set to 5 hours, but Amanda was not a fan of that, so we bumped it down to half an hour.
server.scriptTimeout = 1800
%>

<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/_inclds/common/asp/lib_JChem.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/lib_reg.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/fnc_sendProteinToSearchTool.asp" -->

<%
response.ContentType = "application/json"

If request.form("cdid")<>"" then
	if session("userId") = "2" Or session("email")="support@arxspan.com" or session("email") = "amanda.lashua@arxspan.com" then
		a = sendProteinToSearchTool(request.form("cdid"),true,true)
		response.write("{""cdid"": """ & request.form("cdid") & """}")			
	else
		response.status = "403"
		response.write "We don't trust you"
	end if
else
	response.status = "500"
	response.write "No CDID"
end If

%>