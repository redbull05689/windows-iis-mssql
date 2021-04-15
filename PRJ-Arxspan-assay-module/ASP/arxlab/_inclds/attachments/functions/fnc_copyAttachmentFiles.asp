<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
function copyAttachmentFiles(experimentType,experimentId,newExperimentId,revisionNumber)
	'copy attachment files into a new experiments folder

	'get attachment table name and name for folder
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "attachments_history", true)
	folderName = GetAbbreviation(experimentType)
		
	Set caRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT userId, experimentId, originalrevisionNumber, actualFileName from "&tableName&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" and revisionNumber="&SQLClean(revisionNumber,"N","S")
	caRec.open strQuery,conn,3,3
	'loop through all attachments
	Do While Not caRec.eof
		'get path of original file and generate new experiment path for initial revision
		oldPath = uploadRootRoot & "\" & session("companyId") & "\" & caRec("userId") & "\" & caRec("experimentId") & "\" & caRec("originalrevisionNumber") & "\"&folderName&"\"
		newPath = uploadRootRoot & "\" & session("companyId") & "\" & session("userId") & "\" & newExperimentId & "\1\"&folderName&"\"
		'create the new path if it doesnt exist
		a = recursiveDirectoryCreate(uploadRootRoot,newPath)
		'copy the file
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		fs.CopyFile oldPath&caRec("actualFilename"),newPath&caRec("actualFilename")
		'if the attachment is an office doc(has a pdf preview) then copy that too
		If isOfficeDoc(caRec("actualFilename")) Then

			' Let's start by setting up some filenames we might need.
			officePdf = caRec("actualFilename")&".pdf"
			oldPdf = oldPath & officePdf

			' Split up the office file
			fileParts = split(oldPdf, ".")
			numParts = ubound(fileparts)

			' Figure out the file extension
			fileExt = fileParts(numParts)

			' Start building the file name up to the file extension.
			nameOfFile = ""
			for i=0 to numParts - 1
				nameOfFile = nameOfFile & fileParts(i) & "."
			next

			' If we have a file name, then we have a trailing . so remove it.
			if len(nameOfFile) > 0 then
				nameOfFile = Mid(nameOfFile, 1, len(nameOfFile) - 1)
			end if

			' If the PDF exists, then copy it.
			if fs.FileExists(oldPdf) then
				fs.CopyFile oldPdf, newPath & officePdf
			else
				' Otherwise, add this file into the pdfProcQueue for reprocessing.
				pdfQuery = "INSERT INTO pdfProcQueue (serverName, companyId, userId, experimentId, revisionNumber, fileName, fileType, experimentType, filePath, dateCreated, status) " &_
							"VALUES ('" & whichServer & "', " & session("companyId") & ", " & session("userId") & "," & newExperimentId & ", 1, '" & nameOfFile & "', '" & fileExt & "', '" & folderName & "', '" & newPath & "', GETDATE(), 'NEWPYTHON')"
				session("test") = pdfQuery
				Set pdfRec = server.CreateObject("ADODB.RecordSet")
				pdfRec.open pdfQuery, connAdm, 3, 3
				Set pdfRec = nothing
			end if
		End If
		If isChemicalFile(caRec("actualFilename")) Then
			oldFile = oldPath&Replace(caRec("actualFileName"),getFileExtension(caRec("actualFileName")),"_image.gif")

			if fs.FileExists(oldFile) then
				newFile = newPath&Replace(caRec("actualFileName"),getFileExtension(caRec("actualFileName")),"_image.gif")
				fs.CopyFile oldFile, newFile
			end if
		End If
		set fs=nothing				
		caRec.movenext
	loop	
end function
%>