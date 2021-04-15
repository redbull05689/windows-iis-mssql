<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId="reg"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
fid = request.querystring("fid")
If request.querystring("rfid") <> "" Then
	useFilename = True
	rfid = request.querystring("rfid")
End if

set fs=Server.CreateObject("Scripting.FileSystemObject")

sdFile = regInboxPath&fid&".export"
doneFile = regInboxPath&fid&".done"
searchFile = regInboxPath&fid&".search"
if fs.FileExists(doneFile) Then
	Set Upload = Server.CreateObject("Persits.Upload")

	response.contenttype="application/octet-stream"
	response.addheader "contenttype","application/octet-stream"
	If useFilename Then
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT sdFilename FROM sdImports WHERE id="&SQLClean(rfid,"T","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			response.addheader "Content-Disposition", "attachment; " & "filename=""" & rec("sdFilename") &""""	
		Else
			response.addheader "Content-Disposition", "attachment; " & "filename=""" & "search-results.sdf" &""""		
		End If
		rec.close
		Set rec = nothing
	else
		response.addheader "Content-Disposition", "attachment; " & "filename=""" & "search-results.sdf" &""""
	End if

	'Set fs=Server.CreateObject("Scripting.FileSystemObject")
	'Set f=fs.GetFile(sdFile)
	'dataSize = f.size
	'Set f = nothing
	'Set fs = Nothing
	
	'Response.AddHeader "Content-Length",dataSize

	Upload.SendBinary sdFile, False, "", False

	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
	Set f = objFSO.CreateTextFile(regInboxPath&fid&".recd")
	f.write("rec")
	f.close
	Set f = Nothing
	Set objFSO = Nothing
	Response.End
Else
%>
	processing<img src="<%=mainAppPath%>/images/ajax-loader.gif">
	<script type="text/javascript">
		setTimeout('window.location.href = window.location.href',2000)
	</script>
<%
End If
%>