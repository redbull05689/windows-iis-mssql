<%
function displayToolTip(details, name)
	If IsNull(details) Then
		toolTip = ""
	Else
		toolTip = Replace(details,"""","")
	End If
	displayToolTip = toolTip & "&#13;" & name
end function
%>