<%
'On Error Resume Next
'used in included files to avoid dictionary attacks on files
If (session("userId") = "" Or session("email") = "" Or session("companyId") = "") And ((Not isArxLoginScript) And (Not isApiPage)) Then
	' If not login/logout/home/header-notifications/hungSave section, not checkExport.asp, not getHeaderNotifications.asp, and it's not an Ajax call
	If sectionId <> "login" And sectionId <> "logout" And sectionId <> "home" And request.servervariables("SCRIPT_NAME") <> mainAppPath&"/exports/checkExport.asp" And request.servervariables("SCRIPT_NAME") <> mainAppPath&"/ajax_checkers/getHeaderNotifications.asp" And sectionId <> "header-notifications" And sectionId <> "hungSave" And (Not isAjax) then
		If Not InStr(request.servervariables("SCRIPT_NAME"),"404") > 0 then
			If sectionId = "dashboard" Or sectionId = "experiment" Or sectionId = "bio-experiment" Or sectionId = "anal-experiment" Or sectionId = "free-experiment" Or sectionId = "workflow" Then
				session("prevUrl") = request.servervariables("SCRIPT_NAME")&"?"&request.servervariables("QUERY_STRING")
				response.redirect("/login.asp")
			End If
			If request.querystring("newsSection") <> "" Then
				session("prevUrl") = request.servervariables("SCRIPT_NAME")&"#"&request.querystring("newsSection")
				If session("userId") <> "" Then
					prevUrl = session("prevUrl")
					session("prevUrl") = ""
					response.redirect(prevUrl)
				End if
			End if
		End if
	End If

	reason = ""
	if session("userId") = "" then
		reason = "No UserId "
	end if
	if session("email") = "" then
		reason = reason & "No Email "
	end if
	if session("companyId") = "" then
		reason = reason & "No CompanyId "
	end if

	response.write("You have been logged out. If this was in error, please send the following to support@arxspan.com:<br>")
	response.write("userId: " & session("userId") & "<br>")
	response.write("email: " & session("email") & "<br>")
	response.write("companyId: " & session("companyId") & "<br>")
	response.write("isArxLoginScript: " & isArxLoginScript & "<br>")
	response.write("isApiPage: " & isApiPage & "<br>")
	response.write("sectionId: " & sectionId & "<br>")
	response.write("scriptName: " & request.servervariables("SCRIPT_NAME") & "<br>")
	response.write("newsSection: " & request.querystring("newsSection") & "<br>")
	response.end
End If

%>