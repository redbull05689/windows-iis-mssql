<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function padWithZeros(inString,strLen2)
	If Len(inString) < strLen2 Then
		For iwq = Len(inString) To strLen2 - 1
			inString = "0" & inString
		next
	End If
	padWithZeros = inString
End function
%>