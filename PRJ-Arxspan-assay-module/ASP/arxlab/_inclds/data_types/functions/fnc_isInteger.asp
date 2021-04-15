<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function IsInteger(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	IsInteger = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
For i = 1 to Len( string )
      spec = Mid(string, i, 1)
      Set regExp = New RegExp
      regExp.Global = True
      regExp.IgnoreCase = True
      regExp.Pattern = "[\-0-9]"
      set match = regExp.Execute(spec)
      If match.count = 0 Then
			'if the char is not [0-9] return false(not an integer)
            IsInteger = False
            Exit Function
      End If
      Set regExp = Nothing
Next
IsInteger = True
End Function

Function IsNumber(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	IsNumber = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
For i = 1 to Len( string )
      spec = Mid(string, i, 1)
      Set regExp = New RegExp
      regExp.Global = True
      regExp.IgnoreCase = True
      regExp.Pattern = "[\-\.0-9]"
      set match = regExp.Execute(spec)
      If match.count = 0 Then
			'if the char is not [0-9] return false(not an integer)
            IsNumber = False
            Exit Function
      End If
      Set regExp = Nothing
Next
IsNumber = True
End Function
%>