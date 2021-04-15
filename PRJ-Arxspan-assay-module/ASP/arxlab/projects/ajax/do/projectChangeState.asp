<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
projectId = request.querystring("projectId")
notebookId = request.querystring("notebookId")
state = request.querystring("state")
Call getconnectedadm
strQuery = "DELETE FROM projectStates WHERE userId="&SQLClean(session("userId"),"N","S")& " AND projectId="&SQLCLean(projectId,"N","S")& " AND notebookId="&SQLCLean(notebookId,"N","S")
connAdm.execute(strQuery)
strQuery = "INSERT INTO projectStates(userId,projectId,notebookId,state) values("&SQLClean(session("userId"),"N","S")& ","&SQLCLean(projectId,"N","S")& ","&SQLCLean(notebookId,"N","S")&","&SQLClean(state,"N","S")&")"
connAdm.execute(strQuery)
Call disconnectAdm
%>