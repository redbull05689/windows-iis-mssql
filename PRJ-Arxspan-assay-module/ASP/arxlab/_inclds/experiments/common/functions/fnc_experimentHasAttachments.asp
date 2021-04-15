<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function experimentHasAttachments(experimentType,experimentId,revisionNumber)
	'check whether or not a specific version of an experiment has attachments
	experimentHasAttachments = False
	'select the correct attachment table for the experiment type
	prefix = GetPrefix(experimentType)
	attachmentsTable = GetFullName(prefix, "attachments", true)
	attachmentsHistoryTable = GetFullName(prefix, "attachments_history", true)
	attachmentsPreSaveTable = GetFullName(prefix, "attachments_preSave", true)

	set haRec = server.createobject("ADODB.RecordSet")
	If revisionNumber = "" then 
		'if revision number is blank then check the current attachments table
		strQuery = "SELECT id FROM "&attachmentsTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
		haRec.open strQuery,conn,3,3
		If Not haRec.eof Then
			experimentHasAttachments = True
		Else
			''if there is nothing in the current attachments table check the presave table
			'haRec.close
			'strQuery = "SELECT * FROM "&attachmentsPreSaveTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
			'haRec.open strQuery,conn,3,3
			'If Not haRec.eof then
			'	experimentHasAttachments = True
			'End if
		End if	
	Else
		'if there is a revision number then check the attachment history table
		strQuery = "SELECT id from "&attachmentsHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
		haRec.open strQuery,conn,3,3
		If Not haRec.eof Then
			experimentHasAttachments = True
		End if
	End if
end function
%>