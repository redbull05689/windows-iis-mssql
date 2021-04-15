<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%subSectionId= request.querystring("subSectionId")%>
<%If subSectionId="force-change-password" then
	response.end
End if%>
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<div id="navMyNotebooks" <%If userOptions.Get("navSharedNotebooks") then%>style="display:none;"<%End if%>>
	<%
	' Notes about this query: userId on this view is how has permissions.  creatorId is the person who created the notebook
	strQuery = "select fullName,description,notebookId,name,lastViewed,creatorId FROM allNotebookPermViewWithInfo WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and (accepted=1 or accepted is null) GROUP BY fullName,description,notebookId,name,lastViewed,creatorId"
		
	sortBy = "recentlyViewed"
	If userOptions.exists("leftNavSort") Then
		sortBy = userOptions.Get("leftNavSort")
	End If
	Select Case sortBy
		Case "recentlyViewed"
			orderStr = "lastViewed DESC"
		Case "dateCreated"
			orderStr = "notebookId DESC"
	End Select
		
	Set navNotebookRec = server.CreateObject("ADODB.Recordset")
	navNotebookRec.CursorLocation = adUseClient
	navNotebookRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
	navNotebookRec.Sort = orderStr
	%>
	<ul>
		<%
		counter = 0	
		Do While Not navNotebookRec.eof And counter <5
			If navNotebookRec("creatorId") = session("userId") Then				
				counter = counter + 1				
				%>
					<li><a title="<%=displayToolTip(navNotebookRec("description"), navNotebookRec("fullName"))%>" href="<%=mainAppPath%>/show-notebook.asp?id=<%=navNotebookRec("notebookId")%>"<%If CStr(notebookId)=CStr(navNotebookRec("notebookId")) then%> class="navSelected"<%End if%>><%=navNotebookRec("name")%></a></li>
				<%
			End If
			navNotebookRec.movenext
		Loop
		navNotebookRec.movefirst
		%>

	</ul>
	<%If session("roleNumber") <= 1 then%>
		<div class="navSectionFooter navFooter">
			<a style="font-weight: bold;" href="<%=mainAppPath%>/table_pages/show-notebooks.asp?all=true&m=y"><%=UCase(viewAllLabel)%> >></a>
		</div>
	<%else%>
		<%If counter = 5 Then%>
			<div class="navSectionFooter navFooter">
				<a style="font-weight: bold;" href="<%=mainAppPath%>/table_pages/show-notebooks.asp?m=y"><%=UCase(viewAllLabel)%> >></a>
			</div>
		<%End if%>
	<%End if%>
</div>
<div id="navSharedNotebooks" <%If Not userOptions.Get("navSharedNotebooks") then%>style="display:none;"<%End if%>>
	<ul>
		<%
		counter = 0		
		Do While Not navNotebookRec.eof And counter <5
			If navNotebookRec("creatorId") <> session("userId") Then				
				counter = counter + 1				
				%>
					<li><a title="<%=displayToolTip(navNotebookRec("description"), navNotebookRec("fullName"))%>" href="<%=mainAppPath%>/show-notebook.asp?id=<%=navNotebookRec("notebookId")%>"<%If CStr(notebookId)=CStr(navNotebookRec("notebookId")) then%> class="navSelected"<%End if%>><%=navNotebookRec("name")%></a></li>
				<%
			End If
			navNotebookRec.movenext
		Loop
		navNotebookRec.close
		Set navNotebookRec = Nothing
		%>

	</ul>
	<%If session("roleNumber") <= 1 then%>
		<div class="navSectionFooter navFooter">
			<a style="font-weight: bold;" href="<%=mainAppPath%>/table_pages/show-notebooks.asp?all=true&m=n"><%=UCase(viewAllLabel)%> >></a>
		</div>
	<%else%>
		<%If counter = 5 Then%>
			<div class="navSectionFooter navFooter">
				<a style="font-weight: bold;" href="<%=mainAppPath%>/table_pages/show-notebooks.asp?m=n"><%=UCase(viewAllLabel)%> >></a>
			</div>
		<%End if%>
	<%End if%>
</div>