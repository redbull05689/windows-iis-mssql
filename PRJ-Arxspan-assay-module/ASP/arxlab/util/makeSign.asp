<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->

<%
if session("email") = "support@arxspan.com" then

	if request.form("submitIt") <> "" Then
		Call getconnectedadm
		a = savePDF(request.form("experimentType"),request.form("experimentId"),request.form("revisionNumber"),true,false,false)
		Call disconnectadm
	end if
%>
	<form action="makeSign.asp" method="POST">
		experimentType<br/>
		<input type="text" name="experimentType"><br/>
		experimentId<br/>
		<input type="text" name="experimentId"><br/>
		revisionNumber<br/>
		<input type="text" name="revisionNumber"><br/>
		<input type="submit" name="submitIt">
	</form>
<%
end if
%>