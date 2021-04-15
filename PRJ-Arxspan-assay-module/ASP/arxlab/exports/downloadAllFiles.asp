<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/attachments/functions/fnc_getAttachmentFilePath.asp"-->
<%
'mfu
If session("hasMUFExperiment") or hasFileSearch then
	exportPath = uploadRoot&"\exports\"&session("userId")&"\experimentFiles"
	endPath = uploadRoot&"\exports\"&session("userId")
	
	on error resume next
	SET fso = Server.CreateObject("Scripting.FileSystemObject")
	If fso.FolderExists(exportPath) Then
		fso.DeleteFolder(exportPath)
	End if
	Set fso = Nothing
	on error goto 0

	a = recursiveDirectoryCreate(uploadRoot,exportPath)
	Set rec = server.CreateObject("ADODB.RecordSet")
	attachmentIds = Split(request.Form("attachmentIds"),",")
	attachmentIdStr = ""
	For i = 0 To UBound(attachmentIds)
		attachmentIdStr = attachmentIdStr & SQLClean(attachmentIds(i),"N","S")
		If i<UBound(attachmentIds) Then
			attachmentIdStr = attachmentIdStr &","
		End if
	Next
	If attachmentIdStr = "" Then
		attachmentIdStr = "0"
	End if
	notebookList = getReadNotebooks(session("userId"))
	strQuery = "SELECT id, experimentType from allAttachmentsHistoryView WHERE companyId="&SQLClean(session("companyId"),"N","S")& " AND id in ("&attachmentIdStr&") AND notebookId in ("&notebookList&")"
	rec.open strQuery,conn,0,-1
	Do While Not rec.eof
		filepath = getAttachmentFilePath(rec("experimentType"),rec("id"),"","true",false)
		displayFileName = getAttachmentDisplayFileName(rec("experimentType"),rec("id"),"","true",false)
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(filepath) Then
			Set adoStream = CreateObject("ADODB.Stream")  
			adoStream.Open()  
			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)
			adoStream.SaveToFile exportPath &  "\"&CStr(rec("id"))&"-"&cleanFilename(displayFilename), 2
			adoStream.Close
			Set adoStream = Nothing  
		End If
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	Set rec = server.CreateObject("ADODB.RecordSet")

	Call getconnectedadm
	endFile = endPath &"\"&Replace("files"," ","")&".zip"
	strQuery = "INSERT into exports(userId,exportPath,endFile,status) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(exportPath,"T","S")&","&SQLClean(endFile,"T","S")&",0)"
	connAdm.execute(strQuery)
	Call disconnectAdm
	Call disconnect
	response.redirect(mainAppPath&"/exports/exportWait.asp")

End if
%>