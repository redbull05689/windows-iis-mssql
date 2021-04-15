<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "show-logLastLogin"
subsectionId = "show-logLastLogin"
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
sectionId = "tool"
%>

<%
logViewName = getDefaultSingleAppConfigSetting("logViewName")
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
	sortBy = "lastLoginDate"
Else
	s = request.querystring("s")
	If s = "fullName" Or s="companyName" Or s="email" Or s="lastLoginDate" Or s="ip" Then
		sortBy = s
	Else
		sortBy = "lastLoginDate"
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
	resultsPerPage = 100
Else
	resultsPerPage = CInt(resultsPerPage)
End if

Call getconnected
%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<%
If session("roleNumber")<=1 then
%>
<%
Set rec = server.CreateObject("ADODB.RecordSet")
rec.pageSize = resultsPerPage
rec.CacheSize = resultsPerPage
rec.CursorLocation = 3

' ######## LAST LOGIN QUERY ##############
strQuery = "select logV.lastLoginDate,logV2.ip,userV.* from (SELECT userId,MAX(dateSubmitted) as lastLoginDate from [LOGS].dbo."&logViewName&" WHERE actionId=10 group by userID) logV inner join (SELECT ip,dateSubmitted,userId as uid2 from [LOGS].dbo."&logViewName&") logV2 on logV.userId = logV2.uid2 and logV2.dateSubmitted = logV.lastLoginDate inner join usersView userV on userV.id = logV.userId WHERE  1=1"
If request.querystring("strSearch") <> "" then
	strQuery = strQuery & " AND (companyName like "&SQLClean(request.querystring("strSearch"),"L","S")&" or email like "&SQLClean(request.querystring("strSearch"),"L","S")&" or fullName like "&SQLClean(request.querystring("strSearch"),"L","S")&" or ip like "&SQLClean(request.querystring("strSearch"),"L","S")&")"
End If
If request.querystring("groupSelect") <> "" Then
	If request.querystring("groupSelect") <> "0" then
		idStr = "(-1,"
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
		idStr = idStr & ")"
		strQuery = strQuery & " AND userId in "&idStr 
	End if
End if
If session("companyId") <> "1" Then
	strQuery = strQuery &" AND companyId="&SQLClean(session("companyId"),"N","S")
End If

'response.write strQuery

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
<form action="show-logLastLogin.asp" method="get">
	<label for="groupSelect">Group</label>
	<select id="groupSelect" name="groupSelect">
	<option value="0">Any</option>
<%
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM groups WHERE companyId="&SQLClean(session("companyId"),"N","S")
	rec2.open strQuery,conn,3,3
	Do While Not rec2.eof
		%>
			<option value="<%=rec2("id")%>" <%If CStr(request.querystring("groupSelect"))=CStr(rec2("id")) then%>SELECTED<%End if%>><%=rec2("name")%></option>
		<%
		rec2.movenext
	loop
%>
	</select>
	<br/>
	<label for="strSearch">Text</label>
	<input type="text" name="strSearch" id="strSearch" style="display:inline;" value="<%=request.querystring("strSearch")%>">
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
			sortHref = "show-logLastLogin.asp?s=fullName"
			If s = "fullName" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If s = "fullName" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Name</a>
			<%If s = "fullName" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "show-logLastLogin.asp?s=companyName"
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
			<%
			sortHref = "show-logLastLogin.asp?s=email"
			If sortBy = "email" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "email" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Email</a>
			<%If sortBy = "email" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "show-logLastLogin.asp?s=ip"
			If sortBy = "ip" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "ip" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">IP</a>
			<%If sortBy = "ip" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "show-logLastLogin.asp?s=lastLoginDate"
			If sortBy = "lastLoginDate" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "lastLoginDate" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Date</a>
			<%If sortBy = "lastLoginDate" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>Enabled</th>
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
				<a href="<%=mainAppPath%>/table_pages/show-userActivityRecentlyViewedExperiments.asp?id=<%=rec("id")%>"><%=rec("fullName")%></a>
			</td>
			<td class="statusCell">
				<%=rec("companyName")%>
			</td>
			<td class="statusCell">
				<%=rec("email")%>
			</td>
			<td class="statusCell">
				<%=rec("ip")%>
			</td>
			<td id="<%=counter%>_rec_date" class="statusCell">
				<script>setElementContentToDateString("<%=counter%>_rec_date", "<%=rec("lastLoginDate")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
			</td>
			<td class="statusCell">
				<% If rec("Enabled") = 0 Then %>NO<%End If%>
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
hrefStr = "show-logLastLogin.asp?strSearch="&request.querystring("strSearch")&"&rpp="&resultsPerPage&"&s="&request.querystring("s")&"&d="&sortDir&"&groupSelect="&request.querystring("groupSelect")
%>
		<tr>
		<td colspan="6" align="right">	
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