<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../_inclds/misc/functions/fnc_ipsFromRange_local.asp"-->
<%server.scripttimeout = 1000%>
<%If session("companyId")=1 then%>
<%
if request.form("submit") <> "" then
	response.write(Replace(ipsFromRange(request.Form("ipRange")),",",",<br/>"))
end if
%>

<form method="post" action="ipRangeTest.asp">
<input type="text" name="ipRange" value="<%=request.Form("ipRange")%>" style="width:1000px;">
<input type="submit" name="submit" value="Get 'em">
</form>

<%End if%>