<!-- #include file="../../../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="../../../_inclds/__standardizerConfigs.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include virtual="/arxlab/_inclds/experiments/common/functions/fnc_getFileFormat.asp"-->
<%
chemAxonDatabaseName = getCompanySpecificSingleAppConfigSetting("chemAxonDatabaseName", session("companyId"))
chemAxonStructuresTableName = getCompanySpecificSingleAppConfigSetting("chemAxonMoleculesSearchTableName", session("companyId"))
Function getExperimentStructureSearch(molData, molType, molSearchType, includeHistory)
	
	molDataFormat = getFileFormat(molData)

	cdxmlPos = InStr(molData, "&lt;CDXML")
	If cdxmlPos = 0 Then
		cdxmlPos = InStr(molData, "<CDXML")
	End If

	If cdxmlPos > 0 Then
		molDataFormat = "cdxml"
		molData = Mid(molData, cdxmlPos)
		molData = JSON.stringify(molData)
		molData = mid(molData, 2, Len(molData)-2)
	End If
	
	molData = Replace(HTMLDecode(molData),"&","&amp;")
	molData = CX_standardize(molData,molDataFormat,searchStandardizerConfig,"mrv")
	
	molTypeFilter = "{""company_id"": {""$eq"":"& session("companyId") & "}}"
	If molType <> "" Then
		molTypeFilter = molTypeFilter & ",{""type_id"": {""$eq"":"& molType & "}}"
	End If
	if includeHistory = "false" then ' include history is actually a string
		currRevFilter = "{""is_current_revision"": {""$eq"":1}}"

		if molType = "" or molType = "10" then
			' If we're doing a search that should include attachment files, then we want to do an OR
			' so that jchem either returns current revision structures OR attachments. The is_current_revision
			' flag is only on experiment structures, not attachment structures. Trying to add it to the
			' attachment structures would mean we would have to figure out a mechanism to update the jchem data
			' and flag attachment structures as "not current".
			molTypeFilter = molTypeFilter + ",{""$or"": [" & currRevFilter & ", {""type_id"": {""$eq"": 10}}]}"
		else
			' Otherwise, only get current revisions.
			molTypeFilter = molTypeFilter + "," & currRevFilter
		end if
	end if

	Set searchParams = JSON.parse("{}")
	searchParams.Set "searchType", molSearchType
	'response.write queryOptions
	'TODO 2147483647 is just Java Max Int, need to do a better job of knowing what the number of results should be
	retval = CX_structureSearch(chemAxonDatabaseName,chemAxonStructuresTableName,molData,molTypeFilter,JSON.stringify(searchParams),"[""experiment_id"",""full_filename"",""experiment_type"",""revision_number""]",2147483647,0)
	getExperimentStructureSearch = retval
End Function
%>