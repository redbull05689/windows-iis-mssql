<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function addNoteToExperimentPreSave(experimentType,experimentId,name,note,readOnly)
	'used to add a note to an experiment this is used by the quick note functionality
	'this note is not going to be inserted into the experiment but will be added to the preSave table
	'the note will not become part of the experiment until the experiment is saved

	'get revision number of experiment
	revisionNumber = getExperimentRevisionNumber(experimentType,experimentId)

	'get correct presave table for experiment type
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "notes_preSave", true)

	readOnlySQL = null
	if readOnly Then
		readOnlySQL = 1
	end if

	'insert note into note presave table
	strQuery = "INSERT into "&tableName&"(userId,experimentId,name,note,revisionNumber,readOnly,dateAdded,dateUpdated,dateAddedServer,dateUpdatedServer) values("&_
	SQLClean("0","N","S") & "," &_
	SQLClean(experimentId,"N","S") & "," &_
	SQLClean(name,"T","S") & "," &_
	SQLClean(note,"T","S") & "," &_
	SQLClean(revisionNumber,"N","S") & "," &_
	SQLClean(readOnlySQL,"N","S") & "," &_
	"GETUTCDATE(),GETUTCDATE(),GETDATE(),GETDATE())"
	
	'not necessary to get new id nxq
	Set rs = connAdm.execute(strQuery)
	newId = CStr(rs("newId"))

	'set read only if necessary. I don't think that this is used, but it is an option
	If readOnly Then
		strQuery = "UPDATE "&tableName&" SET readOnly=1 WHERE id="&SQLClean(newId,"N","S")
		connAdm.execute(strQuery)
	End If
	
end function
%>