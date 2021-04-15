<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function cleanWhitespace(inString)
	'replace all the whitespace(s) with a single whitespace
	'e.g. Hello &nbsp;    World -> Hello World
	If isnull(inString) Then
		inString = ""
	End if
	Set RegEx = New regexp
	RegEx.Pattern = "&nbsp;"
	RegEx.Global = True
	RegEx.IgnoreCase = True
	inString = RegEx.Replace(inString," ")

	RegEx.Pattern = "\s+"
	RegEx.Global = True
	RegEx.IgnoreCase = True
	cleanWhitespace = RegEx.Replace(inString," ")
	Set RegEx = nothing
end function
%>