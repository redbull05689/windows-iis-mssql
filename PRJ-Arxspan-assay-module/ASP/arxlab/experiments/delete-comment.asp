<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
hasCommentDeleteButtons = getCompanySpecificSingleAppConfigSetting("hasCommentDeleteButtons", session("companyId"))
'deletes a comment via ajax
commentIds = request.Form("commentId[]")
commentId = Split(commentIds,",")
commenterId = ""
experimentId = ""
attachmentId = ""
actualFileName = ""
deleteFile = ""
Set file = CreateObject("Scripting.FileSystemObject") 
if hasCommentDeleteButtons = 1 then
	Call getconnectedadm
	for q =0 to ubound(commentId)
	'make sure the comment to be deleted is owned by the user
	Set dcRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM experimentComments WHERE id="&SQLClean(commentId(q),"N","S") & " AND userId="&SQLClean(session("userId"),"N","S")
	dcRec.open strQuery,conn,3,3
	If Not dcRec.eof Then
		'delete all the attachments of the selected comment
		Set attRec = server.CreateObject("ADODB.RecordSet")  
		attQuery = "SELECT commenterId,experimentId,id,actualFileName FROM commentAttachments WHERE commentId="&SQLClean(commentId(q),"N","S")

		attRec.open attQuery,conn,3,3
		If Not attRec.eof Then
			commenterId = attRec("commenterId")
			experimentId = attRec("experimentId")
			attachmentId = attRec("id")
			actualFileName = attRec("actualFileName")

			deleteFile = uploadRoot & "\" & commenterId &"\" & experimentId & "\" & "Comments" & "\" & commentId(q) & "\" & actualFileName

			delQuery = "DELETE FROM commentAttachments WHERE id="&SQLClean(attachmentId,"N","S")
		    connAdm.execute(delQuery)

		    if file.FileExists(deleteFile) then
		         file.DeleteFile(deleteFile)
		    end if
		End If

		attRec.close
		Set attRec = Nothing

		strQuery = "UPDATE experimentComments SET deleted=1 WHERE id="&SQLClean(commentId(q),"N","S")
		connAdm.execute(strQuery)

	End If
	next
	dcRec.close
	Set dcRec = Nothing
end if
%>