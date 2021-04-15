<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function ownsProject(cProjectId)
	'returns true if the logged in user owns the specified project id
	If cProjectId <> "" then
		ownsProject = False
		Call getconnected
		Set crnRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM projects WHERE userId="&SQLClean(session("userId"),"N","S") & " AND id="&SQLClean(cProjectId,"N","S")
		crnRec.open strQuery,conn,3,3
		If Not crnRec.eof Then
			ownsProject = True
		End if
	Else
		ownsProject = False
	End if
end Function
%>