<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
call getconnectedadm
strQuery = "INSERT INTO experimentFavorites(userId,experimentType,experimentId) values("&_
	SQLClean(session("userId"),"N","S") & "," &_
	SQLClean(request.Form("experimentType"),"N","S") & "," &_
	SQLClean(request.Form("experimentId"),"N","S") & ")"
	connAdm.execute(strQuery)
call disconnectadm
%>