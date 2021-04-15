<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getCaseNumber()
Call getconnected
y = Year(Date())
m = Month(Date())
d = Day(Date())
y = Mid(y,3,2)
If Len(m) = 1 Then
	m = "0" & m
End If
If Len(d) = 1 Then
	d = "0" & d
End If
dp = y & m & d
If session("overrideDB") = "BROAD" Then
	dp = "B" &"-"& dp
End if

'default to case number 1
caseNumber = 1

On Error Resume Next
Set caseNumRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT COUNT(*) as caseNumber from cases WHERE caseNumber like '%" & dp & "%'"
caseNumRec.Open strQuery,Conn,adOpenStatic,adLockReadOnly
If Not caseNumRec.eof Then
	caseNumber = CLng(caseNumRec("caseNumber")) + 1
End if
caseNumRec.close
Set caseNumRec = Nothing
On Error Goto 0

getCaseNumber = dp & "-" & caseNumber
end function
%>