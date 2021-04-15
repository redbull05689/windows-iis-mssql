<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<%
subSectionId = "force-change-password"
%>
<!-- #include file="../_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->


<%
If request.Form <> "" Then
	usersTable = getDefaultSingleAppConfigSetting("usersTable")
	usersTablePasswordField = getDefaultSingleAppConfigSetting("usersTablePasswordField")
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

	If errString = "" then
		connAdm.execute("UPDATE "&usersTable&" set mustChangePassword=0,datePasswordChanged=GETUTCDATE() WHERE id="&SQLClean(session("userId"),"N","S"))
		'pw_stuff
		connAdm.execute("UPDATE passwords set "&usersTablePasswordField&"="&SQLClean(request.Form("new"),"PW","S") & " WHERE email="&SQLClean(session("email"),"T","S"))
		session("mustChangePassword") = 0
		If session("hasELN") then
			response.redirect(mainAppPath&"/dashboard.asp")
		Else
			If session("regRegistrar") And Not session("regRegistrarRestricted") Then
				response.redirect(regPath&"/AdminApprove.asp")
			Else
				regDefaultGroupId = getCompanySpecificSingleAppConfigSetting("defaultRegGroupId", session("companyId"))
				If CStr(regDefaultGroupId)<>"" Then 
					extra = "?groupId="&regDefaultGroupId
				End if
				response.redirect(regPath&"/addStructure.asp"&extra)
				response.redirect(regPath&"/addStructure.asp")
			End if
		End if
	End if
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

<div class="dashboardObjectContainer changePassword"><div class="objHeader elnHead"><h2>Change Password</h2></div>
			<div class="objBody">

				<form method="post" action="<%=mainAppPath%>/users/force-change-password.asp">
				<p>You are required to change your password</p>
				<%If request.querystring("m") = "1" then%>
						<p class="changePasswordMessage">Your password has been changed</p>
				<%End if%>
						<%If errString <> "" then%>
							<p class="changePasswordMessage" style="color:red;"><%=errString%></p>
						<%End if%>
						<label for="current">Current Password</label>
						<input type="password" name="current" id="current" value="">
						<label for="current">New Password</label>
						<input type="password" name="new" id="new" value="">
						<label for="current">Confirm Password</label>
						<input type="password" name="confirm" id="confirm" value="">
						<input type="submit" value="Change Password" class="btn">
						</form>

		</div>
	</div>

<%end if%>

<!-- #include file="../_inclds/footer-tool.asp"-->