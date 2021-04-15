<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
attachmentId = request.querystring("id")
Call getConnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM fileAttachments WHERE id="&SQLClean(attachmentId,"N","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	filepath = uploadRootReg&"\"&rec("actualFilename")
End if
Call disconnectJchemReg
If filepath <> "" Then
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	if fs.FileExists(filepath) Then
		response.ContentType="image/JPEG"
		Set adoStream = CreateObject("ADODB.Stream")  
		adoStream.Open()  
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
	End if
End if
%>