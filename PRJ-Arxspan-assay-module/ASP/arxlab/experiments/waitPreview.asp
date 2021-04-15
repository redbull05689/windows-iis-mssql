<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/attachments/functions/fnc_getAttachmentFilePath.asp"-->
<%
'this script is loaded into an IFrame for an attachment preview.  It waits for the target file to exist on the drive
'while it does not exist it displays a processing icon and retries every 5 secdonds.
'when the file does exist it redirects to show preview

'get querystring params
experimentType = request.querystring("experimentType")
attachmentId = request.querystring("id")
pre = request.querystring("pre")
hist = request.querystring("history")
experimentId = getAttachmentExperimentId(experimentType,attachmentId,pre,hist)
officeDoc = request.querystring("isOfficeDoc")

'only users who can view experiment can access this page
If canViewExperiment(experimentType,experimentId,session("userId")) Then
	'get the full filepath of the file
	officeAtt = officeDoc = 1
	filepath = getAttachmentFilePath(experimentType, attachmentId, pre, hist, officeAtt)
	
	'if the system could generate a file path
	If filepath <> "" Then
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		'if the file exists redirect to show preview 
		if fs.FileExists(filepath) Then
		%>
			<script type="text/javascript">
				window.location = "<%=mainAppPath%>/experiments/showPreview.asp?id=<%=request.querystring("id")%>&experimentType=<%=request.querystring("experimentType")%>&pre=<%=request.querystring("pre")%>&history=<%=request.querystring("history")%>&isOfficeDoc=<%=officeDoc%>";
			</script>
		<%
		Else
			'if the file does not exist reload this page after 5 seconds
		%>
			processing<img src="<%=mainAppPath%>/images/ajax-loader.gif">
			<script type="text/javascript">
				setTimeout('location.reload(true)',5000)
			</script>
		<%
		End if
	End if
End if
%>