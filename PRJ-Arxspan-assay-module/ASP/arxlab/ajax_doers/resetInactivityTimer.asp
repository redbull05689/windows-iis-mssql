<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
'resets inactivity time by setting the lastActivityTime column in the users row in the users table to the current time
call getconnectedadm
connAdm.execute("UPDATE users SET lastActivityTime=GETUTCDATE() WHERE id="&SQLClean(session("userId"),"N","S"))
call disconnectadm
%>