<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
response.buffer = false
sectionId = "show-log"
subsectionId = "show-log"
server.scriptTimeout = 30000
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "tool"
%>

<%
If request.querystring("fields") = "" Then
	If session("companyId") = "1" Then
		selectedFields = Split("email,companyName,action,ip,dateSubmittedServer,firstTimeout,secondTimeout,saveCompleted,serial",",")
	Else
		selectedFields = Split("fullName,companyName,action,ip,dateSubmittedServer",",")
	End If
Else
	selectedFields = Split(request.querystring("fields"),",")
End if

Set fieldsByName = JSON.parse("{}")
set fields = JSON.parse("[]")

Set field = JSON.parse("{}")
field.Set "displayName","Email"
field.Set "dbName","email"
field.Set "defaultSortDir","ASC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Name"
field.Set "dbName","fullName"
field.Set "defaultSortDir","ASC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Company Name"
field.Set "dbName","companyName"
field.Set "defaultSortDir","ASC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Action"
field.Set "dbName","action"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","IP"
field.Set "dbName","ip"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Date"
field.Set "dbName","dateSubmittedServer"
field.Set "defaultSortDir","DESC"
field.Set "canSort",true
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","type"
field.Set "dbName","type"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Experiment"
field.Set "dbName","experimentName"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Status"
field.Set "dbName","status"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Notebook"
field.Set "dbName","notebookName"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Project"
field.Set "dbName","projectName"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

If session("companyId") = "1" Then
Set field = JSON.parse("{}")
field.Set "displayName","10 sec+"
field.Set "dbName","firstTimeout"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","30 sec+"
field.Set "dbName","secondTimeout"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Save Completed"
field.Set "dbName","saveCompleted"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

Set field = JSON.parse("{}")
field.Set "displayName","Serial"
field.Set "dbName","serial"
field.Set "defaultSortDir","DESC"
field.Set "canSort",false
field.Set "show",false
If inArr(field.Get("dbName"),selectedFields) Then
	field.Set "show",true
End if
fields.push(field)
fieldsByName.Set field.Get("dbName"),field

End if

'If request.querystring("s") = "" Then
	sortBy = "dateSubmittedServer"
'Else
'	s = request.querystring("s")
'	sortBy = s
'End If

If request.querystring("d") = "" Then
	sortDir = fieldsByName.Get(sortBy).Get("defaultSortDir")
Else
	d = request.querystring("d")
	If d = "ASC" Then
		sortDir = "ASC"
	Else
		sortDir = "DESC"
	End if
End If
%><!-- #include virtual="/arxlab/_inclds/common/asp/saveTableSort.asp"--><%
'If  sortBy = "fullName" Then
	sortBy = "dateSubmittedServer"
'End If

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
	resultsPerPage = 40
Else
	resultsPerPage = CInt(resultsPerPage)
End if

Call getconnected

%>


<%
If session("roleNumber")<=1 then
%>

<%
Set rec = server.CreateObject("ADODB.RecordSet")
rec.pageSize = resultsPerPage
rec.CacheSize = resultsPerPage
rec.CursorLocation = 3

strQuery = "SELECT "
If Not userOptions.Get("showAllLogEntries") Then
	strQuery = strQuery &"top 1000 "
End if
strQuery = strQuery & "* FROM combinedLogView WITH(NOLOCK) WHERE 1=1"
If request.querystring("strSearch") <> "" then
	strQuery = strQuery & " AND (companyName like "&SQLClean(request.querystring("strSearch"),"L","S")&" or action like "&SQLClean(request.querystring("strSearch"),"L","S")&" or fullName like "&SQLClean(request.querystring("strSearch"),"L","S")&" or email like "&SQLClean(request.querystring("strSearch"),"L","S")&" or IP like "&SQLClean(Trim(request.querystring("strSearch")),"L","S")&")"
End If

If request.querystring("groupSelect") <> "" Then
	If request.querystring("groupSelect") <> "0" then
		strQuery = strQuery & " AND userId IN (SELECT userId FROM groupMembers WHERE groupId="&SQLClean(request.querystring("groupSelect"),"N","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")&")"
	End if
End if

strQuery = strQuery &" AND companyId="&SQLClean(session("companyId"),"N","S")&" AND actionId in (select id from logActions where id not in (16, 18, 26, 27, 28))"

If request.querystring("onlynonCompleted")="on" Then
	strQuery = strQuery & " AND (saveCompleted=0 or saveCompleted is null)"
End If

If request.querystring("actionIds")<> "" Then
	strQuery = strQuery & " AND actionId in ("&Replace(SQLClean(request.querystring("actionIds"),"T","S"),"'","")&")"
End if

strQuery = strQuery & " AND (saveCompleted is null or firstTimeout=1 or saveCompleted=1)"
'strQuery = strQuery & " ORDER BY "&sortBy& " " & sortDir

'response.write(strQuery)
rec.open strQuery,connNoTimeout,0,-1
rec.Sort = sortBy & " " & sortDir

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
If request.querystring("dl") <> "" Then
	response.buffer = false
	response.contenttype="text/CSV"
	response.addheader "ContentType","text/CSV"
	Response.addheader "Content-Disposition", "attachment; " & "filename=arxspan_log_"&Year(date)&"_"&Month(date)&"_"&Day(date)&"_"&Hour(time)&"_"&Minute(time)&".csv"
	rowStr = ""
	For Each field In fields
		If field.Get("show") Then
			rowStr = rowStr & field.Get("displayName") & ","
		End if
	Next
	If Len(rowStr) > 1 Then
		rowStr = Mid(rowStr,1,Len(rowStr)-1)
	End If
	rowStr = rowStr & vbcrlf
	response.write(rowStr)
	
	Do While Not rec.eof
		rowStr = ""
		For Each field In fields
			If field.Get("show") Then
				If rec("actionId") <> 24 Then
					rowStr = rowStr & """"&Replace(nullSpace(rec(field.Get("dbName"))),"""","""""")&"""" & ","
				Else
					rowStr = rowStr & """"&Replace(nullSpace("file: "&rec("extraText")),"""","""""")&"""" & ","
				End if
			End if
		Next
		If Len(rowStr) > 1 Then
			rowStr = Mid(rowStr,1,Len(rowStr)-1)
		End If
		rowStr = rowStr & vbcrlf
		response.write(rowStr)

		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	response.end
End if
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<%If Not eofFlag then%>
<form action="show-log.asp" method="get">
	<label for="groupSelect">Group</label><br/>
	<select id="groupSelect" name="groupSelect">
	<option value="0">Any</option>
<%
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM groups WHERE companyId="&SQLClean(session("companyId"),"N","S")
	rec2.open strQuery,connNoTimeout,0,-1
	Do While Not rec2.eof
		%>
			<option value="<%=rec2("id")%>" <%If CStr(request.querystring("groupSelect"))=CStr(rec2("id")) then%>SELECTED<%End if%>><%=rec2("name")%></option>
		<%
		rec2.movenext
	loop
%>
	</select>
	<br/>
	<label for="strSearch">Text</label><br/>
	<input type="text" name="strSearch" id="strSearch" style="display:inline;" value="<%=request.querystring("strSearch")%>">
	<br/>
	<%If session("companyId") = "1" then%>
		<label for="onlynonCompleted">Show only non-completed</label>
		<input type="checkbox" name="onlynonCompleted" id="onlynonCompleted" style="display:inline;" <%If request.querystring("onlynonCompleted")="on" then%>checked<%End if%>>
	<br/>
	<%End if%>
	<label style="margin-right:4px!important;display:inline;">Show All Entries (Default: First 1000)</label><input style="margin:0;display:inline;" type="checkbox" <%If userOptions.Get("showAllLogEntries") then%>CHECKED<%End if%> onclick="if(this.checked){setUserOption('showAllLogEntries',true)}else{setUserOption('showAllLogEntries',false)}">
	<br/>
	<label style="margin-right:4px!important;display:inline;">auto refresh</label><input style="margin:0;display:inline;" type="checkbox" <%If userOptions.Get("logAutoRefresh") then%>CHECKED<%End if%>  onclick="if(this.checked){setUserOption('logAutoRefresh',true);window.setTimeout(function(){window.location=window.location},10000)}else{setUserOption('logAutoRefresh',false)}">
	<%If userOptions.Get("logAutoRefresh") then%>
	<script type="text/javascript">
		window.setTimeout(function(){window.location=window.location},10000)
	</script>
	<%End if%>
	<table>
		<tr>
			<td>
				<label for="actionIds">Actions</label><br/>
				<select id="actionIds" name="actionIds" multiple style="height:160px;">
				<%
				aStr = request.querystring("actionIds")
				actionIds = Split(aStr,",")
				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM logActions WHERE 1=1"
				If session("companyId")<>"1" Then
					strQuery = strQuery & " AND id <> 28 AND id <> 27 AND id <> 26 and id <> 16 and id <> 18"
				End if
				strQuery = strQuery & " order by action asc"
				rec2.open strQuery,connNoTimeout,0,-1
				Do While Not rec2.eof
					%><option value="<%=rec2("id")%>" <%If request.querystring("actionIds")="" Or inArr(rec2("id"),actionIds) then%>selected<%End if%>><%=rec2("action")%></option><%
					rec2.movenext
				loop
				%>
				</select>
			</td>
			<td style="padding-left:20px;">
				<label for="">Fields</label><br/>
				<select id="fields" name="fields" multiple style="height:160px;">
					<%For Each field In fields%>
						<%
						If field.Get("dbName")="" Then
							Exit for
						End if
						%>
						<option value="<%=field.Get("dbName")%>" <%If field.Get("show") then%>SELECTED<%End if%>><%=field.Get("displayName")%></option>
					<%next%>
				</select>
			</td>
		</tr>
	</table>
	<input type="submit" value="filter" style="margin-top:10px;">
</form>
<br/>
<%
hrefStr = "show-log.asp?strSearch="&request.querystring("strSearch")&"&rpp="&resultsPerPage&"&groupSelect="&request.querystring("groupSelect")&"&onlynonCompleted="&request.querystring("onlynonCompleted")&"&actionIds="&request.querystring("actionIds")&"&fields="&request.querystring("fields")
%>
<div style="width:850px;text-align:right;"><a href="<%=hrefStr%>&dl=1">Download CSV</a></div>
<table class="experimentsTable">
	<tr>
		<th>
		</th>
		<%
		For Each field In fields
			If field.Get("show") then
			%>
				<th>
					<%If field.Get("canSort") then%>
						<%
						sortHref = hrefStr&"&s="&field.Get("dbName")
						If s = field.Get("dbName") And sortDir = "ASC" Then
							sortHref = sortHref & "&d=DESC"
						End If
						If s = field.Get("dbName") And sortDir = "DESC" Then
							sortHref = sortHref & "&d=ASC"
						End if			
						%>
						<a href="<%=sortHref%>" class="headerSortLink"><%=field.Get("displayName")%></a>
						<%If s = field.Get("dbName") then%>
							<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
						<%End if%>
					<%else%>
						<%=field.Get("displayName")%>
					<%End if%>
				</th>
			<%
			End if
		next
		%>


<%
For intRec = 1 To rec.pageSize
	If Not rec.eof then
	counter = counter + 1
	%>
		<tr>
			<td class="counterCell">
				<%=counter%>.
			</td>
			<%For Each field In fields%>
				<%If field.Get("show") then%>
					<%
					If field.Get("dbName")="" Then
						Exit for
					End if
					%>
					<%If field.Get("dbName")<>"action" then%>
						<td class="statusCell">
							<%if rec("actionId") = 14 And field.Get("dbName")="email" Then%>
								<%=rec("extraText")%>
							<%else%>
								<%=rec(field.Get("dbName"))%>
							<%End if%>
						</td>
					<%else%>
						<td class="statusCell">
							<%
							If rec("extraTypeId") <> 0 Then
								Select Case rec("extraTypeId")
									Case "1"
										actionHref = mainAppPath & "/" & "show-notebook.asp?id="&rec("extraId")
									Case "2"
										actionHref = mainAppPath & "/" & session("expPage")&"?id="&rec("extraId")
									Case "3"
										actionHref = mainAppPath & "/" & "bio-experiment.asp?id="&rec("extraId")
									Case "4"
										actionHref = mainAppPath & "/" & "free-experiment.asp?id="&rec("extraId")
									Case "5"
										actionHref = mainAppPath & "/" & "search.asp?q="&rec("extraText")
									Case "6"
										actionHref = mainAppPath & "/" & "anal-experiment.asp?q="&rec("extraId")
								End select
								If InStr(rec("action"),"Project") <> 0 Then
									actionHref = mainAppPath & "/" & "show-project.asp?id="&rec("extraId")
								End if
							End if
							%>
							<%
							If rec("extraTypeId") = 0 Then
								If rec("actionId") = 14 then
									response.write("<span style='color:red;'>" & rec("action") & "</span>")
								ElseIf rec("actionId") = 30 then
									response.write("<span>Tag Added</span>")
								Else
									response.write(rec("action"))
								End if
							Else
								If rec("actionId") = 24 Then
									theAction = "file: "&rec("extraText")
								Else
									theAction = rec("action")
								End if
								%>
								<a href="<%=actionHref%>"><%=theAction%></a>
								<%
							End if
							%>
						</td>
					<%End if%>
				<%End if%>
			<%next%>
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