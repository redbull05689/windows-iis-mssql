<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function getFileExtension(filename)
	'get the file extension from a file name
	'last 3-5 alphanumeric characters after a "." to the end of the filename
	Set myRegExp = New RegExp
	myRegExp.IgnoreCase = True
	myRegExp.Global = True
	myRegExp.Pattern = "\.[a-z0-9]{3,5}$"
	Set myMatches = myRegExp.Execute(filename)
	If myMatches.Count >=1 then
		getFileExtension = myMatches(0).value
	Else
		getFileExtension = ""
	End If
End function
%>