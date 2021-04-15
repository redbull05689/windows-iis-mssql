<%
function canDisplayInBrowser(fn)
	'for attachments.  Checks whether attachment can be displayed in an image tag
	isExt = Replace(lcase(getFileExtension(fn)),".","")
	if isExt = "jpg" or isExt = "jpeg" or isExt = "gif" or isExt = "bmp" or isExt = "png" then
		canDisplayInBrowser = true
	else
		canDisplayInBrowser = false
	end if
end function
%>