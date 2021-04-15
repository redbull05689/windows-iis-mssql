<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function maxChars(inputString,charMax)
	Dim i
	'truncate the input string at the charMax or at the first space after the charMax before charMax + 12
	inputString = removeTags(inputString)
	breakNextSpace = False
	newString = ""
	periodCount = 0
	periodMax = 100
	nlOffset = 0
	for i=0 to len(inputString)
		newString = newString & mid(inputString,i+1,1)
		if mid(inputString,i+1,1) = "." then
			periodCount = periodCount + 1
		end if
		if periodCount = periodMax then
			if i > charMin then
				exit for
			else
				periodMax = periodMax +1
			end if
		end if
		if i > charMax + nlOffset then
			breakNextSpace = True
		end if
		if breakNextSpace = True then
			if mid(inputString,i+1,1) = " " or mid(inputString,i+1,1) = "." Or i > charMax + 12 then
				exit for
			end if
		end if
	next
	maxChars = newString
end function
%>