<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function experimentHasNotes(experimentType,experimentId,revisionNumber)
	'return true if the specified revision of the experiment has notes
	experimentHasNotes = False

	'select the right notes tables for the experiment type
	prefix = GetPrefix(experimentType)
	notesTable = GetFullName(prefix, "notes", true)
	notesHistoryTable = GetFullName(prefix, "notes_history", true)
	notesPreSaveTable = GetFullName(prefix, "notes_preSave", true)

	set hnRec = server.createobject("ADODB.RecordSet")
	If revisionNumber = "" then 
		'if the revision number is blank check the current notes table
		strQuery = "SELECT id FROM "&notesTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
		hnRec.open strQuery,conn,3,3
		If Not hnRec.eof Then
			experimentHasNotes = True
		Else
			'if there are no current notes then check the presave table
			hnRec.close
			strQuery = "SELECT id FROM "&notesPreSaveTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
			hnRec.open strQuery,conn,3,3
			If Not hnRec.eof then
				experimentHasNotes = True
			End if
		End if	
	Else
		'if the revision number is not blank then check the specified revision
		strQuery = "SELECT id from "&notesHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
		hnRec.open strQuery,conn,3,3
		If Not hnRec.eof Then
			experimentHasNotes = True
		End if
	End if
end function
%>