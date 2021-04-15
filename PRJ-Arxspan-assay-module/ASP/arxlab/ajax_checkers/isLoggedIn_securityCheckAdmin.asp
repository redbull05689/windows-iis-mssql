<%
'returns false if the user does not have a session
'and true if the user does have a session
'used to redirect pages when user logs out in a different tab
if session("userId") = "" or session("email") = "" or session("company") = "" or session("role") <> "admin" then
	response.end
end if
%>