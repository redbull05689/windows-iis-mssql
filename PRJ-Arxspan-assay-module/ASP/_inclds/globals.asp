<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
resetPasswordEmailAddress = "support@arxspan.com"
subFolderPath = ""
mainSiteLink = "http://www.arxspan.com"
loginPath = "/login.asp"
defaultEmail = "support@arxspan.com"



If sectionId <> "login" And sectionId <> "logout" then
	If Not InStr(request.servervariables("SCRIPT_NAME"),"404") > 0 then
		session("prevUrl") = request.servervariables("SCRIPT_NAME")&"?"&request.servervariables("QUERY_STRING")
	End if
End If
If session("unAuthorized") Then
	session("prevUrl") = ""
	session("unAuthorized") = False
End If

%>