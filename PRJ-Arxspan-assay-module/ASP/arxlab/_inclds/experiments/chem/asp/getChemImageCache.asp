<%@Language="VBScript" CodePage = 65001 %>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
	Response.CharSet = "UTF-8"
	Response.CodePage = 65001

	server.scriptTimeout = 10000
%>
<!-- #include file="../../../../_inclds/globals.asp"-->
<%
experimentId = request.querystring("expId")
experimentType = 1
If canViewExperiment(1,experimentId,session("userId")) then

	' use the database to find some metadata about this experiment
	strQuery = "SELECT userId, revisionNumber FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		imageFilePath = uploadRootRoot&"\"&getCompanyIdByUser(session("userId"))&"\"&rec("userId")&"\"&experimentId&"\"&rec("revisionNumber")&"\chem\chemImage.svg"
		If fs.FileExists(imageFilePath)=true Then
			'if file exists open it in a stream and write it back as the response
			Set adoStream = CreateObject("ADODB.Stream")  
			adoStream.Open()  
			adoStream.Type = 1  
			adoStream.LoadFromFile(imageFilePath)
			Set objXML = CreateObject("MSXml2.DOMDocument")
			Set objDocElem = objXML.createElement("Base64Data")
			
			Response.BinaryWrite adoStream.Read
			
			adoStream.Close
			Set adoStream = Nothing  
		End if
	end if
	rec.close
	Set rec = nothing
end if
%>