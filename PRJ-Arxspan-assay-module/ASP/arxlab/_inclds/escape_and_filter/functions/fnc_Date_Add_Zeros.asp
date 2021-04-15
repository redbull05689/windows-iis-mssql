<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function dateAddZeros(dateStr)
	'add zeros to dates to put dates into the form 01/01/11
	'used for calendar plugin which only accepts dates in this format and the
	'database returns the 1/1/11 form
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