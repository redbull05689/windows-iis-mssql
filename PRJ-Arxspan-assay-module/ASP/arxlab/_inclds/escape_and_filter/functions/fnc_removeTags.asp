<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function removeTags(inString)
	'replaces all the tags in html with spaces
	'used to remove tags from cas scraping and also used to create a clean preparation text for search
	If isnull(inString) Then
		inString = ""
	End if
	Set RegEx = New regexp
	RegEx.Pattern = "<[^>]*>"
	RegEx.Global = True
	RegEx.IgnoreCase = True
	removeTags = RegEx.Replace(inString," ")
	Set RegEx = nothing
end function
%>