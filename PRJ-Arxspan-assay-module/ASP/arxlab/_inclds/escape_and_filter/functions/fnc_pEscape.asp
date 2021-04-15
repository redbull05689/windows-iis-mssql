<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function pEscape(inString)
	'escape for python
	'used for generating witnessing/pdf files
	pEscape = inString
	
	If Not IsNull(inString) Then
		'replace all "'" with "\'" and remove \n's
		Set RegEx = New regexp
		RegEx.Pattern = "\\"
		RegEx.Global = True
		RegEx.IgnoreCase = True
		pEscape = RegEx.Replace(CStr(inString),"\\")
		Set RegEx = Nothing
		Set RegEx = New regexp
		RegEx.Pattern = "'"
		RegEx.Global = True
		RegEx.IgnoreCase = True
		pEscape = RegEx.Replace(pEscape,"\'")
		Set RegEx = Nothing
		pEscape = Replace(pEscape,vbcr,"")
		pEscape = Replace(pEscape,vblf,"")
	End If
End Function
%>