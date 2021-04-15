<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/attachments/functions/fnc_getAttachmentFilePath.asp"-->
<%
experimentType = request.querystring("experimentType")
attachmentId = request.querystring("id")
pre = request.querystring("pre")
hist = request.querystring("history")
experimentId = getAttachmentExperimentId(experimentType,attachmentId,pre,hist)
If canViewExperiment(experimentType,experimentId,session("userId")) then
	filepath = getAttachmentFilePath(experimentType,attachmentId,pre,hist,False)
	If filepath <> "" Then
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(filepath) Then
			response.ContentType="image/JPEG"
			Set adoStream = CreateObject("ADODB.Stream")  
			adoStream.Open()  
			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)  
			Response.BinaryWrite adoStream.Read()  
			adoStream.Close: Set adoStream = Nothing  
			Response.End  
		End if
	End if
End if
%>