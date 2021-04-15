<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getRandomString(strLen)
	'return a random alphanumeric string of the specified length
	'used for naming files
	code = ""
	randomize
	for i = 1 to strLen
		typeSelect = Int(2 * Rnd) + 1
		select case typeSelect
		case 1
			code = code & chr(Int(9 * Rnd) + 48)
		case 2
			code = code & chr(Int(25 * Rnd + 97))
		end select
	next
	getRandomString = code
end Function

function getRandomStringPassword(strLen)
	'return a random alphanumeric string of the specified length for passwords
	code = ""
	randomize
	for i = 1 to strLen
		typeSelect = Int(3 * Rnd) + 1
		select case typeSelect
		case 1
			code = code & chr(Int(9 * Rnd) + 48)
		case 2
			code = code & chr(Int(25 * Rnd + 97))
		Case 3
			whichSymbol = Int(5 * Rnd) + 1
			Select Case whichSymbol
				Case 1
					code = code & "-"
				Case 2
					code = code & "_"
				Case 3
					code = code & "$"
				Case 4
					code = code & "@"
				Case 5
					code = code & "#"
			End select
		end select
	next
	getRandomStringPassword = code
end Function
%>