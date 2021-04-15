<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
response.buffer = false
sectionId = "show-asp-errors"
subsectionId = "show-asp-errors"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "tool"
%>

<%
<!-- #include virtual="/arxlab/_inclds/common/asp/saveTableSort.asp"--><%
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
	resultsPerPage = 100
Else
	resultsPerPage = CInt(resultsPerPage)
End if

Call getconnected

%>


<%
If session("roleNumber")<=1 Or session("email")="joe@demo.com" Then
%>

<%
Set rec = server.CreateObject("ADODB.RecordSet")
rec.pageSize = resultsPerPage
rec.CacheSize = resultsPerPage
rec.CursorLocation = 3

strQuery = "SELECT "
If Not userOptions.Get("showAllLogEntries") Or request.querystring("strSearch")="" Then
	strQuery = strQuery &"top 1000 "
End If
strQuery = strQuery & "* FROM aspErrorsView ORDER BY id DESC"
'response.write(strQuery)
rec.open strQuery,connNoTimeout,0,-1
counter = resultsPerPage * pageNum - resultsPerPage
If Not rec.eof then
	rec.absolutePage = pageNum
	eofFlag = False
Else
	eofFlag = True
End if
%>

<%
Function nullSpace(inString)
	If IsNull(inString) Then
		nullSpace = ""
	Else
		nullSpace = inString
	End if
End function
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<%If Not eofFlag then%>
<table class="experimentsTable">
	<tr>
		<th>
		</th>
		<th>
			<td class="counterCell">
				Row Number
			</td>
			<td class="companyId">
				Company ID
			</td>
			<td class="sessionEmail">
				User Email
			</td>
			<td class="fileName">
				File Name
			</td>
			<td class="lineNumber">
				Line Number
			</td>
			<td class="columnNumber">
				Column Number
			</td>
			<td class="category">
				Category
			</td>
			<td class="errorDate">
				Error Date
			</td>
			<td class="serverVariables">
				Server Variables
			</td>
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
			<td class="companyId">
				<%=rec("companyId")%>
			</td>
			<td class="sessionEmail">
				<%=rec("sessionEmail")%>
			</td>
			<td class="fileName">
				<%=rec("fileName")%>
			</td>
			<td class="lineNumber">
				<%=rec("lineNumber")%>
			</td>
			<td class="columnNumber">
				<%=rec("description")%>
			</td>
			<td class="category">
				<%=rec("category")%>
			</td>
			<td class="errorDate">
				<%=rec("errorDate")%>
			</td>
			<td class="serverVariables" height="50px">
				<%=rec("serverVariables")%>
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
hrefStr = "show-log.asp?strSearch="&request.querystring("strSearch")&"&rpp="&resultsPerPage&"&s="&request.querystring("s")&"&d="&sortDir&"&groupSelect="&request.querystring("groupSelect")&"&onlynonCompleted="&request.querystring("onlynonCompleted")&"&actionIds="&request.querystring("actionIds")&"&fields="&request.querystring("fields")
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