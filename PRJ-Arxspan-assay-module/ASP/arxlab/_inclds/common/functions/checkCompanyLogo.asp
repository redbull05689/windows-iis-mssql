<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<%
Function checkCompanyLogo()
	Call getconnectedAdm
	checkCompanyLogo = ""
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	logoFilePath = uploadRoot&"\logo.gif"
	If fs.FileExists(logoFilePath)=true Then
		checkCompanyLogo = "true"
	End If
End Function



Function checkCompanyLogo2()
	checkCompanyLogo = ""
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	filename = "company_logo.gif"
	logoFilePath = uploadRoot&"\logo.gif"
	If fs.FileExists(logoFilePath)=true Then
		response.contenttype="image/gif"
		response.addheader "ContentType","image/gif"
		response.addheader "Content-Disposition", "inline; " & "filename=logo.gif"
		'returnedFile = returnImageFile(filepath, filename, server.mappath(mainAppPath)&"/images/", "return-error")
		checkCompanyLogo = returnImageFile(logoFilePath, filename, server.mappath(mainAppPath)&"/images/", "return-error")
		'checkCompanyLogo = ""
	End If
End Function
%>