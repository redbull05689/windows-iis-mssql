<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
regEnabled = true
%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
call getconnectedAdm
strQuery = "UPDATE notifications SET dismissed=1 WHERE userId="&SQLClean(session("userId"),"N","S") & " AND id="&SQLClean(request.querystring("id"),"N","S")
connAdm.execute(strQuery)
%>