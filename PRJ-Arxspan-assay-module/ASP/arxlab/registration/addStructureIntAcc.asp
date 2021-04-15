<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="regInt"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include file="../accint/_inclds/fnc_getLocalRegNumber.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
accordServicePath = getCompanySpecificSingleAppConfigSetting("accordServiceEndpointUrl", session("companyId"))
useRegDataBaseOverWorkflowRequests = getCompanySpecificSingleAppConfigSetting("useSunovionWorkflow", session("companyId"))

Function isGridField(fieldName)
	If LCase(fieldName) <> "notebookname" And LCase(fieldName) <> "experimentname" And LCase(fieldName) <> "todaysdateoracle" Then
		isGridField = True
	Else
		isGridField = False
	End If
End function



Function arxReg_isInteger(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_IsInteger = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
For i = 1 to Len( string )
      spec = Mid(string, i, 1)
      Set regExp = New RegExp
      regExp.Global = True
      regExp.IgnoreCase = True
      regExp.Pattern = "[0-9]"
      set match = regExp.Execute(spec)
      If match.count = 0 Then
			'if the char is not [0-9] return false(not an integer)
            arxReg_IsInteger = False
            Exit Function
      End If
      Set regExp = Nothing
Next
arxReg_IsInteger = True
End Function

Function arxReg_isDate(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_isDate = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
Set regExp = New RegExp
regExp.Global = True
regExp.IgnoreCase = True
regExp.Pattern = "^([0-1][0-9]|[1-9])\/([0-2][0-9]|[3][0-1]|[1-9])\/(([0-9][0-9])|(20|19)[0-9][0-9])$"
set match = regExp.Execute(Trim(string))
If match.count = 0 Then
	'if the char is not [0-9] return false(not an integer)
	arxReg_isDate = False
	Exit Function
End If
Set regExp = Nothing
arxReg_isDate = True
End Function

Function arxReg_isPercent(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_isPercent = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
Set regExp = New RegExp
regExp.Global = True
regExp.IgnoreCase = True
regExp.Pattern = "^[0-9]+(\.){0,1}[0-9]*( )*[%]{0,1}$"
set match = regExp.Execute(Trim(string))
If match.count = 0 Then
	'if the char is not [0-9] return false(not an integer)
	arxReg_isPercent = False
	Exit Function
End If
Set regExp = Nothing
arxReg_isPercent = True
End Function

Function arxReg_isNumber(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_isNumber = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
Set regExp = New RegExp
regExp.Global = True
regExp.IgnoreCase = True
regExp.Pattern = "^[0-9]+(\.){0,1}[0-9]*$"
set match = regExp.Execute(Trim(string))
If match.count = 0 Then
	'if the char is not [0-9] return false(not an integer)
	arxReg_isNumber = False
	Exit Function
End If
Set regExp = Nothing
arxReg_isNumber = True
End Function

Function arxReg_isOracleDate(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_isOracleDate = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
Set regExp = New RegExp
regExp.Global = True
regExp.IgnoreCase = True
regExp.Pattern = "^([0-2][0-9]|[3][0-1]|[1-9])\-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\-(([0-9][0-9])|(20|19)[0-9][0-9])$"
set match = regExp.Execute(trim(string))
If match.count = 0 Then
	'if the char is not [0-9] return false(not an integer)
	arxReg_isOracleDate = False
	Exit Function
End If
Set regExp = Nothing
arxReg_isOracleDate = True
End Function


success = false

If experimentId = "" Then
	experimentId = request.Form("experimentId")
	experimentType = request.Form("experimentNumber")
	revisionNumber = request.form("revisionNumber")
	regFieldId = request.form("regFieldId")
	molData = request.form("regMolData")
	regName = request.Form("regName")
	regExperimentName = request.Form("regExperimentName")
	regNotebookId = request.Form("regNotebookId")
	molPrefix = request.Form("molPrefix")
	notebookName = request.Form("regNotebookName")
End if

Function getElnVar(elnVar)
	Select Case LCase(elnVar)
		Case "notebookname"
			getElnVar = notebookName
		Case "experimentname"
			getElnVar = regExperimentName
		Case "todaysdateoracle"
			getElnVar = Day(now)&"-"&MonthName(Month(Now()),true)&"-"&Right(Year(Now()),2)
	End select
End Function

molData = request.form("regMolData")
molDataLines = Split(molData,vbcrlf)
If UBound(molDataLines) = 0 Then
	molDataLines = Split(molData,vbcr)
End If
If UBound(molDataLines) = 0 Then
	molDataLines = Split(molData,vblf)
End If
If Not isInteger(Trim(Left(molDataLines(3),3))) Then
	molData = vbcrlf & molData
End if


Call getconnectedJchemReg
'response.write(molData)
'response.write(session("userId"))
useNotebookId = True
if useRegDataBaseOverWorkflowRequests = 1 then
	cd_id = getLocalRegNumber(molData,false)(0)
else 
	allMoleculesDB = getCompanySpecificSingleAppConfigSetting("allMoleculesDB", session("companyId"))
	allMoleculesTable = getCompanySpecificSingleAppConfigSetting("allMoleculesTable", session("companyId"))
	regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
	
	standardizedMol3000 = CX_standardize(aspJsonStringify(molData),"mol:V3","","mol:V3")
	searchHitJson = CX_structureSearch(allMoleculesDB, allMoleculesTable, standardizedMol3000, "", "", "[""cd_id""]", 2147483647, 0)
	Set searchHits = JSON.parse(searchHitJson)
	If IsObject(searchHits) And searchHits.Exists("data") Then
		Set results = searchHits.Get("data")
		If IsObject(results) Then
			cleanResultsJson = cleanRelativeStereoHits(standardizedMol3000, "mol:V3", JSON.Stringify(results), allMoleculesDB, allMoleculesTable)
			Set cleanResults = JSON.Parse(cleanResultsJson)
			numResults = cleanResults.Length
			'response.write(numResults)
			
			if numResults > 0 then
				Set thisResult = cleanResults.Get(0)
				cd_id = thisResult.Get("cd_id")
			else 
				cd_id = false
			end if 
			
		
		End If
	End If
end if 

If cd_id <> False Then
	Set rec = server.CreateObject("ADODB.RecordSet")
	if useRegDataBaseOverWorkflowRequests = 1 then
		strQuery = "SELECT id, newStructure, localRegNumber, foreignRegNumber, projectName, notebookId FROM accMols WHERE included=1 and cd_id="&SQLClean(cd_id,"N","S")&" AND notebookId="&SQLClean(regNotebookId,"N","S")&" AND (cancelled<>1 or cancelled is null)"
		rec.open strQuery,jchemRegConn,3,3
		If Not rec.eof Then
            Set nbRec = server.CreateObject("ADODB.RecordSet")
            nbQuery = "SELECT lastName, description, email FROM notebookView WHERE id="&rec("notebookId")
            nbRec.open nbQuery, conn, 3, 3
			molData = rec("newStructure")
			localRegNumber = rec("localRegNumber")
			foreignRegNumber = rec("foreignRegNumber")
			notebookOwner = nbRec("lastName")
			notebookDescription = nbRec("description")
			notebookOwnerEmail = nbRec("email")
			If IsNull(notebookDescription) Then
				notebookDescription = ""
			End If
			projectName = rec("projectName")
			If IsNull(projectName) Then
				projectName = ""
			End If
			projectName = Replace(projectName,chrw(8211),"-")
			accMolsId = rec("id")
            nbRec.close
            Set nbRec = Nothing
		Else
			getFieldTypesError = true
			errorText = "You are not authorized to register this compound because it was not found in this Notebook."	
		End if
        rec.close
        Set rec = Nothing
	else
		If request.form("checkComRequested") <> "False" then 
		
			url = "/requests/{requestId}/containsCdId/{cdId}/?appName=ELN"
			url = Replace(url, "{requestId}", request.form("requestId"))
			url = Replace(url, "{cdId}", cd_id)

			requestData = appServiceGet(url)

			set requestData = JSON.parse(requestData)
			passFail = requestData.get("result")

			if passFail <> "success" then
				getFieldTypesError = true
				errorText = "You are not authorized to register this compound because it was not found in this workflow Notebook."
			else
				if requestData.get("data") = false then					
					getFieldTypesError = true
					errorText = "You are not authorized to register this compound because it was not found in this workflow Notebook."
				end if
			end if 
			'response.write("WFdata: " & passFail)
		end if
				
	end if


Else
	if useRegDataBaseOverWorkflowRequests = 1 then
		getFieldTypesError = true
		errorText = "You are not authorized to register this compound from this Notebook. (cd_id: " & cd_id & ")"
	else 
		'response.write(request.form("checkComRequested"))
		'response.end
		If request.form("checkComRequested") <> "False" then 
			getFieldTypesError = true
			errorText = "You are not authorized to register this compound from this workflow Notebook. (cd_id: " & cd_id & ")"
		end if 
	end if 
End if
Call disconnectJchemReg

Set xmlhttp = CreateObject("MSXML2.ServerXMLHTTP")
xmlhttp.setOption 2, 13056

Dim aErr
bXML = ""

On Error Resume Next
xmlhttp.Open "GET",accordServicePath&"/getfieldtypes?email="&server.urlencode(session("email")),True
aErr = Array(Err.Number, Err.Description)

On Error GoTo 0
If 0 = aErr(0) Then
	xmlhttp.setRequestHeader "Content-Type", "text/xml"
	On Error Resume Next
	xmlhttp.send soapEnv
	xmlhttp.waitForResponse(60)
	bXML = xmlhttp.responsexml.xml
	On Error GoTo 0
	If 0 <> aErr(0) Then
		response.write("Error sending data to Accord: " & aErr(0) & " " & aErr(1))
		response.End()
	End If
Else
	response.write("Error contacting Accord: " & aErr(0) & " " & aErr(1))
	response.End()
End If

'If session("email") = "support@arxspan.com" Then
'	response.write("URL: " & accordServicePath&"/getfieldtypes?email="&server.urlencode(session("email")) & "<br>")
'	response.write("AA"&bxml&"AA")
'	response.End()
'End If

If bXml = "Invalid Email Address" Then
	getFieldTypesError = True
	errorText = "Invalid Email Address"
Else
	If instr(bXml,"<Errors>") > 0 Then
		getFieldTypesError = True
		errorText = getXMLTag("Message",bxml)
	else
		Set xml = server.CreateObject("Microsoft.XMLDOM")
		xml.loadXML(bXML)
		For Each oNode In xml.GetElementsByTagName("EntryList")
			numVisibleFields = 0
			For Each subNode In oNode.SelectNodes("*")
				hidden = false
				For Each entry In subNode.selectNodes("*")
					if entry.nodeName = "hidden" then
						If entry.text = "true" Then
							hidden = True
						End if
					End if
				Next
				If Not hidden Then
					numVisibleFields = numVisibleFields + 1
				End if
			Next
		Next
	End if
End if

sectionId = "regInt"
subSectionId = "add-structure"

If Not session("hasAccordInt") Then
	response.redirect("logout.asp")
End If

addBatch = false
moleculeAdded = false

inFrame = True

If experimentId = "" Then
	experimentId = request.Form("experimentId")
	experimentType = request.Form("experimentNumber")
	revisionNumber = request.form("revisionNumber")
	regFieldId = request.form("regFieldId")
	molData = request.form("regMolData")
	regName = request.Form("regName")
	regExperimentName = request.Form("regExperimentName")
End if


If request.Form("addStructureSubmitHidden") <> "" Then
	efields = ""
	Set xml = server.CreateObject("Microsoft.XMLDOM")
	xml.loadXML(bXML)
	For Each oNode In xml.getElementsByTagName("EntryList")
		counter = 0
		For Each subNode In oNode.SelectNodes("*")
			counter = counter + 1
			hidden = False
			isList = False
			theValue = ""
			For Each entry In subNode.selectNodes("*")
				if entry.nodeName = "Hidden" then
					If entry.text = "true" Then
						hidden = True
					End If
				End if
				Select Case LCase(entry.nodeName)
					Case "name"
						name = entry.text
					Case "description"
						description = entry.text
					Case "required"
						If entry.text = "true" Then
							required = True
						Else
							required = False
						End If
					Case "values"
						isList = true
						foundItem = false
						For Each value In entry.selectNodes("*")
							If value.text <> "" Then
								theValue = value.text
							Else
								theValue = value.getAttribute("ID")
							End If
							If theValue = request.Form("formItem_"&counter) Then
								foundItem = true
							End if
						Next
					Case "type"
						fieldType = LCase(entry.text)
					Case "validation"
						validationFunction = LCase(entry.text)
				End Select
			Next
			If hidden Then 
				isList = False
			End If
			If required And Not hidden And request.Form("formItem_"&counter) = "" Then
				efields = efields & "formItem_"&counter&","
			Else
				If validationFunction <> "" Then
					Select Case validationFunction
						Case "arxreg_isinteger"
							If Not arxReg_isInteger(request.Form("formItem_"&counter)) Then
								efields = efields & "formItem_"&counter&","
								errorStr = errorStr & description &": please enter only numbers<br/>"
							End if
						Case "arxreg_isdate"
							If Not arxReg_isDate(request.Form("formItem_"&counter)) Then
								efields = efields & "formItem_"&counter&","
								errorStr = errorStr & description &": please enter a valid date<br/>"
							End If
						Case "arxreg_ispercent"
							If Not arxReg_isPercent(request.Form("formItem_"&counter)) Then
								efields = efields & "formItem_"&counter&","
								errorStr = errorStr & description &": please enter a valid percentage<br/>"
							End If
						Case "arxreg_isnumber"
							If Not arxReg_isNumber(request.Form("formItem_"&counter)) Then
								efields = efields & "formItem_"&counter&","
								errorStr = errorStr & description &": please enter a number<br/>"
							End if
						Case "arxreg_isoracledate"
							If Not arxReg_isOracleDate(request.Form("formItem_"&counter)) Then
								efields = efields & "formItem_"&counter&","
								errorStr = errorStr & description &": please enter a valid date<br/>"
							End if
					End select
				End if
			End If
			If required And isList And Not foundItem Then
				efields = efields & "formItem_"&counter&","
			End If
		Next
	Next
	
	If efields = "" Then
		sdFile = ""
		sdFile = sdFile & request.Form("regMolData")
		If Left(sdFile,2) = vbcrlf Then
			sdFile = "Untitled" & sdFile
		End if
		If Right(sdFile,2) <> vbcrlf Then
			sdFile = sdFile & vbcrlf
		End if
		Call getconnected
		Set tRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM experiments WHERE id="&SQLClean(request.Form("experimentId"),"N","S")
		tRec.open strQuery,conn,3,3
		If Not tRec.eof Then
			notebookId = tRec("notebookId")
		End If
		tRec.close
		strQuery = "SELECT * FROM notebooks WHERE id="&SQLClean(notebookId,"N","S")
		tRec.open strQuery,conn,3,3
		If Not tRec.eof Then
			notebookName = tRec("name")
		End If
		tRec.close
		Set tRec = nothing
		Call disconnect

		experimentPage = ""
		rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
		experimentUrl = "https://" & rootAppServerHostName & "/arxlab/"
		Select Case experimentType
			 Case 1
				experimentPage = "experiment.asp"
			Case 2
				experimentPage = "bio-experiment.asp"
			Case 3
				experimentPage = "free-experiment.asp"
			Case 4
				experimentPage = "anal-experiment.asp"
		End Select
		
		If experimentPage = "" Then
			experimentPage = "experiment.asp"
		End If
		
		experimentUrl = experimentUrl & experimentPage & "?id=" & request.Form("experimentId")
		
		sdFile = sdFile & ">  <arxspan_experiment_name>"&vbcrlf&server.HTMLEncode(request.Form("regExperimentName"))&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_project_name>"&vbcrlf&server.HTMLEncode(projectName)&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_local_reg_number>"&vbcrlf&localRegNumber&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_foreign_reg_number>"&vbcrlf&foreignRegNumber&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_experiment_id>"&vbcrlf&request.Form("experimentId")&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_experiment_url>"&vbcrlf&experimentUrl&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_owner_name>"&vbcrlf&notebookOwner&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_owner_email>"&vbcrlf&notebookOwnerEmail&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_page_number>"&vbcrlf&Trim(Replace(Replace(regExperimentName,notebookName&" -",""),"-",""))&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_experiment_revision_number>"&vbcrlf&request.form("revisionNumber")&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_name>"&vbcrlf&server.HTMLEncode(notebookName)&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_description>"&vbcrlf&server.HTMLEncode(notebookDescription)&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_id>"&vbcrlf&notebookId&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_user_email>"&vbcrlf&session("email")&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_user_full_name>"&vbcrlf&session("firstName")&" "&session("lastName")&vbcrlf&vbcrlf
		Set xml = server.CreateObject("Microsoft.XMLDOM")
		xml.loadXML(bXML)
		For Each oNode In xml.getElementsByTagName("EntryList")
			counter = 0
			For Each subNode In oNode.SelectNodes("*")
				counter = counter + 1
				hidden = False
				theValue = ""
				For Each entry In subNode.selectNodes("*")
					isList = False
					if entry.nodeName = "Hidden" then
						If entry.text = "true" Then
							hidden = True
						End If
					End if
					Select Case LCase(entry.nodeName)
						Case "name"
							name = entry.text
						Case "description"
							description = entry.text
						Case "values"
							isList = true
							foundItem = false
							For Each value In entry.selectNodes("*")
								If value.text <> "" Then
									theValue = value.text
								Else
									theValue = value.getAttribute("ID")
								End If
								If theValue = request.Form("formItem_"&counter) Then
									foundItem = true
								End if
							Next
						Case "type"
							fieldType = LCase(entry.text)
					End Select
				Next
			If hidden And theValue <> "" Then
				theData = theValue
				If fieldType = "oracleDate" Then
					theData = UCase(theData)
				End if
			Else
				If request.Form("formItem_"&counter) = "-1" then
					theData = ""
				Else
					theData = request.Form("formItem_"&counter)
				End if
			End If
			If fieldType = "bool" Then
				If request.Form("formItem_"&counter) ="on" Then
					theData = "true"
				Else
					theData = "false"
				End if
			End if
			sdFile = sdFile & ">  <"&name&">"&vbcrlf&server.HTMLEncode(Trim(theData))&vbcrlf&vbcrlf
			Next
		Next
		sdFile = sdFile & "$$$$"
		'response.write("addStructureIntAcc: " & sdFile)

		soapEnv = "<?xml version=""1.0"" encoding=""utf-8""?>" &_
		"    <insertStructure>"&_
		"      <sdfile>"&server.HTMLEncode(sdFile)&"</sdfile>"&_
		"    </insertStructure>"

		'response.write(soapEnv)

        gwl_logpath = "C:/Temp/addStructureIntAcc-debug.txt"
        set gwl_logfs=Server.CreateObject("Scripting.FileSystemObject")
        set gwl_logfile = Nothing

        With (gwl_logfs)
          If .FileExists(gwl_logpath) Then
            Set gwl_logfile = gwl_logfs.OpenTextFile(gwl_logpath, 8)
          Else 
            Set gwl_logfile = gwl_logfs.CreateTextFile(gwl_logpath)
          End If 
        End With

        gwl_logfile.WriteLine(Now & ": enter addStructureIntAcc.asp")
        gwl_logfile.WriteLine("BEGIN SOAP ENV")
		gwl_logfile.Write(soapEnv)
        gwl_logfile.WriteLine("END SOAP ENV")

		Set xmlhttp = CreateObject("MSXML2.ServerXMLHTTP")
		xmlhttp.setOption 2, 13056
		xmlhttp.Open "POST",accordServicePath&"/insertstructure/",True
		xmlhttp.setRequestHeader "Content-Type", "text/xml"
		xmlhttp.send soapEnv
		xmlhttp.waitForResponse(60)
		retStr = HTMLDecode(xmlhttp.responsexml.xml)
		firstRetStr = retStr
		'retStr = "<result><regnumber>SEP-324232</regnumber></result>"
		'retStr = "<result><errors><message>hey</message></errors></result>"
		firstRetStr = retStr
        
        gwl_logfile.WriteLine("BEGIN XML RESPONSE")
        gwl_logfile.Write(retStr)
        gwl_logfile.WriteLine("END XML RESPONSE")
		gwl_logfile.WriteLine(Now & ": exit addStructureIntAcc.asp")
		gwl_logfile.close
		set gwl_logfile=nothing
		set gwl_logfs=nothing
        
		'response.write(retStr)
		If InStr(lcase(retStr),"<regnumber>") >0 Then
			success = True
			compoundNumber = getXMLTag("regnumber",retStr)
			compoundURL = getXMLTag("URL",retStr)
			compoundNumberNoBatch = getXMLTag("compoundnumber",retStr)
			Call getconnectedJchemReg

			regNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regIdDelimiter", session("companyId"))
			regNumberPrefix = getCompanySpecificSingleAppConfigSetting("regNumberPrefix", session("companyId"))
			regNumber = Replace(localRegNumber,regNumberPrefix&regNumberDelimiter,"")
			batchNumber = getNewBatchNumber(0,regNumber)
			wholeRegNumber = regNumberPrefix&regNumberDelimiter&regNumber&regBatchNumberDelimiter&batchNumber
			
			a = addToMolTable(cd_id,"1","",session("userId"),session("userId"),"2",session("firstName")&" "&session("lastName"),"1","3",molData,request.Form("experimentId"),request.Form("experimentType"),request.Form("revisionNumber"),request.Form("regExperimentName"),"","",wholeRegNumber,regNumber,batchNumber,0)
			
			strQuery = "INSERT INTO finalRegNumbers(accMolId,foreignRegNumberFinal,localRegNumberFinal,experimentId) values("&_
						SQLClean(accMolsId,"N","S") & "," &_
						SQLClean(compoundNumber,"T","S") & "," &_
						SQLClean(wholeRegNumber,"T","S") & "," &_
						SQLClean(request.Form("experimentId"),"N","S") & ")"
			jchemRegConn.execute(strQuery)
			strQuery = "UPDATE accMols set foreignRegNumber="&SQLClean(compoundNumberNoBatch,"T","S")&" WHERE id="&SQLClean(accMolsId,"N","S")
			jchemRegConn.execute(strQuery)
			Call disconnectJchemReg

		Else
			regError = True
			errorText = getXMLTag("Message",retStr)
			If errorText = "" Then
				errorText = "Unspecified Error"
			End if
		End if
		Set xmlhttp = Nothing

		Call getconnected
		a = logAction(2,experimentId,"",16)
		Call disconnect

	End if
End if
%>

<html>
<head>
<link href="<%=mainCSSPath%>/reg-styles.css?<%=jsRev%>" rel="stylesheet" type="text/css" media="screen">

<style type="text/css">@import url(<%=mainAppPath%>/js/jscalendar/calendar-win2k-1.css);</style>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/lang/calendar-en.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar-setup.js?<%=jsRev%>"></script>

<script type="text/javascript" src="<%=mainAppPath%>/js/getFile2.js?<%=jsRev%>"></script>

</head>
<body>
<%If Not success And efields = "" And not regError And not getFieldTypesError then%>
<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM finalRegNumbers WHERE accMolId="&SQLClean(accMolsId,"N","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
%>
<script type="text/javascript">
 if(!confirm("This compound has already been registered from this notebook.  Are you sure you want to re-register it?")){
	 window.parent.hidePopup('regDiv');
 }
</script>
<%
End If
rec.close
Set rec = nothing
Call disconnectJchemReg
%>
<%End if%>

<div class="registrationPage">

<div id="addStructureContainer" style="position:relative;z-index:0;">

<div class="objectBox" <%If 1=1 then%>style="visibility:hidden;height:0px;width:0px;"<%End if%> <%If moleculeAdded then%>style="display:none;"<%End if%>>
<div class="chemDrawWin" <%If 1=1 then%>style="height:0px;width:0px;"<%End if%>>

</div>


</div>
<br>
<%If moleculeAdded then%>
<div class="regSuccessDiv">
	Molecule Added: <%=wholeRegNumberLink%>
</div>
<%End if%>
<form action="addStructureIntAcc.asp?inFrame=<%=request.querystring("inFrame")%>&sourceId=<%=sourceId%>" method="post" onsubmit="document.getElementById('addStructureSubmit').disabled=true;document.getElementById('addStructureSubmit').value='WAIT';return true;">
<div style="z-index:100000;">
<H1 style="margin-left:10px;margin-top:0px;">Register Compound</H1>
<%If efields <> "" Or regError Or getFieldTypesError Then%>
<div style="margin-bottom:5px;"><p style="color:red;margin-left:10px;font-weight:bold;margin-bottom:10px;"><%If regError Or getFieldTypesError then%><%=errorText%><%else%>Please correct the errors highlighted in red<%End if%><%If errorStr <> "" then%><br/><%=errorStr%><%End if%></p></div>
<%End if%>
</div>
<div class="regInfoDiv regIntegrated">
<%
If Not getFieldTypesError then
	Dim values()
	Dim texts()
	Set xml = server.CreateObject("Microsoft.XMLDOM")
	xml.loadXML(bXML)
	response.write(xml.parseError.reason)
	jsGridStr = ""
	For Each oNode In xml.getElementsByTagName("EntryList")
		counter = 0
		visibleCounter = 0 
		For Each subNode In oNode.SelectNodes("*")
			counter = counter + 1
			hidden = False
			isList = False
			defaultValue = ""
			readOnly = False
			elnVar = ""
			For Each entry In subNode.selectNodes("*")
				if entry.nodeName = "hidden" then
					If entry.text = "true" Then
						hidden = True
						fieldType = "hidden"
					End if
				End if
				Select Case LCase(entry.nodeName)
					Case "name"
						name = entry.text
					Case "elnvar"
						elnVar = entry.text
					Case "readonly"
						If LCase(entry.text) = "true" Then
							readOnly = true
						End if
					Case "description"
						description = entry.text
					Case "required"
						If entry.text = "true" Then
							required = True
						Else
							required = False
						End If
					Case "defaultvalue"
						defaultValue = entry.text
					Case "values"
						isList = true
						valuesCounter = 0
						For Each value In entry.selectNodes("*")
							valuesCounter = valuesCounter + 1
						Next
						ReDim values(valuesCounter - 1)
						ReDim texts(valuesCounter - 1)
						valuesCounter = 0
						For Each value In entry.selectNodes("*")
							valuesCounter = valuesCounter + 1
							If value.text <> "" Then
								theValue = value.text
							Else
								theValue = value.getAttribute("ID")
							End If
							theText = value.text
							values(valuesCounter-1)=theValue
							If theText = "" Then
								theText = theValue
							End if
							texts(valuesCounter-1)=theText
						Next
					Case "type"
						fieldType = LCase(entry.text)
				End Select
			Next
			If elnVar <> "" Then
				If Not isGridField(elnVar) then
					defaultValue = getElnVar(elnVar)
				Else
					jsGridStr = jsGridStr & "document.getElementById('formItem_"&counter&"').value=window.parent.document.getElementById('"&molPrefix&"_"&elnVar&"').value;"&vbcrlf
				End if
			End if
			If visibleCounter = CInt(numVisibleFields/2) Then
			%></div><div class="regInfoDiv regIntegrated"><%
			End if
			If 1=1 Then
			%>
			<%If fieldType <> "hidden" then 
				visibleCounter = visibleCounter + 1
			%>
			<label for="formItem_<%=counter%>" <%If InStr(efields,"formItem_"&counter&",") Then%>style="color:red;width:260px;"<%End if%> style="width:260px;"><%=description%><%if required then%>*<%End if%></label>
			<%End if%>
			<%
			If isList Then
				%>
				<select name="formItem_<%=counter%>" id="formItem_<%=counter%>">
				<option value="-1">--SELECT--</option>
				<%
				For i = 0 To UBound(values)
					%>
					<option value="<%=values(i)%>" <%If request.Form("formItem_"&counter)=values(i) Then response.write("selected")End if%><%If Not IsNull(defaultValue) And Not IsNull(texts(i)) then%><%If request.Form("addStructureSubmitHidden") = "" And CStr(defaultValue) = CStr(texts(i)) then%> selected <%End if%><%End if%>><%=texts(i)%></option>
					<%
				Next
				%>
					</select><br/>
				<%
			Else
				If fieldType = "multilinestring" Then
					%>
					<textarea name="formItem_<%=counter%>" id="formItem_<%=counter%>"><%If request.Form("addStructureSubmitHidden") = "" And defaultValue <> "" then%><%=defaultValue%><%else%><%=request.Form("formItem_"&counter)%><%End if%></textarea><br/>			
					<%
				else
			%>
				<%If fieldType <> "bool" And fieldType <> "hidden" Then%>
					<input type="text" name="formItem_<%=counter%>" id="formItem_<%=counter%>" <%If request.Form("addStructureSubmitHidden") = "" And defaultValue <> "" then%>value="<%=defaultValue%>"<%else%>value="<%=request.Form("formItem_"&counter)%>"<%End if%> <%If readOnly then%>readonly<%End if%>><br/>
					<%If fieldType="date" then%>
					<script type="text/javascript">
					  Calendar.setup(
						{
						  inputField  : "formItem_<%=counter%>",         // ID of the input field
						  ifFormat    : "%m/%d/%Y",    // the date format
						  showsTime   : false,
						  timeFormat  : "12",
						  electric    : false
						}
					  );
					</script>
					<%End if%>
					<%If fieldType="oracledate" then%>
					<script type="text/javascript">
					  Calendar.setup(
						{
						  inputField  : "formItem_<%=counter%>",         // ID of the input field
						  ifFormat    : "%d-%b-%y",    // the date format
						  showsTime   : false,
						  timeFormat  : "12",
						  electric    : false
						}
					  );
					</script>
					<%End if%>
				<%else%>
					<%If fieldType <> "hidden" Then%>
						<input type="checkbox" name="formItem_<%=counter%>" id="formItem_<%=counter%>" <%If request.Form("formItem_"&counter) = "on" then%> checked<%else%><%If request.Form("addStructureSubmitHidden") = "" And LCase(defaultValue)="true" then%> checked<%End If End if%>>
					<%End if%>
				<%End if%>
				<%If fieldType = "hidden" Then%>
					<input type="hidden" name="formItem_<%=counter%>" id="formItem_<%=counter%>" <%If request.Form("addStructureSubmitHidden") = "" And defaultValue <> "" then%>value="<%=defaultValue%>"<%else%>value="<%=request.Form("formItem_"&counter)%>"<%End if%>><br/>
				<%End if%>
			<%
				End if
			End If
			End if
		Next
	next
End if

%>
</div>
<div style="height:0px;width:0px;clear:both;">

<input type="hidden" name="oldCDX" id="oldCDX" value="<%=replace(oldCdxml,"""","&quot;")%>">
<input type="hidden" name="experimentId" id="experimentId" value="<%=experimentId%>">
<input type="hidden" name="experimentType" id="experimentType" value="<%=experimentType%>">
<input type="hidden" name="revisionNumber" id="revisionNumber" value="<%=revisionNumber%>">
<input type="hidden" name="regMolData" id="regMolData" value="<%=molData%>">
<input type="hidden" name="regMolData2000" id="regMolData2000" value="<%=request.Form("regMolData2000")%>">
<input type="hidden" name="regName" id="regName" value="<%=regName%>">
<input type="hidden" name="regExperimentName" id="regExperimentName" value="<%=regExperimentName%>">
<input type="hidden" name="regFieldId" id="regFieldId" value="<%=regFieldId%>">
<input type="hidden" name="addStructureSubmitHidden" id="addStructureSubmitHidden" value="REGISTER">
<input type="hidden" name="regNotebookId" id="regNotebookId" value="<%=regNotebookId%>">
<input type="hidden" name="foreignRegNumber" name="foreignRegNumber" value="<%=foreignRegNumber%>">
<input type="hidden" name="localRegNumber" name="localRegNumber" value="<%=localRegNumber%>">
<input type="hidden" name="molPrefix" name="molPrefix" value="<%=molPrefix%>">
<input type="hidden" name="regNotebookName" name="regNotebookName" value="<%=notebookName%>">

<%If Not getFieldTypesError then%>
<input type="submit" name="addStructureSubmit" id="addStructureSubmit" value="REGISTER" style="margin-bottom:10px;">
<%End if%>
</form>




</div>

<%If jsGridStr <> "" then%>
	<script type="text/javascript">
		<%=jsGridStr%>
	</script>
<%End if%>

<%If success then%>
	<script type="text/javascript">
		<%if compoundURL <> "error" then%>
		window.parent.document.getElementById(document.getElementById("regFieldId").value).value = '<a href="<%=compoundURL%>"><%=compoundNumber%></a>';
		window.parent.experimentJSON[document.getElementById("regFieldId").value] = '<a href="<%=compoundURL%>"><%=compoundNumber%></a>';
		<%else%>
		window.parent.document.getElementById(document.getElementById("regFieldId").value).value = '<%=compoundNumber%><br/><%=wholeRegNumber%>';
		window.parent.experimentJSON[document.getElementById("regFieldId").value] = '<%=compoundNumber%><br/><%=wholeRegNumber%>';
		<%end if%>
		window.parent.hidePopup('regDiv');
		window.location='<%=mainAppPath%>/static/blank.html'
		window.parent.unsavedChanges=false;
		window.parent.experimentSubmit(false,false,false);
	</script>
<%End if%>
</body>
</html>