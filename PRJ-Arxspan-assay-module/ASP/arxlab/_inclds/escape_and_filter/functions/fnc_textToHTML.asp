<%
function textToHTML(inString)
	'convert text to simple html
	textToHTML = "<p>" & Replace(inString,vbcrlf,"</p><p>") & "</p>"
end function
%>