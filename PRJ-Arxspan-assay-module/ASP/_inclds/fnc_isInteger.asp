<%
Function IsInteger(byVal string)
If String = "" Then
	IsInteger = False
	Exit Function
End if
dim regExp, match, i, spec
For i = 1 to Len( string )
      spec = Mid(string, i, 1)
      Set regExp = New RegExp
      regExp.Global = True
      regExp.IgnoreCase = True
      regExp.Pattern = "[0-9]"
      set match = regExp.Execute(spec)
      If match.count = 0 then
            IsInteger = False
            Exit Function
      End If
      Set regExp = Nothing
Next
IsInteger = True
End Function
%>