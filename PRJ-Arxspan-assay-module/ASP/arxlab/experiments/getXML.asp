<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
Server.ScriptTimeout=10000
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/backup_and_pdf/functions/fnc_getCSXML.asp"-->
<%
'gets cambridge soft xml backup of experiment

experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")

'only the experiment owner can get the xml
if ownsExperiment(experimentType,experimentId,session("userId")) Then
	'get xml
	xmlStr = getCSXML(session("companyId"),experimentType,experimentId)

	'save xml to a file
	fileName = uploadRoot & "\" & getRandomString(16) & ".xml"
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	set tfile=fs.CreateTextFile(filename)
	tfile.WriteLine(xmlStr)
	tfile.close
	set tfile=nothing

	'stream file to user
	Set fs=Server.CreateObject("Scripting.FileSystemObject")
	Set f=fs.GetFile(filename)
	Set adoStream = CreateObject("ADODB.Stream")
	adoStream.Open()
	response.contenttype="text/xml"
	response.addheader "ContentType","text/xml"
	response.addheader "Content-Disposition", "attachment; " & "filename=experiment-"&request.querystring("experimentId")&".xml"
	adoStream.Type = 1
	adoStream.LoadFromFile(filename)
	dataSize = f.size

	dataPosition = 0
	chunkSize = 1024*1024
	do while dataPosition < dataSize
	Response.BinaryWrite adoStream.Read(chunkSize)
	Response.flush
	dataPosition = dataPosition + chunkSize
	loop

	'Response.BinaryWrite adoStream.Read()
	adoStream.Close
	Set adoStream = Nothing  

	'delete the file
	a = fs.DeleteFile(filename,true)
	Set fs = nothing

end if
%>