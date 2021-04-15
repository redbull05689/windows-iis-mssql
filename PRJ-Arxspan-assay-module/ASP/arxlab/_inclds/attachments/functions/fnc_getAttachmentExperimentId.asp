<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getAttachmentExperimentId(experimentType,id,pre,history)
	'get the experiment if of an attachment
	'mostly used for permissions so you can tell if a user can access the specified attachment
	'pre means presave table
	'history means history table
	'no pre and no history means the default attachments table
	'the id is the attachment table id (i.e. the row identifier) not an attachment id

	prefix = getPrefix(experimentType)
	exType = getAbbreviation(experimentType)

	tableName = ""
	if pre = "" then
		if history = "" then
			tableName = "attachments"
		else
			tableName = "attachments_history"
		end if
	else
		tableName = "attachments_preSave"
	end if

	tableName = GetFullName(prefix, tableName, true)

	strQuery = "SELECT experimentId from " & tableName & " WHERE id=" & SQLClean(attachmentId,"N","S")
	Call getconnected
	Set imageRec = server.CreateObject("ADODB.Recordset")
	imageRec.open strQuery,conn,3,3
	If Not imageRec.eof Then
		'if the record is found set the function value equal to the experiment id of the query
		getAttachmentExperimentId = CStr(imageRec("experimentId"))
	Else
		'return blank if not found
		getAttachmentExperimentId = ""
	End if
end function
%>