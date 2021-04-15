<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%session("overrideDB")=""%>
<%
Dim isArxLoginScript
Dim onlyCompanyError : onlyCompanyError = false
Dim globalEmail : globalEmail = ""
Dim formErrorText : formErrorText = ""
isArxLoginScript = True
server.scripttimeout =120
	sectionID = "home"
	subSectionID=""
	terSectionID=""

	pageTitle = "Arxspan web based electronic lab notebook, cloud-based ELN for scientific collaboration platform."

	metaD="Arxspan is a web based electronic lab notebook company. Arxspan is a cloud-based ELN hosted online ELN application platform for scientific collaboration, internal research management, contract research organization (CRO) and academic scientific collaboration."

	metaKey="cloud based ELN, web based lab notebook, electronic notebook, ELN, e signatures, electronic signatures, chemistry notebook, biology notebook, electronic research notebook, scientific data management, cro data management, cro notebook, cro workflow,  cro notebook, cro Management"

' #################### TO ENABLE MAINTENANCE MODE GOTO APPROX LINE#215 AND CHANGE 1=1  TO 1=2 ###########################

%>

<%
If Request.ServerVariables("SERVER_PORT")=80 Then
	response.redirect("https://"&request.servervariables("SERVER_NAME")&"/login.asp")
End if
%>
<!-- #include file="arxlab/_inclds/maintenance.asp"-->
<!-- #include file="arxlab/_inclds/globals.asp"-->
<!-- #include file="arxlab/_inclds/misc/functions/fnc_ipsFromRange_local.asp"-->
<%
'redirect users in broad ip range to sso login
If whichServer = "PROD" Or whichServer = "MODEL" then
	ipStr = "69.173.96-126.1-255,69.173.127.1-128"
	'ipStr = ipStr & ",100.0.175.27"
	ipStr = ipStr & ",70.192.0.104"
	ipArray = Split(ipsFromRange(ipStr),",")
	For q = 0 To UBound(ipArray)
		If ipArray(q) = request.servervariables("REMOTE_ADDR") Then
			response.redirect("SSO/broad")
		End if
	Next
End if
%>
<%
If session("userId") <> "" Then
	session("prevUrl") = ""
End if
%>

<!--#include file="_inclds/header.asp"-->
<%

usersTable = getDefaultSingleAppConfigSetting("usersTable")

if request.form("login-submit") <> "" Then
	globalEmail = request.form("login-email")
	loginCompany = Trim(request.Form("login-company"))
	If loginCompany = "" Then
		loginCompany = -1
	End If
	strQuery = buildCompanyUserQuery(loginCompany, request.form("login-email"), request.form("login-pass"))
	call setupLogin(strQuery, request.Form("login-company"), request.form("login-email"))
end if

if session("email") <> "" AND session("companyid") <> "" then
	sessionCompany = session("companyid")
	sessionEmail = session("email")
	globalEmail = session("email")

	strQuery = buildCompanyUserQuerySSO(sessionCompany, sessionEmail)
	call setupLogin(strQuery, sessionCompany, sessionEmail)
end if

Function getCompanyQuery(loginEmail)
	getCompanyQuery = "SELECT distinct c.id as companyId, c.name as companyName FROM users u INNER JOIN companies c on u.companyId=c.id WHERE u.enabled=1 AND u.email=" & SQLClean(loginEmail,"T","S") & " AND (datediff(day,getdate(),c.expirationDate) > 0 or c.expirationDate is null or c.expirationDate='1/1/1900') and (c.disabled=0 or c.disabled is null) and ((c.limitLoginAttempts=0 or c.limitLoginAttempts is null) or (c.limitLoginAttempts=1 and (u.loginAttempts<=maxLoginAttempts or u.loginAttempts is null)))"
End Function

Function buildCompanyUserQuery(userCompany, userEmail, userPassword)
	If userCompany <= 0 Then
		companyQuery = " in (SELECT companyId FROM(" & getCompanyQuery(request.form("login-email")) & ")q)"
	Else
		companyQuery = "=" & SQLClean(userCompany,"N","S")
	End If
	
	buildCompanyUserQuery = "SELECT * FROM usersView WHERE email="&SQLClean(userEmail,"T","S")& " AND password="&SQLClean(userPassword,"PW","S")& " AND companyId"
	buildCompanyUserQuery = buildCompanyUserQuery & companyQuery
	buildCompanyUserQuery = buildCompanyUserQuery & " AND password is not null and ((limitLoginAttempts=0 or limitLoginAttempts is null) or (limitLoginAttempts=1 and (loginAttempts<=maxLoginAttempts or loginAttempts is null))) and companyId<>62"
End Function

Function buildCompanyUserQuerySSO(userCompany, userEmail)
	
	buildCompanyUserQuerySSO = "SELECT * FROM usersView WHERE email=" & SQLClean(userEmail,"T","S") & " AND companyId = (SELECT id FROM companies WHERE id = " & SQLClean(userCompany,"N","S") & " AND (datediff(DAY,GETDATE(), expirationDate) > 0 OR expirationDate IS NULL OR expirationDate='1/1/1900'))"
	buildCompanyUserQuerySSO = buildCompanyUserQuerySSO & " AND password is not null and ((limitLoginAttempts=0 or limitLoginAttempts is null) or (limitLoginAttempts=1 and (loginAttempts<=maxLoginAttempts or loginAttempts is null)))"
End Function

Function setupLogin(strQuery, loginCompany, loginEmail)

	formError = true
	formErrorText = ""

	call getconnected
	call getconnectedadm
	Set rec = Server.CreateObject("ADODB.RecordSet")

	rec.Open strQuery,Conn,adOpenStatic,adLockReadOnly
	if not rec.eof Then
		numCompanies = rec.RecordCount
			
		If numCompanies = 1 Then
			companyId = rec("companyId")
		else
			companyId = -1
		End If

		If Trim(loginCompany) <> "" Or (numCompanies = 1 And companyId > 0) Then
		
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * from companies where id="&SQLClean(companyId,"N","S")
			rec2.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
			If rec2.eof Then
				expiredError = True
			Else
				expiredError = False
			End if
			rec2.close
			Set rec2 = nothing
			If loginEmail = "support@arxspan.com" Then
				expiredError = False
			End if

			if rec("enabled") = 0 Or expiredError then
				If rec("enabled") = 0 then
					formErrorText = "Your account is not yet activated"
				Else
					formErrorText = "Your account has expired."
				End if
			Else
				
				ipBlocked = False
				If rec("ipBlock") = 1 And rec("ipBlockMe") = 1 Then
					ipBlocked = True
				End If
				
				If ipBlocked Then
					ipStr = rec("ipRanges")
					If ipStr = "" Or IsNull(ipStr) Then
						ipBlocked = False
					End If
					
					If ipBlocked Then
						ipStr = CStr(ipStr) & ",100.0.175.27,8.20.189.20,108.7.43.41,8.20.189.168,8.20.189.170"
						ipArray = Split(ipsFromRange(ipStr),",")
						For q = 0 To UBound(ipArray)
							If ipArray(q) = request.servervariables("REMOTE_ADDR") Then
								ipBlocked = false
								Exit For
							End if
						Next
					End If
				End If
				
				If ipBlocked Then
					formErrorText = "You are trying to login from a restricted location. "&request.servervariables("REMOTE_ADDR")
				End if
				
				If Not ipBlocked then
					If session("perftime") Then
						st2 = timer()
					End If
					If Not IsNull(rec("requirePasswordChange")) Then
						If (Not companyUsesSso()) Or (IsNull(rec("isSsoUser")) Or rec("isSsoUser")=0) Then
							If rec("requirePasswordChange")=1 Then
								If IsNull(rec("datePasswordChanged")) And rec("email")<>"support@arxspan.com" then
									connAdm.execute("UPDATE "&usersTable&" set mustChangePassword=1 WHERE id="&SQLClean(rec("id"),"N","S"))
								Else
									Set tRec = server.CreateObject("ADODB.RecordSet")
									strQuery = "SELECT DATEDIFF(day,datePasswordChanged,GETUTCDATE()) as daysSincePasswordChanged from "&usersTable&" WHERE id="&SQLClean(rec("id"),"N","S")
									tRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
									If tRec("daysSincePasswordChanged")>=rec("requirePasswordChangeDays") And rec("requirePasswordChangeDays") <> 0 And rec("email")<>"support@arxspan.com" Then
										connAdm.execute("UPDATE "&usersTable&" set mustChangePassword=1 WHERE id="&SQLClean(rec("id"),"N","S"))
									End If
									tRec.close
									Set tRec = nothing
								End if
							End If
						End if
					End if
					
					' Log the user in
					loginUser(rec("id"))

					If session("perftime") then
						response.write("logged in user: "&timer()-st2)
						response.write("total time: "&timer()-st)
					End if

					' If session("prevUrl") <> "" Then
					' 	response.redirect(session("prevUrl"))
					' else
						If session("role") = "admin" Then
							If session("hasELN") then
								response.redirect("/arxlab/dashboard.asp")
							Else
								response.redirect("/arxlab/reg-users.asp")
							End if
						Else
							If session("hasELN") then
								response.redirect("/arxlab/dashboard.asp")
							Else
								If session("regRegistrar") And Not session("regRegistrarRestricted") Then
									response.redirect(regPath&"/adminApprove.asp")
								Else
									response.redirect(regPath&"/addStructure.asp")
								End if
							End if
						End if
					'End If
				End if
			end If
		Else
			If trim(loginCompany) = "" Then
				formErrorText = "Please select a company"			
			End if
			onlyCompanyError = true
		End if
	Else
		if session("email") <> "" AND session("companyid") <> "" then 
			formErrorText = "There was an error logging you in.  Please contact support@arxspan.com  Reference error: GUITAR." ' Just a random searchable word so the error message doesn't need to say "You guys forgot to pay"
		else 
			Set aRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT loginAttempts FROM users WHERE email=" & SQLClean(loginEmail, "T", "S")
			aRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
			If Not aRec.eof Then
				If IsNull(aRec("loginAttempts")) Then
					loginAttempts = 1
				Else
					loginAttempts = aRec("loginAttempts") + 1
				End If
				connAdm.execute("UPDATE users SET loginAttempts="&SQLClean(loginAttempts,"N","S")&" WHERE email="&SQLClean(loginEmail, "T", "S"))
				aRec.close
			End if
			Set aRec = nothing
			formErrorText = "Invalid username or password"
			a = logAction(0, 0, loginEmail, 14)
		end if 
	end if
	rec.close
	Set rec = Nothing
	Call disconnectadm
END function

%>
<%If onlyCompanyError then%>
<script type="text/javascript">
	window.onload = function(){document.getElementById('login-company').focus();}
</script>
<%else%>
<script type="text/javascript">
	window.onload = function(){document.getElementById('login-email').focus()}
</script>
<%End if%>

<!-- #include virtual="header_bar.asp"-->
<div class="login-page container">
<div class="form">
	<div class="row">
	<div class="col-sm-8">
		<div class="row hidden-xs">
			<div class="col-sm-6">
				<img src="/images/icons.png" />
			</div>
			<div class="col-sm-6 cloudBased">
				<h1>Cloud-based<br/>Scientific<br/>Collaboration<br/>Software</h1>
			</div>

		</div>
		<div class="row">
			<div class="col-sm-12">
				<h2>Create. Connect. Collaborate.</h2>
			</div>
		</div>
	</div>
	<div class="col-sm-4">
	 <% If request.QueryString("override") = "hmwc" Or Maintenance <> true Then %> 
		<form id="login-form" action="login.asp?action=<%=request.querystring("action")%>&override=<%=request.querystring("override")%>" method="post" class="loginForm">
			<%If onlyCompanyError then%>
				<div class="companyPicker">
					<label for="login-company">Company:</label><br />
					<select name="login-company" id="login-company">
						<option value=" ">--SELECT--</option>
						<%
						Call getconnected
						Set rec = server.CreateObject("ADODB.RecordSet")
						query = getCompanyQuery(globalEmail) & " ORDER BY c.name ASC"
						rec.open query,conn,adOpenForwardOnly,adLockReadOnly
						Do While Not rec.eof
							%>
							<option value="<%=rec("companyId")%>"><%=rec("companyName")%></option>
							<%
							rec.movenext
						Loop
						rec.close
						Set rec = nothing
						%>
					</select>
					<div style="display:none;">
						<label for="login-email">User Name:</label>
						<input type="text" id="login-email" name="login-email" value="<%=request.Form("login-email")%>" autocomplete='off'>
						<label id="login-pass-label" for="login-pass">Password:</label>
						<input type="password" id="login-pass" name="login-pass" value="<%=request.Form("login-pass")%>" autocomplete='off'>
					</div>
				</div>
			<%else%>
			  <label for="login-email">User Name:</label>
			  <input type="text" id="login-email" name="login-email">
			  <label id="login-pass-label" for="login-pass">Password:</label>
			  <input type="password" id="login-pass" name="login-pass" autocomplete='off'>
			<%End if%>

			<p class="errorText"><%=formErrorText%>&nbsp;</p>

			<button class="loginButton" name="login-submit" id="login-submit" value="go">Sign In &#10095;</button>
		</form>
		<% Else %>
			<h1>Down for Maintenance</h1>

		<% End If %>
	</div>
	</div>
	<div class="bottom row">
		<div class="col-sm-12">
			<p class="loginAccessDisclaimer">Unauthorized access to this system is strictly prohibited. Unauthorized access to this system, and/or unauthorized use of information from this system may result in civil and/or criminal penalties under applicable state and federal laws.</p>
		</div>
	</div>
</div>

<!--#include file="_inclds/footer.asp"-->
	