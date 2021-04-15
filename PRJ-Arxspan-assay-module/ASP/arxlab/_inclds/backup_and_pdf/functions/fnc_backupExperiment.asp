<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
function backupExperiment(experimentId,experimentType,pathName)
	rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
	on error resume Next
	xmlUrl = "https://"&rootAppServerHostName&"/arxlab/services/bu_xml.asp?experimentType="&experimentType&"&experimentId="&experimentId

	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "GET",xmlUrl,True
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	xmlStr = xmlhttp.responsetext

	If Err.number <> 0 Then
		xmlStr = "Error Occured"
	End If
	On Error goto 0

	Set eRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM notebookIndexView WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND typeId="&SQLClean(experimentType,"N","S")& " AND visible=1"
	eRec.open strQuery,conn,3,3
	If Not eRec.eof Then
		experimentName = eRec("name")
		expUserId = eRec("userId")
	End if

	set fs=Server.CreateObject("Scripting.FileSystemObject")
	a = recursiveDirectoryCreate(uploadRoot,trim(pathName))
	set tfile=fs.CreateTextFile(trim(pathName) & "\" & Trim(Left(cleanFilename(experimentName),50))&".xml")
	tfile.WriteLine(xmlUrl)
	tfile.WriteLine(xmlStr)
	tfile.close
	set tfile=nothing
	set fs=nothing	

	revisionNumber = getExperimentRevisionNumber(experimentType,experimentId) 

	Set xmlRec = server.CreateObject("ADODB.RecordSet")
	prefix = GetPrefix(experimentType)
	abbreviation = GetAbbreviation(experimentType)
	attachmentTable = GetFullName(prefix, "attachments", true)
	strQuery = "SELECT * FROM " & attachmentTable & " WHERE experimentId=" & SQLClean(experimentId,"N","S")
	xmlRec.open strQuery,conn,3,3

	Do While Not xmlRec.eof
		filepath = uploadRoot & "\"&xmlRec("userId")&"\"&xmlRec("experimentId")&"\"&xmlRec("revisionNumber")&"\" & abbreviation & "\"&xmlRec("actualFilename")
		userId = xmlRec("userId")
		'xmlData = xmlData & "<attach file="""&filepath&"""/>"		
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(filepath) Then
		'xmlData = xmlData & "<exists/>"				
			Set adoStream = CreateObject("ADODB.Stream")  
			adoStream.Open()  
			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)
			adoStream.SaveToFile trim(pathName) &  "\" & HTMLDecodeUnicodeRegex(cleanFilename(xmlRec("filename"))), 2
			adoStream.Close
			Set adoStream = Nothing  
		End If
		Set fs = Nothing
		xmlRec.moveNext
	Loop

	' get the sign/witness PDF
	signFilePath = uploadRoot & "\"&expUserId&"\"&trim(experimentId)&"\"&revisionNumber&"\" & abbreviation & "\sign.pdf"
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	if fs.FileExists(signFilePath) Then
		Set adoStream = CreateObject("ADODB.Stream")  
		adoStream.Open()  
		adoStream.Type = 1  
		adoStream.LoadFromFile(signFilePath)
		adoStream.SaveToFile trim(pathName) &  "\experimentPdfVersion.pdf", 2
		adoStream.Close
		Set adoStream = Nothing  
	End If
	Set fs = Nothing

	on error resume Next
	htmlUrl = "https://"&rootAppServerHostName&"/arxlab/services/bu_html.asp?experimentType="&experimentType&"&experimentId="&experimentId

	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "GET",htmlUrl,True
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	htmlStr = xmlhttp.responsetext

	If Err.number <> 0 Then
		htmlStr = "Error Occured"
	End If
	On Error goto 0

	set fs=Server.CreateObject("Scripting.FileSystemObject")
	set tfile=fs.CreateTextFile(trim(pathName) & "\" & Trim(Left(cleanFilename(experimentName),50))&".html")
	tfile.WriteLine(htmlStr)
	tfile.close
	set tfile=nothing
	set fs=nothing	
end function
%>