<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getExperimentRevisionNumber(experimentType,experimentId)
	'get the revision number of the specified experiment

	'select the appropriate history table for the experiment type
	prefix = GetPrefix(experimentType)
	tableName = GetFullname(prefix, "experiments", true)
	
	'get the experiment history record order backwards so that the first row is the last revision
	Set geRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT revisionNumber from "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")
	geRec.open strQuery,conn,adOpenStatic,adLockReadOnly
	If Not geRec.eof Then
		'set the function value to the last revision number
		if IsNull(geRec("revisionNumber")) Then
			getExperimentRevisionNumber = 1
		else
			getExperimentRevisionNumber = CStr(geRec("revisionNumber"))
		end if
	End if
end function
%>