<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/escape_and_filter/functions/fnc_aspJsonStringify.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="../registration/_inclds/lib_reg.asp"-->
<!-- #include file="../_inclds/__whichServer.asp"-->
<!-- #include file="../_inclds/escape_and_filter/functions/fnc_HTMLDecode.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
molData = request.form("mol")

'response.write(molData)
'response.end

allMoleculesDB = getCompanySpecificSingleAppConfigSetting("allMoleculesDB", session("companyId"))
allMoleculesTable = getCompanySpecificSingleAppConfigSetting("allMoleculesTable", session("companyId"))
standardizedMol3000 = molData
	searchHitJson = CX_structureSearch(allMoleculesDB, allMoleculesTable, standardizedMol3000, "", "", "[""cd_id""]", 2147483647, 0)
	Set searchHits = JSON.parse(searchHitJson)
	If IsObject(searchHits) And searchHits.Exists("data") Then
		Set results = searchHits.Get("data")
		If IsObject(results) Then
			cleanResultsJson = cleanRelativeStereoHits(standardizedMol3000, "mol:V3", JSON.Stringify(results), allMoleculesDB, allMoleculesTable)
			Set cleanResults = JSON.Parse(cleanResultsJson)
			numResults = cleanResults.Length
			
			if numResults > 0 then
				Set thisResult = cleanResults.Get(0)
				cd_id = thisResult.Get("cd_id")
			else 
				cd_id = false
			end if 
		
		End If
	End If

response.write(cd_id)
response.end
%>