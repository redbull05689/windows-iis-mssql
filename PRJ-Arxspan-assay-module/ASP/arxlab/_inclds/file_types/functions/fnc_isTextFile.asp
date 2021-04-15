<%
function isTextFile(fn)
	'returns true if the file extension of the filename is a text extension
	isExt = Replace(lcase(getFileExtension(fn)),".","")
	if isExt = "txt" then
		isTextFile = true
	else
		isTextFile = false
	end if
end function
%>