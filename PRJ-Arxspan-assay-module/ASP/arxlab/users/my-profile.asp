<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
subSectionId = "my-profile"
response.charset = "UTF-8"
response.codePage = 65001
%>
<!-- #include file="../_inclds/globals.asp" -->


<%
usersTable = getDefaultSingleAppConfigSetting("usersTable")
usersTablePasswordField = getDefaultSingleAppConfigSetting("usersTablePasswordField")
If request.Form("passwordSubmit") <> "" Then
	Call getconnectedadm
	Set rec = server.CreateObject("ADODB.RecordSet")
	'pw_stuff
	strQuery = "SELECT * from passwords WHERE "&usersTablePasswordField&"="&SQLClean(request.Form("current"),"PW","S") & " AND email="&SQLClean(session("email"),"T","S")
	rec.open strQuery,connadm,3,3
	If Not rec.eof Then
		if request.form("new") <> request.form("confirm") then
			errString = "Passwords do not match"
		End If
		If request.Form("new") = request.Form("current") Then
			errString = "New password cannot be the same as your old password"
		End if
		policy = false
		Set myRegExp = New RegExp
		myRegExp.IgnoreCase = False
		myRegExp.Global = True
		myRegExp.Pattern = session("passwordRegEx")
		Set matches = myRegExp.execute(request.Form("new"))							
		If matches.count > 0 Then
			policy = true
		End If
		If Not policy Then
			errString = session("passwordMessage")
		End If
		policy = True
		myRegExp.Pattern = "([^\dA-Za-z@#$%^&+=_])"
		Set matches = myRegExp.execute(request.form("new"))
		If matches.count > 0 Then
			policy = false
		End If
		If Not policy Then
			errString = "Password may only contain alphanumeric characters and @#$%^&+=_"							
		End if

	Else
		errString = "Current Password Incorrect"
	End if

	If errString = "" Then
		'pw_stuff
		connAdm.execute("UPDATE passwords set "&usersTablePasswordField&"="&SQLClean(request.Form("new"),"PW","S") & " WHERE email="&SQLClean(session("email"),"T","S"))
		response.redirect(mainAppPath&"/users/my-profile.asp?m=1")
	End if
End if
%>
<%
If request.Form("optionsSubmit") <> "" Then
	Call getconnectedadm
	
	if request.Form("chemicalEditor") = "0" then 'Live Edit
		strQuery = "UPDATE "&usersTable&" SET useChemdrawPlugin=0, useMarvin=0 WHERE id="&SQLClean(session("userId"),"N","S")
		connAdm.execute(strQuery)
		session("useMarvin") = false
		session("noChemDraw") = true
		session("expPage") = "experiment_no_chemdraw.asp"
	elseif request.Form("chemicalEditor") = "1" then 'Chem Draw
		strQuery = "UPDATE "&usersTable&" SET useChemdrawPlugin=1, useMarvin=0 WHERE id="&SQLClean(session("userId"),"N","S")
		connAdm.execute(strQuery)
		session("useMarvin") = false
		session("noChemDraw") = false
		session("expPage") = "experiment.asp"
	elseif request.Form("chemicalEditor") = "2" then 'Marvin
		strQuery = "UPDATE "&usersTable&" SET useChemdrawPlugin=0, useMarvin=1 WHERE id="&SQLClean(session("userId"),"N","S")
		connAdm.execute(strQuery)
		session("useMarvin") = true
		session("noChemDraw") = true
		session("expPage") = "experiment_no_chemdraw.asp"
	end if

	If IsNumeric(request.Form("defaultWitnessId")) Then
		strQuery = "UPDATE "&usersTable&" set defaultWitnessId="&SQLClean(request.Form("defaultWitnessId"),"N","S")& " WHERE id="&SQLClean(session("userId"),"N","S")
		connAdm.execute(strQuery)
		session("defaultWitnessId") = Int(request.Form("defaultWitnessId"))
	End if

	connAdm.execute("UPDATE users SET defaultMolUnits="&SQLClean(request.Form("defaultMolUnits"),"T","S")&" WHERE id="&SQLClean(session("userId"),"N","S"))
	session("defaultMolUnits") = request.Form("defaultMolUnits")
	
	If request.Form("defaultResults")>=10 And request.Form("defaultResults") <=50 Then
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM defaultNotebookResults WHERE userId="&SQLClean(session("userId"),"N","S")
		rec.open strQuery,connAdm,3,3
		If rec.eof Then
			connAdm.execute("INSERT into defaultNotebookResults(userId,numResults) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(request.Form("defaultResults"),"N","S")&")")
		Else
			connAdm.execute("UPDATE defaultNotebookResults SET numResults="&SQLClean(request.Form("defaultResults"),"N","S")&" WHERE userId="&SQLClean(session("userId"),"N","S"))
		End If
		rec.close
		Set rec = nothing
	End if

	userOptions.Set "leftNavSort",CStr(request.Form("leftNavSort"))
	saveUserOptions(userOptions)
	
	'ELN-447 Saving redirectToSignedPDFUser option
	If request.Form("redirectToSignedPDFUser") = "1" Then
		strQuery = "UPDATE "&usersTable&" SET redirectUserToSignedPDF=1 WHERE id="&SQLClean(session("userId"),"N","S")
		connAdm.execute(strQuery)
		session("redirectToSignedPDF") = true
	Else
		strQuery = "UPDATE "&usersTable&" SET redirectUserToSignedPDF=0 WHERE id="&SQLClean(session("userId"),"N","S")
		connAdm.execute(strQuery)
		session("redirectToSignedPDF") = false
	End If
	
	'INV-316 Yumanity multiple label printers
	If IsNumeric(request.Form("labelPrinterId")) Then
		If request.Form("labelPrinterId") = 0 Then
			strQuery = "UPDATE "&usersTable&" set labelPrinterId=null WHERE id="&SQLClean(session("userId"),"N","S")
		Else
			strQuery = "UPDATE "&usersTable&" set labelPrinterId="&SQLClean(request.Form("labelPrinterId"),"N","S")& " WHERE id="&SQLClean(session("userId"),"N","S")
		End If
		connAdm.execute(strQuery)
	End if
	Call disconnectadm
	response.redirect(mainAppPath&"/users/my-profile.asp?r=1")
End if
%>

<%
If request.Form("notificationsSubmit") <> "" Then
	Call getconnectedadm
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM notificationTypes WHERE 1=1 "
	If Not session("hasMUFExperiment") Then
		strQuery = strQuery &"AND id<>13 "
	End if
	rec.open strQuery,conn,3,3
	Do While Not rec.eof
		If rec("id") <> 11 Or (rec("id")=11 And session("hasReg") And session("regRegistrar")) then		
			If request.Form("notificationType-"&rec("id")) = "on" And request.Form("notificationType-"&rec("id")&"-email") = "on" Then
				strQuery = "DELETE from userNotificationOptions WHERE userId="&SQLClean(session("userId"),"N","S") & " AND notificationTypeId=" & SQLClean(rec("id"),"N","S")
				connAdm.execute(strQuery)
				strQuery = "INSERT into userNotificationOptions(userId,notificationTypeId,enabled,email) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(rec("id"),"N","S")&",1,1)"
				connAdm.execute(strQuery)
			End If
			If request.Form("notificationType-"&rec("id")) = "on" And request.Form("notificationType-"&rec("id")&"-email") <> "on" Then
				strQuery = "DELETE from userNotificationOptions WHERE userId="&SQLClean(session("userId"),"N","S") & " AND notificationTypeId=" & SQLClean(rec("id"),"N","S")
				connAdm.execute(strQuery)
				strQuery = "INSERT into userNotificationOptions(userId,notificationTypeId,enabled,email) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(rec("id"),"N","S")&",1,0)"
				connAdm.execute(strQuery)
			End If
			If request.Form("notificationType-"&rec("id")) <> "on" And request.Form("notificationType-"&rec("id")&"-email") = "on" Then
				strQuery = "DELETE from userNotificationOptions WHERE userId="&SQLClean(session("userId"),"N","S") & " AND notificationTypeId=" & SQLClean(rec("id"),"N","S")
				connAdm.execute(strQuery)
				strQuery = "INSERT into userNotificationOptions(userId,notificationTypeId,enabled,email) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(rec("id"),"N","S")&",0,1)"
				connAdm.execute(strQuery)
			End If
			If request.Form("notificationType-"&rec("id")) <> "on" And request.Form("notificationType-"&rec("id")&"-email") <> "on" Then
				strQuery = "DELETE from userNotificationOptions WHERE userId="&SQLClean(session("userId"),"N","S") & " AND notificationTypeId=" & SQLClean(rec("id"),"N","S")
				connAdm.execute(strQuery)
				strQuery = "INSERT into userNotificationOptions(userId,notificationTypeId,enabled,email) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(rec("id"),"N","S")&",0,0)"
				connAdm.execute(strQuery)
			End if
		End if
		rec.movenext
	loop
	Call disconnectadm
	response.redirect(mainAppPath&"/users/my-profile.asp?x=1")
End if
%>


<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<%
Call getconnected
Set userRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM usersView WHERE id="&SQLClean(session("userId"),"N","S")
userRec.open strQuery,conn,3,3
If Not userRec.eof then
%>

<table style="width:100%;margin-top:25px;">
<tr>
<td valign="top">
<!-- #include file="../_inclds/users/profile/html/userData.asp"-->
</td>

<%'QQQ START REMOVE FOR H3%>
<td valign="top" style="padding-left:10px;">
<%If session("hasELN") then%>
<!-- #include file="../_inclds/users/profile/html/notifications.asp"-->
<%End if%>
</td>
<%'QQQ END REMOVE FOR H3%>

</tr>
</table>


<table style="width:100%;margin-top:25px;">
<tr>
<td valign="top">
<!-- #include file="../_inclds/users/profile/html/changePassword.asp"-->
</td>

<%'QQQ START REMOVE FOR H3%>
<td valign="top" style="padding-left:10px;">
<%If session("hasELN") then%>
<!-- #include file="../_inclds/users/profile/html/options.asp"-->
<%End if%>
</td>
<%'QQQ END REMOVE FOR H3%>

</tr>
</table>
<iframe src="<%=mainAppPath%>/table_pages/frame-show-my-users.asp" style="background-color:#DFDFDF;width:100%;height:100px;border:none;" name="groupNotebookFrame" id="groupNotebookFrame" scrolling="no" frameborder="0"></iframe>
<%end if%>

<!-- #include file="../_inclds/footer-tool.asp"-->