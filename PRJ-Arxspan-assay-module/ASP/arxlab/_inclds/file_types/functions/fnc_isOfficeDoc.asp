<%
function isOfficeDoc(fn)
	'returns true if the file extension of the filename is an office extension
	isExt = Replace(lcase(getFileExtension(fn)),".","")
	if isExt = "doc" or isExt = "xls" or isExt = "ppt" or isExt = "docx" or isExt = "xlsx" or isExt = "pptx" Or isExt= "csv" then
		isOfficeDoc = true
	else
		isOfficeDoc = false
	end if
end function
%>