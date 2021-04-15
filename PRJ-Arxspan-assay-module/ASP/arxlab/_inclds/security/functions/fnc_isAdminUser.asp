<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function isAdminUser(userId)
	isAdminUser = false
	If userId <> False Then
		Set cwRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM usersView WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND id="&SQLClean(userId,"N","S") & " AND roleNumber = 1"
		cwRec.open strQuery,conn,adOpenStatic,adLockReadOnly
		If Not cwRec.eof Then
			If cwRec("id") = userId Then
				isAdminUser = True
			End If
		End If
		cwRec.close
		Set cwRec = nothing
	Else
		'if user id not supplied use session userId
		If session("roleNumber") = 1 Then
			isAdminUser = True
		End If
	End If
End Function
%>