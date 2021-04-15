<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include file="../functions/fnc_logSearch.asp"-->

<script language="JScript" src="elasticUtilities.asp" runat="server"></script>
<%
elasticURL = getCompanySpecificSingleAppConfigSetting("elasticSearchEndpointUrl", session("companyId"))

Server.scripttimeout=360000
response.buffer = false
Response.CodePage = 65001
Response.CharSet = "UTF-8"

searchJSON = request.form("searchJSON")
If searchJSON <> "" Then
	Set searchObj = JSON.parse(searchJSON)
End If

If IsObject(searchObj) Then
    pageNum = CLng(request.form("pageNum"))
    pageSize = CLng(request.form("pageSize"))
    sortCol = request.form("sortCol")
    sortOrder = request.form("sortOrder")
    loadAttachments = request.form("attachments")
	includeHistory = request.form("includeHistory")
	structuresJSON = request.form("structureJSON")
	searchCode = request.form("searchCode")

	If structuresJSON = "" Then
		structuresJSON = "[]"
	End If
	Set structuresArr = JSON.parse(structuresJSON)
	
	logSearch searchCode, searchJSON, structuresJSON
	
	hasStructureSearch = False
	If structuresArr.length > 0 Then
		hasStructureSearch = True
	End If


	'order of operations with structures 
	'1. Ask jchem for all of the experiments related to the structures passed in.
	'2. Rebuild the search query with the new experiments that are passed in.
	'3. Submit the search.
	'NOTE: the reason we do it this way is because elastic search can be more in depth with searching with diffrent logic sets.
	'This allows us to let elastic search put things together instead of forceing jchem to do it and having to interlace all of that into the response from elastic search.


	Set experimentJson = JSON.parse("{}")
	Set experimentData = JSON.parse("[]")

	If IsObject(structuresArr) Then
		For i=0 To structuresArr.length - 1
			Set thisStructureSearch = structuresArr.Get(i)
			structureHits = getExperimentStructureSearch(thisStructureSearch.Get("molData"), thisStructureSearch.Get("molType"), thisStructureSearch.Get("searchType"), includeHistory)
			Set structuresObj = JSON.parse(structureHits)
			Set experimentIds = JSON.parse("[]")
			If IsObject(structuresObj) Then
				If structuresObj.Exists("data") Then
					Set structuresObjData = structuresObj.Get("data")
					For j=0 to structuresObjData.length - 1
						Set thisStructure = structuresObjData.Get(j)
						If thisStructure.Exists("experiment_id") Then
							
							thisExperimentId = CStr(thisStructure.Get("experiment_id"))
							If Not experimentIds.Get(thisExperimentId) Then
								experimentIds.Set experimentIds.length, thisExperimentId
							End If
							
							Set eData = JSON.parse("{}")
							eData.Set "experiment_id", thisExperimentId
							
							jsonExperimentType = ""
							If thisStructure.Exists("experiment_type") Then
								jsonExperimentType = CStr(thisStructure.Get("experiment_type"))
							End If
							eData.Set "experiment_type", jsonExperimentType
							
							jsonRevisionNumber = ""
							If thisStructure.Exists("revision_number") Then
								jsonRevisionNumber = CStr(thisStructure.Get("revision_number"))
							End If
							eData.Set "revision_number", jsonRevisionNumber
							
							jsonFullFilename = ""
							If thisStructure.Exists("full_filename") Then
								jsonFullFilename = thisStructure.Get("full_filename")
							End If
							eData.Set "full_filename", jsonFullFilename
							
							experimentData.Set j, eData
						End If
					Next
					experimentJson.Set CStr(i) , JSON.parse(JSON.stringify(experimentIds))
				End If
			End If
		Next
	End If
	
	canViewExperiments = getExperimentsICanView()
	Set canViewJson = JSON.parse(canViewExperiments)

	hasMustNotQuery = false
	If IsObject(canViewJson) Then
		Set boolObj = searchObj.Get("bool")

		if IsObject(boolObj.Get("mustNot")) then
			hasMustNotQuery = True
		end if
		
		' Set filter for experiments this user can view
		Set filterObj = boolObj.Get("filter")
		Set filterTermsObj = filterObj.Get("terms")
		filterTermsObj.Set "allExperimentId", canViewJson
		boolObj.Set "filter", filterObj

		If hasStructureSearch Then

			Set boolMustObj = handleStructureBool(boolObj, experimentJson) 
			searchObj.Set "bool", boolMustObj.get("bool")

		else 
			searchObj.Set "bool", boolObj
		End If

		
	End If

	Set esFieldsList = JSON.parse("[]")
	esFieldsList.push("e_userAddedName")
	esFieldsList.push("notebookid")
	esFieldsList.push("notebookName")
	esFieldsList.push("notebookDesc")
	esFieldsList.push("experimentType")
	esFieldsList.push("experimentId")
	esFieldsList.push("e_name")
	esFieldsList.push("e_details")
	esFieldsList.push("fullName")
	esFieldsList.push("dateCreated")
	esFieldsList.push("dateUpdated")
	esFieldsList.push("statusName")
	esFieldsList.push("revisionNumber")
	esFieldsList.push("attachmentNames")
	esFieldsList.push("attachmentIds")
	esFieldsList.push("attachmentFileNames")
	esFieldsList.push("noteNames")
	esFieldsList.push("visible")

	Set srcJson = JSON.parse("{}")
	srcJson.Set "includes", esFieldsList

	Set sortColOrderJson = JSON.parse("{}")
	sortColOrderJson.set "order", sortOrder
	Set sortJson = JSON.parse("{}")
	sortJson.set sortCol, sortColOrderJson

	Set sortList = JSON.parse("[]")
	sortList.push(sortJson)
	sortList.push("_score")

	Set searchJson = JSON.parse("{}")
	searchJson.Set "timeout", "5s"
	searchJson.Set "from", pageNum * pageSize
	searchJson.Set "size", pageSize
	searchJson.Set "sort", sortList
    searchJson.Set "_source", srcJson
	searchJson.Set "query", searchObj

	if not hasMustNotQuery then
		searchJson.set "min_score", 0.1
	end if

	searchJson = JSON.stringify(searchJson)
	
    Dim objXmlHttp
    Set objXmlHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.6.0")
    objXmlHttp.open "POST", elasticURL & "/_all/_search", True
    objXmlHttp.setRequestHeader "Content-Type", "application/json"
    objXmlHttp.send searchJson
	objXmlHttp.waitForResponse(60)
	
	Set searchResultsObj = JSON.parse(objXmlHttp.responseText)
	Set objXmlHttp = Nothing
	
    response.write("{""searchResults"":"&JSON.stringify(searchResultsObj)&",""structureData"":"&JSON.stringify(experimentData)&"}")
End If


%>