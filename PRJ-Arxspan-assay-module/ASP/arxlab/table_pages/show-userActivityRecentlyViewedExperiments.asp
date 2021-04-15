<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "show-user-activity"
subsectionId = "show-user-activity"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "tool"
%>
<%
If LCase(request.querystring("inframe")) = "true" Then
	inFrame = true
Else
	inFrame = false
End if
frameStuff = "&inframe="&inframe&"&frameBG="&request.querystring("frameBG")&"&frameWidth="&request.querystring("frameWidth")&"&frameExperimentTableWidth="&request.querystring("frameExperimentTableWidth")
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
	sortBy = "theDate"
Else
	s = request.querystring("s")
	If s = "name" Or s="status" Or s="type" Or s="lastViewed" Then
		sortBy = s
		If s="lastViewed" Then
			sortBy = "theDate"
		End if
	Else
		sortBy = "theDate"
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
'get notebook Id it is used everywhere
	Call getconnected

	pageTitle = "User Actvity"
%>
	<%If inframe then%>
		<!-- #include file="../_inclds/frame-header-tool.asp"-->
		<!-- #include file="../_inclds/frame-nav_tool.asp"-->
	<%else%>
		<!-- #include file="../_inclds/header-tool.asp"-->
		<!-- #include file="../_inclds/nav_tool.asp"-->
	<%End if%>
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	


<script type="text/javascript" src="<%=mainAppPath%>/js/showTR.js"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/parseRXN.js"></script>

<%
Call getconnected

validUser = false
userId = request.querystring("id")
Set uRec = server.CreateObject("ADODB.RecordSet")
If session("companyId") <> "1" Then
	strQuery = "SELECT * FROM usersView WHERE id="&SQLClean(userId,"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
Else
	strQuery = "SELECT * FROM usersView WHERE id="&SQLClean(userId,"N","S")
End if
uRec.open strQuery,conn,3,3
If Not uRec.eof Then
	validUser = True
	fullName = uRec("fullName")
	userCompanyId = uRec("companyId")
	userManagerId = uRec("userAdded")
End if
uRec.close
Set uRec = nothing

authorized = False
If session("roleNumber") = "1" Then
	If session("companyId") = "1" Then
		authorized = true
	Else
		If CStr(userCompanyId) = CStr(session("companyId")) Then
			authorized = true
		End if
	End if
End If
If session("roleNumber") = "2" Then
	If CStr(userManagerId) = CStr(session("userId")) Then
		authorized = true
	End if
End if
If session("roleNumber") = "3" Then
	If CStr(userManagerId) = CStr(session("managerId")) Then
		authorized = true
	End if
End if

Set rec = server.CreateObject("ADODB.RecordSet")
rec.pageSize = resultsPerPage
rec.CacheSize = resultsPerPage
rec.CursorLocation = 3
strQuery = "SELECT * FROM recentlyViewedExperimentsView WHERE companyId="&SQLClean(session("companyId"),"N","S")&" and userId="&SQLClean(userId,"N","S") & " AND visible=1 "
q = Trim(request.querystring("q"))
If q <> "" Then
	strQuery = strQuery & "AND (name like "&SQLClean(q,"L","S")&" OR status like "&SQLClean(q,"L","S")&" OR type like "&SQLClean(q,"L","S")&") "
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
<%If Not eofFlag And authorized then%>
<h1>User Activity for <%=fullName%></h1><br/>
<form action="<%=mainAppPath%>/table_pages/show-userActivityRecentlyViewedExperiments.asp" method="get">
<input type="hidden" name="id" value="<%=userId%>">
<input type="text" name="q" id="q" value="<%=request.querystring("q")%>" style="display:inline;margin-right:10px;">
<input type="hidden" name="inframe" value="<%=request.querystring("inframe")%>">
<input type="hidden" name="frameBG" value="<%=request.querystring("frameBG")%>">
<input type="hidden" name="frameWidth" value="<%=request.querystring("frameWidth")%>">
<input type="hidden" name="frameExperimentTableWidth" value="<%=request.querystring("frameExperimentTableWidth")%>">
<input type="submit" value="<%=searchLabel%>" style="display:inline;font-size:12px;padding:2px;">
</form>
<br/>
<table class="experimentsTable">
	<tr>
		<th>
		</th>
		<th>
			<%
			sortHref = "show-userActivityRecentlyViewedExperiments.asp?id="&request.querystring("id")&"&s=name"&frameStuff
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
			sortHref = "show-userActivityRecentlyViewedExperiments.asp?id="&request.querystring("id")&"&s=status"&frameStuff
			If sortBy = "status" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If sortBy = "status" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink"><%=statusLabel%></a>
			<%If sortBy = "status" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "show-userActivityRecentlyViewedExperiments.asp?id="&request.querystring("id")&"&s=type"&frameStuff
			If s = "type" And sortDir = "ASC" Then
				sortHref = sortHref & "&d=DESC"
			End If
			If s = "type" And sortDir = "DESC" Then
				sortHref = sortHref & "&d=ASC"
			End if			
			%>
			<a href="<%=sortHref%>" class="headerSortLink"><%=typeLabel%></a>
			<%If s = "type" then%>
				<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
			<%End if%>
		</th>
		<th>
			<%
			sortHref = "show-userActivityRecentlyViewedExperiments.asp?id="&request.querystring("id")&"&s=lastViewed"&frameStuff
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
		<th></th>
		<th></th>
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
						<%If rec("typeId") = 1 then%>
							<a href="<%=mainAppPath%>/<%=session("expPage")%>?id=<%=Trim(rec("experimentId"))%>" onclick="parent.location.href=this.href"><%=rec("name")%></a>
						<%End if%>
						<%If rec("typeId") = 2 then%>
							<a href="<%=mainAppPath%>/bio-experiment.asp?id=<%=rec("experimentId")%>" onclick="parent.location.href=this.href"><%=rec("name")%></a>
						<%End if%>
						<%If rec("typeId") = 3 then%>
							<a href="<%=mainAppPath%>/free-experiment.asp?id=<%=rec("experimentId")%>" onclick="parent.location.href=this.href"><%=rec("name")%></a>
						<%End if%>
						<%If rec("typeId") = 4 then%>
							<a href="<%=mainAppPath%>/anal-experiment.asp?id=<%=rec("experimentId")%>" onclick="parent.location.href=this.href"><%=rec("name")%></a>
						<%End if%>
					</td>
					<td class="statusCell">
						<%=rec("status")%>
					</td>
					<td class="experimentTypeCell">
						<%=rec("type")%>
					</td>
					<td id="<%=counter%>_rec_date" class="submittedCell">
						<script>setElementContentToDateString("<%=counter%>_rec_date", "<%=rec("theDate")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
					</td>
					<td class="updatedCell">
					<%
					Set fRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * from noteAddedNotifications WHERE experimentType="&SQLClean(rec("experimentType"),"N","S")& " AND experimentId="&SQLClean(rec("experimentId"),"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND dismissed=0"
					fRec.open strQuery,conn,1,1
					numNotesAdded = fRec.recordcount
					fRec.close
					strQuery = "SELECT * from attachmentAddedNotifications WHERE experimentType="&SQLClean(rec("experimentType"),"N","S")& " AND experimentId="&SQLClean(rec("experimentId"),"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND dismissed=0"
					fRec.open strQuery,conn,1,1
					numAttachmentsAdded = fRec.recordcount
					fRec.close
					strQuery = "SELECT * from experimentSavedNotifications WHERE experimentType="&SQLClean(rec("experimentType"),"N","S")& " AND experimentId="&SQLClean(rec("experimentId"),"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND dismissed=0"
					fRec.open strQuery,conn,1,1
					numSaves = fRec.recordcount
					fRec.close
					strQuery = "SELECT * from commentNotifications WHERE experimentType="&SQLClean(rec("experimentType"),"N","S")& " AND experimentId="&SQLClean(rec("experimentId"),"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND (dismissed=0 or dismissed is null)"
					fRec.open strQuery,conn,1,1
					numCommentsAdded = fRec.recordcount
					fRec.close
					Set fRec = Nothing
					%>
					<div>
						<div class="actionIconHolder">
							<span class="textOnImage overlayText"><%=numSaves%></span>
							<img src="<%=mainAppPath%>/images/cow-save.gif" alt="Saves" title="Saves">
						</div>
						<div class="actionIconHolder">
							<span class="textOnImage overlayText"><%=numNotesAdded%></span>
							<img src="<%=mainAppPath%>/images/cow-note.gif" alt="Notes" title="Notes"> 
						</div>
						<div class="actionIconHolder">					
							<span class="textOnImage overlayText"><%=numAttachmentsAdded%></span>
							<img src="<%=mainAppPath%>/images/cow-attachment.gif" alt="Attachments" title="Attachments">
						</div>
						<div class="actionIconHolder">
							<span class="textOnImage overlayText"><%=numCommentsAdded%></span>
							<img src="<%=mainAppPath%>/images/cow-comment.gif" alt="Comments" title="Comments">
						</div>
					</div>
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
						document.write("<a href='javascript:void(0);' title='Click to Enlarge'><img border='0' width='100' height='50' src='<%=mainAppPath%>/experiments/ajax/load/getProds.asp?experimentId=<%=rec("experimentid")%>' onclick='showBigProd(this,<%=rec("experimentid")%>)'></a>")

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
				</tr>

	<%
	rec.movenext
End if
Next
%>


<%
hrefStr = mainAppPath&"/table_pages/show-userActivityRecentlyViewedExperiments.asp?id="&userId&"&rpp="&resultsPerPage&"&s="&sortBy&"&d="&sortDir&"&q="&q&frameStuff
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
<%else%>
<%If eofFlag then%>
	<table class="experimentsTable" style="width:100%;">
		<tr>
			<td>
				<p>No Results.</p>
			</td>
		</tr>
	</table>
<%else%>
	<h1>User Activity</h1>
	<br/>
	<p>You are not authorized to view this page.</p>
<%End if%>
<%End if%>

<%If inframe then%>
	<!-- #include file="../_inclds/frame-footer-tool.asp"-->
<%else%>
	<!-- #include file="../_inclds/footer-tool.asp"-->
<%End if%>