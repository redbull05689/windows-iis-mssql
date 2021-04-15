<%
function isChemicalFile(fn)
	'return true if the supplied filename is a type of file that chemdraw can view
	isExt = Replace(lcase(getFileExtension(fn)),".","")
	if isExt = "mol" or isExt = "cdx" or isExt = "cdxml" or isExt = "rxn" or isExt = "chm" or isExt = "cml" or isExt = "jdx" then
		isChemicalFile = true
	else
		isChemicalFile = false
	end if
end function
%>