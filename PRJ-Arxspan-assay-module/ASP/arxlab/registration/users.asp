<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
mailServerAddress = getCompanySpecificSingleAppConfigSetting("mailServerAddress", session("companyId"))
globalSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("globalSupportEmailAddress", session("companyId"))
sectionId = "reg"
subSectionId = "reg-users"
pageTitle = "Arxspan Manage Users"
%>
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include file="../_inclds/globals.asp"-->

<%
If session("roleNumber") <> "1" And session("roleNumber") <> "0" And session("roleNumber") <> "2" And session("roleNumber") <> "3" Then
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
Dim fields()

If session("roleNumber") = "0" or session("roleNumber") = "1" then
fieldMax = 16
If session("hasInv") then
	fieldMax = fieldMax + 1
End If
reDim fields(fieldMax)
fields(0) = split("id:pageId:text:Id:Id:number:none:false:false:false:true:false:$userId$:",":")
fields(1) = Split("none:name:name:Name:Name:text:none:false:false:true:false:false:$firstName$ $lastName$:",":")
fields(2) = split("firstName:firstName:text:First Name*:First Name:text:notEmpty:true:true:false:true:true:$userId$:",":")
fields(3) = split("lastName:lastName:text:Last Name*:Last Name:text:notEmpty:true:true:false:true:true:$userId$:",":")
fields(4) = split("email:email:text:email*:email:text:validateEmail:true:true:true:true:true:$userId$:",":")
'fields(4) = split("groupId:company:select*groups*id*name:Group:Group:text:notEmpty:false:true:true:true:true:$userId$:name*SELECT name from groups where id=$groupId$",":")
fields(5) = split("title:title:text:Title:Title:text:none:true:true:true:true:true:$userId$:",":")
fields(6) = split("address:address:text:Address:Address:text:none:false:true:false:false:true:$userId$:",":")
fields(7) = split("city:city:text:City:City:text:none:false:true:false:false:true:$userId$:",":")
fields(8) = split("state:state:text:State:State:text:none:false:true:false:false:true:$userId$:",":")
fields(9) = split("zip:zip:text:Zip:Zip:text:none:false:true:false:false:true:$userId$:",":")
fields(10) = split("country:country:text:Country:Country:text:none:false:true:false:false:true:$userId$:",":")
fields(11) = split("phone:phone:text:Phone:Phone:text:none:false:true:false:false:true:$userId$:",":")
fields(12) = split("enabled:enabled:select*yesno*num*display:Enabled*:Enabled:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
fields(13) = Split("none:resetPassword:resetPassword:Reset Password:Reset&nbsp;Password:text:none:false:false:true:false:false:<a href='"&mainAppPath&"/users/admin-reset-password.asp?id=$id$'>Reset&nbsp;Password</a>:",":")
fields(14) = split("regRoleNumber:regRoleNumber:select*regRoles*roleNumber*roleName:Registration Role:Registration Role:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:1",":")
fields(15) = split("canEditReg:canEditReg:select*yesno*num*display:Can Edit Reg*:Can Edit Reg:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$canEditReg$:0",":")
'fields(15) = split("userAdded:addedby:text:Manager:Manager:number:none:false:true*hidden:false:true:false:$userId$::"&session("userId"),":")
fields(16) = split("roleId:roleId:text:Manager:Manager:number:none:false:true*hidden:false:true:false:::6",":")
fieldNum = 16
If session("hasInv") Then
	fieldNum = fieldNum + 1
	fields(fieldNum) = split("invRoleNumber:invRoleNumber:select*invRoles*roleNumber*roleName:Inventory Role:Inventory Role:number::false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:4",":")
End if
Else
End if

updateKey = "id"
deleteKey = "id"
defaultSort = "id"
tableName = getDefaultSingleAppConfigSetting("usersTable")
viewName = "usersView"
handleClickId = "id"
tableTitle = "Users"
addNewItemText = "Add a New User"
addButtonText = "Add User"

'If session("roleNumber") = "1" then
'	viewExtra = "roleNumber >=1"
'End If
'If session("roleNumber") = "2" then
'	viewExtra = "roleNumber >2 and userAdded="&SQLClean(session("userId"),"N","S")
'End if
'If session("roleNumber") = "3" then
'	viewExtra = "roleNumber >3 and userAdded="&SQLClean(theUserId,"N","S")& " and id <>"&SQLClean(session("userId"),"N","S")
'End if

globalFilterKey = "companyId"
globalFilterValue = session("companyId")

'inline | table
addNewDisplay = "table"

pageAddItemEnabled = "true"
pageSearchEnabled = "true"

pageTitle = "Users "
%>

<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->

localSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("localSupportEmailAddress", session("companyId"))
<div id="xtranetDiv">
<h1>Users</h1>

<!-- #INCLUDE virtual="/arxlab/admin/cmshead.asp" -->
<!-- #INCLUDE virtual="/arxlab/admin/cmsbody.asp" -->
</div>
</div>

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
		mailObj.Subject = "Your ELN Account"
		bodyText = "Hello "&postUpdate("firstName")&" "&postUpdate("lastName")&","&vbcrlf&vbcrlf&"Your ELN account has been reactivated by "&session("firstName") & " " & session("lastName")&".  You can login at https://"&rootAppServerHostName&loginScriptName&" using your email address: "&postUpdate("email")&".  If you need to reset your password please email "&session("email")&vbcrlf&vbcrlf&"Please contact "&localSupportEmailAddress&" if you need further assistance."&vbcrlf&vbcrlf&"Thank You,"&vbcrlf&vbcrlf&"The Arxspan Support Team"
		If whichServer <> "PROD" Then
			bodyText = bodyText & vbcrlf & vbcrlf & postUpdate("email")
		End if
		mailObj.textBody = bodyText
		mailObj.Send
	end if
end If
if recordAdded = true then
	if postUpdate("enabled") = "1" Then
		Call getconnectedadm
		newPW = getRandomStringPassword(8)
		Set rec3 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM "&usersTable&" WHERE email="&SQLClean(postUpdate("email"),"T","S")
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
			strQuery = "INSERT into passwords(email,password) values("&SQLClean(postUpdate("email"),"T","S")&","&SQLClean(newPW,"PW","S")&")" 
			connAdm.execute(strQuery)
		Else
			strQuery = "UPDATE "&usersTable&" set mustChangePassword=0 WHERE id="&SQLClean(newId,"N","S")
			connAdm.execute(strQuery)
		End If
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
		mailObj.Subject = "Your new ELN Account"
		bodyText = "Hello "&postUpdate("firstName")&" "&postUpdate("lastName")&","&vbcrlf&vbcrlf&"A new ELN account has been created for you by "&session("firstName") & " " & session("lastName")&".  You can login at https://"&rootAppServerHostName&loginScriptName&" using your email address: "&postUpdate("email")&"."
		If Not userExists then
			bodyText = bodyText & "  Your temporary password is: "& newPW&vbcrlf&vbcrlf
		Else
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
<!--#include file="../_inclds/footer-tool.asp"-->