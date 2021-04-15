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
pageNum = request.querystring("pageNum")
If Not isInteger(pageNum) Then
	pageNum = 1
Else
	pageNum = CInt(pageNum)
End if

resultsPerPage = request.querystring("rpp")
If Not isInteger(resultsPerPage) Then
	resultsPerPage = 50
Else
	resultsPerPage = CInt(resultsPerPage)
End if

%>
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<%
'get notebook Id it is used everywhere
	Call getconnected
	' If you update this pageTitle, update it in header-tool.asp too - there's a <base> tag that's inserted based on the pageTitle
	pageTitle = "Notifications"
%>
	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->

<script type="text/javascript">
	var clearNotificationTO;
	function clearNotification(notificationId)
	{
		document.getElementById("notification_body_"+notificationId).classList.add("dismissed");
		ajaxNoReturn('<%=mainAppPath%>/misc/ajax/do/clearNotification.asp?id='+notificationId);
	}
</script>

<script type="text/javascript">
	var newNotSack = new sack();
	var getNewNotSack = new sack();
	var newNotNode;

function insertAfter(parent, node, referenceNode) {
  parent.insertBefore(node, referenceNode.nextSibling);
}

function checkNewNotifications()
{
	newNotSack.requestFile = "<%=mainAppPath%>/misc/ajax/check/checkNewNotifications.asp?id="+document.getElementById("lastNotificationId").value+"&random="+Math.random();
	newNotSack.onCompletion = checkNewNotificationsComplete;
	newNotSack.runAJAX();
}

function checkNewNotificationsComplete()
{
	if (newNotSack.response != '')
	{
		document.getElementById("notificationLoadingDiv").style.display = "block";
		newLast = newNotSack.response
		newNotSack.requestFile = "<%=mainAppPath%>/misc/ajax/load/getNewNotification.asp?id="+document.getElementById("lastNotificationId").value+"&random="+Math.random();
		newNotSack.onCompletion = getNewNotificationComplete;
		newNotSack.runAJAX();
		document.getElementById("lastNotificationId").value = newLast
	}
}

function getNewNotificationComplete()
{
	newDIV = document.createElement("div")
	newDIV.innerHTML = newNotSack.response
	newNotNode = newDIV
	window.setTimeout('showNewSack()',1000)
}

function showNewSack()
{
	insertAfter(document.getElementById("notificationLoadingDiv").parentNode,newNotNode,document.getElementById("notificationLoadingDiv"))
	document.getElementById("notificationLoadingDiv").style.display = "none";
}

checkNewNotificationsInterval = window.setInterval('checkNewNotifications()',60000)

</script>

	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	


<%
Call getconnected


Set rec = server.CreateObject("ADODB.RecordSet")
rec.pageSize = resultsPerPage
rec.CacheSize = resultsPerPage
rec.CursorLocation = 3
strQuery = "SELECT * FROM notificationsView WHERE companyId=" & SQLClean(session("companyId"),"N","S") & " AND userId="&SQLClean(session("userId"),"N","S") & " ORDER BY dateAdded DESC"
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
<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/misc/show-notifications.asp" style="text-decoration:none;"><h2>Notifications</h2></a></div>
<div class="objBody">

	<table style="width:100%;">
<%
lastMonth = "0"
lastDay = "0"
lastYear = "0"
todayDate = Date()
todayMonth = Month(todayDate)
todayDay = Day(todayDate)
todayYear = Year(todayDate)
%>
<%
For intRec = 1 To rec.pageSize
	If Not rec.eof then
	counter = counter + 1
	%>
							<tr>
								<td>
									<%
									'Not adjusted for timezones!!
									If Not IsNull(rec("dateAdded")) Then
										thisDate = CDate(rec("dateAdded"))
										thisMonth = Month(thisDate)
										thisDay = Day(thisDate)
										thisYear = Year(thisDate)
										If Not (thisMonth = lastMonth And thisDay = lastDay And thisYear = lastYear) then
											If thisMonth = todayMonth And thisDay = todayDay And thisYear = todayYear Then
												%>
												<span class="notificationDateDividerText">Today</span>
												<br/>
												<hr class="notificationDateDivider">
												<%
											Else														
												%>
												<span class="notificationDateDividerText"><%=MonthName(thisMonth)%>&nbsp;<%=thisDay%>,&nbsp;<%=thisYear%></span>
												<br/>
												<hr class="notificationDateDivider">
												<%
											End If
										If counter = 1 Then
										%>
											<div align="center" style="width:100%;display:none;" id="notificationLoadingDiv"><img src="<%=mainAppPath%>/images/ajax-loader.gif" width="20" height="20"></div>
											<input type="hidden" id="lastNotificationId" value="<%=rec("id")%>">
										<%
										End if
										End If
										lastMonth = thisMonth
										lastDay = thisDay
										lastYear = thisYear
									End if
									If Not IsNull(rec("title")) Then
										title = rec("title")
									Else
										title = ""
									End if
									If rec("notificationType") = 1 Then
										Set tRec = server.CreateObject("ADODB.RecordSet")
										strQuery = "SELECT max(id) as id,commenterName FROM commentNotificationsView WHERE userId="&SQLClean(session("userId"),"N","S") & " AND experimentType="&SQLClean(rec("experimentType"),"N","S") & " AND experimentId="&SQLClean(rec("experimentId"),"N","S") &" AND commenterId <>"&SQLClean(session("userId"),"N","S")&" GROUP BY commenterName ORDER BY ID DESC"
										tRec.open strQuery,conn,1,1
										rc = tRec.recordcount
										counter = 0
										Do While Not tRec.eof
											counter = counter + 1
											If counter = 1 then
												notification = tRec("commenterName")
											End If
											If rc = 2 Then
												If counter = 2 Then
													notification = notification & " and " & tRec("commenterName")
												End if
											End if
											If rc > 2 Then
												If counter = 2 Then
													notification = notification & ", " & tRec("commenterName")
												End If
												If counter = 3 And rc=3 then
													notification = notification & " and " & tRec("commenterName")
												End If
												If counter = 3 And rc=4 then
													notification = notification & ", " & tRec("commenterName") & " and 1 other user "
												End If
												If counter = 3 And rc > 4 then
													notification = notification & ", " & tRec("commenterName") & " and "&(rc-3)& " others "
												End If
											End If

											tRec.movenext
										Loop
										If rc > 1 Then
											notification = notification & " added comments to "
										Else
											notification = notification & " added a comment to "
										End if										
										
										prefix = GetPrefix(experimentType)
										page = GetExperimentPage(prefix)
										
										page = mainAppPath & "/" & page
										notification = notification & "<a href='/arxlab/"&page&"?id="&rec("experimentId")&"'>"&rec("experimentName")&"</a>"

										tRec.close
										title = "Comment Added"
									else
										notification = rec("notification")
									End if
									%>
		
									
									<div id="notification_body_<%=rec("id")%>" class="notificationBody<%If rec("dismissed") = 1 then%> dismissed<%End if%>" onMouseOver="clearNotificationTO = window.setTimeout('clearNotification(\'<%=rec("id")%>\')',500)" onMouseOut="clearTimeout(clearNotificationTO)">
									<span class="notificationBodyTitle" onclick="document.getElementById('notification_<%=rec("id")%>_body').style.display='none';document.getElementById('notification_<%=rec("id")%>_title').style.display='block';"><%=title%>: </span>
									<span class="noteText">
									<%=HTMLDecode(notification)%>
									</span>
									</div>
								</td>
								<td>
								</td>
							</tr>
	<%
	rec.movenext
End if
Next
%>


<%
hrefStr = mainAppPath&"/misc/show-notifications.asp?id="&notebookId&"&rpp="&resultsPerPage&"&s="&sortBy&"&d="&sortDir&"&q="&q
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
</div>
</div>
<%End if%>


<!-- #include file="../_inclds/footer-tool.asp"-->