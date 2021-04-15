<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%If session("companyId") <> "4" then%>
<div class="dashboardObjectContainer changePassword" style="width:452px;"><div class="objHeader elnHead"><h2><%=changePasswordLabel%></h2></div>
			<div class="objBody">

				<form method="post" action="<%=mainAppPath%>/users/my-profile.asp">
				<%If request.querystring("m") = "1" then%>
						<p class="changePasswordMessage">Your password has been changed</p>
				<%End if%>
						<%If errString <> "" then%>
							<p class="changePasswordMessage"><%=errString%></p>
						<%End if%>
						<label for="current"><%=currentPasswordLabel%></label>
						<input type="password" name="current" id="current" value="">
						<label for="current"><%=newPasswordLabel%></label>
						<input type="password" name="new" id="new" value="">
						<label for="current"><%=confirmPasswordLabel%></label>
						<input type="password" name="confirm" id="confirm" value="">
						<input type="submit" value="<%=changePasswordLabel%>" class="btn" name="passwordSubmit">
						</form>

		</div>
	</div>
<%End if%>