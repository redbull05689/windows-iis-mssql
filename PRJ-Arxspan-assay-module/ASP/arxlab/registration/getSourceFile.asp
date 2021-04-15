<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
experimentType = request.querystring("experimentType")
attachmentId = request.querystring("id")
Call getConnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM fileAttachments WHERE id="&SQLClean(attachmentId,"N","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	filepath = uploadRootReg&"\"&rec("actualFilename")
	displayFilename = rec("filename")
End if
Call disconnectJchemReg

extension = getFileExtension(filepath)
If filepath <> "" Then
	t = Split(filepath,"\")
	filename = t(UBound(t))
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	if fs.FileExists(filepath) Then
		Set adoStream = CreateObject("ADODB.Stream")
		adoStream.Open()
		If extension = "pdf" then
			response.contenttype="application/pdf"
			response.addheader "contenttype","application/pdf"
		Else
			response.contenttype="application/octet-stream"
			response.addheader "contenttype","application/octet-stream"
		End If
		If doStream Then
			response.contenttype="text/plain"
			response.addheader "contenttype","text/plain"
		End If
		
		response.addheader "Content-Disposition", "attachment; " & "filename=""" & displayFileName &""""

		adoStream.Type = 1  
		adoStream.LoadFromFile(filepath)  

			Set fs=Server.CreateObject("Scripting.FileSystemObject")
			Set f=fs.GetFile(filepath)
			dataSize = f.size
			Set f = nothing
			Set fs = Nothing
			
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
		response.write("file does not exist")
		response.end
	End if
End if
%>