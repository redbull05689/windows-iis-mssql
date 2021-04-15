<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../_inclds/globals.asp"-->
<%recLimit = Int(request.querystring("recLimit"))%>
<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead" style="position:relative;">
	<a href="javascript:void(0);" onclick="clearAllNotifications();" style="position:absolute;top:5px;right:5px;color:white;z-index:100;text-shadow: 1px 1px #0009;">Clear Notifications</a><a href="<%=mainAppPath%>/misc/show-notifications.asp" style="text-decoration:none;"><h2><%=notificationsLabel%></h2></a></div>
<div class="objBody">

	<table class="experimentsTable notifications" style="width:100%;">
	<% 
						

				Set nRec = server.CreateObject("ADODB.RecordSet")
				If recLimit = "" Then
					recLimit = 1000
				End If
				strQuery = "SELECT dateAdded,id,title,notificationType,experimentType,experimentId,notification,dismissed,experimentName FROM notificationsView WHERE companyId=" & SQLClean(session("companyId"),"N","S") & " AND userId="&SQLClean(session("userId"),"N","S") & " AND dismissed=0 ORDER BY dateAdded DESC"
				nRec.open strQuery,conn,3,3
				%>
				<%If nRec.eof then%>
					<tr>
						<td>
							<div align="center" style="width:100%;display:none;" id="notificationLoadingDiv"><img src="<%=mainAppPath%>/images/ajax-loader.gif" width="20" height="20"></div>
							<input type="hidden" id="lastNotificationId" value="<%=getLastNotificationId()%>">
						</td>
					</tr>
					<tr id="noNotificationsMessage"><td><p>You have no unread notifications</p></td></tr>
				<%End if%>
						<%
						lastMonth = "0"
						lastDay = "0"
						lastYear = "0"
						todayDate = Date()
						todayMonth = Month(todayDate)
						todayDay = Day(todayDate)
						todayYear = Year(todayDate)

						counter = 0
						Do While Not nRec.eof And counter < recLimit
						counter = counter + 1
						%>
							<tr>
								<td>
									<%
									'Not adjusted for timezones!!
									If Not IsNull(nRec("dateAdded")) Then
										thisDate = CDate(nRec("dateAdded"))
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
											<input type="hidden" id="lastNotificationId" value="<%=nRec("id")%>">
											<div id="noNotificationsMessage" style="display: none;">You have no unread notifications</div>
										<%
										End if
										End If
										lastMonth = thisMonth
										lastDay = thisDay
										lastYear = thisYear
									End if
									If Not IsNull(nRec("title")) Then
										title = nRec("title")
									Else
										title = ""
									End if
									If nRec("notificationType") = 1 Then
										Set tRec = server.CreateObject("ADODB.RecordSet")
										strQuery = "SELECT max(id) as id,commenterName FROM commentNotificationsView WHERE userId="&SQLClean(session("userId"),"N","S") & " AND experimentType="&SQLClean(nRec("experimentType"),"N","S") & " AND experimentId="&SQLClean(nRec("experimentId"),"N","S") &" AND commenterId <>"&SQLClean(session("userId"),"N","S")&" GROUP BY commenterName ORDER BY ID DESC"
										tRec.open strQuery,conn,1,1
										rc = tRec.recordcount
										counter2 = 0
										Do While Not tRec.eof
											counter2 = counter2 + 1
											If counter2 = 1 then
												notification = tRec("commenterName")
											End If
											If rc = 2 Then
												If counter2 = 2 Then
													notification = notification & " and " & tRec("commenterName")
												End if
											End if
											If rc > 2 Then
												If counter2 = 2 Then
													notification = notification & ", " & tRec("commenterName")
												End If
												If counter2 = 3 And rc=3 then
													notification = notification & " and " & tRec("commenterName")
												End If
												If counter2 = 3 And rc=4 then
													notification = notification & ", " & tRec("commenterName") & " and 1 other user "
												End If
												If counter2 = 3 And rc > 4 then
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
										prefix = GetPrefix(nRec("experimentType"))
										page = GetExperimentPage(prefix)
										notification = notification & "<a href='"&page&"?id="&nRec("experimentId")&"'>"&nRec("experimentName")&"</a>"

										tRec.close
										title = "Comment Added"
									else
										notification = nRec("notification")
									End if
									%>
		
									
									<div id="notification_body_<%=nRec("id")%>" class="notificationBody<%If nRec("dismissed") = 1 then%> dismissed<%End if%>" onMouseOver="clearNotificationTO = window.setTimeout('clearNotification(\'<%=nRec("id")%>\')',500)" onMouseOut="clearTimeout(clearNotificationTO)">
									<span class="notificationBodyTitle" onclick="document.getElementById('notification_<%=nRec("id")%>_body').style.display='none';document.getElementById('notification_<%=nRec("id")%>_title').style.display='block';"><%=title%>: </span>
									<span class="noteText">
									<%=notification%>
									</span>
									</div>
								</td>
								<td>
								</td>
							</tr>
						<%
							nRec.moveNext
						Loop
						If counter = recLimit  And Not nRec.eof Then
							theText = moreLabel & "..."
						Else
							theText = detailsLabel & "..."
						End if
						%>
		<%If counter > 0 then%>
		<tr>
			<td colspan="1" align="right"><a href="<%=mainAppPath%>/misc/show-notifications.asp"><%=moreLabel%>...</a></td>
		</tr>
		<%End if%>
	</table>
</div>
</div>