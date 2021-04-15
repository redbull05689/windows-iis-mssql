<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
call getconnectedAdm
strQuery = "UPDATE commentNotifications set dismissed=1 WHERE experimentType="&SQLClean(request.querystring("experimentType"),"N","S")& " AND experimentId="&SQLClean(request.querystring("experimentId"),"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND (dismissed=0 or dismissed is null)"
connAdm.execute(strQuery)
call disconnectAdm
%>