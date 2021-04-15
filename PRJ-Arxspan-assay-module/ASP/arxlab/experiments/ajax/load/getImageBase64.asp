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
			response.ContentType="text/plain"
			Set adoStream = CreateObject("ADODB.Stream")  
			adoStream.Open()  
			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)
			Set objXML = CreateObject("MSXml2.DOMDocument")
			Set objDocElem = objXML.createElement("Base64Data")
			objDocElem.dataType = "bin.base64"
			objDocElem.nodeTypedValue = adoStream.Read()
			randomize
			string64 = objDocElem.text
			'get the file extension and complete the string format "[file_extension];[b64 data]"
			imageData = "data:image/"&getFileExtension(filepath) & ";base64," & string64
			Response.Write imageData
			adoStream.Close: Set adoStream = Nothing  
			Response.End  
			adoStream.Close
			Set adoStream = Nothing  
		End if
	End if
End if
%>