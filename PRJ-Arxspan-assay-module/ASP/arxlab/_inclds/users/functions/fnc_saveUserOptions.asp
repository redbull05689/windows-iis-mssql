<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function saveUserOptions(userOptions)
	Call getconnectedadm
	strQuery = "UPDATE users SET options="&SQLClean(JSON.stringify(userOptions),"T","S")&" WHERE id="&SQLClean(session("userId"),"N","S")
	connAdm.execute(strQuery)
	session("userOptions") = JSON.stringify(userOptions)
end function
%>