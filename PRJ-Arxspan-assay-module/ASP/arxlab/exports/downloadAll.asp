<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/attachments/functions/fnc_getAttachmentFilePath.asp"-->
<%
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
If canViewExperiment(experimentType,experimentId,session("userId")) then
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "attachments", true)
	experimentTableName = GetFullName(prefix, "experiments", true)
	exportPath = uploadRoot&"\exports\"&session("userId")&"\experimentFiles"
	endPath = uploadRoot&"\exports\"&session("userId")
	'response.write(exportPath)

	SET fso = Server.CreateObject("Scripting.FileSystemObject")
	If fso.FolderExists(exportPath) Then
		fso.DeleteFolder(exportPath)
	End if
	Set fso = Nothing

	a = recursiveDirectoryCreate(uploadRoot,exportPath)
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id from "&tableName&" WHERE experimentId="&SQLClean(experimentId,"N","S")
	rec.open strQuery,conn,0,-1
	Do While Not rec.eof
		filepath = getAttachmentFilePath(experimentType,rec("id"),"","",false)
		displayFileName = getAttachmentDisplayFileName(experimentType,rec("id"),"","",false)
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(filepath) Then
			If fs.fileExists(exportPath &  "\" &cleanFilename(displayFilename)) Then
				counter = 0
				didIt = false
				Do While Not didIt
					counter = counter + 1
					Set RegEx = New regexp
					RegEx.Pattern = "(\.[^\.]+)$"
					RegEx.Global = True
					RegEx.IgnoreCase = True
					numberedFile = RegEx.Replace(cleanFilename(displayFilename),"("&counter&")$1")
					Set RegEx = nothing
					thisFilePath = exportPath &  "\" & numberedFile
					If Not fs.fileExists(thisFilePath) then
						Set adoStream = CreateObject("ADODB.Stream")  
						adoStream.Open()  
						adoStream.Type = 1  
						adoStream.LoadFromFile(filepath)
						adoStream.SaveToFile thisFilePath, 2
						adoStream.Close
						Set adoStream = Nothing  

						didIt = True
					End if
				Loop
				
			else
				Set adoStream = CreateObject("ADODB.Stream")  
				adoStream.Open()  
				adoStream.Type = 1  
				adoStream.LoadFromFile(filepath)
				adoStream.SaveToFile exportPath &  "\" &cleanFilename(displayFilename), 2
				adoStream.Close
				Set adoStream = Nothing  
			End if
		End If
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT name FROM "&experimentTableName&" WHERE id="&SQLClean(experimentId,"N","S")
	rec.open strQuery,conn,0,-1
	If Not rec.eof then
		experimentName = rec("name")
	End If
	rec.close
	Set rec = nothing
	Call getconnectedadm

	endFile = endPath &"\"&Replace(cleanFilename(experimentName)," ","")&".zip"
	strQuery = "INSERT into exports(userId,exportPath,endFile,status) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(exportPath,"T","S")&","&SQLClean(endFile,"T","S")&",0)"
	connAdm.execute(strQuery)
	Call disconnectAdm
	Call disconnect
	response.redirect(mainAppPath&"/exports/exportWait.asp")

End if
%>