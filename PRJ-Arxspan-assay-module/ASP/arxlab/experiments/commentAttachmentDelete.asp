<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
'deletes a comment attachment via ajax
attachmentId = request.Form("attachmentId")

'get the real name of file stored in backend
Call getconnectedadm
Set dcRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT experimentId, experimentType, commentId, commenterId, actualFileName FROM commentAttachments WHERE id="&SQLClean(attachmentId,"N","S")&" AND commenterId="&SQLClean(session("userId"),"N","S")

dcRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
If Not dcRec.eof Then
	actualFileName = dcRec("actualFileName")
	path = uploadRoot & "\" & dcRec("commenterId") & "\commentAttachments\" & dcRec("experimentType") & "\" & dcRec("experimentId") & "\" & dcRec("commentId") & "\"
	dcRec.close
	Set dcRec = Nothing
Else
	dcRec.close
	Set dcRec = Nothing
	response.end
End if

If path <> "" And actualFileName <> "" Then
	'delete the selected file
	delQuery = "DELETE FROM commentAttachments WHERE id="&SQLClean(attachmentId,"N","S")
	connAdm.execute(delQuery)
	Call disconnectadm

	'delete the file if it exists
	Set file = CreateObject("Scripting.FileSystemObject") 
	If file.FileExists(path&actualFileName) Then
		file.DeleteFile(path&actualFileName)
	End If
End If

%>
