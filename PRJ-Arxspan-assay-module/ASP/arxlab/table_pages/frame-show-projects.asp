<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "show-notebooks"
subsectionId = "show-notebooks"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "tool"
%>

<%
If request.querystring("d") = "" Then
	sortDir = "DESC"
Else
	d = request.querystring("d")
	If d = "ASC" Then
		sortDir = "ASC"
	Else
		sortDir = "DESC"
	End if
End If

If request.querystring("s") = "" Then
	sortBy = "lastViewed"
Else
	s = request.querystring("s")
	If s = "name" Or s="description" Or s="creator" Or s="lastViewed" Then
		sortBy = s
		If s="creator" Then
			sortBy = "fullName"
		End if
	Else
		sortBy = "lastViewed"
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
strQuery = "SELECT DISTINCT projectId,userId,name,visible,lastViewed,description,fullName FROM allProjectPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and (accepted=1 or accepted is null) and parentProjectId is NULL "
If request.querystring("groupId") <> "" Then
	strQuery = strQuery & "AND groupId="&SQLClean(request.querystring("groupId"),"N","S")& " "
End if
q = Trim(request.querystring("q"))
If q <> "" Then
	strQuery = strQuery & "AND (fullName like "&SQLClean(q,"L","S")&" OR name like "&SQLClean(q,"L","S")&" OR description like "&SQLClean(q,"L","S")&") "
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
<h1>Projects</h1><br/>
<%If request.querystring("groupId") = "" then%>
<form action="frame-show-projects.asp" method="get">
<input type="text" name="q" id="q" value="<%=request.querystring("q")%>" style="display:inline;margin-right:10px;">
<input type="submit" value="Search" style="display:inline;font-size:12px;padding:2px;">
</form>
<br/>
<%End if%>
<table class="experimentsTable">
	<tr>
		<th>
		</th>
		<th>
			<%
			sortHref = "frame-show-projects.asp?groupId="&request.querystring("groupId")&"&s=name"
			If sortBy = "name" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "name" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Name</a>
			<%If sortBy = "name" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "frame-show-projects.asp?groupId="&request.querystring("groupId")&"&s=description"
			If sortBy = "description" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "description" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Description</a>
			<%If sortBy = "description" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "frame-show-projects.asp?groupId="&request.querystring("groupId")&"&s=creator"
			If s = "creator" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If s = "creator" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink"><%=creatorLabel%></a>
			<%If s = "creator" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "frame-show-projects.asp?groupId="&request.querystring("groupId")&"&s=lastViewed"
			If sortBy = "lastViewed" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "lastViewed" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink"><%=lastViewedLabel%></a>(<%If session("useGMT") then%><%="GMT"%><%else%><script type="text/javascript">document.write((new Date()).format("Z"));</script><%End if%>)
			<%If sortBy = "lastViewed" then%>
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
			<td class="experimentCell">
				<a href="<%=mainAppPath%>/show-project.asp?id=<%=rec("projectId")%>" onclick="parent.location.href=this.href"><%=rec("name")%></a>
			</td>
			<td class="statusCell">
				<%=maxChars(rec("description"),80)%>
			</td>
			<td class="submittedCell">
				<%=rec("fullName")%>
			</td>
			<td id="<%=counter%>_rec_date" class="updatedCell">
				<script>setElementContentToDateString("<%=counter%>_rec_date", "<%=rec("lastViewed")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
			</td>
		</tr>
	<%
	rec.movenext
End if
Next
%>


<%
hrefStr = "frame-show-projects.asp?id="&projectId&"&rpp="&resultsPerPage&"&s="&sortBy&"&d="&sortDir&"&q="&q&"&groupId="&request.querystring("groupId")
%>
		<tr>
		<td colspan="7" align="right">	
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