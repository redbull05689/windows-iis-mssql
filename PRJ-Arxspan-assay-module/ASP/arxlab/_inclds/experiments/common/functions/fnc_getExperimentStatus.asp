<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getExperimentStatus(experimentType,experimentId,revisionNumber, returnName)
	'get the revision number of the specified experiment

	'select the appropriate history table for the experiment type
	Select Case experimentType
		Case "1"
			tableName = "experiments_history"
		Case "2"
			tableName = "bioExperiments_history"
		Case "3"
			tableName = "freeExperiments_history"
		Case "4"
			tableName = "analExperiments_history"
		Case "5"
			tableName = "custExperiments_history"
	End select

	'get the experiment history record order backwards so that the first row is the last revision
	Set geRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "select s.id as id, s.name as name from statuses s join "&tableName&" t on t.statusId = s.id where t.experimentId = " & SQLClean(experimentId,"N","S") & " and t.revisionNumber = " & SQLClean(revisionNumber,"N","S")
	geRec.open strQuery,conn,adOpenStatic,adLockReadOnly
	If Not geRec.eof Then
		'set the function value to the last revision number
		if returnName = true Then
			getExperimentStatus = geRec("name")
		else
			getExperimentStatus = CStr(geRec("id"))
		end if
	End if
end function
%>