<%
'get the file extension from a file name
Function getFileExtension(filename)
	Set myRegExp = New RegExp
	myRegExp.IgnoreCase = True
	myRegExp.Global = True
	myRegExp.Pattern = "\.[a-z0-9]{3,5}$"
	Set myMatches = myRegExp.Execute(filename)
	getFileExtension = myMatches(0).value
End function
%>