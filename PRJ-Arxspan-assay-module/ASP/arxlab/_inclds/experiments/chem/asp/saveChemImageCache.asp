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
		imageFilePath = uploadRootRoot&"\"&getCompanyIdByUser(session("userId"))&"\"&rec("userId")&"\"&experimentId&"\"&rec("revisionNumber")&"\chem\"
		If fs.FolderExists(imageFilePath)=false Then
			recursiveDirectoryCreate uploadRootRoot,getCompanyIdByUser(session("userId"))&"\"&rec("userId")&"\"&experimentId&"\"&rec("revisionNumber")&"\chem\"
		end if

		bytecount = Request.TotalBytes

		if bytecount > 0 then
			bytes = Request.BinaryRead(bytecount)

			Dim outStream
			Set outStream = CreateObject("ADODB.Stream")
			outStream.CharSet = "utf-8"
			outStream.Open

			Set inStream = Server.CreateObject("ADODB.Stream")
				inStream.Type = 1 'adTypeBinary              
				inStream.Open()                                   
					inStream.Write(bytes)
					inStream.Position = 0                             
					inStream.Type = 2 'adTypeText                
					inStream.Charset = "utf-8"                      
					outStream.WriteText inStream.ReadText() 'here is your image as a string
					outStream.SaveToFile imageFilePath&"\chemImage.svg", 2                
				inStream.Close()
			Set inStream = nothing
			Set outStream = nothing
		end if
	end if
	rec.close
	Set rec = nothing
end if
%>