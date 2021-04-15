<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
server.scriptTimeout = 10000
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
'displays the PDF of the specified experiment/experiment type/revision number

'get querystring params
experimentId = request.querystring("id")
experimentType = request.querystring("experimentType")

'set safe version flag
safeVersion = LCase(request.querystring("safeVersion")) = "true"

'can only see PDF if user can view the experiment
If canViewExperiment(experimentType,experimentId,session("userId")) then
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	'get the PDF filepath for the experiment and revision
	prefix = GetPrefix(experimentType)
	exType = GetAbbreviation(experimentType)
	historyTableView = GetFullName(prefix, "experimentHistoryView", true)
	strQuery = "SELECT userId, experimentId, revisionNumber from " & historyTableView & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(request.querystring("revisionNumber"),"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof then
		pdfName = uploadRootRoot & "\" & getCompanyIdByUser(rec("userId")) & "\"&rec("userId")&"\"&rec("experimentId")&"\"&rec("revisionNumber")&"\" & exType & "\sign"
	End If
	
	'add the right filename based on provided flags to the PDF filepath
	If request.querystring("short") = "1" Then
		pdfName = pdfName & "-short"
	End if

	If safeVersion Then
		pdfName = pdfName & "-sign.pdf"
	Else
		pdfName = pdfName & ".pdf"
	End if

	'if the PDF file exists stream it
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	if fs.FileExists(pdfName) Then
		Set adoStream = CreateObject("ADODB.Stream")
		adoStream.Open()
		response.contenttype="application/pdf"
		response.addheader "ContentType","application/pdf"
		If session("noPdf") then
			response.addheader "Content-Disposition", "attachment; " & "filename=sign-"&exType&"-"&experimentId&"_"&getRandomString(4) &".pdf"
		else
			response.addheader "Content-Disposition", "inline; " & "filename=sign-"&exType&"-"&experimentId&"_"&getRandomString(4) &".pdf"
		End if
		adoStream.Type = 1 
		'open file with stream
		adoStream.LoadFromFile(pdfName)

		Set fs=Server.CreateObject("Scripting.FileSystemObject")
		Set f=fs.GetFile(pdfName)
		dataSize = f.size
		Set f = nothing
		Set fs = Nothing
		
		'chunked download
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
		'file does not exist error
		response.write("file does not exist")
		response.end
	End If
End if
%>