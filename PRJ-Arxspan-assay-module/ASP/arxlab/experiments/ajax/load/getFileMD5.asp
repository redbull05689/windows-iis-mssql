<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/attachments/functions/fnc_getAttachmentFilePath.asp"-->
<!-- #include file="../../../_inclds/attachments/functions/fnc_hashBytes.asp"-->

<%
server.scripttimeout = 60000
response.charset = "UTF-8"
response.codePage = 65001
experimentType = request.querystring("experimentType")
attachmentId = request.querystring("id")
If request.querystring("stream") <> "" Then
	doStream = True
Else
	doStream = False
End If

Set rec = server.CreateObject("ADODB.RecordSet")
pre = request.querystring("pre")
historyFlag = request.querystring("history")
If request.querystring("officeAttachment") = "" Then
	officeAttachment = False
Else
	officeAttachment = True
End If


filepath = getAttachmentFilePath(experimentType,attachmentId,pre,historyFlag,officeAttachment)
experimentId = getAttachmentExperimentId(experimentType,attachmentId,pre,historyFlag)
If canViewExperiment(experimentType,experimentId,session("userId")) then
	displayFileName = getAttachmentDisplayFileName(experimentType,attachmentId,pre,historyFlag,officeAttachment)

	If filepath <> "" Then
		t = Split(filepath,"\")
		filename = t(UBound(t))
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(filepath) Then
			'response.write(ReadBinaryFile(filepath))
			response.write(bytesToHex(md5hashBytes(ReadBinaryFile(filepath))))
			Response.End  
		Else
			Response.Status = "404 File Not Found"
			response.end
		End if
	End if
End if


Function ReadBinaryFile(FileName)
  Const adTypeBinary = 1
  
  'Create Stream object
  Dim BinaryStream
  Set BinaryStream = CreateObject("ADODB.Stream")
  
  'Specify stream type - we want To get binary data.
  BinaryStream.Type = adTypeBinary
  
  'Open the stream
  BinaryStream.Open
  
  'Load the file data from disk To stream object
  BinaryStream.LoadFromFile FileName
  
  'Open the stream And get binary data from the object
  ReadBinaryFile = BinaryStream.Read
End Function
%>