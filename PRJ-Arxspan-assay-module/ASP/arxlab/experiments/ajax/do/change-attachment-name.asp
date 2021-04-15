<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
'this script changes the name of an attachment that is in the presave table
'attachments that are not saved in the presave table are handled by experiment saving and the experiment drafts
'this script is pretty old and may be obsoleted by the experiment draft autosave functionality
attachmentId = request.querystring("attachmentId")
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
name = request.querystring("name")

Call getconnectedadm

'only the owner of an experiment may change the attachment name
If ownsExperiment(experimentType,experimentId,session("userId")) then
	Set rec = CreateObject("ADODB.RecordSet")
	prefix = GetPrefix(experimentType)
	attachmentsPreSaveTable = GetFullName(prefix, "attachments_preSave", true)
	strQuery = "SELECT id FROM " & attachmentsPreSaveTable & " WHERE id="&SQLClean(attachmentId,"N","S")
	'make sure the attachment exists
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		'disallow blank names
		If name = "" Then
			name = "Untitled"
		End If
		prefix = GetPrefix(experimentType)
		attachmentsPreSaveTable = GetFullName(prefix, "attachments_preSave", true)
		strQuery = "UPDATE " & attachmentsPreSaveTable & " set name="&SQLClean(name,"T","S")& " WHERE id="&SQLClean(attachmentId,"N","S")
		'update the attachment name
		connAdm.execute(strQuery)
	End if

End If

Call disconnectadm()
%>