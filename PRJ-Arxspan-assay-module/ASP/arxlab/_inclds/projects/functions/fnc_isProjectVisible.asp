<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function isProjectVisible(projectId)
	'returns true if the specified project is visible
	Set insRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM projects WHERE id="&SQLClean(projectId,"N","S") & " AND visible=1"
	insRec.open strQuery,conn,3,3
	isProjectVisible = Not insRec.eof
	
end function
%>