<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
    Dim post : post = Request.Form("molData")
%>
<%sectionId="reg"%>
<%
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Expires = -1
%>
<%dontResize=True%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="../registration/_inclds/lib_reg.asp"-->
<%
sectionId = "reg"
subSectionId = "search"

if (Not (session("regRegistrar") Or session("regUser")) Or session("regRestrictedUser")) Then
	response.redirect("logout.asp")
End If
%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<div class="registrationPage">
<h1>This is the query structure</h1>
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>

<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->

<script type="text/javascript">
	<%If session("useChemDrawForLiveEdit") Then%>
		useChemDrawForLiveEdit = true;
	<%End If%>

	var hasMarvin = <%=LCase(CStr(session("useMarvin")))%>
</script>
<div class="chemDrawWin" id="chemDrawWinRegSearch" style="width:200px;height:200px">
<div id="showRegHitsAspChemBox">
</div>
<script type="text/javascript">
	var formData = "";
	<%If post <> "" Then%>
		formData = `<%=post%>`;
	<% End If %>

    getChemistryEditorMarkup("searchCDX", "", formData, 200, 200, true).then(function (theHtml) {
        $("#showRegHitsAspChemBox").html(theHtml);
    });
</script>
</div>
<div>
<%
	Set resultCols = JSON.parse("[]")
	resultCols.Push("cd_id")
	resultCols.Push("reg_id")
	
	Set searchParamJson = JSON.parse("{}")
    searchParamJson.Set "searchType", "DUPLICATE"
	
	queryMol = CX_standardize(post,"mol:V3",stereoStandardizerConfig,"mol:V3")
	If whichClient = "SUNOVION" Or whichClient = "CARDURION" Then
		queryMol = setChiralFlag(queryMol, False)
	End If
	querySmiles = CX_standardize(queryMol,"mol:V3",stereoStandardizerConfig,"cxsmiles:+u")
%>
	Query SMILES: <%=querySmiles%><br><br>
<%
	jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))

    searchHitJson = CX_structureSearch(jChemRegDB,regMoleculesTable,aspJsonStringify(queryMol),conditions,JSON.stringify(searchParamJson),JSON.stringify(resultCols),2147483647,0)
	'response.write("searchHitJson: " & searchHitJson & "<br>")
	
	numResults = 0
	numCleanResults = 0
    Set searchHits = JSON.parse(searchHitJson)
    If IsObject(searchHits) And searchHits.Exists("data") Then
        Set results = searchHits.Get("data")
        If IsObject(results) Then
			numResults = results.Length
			cleanResultsJson = cleanRelativeStereoHits(queryMol, "mol:V3", JSON.Stringify(results), jChemRegDB, regMoleculesTable)
			Set cleanResults = JSON.Parse(cleanResultsJson)
			numCleanResults = cleanResults.Length
        End If
    End If
%>
<h1>Database (ChemAxon) Results</h1>
<table>
<tr>
<th>Structure</th>
<th align="center" style="width:50px;">ARX HIT</th>
<th align="center" style="width:200px;">Reg ID</th>
<th align="center" style="width:75px;">cd_id</th>
<th align="center">SMILES</th>
</tr>
<%
If numResults > 0 And IsObject(results) Then
	resultsProcessed = 0
	Do While resultsProcessed < numResults
		Set thisResult = results.Get(resultsProcessed)
%>
			<tr>
			<td align="center"><%=CX_getSvgByCdId(jChemRegDB,regMoleculesTable, thisResult.Get("cd_id"), 200, 200)%></td>
<%
			foundHit = "NO"
			thisResultCdId = thisResult.Get("cd_id")
			thisResultRegId = thisResult.Get("reg_id")
			If numCleanResults > 0 And IsObject(cleanResults) Then
				proc = 0
				Do While proc < numCleanResults
					Set thisResult = cleanResults.Get(proc)
					If thisResult.Get("cd_id") = thisResultCdId Then
						foundHit = "YES"
						Exit Do
					End If
					proc = proc + 1
				Loop
			End If
			
			smilesText = CX_cdIdSearch(jChemRegDB,regMoleculesTable, thisResultCdId, "mol:V3")
			thisResultSmiles = "ERROR: " & smilesText

			Set smilesJson = JSON.parse(smilesText)
			If IsObject(smilesJson) And smilesJson.Exists("structureData") Then
				Set structureData = smilesJson.Get("structureData")
				If IsObject(structureData) And structureData.Exists("structure") Then
					thisResultSmiles = structureData.Get("structure")
					If whichClient = "SUNOVION" Or whichClient = "CARDURION" Then
						thisResultSmiles = setChiralFlag(thisResultSmiles, False)
					End If
					thisResultSmiles = CX_standardize(thisResultSmiles,"mol:V3",stereoStandardizerConfig,"cxsmiles:+u")
				End If
				Set structureData = Nothing
			End If
			smilesText = ""
			Set smilesJson = Nothing
%>
			<td align="center"><%=foundHit%></td>
			<td align="center"><%=thisResultRegId%></td>
			<td align="center"><%=thisResultCdId%></td>
			<td align="center"><%=thisResultSmiles%></td>
			</tr>
<%
		resultsProcessed = resultsProcessed + 1
	Loop
End If
%>
</table>
</div>
</div>
<!-- #include file="../_inclds/footer-tool.asp"-->
