<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "delete-user-data"
subsectionId = "delete-user-data"
%>
<!-- #include file="../_inclds/globals.asp"-->


<%
	If session("roleNumber") <> "0" Then
		response.redirect(loginScriptName)
	End if

	pageTitle = "Delete User Data"
%>
<%
If request.Form("sure") <> "" Then
	Call getconnectedAdm
	If request.Form("notebooks") = "on" Then
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM notebooks WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		rec.open strQuery,connAdm,3,3
		Do While Not rec.eof
			strQuery = "UPDATE notebookInvites SET denied=1,accepted=1 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE groupNotebookInvites SET denied=1,accepted=1 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE notebookIndex SET visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE experiments set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE experiments_history set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE bioExperiments set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE bioExperiments_history set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE freeExperiments set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE freeExperiments_history set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE analExperiments set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE analExperiments_history set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE custExperiments set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE custExperiments_history set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE allExperiments set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE allExperiments_history set visible=0 WHERE notebookId="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			strQuery = "UPDATE notebooks SET visible=0 WHERE id="&SQLClean(rec("id"),"N","S")
			connAdm.execute(strQuery)
			rec.movenext
		Loop
		rec.close
		Set rec = Nothing
	End If
	If request.Form("experiments") = "on" Then
		strQuery = "UPDATE notebookIndex SET visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE experiments set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE experiments_history set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE bioExperiments set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE bioExperiments_history set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE freeExperiments set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE freeExperiments_history set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE analExperiments set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE analExperiments_history set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE custExperiments set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE custExperiments_history set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE allExperiments set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE allExperiments_history set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
	End If
	If request.Form("projects") = "on" Then
		strQuery = "UPDATE projects set visible=0 WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE projectInvites SET denied=1,accepted=1 WHERE sharerId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE groupProjectInvites SET denied=1,accepted=1 WHERE sharerId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
	End If
	If request.Form("groups") = "on" Then
		strQuery = "DELETE FROM groupMembers WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
	End If
	If request.Form("notifications") = "on" Then
		strQuery = "DELETE FROM notifications WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
	End If
	If request.Form("recentlyViewedExperiments") = "on" Then
		strQuery = "DELETE FROM recentlyViewedExperiments WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
	End If
	If request.Form("recentlyViewedNotebooks") = "on" Then
		strQuery = "DELETE FROM recentlyViewedNotebooks WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
	End If
	If request.Form("recentlyViewedProjects") = "on" Then
		strQuery = "DELETE FROM recentlyViewedProjects WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
	End If
	If request.Form("watchlist") = "on" Then
		strQuery = "DELETE FROM experimentFavorites WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
	End If
	If request.Form("otherNotifications") = "on" Then
		strQuery = "DELETE FROM experimentSavedNotifications WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "DELETE FROM commentNotifications WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "DELETE FROM noteAddedNotifications WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "DELETE FROM attachmentAddedNotifications WHERE userId="&SQLClean(request.Form("userId"),"N","S")
		connAdm.execute(strQuery)
	End if
	Call disconnectAdm
End if
%>


	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	

<h1>Clear User Data</h1>
<ul>
<%
companyId = request.querystring("companyId")
If request.Form("sure") = "" then
	If companyId = "" then
		Call getconnected
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM companies ORDER BY name"
		rec.open strQuery,conn,3,3
		Do While Not rec.eof
			%>
				<li><a href="<%=mainAppPath%>/admin/delete-userData.asp?companyId=<%=rec("id")%>"><%=rec("name")%></a></li>
			<%
			rec.movenext
		Loop
		rec.close
		Set rec = Nothing
		Call disconnect
	%>

	<%
	Else
		If request.querystring("userId") = "" then
			usersTable = getDefaultSingleAppConfigSetting("usersTable")
			Call getconnected
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM "&usersTable&" WHERE companyId="&SQLClean(companyId,"N","S")& " ORDER BY firstName,lastName"
			rec.open strQuery,conn,3,3
			Do While Not rec.eof
				%>
					<li><a href="<%=mainAppPath%>/admin/delete-userData.asp?companyId=<%=companyId%>&userId=<%=rec("id")%>"><%=rec("firstName")%>&nbsp;<%=rec("lastName")%></a></li>		
				<%
				rec.movenext
			Loop
			rec.close
			Set rec = Nothing
			Call disconnect
		Else
			%>
				<form method="post" action="<%=mainAppPath%>/admin/delete-userData.asp?companyId=<%=companyId%>&userId=<%=request.querystring("userId")%>">
					<input type="checkbox" name="notebooks" style="display:inline;">&nbsp;Notebooks<br/>
					<input type="checkbox" name="experiments" style="display:inline;">&nbsp;Experiments<br/>
					<input type="checkbox" name="projects" style="display:inline;">&nbsp;Projects<br/>
					<input type="checkbox" name="groups" style="display:inline;">&nbsp;Groups<br/>
					<input type="checkbox" name="notifications" style="display:inline;">&nbsp;Notifications<br/>
					<input type="checkbox" name="recentlyViewedExperiments" style="display:inline;">&nbsp;Recently Viewed Experiments<br/>
					<input type="checkbox" name="recentlyViewedNotebooks" style="display:inline;">&nbsp;Recently Viewed Notebooks<br/>
					<input type="checkbox" name="recentlyViewedProjects" style="display:inline;">&nbsp;Recently Viewed Projects<br/>
					<input type="checkbox" name="watchlist" style="display:inline;">&nbsp;Watchlist<br/>
					<input type="checkbox" name="otherNotifications" style="display:inline;">&nbsp;Other Notifications<br/>
					<input type="hidden" name="userId" value="<%=request.querystring("userId")%>">
					<input type="submit" name="sure" value="ARE YOU REALLY REALLY SURE?" style="padding:2px;" onclick="return confirm('really really really sure?')">
				</form>
			<%
		End if
	%>
	<%
	End if
Else
	If errorStr = "" then
		response.write("<p>User Data Deleted</p>")
	Else
		response.write("<p>"&errorStr&"</p>")
	End if
End if
%>
</ul>

<!-- #include file="../_inclds/footer-tool.asp"-->