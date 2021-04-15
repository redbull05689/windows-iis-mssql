<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/attachments/functions/fnc_getAttachmentFilePath.asp"-->
<%
'stream browser viewable file or preview of file to the attachment preview iframe

'get querystring params
experimentType = request.querystring("experimentType")
attachmentId = request.querystring("id")
pre = request.querystring("pre")
hist = request.querystring("history")
officeDoc = request.querystring("isOfficeDoc")

'if the attachemnt is an office document get the PDF filepath for the preview.  Otherwise get the actual file
If officeDoc = 1 then
	filepath = getAttachmentFilePath(experimentType,attachmentId,pre,hist,true)
Else
	filepath = getAttachmentFilePath(experimentType,attachmentId,pre,hist,false)
End If

'get experiment id from experiment type and attachment id
experimentId = getAttachmentExperimentId(experimentType,attachmentId,pre,hist)

'can only see preview if user can view the parent experiment
If canViewExperiment(experimentType,experimentId,session("userId")) then
	'if we have a filepath for the preview
	If filepath <> "" Then
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		'make sure file exists
		if fs.FileExists(filepath) Then
			'stream appropriate file
			Set adoStream = CreateObject("ADODB.Stream")
			adoStream.Open()
			'set content type for office docs to be pdf
			If officeDoc = 1 then
				response.contenttype="application/pdf"
				response.addheader "contenttype","application/pdf"
				response.addheader "Content-Disposition", "inline; " & "filename=preview-" & request.querystring("id") & "_" & getRandomString(4) & ".pdf"
			Else
				response.contenttype="text/plain"
				response.addheader "contenttype","text/plain"
				response.addheader "Content-Disposition", "inline; " & "filename=preview-" & request.querystring("id") & "_" & getRandomString(4) & ".txt"
			End if
			adoStream.Type = 1  
			'load file
			adoStream.LoadFromFile(filepath)  

				Set fs=Server.CreateObject("Scripting.FileSystemObject")
				Set f=fs.GetFile(filepath)
				dataSize = f.size
				Set f = nothing
				Set fs = Nothing
				
				'chunk stream by 4MB
				dataPosition = 0
				chunkSize = 1024*1024*4
				do while dataPosition < dataSize
				Response.BinaryWrite adoStream.Read(chunkSize)
				Response.flush
				dataPosition = dataPosition + chunkSize
				loop

			adoStream.Close: Set adoStream = Nothing  
			Response.End  
		Else
			'error if file does not exist
			response.write("file does not exist")
			response.end
		End if
	End if
End if
%>