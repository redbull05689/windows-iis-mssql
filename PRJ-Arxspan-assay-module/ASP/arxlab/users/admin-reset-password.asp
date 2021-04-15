<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
mailServerAddress = getCompanySpecificSingleAppConfigSetting("mailServerAddress", session("companyId"))
globalNotificationEmailAddress = getCompanySpecificSingleAppConfigSetting("globalNotificationEmailAddress", session("companyId"))
globalSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("globalSupportEmailAddress", session("companyId"))
subSectionId = "force-change-password"

localSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("localSupportEmailAddress", session("companyId"))
rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
%>
<!-- #include file="../_inclds/globals.asp" -->


<%
sendUserEmailsFromNotProd = checkBoolSettingForCompany("sendUserEmailsFromNonProdEnvironments", session("companyId"))
If request.Form("action") <> "view" and request.Form("action") <> "email" Then
	response.write "failure1"
	response.end
Else
	If session("roleNumber") = 1 Or session("roleNumber") = 0 Or session("roleNumber") = 2 Or session("roleNumber") = 3 Then
		usersTable = getDefaultSingleAppConfigSetting("usersTable")
		Call getconnectedadm
		Set rec = server.CreateObject("ADODB.RecordSet")
		If session("roleNumber") = 1 Or session("roleNumber") = 0 then
			If session("roleNumber") = 0 Then
				strQuery = "SELECT * from "&usersTable&" WHERE id="&SQLClean(request.Form("userId"),"N","S")
			else
				strQuery = "SELECT * from "&usersTable&" WHERE id="&SQLClean(request.Form("userId"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
			End if
		Else
			strQuery = "SELECT * from "&usersTable&" WHERE id="&SQLClean(request.Form("userId"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")& " AND (userAdded="&SQLClean(session("userId"),"N","S")& " or userAdded in (SELECT id FROM users WHERE userAdded="&SQLClean(session("userId"),"N","S")&"))"
		End if
		rec.open strQuery,connadm,3,3
		If Not rec.eof Then
			If request.Form("tempPassword") <> "" Then
				newPW = request.Form("tempPassword")
			Else
				newPW = getRandomStringPassword(8)
				usersTablePasswordField = getDefaultSingleAppConfigSetting("usersTablePasswordField")
				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM passwords WHERE email="&SQLClean(rec("email"),"T","S")
				rec2.open strQuery,connAdm,3,3
				If rec2.eof Then
					'pw_stuff
					strQuery = "INSERT INTO passwords(email,"&usersTablePasswordField&") values("&SQLClean(rec("email"),"T","S")&","&SQLClean(newPW,"PW","S")&")"
				Else
					'pw_stuff
					strQuery = "UPDATE passwords set "&usersTablePasswordField&"="&SQLClean(newPW,"PW","S")&" WHERE email="&SQLClean(rec("email"),"T","S")
				End if
				connAdm.execute(strQuery)
				strQuery = "UPDATE "&usersTable&" SET loginAttempts=0,mustChangePassword=1 WHERE id="&SQLClean(rec("id"),"N","S")
				connAdm.execute(strQuery)
			End If
			
			
			' Either spit the password out to the admin or send it in an email to the user
			If request.Form("action") = "view" Then
				'SPIT OUT THE PASSWORD
				response.write newPW
				response.end
			ElseIf request.Form("action") = "email" Then
				' GENERATE AND SEND THE EMAIL
				set mailObj = Server.CreateObject("CDO.Message")
				'mailObj.Host = mailServerAddress ' Required
				mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
				mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = mailServerAddress
				mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
				mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = False
				mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
				mailObj.Configuration.Fields.Update
				If whichServer = "PROD" And (session("companyId")="35" Or session("companyId")="1") Then
					mailObj.From = globalSupportEmailAddress
					mailObj.ReplyTo = session("email")
				else
					mailObj.From = "support@arxspan.com"
					mailObj.ReplyTo = session("firstName")&" "&session("lastName")&"<"&session("email")&">"
					
				End if	
				If whichServer = "PROD" or sendUserEmailsFromNotProd then
					mailObj.To = rec("email")
				Else
					mailObj.To = globalNotificationEmailAddress
				End if
				mailObj.bcc = globalNotificationEmailAddress
				mailObj.Subject = "ELN Account Password"
				bodyText = "Hello "&rec("firstName")&" "&rec("lastName")&","&vbcrlf&vbcrlf&session("firstName") & " " & session("lastName")&" has reset your password.  You can login at https://"&rootAppServerHostName&loginScriptName&" using your email address: "&rec("email")&".  Your temporary password is: "& newPW&vbcrlf&vbcrlf&"Please contact "&localSupportEmailAddress&" if you need further assistance."&vbcrlf&vbcrlf&"Thank You,"&vbcrlf&vbcrlf&"The Arxspan Support Team"
				If whichServer <> "PROD" Then
					bodyText = bodyText & vbcrlf & vbcrlf & rec("email")
				End if
				mailObj.textBody = bodyText
				mailObj.Send
				If session("roleNumber") = 0 Or session("roleNumber") = 1 Or session("roleNumber") = 2 Or session("roleNumber") = 3 then%>
					<%
					Call getconnected
					Set userRec = server.CreateObject("ADODB.RecordSet")
					If session("roleNumber") = 0 Then
						strQuery = "SELECT * FROM usersView WHERE id="&SQLClean(request.Form("userId"),"N","S")
					else
						strQuery = "SELECT * FROM usersView WHERE id="&SQLClean(request.Form("userId"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
					End if
					userRec.open strQuery,conn,3,3

					If Not userRec.eof then %>
						<p>Password for user <%=userRec("firstName")%>&nbsp;<%=userRec("lastName")%> has been reset and an email containing their new password has been sent to their email address.</p>
					<%
					end If
					Call disconnect
				End If
				response.end
			Else
				response.write "failure4"
				response.end
			End If
		Else
			response.write "failure3"
			response.write strQuery
			response.end
		End If
	Else
		response.write "failure2"
		response.end
	End if
End If
%>