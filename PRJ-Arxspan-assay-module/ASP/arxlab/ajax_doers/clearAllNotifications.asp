<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<%
regEnabled = true
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
'clears of a users notification. i.e. sets their status to dismissed
call getconnectedAdm
strQuery = "UPDATE notifications SET dismissed=1 WHERE userId="&SQLClean(session("userId"),"N","S") & " AND dismissed=0"
connAdm.execute(strQuery)
Call disconnectAdm
%>