<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
function sendNotification(userId,ByVal title,ByVal notification,notificationType)

	rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
	Dim nRec
	Set nRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM userNotificationOptions WHERE userId=" & SQLClean(userId,"N","S") & " AND notificationTypeId="&SQLClean(notificationType,"N","S") & " AND enabled=0"
	nRec.open strQuery,connAdm,3,3
	If nRec.eof then
		strQuery = "INSERT into notifications(userId,title,notification,dateAdded,dateAddedServer) values("&_
		SQLClean(userId,"N","S") & "," &_
		SQLClean(title,"T","S") & "," &_
		SQLClean(notification,"T","S") & "," &_
		"GETUTCDATE(),GETDATE())"
		connAdm.execute(strQuery)
	End if	
	nRec.close
	Set nRec = Nothing

	Set nRec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM userNotificationOptions WHERE userId=" & SQLClean(userId,"N","S") & " AND notificationTypeId="&SQLClean(notificationType,"N","S") & " AND email=1"
	nRec2.open strQuery,connAdm,3,3
	If Not nRec2.eof Then
		If InStr(notification,mainAppPath) then
			a = emailUser(userId,"ARXSPAN - You have received a new notification.",Replace(Replace(notification,"href="""&mainAppPath&"/","href=""https://"&rootAppServerHostName&mainAppPath&"/"),"href='"&mainAppPath&"/","href='https://"&rootAppServerHostName&mainAppPath&"/"))
		else
			a = emailUser(userId,"ARXSPAN - You have received a new notification.",Replace(Replace(notification,"href=""","href=""https://"&rootAppServerHostName&mainAppPath&"/"),"href='","href='https://"&rootAppServerHostName&mainAppPath&"/"))
		End if
	End If
	nRec2.close
	Set nRec2 = nothing
end function
%>