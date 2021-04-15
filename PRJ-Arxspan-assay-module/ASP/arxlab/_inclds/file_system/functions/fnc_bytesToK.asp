<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function bytesToK(bytes)
	'convert bytes to Kilobytes and Megabytes
	If bytes >= 1024 And bytes < 1024 * 1024 Then
		bytesToK = Round(bytes/1024,1) & " K"
	End If
	If bytes >= 1024 * 1024 Then
		bytesToK = Round(bytes/(1024*1024),1) & " M"
	End if	
end function
%>