<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
function getAttachmentFilePath(experimentType,id,pre,history,officeAttachment)
	'get the attachments file path for a specified attachment, for display inside browser
	'pre means presave table,history means history table
	'no pre and no history means attachments table
	'the id is the id of the attachment table (i.e the actual row identifier) not a specific attachment id
	'officeAttchment is whether or not the attachment is an office doc. If it is we will show the pdf version

	colNames = "actualFileName, userId, experimentId, "

	prefix = getPrefix(experimentType)
	exType = getAbbreviation(experimentType)

	tableName = ""
	if pre = "" then
		if history = "" then
			tableName = "attachments"
			colNames = colNames & "revisionNumber"
		else
			tableName = "attachments_history"
			colNames = colNames & "originalRevisionNumber"
		end if
	else
		tableName = "attachments_preSave"
		colNames = colNames & "revisionNumber"
	end if

	tableName = GetFullName(prefix, tableName, true)
	
	strQuery = "SELECT " & colNames & " from " & tableName & " WHERE id=" & SQLClean(id,"N","S")

	Call getconnected
	Set imageRec = server.CreateObject("ADODB.Recordset")

	imageRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
	If Not imageRec.eof Then
		If officeAttachment then
			'if the attachment is an office doc then replace the filename's extension with .pdf else just take the filename
			If LCase(right(imageRec("actualFileName"),3)) <> "pdf" then
				filename = imageRec("actualFileName") & ".pdf"
			Else
				filename = imageRec("actualFileName")
			End if
		Else
			filename = imageRec("actualFileName")
		End if
		If history = "" Then
			'if the history flag is blank then get the standard current revision file path else create a path to the original revision number 'nxq make a function to generate these file paths
			filepath = uploadRootRoot & "\" & getCompanyIdByUser(imageRec("userId")) & "\"&imageRec("userId")&"\"&imageRec("experimentId")&"\"&imageRec("revisionNumber")&"\"&exType&"\"&filename
		Else
			filepath = uploadRootRoot & "\" & getCompanyIdByUser(imageRec("userId")) & "\"&imageRec("userId")&"\"&imageRec("experimentId")&"\"&imageRec("originalRevisionNumber")&"\"&exType&"\"&filename
		End If
		'set function value to filepath
		getAttachmentFilePath = filepath
	Else
		'if the record was not found then return blank
		getAttachmentFilePath = ""
	End if
end function
%>