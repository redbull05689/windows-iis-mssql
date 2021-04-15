<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
Call getconnectedAdm
strQuery = "DELETE FROM experimentFavorites WHERE userId="&SQLClean(session("userId"),"N","S")& " AND id="&SQLClean(request.querystring("id"),"N","S")
connAdm.execute(strQuery)
Call disconnectAdm
%>