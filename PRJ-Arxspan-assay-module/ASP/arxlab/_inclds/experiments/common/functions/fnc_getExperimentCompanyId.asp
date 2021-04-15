<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getExperimentCompanyId(experimentType,experimentId)
	'get the company id of the specified experiment
	Set geRec = server.CreateObject("ADODB.RecordSet")
	prefix = GetPrefix(experimentType)
	experimentView = GetExperimentView(prefix)

	strQuery = "SELECT companyId FROM " & experimentView & " WHERE id="&SQLClean(experimentId,"N","S")
	geRec.open strQuery,conn,3,3
	If Not geRec.eof Then
		'if the record is found then set the function value to the company Id
		getExperimentCompanyId = CStr(geRec("companyId"))
	End If
	geRec.close
	Set geRec = nothing
end function
%>