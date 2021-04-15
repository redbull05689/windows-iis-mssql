<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
call getconnectedadm
strQuery = "UPDATE users SET defaultAddFromELNKeypath="&SQLClean(request.querystring("keyPath"),"T","S")&" WHERE id="&SQLClean(session("userId"),"N","S")
connAdm.execute(strQuery)
call disconnectadm
%>