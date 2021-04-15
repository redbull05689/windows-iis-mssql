<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
server.scriptTimeout = 10000
%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
imagefilename = request.querystring("imagefilename")
justfilename = request.querystring("justfilename")
If imageFilename = "" Then
	Call getconnected
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "attachments", true)
	attachmentsTable = "(SELECT * FROM " & tableName & " UNION ALL SELECT * FROM attachments_preSave) as T"
	experimentTypeName = GetAbbreviation("experimentType")
	Set attachmentRec = server.CreateObject("ADODB.recordset")
	strQuery = "SELECT userId, actualFilename, RevisionNumber FROM "&attachmentsTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND actualFilename like "&SQLClean(justfilename,"L","S")
	attachmentRec.open strQuery,conn,0,-1
	imageFileName = uploadRootRoot&"\"&getCompanyIdByUser(attachmentRec("userId"))&"\"&attachmentRec("userId")&"\"&experimentId&"\"&attachmentRec("RevisionNumber")&"\"&experimentTypeName&"\"&Replace(attachmentRec("actualFileName"),getFileExtension(attachmentRec("actualFileName")),"_image.gif")
End if
If canViewExperiment(experimentType,experimentId,session("userId")) then
	filepath = imagefilename
	'response.write(filepath)
	response.contenttype="image/gif"
	response.addheader "ContentType","image/gif"
	response.addheader "Content-Disposition", "inline; " & "filename=chem-"&experimentId&".gif"
	If filepath <> "" Then
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(filepath) Then
			Set adoStream = CreateObject("ADODB.Stream")  
			adoStream.Open()  
			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)
			Response.BinaryWrite adoStream.Read()
			adoStream.Close: Set adoStream = Nothing  
			Response.End  
		Else
			filepath = server.mappath(mainAppPath&"/images/white-pixel.gif")
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