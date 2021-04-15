<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/attachments/functions/fnc_getAttachmentFilePath.asp"-->

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

Function HTMLDecode(sText)
    Dim regEx
    Dim matches
    Dim match
    sText = Replace(sText, "&quot;", Chr(34))
    sText = Replace(sText, "&lt;"  , Chr(60))
    sText = Replace(sText, "&gt;"  , Chr(62))
    sText = Replace(sText, "&amp;" , Chr(38))
    sText = Replace(sText, "&nbsp;", Chr(32))


    Set regEx= New RegExp

    With regEx
     .Pattern = "&#(\d+);" 'Match html unicode escapes
     .Global = True
    End With

    Set matches = regEx.Execute(sText)

    'Iterate over matches
    For Each match in matches
        'For each unicode match, replace the whole match, with the ChrW of the digits.

        sText = Replace(sText, match.Value, ChrW(match.SubMatches(0)))
    Next

    HTMLDecode = sText
End Function

filepath = getAttachmentFilePath(experimentType,attachmentId,pre,historyFlag,officeAttachment)
experimentId = getAttachmentExperimentId(experimentType,attachmentId,pre,historyFlag)
If canViewExperiment(experimentType,experimentId,session("userId")) then
	displayFileName = getAttachmentDisplayFileName(experimentType,attachmentId,pre,historyFlag,officeAttachment)
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
			
			If doStream then
				response.addheader "Content-Disposition", "inline; " & "filename=""" & Server.UrlEncode(HTMLDecode(displayFileName)) &""""
			else
				response.addheader "Content-Disposition", "attachment; " & "filename=""" & Server.UrlEncode(HTMLDecode(displayFileName)) &""""
			End if

			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)  

				Set fs=Server.CreateObject("Scripting.FileSystemObject")
				Set f=fs.GetFile(filepath)
				dataSize = f.size
				Set f = nothing
				Set fs = Nothing
				Response.AddHeader "Content-Length", dataSize
				
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
End if
%>