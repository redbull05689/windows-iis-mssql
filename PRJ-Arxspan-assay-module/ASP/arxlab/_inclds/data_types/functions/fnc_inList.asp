<%
function inList(val,list)
	'return true if the val is in the comma seperated list of values
	inListBool = false
	l = split(list,",")
	for i = 0 to ubound(l)
		if l(i) = CStr(val) then
			inListBool = True
		end if
	Next
	inList = inListBool
end function
%>