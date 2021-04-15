<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function ColumnExists(objRS, Column)
  Dim blnOutput, x
  blnOutput = True
  On Error Resume Next
  x = objRS(Column)
  If err.Number <> 0 Then blnOutput = False
  On Error Goto 0
  ColumnExists = blnOutput
End Function
%>