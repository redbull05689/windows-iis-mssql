<%
function removeTags(inString)
	Set RegEx = New regexp
	RegEx.Pattern = "<[^>]*>"
	RegEx.Global = True
	RegEx.IgnoreCase = True
	removeTags = RegEx.Replace(inString,"")
	Set RegEx = nothing
end function
%>