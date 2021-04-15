<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
regEnabled = true
%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
call getconnected
id = request.querystring("id")
set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT * FROM notificationsView WHERE companyId=" & SQLClean(session("companyId"),"N","S") & " AND id>"&SQLClean(id,"N","S")&" AND userId="&SQLClean(session("userId"),"N","S")& " ORDER BY id ASC"
rec.open strQuery,conn,3,3
if not rec.eof then
	If Not IsNull(rec("title")) Then
		title = rec("title")
	Else
		title = ""
	End if
	If rec("notificationType") = 1 Then
		Set tRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT DISTINCT commenterName FROM commentNotificationsView WHERE userId="&SQLClean(session("userId"),"N","S") & " AND experimentType="&SQLClean(rec("experimentType"),"N","S") & " AND experimentId="&SQLClean(rec("experimentId"),"N","S")
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
		prefix = GetPrefix(rec("experimentType"))
		page = GetExperimentPage(prefix)
		
		page = mainAppPath & "/" & page
		notification = notification & "<a href='"&page&"?id="&rec("experimentId")&"'>"&rec("experimentName")&"</a>"

		tRec.close
		title = "Comment Added"
	else
		notification = rec("notification")
	End if
	%>
	<div id="notification_body_<%=rec("id")%>" class="notificationBody<%If rec("dismissed") = 1 then%> dismissed<%End if%>" onMouseOver="clearNotificationTO = window.setTimeout('clearNotification(\'<%=rec("id")%>\')',750)" onMouseOut="clearTimeout(clearNotificationTO)">
	<span class="notificationBodyTitle" onclick="document.getElementById('notification_<%=rec("id")%>_body').style.display='none';document.getElementById('notification_<%=rec("id")%>_title').style.display='block';"><%=title%>: </span>
	<span class="noteText">
	<%=notification%>
	</span>
	</div>
<%
end If
rec.close
Set rec = nothing
call disconnect
response.end
%>