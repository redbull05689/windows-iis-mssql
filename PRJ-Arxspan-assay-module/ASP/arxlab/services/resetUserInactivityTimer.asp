<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%isApiPage=true%>
<% Response.AddHeader "Access-Control-Allow-Origin", "*"%>
<%
If request.querystring("override") = "BROAD" Then
	session("overrideDB")="BROAD"
End if
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
call getconnectedadm
connAdm.execute("UPDATE users SET lastActivityTime=GETUTCDATE() WHERE id="&SQLClean(request.querystring("userId"),"N","S"))
call disconnectadm
%>