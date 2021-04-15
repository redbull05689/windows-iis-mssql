<%
function isPdf(fn)
	'returns true if the extension of the filename is pdf
	isExt = Replace(lcase(getFileExtension(fn)),".","")
	if isExt = "pdf" then
		isPdf = true
	else
		isPdf = false
	end if
end function
%>