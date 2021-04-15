<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getXMLTag(tagName,inString)
	instring = Replace(instring,vbcrlf,"$$$%%%^%^$%^$%^$%$%^45")
	instring = Replace(instring,vbcr,"$$$%%%^%^$%^$%^$%$%^45")
	instring = Replace(instring,vblf,"$$$%%%^%^$%^$%^$%$%^45")
	Set re = new RegExp
	re.IgnoreCase = true
	re.Global = true

	re.Pattern = "<"&tagName&">(.*?)</"&tagName&">"
	re.multiline = true
	Set Matches = re.execute(inString)
	If Matches.count > 0 Then
		m = Matches.Item(0).subMatches(0)
		m = Replace(m,"$$$%%%^%^$%^$%^$%$%^45",vbcrlf)
		getXMLTag = m
	else
		getXMLTag = "error"
	End If
	set re = nothing
end function
%>