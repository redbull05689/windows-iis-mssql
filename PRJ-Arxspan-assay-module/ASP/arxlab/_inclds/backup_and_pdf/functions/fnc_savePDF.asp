<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
pdfFooterOptions = getCompanySpecificSingleAppConfigSetting("pdfFooterOptions", session("companyId"))
pdfHeaderOptions = getCompanySpecificSingleAppConfigSetting("pdfHeaderOptions", session("companyId"))
pdfFooterOptionsRight = getCompanySpecificSingleAppConfigSetting("pdfFooterOptionsRight", session("companyId"))
callExperimentNameExperimentNumber = checkBoolSettingForCompany("useExperimentNumberAsNameForPdf", session("companyId"))

uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
'  The main entry point for this script in creating PDF proc queue records is the savePDF function
'  whose goal is to create a JSON that gets inserted into the pdfProcQueue table, where it will
'  be processed by the PDFGeneration service

' We set these as global variables due to an issue in parsing function returned values
' that resulted in incorrectly formatted data being put into the PDF JSON values.  
Set pdfJsonObject = JSON.parse("{}")  ' the json of what should be put into the PDF we're creating
Set contentSequenceJsonArray = JSON.parse("[]")  '  the json array that gets built to store the contentSequence data

Function replaceAttachmentLinks(theText,experimentType,experimentId,revisionNumber)
	
	' since we want to replace any getImage.asp references, we check first to see if theText contains getImage.asp
	if InStr(theText, "/experiments/ajax/load/getImage.asp?id=") > 0 then

		prefix = GetPrefix(CStr(experimentType))
		attachmentsTable = GetFullName(prefix, "attachments", true)
		attachmentsHistoryTable = GetFullName(prefix, "attachments_history", true)

		'make the site URL, should look something like "https://eln.arxspan.com"
		siteURL = ""
		if Request.ServerVariables("HTTPS") = "on" then
			siteURL = siteURL & "https://"
		else
			siteURL = siteURL & "http://"
		end if
		siteURL = siteURL & Request.ServerVariables("server_name")

		if (revisionNumber = "") then
			Set aRec = server.CreateObject("ADODB.recordset")
			strQueryA = "SELECT id from "&attachmentsTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
			aRec.open strQueryA,connAdm,3,3
			Do While Not aRec.eof
				attachmentId = aRec("id")

				' don't do string replacements if we don't have to.
				if InStr(theText, "/experiments/ajax/load/getImage.asp?id="&attachmentId) > 0 then

					theText = Replace(theText,siteURL & mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&experimentType="&experimentType,getAttachmentFilePath(experimentType,attachmentId,"","",false))
					theText = Replace(theText,siteURL & mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&amp;experimentType="&experimentType,getAttachmentFilePath(experimentType,attachmentId,"","",false))
					theText = Replace(theText,siteURL & mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&amp;amp;experimentType="&experimentType,getAttachmentFilePath(experimentType,attachmentId,"","",false))

					theText = Replace(theText,mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&experimentType="&experimentType,getAttachmentFilePath(experimentType,attachmentId,"","",false))
					theText = Replace(theText,mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&amp;experimentType="&experimentType,getAttachmentFilePath(experimentType,attachmentId,"","",false))
					theText = Replace(theText,mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&amp;amp;experimentType="&experimentType,getAttachmentFilePath(experimentType,attachmentId,"","",false))
					
				end if

				aRec.movenext
			Loop
			aRec.close
			Set aRec = Nothing	
		else
			Set aRec = server.CreateObject("ADODB.recordset")
			strQueryA = "SELECT id FROM "&attachmentsHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
			aRec.open strQueryA,connAdm,3,3
			Do While Not aRec.eof
				attachmentId = aRec("id")

				' don't do string replacements if we don't have to.
				if InStr(theText, "/experiments/ajax/load/getImage.asp?id="&attachmentId) > 0 then

					theText = Replace(theText,siteURL & mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&experimentType="&experimentType&"&history=true",getAttachmentFilePath(experimentType,attachmentId,"","true",false))
					theText = Replace(theText,siteURL & mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&amp;experimentType="&experimentType&"&amp;history=true",getAttachmentFilePath(experimentType,attachmentId,"","true",false))
					theText = Replace(theText,siteURL & mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&amp;amp;experimentType="&experimentType&"&amp;amp;history=true",getAttachmentFilePath(experimentType,attachmentId,"","true",false))

					theText = Replace(theText,mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&experimentType="&experimentType&"&history=true",getAttachmentFilePath(experimentType,attachmentId,"","true",false))
					theText = Replace(theText,mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&amp;experimentType="&experimentType&"&amp;history=true",getAttachmentFilePath(experimentType,attachmentId,"","true",false))
					theText = Replace(theText,mainAppPath&"/experiments/ajax/load/getImage.asp?id="&attachmentId&"&amp;amp;experimentType="&experimentType&"&amp;amp;history=true",getAttachmentFilePath(experimentType,attachmentId,"","true",false))
					
				end if
				
				aRec.movenext
			Loop
			aRec.close
			Set aRec = Nothing
		end if
	end if

	replaceAttachmentLinks = theText
End function

Function processFileAttachments(attachmentsTable, attachmentsHistoryTable, experimentId, revisionNumber, attachmentId, uploadPathPath, folderPath)
	strAttachmentId = ""
	If attachmentId<>"" Then
		strAttachmentId = " AND attachmentId=" & SQLClean(attachmentId,"N","S")
	End If	
	
	Set attachmentRec = server.CreateObject("ADODB.RecordSet")
	If revisionNumber = "" Then		
		strQuery = "SELECT id, name, filename, actualFilename, description, userId, hideInPdf, revisionNumber, dateUploaded, dateUploadedServer FROM "&attachmentsTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & strAttachmentId & " ORDER by sortOrder,dateUploadedServer DESC"
	Else
		strQuery = "SELECT id, name, filename, actualFilename, description, userId, hideInPdf, revisionNumber, originalRevisionNumber, dateUploaded, dateUploadedServer FROM "&attachmentsHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")&strAttachmentId&" ORDER by sortOrder,dateUploadedServer DESC"
	End If 
	
	attachmentRec.open strQuery,connadm,3,3
	
	Set attachmentsJsonArray = JSON.parse("[]")	

	'loop through all the attachments for the specified revision	
	Do While Not attachmentRec.eof
		'get the data that is not attachment type specific
		filename = attachmentRec("filename")
		desc = attachmentRec("description")
		If session("useGMT") Then
			theDate = attachmentRec("dateUploaded")& " (GMT)"		
		Else
			theDate = attachmentRec("dateUploadedServer")& " (EST)"
		End if
		
		'if the attachment is an office doc or a pdf
		If isOfficeDoc(filename) And Not isPdf(filename) then
			'if the attachment is an office doc the file needs to be appended with .pdf because that is the preview file
			ext2 = ".pdf"
		Else
			ext2 = ""
		End If

		' attachments and attachments history differ in revisionNumber storage
		If revisionNumber = "" Then
			filepathRevisionNumber = attachmentRec("revisionNumber")
		Else
			filepathRevisionNumber = attachmentRec("originalRevisionNumber")
		End If

		'create the filepaths to the attachments
		filename = pEscape(uploadPathPath&"/"&getCompanyIdByUser(attachmentRec("userId"))&"/"&attachmentRec("userId")&"/"&experimentId&"/"&filepathRevisionNumber&"/"&folderPath&"/"&attachmentRec("filename")&ext2)
		actualFilename = pEscape(uploadPathPath&"/"&getCompanyIdByUser(attachmentRec("userId"))&"/"&attachmentRec("userId")&"/"&experimentId&"/"&filepathRevisionNumber&"/"&folderPath&"/"&attachmentRec("actualFilename")&ext2)
		'append this attachment to the office doc attachments dictionary string		
		
		' create the attachment json obj for the content sequence array
		Set attachmentObj = JSON.parse("{}")
		attachmentObj.Set "type","attachment"
		attachmentObj.Set "ID", pEscape(attachmentRec("id"))
		attachmentObj.Set "NAME", pEscape(attachmentRec("name"))
		attachmentObj.Set "DESCRIPTION", pEscape(desc)
		attachmentObj.Set "FILENAME", pEscape(filename)
		attachmentObj.Set "ACTUALFILENAME", pEscape(actualFileName)
		attachmentObj.Set "DISPFILENAME", pEscape(attachmentRec("filename"))
		attachmentObj.Set "DATEUPLOADED", pEscape(theDate)
		
		if attachmentRec("hideInPdf") = "1" then					
			attachmentObj.Set "SKIP","TRUE"
		end if		

		' add the attachment json obj to the content sequence array	

		contentSequenceJsonArray.push(attachmentObj)
		attachmentRec.movenext
	Loop
	attachmentRec.close()

	Set attachmentRec = nothing		
End Function

Function processExperimentNotes(notesTable, notesHistoryTable, experimentType, experimentId, revisionNumber)
	
	Set attachmentRec = server.CreateObject("ADODB.RecordSet")

	If revisionNumber = "" Then
		strQuery = "SELECT dateAdded, dateAddedServer, name, note FROM "&notesTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
	Else
		strQuery = "SELECT dateAdded, dateAddedServer, name, note FROM "&notesHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
	End If
	
	attachmentRec.open strQuery,connadm,3,3
	noteCounter = 0
	notesD = ""

	Set notesJson = JSON.parse("{}")
	Set notesJsonArray = JSON.parse("[]")	

	'loop through all the notes
	Do While Not attachmentRec.eof
		If session("useGMT") Then
			theDate = attachmentRec("dateAdded")& " (GMT)"		
		Else
			theDate = attachmentRec("dateAddedServer")& " (EST)"
		End if
		noteCounter = noteCounter + 1
		noteText = attachmentRec("note")
		note = replaceAttachmentLinks(noteText,experimentType,experimentId,revisionNumber)&"<p> </p>"
		
		'add this note dictionary into the array of notes
		Set noteJson = JSON.parse("{}")
		noteJson.Set "type","note"
		noteJson.Set "NAME", pEscape(attachmentRec("name"))
		noteJson.Set "NOTE", pEscape(note)
		noteJson.Set "DATEADDED", pEscape(theDate)				
		notesJsonArray.push noteJson		
		
		attachmentRec.movenext
	Loop
	attachmentRec.close()
	Set attachmentRec = nothing

	' add the notes array into the content sequence
	If JSON.stringify(notesJsonArray) <> "[]" Then
		notesJson.Set "type","notes"
		notesJson.Set "sectionTitle","Notes"
		notesJson.Set "notes", notesJsonArray
		contentSequenceJsonArray.push notesJson
	End If	

	processExperimentNotes = notesD
End Function

Function processExperimentLinks(experimentType, experimentId, revisionNumber)
	
	Set attachmentRec = server.CreateObject("ADODB.RecordSet")
	If revisionNumber = "" Then
		strQuery = "SELECT * from (SELECT * FROM experimentLinksView UNION ALL SELECT * FROM experimentLinks_preSaveView) as T WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S")
	Else
		strQuery = "SELECT linkExperimentType, linkExperimentId, name, details from experimentLinks_historyView WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
	End If
	attachmentRec.open strQuery,connadm,0,1
	noteCounter = 0
	'loop through all the notes

	Set linksJson = JSON.parse("{}")
	Set linksJsonArray = JSON.parse("[]")

	Do While Not attachmentRec.eof
		noteCounter = noteCounter + 1
		thisHTML = ""
		experimentPage = GetExperimentPage(attachmentRec("linkExperimentType"))
		thisHTML = thisHTML & ("<a href="""&experimentPage&"?id="&attachmentRec("linkExperimentId")&""">"&attachmentRec("name")&"</a>")
		thisHTML = thisHTML & ("<p style='margin-top:0;padding-top:0;' class=""linkDescription"">"&attachmentRec("details")&"</p>")
		
		' create a json object for the experiment link
		Set linkageJson = JSON.parse("{}")
		linkageJson.Set "HTML", pEscape(thisHTML)
		linksJsonArray.push linkageJson
		attachmentRec.movenext
	Loop
	attachmentRec.close()
	Set attachmentRec = nothing

	' add the json object link to the content sequence if necessary
	If JSON.stringify(linksJsonArray) <> "[]" Then
		linksJson.Set "type","experimentLinks"
		linksJson.Set "sectionTitle","Experiment Links"
		linksJson.Set "links", linksJsonArray		
		contentSequenceJsonArray.push linksJson
	End If	

End Function

Function processRegLinks(experimentType, experimentId, revisionNumber)
	
	Set attachmentRec = server.CreateObject("ADODB.RecordSet")
	If revisionNumber = "" Then
		strQuery = "SELECT * from (SELECT * FROM experimentRegLinks UNION ALL SELECT * FROM experimentRegLinks_preSave) as T WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S")
	Else
		strQuery = "SELECT displayRegNumber, regNumber, comments from experimentRegLinks_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
	End If
	attachmentRec.open strQuery,connadm,0,1
	noteCounter = 0

	Set linksJson = JSON.parse("{}")
	Set linksJsonArray = JSON.parse("[]")

	'loop through all the notes
	Do While Not attachmentRec.eof
		noteCounter = noteCounter + 1
		If attachmentRec("regNumber") <> attachmentRec("displayRegNumber")  Then
			thePage = regPath&"/showReg.asp"
		Else
			thePage = regPath&"/showBatch.asp"
		End if

		thisHTML = "<div><a href="""&thePage&"?regNumber="&attachmentRec("displayRegNumber")&""">"&attachmentRec("displayRegNumber")&"</a><span>&nbsp;"&pEscape(attachmentRec("comments"))&"</span></div>"

		' add the HTML reg link to the array of links
		Set linkJsonObj = JSON.parse("{}")
		linkJsonObj.Set "HTML", pEscape(thisHTML)
		linksJsonArray.push linkJsonObj
		attachmentRec.movenext
	Loop
	attachmentRec.close()
	Set attachmentRec = nothing

	' add the array of links to the content sequence if necessary
	If JSON.stringify(linksJsonArray) <> "[]" Then
		linksJson.Set "type","registrationLinks"
		linksJson.Set "sectionTitle","Registration Links"
		linksJson.Set "links", linksJsonArray		
		contentSequenceJsonArray.push linksJson
	End If	
		
End Function

Function processProjectLinks(experimentTable, experimentType, experimentId)
	
	Set linksJsonArray = JSON.parse("[]")	
	
	' this checks linksProjectExperimentsView for experiments then notebooks
	For i = 1 To 2
		Set attachmentRec = server.CreateObject("ADODB.RecordSet")
		If i = 1 then
			strQuery = "SELECT projectName, projectId, description, parentProjectId FROM linksProjectExperimentsView WHERE experimentId="&SQLClean(experimentId,"N","S")& " AND typeId="&SQLClean(experimentType,"N","S")
		End If
		If i = 2 Then
			Set nRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT notebookId FROM "&experimentTable&" WHERE id="&SQLClean(experimentId,"N","S")
			nRec.open strQuery,connadm,0,1
			If Not nRec.eof then
				notebookId = nRec("notebookId")
			Else
				notebookId=-1
			End If
			nRec.close
			Set nRec = nothing
			strQuery = "SELECT projectName, projectId, description, parentProjectId FROM linksProjectNotebooksView WHERE notebookId="&SQLClean(notebookId,"N","S")
		End if
		attachmentRec.open strQuery,connadm,0,1
		noteCounter = 0

		'loop through all the notes
		Do While Not attachmentRec.eof
			noteCounter = noteCounter + 1
			projectName = attachmentRec("projectName")
			projectId = attachmentRec("projectId")
			projectDescription = attachmentRec("description")
			If Not IsNull(attachmentRec("parentProjectId")) Then
				Set lRec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT name, description FROM projects WHERE id="&SQLClean(attachmentRec("parentProjectId"),"N","S")
				lRec2.open strQuery,conn
				If Not lRec2.eof Then
					parentProjectName = lRec2("name")
					projectName = parentProjectName & " => "&projectName
					projectDescription = lRec2("description")
				End If
				lRec2.close
				Set lRec2 = nothing
			End if
			thisHTML = ""
			thisHTML = thisHTML & ("<a href='show-project.asp?id="&projectId&"'>"&projectName)
			If i=2 Then
				thisHTML = thisHTML & "&nbsp;(via Notebook)"
			End if
			
			thisHTML = thisHTML & ("</a><p style='margin-top:0;padding-top:0;' class='"&linkDescription&"'>"&projectDescription&"</p>")
		
			' add the HTML link to the array of links
			Set linkJsonObj = JSON.parse("{}")
			linkJsonObj.Set "HTML", pEscape(thisHTML)
			linksJsonArray.push linkJsonObj
			
			attachmentRec.movenext
		Loop

		attachmentRec.close()
		Set attachmentRec = nothing
	Next

	' add the linksJson to the contentSequence if necessary	
	If JSON.stringify(linksJsonArray) <> "[]" Then
		Set linksJson = JSON.parse("{}")
		linksJson.Set "type","projectLinks"
		linksJson.Set "sectionTitle","Project Links"
		linksJson.Set "links", linksJsonArray
		contentSequenceJsonArray.push linksJson
	End If		
				
End Function

Function processRequestLinks(experimentType, experimentId)
	
	Set attachmentRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT experimentId, " &_
				"experimentType, " &_
				"requestId, " &_
				"comments " &_
				"FROM experimentRequests " &_
				"WHERE experimentId={experimentId} " &_
				"AND experimentType={experimentType}"
				
	strQuery = Replace(strQuery, "{experimentId}", SQLClean(experimentId,"N","S"))
	strQuery = Replace(strQuery, "{experimentType}", SQLClean(experimentType,"N","S"))
	attachmentRec.open strQuery,connadm,0,1
	'loop through all the notes
	Set linksJson = JSON.parse("{}")
	Set linksJsonArray = JSON.parse("[]")
	Do While Not attachmentRec.eof
	
		requestUrl = "/requests/{requestId}/requestName?appName=ELN"
		requestUrl = Replace(requestUrl, "{requestId}", CSTR(attachmentRec("requestId")))
		requestObj = appServiceGet(requestUrl)
		Set requestData = JSON.parse(requestObj)
		if requestData.get("result") = "success" then
			requestType = ""
			
			set requestData = JSON.parse(requestData.get("data"))
			thisHTML = ""
			thisHTML = thisHTML & ("<a href=""arxlab/Workflow/viewIndividualRequest.asp?id=" & attachmentRec("requestId") & """>" & requestData.get("requestName") & "</a>")
			thisHTML = thisHTML & ("<p style='margin-top:0;padding-top:0;' class=""linkDescription"">"&attachmentRec("comments")&"</p>")
		
			' create a json object for the experiment link
			Set linkageJson = JSON.parse("{}")
			linkageJson.Set "HTML", pEscape(thisHTML)
			linksJsonArray.push linkageJson
		end if
		attachmentRec.movenext
	Loop
	attachmentRec.close()
	Set attachmentRec = nothing
	' add the json object link to the content sequence if necessary
	If JSON.stringify(linksJsonArray) <> "[]" Then
		linksJson.Set "type","experimentLinks"
		linksJson.Set "sectionTitle","Request Links"
		linksJson.Set "links", linksJsonArray		
		contentSequenceJsonArray.push linksJson
	End If	
End Function

Function processChemistrySection(experimentId, revisionNumber, reactantsHistoryTable, reagentsHistoryTable, solventsHistoryTable, productsHistoryTable)	
	
	numSteps = 1			
	qvCounter = 0

	Dim currReactantSteps()
	ReDim currReactantSteps(numSteps+1)
	For i = 1 To numSteps
		currReactantSteps(i) = 0
	next
	Dim currReagentSteps()
	ReDim currReagentSteps(numSteps+1)
	For i = 1 To numSteps
		currReagentSteps(i) = 0
	next
	Dim currProductSteps()
	ReDim currProductSteps(numSteps+1)
	For i = 1 To numSteps
		currProductSteps(i) = 0
	next
	Dim currSolventSteps()
	ReDim currSolventSteps(numSteps+1)
	For i = 1 To numSteps
		currSolventSteps(i) = 0
	next

	'create the table header for the quick view table	
	qvHTML = "<style type='text/css'>.stochOdd td{background-color:#eaeaea;padding:3px;}.stochEven td{padding:3px;}.stochHeadRow td{	padding:3px;background-color:#eaeaea;	border-bottom:2px solid #dfdfdf;}.borderTable{border:1px solid #eaeaea;}</style><table class='caseTable borderTable' cellpadding='0' cellspacing='0' id='qv_body' style='margin-bottom:0;width:100%;'><tr class='stochHeadRow'><td colspan='6'><h1>Quick View</h1></td></tr><tr class='stochHeadRow'><td class='caseInnerData' valign='top'><b>Name</b></td><td class='caseInnerData' valign='top'><b>Molecular Weight</b></td><td class='caseInnerData' valign='top'><b>Molarity/Density</b></td><td class='caseInnerData' valign='top'><b>Moles</b></td><td class='caseInnerData' valign='top'><b>Mass/Volume</b></td><td class='caseInnerData' valign='top'><b>Equivalents</b></td></tr>"	

	'start the reactants dictionary		
	Set reactantsJsonArray = JSON.parse("[]")	
	Set reactantRec = server.CreateObject("ADODB.RecordSet")

	reactantRec.cursorLocation = adUseClient
	strQuery = "SELECT stepNumber, trivialName, molecularWeight, molarity, density, moles, volume, sampleMass, equivalents,sortOrder,userAdded,id FROM "&reactantsHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
	reactantRec.open strQuery,connadm,adOpenStatic,adLockReadOnly
	reactantRec.Sort = "sortOrder,userAdded,id asc"
	z = 0
	'loop through all the reactants for the specified experiment
	Do While Not reactantRec.eof				
		z = z + 1
		'get the reactant stochiometry table
		myHTML = getObjectForm(experimentId,revisionNumber,1,CStr(z),true,false,3,true)
		'add the reactant name if it exists otherwise auto number to the h1 before the stoch table 
		If IsNull(reactantRec("stepNumber")) Then
			stepNumber = "1"
		Else
			If Not IsNumeric(reactantRec("stepNumber")) Then
				stepNumber = "1"
			Else
				stepNumber = "1"
			End if
		End If
		currReactantSteps(CInt(stepNumber)) = currReactantSteps(CInt(stepNumber)) + 1
		If reactantRec("trivialName") <> "" then
			myHTML = "<table style='margin-top:20px;'><tr><td><h1>" & reactantRec("trivialName") & "</h1></td></tr><tr><td>" & myHTML& "</td></tr></table>"
		Else
			myHTML = "<table style='margin-top:20px;'><tr><td><h1>Reactant " & currReactantSteps(CInt(stepNumber)) & "</h1></td></tr><tr><td>" & myHTML & "</td></tr></table>"
		End If

		'add the reactant Table to the main dictionary		
		Set reactantJson = JSON.parse("{}")
		reactantJson.Set "HTML", myHTML
		reactantJson.Set "stepNumber", stepNumber
		reactantsJsonArray.push reactantJson

		'add a row to the quick view for this reactant
		If qvCounter Mod 2 = 0 Then
			theClass = "stochEven"
		Else
			theClass = "stochOdd"
		End If
		qvCounter = qvCounter + 1
		qvHTML = qvHTML & ("<tr class='"&theClass&"'>")
		'add reactant name if it exists otherwise autonumber
		If reactantRec("trivialName") <> "" then
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("trivialName")&"</td>")
		else
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>Reactant "&currReactantSteps(CInt(stepNumber))&"</td>")
		End If
		'add molecular weight column
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("molecularWeight")&"</td>")
		'add a molarity column if it exists otherwist add density
		if reactantRec("molarity") <> "" then
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("molarity")&"</td>")
		else
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("density")&"</td>")
		End If
		'add the moles column
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("moles")&"</td>")
		'add a volume column if it exists otherwise use sample mass
		if reactantRec("volume") <> "" then
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("volume")&"</td>")
		else
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("sampleMass")&"</td>")
		End If
		'add equivalents column
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("equivalents")&"</td></tr>")
		
		reactantRec.movenext
	Loop

	pdfJsonObject.Set "reactants", reactantsJsonArray

	'start reagents section	
	Set reactantRec = server.CreateObject("ADODB.RecordSet")
	Set reagentsJsonArray = JSON.parse("[]")

	reactantRec.cursorLocation = adUseClient
	strQuery = "SELECT stepNumber, trivialName, molecularWeight, molarity, density, moles, volume, sampleMass, equivalents, sortOrder,userAdded,id FROM "&reagentsHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
	reactantRec.open strQuery,connadm,adOpenStatic,adLockReadOnly
	reactantRec.Sort = "sortOrder,userAdded,id asc"
	z = 0
	'loop through all the reagents
	Do While Not reactantRec.eof				
		z = z + 1
		'get the reagent stochiometry table
		myHTML = getObjectForm(experimentId,revisionNumber,2,CStr(z),true,false,3,true)
		'add h1 to the stoch table name of reagent if it exists otherwise autonumber

		If IsNull(reactantRec("stepNumber")) Then
			stepNumber = "1"
		Else
			If Not IsNumeric(reactantRec("stepNumber")) Then
				stepNumber = "1"
			Else
				stepNumber = "1"
			End if
		End If
		currReagentSteps(CInt(stepNumber)) = currReagentSteps(CInt(stepNumber)) + 1

		If reactantRec("trivialName") <> "" then
			myHTML = "<table style='margin-top:20px;'><tr><td><h1>" & reactantRec("trivialName") & "</h1></td></tr><tr><td>" & myHTML & "</td></tr></table>"
		Else
			myHTML = "<table style='margin-top:20px;'><tr><td><h1>Reagent " & currReagentSteps(CInt(stepNumber)) & "</h1></td></tr><tr><td>" & myHTML & "</td></tr></table>"
		End If

		'add the reagent table to the reagents array	
		Set reagentJson = JSON.parse("{}")
		reagentJson.Set "HTML", myHTML
		reagentJson.Set "stepNumber", stepNumber
		reagentsJsonArray.push reagentJson
		
		'add a row for reagent into quick view table
		If qvCounter Mod 2 = 0 Then
			theClass = "stochEven"
		Else
			theClass = "stochOdd"
		End If
		qvCounter = qvCounter + 1
		qvHTML = qvHTML & ("<tr class='"&theClass&"'>")
		'add reactant name column name if it exists otherwise autonumber
		If reactantRec("trivialName") <> "" then
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("trivialName")&"</td>")
		else
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>Reagent "&currReagentSteps(CInt(stepNumber))&"</td>")
		End If
		'add molecular weight column
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("molecularWeight")&"</td>")
		'add molarity column if it exosts otherwise use density
		if reactantRec("molarity") <> "" then
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("molarity")&"</td>")
		else
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("density")&"</td>")
		End If
		'add moles column
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("moles")&"</td>")
		'add volume column if it exists otherwise use density
		if reactantRec("volume") <> "" then
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("volume")&"</td>")
		else
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("sampleMass")&"</td>")
		End If
		'add equivalents column
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&reactantRec("equivalents")&"</td></tr>")		
		
		reactantRec.movenext
	Loop

	' add the reagents array to the main pdfJsonObject
	pdfJsonObject.Set "reagents", reagentsJsonArray

	'start solvents section	
	Set solventRec = server.CreateObject("ADODB.RecordSet")
	Set solventsJsonArray = JSON.parse("[]")

	solventRec.cursorLocation = adUseClient
	strQuery = "SELECT stepNumber, trivialName, volume,sortOrder,userAdded,id FROM "&solventsHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
	solventRec.open strQuery,connadm,adOpenStatic,adLockReadOnly
	solventRec.Sort = "sortOrder,userAdded,id asc"
	z = 0
	'loop through all the solvents for the specified experiment
	Do While Not solventRec.eof				
		z = z + 1
		'get the stochiometry table for the solvent
		myHTML = getObjectForm(experimentId,revisionNumber,4,CStr(z),true,false,1,true)
		'add h1 header to the stoch table use name if it exists otherwise autonumber
		If IsNull(solventRec("stepNumber")) Then
			stepNumber = "1"
		Else
			If Not IsNumeric(solventRec("stepNumber")) Then
				stepNumber = "1"
			Else
				stepNumber = "1"
			End if
		End If
		currSolventSteps(CInt(stepNumber)) = currSolventSteps(CInt(stepNumber)) + 1
		If solventRec("trivialName") <> "" then
			myHTML = "<table style='margin-top:20px;'><tr><td><h1>" & solventRec("trivialName") & "</h1></td></tr><tr><td>" & myHTML & "</td></tr></table>"
		Else
			myHTML = "<table style='margin-top:20px;'><tr><td><h1>Solvent " & currSolventSteps(CInt(stepNumber)) & "</h1></td></tr><tr><td>" & myHTML & "</td></tr></table>"
		End If

		'add table to the main python dictionary string
		Set solventJson = JSON.parse("{}")
		solventJson.Set "HTML", myHTML
		solventJson.Set "stepNumber", stepNumber
		solventsJsonArray.push solventJson	

		'add quick view table row for this product
		If qvCounter Mod 2 = 0 Then
			theClass = "stochEven"
		Else
			theClass = "stochOdd"
		End If
		qvCounter = qvCounter + 1
		qvHTML = qvHTML & ("<tr class='"&theClass&"'>")
		'add name column if no name then autonumber
		if solventRec("trivialName") <> "" then
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&solventRec("trivialName")&"</td>")
		else
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>Solvent "&currSolventSteps(CInt(stepNumber))&"</td>")
		End If
		'add the rest of the columns for the product
		qvHTML = qvHTML & "<td class='caseInnerData' valign='top'></td><td class='caseInnerData' valign='top'></td><td class='caseInnerData' valign='top'></td>"		
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&solventRec("volume")&"</td><td class='caseInnerData' valign='top'></td></tr>")		
		
		solventRec.movenext
	Loop

	' add the solvents array to the main pdfJsonObject
	pdfJsonObject.Set "solvents", solventsJsonArray

	'start products section	
	Set productRec = server.CreateObject("ADODB.RecordSet")
	Set productsJsonArray = JSON.parse("[]")

	productRec.cursorLocation = adUseClient
	strQuery = "SELECT stepNumber, trivialName, molecularWeight, actualMoles, measuredMass, equivalents, sortOrder,userAdded,id FROM "&productsHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
	productRec.open strQuery,connadm,adOpenStatic,adLockReadOnly
	productRec.Sort = "sortOrder,userAdded,id asc"
	z = 0
	'loop through all the products for the specified experiment
	Do While Not productRec.eof				
		z = z + 1
		'get the product stochiometry table
		myHTML = getObjectForm(experimentId,revisionNumber,3,CStr(z),true,false,3,true)
		'add h1 header to stoch table use name if it exists otherwise autonumber
		If IsNull(productRec("stepNumber")) Then
			stepNumber = "1"
		Else
			If Not IsNumeric(productRec("stepNumber")) Then
				stepNumber = "1"
			Else
				stepNumber = "1"
			End if
		End If
		currProductSteps(CInt(stepNumber)) = currProductSteps(CInt(stepNumber)) + 1
		If productRec("trivialName") <> "" then
			myHTML = "<table style='margin-top:20px;'><tr><td><h1>" & productRec("trivialName") & "</h1></td></tr><tr><td>" & myHTML & "</td></tr></table>"
		Else
			myHTML = "<table style='margin-top:20px;'><tr><td><h1>Product " & currProductSteps(CInt(stepNumber)) & "</h1></td></tr><tr><td>" & myHTML & "</td></tr></table>"
		End If

		'add stoch table to main python dictionary string
		Set productJson = JSON.parse("{}")
		productJson.Set "HTML", myHTML
		productJson.Set "stepNumber", stepNumber
		productsJsonArray.push productJson

		'add quick view table row for this product
		If qvCounter Mod 2 = 0 Then
			theClass = "stochEven"
		Else
			theClass = "stochOdd"
		End If
		qvCounter = qvCounter + 1
		qvHTML = qvHTML & ("<tr class='"&theClass&"'>")
		'add name column if no name then autonumber
		if productRec("trivialName") <> "" then
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&productRec("trivialName")&"</td>")
		else
			qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>Product "&currProductSteps(CInt(stepNumber))&"</td>")
		End If
		'add the rest of the columns for the product
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&productRec("molecularWeight")&"</td><td class='caseInnerData' valign='top'></td>")
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&productRec("actualMoles")&"</td>")
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&productRec("measuredMass")&"</td>")
		qvHTML = qvHTML & ("<td class='caseInnerData' valign='top'>"&productRec("equivalents")&"</td></tr>")		
		
		productRec.movenext
	Loop

	'close quickview table
	qvHTML = qvHTML & "</table>"

	' add the products array to the main pdfJsonObject
	pdfJsonObject.Set "products", productsJsonArray	
	
	'open experiment history row for specified revision to add conditions and preparation
	Set expRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT preparation, reactionMolarity, pressure, temperature, cdx, userId FROM experimentHistoryView WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
	expRec.open strQuery,connadm,3,3
	
	'get preparation
	prepText = expRec("preparation")
	prepText = replaceAttachmentLinks(prepText,"1",experimentId,revisionNumber)

	'build conditions table
	conditionsTable = "<table width='150'>"
	conditionsTable = conditionsTable & ("<tr><td style='font-weight:bold;'>Molarity</td><td>"&expRec("reactionMolarity")&"</td></tr>")
	conditionsTable = conditionsTable & ("<tr><td style='font-weight:bold;'>Pressure</td><td>"&expRec("pressure")&"</td></tr>")
	conditionsTable = conditionsTable & ("<tr><td style='font-weight:bold;'>Temperature</td><td>"&expRec("temperature")&"</td></tr></table>")	

	'add the quickview table, preparation html. conditions table, and experiment name to the main pdfJsonObject
	Set quickViewSectionArray = JSON.parse("[]")
	quickViewSectionArray.push qvHTML				
	pdfJsonObject.Set "quickView", quickViewSectionArray
	pdfJsonObject.Set "conditionsTable", pEscape(conditionsTable)
	
	Set sectionCkTextObj = JSON.parse("{}")
	sectionCkTextObj.Set "sectionCkText", pEscape(prepText)
	pdfJsonObject.Set "preparation", sectionCkTextObj
	
	'get the cdx data so that a reaction file can be sent to inbox 'nxq not exactly sure why
	If expRec("cdx") = "" Then
		cdxData = "<?xml version=""1.0"" encoding=""UTF-8"" ?>"&vbcrlf&"<!DOCTYPE CDXML SYSTEM ""http://www.cambridgesoft.com/xml/cdxml.dtd"" ><CDXML"&vbcrlf&"CreationProgram=""ChemDraw 12.0.2.1076"""&vbcrlf&" Name=""Untitled Phytomedicine Document-1"""&vbcrlf&" BoundingBox=""0 0 0 0"""&vbcrlf&" WindowPosition=""0 0"""&vbcrlf&" WindowSize=""1073741824 0"""&vbcrlf&" FractionalWidths=""yes"""&vbcrlf&" InterpretChemically=""yes"""&vbcrlf&" ShowAtomQuery=""yes"""&vbcrlf&" ShowAtomStereo=""no"""&vbcrlf&" ShowAtomEnhancedStereo=""yes"""&vbcrlf&" ShowAtomNumber=""no"""&vbcrlf&" ShowBondQuery=""yes"""&vbcrlf&" ShowBondRxn=""yes"""&vbcrlf&" ShowBondStereo=""no"""&vbcrlf&" ShowTerminalCarbonLabels=""no"""&vbcrlf&" ShowNonTerminalCarbonLabels=""no"""&vbcrlf&" HideImplicitHydrogens=""no"""&vbcrlf&" LabelFont=""3"""&vbcrlf&" LabelSize=""12"""&vbcrlf&" LabelFace=""97"""&vbcrlf&" CaptionFont=""3"""&vbcrlf&" CaptionSize=""12"""&vbcrlf&" HashSpacing=""3"""&vbcrlf&" MarginWidth=""1.25"""&vbcrlf&" LineWidth=""1"""&vbcrlf&" BoldWidth=""1.33"""&vbcrlf&" BondLength=""20"""&vbcrlf&" BondSpacing=""8"""&vbcrlf&" ChainAngle=""120"""&vbcrlf&" LabelJustification=""Auto"""&vbcrlf&" CaptionJustification=""Left"""&vbcrlf&" AminoAcidTermini=""HOH"""&vbcrlf&" ShowSequenceTermini=""yes"""&vbcrlf&" ShowSequenceBonds=""yes"""&vbcrlf&" PrintMargins=""36 36 36 36"""&vbcrlf&" MacPrintInfo=""0003000002D002D0000000001E0016EDFF88FF881E7817700367052803FC0002000002D002D0000000001E0016ED000100640064000000010001010100000001270F000100010000000000000000000000000002001901900000000000600000000000000000000100000000000000000000000000000000"""&vbcrlf&" color=""0"""&vbcrlf&" bgcolor=""1"""&vbcrlf&"><colortable>"&vbcrlf&"<color r=""1"" g=""1"" b=""1""/>"&vbcrlf&"<color r=""0"" g=""0"" b=""0""/>"&vbcrlf&"<color r=""1"" g=""0"" b=""0""/>"&vbcrlf&"<color r=""1"" g=""1"" b=""0""/>"&vbcrlf&"<color r=""0"" g=""1"" b=""0""/>"&vbcrlf&"<color r=""0"" g=""1"" b=""1""/>"&vbcrlf&"<color r=""0"" g=""0"" b=""1""/>"&vbcrlf&"<color r=""1"" g=""0"" b=""1""/>"&vbcrlf&"</colortable><fonttable>"&vbcrlf&"<font id=""3"" charset=""iso-8859-1"" name=""Arial""/>"&vbcrlf&"</fonttable><page"&vbcrlf&" id=""5"""&vbcrlf&" BoundingBox=""0 0 540 720"""&vbcrlf&" HeaderPosition=""36"""&vbcrlf&" FooterPosition=""36"""&vbcrlf&" PrintTrimMarks=""yes"""&vbcrlf&" HeightPages=""1"""&vbcrlf&" WidthPages=""1""/></CDXML>"
	Else
		cdxData = expRec("cdx")
	End if

	'save the reaction file to the inbox
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	upp = Replace(uploadRootRoot,"\","/")
		
	CreateFolderRecursive(upp&"\"&getCompanyIdByUser(expRec("userId"))&"\"&expRec("userId")&"\"&experimentId&"\"&revisionNumber&"\chem\")

	set tfile=fs.CreateTextFile(upp&"\"&getCompanyIdByUser(expRec("userId"))&"\"&expRec("userId")&"\"&experimentId&"\"&revisionNumber&"\chem\chem.cdxml")
	tfile.Write(Replace(cdxData,"\""",""""))
	tfile.close
	set tfile=nothing
	set fs=nothing
	reactantRec.close
	Set reactantRec = nothing
	productRec.close
	Set productRec = Nothing
	solventRec.close
	Set solventRec = Nothing
	expRec.close
	Set expRec = nothing

End Function

Function CreateFolderRecursive(FullPath)  
  
  Dim arr, dir, path
  Dim oFs
  set fs=Server.CreateObject("Scripting.FileSystemObject")
  
  arr = split(FullPath, "\")
  path = ""
  For Each dir In arr
    If path <> "" Then path = path & "\"
    path = path & dir
    If fs.FolderExists(path) = False Then fs.CreateFolder(path)
  Next

End Function

Function processExperimentDetails(experimentTable, experimentHistoryTable, experimentId, revisionNumber)
	'get the history row for the specified revision of this experiment
	
	Set expRec = server.CreateObject("ADODB.RecordSet")
	If revisionNumber = "" Then
		strQuery = "SELECT details FROM " & experimentTable & " WHERE id="&SQLClean(experimentId,"N","S")
	Else
		strQuery = "SELECT details FROM " & experimentHistoryTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
	End If
	
	detailsD = ""
	expRec.open strQuery,connadm,3,3
	If Not expRec.eof Then
		If (Not IsNull(expRec("details"))) And (Not expRec("details")="") Then
			detailsD = Replace(expRec("details"),vbLf,"<br>")			
		End If	
	End If
	
	expRec.close()
	Set expRec = nothing	
	pdfJsonObject.Set "experimentDetails", detailsD

End Function

Function processExperimentCkSection(experimentTable, experimentHistoryTable, experimentType, experimentId, revisionNumber, sectionDbName, sectionDisplayName)
	'get the history row for the specified revision of this experiment

	Set expRec = server.CreateObject("ADODB.RecordSet")
	Set ckSectionJson = JSON.parse("{}")
	
	If revisionNumber = "" Then
		strQuery = "SELECT "&sectionDbName&" FROM " & experimentTable & " WHERE id="&SQLClean(experimentId,"N","S")
	Else
		strQuery = "SELECT "&sectionDbName&" FROM " & experimentHistoryTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
	End If

	sectionD = ""
	expRec.open strQuery,connadm,3,3

	If Not expRec.eof Then
		If IsNull(expRec(sectionDbName)) Then
			sectionText = ""
		Else
			sectionText = expRec(sectionDbName)
		End if

		sectionText = replaceAttachmentLinks(sectionText,experimentType,experimentId,revisionNumber)		

		'add the section to the content sequence
		Call AddCkSectionToContentSequence(sectionDisplayName,pEscape(handleCodeBlocks(sectionText)))

	End If
	
	expRec.close()
	Set expRec = nothing	
End Function

Function processWorkflowRequestSection(experimentId, revisionNumber, sign)	
	
	'get the correct row for the specified revision of this experiment
	Set expRec = server.CreateObject("ADODB.RecordSet")

	' 4516: get experiment created date in UTC format 
	if revisionNumber = "" Then
		strQuery = "SELECT requestId, requestRevisionNumber, dateSubmitted FROM custExperiments WHERE id=" & SQLClean(experimentId, "N", "S")
	Else
		strQuery = "SELECT requestId, requestRevisionNumber, (SELECT dateSubmitted FROM custExperiments WHERE id=" & SQLClean(experimentId, "N", "S") & ") AS dateSubmitted FROM custExperiments_history WHERE experimentId=" & SQLClean(experimentId, "N", "S") & " AND revisionNumber=" & SQLClean(revisionNumber, "N", "S")
	End If

	expRec.open strQuery, connadm, 3, 3

	If Not expRec.eof Then
		requestId = expRec("requestId")
		requestRevisionNumber = expRec("requestRevisionNumber")
		dateCreated = expRec("dateSubmitted")

		' Hack to just use the latest revision. For some reason, requestRevisionNumber is being set to 0 and
		' I'm not sure where.
		if requestRevisionNumber = 0 then
			revQuery = "select top 1 id FROM requestHistory where requestId = " & requestId & " ORDER BY revisionDate DESC"

			Set revRec = server.CreateObject("ADODB.RecordSet")
			revRec.open revQuery, connadm, 3, 3
			If not revRec.eof then
				requestRevisionNumber = revRec("id")
			end if
			revRec.close
		end if

		requestUrl = "/requests/{requestId}/revision/{revisionId}/PdfFormatted?appName=ELN"
		requestUrl = Replace(requestUrl, "{requestId}", CSTR(requestId))
		requestUrl = Replace(requestUrl, "{revisionId}", CSTR(requestRevisionNumber))
		requestObj = appServiceGet(requestUrl)

		Set requestData = JSON.parse(requestObj)

		if requestData.get("result") = "success" then
			requestType = ""
			
			set values = JSON.parse(requestData.get("data"))

			for each value in values
				if value.get("requestTypeName") <> "" then
					requestType = value.get("requestTypeName")
					Call AddCkSectionToContentSequence("Experiment Type", PEscape(CStr(requestType)))
					Call AddCkSectionToContentSequence("Date Experiment Created", PEscape(CStr(dateCreated) & " (UTC)"))
				else
					fieldName = value.get("name")
					fieldValue = value.get("value")
					Call AddCkSectionToContentSequence(PEscape(fieldName), PEscape(fieldValue))					
				end if
			next
		end if		
	End If

	expRec.close()
	Set expRec = nothing
	
End Function

Function AddCkSectionToContentSequence(sectionCkTitle, sectionCkText)	
	
	' create json object
	Set ckSectionJson = JSON.parse("{}")

	' set the object's items and values
	ckSectionJson.Set "type", "ckSection"
	ckSectionJson.Set "sectionCkTitle",sectionCkTitle

	' The PDF generator does not recognize double byte characters, so we have to Encode them here so that they'll render in the PDF correctly
	if not IsNull(sectionCkText) then
		sectionCkText = Server.HTMLEncode(sectionCkText)
	end if

	ckSectionJson.Set "sectionCkText",sectionCkText

	' push the json object into the content sequence array
	contentSequenceJsonArray.push ckSectionJson

End Function

function latestRevisionCust(experimentId, revisionNumber)
	latestRevisionCust = 0
	Set reqRec = server.CreateObject("ADODB.RecordSet")
	reqQuery = "SELECT revisionNumber FROM custExperiments WHERE id=" & experimentId
	reqRec.open reqQuery, connAdm, 3, 3
	if not reqRec.eof then
		if CSTR(reqRec("revisionNumber")) = revisionNumber then
			latestRevisionCust = 1
		end if
	end if
	reqRec.close
End function

function handleCodeBlocks(strTarget)
	'strPattern = "<code.*?>.*?<\/code>"
	strPattern = "<code.*?>[^<]*<\/code>"
	if(strTarget <> "") Then
		Set regEx = New RegExp
		regEx.Pattern = strPattern
		regEx.Global = True
		regEx.IgnoreCase = True
		regEx.Multiline = True
		Set matches = regEx.Execute(strTarget)
		
		Set regEx = Nothing

		If matches.Count > 0 Then
			For Each Match in Matches
				newString = Replace(htmlspecialchars(Match.Value), chr(10), "<br/>")
				strTarget = Replace(strTarget, Match.Value, newString)
			Next
		End If
	End If

handleCodeBlocks = strTarget

end Function

Function renderPdfWithoutContentSequence(experimentType,experimentId,revisionNumber,sign,makeSafeVersion,shortVersion,experimentTable,experimentHistoryTable,notesTable,notesHistoryTable,attachmentsTable,attachmentsHistoryTable,reactantsHistoryTable,reagentsHistoryTable,solventsHistoryTable,productsHistoryTable,uploadPathPath,folderPath)
	
	If experimentType <> "1" Then
		'biology experiment
		If experimentType = "2" Then
			Call processExperimentCkSection(experimentTable, experimentHistoryTable, experimentType, experimentId, revisionNumber, "protocol", "Protocol")
			Call processExperimentCkSection(experimentTable, experimentHistoryTable, experimentType, experimentId, revisionNumber, "summary", "Summary")
		End if

		'free/concept experiment
		If experimentType = "3" Then
			Call processExperimentCkSection(experimentTable, experimentHistoryTable, experimentType, experimentId, revisionNumber, "description", "Description")
		End if
		
		'analytical experiment
		If experimentType = "4" Then
			Call processExperimentCkSection(experimentTable, experimentHistoryTable, experimentType, experimentId, revisionNumber, "protocol", "Objective")
			Call processExperimentCkSection(experimentTable, experimentHistoryTable, experimentType, experimentId, revisionNumber, "summary", "Summary")
		End if
	End If
	
	'then experiment links section
	Call processExperimentLinks(experimentType, experimentId, revisionNumber)

	'start the reg links section
	Call processRegLinks(experimentType, experimentId, revisionNumber)

	'start the project links section
	Call processProjectLinks(experimentTable, experimentType, experimentId)

	'start the request links section
	Call processRequestLinks(experimentType, experimentId)

	'then notes section
	Call processExperimentNotes(notesTable, notesHistoryTable, experimentType, experimentId, revisionNumber)

	'attachments section processing
	Call processFileAttachments(attachmentsTable, attachmentsHistoryTable, experimentId, revisionNumber, "", uploadPathPath, folderPath)
	
	pdfJsonObject.Set "contentSequence", contentSequenceJsonArray	
End Function

Function renderPdfWithContentSequence(experimentType,experimentId,revisionNumber,sign,makeSafeVersion,shortVersion,experimentTable,experimentHistoryTable,notesTable,notesHistoryTable,attachmentsTable,attachmentsHistoryTable,reactantsHistoryTable,reagentsHistoryTable,solventsHistoryTable,productsHistoryTable,uploadPathPath,folderPath)	
	
	Set expRec = server.CreateObject("ADODB.RecordSet")
	If revisionNumber = "" Then
		strQuery = "SELECT attachmentId, experimentFieldName FROM experimentContentSequence WHERE experimentType="&SQLClean(experimentType,"N","S") & " and experimentId="&SQLClean(experimentId,"N","S") & " ORDER BY sortOrder ASC"
	Else
		strQuery = "SELECT attachmentId, experimentFieldName FROM experimentContentSequence_history WHERE experimentType="&SQLClean(experimentType,"N","S") & " and experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S") & " ORDER BY sortOrder ASC"
	End If				

	expRec.open strQuery,connadm,3,3
	Do While Not expRec.eof
		
		if expRec("attachmentId") <> "" And expRec("attachmentId") <> "0" And Not IsNull(expRec("attachmentId")) Then			
			' process file attachments
			Call processFileAttachments(attachmentsTable, attachmentsHistoryTable, experimentId, revisionNumber, expRec("attachmentId"), uploadPathPath, folderPath)			
		ElseIf expRec("experimentFieldName") <> "" And Not IsNull(expRec("experimentFieldName")) Then
			sectionTitle = expRec("experimentFieldName")
			If sectionTitle = "Experiment Links" Then
				' process experiment links
				Call processExperimentLinks(experimentType, experimentId, revisionNumber)
			ElseIf sectionTitle = "Registration Links" Then
				' process registration links
				Call processRegLinks(experimentType, experimentId, revisionNumber)
			ElseIf sectionTitle = "Request Links" Then
				'start the request links section
				Call processRequestLinks(experimentType, experimentId)
			ElseIf sectionTitle = "Projects" Then
				' process project links
				Call processProjectLinks(experimentTable, experimentType, experimentId)
			ElseIf sectionTitle = "Notes" Then
				' process any experiment notes
				Call processExperimentNotes(notesTable, notesHistoryTable, experimentType, experimentId, revisionNumber)
			ElseIf sectionTitle = "Request" Then
				' process any workflow links
				Call processWorkflowRequestSection(experimentId, revisionNumber, sign)
			Else
				sectionName = getSectionNameFromTitle(experimentType, sectionTitle)
				If sectionName <> "" Then					
					Call processExperimentCkSection(experimentTable, experimentHistoryTable, experimentType, experimentId, revisionNumber, sectionName, sectionTitle)					
				End If
			End If
		End If
		expRec.movenext
	Loop
	
	expRec.close()
	Set expRec = nothing

	' close out the contentSequence array and add it to the main pdfJsonObject	
	pdfJsonObject.Set "contentSequence", contentSequenceJsonArray		
	
End Function

Function getSectionNameFromTitle(experimentType, sectionTitle)
	sectionName = ""
	If sectionTitle = "Protocol" Or sectionTitle = "Objective" Then
		sectionName = "protocol"
	ElseIf sectionTitle = "Summary" Then
		sectionName = "summary"
	ElseIf sectionTitle = "Description" Then
		sectionName = "description"
	End If
	
	getSectionNameFromTitle = sectionName
End Function

Function savePDF(experimentType,experimentId,revisionNumber,sign,replaceExistingPDF,shortVersion)
	' 6336 - The content sequence is never re-instantiated whenever this gets run, so if savePDF is ever called
	' in a loop, then the resulting PDFs carry the remnants of the ones that preceded them.
	Set pdfJsonObject = JSON.parse("{}")  ' the json of what should be put into the PDF we're creating
	Set contentSequenceJsonArray = JSON.parse("[]")  '  the json array that gets built to store the contentSequence data

	'Check to make sure the sign.pdf doesn't already exist (or we have replace set to true)
	if pdfExists(experimentId, experimentType, revisionNumber, shortVersion) = false OR replaceExistingPDF then

		'get the right tables based on the specified experiment type
		prefix = GetPrefix(experimentType)
		folderPath = GetAbbreviation(experimentType)
		
		' Update any ERROR statuses for this revision.
		updatePDFRevisionErrors experimentId, revisionNumber, folderPath

		'get the python appropriate upload path nxq duplicated below
		uploadPath = Replace(uploadRoot,"\","/")

		attachmentsTable = GetFullName(prefix, "attachments", true)
		attachmentsHistoryTable = GetFullName(prefix, "attachments_history", true)
		notesTable = GetFullName(prefix, "notes", true)
		notesHistoryTable = GetFullName(prefix, "notes_history", true)
		experimentTable = GetFullName(prefix, "experiments", true)
		experimentHistoryTable = GetFullName(prefix, "experiments_history", true)

		if experimentType = "1" then
			reactantsHistoryTable = "reactants_history"
			reagentsHistoryTable = "reagents_history"
			productsHistoryTable = "products_history"
			solventsHistoryTable = "solvents_history"
		end if
		
		'get upload paths
		uploadPath = Replace(uploadRoot,"\","/")
		uploadPathPath = Replace(uploadRootRoot,"\","/")

		' figure if there is experimentContentSequence data for this experiment or not, and whether to use the history tables, or the current revision
		Set expRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT TOP 1 id FROM experimentContentSequence_history WHERE experimentType="&SQLClean(experimentType,"N","S") & " and experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S") & " ORDER BY sortOrder ASC"
		expRec.open strQuery,connadm,3,3
		hasContentSequence = true
		useHistoryTabales = true
		
		If expRec.eof Then
			strQuery = "SELECT TOP 1 id FROM experimentContentSequence WHERE experimentType="&SQLClean(experimentType,"N","S") & " and experimentId="&SQLClean(experimentId,"N","S") & " ORDER BY sortOrder ASC"
			expRec.close()
			expRec.open strQuery,connadm,3,3
			If expRec.eof Then
				hasContentSequence = false
			Else
				useHistoryTabales = false
				'until ELN-701 is fixed, set hasContentSequence to false
				hasContentSequence = false
			End If
			expRec.close()
		End If

		' if we are not using the experimentContentSequence, we still need to know whether or not to use the history tables
		If Not hasContentSequence Then
			useHistoryTables = true
			strQuery = "SELECT TOP 1 id FROM " & experimentHistoryTable & " WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S")
			expRec.open strQuery,connadm,3,3
			If expRec.eof Then
				useHistoryTables = false
			End If
			expRec.close()
		End If
		Set expRec = nothing
		
		fileRevisionNumber = revisionNumber
		
		If hasContentSequence Then
			' this block will be used for any experiment saved after 24 OCT 2016
			Call renderPdfWithContentSequence(experimentType,experimentId,revisionNumber,sign,makeSafeVersion,shortVersion,experimentTable,experimentHistoryTable,notesTable,notesHistoryTable,attachmentsTable,attachmentsHistoryTable,reactantsHistoryTable,reagentsHistoryTable,solventsHistoryTable,productsHistoryTable,uploadPathPath,folderPath)									
		Else
			' this block is for old experiments before we used the experimentContentSequence_history table for rendering
			Call renderPdfWithoutContentSequence(experimentType,experimentId,revisionNumber,sign,makeSafeVersion,shortVersion,experimentTable,experimentHistoryTable,notesTable,notesHistoryTable,attachmentsTable,attachmentsHistoryTable,reactantsHistoryTable,reagentsHistoryTable,solventsHistoryTable,productsHistoryTable,uploadPathPath,folderPath)						
		End If		

		'add details section this is separate because we always put it at the top of the PDF
		Call processExperimentDetails(experimentTable, experimentHistoryTable, experimentId, revisionNumber)		

		'chemistry data are rendered separately
		If experimentType = "1" Then						
			Call processChemistrySection(experimentId, revisionNumber, reactantsHistoryTable, reagentsHistoryTable, solventsHistoryTable, productsHistoryTable)
		End If
		
		Set expRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT name, userExperimentName, fullName, userId, statusId, action FROM " & experimentHistoryTable & " h inner join usersView u on u.id=h.userId WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
		expRec.open strQuery,connadm,3,3

		if not expRec.eof then

			'add the sign table if necessary
			If sign Then
				%><!-- #include file="../html/signTable.asp"--><%			
				pdfJsonObject.Set "signTable", pEscape(signTable)
			End If

			experimentName = expRec("name")

			If (Not IsNull(expRec("userExperimentName"))) And expRec("userExperimentName") <> "" Then
				experimentName = experimentName & " | " & expRec("userExperimentName")
			End If
						
			pdfJsonObject.Set "experimentName",experimentName
			
			If callExperimentNameExperimentNumber Then				
				pdfJsonObject.Set "callExperimentNameExperimentNumber","True"
			Else				
				pdfJsonObject.Set "callExperimentNameExperimentNumber","False"		
			End if
			If pdfHeaderOptions <> "" Then				
				pdfJsonObject.Set "headerOptions", pdfHeaderOptions
			Else				
				pdfJsonObject.Set "headerOptions", JSON.parse("[]")
			End if
			If pdfFooterOptions <> "" Then				
				pdfJsonObject.Set "footerOptions", pdfFooterOptions
			Else				
				pdfJsonObject.Set "footerOptions", JSON.parse("[]")
			End if
			If pdfFooterOptionsRight <> "" Then				
				pdfJsonObject.Set "footerOptionsRight", pdfFooterOptionsRight
			Else				
				pdfJsonObject.Set "footerOptionsRight", JSON.parse("[]")
			End if
			If expRec("statusId") = 5 Then
				If expRec("statusId") = 5 Then					
					pdfJsonObject.Set "signerName", pEscape(expRec("fullName"))
				End If
			Else				
				pdfJsonObject.Set "signerName", ""
			End If
			
			pdfJsonObject.Set "ownerName", pEscape(expRec("fullName"))			
			pdfJsonObject.Set "witnessName", ""			
			pdfJsonObject.Set "experimentStatus", pEscape(expRec("action"))

			If shortVersion Then
				pdfJsonObject.Set "shortVersion","1"
			End if

			expExtension = folderPath

			companyIden = getCompanyIdByUser(expRec("userId"))
			userIden = expRec("userId")
			
			If expRec("statusId") = 10 or expRec("statusId") = 11 Then
				fileType = "abandoned"
			Else
				fileType = ""
			End If
			'Save to DATABASE
			Call writePDFDataToDatabase(whichServer, companyIden, userIden, experimentId, fileRevisionNumber, expExtension, fileType, JSON.stringify(pdfJsonObject))
		end if

		expRec.close()
		Set expRec = nothing
		set tfile=nothing
		set fs=nothing
		
		'return the dictionary string
		savePDF = JSON.stringify(pdfJsonObject)
	end if
On Error Resume Next
On Error goto 0
end function

Function pdfExists(experimentId, experimentType, revisionNumber, shortVersion)
	pdfExists = false
	histTable = "experiments"
	fileRoot = "chem"
	Select Case experimentType
		Case "2"
			fileRoot = "bio"
			histTable = "bioExperiments"
		Case "3"
			fileRoot = "free"
			histTable = "freeExperiments"
		Case "4"
			fileRoot = "anal"
			histTable = "analExperiments"
		Case "5"
			fileRoot = "cust"
			histTable = "custExperiments"
	End select

	Call getconnected
	Set rRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT TOP 1 userId from " & histTable & "_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " ORDER BY revisionNumber DESC"

	rRec.open strQuery,conn,3,3
	If Not rRec.eof Then
		expUserId = CStr(rRec("userId"))
	End if

	if shortVersion then
		pdfName = "sign-short.pdf"	
	else
		pdfName = "sign.pdf"
	end if

	signFile = uploadRootRoot & "\" & getCompanyIdByUser(session("userId")) & "\" & expUserId & "\" & experimentId & "\" & revisionNumber & "\" & fileRoot & "\" & pdfName

	set fs=Server.CreateObject("Scripting.FileSystemObject")
	If fs.FileExists(signFile) Then
		pdfExists = true
	End if
	set fs = Nothing
End Function

Function writePDFDataToDatabase(serverName,companyId,userId,experimentId,revisionNumber,experimentType,fileType,pythonD)
	Call getconnectedadm
	strQuery = "INSERT INTO [pdfProcQueue] (serverName, companyId, userId, experimentId, revisionNumber, experimentType, fileType, jsonBODY, dateCreated, status) VALUES (" & SQLClean(serverName,"T","S") & ", " & SQLClean(companyId,"N","S") & ", " &SQLClean(userId,"N","S") & ", " & SQLClean(experimentId,"N","S") & ", " & SQLClean(revisionNumber,"N","S") & ", " & SQLClean(experimentType, "T", "S") & ", " & SQLClean(fileType, "T", "S") & ", " & SQLClean(pythonD,"T","S") & ", SYSDATETIME(), 'NEW')" 
	connAdm.execute(strQuery)
end function

Function updatePDFRevisionErrors(experimentId, revisionNumber, experimentType)
	' Update any failed attempts at generating this revision with the "ERROR-PASS" status so we know
	' there was an error and that we acknowledge it so that it doesn't error out when we try to make
	' a new PDF.
	Call getconnectedadm
	strQuery = "UPDATE pdfProcQueue " &_
		"SET status='ERROR-PASS' " &_
		"WHERE experimentId=" & SQLClean(experimentId,"N","S") & " " &_
		"AND revisionNumber=" & SQLClean(revisionNumber,"N","S") & " " &_
		"AND experimentType=" & SQLClean(experimentType, "T", "S") & " " &_
		"AND fileType is NULL;"
	connAdm.execute(strQuery)
End Function

%>