<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function cdXMLGetParam(param,xmlData)
	'get a parameter from the xmlData. i.e. ReactionStepReactants="[get this]"
	On Error Resume next
	Set RegEx = New regexp
	RegEx.Pattern = param&"=""(.*?)"""
	RegEx.Global = True
	RegEx.IgnoreCase = True
	set matches = RegEx.Execute(xmlData)
	Set RegEx = Nothing
	cdXMLGetParam = Trim(matches(0).SubMatches(0))
	If Err.number <> 0 Then
		cdXMLGetParam = "Error Occured"
	End If
	On Error goto 0
End function
%>