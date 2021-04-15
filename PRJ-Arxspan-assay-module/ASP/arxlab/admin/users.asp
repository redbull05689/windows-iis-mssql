<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
ssoFolderName = getCompanySpecificSingleAppConfigSetting("ssoFolderPathName", Session("companyId"))
ssoLoginPath = getCompanySpecificSingleAppConfigSetting("ssoLoginPath", Session("companyId"))
mailServerAddress = getCompanySpecificSingleAppConfigSetting("mailServerAddress", session("companyId"))
globalNotificationEmailAddress = getCompanySpecificSingleAppConfigSetting("globalNotificationEmailAddress", session("companyId"))
globalSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("globalSupportEmailAddress", session("companyId"))
sectionId = "tool"
subSectionId = "users"
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
	''412015
	fieldMax = 26
	''//412015
	If session("useSafe") Then
		fieldMax = fieldMax + 1
	End if
	If session("hasReg") then
		fieldMax = fieldMax + 2
	End If
	If session("hasInv") then
		fieldMax = fieldMax + 1
	End If
	If session("hasAssay") then
		fieldMax = fieldMax + 1
	End If
	If session("ipBlock") Then
		fieldMax = fieldMax + 1
	End If
	If session("companyHasChemistry") And session("canChangeHasChemistry") Then
		fieldMax = fieldMax + 1
	End If
	If session("companyHasFT") Then
		fieldMax = fieldMax + 1
	End If
	If companyUsesSso() Then
		fieldMax = fieldMax + 1
	End If
	If session("hasOrdering") then
		fieldMax = fieldMax + 1
	end if
	ReDim fields(fieldMax)

	fields(0) = split("id:pageId:text:Id:Id:number:none:false:false:false:true:false:$userId$:",":")
	fields(1) = Split("none:name:name:Name:Name:text:none:false:false:true:false:false:$firstName$ $lastName$:",":")
	fields(2) = split("firstName:firstName:text:First Name*:First Name:text:notEmpty:true:true:false:true:true:$userId$:",":")
	fields(3) = split("lastName:lastName:text:Last Name*:Last Name:text:notEmpty:true:true:false:true:true:$userId$:",":")
	fields(4) = split("email:email:text:email*:email:text:validateEmail:true:true:true:true:false:$userId$:",":")
	'fields(4) = split("groupId:company:select*groups*id*name:Group:Group:text:notEmpty:false:true:true:true:true:$userId$:name*SELECT name from groups where id=$groupId$",":")
	fields(5) = split("title:title:text:Title:Title:text:none:true:true:true:true:true:$userId$:",":")
	fields(6) = split("address:address:text:Address:Address:text:none:false:true:false:false:true:$userId$:",":")
	fields(7) = split("city:city:text:City:City:text:none:false:true:false:false:true:$userId$:",":")
	fields(8) = split("state:state:text:State:State:text:none:false:true:false:false:true:$userId$:",":")
	fields(9) = split("zip:zip:text:Zip:Zip:text:none:false:true:false:false:true:$userId$:",":")
	fields(10) = split("country:country:text:Country:Country:text:none:false:true:false:false:true:$userId$:",":")
	fields(11) = split("phone:phone:text:Phone:Phone:text:none:false:true:false:false:true:$userId$:",":")
	fields(12) = split("roleId:role:select*adminRoles*id*name:Role*:Role:number:notEmpty:false:true:true:true:true:$state$:name*SELECT name from adminRoles WHERE id=$roleId$:",":")
	fields(13) = split("none:groupId:select*groups*id*name****groupMembers*userId*GroupId:Groups:Groups:number:none:false:true:false:true:true::@:",":")
	fields(14) = split("enabled:enabled:select*yesno*num*display:Enabled*:Enabled:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
	fields(15) = split("userAdded:userAdded:select*groupAdminUsers*id*fullName:Manager:Manager:number:none:false:true:false:false:true:$state$::"&session("userId"),":")
	fields(16) = Split("none:resetPassword:resetPassword:Reset Password:Reset&nbsp;Password:text:none:false:false:true:false:false:<a class=""showResetPasswordPopup"" onclick=""changePwUserId='$id$';showPopup('resetPasswordPopup');"" href='#'>Reset&nbsp;Password</a>:",":")
	fields(17) = split("canLeadProjects:canLeadProjects:select*yesno*num*display:Can Lead Projects:Can Lead Projects:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
	fields(18) = split("canDelete:canDelete:select*yesno*num*display:Can Delete:Can Delete:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	fields(19) = split("canViewSiblings:canViewSiblings:select*yesno*num*display:Can View Siblings:Can View Siblings:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	fields(20) = split("canViewEveryOne:canViewEveryone:select*yesno*num*display:Can View Everyone:Can View Everyone:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	fields(21) = split("useChemdrawPlugin:useChemdrawPlugin:select*yesno*num*display:Use ChemDraw&#8482;:Use ChemDraw&#8482;:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
	''412015
	fields(22) = split("canReopen:canReopen:select*yesno*num*display:Can Reopen:Can Reopen:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	fields(23) = split("canEditTemplates:canEditTemplates:select*yesno*num*display:Can Edit Templates:Can Edit Templates:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	fields(24) = split("cd14Fix:cd14Fix:select*yesno*num*display:CD 14 Compatibility Mode:CD 14 Compatibility Mode:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	fields(25) = split("canEditKeywords:canEditKeywords:select*yesno*num*display:Can Edit Keywords:Can Edit Keywords:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	fields(26) = split("allowAllNotebookPDFDownloads:allowAllNotebookPDFDownloads:select*yesno*num*display:Can Download All Notebook PDFs:Can Download All Notebook PDFs:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	fieldNum = 26
	''/412015
	If session("useSafe") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("softToken:softToken:select*yesno*num*display:Soft Token:Soft Token:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	End if
	If session("hasReg") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("regRoleNumber:regRoleNumber:select*regRoles*roleNumber*roleName:Registration Role:Registration Role:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:1000",":")
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("canEditReg:canEditReg:select*yesno*num*display:Can Edit Reg*:Can Edit Reg:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$canEditReg$:0",":")
	End If
	If session("hasInv") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("invRoleNumber:invRoleNumber:select*invRoles*roleNumber*roleName:Inventory Role:Inventory Role:number::false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:4",":")
	End if
	If session("hasAssay") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("assayRoleNumber:assayRoleNumber:select*assayRoles*roleNumber*roleName:Assay Role:Assay Role:number:none:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:4",":")
	End if
	If session("ipBlock") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("ipBlockMe:ipBlockMe:select*yesno*num*display:IP Block:IP Block:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
	End if
	If session("companyHasChemistry") And session("canChangeHasChemistry") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("userHasChemistry:userHasChemistry:select*yesno*num*display:Chemistry Enabled: Chemistry Enabled:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	End if
	If session("companyHasFT") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("userHasFT:userHasFT:select*yesno*num*display:User Can Use Search:User Can Use Search:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	End If
	If companyUsesSso() Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("isSsoUser:isSsoUser:select*yesno*num*display:Use SSO:Use SSO:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	End If
	If session("hasOrdering") then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("manageWorkflow:manageWorkflow:select*yesno*num*display:Manage Workflow:Manage Workflow:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	end if

Else
	If session("roleNumber") = "2" Then
		theUserId = session("userId")
	End If
	If session("roleNumber") = "3" Then
		theUserId = session("managerId")
	End If
	fieldMax = 20
	If session("useSafe") Then
		fieldMax = fieldMax + 1
	End if
	If session("hasReg") then
		fieldMax = fieldMax + 1
	End If
	If session("hasInv") then
		fieldMax = fieldMax + 1
	End If
	If session("hasAssay") then
		fieldMax = fieldMax + 1
	End If
	If session("hasOrdering") then
		fieldMax = fieldMax + 1
	End If
	ReDim fields(fieldMax)
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
	fields(12) = split("roleId:role:select*adminRoles*id*name:Role*:Role:number:notEmpty:false:true:true:true:true:$state$:name*SELECT name from adminRoles WHERE id=$roleId$:",":")
	fields(13) = split("none:groupId:select*groups*id*name****groupMembers*userId*GroupId:Groups:Groups:number:none:false:true:true:true:true::@:",":")
	fields(14) = split("enabled:enabled:select*yesno*num*display:Enabled*:Enabled:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
	fields(15) = split("userAdded:addedby:text:Manager:Manager:number:none:false:true*hidden:false:true:false:$userId$::"&theUserId,":")
	fields(16) = Split("none:resetPassword:resetPassword:Reset Password:Reset&nbsp;Password:text:none:false:false:true:false:false:<a class=""showResetPasswordPopup"" onclick=""changePwUserId='$id$';showPopup('resetPasswordPopup');"" href='#'>Reset&nbsp;Password</a>:",":")
	fields(17) = split("canLeadProjects:canLeadProjects:select*yesno*num*display:Can Lead Projects:Can Lead Projects:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
	fields(18) = split("canDelete:canDelete:select*yesno*num*display:Can Delete:Can Delete:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
	fields(19) = split("canViewSiblings:canViewSiblings:select*yesno*num*display:Can View Siblings:Can View Siblings:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	fields(20) = split("useChemdrawPlugin:useChemdrawPlugin:select*yesno*num*display:Use ChemDraw&#8482;:Use ChemDraw&#8482;:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
	fieldNum = 20
	If session("useSafe") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("softToken:softToken:select*yesno*num*display:Soft Token:Soft Token:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	End if
	If session("hasReg") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("regRoleNumber:regRoleNumber:select*regRoles*roleNumber*roleName:Registration Role:Registration Role:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:1000",":")
	End If
	If session("hasInv") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("invRoleNumber:invRoleNumber:select*invRoles*roleNumber*roleName:Inventory Role:Inventory Role:number::false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:4",":")
	End if
	If session("hasAssay") Then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("assayRoleNumber:assayRoleNumber:select*assayRoles*roleNumber*roleName:Assay Role:Assay Role:number:none:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:4",":")
	End if
	If session("hasOrdering") then
		fieldNum = fieldNum + 1
		fields(fieldNum) = split("manageWorkflow:manageWorkflow:select*yesno*num*display:Manage Workflow:Manage Workflow:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
	end if
End if

'editScroll = "false"
'noList = "true"
'redirect = "true"
'hideDelete = "true"
'hideExpander = "true"
dateCreatedKey = "dateOfSignup"
updateKey = "id"
deleteKey = "id"
defaultSort = "id"
tableName = getDefaultSingleAppConfigSetting("usersTable")
viewName = getDefaultSingleAppConfigSetting("usersView")
handleClickId = "id"
tableTitle = "Users"
'disallow gbt from adding users
addNewItemText = "Add a New User"
addButtonText = "Add User"
numberRows = True

If session("roleNumber") = "1" then
	viewExtra = "roleNumber >=1"
End If
If session("roleNumber") = "2" then
	viewExtra = "roleNumber >2 and (userAdded="&SQLClean(session("userId"),"N","S")& " or userAdded in (SELECT id FROM users WHERE userAdded="&SQLClean(session("userId"),"N","S")&"))"
End if
If session("roleNumber") = "3" then
	viewExtra = "roleNumber >3 and userAdded="&SQLClean(theUserId,"N","S")& " and id <>"&SQLClean(session("userId"),"N","S")
End if

If session("email") <> "support@arxspan.com" Then
	supportCheck = "email <> 'support@arxspan.com'"
	If viewExtra <> "" Then
		viewExtra = viewExtra & " AND " & supportCheck
	Else 
		viewExtra = viewExtra & supportCheck
	End If 
End If

globalFilterKey = "companyId"
globalFilterValue = session("companyId")

'inline | table
addNewDisplay = "table"


pageAddItemEnabled = "true"
pageSearchEnabled = "true"

pageTitle = "Users "

localSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("localSupportEmailAddress", session("companyId"))
defaultUserToNotificationForNotebookShareInvite = checkBoolSettingForCompany("optInNewUsersToNotebookShareInvites", session("companyId"))
%>

<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->
<div id="xtranetDiv">
<h1>Users</h1>

<!-- #INCLUDE virtual="/arxlab/admin/cmshead.asp" -->
<!-- #INCLUDE virtual="/arxlab/admin/cmsbody.asp" -->
</div>
</div>
<div class="resetPasswordPopup popupBox" id="resetPasswordPopup" style="width: 400px;">
	<form class="popupForm" action="">
		<div class="popupFormHeader">Reset Password</div>
		<div class="popupFormDescText" style="padding-top:15px;text-align:center;"></div>
		<section class="bottomButtons" style="padding-top:15px;padding-left:12px;">
			<button class="closeButton" style="display: none;" type="button">Close</button>
			<button class="viewPasswordButton enabled" type="button">View Password</button>
			<button class="emailPasswordButton primaryActionButton enabled" type="button">Email Password</button>
		</section>
	</form>
</div>

<script type="text/javascript">
	$(document).ready(function () {
		$('.showResetPasswordPopup').on('click',function(event){
			tempPassword = ""
			$('#resetPasswordPopup .popupFormDescText').text('');
			$('#resetPasswordPopup .closeButton').hide();
			$('#resetPasswordPopup .viewPasswordButton').show();
			$('#resetPasswordPopup .emailPasswordButton').show();
		});
		$('#resetPasswordPopup .viewPasswordButton').on('click',function(event){
			$.ajax({
				url: '<%=mainAppPath%>/users/admin-reset-password.asp',
				type: 'POST',
				dataType: 'html',
				data: {userId: changePwUserId, action: "view", tempPassword: tempPassword},
			})
			.done(function(response) {
				$('#resetPasswordPopup .popupFormDescText').html('<span>Temporary Password:</span><div class="passwordRevealed" style="background: #fff;display: inline-block;margin-left: 7px;font-size: 15px;padding: 5px;">'+response+'</div>');
				tempPassword = response;
			})
			.fail(function() {

			})
			.always(function() {
				$('#resetPasswordPopup .viewPasswordButton').hide();
				$('#resetPasswordPopup .emailPasswordButton').show();
				$('#resetPasswordPopup .closeButton').show();
			});
		});
		$('#resetPasswordPopup .emailPasswordButton').on('click',function(event){
			$.ajax({
				url: '<%=mainAppPath%>/users/admin-reset-password.asp',
				type: 'POST',
				dataType: 'html',
				data: {userId: changePwUserId, action: "email", tempPassword: tempPassword},
			})
			.done(function(response) {
				$('#resetPasswordPopup .popupFormDescText').html('<span>'+response+'</span');
			})
			.fail(function() {
				
			})
			.always(function() {
				tempPassword = ""
				$('#resetPasswordPopup .viewPasswordButton').hide();
				$('#resetPasswordPopup .emailPasswordButton').hide();
				$('#resetPasswordPopup .closeButton').show();
			});
		});
		$('.closeButton').on('click',function(event){
			hidePopup('resetPasswordPopup');
		});		
	})
</script>


<!--#include file="../_inclds/footer-tool.asp"-->
<%
if recordUpdated = true then
	if preUpdate("enabled")="0" and postUpdate("enabled") = "1" then
		If session("roleNumber") <> "0" And session("companyId")<>"1" And session("email")<>"support@arxspan.com" And session("email")<>"amanda.lashua@arxspan.com" Then
			Call getconnectedadm
			strQuery = "UPDATE users SET enabled=0 WHERE id="&SQLClean(updateId,"N","S")
			connAdm.execute(strQuery)
			a = logAction(0,0,"",18)
			Call disconnectadm
			title = "Update Error"
    		message = "Re-enabling users is not permitted.  Please contact arxspan support at support@arxspan.com"
			response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
		else
			a = logAction(0,updateId,"",22)
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
				mailObj.replyTo = postUpdate("email")
			else
				sendEmailsFromArxspanNet = checkBoolSettingForCompany("sendEmailsFromArxspanNet", session("companyId"))
				If sendEmailsFromArxspanNet <> 1 Then
					mailObj.From = session("email")
				Else
					mailObj.From = "support@arxspan.net"
					mailObj.ReplyTo = session("firstName")&" "&session("lastName")&"<"&session("email")&">"
				End if
			End if	
			If whichServer = "PROD" Or sendUserEmailsFromNotProd then
				mailObj.To =  postUpdate("email")
			Else
				mailObj.To =  globalSupportEmailAddress
			End if
			mailObj.bcc = globalSupportEmailAddress
			mailObj.Subject = "Your Arxspan ELN Account"
			bodyText = "Hello "&postUpdate("firstName")&" "&postUpdate("lastName")&","&vbcrlf&vbcrlf&"Your account has been reactivated by "&session("firstName") & " " & session("lastName")&".  You can login at https://"&rootAppServerHostName&loginScriptName&" using your email address: "&postUpdate("email")&".  If you need to reset your password please email "&session("email")&vbcrlf&vbcrlf&"Please contact "&localSupportEmailAddress&" if you need further assistance."&vbcrlf&vbcrlf&"Thank You,"&vbcrlf&vbcrlf&"The Arxspan Support Team"
			If whichServer <> "PROD" Then
				bodyText = bodyText & vbcrlf & vbcrlf & postUpdate("email")
			End if
			mailObj.textBody = bodyText
			If session("companyId")<>"4" then
				mailObj.Send
			End if
		End If
	Else
		If preUpdate("enabled")="1" and postUpdate("enabled") = "0" then
			a = logAction(0,updateId,"",23)
		End if
	end if
end If
if recordAdded = true then
	if postUpdate("enabled") = "1" Then
		Call getconnectedadm
		isSsoUser = False
		newPW = getRandomStringPassword(8)
		Set rec3 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT isSsoUser FROM users WHERE email=" & SQLClean(postUpdate("email"),"T","S")
		rec3.open strQuery,connAdm,adOpenStatic,adLockReadOnly

		If Not rec3.eof Then
			If rec3("isSsoUser")=1 Then
				isSsoUser = True
			End If
			
			If rec3.recordCount=1 Then
				userExists = False
			Else
				userExists = True
			End If
		End If
		rec3.close
		Set rec3 = Nothing
		
		If Not userExists Then
			'pw_stuff
			strQuery = "INSERT into passwords(email,password) values("&SQLClean(postUpdate("email"),"T","S")&","&SQLClean(newPW,"PW","S")&")" 
			connAdm.execute(strQuery)
			If defaultUserToNotificationForNotebookShareInvite And InStr(postUpdate("email"),"hdbiosci")>0 then
				strQuery = "INSERT INTO userNotificationOptions(userId,notificationTypeId,enabled,email) values("&SQLClean(newId,"N","S")&",2,1,1)"
				connAdm.execute(strQuery)
			End if
		Else
			strQuery = "UPDATE users set mustChangePassword=0, datePasswordChanged=GETUTCDATE() WHERE id="&SQLClean(newId,"N","S")
			connAdm.execute(strQuery)
		End If
		
		a = logAction(0,newId,"",21)
		set mailObj = Server.CreateObject("CDO.Message")
		'mailObj.Host = mailServerAddress ' Required
		mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
		mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = mailServerAddress
		mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
		mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = False
		mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
		mailObj.Configuration.Fields.Update
		
		sendEmailsFromGlobalSupportAddress = checkBoolSettingForCompany("sendEmailsFromGlobalSupportAddress", session("company"))
		If whichServer = "PROD" And sendEmailsFromGlobalSupportAddress Then
			mailObj.From = globalSupportEmailAddress
			mailObj.replyTo = session("email")
		else
			
			mailObj.From = "support@arxspan.com"
			mailObj.ReplyTo = session("firstName")&" "&session("lastName")&"<"&session("email")&">"
			
		End if	
		If whichServer = "PROD" Or sendUserEmailsFromNotProd then
			mailObj.To = postUpdate("email")
		Else
			mailObj.To = globalNotificationEmailAddress
		End if
		mailObj.bcc = globalNotificationEmailAddress
		mailObj.Subject = "Your new Arxspan ELN Account"
		If whichClient = "BROAD" And whichServer = "PROD" then
			bodyHTML = "Hello "&postUpdate("firstName")&" "&postUpdate("lastName")&",<br/><br/>A new account has been created for you by BITS.  You can login at <a href='https://eln.arxspan.com/sso1/login.asp'>https://eln.arxspan.com/sso1/login.asp</a> using your Broad email address: "&postUpdate("email")&" and your Broad password.  If you are having issues with your password, please use Enigma <a href='https://enigma.broadinstitute.org/'>https://enigma.broadinstitute.org/</a>.<br/><br/>Please contact <a href='mailto:support@arxspan.com'>support@arxspan.com</a> if you need further assistance.  If you have general questions about the ELN or the <a href='https://it.broadinstitute.org/wiki/Laboratory_Data_Management_(LDM)'>Laboratory Data Management (LDM) project</a>, please contact <a href='mailto:help@broadinstitute.org'>help@broadinstitute.org</a>.<br/><br/>Thank You,<br/>The Arxspan Support Team"
			mailObj.HTMLBody = bodyHTML
		else
			loginUrl = rootAppServerHostName
			If companyUsesSso() And isSsoUser Then
				if Not IsNull(ssoLoginPath) and ssoLoginPath <> "" then
					loginUrl = loginUrl & ssoLoginPath
				else
					loginUrl = loginUrl & ssoFolderName
				end if
			Else
				loginUrl = loginUrl & loginScriptName
			End If
			
			bodyText = "Hello "&postUpdate("firstName")&" "&postUpdate("lastName")&","&vbcrlf&vbcrlf&"A new account has been created for you by "&session("firstName") & " " & session("lastName")&".  You can login at https://"&loginUrl&" using your email address: "&postUpdate("email")&"."
			
			If whichClient = "BROAD" Or (companyUsesSso() And isSsoUser) Then
				bodyText = bodyText & "  Use your current network password."& vbcrlf&vbcrlf			
			Else
				If Not userExists then
					bodyText = bodyText & "  Your temporary password is: "& newPW&vbcrlf&vbcrlf
				Else
					bodyText = bodyText & "  You may continue to use your current password."&vbcrlf&vbcrlf
				End if
			End if
			bodyText = bodyText & "Please contact "&localSupportEmailAddress&" if you need further assistance."&vbcrlf&vbcrlf&"Thank You,"&vbcrlf&vbcrlf&"The Arxspan Support Team"
			If whichServer <> "PROD" Then
				bodyText = bodyText & vbcrlf & vbcrlf & postUpdate("email")
			End if
			mailObj.textBody = bodyText
		End if
		If session("companyId") <> "4" And session("companyId") <> "161" And  session("companyId") <> "178" then
			mailObj.Send
		End if
	Else
		a = logAction(0,newId,"",23)
	end if
end If
%>