
<%
function validateUSPhone(strPhoneCheck)
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
  dim objRegExp
  
  set objRegExp = New RegExp
  
  with objRegExp  
  .Pattern = "^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$"
  .Global = True
  end with
  
  validateEmail = objRegExp.test(myEmail)
  set objRegExp = nothing

End Function

Function validateDate(myDate)
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
