<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%subSectionId= request.querystring("subSectionId")%>
<%If subSectionId="force-change-password" then
	response.end
End if%>
<%regEnabled=true%>
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<%
Set navProjectRec = server.CreateObject("ADODB.Recordset")
strQuery = "select top 6 u.fullName, p.description, p.id as projectId, p.name, v.theDate as lastViewed from projects p inner join usersView u on p.userId=u.id inner join recentlyViewedProjects v on v.projectId=p.id and v.userId=" & SQLClean(session("userId"),"N","S") & " where p.id in("
strQuery = strQuery & "select distinct projectId FROM allProjectPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and (accepted=1 or accepted is null) and parentProjectId is NULL)"
sortBy = "recentlyViewed"
If userOptions.exists("leftNavSort") Then
	sortBy = userOptions.Get("leftNavSort")
End If
Select Case sortBy
	Case "recentlyViewed"
		orderStr = "lastViewed DESC"
	Case "dateCreated"
		orderStr = "projectId DESC"
End Select
strQuery = strQuery & " ORDER BY "&orderStr
navProjectRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
%>
<ul>
	<%
	counter = 0
	Do While Not navProjectRec.eof And counter <5
		counter = counter + 1
		%>
			<li>
			<a href="<%=mainAppPath%>/show-project.asp?id=<%=navProjectRec("projectId")%>"<%If CStr(projectId)=CStr(navProjectRec("projectId")) then%> class="navSelected"<%End if%> title="<%=displayToolTip(navProjectRec("description"), navProjectRec("fullName"))%>" ><%=navProjectRec("name")%></a></li>
		<%
		navProjectRec.movenext
	Loop
	navProjectRec.close
	Set navProjectRec = nothing
	%>
</ul>

<%If counter = 5 Then%>
	<div class="navSectionFooter navFooter"><a style="font-weight: bold;" href="<%=mainAppPath%>/table_pages/show-projects.asp"><%=UCase(viewAllLabel)%> >></a></div>
<%End if%>