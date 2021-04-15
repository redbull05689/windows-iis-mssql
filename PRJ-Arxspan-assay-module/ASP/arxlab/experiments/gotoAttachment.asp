<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
'takes an experiment id/type and an attachment name and opens up that experiment as displays the attachment
'this is used for the search where the attachment id is not known

'get querystring parameters
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
attachmentFilename = request.querystring("attachmentFilename")

'from the experiment type generate the correct database tables and asp display pages
prefix = GetPrefix(experimentType)
thisExpPage = GetExperimentPage(prefix)
attachmentsTable = GetFullName(prefix, "attachments", true)
attachmentsPreSaveTable = GetFullName(prefix, "attachments_preSave", true)

'build experiment page link
experimentPage = mainAppPath & "/" & thisExpPage&"?id="&experimentId

Call getconnected
'search for attachment in main attachments table
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM "&attachmentsTable&" WHERE actualFilename="&SQLClean(attachmentFileName,"T","S")
rec.open strQuery,conn,0,-1
If Not rec.eof Then
	'add the attachment id to the link
	experimentPage = experimentPage & "&attachmentId=" & rec("id") & "&tab=attachmentTable"
	Call disconnect
	response.redirect(experimentPage)
End if
rec.close
Set rec = Nothing

'search for attachment in pre save attachments table
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM "&attachmentsPreSaveTable&" WHERE actualFilename="&SQLClean(attachmentFileName,"T","S")
rec.open strQuery,conn,0,-1
If Not rec.eof then
	'add the attachment id to the link
	experimentPage = experimentPage & "&attachmentId=p_" & rec("id") & "&tab=attachmentTable"
	Call disconnect
	response.redirect(experimentPage)
End if
rec.close
Set rec = nothing
Call disconnect
%>