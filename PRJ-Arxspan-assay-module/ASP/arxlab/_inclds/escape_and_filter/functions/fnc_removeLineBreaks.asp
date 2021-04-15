<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function removeLineBreaks(inString)
	'remove break line characters and tabs
	'used to clean up fck data for chrome
	inString = replace(inString,vbcr,"")
	inString = replace(inString,vblf,"")
	inString = replace(inString,vbtab,"")
	removeLineBreaks = inString
end function
%>