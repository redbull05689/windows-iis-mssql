<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "show-logHungSave"
subsectionId = "show-logHungSave"
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
	sortBy = "id"
Else
	s = request.querystring("s")
	If s = "userName" Or s="companyName" Or s="action" Or s="ipAddress" Or s="theDate" Then
		sortBy = s
		If s="userName" Then
			sortBy = "fullName"
		End if
	Else
		sortBy = "id"
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
	resultsPerPage = 40
Else
	resultsPerPage = CInt(resultsPerPage)
End if

Call getconnected

%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	


<%
If session("roleNumber")<=1 And session("companyId")="1" then
%>

<%
Set rec = server.CreateObject("ADODB.RecordSet")
rec.pageSize = resultsPerPage
rec.CacheSize = resultsPerPage
rec.CursorLocation = 3

strQuery = "SELECT * FROM hungSaveView WHERE 1=1 AND firstTimeout=1"
If request.querystring("strSearch") <> "" then
	strQuery = strQuery & " AND (companyName like "&SQLClean(request.querystring("strSearch"),"L","S")&" OR fullName like "&SQLClean(request.querystring("strSearch"),"L","S")&")"
End If
If request.querystring("onlynonCompleted")="on" Then
	strQuery = strQuery & " AND saveCompleted=0"
End if
If request.querystring("groupSelect") <> "" Then
	If request.querystring("groupSelect") <> "0" then
		idStr = "(-1,"
		Call getconnected
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery2 = "SELECT * FROM groupMembers WHERE groupId="&SQLClean(request.querystring("groupSelect"),"N","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
		rec2.open strQuery2,conn,3,3
		Do While Not rec2.eof
			idStr = idStr & rec2("userId")
			rec2.movenext
			If Not rec2.eof Then
				idStr = idStr & ","
			End if
		loop
		Call disconnect
		idStr = idStr & ")"
		strQuery = strQuery & " AND userId in "&idStr 
	End if
End if
If session("companyId") <> "1" Then
	strQuery = strQuery &" AND companyId="&SQLClean(session("companyId"),"N","S")
End if
strQuery = strQuery & " ORDER BY "&sortBy& " " & sortDir
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
<form action="show-logHungSave.asp" method="get">
	<label for="groupSelect">Group</label>
	<select id="groupSelect" name="groupSelect">
	<option value="0">Any</option>
<%
	Call getconnected
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM groups WHERE companyId="&SQLClean(session("companyId"),"N","S")
	rec2.open strQuery,conn,3,3
	Do While Not rec2.eof
		%>
			<option value="<%=rec2("id")%>" <%If CStr(request.querystring("groupSelect"))=CStr(rec2("id")) then%>SELECTED<%End if%>><%=rec2("name")%></option>
		<%
		rec2.movenext
	loop
	Call disconnect
%>
	</select>
	<br/>
	<label for="strSearch">Text</label>
	<input type="text" name="strSearch" id="strSearch" style="display:inline;" value="<%=request.querystring("strSearch")%>">
	<br/>
	<label for="onlynonCompleted">Show only non-completed</label>
	<input type="checkbox" name="onlynonCompleted" id="onlynonCompleted" style="display:inline;" <%If request.querystring("onlynonCompleted")="on" then%>checked<%End if%>>
	<br/>
	<input type="submit" value="filter" style="display:inline;margin-left:10px;">
</form>
<br/>
<table class="experimentsTable">
	<tr>
		<th>
		</th>
		<th>
			<%
			sortHref = "show-logHungSave.asp?s=userName"
			If s = "userName" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If s = "userName" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Name</a>
			<%If s = "userName" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "show-logHungSave.asp?s=companyName"
			If sortBy = "companyName" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "companyName" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Company Name</a>
			<%If sortBy = "companyName" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			Experiment
		</th>
		<th>
			<%
			sortHref = "show-logHungSave.asp?s=ipAddress"
			If sortBy = "ipAddress" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "ipAddress" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">IP</a>
			<%If sortBy = "ipAddress" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "show-logHungSave.asp?s=theDate"
			If sortBy = "theDate" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "theDate" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Date</a>
			<%If sortBy = "theDate" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			10 sec+
		</th>
		<th>
			30 sec+
		</th>
		<th>
			save completed
		</th>
		<th>
			serial
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
			<td class="statusCell">
				<a href="<%=mainAppPath%>/table_pages/show-userActivityRecentlyViewedExperiments.asp?id=<%=rec("userId")%>"><%=rec("email")%></a>
			</td>
			<td class="statusCell" style="width:140px;">
				<%=rec("companyName")%>
			</td>
			<td class="statusCell">
				<%
				prefix = GetPrefix(rec("experimentType"))
				expPage = GetExperimentPage(prefix)

				abbrv = GetAbbreviation(rec("experimentType"))

				actionHref = mainAppPath & "/" & expPage &"?id="&rec("experimentId")
				experimentTypeText = CapitalizeFirstLetter(abbrv)

				%>
				<a href="<%=actionHref%>"><%=experimentTypeText%>&nbsp;<%=rec("experimentId")%></a>
			</td>
			<td class="statusCell">
				<%=rec("ipAddress")%>
			</td>
			<td class="statusCell">
				<%=rec("theDate")%>
			</td>
			<td>
				<%=rec("firstTimeout")%>
			</td>
			<td>
				<%=rec("secondTimeout")%>
			</td>
			<td>
				<%=rec("saveCompleted")%>
			</td>
			<td>
				<%=rec("serial")%>&nbsp;<%=rec("actionId")%>
			</td>
		</tr>
	<%
	'rec2.close
	'Set rec2 = nothing
	rec.movenext
End if
Next
%>


<%
hrefStr = "show-logHungSave.asp?strSearch="&request.querystring("strSearch")&"&rpp="&resultsPerPage&"&s="&request.querystring("s")&"&d="&sortDir&"&groupSelect="&request.querystring("groupSelect")&"&onlynonCompleted="&request.querystring("onlynonCompleted")
%>
		<tr>
		<td colspan="10" align="right">	
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
<%End if%>
<!-- #include file="../_inclds/common/html/submitFrame.asp"-->
<!-- #include file="../_inclds/footer-tool.asp"-->