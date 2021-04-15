<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout = 180000000%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_getExperimentStatus.asp" -->
<%


if session("email")="support@arxspan.com" then
	if request.form("submitIt") <> "" Then
		if request.form("OverrideDB") <> "" then
			session("overrideDB") = request.form("OverrideDB")
		end if
		loginUser(request.Form("userId"))

		Response.Redirect mainAppPath & "/dashboard.asp"
	end if
%>
	<form action="impersonate.asp" method="POST">
		User ID:<br/>
		<input type="text" name="userId"><br/>
		OverrideDB (optional):</br>
		<input type="text" name="OverrideDB"><br/>
		<input type="submit" name="submitIt">
	</form>


<%
end if
%>