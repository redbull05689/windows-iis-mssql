<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "show-notebook"
subsectionId = "show-notebook"
If LCase(request.querystring("inframe")) = "true" Then
inframe=True
Else
inframe=false
End if
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
	If s = "name" Or s="status" Or s="type" Or s="creator" Or s="dateSubmitted" Then
		sortBy = s
	Else
		sortBy = "dateSubmitted"
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
	resultsPerPage = 10
Else
	resultsPerPage = CInt(resultsPerPage)
End if

%>
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<%
If request.querystring("id") <> "" then
'get notebook Id it is used everywhere
	Call getconnected
	projectId = request.querystring("id")
	%>
<%
End if
%>
<!-- #include file="../_inclds/frame-header-tool.asp"-->
<!-- #include file="../_inclds/frame-nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	

<script type="text/javascript" src="<%=mainAppPath%>/js/showTR.js"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/parseRXN.js"></script>

<%
Call getconnected
If canReadProject(projectId,session("userId")) Then
%>

<%
Set rec = server.CreateObject("ADODB.RecordSet")
rec.pageSize = resultsPerPage
rec.CacheSize = resultsPerPage
rec.CursorLocation = 3

strQuery = "SELECT * FROM linksProjectExperimentsView WHERE projectId="&SQLClean(request.querystring("id"),"N","S")& " AND (visible=1 or visible is null)"

rec.open strQuery,conn,0,1

If sortBy="creator" Then
	rec.Sort = "firstName "&sortDir&",lastName"& " " & sortDir
Else
	rec.Sort = sortBy & " " & sortDir
End if

pageCount = rec.pageCount
counter = resultsPerPage * pageNum - resultsPerPage
If Not rec.eof then
	rec.absolutePage = pageNum
	eofFlag = False
Else
	eofFlag = True
End if

%>
<%If Not eofFlag then%>
<div class="formRow listTableRow underItemSectionBigText noBorderBottom">
<table class="listTable">
	<tr class="topListTableRow">
		<th class="leftSideListTableCell">
		</th>
		<th>
			<%
			sortHref = "frame-show-experiments.asp?frameBG=intial&id="&projectId&"&s=name"
			If sortBy = "name" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "name" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink">Name
			<%If sortBy = "name" then%>
				<div <%If sortDir="DESC" then%>class="sortColumnDesc"<%else%>class="sortColumnAsc"<%End if%>></div>
			<%End if%>			
			</a>
		</th>
		<th>
			<%
			sortHref = "frame-show-experiments.asp?frameBG=intial&id="&projectId&"&s=status"
			If sortBy = "status" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "status" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink"><%=statusLabel%>
			<%If sortBy = "status" then%>
				<div <%If sortDir="DESC" then%>class="sortColumnDesc"<%else%>class="sortColumnAsc"<%End if%>></div>
			<%End if%>			
			</a>
		</th>
		<th>
			<%
			sortHref = "frame-show-experiments.asp?frameBG=intial&id="&projectId&"&s=type"
			If sortBy = "type" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "type" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink"><%=typeLabel%>
			<%If sortBy = "type" then%>
				<div <%If sortDir="DESC" then%>class="sortColumnDesc"<%else%>class="sortColumnAsc"<%End if%>></div>
			<%End if%>
			</a>
		</th>
		<th>
			<%
			sortHref = "frame-show-experiments.asp?frameBG=intial&id="&projectId&"&s=creator"
			If s = "creator" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If s = "creator" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink"><%=creatorLabel%>
			<%If s = "creator" then%>
				<div <%If sortDir="DESC" then%>class="sortColumnDesc"<%else%>class="sortColumnAsc"<%End if%>></div>
			<%End if%>			
			</a>
		</th>
		<th>
			<%
			sortHref = "frame-show-experiments.asp?frameBG=intial&id="&projectId&"&s=dateSubmitted"
			If sortBy = "dateSubmitted" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "dateSubmitted" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink"><%=dateCreatedLabel%>(<%If session("useGMT") then%><%="GMT"%><%else%><script type="text/javascript">document.write((new Date()).format("Z"));</script><%End if%>)
			<%If sortBy = "dateSubmitted" then%>
				<div <%If sortDir="DESC" then%>class="sortColumnDesc"<%else%>class="sortColumnAsc"<%End if%>></div>
			<%End if%>
			</a>
		</th>
		<th>
			<%=productsLabel%>
		</th>
		<%if ownsProject(projectId) Or canWriteProject(projectId,session("userId")) then%>
			<th>&nbsp;</th>
		<%End if%>
<%
For intRec = 1 To rec.pageSize
	If Not rec.eof then
	counter = counter + 1
	%>
		<tr>
			<td class="counterCell leftSideListTableCell">
				<%=counter%>.
			</td>
			<td class="experimentCell">
				<%If rec("typeId") = 1 then%>
					<a href="<%=mainAppPath%>/<%=session("expPage")%>?id=<%=rec("experimentId")%>"><%=rec("name")%></a>
				<%End if%>
				<%If rec("typeId") = 2 then%>
					<a href="<%=mainAppPath%>/bio-experiment.asp?id=<%=rec("experimentId")%>"><%=rec("name")%></a>
				<%End if%>
				<%If rec("typeId") = 3 then%>
					<a href="<%=mainAppPath%>/free-experiment.asp?id=<%=rec("experimentId")%>"><%=rec("name")%></a>
				<%End if%>
				<%If rec("typeId") = 4 then%>
					<a href="<%=mainAppPath%>/anal-experiment.asp?id=<%=rec("experimentId")%>"><%=rec("name")%></a>
				<%End if%>
				<p><%=rec("details")%></p>
			</td>
			<td class="statusCell">
				<%=rec("status")%>
			</td>
			<td class="experimentTypeCell">
				<%=GetFullExpType(rec("typeId"))%>
			</td>
			<td class="submittedCell">
				<a href="<%=mainAppPath%>/users/user-profile.asp?id=<%=rec("userId")%>"><%=rec("firstName") & " " & rec("lastName")%></a>
			</td>
			<td id="<%=counter%>_rec_date" class="updatedCell">
				<script>setElementContentToDateString("<%=counter%>_rec_date", "<%=rec("dateSubmitted")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
			</td>
			<td  class="productsCell">
			<div>
			<%If rec("typeId") = 1 then%>
			<script type="text/javascript">
				<%molStr = rec("molData")
				if isnull(molStr) then
					molStr = ""
				end if
				
				%>

				document.write("<a href='javascript:void(0);' title='Click to Enlarge'><img border='0' width='100' height='50' src='"&mainAppPath&"/experiments/ajax/load/getProds.asp?experimentId=<%=rec("experimentId")%>' onclick='showBigProd(this,<%=rec("experimentId")%>)'></a>")

					function IsImageOk(img) {
						if (!img.complete) {
							return false;
						}
						if (typeof img.naturalWidth != "undefined" && img.naturalWidth == 0) {
							return false;
						}
						return true;
					}

					function addEvent(obj, evType, fn, useCapture){
					  if (obj.addEventListener){
						obj.addEventListener(evType, fn, useCapture);
						return true;
					  } else if (obj.attachEvent){
						var r = obj.attachEvent("on"+evType, fn);
						return r;
					  } else {
						alert("Handler could not be attached");
					  }
					}

					addEvent(window, "load", function() {
						for (var i = 0; i < document.images.length; i++) {
							if (!IsImageOk(document.images[i])) {
								document.images[i].style.visibility = "hidden";
							}
						}
					});
			</script>
			</div>
			<%End if%>
			<%If rec("typeId") = 2 Or rec("typeId") = 3 then%>
				<div style="height:25px;">&nbsp;</div>
			<%End if%>
			</td>
			<%if ownsProject(projectId) Or canWriteProject(projectId,session("userId")) then%>
				<td class="deleteCell">
					<%If projectOwner Or canWriteProject(projectId,session("userId")) then%>
						<a href="<%=mainAppPath%>/projects/project-remove-experiment.asp?frameBG=initial&projectId=<%=projectId%>&experimentId=<%=rec("experimentId")%>&experimentType=<%=rec("typeId")%>&inframe=true&rpp=<%=request.querystring("rpp")%>" onclick="return confirm('Are you sure you wish to remove this experiment?')" class="deleteObjectLink"><img src="<%=mainAppPath%>/images/cross.png"></a>
					<%End if%>
				</td>
			<%End if%>
		</tr>
	<%
	rec.movenext
End if
Next
%>


<tr class="lastListTableRow">
	<td colspan="8"></td>
</tr>
</table>
<%If pageCount > 1 then%>
<%
hrefStr = "frame-show-experiments.asp?frameBG=intial&id="&projectId&"&rpp="&resultsPerPage&"&s="&sortBy&"&d="&sortDir&"&inFrame="&inframe
%>
<div class="firstPrevNextLastContainer firstPrevNextLastContainerSearchPage">
    <div class="firstPrevNextLastContainerInner">
		<%if pageNum > 1 then %>	
			<a href="<%=hrefStr & "&pageNum=1"%>" class="firstButton" title="First Page"></a>
			<a href="<%=hrefStr & "&pageNum=" & pageNum-1%>" class="previousButton" title="Next Page"></a>
		<%End if%>
		<%if pageNum < rec.pageCount then%>
			<a href="<%=hrefStr & "&pageNum=" & pageNum + 1%>" class="nextButton" title="Next Page"></a>
			<a href="<%=hrefStr & "&pageNum=" & rec.pageCount%>" class="lastButton" title="Last Page"></a>
		<%End if%>
    </div>
</div>
<%End if%>
<%
rec.close()
Set rec = nothing
%>
</div>
<%End if%>
<%End if%>

<br>
<%If request.querystring("message")<>"" then%>
	<script type="text/javascript">
		window.parent.alert("<%=request.querystring("message")%>")
	</script>
<%End if%>
<!-- #include file="../_inclds/frame-footer-tool.asp"-->