<%
Function dateAddZeros(dateStr)
	if isnull(dateStr) then 
		dateStr = ""
	end if
	dateArray = split(dateStr,"/")
	newDateStr = ""
	if ubound(dateArray) = 2 then
		if len(dateArray(0)) = 1 then
			newDateStr = newDateStr & "0" & dateArray(0) & "/"
		else
			newDateStr = newDateStr & dateArray(0)  & "/"
		end if
		if len(dateArray(	1)) = 1 then
			newDateStr = newDateStr & "0" & dateArray(1)  & "/"
		else
			newDateStr = newDateStr & dateArray(1)  & "/"
		end if
		newDateStr = newDateStr & dateArray(2)
	end if
	dateAddZeros = trim(newDateStr)
End Function
%>