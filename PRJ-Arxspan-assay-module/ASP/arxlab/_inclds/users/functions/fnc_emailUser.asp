<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
mailServerAddress = getCompanySpecificSingleAppConfigSetting("mailServerAddress", session("companyId"))

function emailUser(userId,subject,msg)
	On Error Resume next
	set mailObj = Server.CreateObject("CDO.Message")
	'mailObj.Host = mailServerAddress ' Required
	mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = mailServerAddress
	mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
	mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = False
	mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
	mailObj.Configuration.Fields.Update
	mailObj.From = "notifications@arxspan.com"
	'mailObj.FromName = "Arxspan Notification"
	'mailObj.isHTML = true

	usersTable = getDefaultSingleAppConfigSetting("usersTable")
	Set recEmail = Server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT email FROM "&usersTable&" where id="&SQLClean(userId,"N","S")& " AND enabled=1"
	recEmail.open strQuery,connAdm,3,3
	If Not recEmail.eof then
		mailObj.To = recEmail("email")
	End if
	mailObj.Subject = subject
	mailObj.htmlBody = msg
	mailObj.Send
	strQuery = "INSERT into emailsSent(emailRecipient,message,companyId) values(" &_
				SQLClean(recEmail("email"),"T","S") & "," &_
				SQLClean(msg,"T","S") & "," &_
				SQLClean(session("companyId"),"N","S")&")"
	connAdm.execute(strQuery)
	On Error goto 0
	emailUser = "done"
end function
%>