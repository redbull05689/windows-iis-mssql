<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function getGroupIdListByUser(userId)
	'get all groups that the specified user is in
	groupCount = 0
	groupString = ""
	
	Set grnRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT DISTINCT groupId FROM groupMembers WHERE userId="&SQLClean(userId,"N","S")&" AND companyId=" & SQLClean(session("companyId"),"N","S")
	grnRec.open strQuery,conn,3,3
	
	'loop through all the groups
	Do While Not grnRec.eof
		groupCount = groupCount + 1
		groupString = groupString & grnRec("groupId") & ","
		grnRec.movenext
	Loop
	grnRec.close
	Set grnRec = Nothing
	
	'remove the trailing comma if the string is not empty
	If groupCount >= 1 Then
		groupString = Mid(groupString,1,Len(groupString)-1)
	End If
	
	If groupString = "" Then
		getGroupIdListByUser = "(0)"
	Else
		'return the list of groups
		getGroupIdListByUser = "(" & groupString & ")"
	End if
End Function
%>