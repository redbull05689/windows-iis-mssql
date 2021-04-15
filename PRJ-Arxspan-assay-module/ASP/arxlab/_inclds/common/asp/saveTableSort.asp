<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If request.querystring("d") = "" Then
	If userOptions.exists(request.servervariables("SCRIPT_NAME")&"_sortDir") Then
		sortDir = userOptions.get(request.servervariables("SCRIPT_NAME")&"_sortDir")
	End if
Else
	userOptions. Set request.servervariables("SCRIPT_NAME")&"_sortDir",sortDir
	saveUserOptions(userOptions)
End If

If request.querystring("s") = "" Then
	If userOptions.exists(request.servervariables("SCRIPT_NAME")&"_s") Then
		sortBy = userOptions.get(request.servervariables("SCRIPT_NAME")&"_sortBy")
		s = userOptions.get(request.servervariables("SCRIPT_NAME")&"_s")
	End if
Else
	userOptions. Set request.servervariables("SCRIPT_NAME")&"_sortBy",sortBy
	userOptions. Set request.servervariables("SCRIPT_NAME")&"_s",s
	saveUserOptions(userOptions)
End If
%>