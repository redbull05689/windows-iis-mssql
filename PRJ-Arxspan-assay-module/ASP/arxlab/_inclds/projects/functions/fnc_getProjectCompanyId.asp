<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getProjectCompanyId(projectId)
	'get the company id of a project
	Set geRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT companyId FROM projectsView WHERE id="&SQLClean(projectId,"N","S")
	geRec.open strQuery,conn,3,3
	If Not geRec.eof Then
		'return company id
		getProjectCompanyId = CStr(geRec("companyId"))
	End If
	geRec.close
	Set geRec = nothing
end function
%>