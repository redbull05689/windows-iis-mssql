<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<div class="dashboardObjectContainer changePassword" style="display:inline;"><div class="objHeader elnHead"><h2><%=notificationsLabel2%></h2></div>
		<div class="objBody">

			<form method="post" action="<%=mainAppPath%>/users/my-profile.asp">

			<%If request.querystring("x") = "1" then%>
					<p class="changePasswordMessage">Options Saved</p>
			<%End if%>
			<table cellpadding="0" cellspacing="0" class="profileTable">
			<tr>
				<td>
				&nbsp;
				</td>
				<td align="center">
				<strong><%=notificationOnHomePageLabel%></strong>
				</td>
				<td align="center">
				<strong><%=notificationByEmailLabel%></strong>
				</td>
			</tr>
			<%
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT id, notificationType, notificationTypeJapanese, notificationTypeChinese FROM notificationTypes WHERE 1=1 "
			If Not session("hasMUFExperiment") Then
				strQuery = strQuery &"AND id<>13 "
			End if
			rec.open strQuery,conn,3,3
			Do While Not rec.eof
				If rec("id") <> 11 Or (rec("id")=11 And session("hasReg") And session("regRegistrar")) then				
					Set rec2 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT id FROM userNotificationOptions WHERE userId="&SQLClean(session("userId"),"N","S") & " AND notificationTypeId="&SQLClean(rec("id"),"N","S") & " AND enabled=0"
					rec2.open strQuery,conn,3,3
					If rec2.eof Then
						checked = true
					Else
						checked = false
					End If
					rec2.close
					Set rec2 = Nothing
					Set rec2 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT id FROM userNotificationOptions WHERE userId="&SQLClean(session("userId"),"N","S") & " AND notificationTypeId="&SQLClean(rec("id"),"N","S") & " AND email=1"
					rec2.open strQuery,conn,3,3
					If rec2.eof Then
						checkedEmail = false
					Else
						checkedEmail = true
					End If
					rec2.close
					Set rec2 = nothing
				%>
					<tr>
						<td class="caseInnerTitle" valign="top" style="width:180px;">
							<%Select case interfaceLanguage%>
								<%Case "Chinese"%>
									<%=rec("notificationTypeChinese")%>
								<%Case "Japanese"%>
									<%=rec("notificationTypeJapanese")%>
								<%Case else%>
									<%=rec("notificationType")%>
							<%End select%>	
						</td>
						<td class="caseInnerData" style="width:80px;" align="center">
							<input type="checkbox" name="notificationType-<%=rec("id")%>" <%If checked then%>CHECKED<%End if%> style="width:20px;margin-left:10px;">
						</td>
						<td class="caseInnerData" style="width:80px;" align="center">
							<input type="checkbox" name="notificationType-<%=rec("id")%>-email" <%If checkedEmail then%>CHECKED<%End if%> style="width:20px;margin-left:10px;">
						</td>
					</tr>
			<%
				End if
				rec.movenext
			loop
			%>
			</table>
					<input type="submit" value="<%=saveButtonLabel%>" class="btn" name="notificationsSubmit">
			</form>

		</div>
</div>