<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function validatePassword(password)
		'test whether or not a password is valid
		'passwords must be at least 6 characters long and can only contain alphanumeric characters and [-_$@#]
		validatePassword = "valid"
		Set RegEx = New regexp
		RegEx.Pattern = "([^A-Za-z0-9\-_\$@#])"
		RegEx.Global = True
		RegEx.IgnoreCase = True
		set matches = RegEx.Execute(password)
		Set RegEx = nothing
		for each match in matches
			validatePassword = "Passwords may only contain alphanumeric character and the special characters -_$@#"
		next
		If Len(password) < 6 Then
			validatePassword = "Passwords must be at least 6 characters long"
		End if
End Function
%>