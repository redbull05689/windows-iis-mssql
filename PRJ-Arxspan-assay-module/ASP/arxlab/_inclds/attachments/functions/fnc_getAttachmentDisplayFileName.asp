<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getAttachmentDisplayFileName(experimentType,id,pre,history,officeAttachment)
	'get the display name for the attachment
	'pre means presave table,history means history table
	'no pre and no history means attachments table
	'the id is the id of the attachment table (i.e the actual row identifier) not a specific attachment id

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

	strQuery = "SELECT filename from " & tableName & " WHERE id=" & SQLClean(attachmentId,"N","S")
	Call getconnected
	Set imageRec = server.CreateObject("ADODB.Recordset")
	imageRec.open strQuery,conn,3,3
	If Not imageRec.eof Then
		'if the attachment is found then set the function value to the name column of the query
		getAttachmentDisplayFileName = imageRec("filename")
	End if
end function
%>