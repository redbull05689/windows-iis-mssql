<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function isExperimentVisible(experimentType,experimentId)
	'return true if the specified experiment is visible
	Set insRec = server.CreateObject("ADODB.RecordSet")
	'select the right table for the experiment type 'nxq could use notebook index view?
	prefix = GetPrefix(experimentType)
	tableName = GetFullname(prefix, "experiments", true)
	strQuery = "SELECT id FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S") & " AND visible=1"
	insRec.open strQuery,conn,3,3
	If insRec.eof Then
		isExperimentVisible = False
	Else
		isExperimentVisible = True
	End if
end function
%>