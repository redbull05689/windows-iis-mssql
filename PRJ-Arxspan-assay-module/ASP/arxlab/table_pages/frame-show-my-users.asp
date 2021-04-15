<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
regEnabled = true
sectionId = "frame-show-my-users.asp"
subsectionId = "frame-show-my-users.asp"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "tool"
%>

<%
If request.querystring("d") = "" Then
	sortDir = "ASC"
Else
	d = request.querystring("d")
	If d = "ASC" Then
		sortDir = "ASC"
	Else
		sortDir = "DESC"
	End if
End If

If request.querystring("s") = "" Then
	sortBy = "fullName"
Else
	s = request.querystring("s")
	If s = "fullName" Or s="email" Or s="roleName" Then
		sortBy = s
	Else
		sortBy = "fullName"
	End if
End If
%>
<!-- #include virtual="/arxlab/_inclds/common/asp/saveTableSort.asp"-->
<%
pageNum = request.querystring("pageNum")
If Not isInteger(pageNum) Then
	pageNum = 1
Else
	pageNum = CInt(pageNum)
End if

resultsPerPage = request.querystring("rpp")
If Not isInteger(resultsPerPage) Then
	resultsPerPage = 30
Else
	resultsPerPage = CInt(resultsPerPage)
End if

%>
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<%
'get notebook Id it is used everywhere
	Call getconnected

	pageTitle = "Notebooks"
%>
	<!-- #include file="../_inclds/frame-header-tool.asp"-->
	<!-- #include file="../_inclds/frame-nav_tool.asp"-->
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	


<script type="text/javascript" src="<%=mainAppPath%>/js/showTR.js"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/parseRXN.js"></script>

<%
Call getconnected


Set rec = server.CreateObject("ADODB.RecordSet")
rec.pageSize = resultsPerPage
rec.CacheSize = resultsPerPage
rec.CursorLocation = 3
strQuery = "SELECT id, fullName, email, roleName FROM usersView WHERE userAdded="&SQLClean(session("userId"),"N","S")&" and enabled=1 "
q = Trim(request.querystring("q"))
If q <> "" Then
	strQuery = strQuery & "AND (fullName like "&SQLClean(q,"L","S")&" OR email like "&SQLClean(q,"L","S")&" OR roleName like "&SQLClean(q,"L","S")&") "
End if
strQuery = strQuery & "ORDER BY "&Replace(sortBy,"'","")& " " & Replace(sortDir,"'","")
rec.open strQuery,conn,0,1
counter = resultsPerPage * pageNum - resultsPerPage
If Not rec.eof then
	rec.absolutePage = pageNum
	eofFlag = False
Else
	eofFlag = True
End if

%>
<%If Not eofFlag then%>
<h1><%=myUsersLabel%></h1><br/>
<%If request.querystring("groupId") = "" And request.querystring("userId") = "" then%>
<form action="frame-show-my-users.asp" method="get">
<input type="text" name="q" id="q" value="<%=request.querystring("q")%>" style="display:inline;margin-right:10px;">
<input type="submit" value="Search" style="display:inline;font-size:12px;padding:2px;">
</form>
<br/>
<%End if%>
<table class="experimentsTable"">
	<tr>
		<th>
		</th>
		<th>
			<%
			sortHref = "frame-show-my-users.asp?s=fullName"
			If sortBy = "fullName" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "fullName" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Name</a>
			<%If sortBy = "fullName" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "frame-show-my-users.asp?s=email"
			If sortBy = "email" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "email" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">email</a>
			<%If sortBy = "email" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "frame-show-my-users.asp?s=roleName"
			If s = "roleName" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If s = "roleName" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Role</a>
			<%If s = "roleName" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>

<%
For intRec = 1 To rec.pageSize
	If Not rec.eof then
	counter = counter + 1
	%>
		<tr>
			<td class="counterCell">
				<%=counter%>.
			</td>
			<td class="submittedCell">
				<a href="<%=mainAppPath%>/users/user-profile.asp?id=<%=rec("id")%>" onclick="parent.location.href=this.href"><%=rec("fullName")%></a>
			</td>
			<td class="statusCell">
				<%=rec("email")%>
			</td>
			<td class="statusCell">
				<%=rec("roleName")%>
			</td>
		</tr>
	<%
	rec.movenext
End if
Next
%>


<%
hrefStr = "frame-show-my-users.asp?id="&notebookId&"&rpp="&resultsPerPage&"&s="&sortBy&"&d="&sortDir&"&q="&q
%>
		<tr>
		<td colspan="4" align="right">	
	<%if pageNum > 1 then %>	
			<a href="<%=hrefStr & "&pageNum=1"%>"><img src="<%=mainAppPath%>/images/resultset_first.gif" alt="First" border="0"></a><a href="<%=hrefStr & "&pageNum=" & pageNum-1%>" title="Previous Page"><img src="<%=mainAppPath%>/images/resultset_previous.gif" alt="Previous" border="0"></A>
	<%end if
	if pageNum < rec.pageCount then%>
			<a href="<%=hrefStr & "&pageNum=" & pageNum + 1%>" title="Next Page"><img src="<%=mainAppPath%>/images/resultset_next.gif" border="0" alt="Next"></A><a href="<%=hrefStr & "&pageNum=" & rec.pageCount%>"><img src="<%=mainAppPath%>/images/resultset_last.gif" border="0" alt="Last"></a>	
	<%end if%>
		</td>
		</tr>

<%
rec.close()
Set rec = nothing
%>
</table>
<%End if%>


<!-- #include file="../_inclds/frame-footer-tool.asp"-->