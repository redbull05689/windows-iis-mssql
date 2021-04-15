<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "show-userReport"
subsectionId = "show-userReport"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "tool"
%>

<%
If request.querystring("d") = "" Then
	If request.querystring("s") = "userName" Then
		sortDir = "ASC"
	else
		sortDir = "DESC"
	End if
Else
	d = request.querystring("d")
	If d = "ASC" Then
		sortDir = "ASC"
	Else
		sortDir = "DESC"
	End if
End If

If request.querystring("s") = "" Then
	sortBy = "userName"
Else
	s = request.querystring("s")
	If s = "userName" Or s="email" Or s="timeEnabled" Or s="timeDisabled"Then
		sortBy = s
	Else
		sortBy = "email"
	End if
End If
%><!-- #include virtual="/arxlab/_inclds/common/asp/saveTableSort.asp"--><%
Function inArr(str,a)
	inArr=False
	For q=0 To UBound(a)
		If Trim(CStr(a(q))) = Trim(CStr(str)) Then
			inArr = True
			Exit for
		End if
	next
End function
%>

<%
pageNum = request.querystring("pageNum")
If Not isInteger(pageNum) Then
	pageNum = 1
Else
	pageNum = CInt(pageNum)
End if

resultsPerPage = request.querystring("rpp")
If Not isInteger(resultsPerPage) Then
	resultsPerPage = 200
Else
	resultsPerPage = CInt(resultsPerPage)
End if

Call getconnected

%>


<%
If canSeeShowUserReport then
%>

<%
Set rec = server.CreateObject("ADODB.RecordSet")
rec.pageSize = resultsPerPage
rec.CacheSize = resultsPerPage
rec.CursorLocation = 3

strQuery = "SELECT * FROM billingReportsData WHERE email not like '%arxspan%' AND billingReportId="&SQLClean(request.querystring("reportId"),"N","S")
If request.querystring("strSearch") <> "" then
	strQuery = strQuery & " AND (userName like "&SQLClean(request.querystring("strSearch"),"L","S")&" or email like "&SQLClean(request.querystring("strSearch"),"L","S")&")"
End If
If request.querystring("activitySelect")="2" Then
	strQuery = strQuery & " AND (timeEnabled=0)"
End If
If request.querystring("activitySelect")="3" Then
	strQuery = strQuery & " AND (timeDisabled=0)"
End If
If request.querystring("activitySelect")="4" Then
	strQuery = strQuery & " AND (timeDisabled<>0 and timeEnabled<>0)"
End If
strQuery = strQuery & " ORDER BY "&sortBy& " " & sortDir
'response.write(strQuery)
rec.open strQuery,conn,0,1
counter = resultsPerPage * pageNum - resultsPerPage
If Not rec.eof then
	rec.absolutePage = pageNum
	eofFlag = False
Else
	eofFlag = True
End if
%>


<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<%If Not eofFlag then%>
<form action="show-userReportData.asp" method="get">
	<label for="strSearch">Text</label><br/>
	<input type="text" name="strSearch" id="strSearch" style="display:inline;" value="<%=request.querystring("strSearch")%>">
	<br/>
	<label for="activitySelect">Activity</label><br/>
	<select id="activitySelect" name="activitySelect">
		<option value="1"<%If request.querystring("activitySelect")="1" then%> SELECTED<%End if%>>Any</option>
		<option value="2"<%If request.querystring("activitySelect")="2" then%> SELECTED<%End if%>>Disabled Entire Period</option>
		<option value="3"<%If request.querystring("activitySelect")="3" then%> SELECTED<%End if%>>Active Entire Period</option>
		<option value="4"<%If request.querystring("activitySelect")="4" then%> SELECTED<%End if%>>Partially Active</option>
	</select><br/>
	<input type="hidden" name="reportId" value="<%=request.querystring("reportId")%>">
	<input type="submit" value="filter" style="margin-top:10px;">
</form>
<br/>
<%
hrefStr = "show-userReportData.asp?strSearch="&request.querystring("strSearch")&"&rpp="&resultsPerPage&"&activitySelect="&request.querystring("activitySelect")&"&reportId="&request.querystring("reportId")
%>
<table class="experimentsTable">
	<tr>
		<th>
		</th>
		<th>
			<%
			sortHref = hrefStr&"&s=email"
			If s = "email" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If s = "email" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Name</a>
			<%If s = "email" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = hrefStr&"&s=timeEnabled"
			If sortBy = "timeEnabled" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "timeEnabled" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Time Enabled</a>
			<%If sortBy = "timeEnabled" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = hrefStr&"&s=timeDisabled"
			If sortBy = "timeDisabled" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "timeDisabled" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Time Disabled</a>
			<%If sortBy = "timeDisabled" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			Extra Text
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
			<td class="statusCell">
				<%=rec("timeEnabled")%>
			</td>
			<td class="statusCell">
				<%=rec("timeDisabled")%>
			</td>
			<td class="statusCell">
				<%=rec("extraText")%>
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
hrefStr = "show-userReportData.asp?strSearch="&request.querystring("strSearch")&"&rpp="&resultsPerPage&"&s="&request.querystring("s")&"&d="&sortDir&"&activitySelect="&request.querystring("activitySelect")&"&reportId="&request.querystring("reportId")
%>
		<tr>
		<td <%If session("companyId")="1" then%>colspan="11"<%else%>colspan="7"<%End if%> align="right">	
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