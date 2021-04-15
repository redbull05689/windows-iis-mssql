<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
projectId = request.querystring("projectId")
tabId = request.querystring("tabId")
Call getconnectedadm
strQuery = "DELETE FROM projectTabStates WHERE userId="&SQLClean(session("userId"),"N","S")& " AND projectId="&SQLCLean(projectId,"N","S")
connAdm.execute(strQuery)
strQuery = "INSERT INTO projectTabStates(userId,projectId,tabId) values("&SQLClean(session("userId"),"N","S")& ","&SQLCLean(projectId,"N","S")& ","&SQLClean(tabId,"N","S")&")"
connAdm.execute(strQuery)
Call disconnectAdm
%>