<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
mailServerAddress = getCompanySpecificSingleAppConfigSetting("mailServerAddress", session("companyId"))
globalSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("globalSupportEmailAddress", session("companyId"))
sectionId = "tool"
subSectionId = "admin-users"
pageTitle = "Arxspan Manage Users"
%>
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("roleNumber") <> 0 Then
	response.redirect(loginScriptName)
End if
%>

<%

sendUserEmailsFromNotProd = checkBoolSettingForCompany("sendUserEmailsFromNonProdEnvironments", session("companyId"))
rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
Const dbName = 0
Const formName = 1
Const formType = 2
Const formLabel = 3
Const listLabel = 4
Const sqlType = 5
Const validationFunction = 6
Const searchEnabled = 7
Const addEnabled = 8
Const listEnabled = 9
Const sortEnabled = 10
Const editEnabled = 11
Const HTML = 12
Const dispSQL = 13
Const defaultValue = 14

'config setup
  
Dim fields(16)
fields(0) = split("id:pageId:text:Id:Id:number:none:false:false:false:true:false:$userId$:",":")
fields(1) = split("firstName:firstName:text:First Name*:First Name:text:notEmpty:true:true:true:true:true:$userId$:",":")
fields(2) = split("lastName:lastName:text:Last Name*:Last Name:text:notEmpty:true:true:true:true:true:$userId$:",":")
fields(3) = split("email:email:text:email*:email:text:validateEmail:true:true:true:true:true:$userId$:",":")
fields(4) = split("companyId:companyId:select*companies*id*name:Company*:Company:number:notEmpty:false:true:true:true:true:$state$:name*SELECT name from companies WHERE id=$companyId$:",":")
'fields(4) = split("groupId:company:select*groups*id*name:Group:Group:text:notEmpty:false:true:true:true:true:$userId$:name*SELECT name from groups where id=$groupId$",":")
fields(5) = split("title:title:text:Title:Title:text:none:true:true:true:true:true:$userId$:",":")
fields(6) = split("address:address:text:Address:Address:text:none:false:true:false:false:true:$userId$:",":")
fields(7) = split("city:city:text:City:City:text:none:false:true:false:false:true:$userId$:",":")
fields(8) = split("state:state:text:State:State:text:none:false:true:false:false:true:$userId$:",":")
fields(9) = split("zip:zip:text:Zip:Zip:text:none:false:true:false:false:true:$userId$:",":")
fields(10) = split("country:country:text:Country:Country:text:none:false:true:false:false:true:$userId$:",":")
fields(11) = split("phone:phone:text:Phone:Phone:text:none:false:true:false:false:true:$userId$:",":")
'pw_stuff
fields(12) = Split("password:password:password:Password*:Password:password:match:false:true:false:false:true::",":")
fields(13) = Split("none:passwordmatch:password:Confirm Password*:Password:text:none:false:true:false:false:true::",":")
fields(14) = split("roleId:role:select*adminRoles*id*name:Role*:Role:number:notEmpty:false:true:true:true:true:$state$:name*SELECT name from adminRoles WHERE id=$roleId$:",":")
fields(15) = Split("none:resetPassword:resetPassword:Reset Password:Reset&nbsp;Password:text:none:false:false:true:false:false:<a href='"&mainAppPath&"/users/admin-reset-password.asp?id=$id$'>Reset&nbsp;Password</a>:",":")
fields(16) = split("enabled:enabled:select*yesno*num*display:Enabled*:Enabled:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:",":")
'fields(15) = split("companyId:companyId:text:Added By:Added By:number:none:false:true*hidden:false:true:false:$userId$::"&session("companyId"),":")


'editScroll = "false"
'noList = "true"
'redirect = "true"
'hideDelete = "true"
'hideExpander = "true"
dateCreatedKey = "dateOfSignup"
updateKey = "id"
deleteKey = "id"
defaultSort = "id"
tableName = "users"
viewName = "users"
handleClickId = "id"
tableTitle = "Users"
addNewItemText = "Add a New User"
addButtonText = "Add User"

'globalFilterKey = "companyId"
'globalFilterValue = session("companyId")

'inline | table
addNewDisplay = "table"

pageAddItemEnabled = "true"
pageSearchEnabled = "true"

pageTitle = "Users "

localSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("localSupportEmailAddress", session("companyId"))
%>

<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->
<div id="xtranetDiv">
<h1>Users</h1>

<!-- #INCLUDE virtual="/arxlab/admin/cmshead.asp" -->
<!-- #INCLUDE virtual="/arxlab/admin/cmsbody.asp" -->
</div>
</div>
<!--#include file="../_inclds/footer-tool.asp"-->
<%
if recordUpdated = true then
	if preUpdate("enabled")="0" and postUpdate("enabled") = "1" then
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
			mailObj.replyTo = session("email")
		else
			mailObj.From = session("email")
		End if
		If whichServer = "PROD" or sendUserEmailsFromNotProd then
			mailObj.To = postUpdate("email")
		Else
			mailObj.To = globalSupportEmailAddress
		End if
		mailObj.bcc = globalSupportEmailAddress
		mailObj.Subject = "Your Arxspan ELN Account"
		bodyText = "Hello "&postUpdate("firstName")&" "&postUpdate("lastName")&","&vbcrlf&vbcrlf&"Your account has been reactivated by "&session("firstName") & " " & session("lastName")&".  You can login at https://"&rootAppServerHostName&loginScriptName&" using your email address: "&postUpdate("email")&".  If you need to reset your password please email "&session("email")&vbcrlf&vbcrlf&"Please contact "&localSupportEmailAddress&" if you need further assistance."&vbcrlf&vbcrlf&"Thank You,"&vbcrlf&vbcrlf&"The Arxspan Support Team"
		If whichServer <> "PROD" Then
			bodyText = bodyText & vbcrlf & vbcrlf & postUpdate("email")
		End if
		mailObj.textBody = bodyText
		mailObj.Send
	end if
end If
if recordAdded = true Then
	if postUpdate("enabled") = "1" Then
		Call getconnectedadm
		Set rec3 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM users WHERE email="&SQLClean(postUpdate("email"),"T","S")
		rec3.open strQuery,connAdm,3,3
		counter = 0
		Do While Not rec3.eof
			counter = counter + 1
			rec3.movenext
		loop
		If counter=1 Then
			userExists = False
		Else
			userExists = True
		End If
		rec3.close
		Set rec3 = Nothing
		If Not userExists Then
			'pw_stuff
			strQuery = "INSERT into passwords(email,password) values("&SQLClean(postUpdate("email"),"T","S")&","&SQLClean(postUpdate("password"),"PW","S")&")" 
			connAdm.execute(strQuery)
		Else
			strQuery = "UPDATE users set mustChangePassword=0 WHERE id="&SQLClean(newId,"N","S")
			connAdm.execute(strQuery)
		End if
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
			mailObj.replyTo = session("email")
		else
			mailObj.From = session("email")
		End if	
		If whichServer = "PROD" or sendUserEmailsFromNotProd then
			mailObj.To = postUpdate("email")
		Else
			mailObj.To = globalSupportEmailAddress
		End if
		mailObj.bcc = globalSupportEmailAddress
		mailObj.Subject = "Your new Arxspan ELN Account"
		bodyText = "Hello "&postUpdate("firstName")&" "&postUpdate("lastName")&","&vbcrlf&vbcrlf&"A new account has been created for you by "&session("firstName") & " " & session("lastName")&".  You can login at https://"&rootAppServerHostName&loginScriptName&" using your email address: "&postUpdate("email")&"."
		If Not userExists then
			If companyUsesSso() And session("isSsoUser") Then
				bodyText = bodyText & "  Please use your employer supplied username and password when logging in."&vbcrlf&vbcrlf
			Else
				bodyText = bodyText & "  Your temporary password is: "& postUpdate("password")&vbcrlf&vbcrlf
			End If
		else
			bodyText = bodyText & "  You may continue to use your current password."&vbcrlf&vbcrlf
		End if
		bodyText = bodyText & "Please contact "&localSupportEmailAddress&" if you need further assistance."&vbcrlf&vbcrlf&"Thank You,"&vbcrlf&vbcrlf&"The Arxspan Support Team"
		If whichServer <> "PROD" Then
			bodyText = bodyText & vbcrlf & vbcrlf & postUpdate("email")
		End if
		mailObj.textBody = bodyText
		mailObj.Send
	end if
end If
%>