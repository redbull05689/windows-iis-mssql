<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
call getconnectedadm
strQuery = "DELETE FROM experimentFavorites WHERE userId="&SQLClean(session("userId"),"N","S") & " AND experimentType=" & SQLClean(request.Form("experimentType"),"N","S") &" AND experimentId="&SQLClean(request.Form("experimentId"),"N","S")
connAdm.execute(strQuery)
call disconnectadm
%>