<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function addNoteToExperiment(experimentType,experimentId,name,note,readOnly)
	'used to add a note to an experiment this is used by the quick note functionality, and the experiment rejection functionality
	'allows setting of read-only flag

	'get the current revision number so that we know what revision to put the note on in the history
	revisionNumber = getExperimentRevisionNumber(experimentType,experimentId)

	'get the table name of the notes table for the experiment type
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "notes", true)

	readOnlySQL = null
	if readOnly Then
		readOnlySQL = 1
	end if

	'insert the note into the note table
	strQuery = "INSERT into "&tableName&"(userId,experimentId,name,note,revisionNumber,readOnly,dateAdded,dateUpdated,dateAddedServer,dateUpdatedServer) values("&_
	SQLClean(session("userId"),"N","S") & "," &_
	SQLClean(experimentId,"N","S") & "," &_
	SQLClean(name,"T","S") & "," &_
	SQLClean(note,"T","S") & "," &_
	SQLClean(revisionNumber,"N","S") & "," &_
	SQLClean(readOnlySQL,"N","S") & "," &_
	"GETUTCDATE(),GETUTCDATE(),GETDATE(),GETDATE())"

	Set rs = connAdm.execute(strQuery)

	'add note and get the id of the note newId used for link in history table
	Set sRec = server.CreateObject("ADODB.recordSet")

	lastIdSQL = "SELECT TOP 1 id FROM " & tableName &_
	" WHERE userId = " & SQLClean(session("userId"),"N","S") &_
	" AND experimentId = " & SQLClean(experimentId,"N","S") &_
	" ORDER BY id DESC"

	sRec.open lastIdSQL,connAdm,3,3
	newId = 0		
	If not sRec.eof then
		newId = sRec("id")
	end if
	sRec.close	

	'insert note into the history table of the current revision
	strQuery = "INSERT into "&tableName&"_history(userId,experimentId,name,note,revisionNumber,noteId,readOnly,dateAdded,dateUpdated,dateAddedServer,dateUpdatedServer) values("&_
	SQLClean(session("userId"),"N","S") & "," &_
	SQLClean(experimentId,"N","S") & "," &_
	SQLClean(name,"T","S") & "," &_
	SQLClean(note,"T","S") & "," &_
	SQLClean(revisionNumber,"N","S") & "," &_
	SQLClean(newId,"N","S") & "," &_
	SQLClean(readOnlySQL,"N","S") & "," &_
	"GETUTCDATE(),GETUTCDATE(),GETDATE(),GETDATE())"

	'add note to get history and get the id of the note (nxq to get newId?)
	Set rs = connAdm.execute(strQuery)

	'get table for setting unsaved changes
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "experiments", true)

	'set experiment as having unsaved changes
	'strQuery = "UPDATE "&tableName&" SET unsavedChanges=1 WHERE id="&SQLClean(experimentId,"N","S")
	'connAdm.execute(strQuery)

end function
%>