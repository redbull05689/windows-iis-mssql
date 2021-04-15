<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
Function getlocalRegNumber(structure,addIfDoesntExist)
	regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
	regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
    Dim ret(1)
	Set searchParamJson = JSON.parse("{}")
	searchParamJson.Set "searchType", "DUPLICATE"
	'searchParamJson.Set "stereoSearchType", "EXACT"
	
	' list of fields we want back
	fields = "[""cd_id"",""just_reg""]"
	
	' additional conditions to impose on the query, beyond structure
	conditions = "{""just_batch"": {""$eq"":"& SQLClean(padWithZeros(0,regBatchNumberLength),"N","S") & "}}"

	inputMolDataJson = analyzeInputMol(structure)
	Set inputMolData = JSON.Parse(inputMolDataJson)
	If IsObject(inputMolData) Then
		structure = inputMolData.Get("structure")
		structureFormat = inputMolData.Get("molFormat")
	End If
		
	theMolV3 = CX_standardize(structure,structureFormat,defaultStandardizerConfig,"mol:V3")
	theMolFile = theMolV3

	'''''''''''''''''''' DO A DUPLICATE SEARCH TO SEE IF WE HAVE A DIRECT HIT '''''''''''''''''''''''''''''
	'TODO 2147483647 is just Java Max Int, need to do a better job of knowing what the number of results should be
	jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	searchHitJson = CX_structureSearch(jChemRegDB,regMoleculesTable,aspJsonStringify(theMolV3),conditions,JSON.stringify(searchParamJson),fields,2147483647,0)

	numResults = 0
	isMatch = False

	Set searchHits = JSON.parse(searchHitJson)
	If IsObject(searchHits) And searchHits.Exists("data") Then
		thisCdId = -1
		thisRegId = -1
		
		Set results = searchHits.Get("data")
		If IsObject(results) Then
			theActualResults = cleanRelativeStereoHits(theMolFile, "mol:V3", JSON.Stringify(results), jChemRegDB, regMoleculesTable)
			
			Set actualResults = JSON.parse(theActualResults)
			numResults = actualResults.Length
			
			If numResults = 1 Then
				Set thisResult = actualResults.Get(0)
				thisCdId = thisResult.Get("cd_id")
				thisRegId = thisResult.Get("just_reg")
				If useNotebookId Then
					Set ttRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT id FROM accMols WHERE cd_id="&thisCdId&" AND notebookId="&SQLClean(regNotebookId,"N","S")
					'response.write(strQuery)
					ttRec.open strQuery,jchemRegConn,0,-1
					If Not ttRec.eof Then
						isMatch = True
					End if
				else
					isMatch = True
				End if
			End If
		End If
	End If
	'''''''''''''''''''' END DO A DUPLICATE SEARCH TO SEE IF WE HAVE A DIRECT HIT '''''''''''''''''''''''''''''

	regNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regIdDelimiter", session("companyId"))
	regNumberPrefix = getCompanySpecificSingleAppConfigSetting("regNumberPrefix", session("companyId"))
	If isMatch Then
		regNumber = regNumberPrefix & regNumberDelimiter & thisRegId
		ret(0) = thisCdId
		ret(1) = regNumber
	Else
		If addIfDoesntExist Then
			regNumber = getNewRegNumber(0)
			batchNumber = padWithZeros(0,regBatchNumberLength)

			regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
			wholeRegNumber = regNumberPrefix & regNumberDelimiter & regNumber & regBatchNumberDelimiter & batchNumber
			newCdId = addToMolTable(0,"1","",session("userId"),session("userId"),"3",session("firstName")&" "&session("lastName"),"0","3",aspJsonStringify(theMolV3),"","","","","","",wholeRegNumber,regNumber,batchNumber,0)
			
			ret(0) = newCdId

			If newCdId = -1 Then
				ret(1) = "An error occurred locating the ELN number.<br>Please contact Arxspan support."
			Else
				ret(1) = regNumberPrefix & regNumberDelimiter & regNumber
			End If
		Else
			ret(0) = False
			ret(1) = false
		End if
	End If
	getLocalRegNumber = ret
End function
%>