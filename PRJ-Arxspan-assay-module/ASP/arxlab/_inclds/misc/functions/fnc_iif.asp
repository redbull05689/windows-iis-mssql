<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function IIF(bClause, sTrue, sFalse)
	If CBool(bClause) Then
		IIf = sTrue
	Else
		IIf = sFalse
	End If
End Function
%>