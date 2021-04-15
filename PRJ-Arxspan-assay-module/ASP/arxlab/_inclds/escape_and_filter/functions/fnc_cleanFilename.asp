<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function cleanFilename(inFileStr)
	'remove characters that are not allowed in a filename
	'used mostly for creating files in the inbox
	cleanFilename = Replace(inFileStr,"<"," ")
	cleanFilename = Replace(cleanFilename,">"," ")
	cleanFilename = Replace(cleanFilename,":"," ")
	cleanFilename = Replace(cleanFilename,""""," ")
	cleanFilename = Replace(cleanFilename,"/"," ")
	cleanFilename = Replace(cleanFilename,"\"," ")
	cleanFilename = Replace(cleanFilename,"|"," ")
	cleanFilename = Replace(cleanFilename,"?"," ")
	cleanFilename = Replace(cleanFilename,"*"," ")
	cleanFilename = Replace(cleanFilename,vbcrlf," ")
	For i = 129 To 255
		cleanFilename = Replace(cleanFilename,Chr(i),"")
	next
End function
%>