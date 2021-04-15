<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function validateUSPhone(strPhoneCheck)
	'return true if input string is a valid us phone number
	dim objRegExp

	set objRegExp = new RegExp
	with objRegExp
		.Pattern = "^\(?[1-9]\d{2}\)?\s?\-?\+?\d{3}\s?\-?\+?\d{4}$"
		.Global = True
	end with
	validateUSPhone = objRegExp.test(strPhoneCheck)
set objRegExp = nothing

end function


function validateZip(strZipCheck)
	'return true if input string is 5 numerical characters
	dim objRegExp 

	set objRegExp = new RegExp
	with objRegExp
		'.Pattern = "^\d{5}\s?\-?\d{4}?$"
		.Pattern = "^\d{5}$"
		.Global = True
	end with
	validateZip = objRegExp.test(strZipCheck)
set objRegExp = nothing

end function


Function validateEmail(myEmail)
	'return true if input string is a valid email
	dim objRegExp
  
	set objRegExp = New RegExp
  
	with objRegExp  
		.Pattern = "^[a-zA-Z][\w\.\'-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$"
		.Global = True
	end with
  
	validateEmail = objRegExp.test(myEmail)
	  set objRegExp = nothing
End Function

Function validateDate(myDate)
	'return true if input string is a valid date e.g 1/1/99, 12/23/2001
	dim objRegExp

	set objRegExp = New RegExp
	with objRegExp  
		.Pattern = "^([0-1][0-9]|[1-9])\/([0-2][0-9]|[3][0-1]|[1-9])\/(([0-9][0-9])|(20|19)[0-9][0-9])$"
		.Global = True
	end with

	validateDate = objRegExp.test(myDate)
	set objRegExp = nothing
End Function

Function notEmpty(field)
	'return true if string has at least one character
	dim objRegExp

	set objRegExp = New RegExp
	with objRegExp  
		.Pattern = "^.{1,}$"
		.Global = True
	end with

	notEmpty = objRegExp.test(field)
	set objRegExp = nothing
End Function
%>
