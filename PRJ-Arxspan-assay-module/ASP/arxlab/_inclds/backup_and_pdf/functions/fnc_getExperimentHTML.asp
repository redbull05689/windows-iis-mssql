<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
function getExperimentHTML(experimentId,experimentType)
	Set eRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM notebookIndexView WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND typeId="&SQLClean(experimentType,"N","S")& " AND visible=1"
	eRec.open strQuery,conn,3,3
	If Not eRec.eof Then
		experimentName = eRec("name")
		expUserId = eRec("userId")
	End if


	revisionNumber = getExperimentRevisionNumber(experimentType,experimentId) 

	Call getconnectedadm

	If experimentType = "1" Then


		numSteps = 1

		myHTML = "<h1>"&experimentName&"</h1>"

		For x = 1 To numSteps
			myHTML = myHTML & "<table cellspacing='10'><tr><td>"
			If numSteps = 1 then
				myHTML = myHTML & "<h1>Reaction</h1></td></tr><tr><td>"
			Else
				myHTML = myHTML & "<h1>Reaction Step "&x&"</h1></td></tr><tr><td>"
			End if
			If numSteps = 1 then
				filepath =  uploadRootRoot & "\" & getCompanyIdByUser(expUserId) & "\"&expUserId&"\"&Trim(experimentId)&"\"&revisionNumber&"\chem\chemData\rxn.gif"
			Else
				filepath =  uploadRootRoot & "\" & getCompanyIdByUser(expUserId) & "\"&expUserId&"\"&Trim(experimentId)&"\"&revisionNumber&"\chem\chemData\rxn-"&x&".gif"
			End If
			
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			if fs.FileExists(filepath) Then
				Set adoStream = CreateObject("ADODB.Stream")  
				adoStream.Open()  
				adoStream.Type = 1  
				adoStream.LoadFromFile(filepath)
				Set objXML = CreateObject("MSXml2.DOMDocument")
				Set objDocElem = objXML.createElement("Base64Data")
				objDocElem.dataType = "bin.base64"
				objDocElem.nodeTypedValue = adoStream.Read()
				randomize
				string64 = objDocElem.text
				imageData = "data:image/gif;base64," & string64
				adoStream.Close
				Set adoStream = Nothing  
			End if			

			myHTML = myHTML & "<img width=800 src='"&imageData&"'>"

			myHTML = myHTML & "</td></tr><tr><td>"

			Set reactantRec = server.CreateObject("ADODB.RecordSet")
			If numSteps = 1 then
				strQuery = "SELECT * FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")
			Else
				strQuery = "SELECT * FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")& " AND stepNumber="&SQLClean(x,"N","S")
			End if

			'response.write(getExperimentRevisionNumber(experimentType,experimentId))
			'response.end
			reactantRec.open strQuery,connadm,3,3
			i = 0
			Do While Not reactantRec.eof
				i = i + 1
				myHTML = myHTML & getObjectForm(experimentId,getExperimentRevisionNumber(experimentType,experimentId),1,CStr(i),true,false,3,true)
				reactantRec.movenext
			Loop
			
			myHTML = myHTML & "</td></tr><tr><td>"

			Set reactantRec = server.CreateObject("ADODB.RecordSet")
			If numSteps = 1 then
				strQuery = "SELECT * FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
			Else
				strQuery = "SELECT * FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND stepNumber="&SQLClean(x,"N","S")
			End if
			reactantRec.open strQuery,connadm,3,3
			i = 0
			Do While Not reactantRec.eof
				i = i + 1

				myHTML = myHTML & getObjectForm(experimentId,getExperimentRevisionNumber(experimentType,experimentId),2,CStr(i),true,false,3,true)
				reactantRec.movenext
			Loop
			reactantRec.close
			Set reactantRec = nothing
			myHTML = myHTML & "</td></tr><tr><td>"

			Set productRec = server.CreateObject("ADODB.RecordSet")
			If numSteps = 1 then
				strQuery = "SELECT * FROM products WHERE experimentId="&SQLClean(experimentId,"N","S")
			Else
				strQuery = "SELECT * FROM products WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND stepNumber="&SQLClean(x,"N","S")
			End if
			productRec.open strQuery,connadm,3,3
			i = 0
			Do While Not productRec.eof
				i = i + 1

				myHTML = myHTML & getObjectForm(experimentId,getExperimentRevisionNumber(experimentType,experimentId),3,CStr(i),true,false,3,true)
				productRec.movenext
			Loop

			productRec.close
			Set productRec = nothing

			myHTML = myHTML & "</td></tr><tr><td>"

			Set solventRec = server.CreateObject("ADODB.RecordSet")
			If numSteps = 1 then
				strQuery = "SELECT * FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S")
			Else
				strQuery = "SELECT * FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND stepNumber="&SQLClean(x,"N","S")
			End if
			solventRec.open strQuery,connadm,3,3
			i = 0
			Do While Not solventRec.eof
				i = i + 1

				myHTML = myHTML & getObjectForm(experimentId,getExperimentRevisionNumber(experimentType,experimentId),4,CStr(i),true,false,1,true)
				solventRec.movenext
			Loop

			myHTML = myHTML & "</td></tr></table>"
		Next
		
		myHTML = Replace(myHTML,"display:none;","")

		myHTML = Replace(myHTML,"type=""checkbox""","type=""checkbox"" style='display:none;'")
		myHTML = Replace(myHTML,"type='checkbox'","type='checkbox' style='display:none;'")

		styleStr = "<style type='text/css'>"
		styleStr = styleStr & ".caseInnerTitle{"
		styleStr = styleStr & "	font-weight:bold;"
		styleStr = styleStr & "}"
		styleStr = styleStr & "table table{"
		styleStr = styleStr & "	padding:20px;"
		styleStr = styleStr & "}"
		styleStr = styleStr & "table table table{"
		styleStr = styleStr & "	padding:2px;"
		styleStr = styleStr & "}"
		styleStr = styleStr & "</style>"

		Set ttRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
		ttRec.open strQuery,conn,3,3
		If Not ttRec.eof then
			myHTML = myHTML & "<h1>Preparation</h1>"
			myHTML = myHTML & ttRec("preparation")
		End If
		ttRec.close
		Set ttRec = nothing

	End if




	If experimentType = "2" Then
		Set ttRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM bioExperiments WHERE id="&SQLClean(experimentId,"N","S")
		ttRec.open strQuery,conn,3,3
		If Not ttRec.eof then
			myHTML = "<h1>"&experimentName&"</h1>"
			myHTML = myHTML & "<h1>Protocol</h1>"
			myHTML = myHTML & ttRec("protocol")
			myHTML = myHTML & "<h1>Summary</h1>"
			myHTML = myHTML & ttRec("summary")
		End If
		ttRec.close
		Set ttRec = nothing
	End if

	If experimentType = "3" Then
		Set ttRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM freeExperiments WHERE id="&SQLClean(experimentId,"N","S")
		ttRec.open strQuery,conn,3,3
		If Not ttRec.eof then
			myHTML = "<h1>"&experimentName&"</h1>"
			myHTML = myHTML & "<h1>Description</h1>"
			myHTML = myHTML & ttRec("description")
		End If
		ttRec.close
		Set ttRec = nothing
	End if

	If experimentType = "4" Then
		Set ttRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM analExperiments WHERE id="&SQLClean(experimentId,"N","S")
		ttRec.open strQuery,conn,3,3
		If Not ttRec.eof then
			myHTML = "<h1>"&experimentName&"</h1>"
			myHTML = myHTML & "<h1>Protocol</h1>"
			myHTML = myHTML & ttRec("protocol")
			myHTML = myHTML & "<h1>Summary</h1>"
			myHTML = myHTML & ttRec("summary")
		End If
		ttRec.close
		Set ttRec = nothing
	End if

	prefix = GetPrefix(experimentType)
	attachmentsTable = GetFullName(prefix, "attachments", true)
	notesTable = GetFullName(prefix, "notes", true)

	Set tRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM "&attachmentsTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
	tRec.open strQuery,conn,0,-1
	If Not tRec.eof Then
		myHTML = myHTML & "<h1>Attachments</h1>"
	End If
	Do While Not tRec.eof
		myHTML = myHTML & "<table>"
		myHTML = myHTML & "<tr><td>Name</td><td>"&tRec("name")&"</td></tr>"
		myHTML = myHTML & "<tr><td>Filename</td><td>"&tRec("filename")&"</td></tr>"
		myHTML = myHTML & "<tr><td>Description</td><td>"&tRec("description")&"</td></tr>"
		myHTML = myHTML & "<tr><td>Date Created</td><td>"&tRec("dateUploadedServer")&" (EST)</td></tr>"
		myHTML = myHTML & "</table><br/><br/>"
		tRec.movenext
	Loop
	tRec.close
	Set tRec = nothing

	Set tRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM "&notesTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
	tRec.open strQuery,conn,0,-1
	If Not tRec.eof Then
		myHTML = myHTML & "<h1>Notes</h1>"
	End If
	Do While Not tRec.eof
		myHTML = myHTML & "<table>"
		myHTML = myHTML & "<tr><td>Name</td><td>"&tRec("name")&"</td></tr>"
		myHTML = myHTML & "<tr><td>Note</td><td>"&tRec("note")&"</td></tr>"
		myHTML = myHTML & "<tr><td>Date Created</td><td>"&tRec("dateAddedServer")&" (EST)</td></tr>"
		myHTML = myHTML & "<tr><td>Date Updated</td><td>"&tRec("dateUpdatedServer")&" (EST)</td></tr>"
		myHTML = myHTML & "</table><br/><br/>"
		tRec.movenext
	Loop
	tRec.close
	Set tRec = nothing

	response.write("<html><head>"&styleStr&"</head><body>"&myHTML&"</body></html>")

end function
%>