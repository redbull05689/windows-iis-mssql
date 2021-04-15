<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
'Set the touch available feature for the user
if CInt(request.querystring("get")) = 1 then
	response.write session("isTouchAvailable")
elseif CInt(request.querystring("set")) = 1 then
	Do While session("isTouchAvailable") <> true
		session("isTouchAvailable") = true
		session.Save()
	Loop
elseif CInt(request.querystring("set")) = 0 then
	Do While session("isTouchAvailable") <> false
		session("isTouchAvailable") = false
		session.Save()
	Loop
end if
%>