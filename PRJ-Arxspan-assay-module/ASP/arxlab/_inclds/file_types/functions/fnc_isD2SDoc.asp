<%
function isD2SDoc(fn)
	'returns true if the file extension of the filename is an extension that should be used for D2S
	isExt = Replace(lcase(getFileExtension(fn)),".","")
	if isOfficeDoc(fn) or isExt = "pdf" or isExt = "sdf" then
		isD2SDoc = true
	else
		isD2SDoc = false
	end if
end function
%>