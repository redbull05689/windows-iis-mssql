<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<%
sectionId = "reg"
subSectionId = "add-salt"
if Not session("regRegistrar") Or session("regRegistrarRestricted") Then
	response.redirect("logout.asp")
End If

If request.Form("addSaltSubmit") <> "" Then
	jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
	regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
	oldCdxml = request.Form("addSaltCdxmlData")
	inputMol = oldCdxml
	
	inputMolDataJson = analyzeInputMol(inputMol)
	Set inputMolData = JSON.Parse(inputMolDataJson)
	If IsObject(inputMolData) Then
		inputMol = inputMolData.Get("structure")
		inputMolFormat = inputMolData.Get("molFormat")
	End If
		
	regError = False
	errorText = ""
	If Trim(request.Form("addSaltMolData")) = "" Then
		regError = True
		errorText = errorText & "Please enter a structure.  "
	End If
	If Trim(request.Form("addSaltName")) = "" Then
		regError = True
		errorText = errorText & "Please enter a name.  "
	End If
	If Trim(request.Form("addSaltCode")) = "" Then
		regError = True
		errorText = errorText & "Please enter a code.  "
	End If
	If request.Form("addSaltType") <> "1" And request.Form("addSaltType") <> "2" Then
		regError = True
		errorText = errorText & "Please select a type.  "
	End If

	numResults = 0
	regError = True
	Set params = JSON.parse("{}")
	params.Set "searchType", "DUPLICATE"
	searchHitJson = CX_structureSearch(jChemRegDB,regSaltsTable,inputMol,"",JSON.stringify(params),"[""cd_id""]",2147483647,0)
	
	Set searchHits = JSON.parse(searchHitJson)
	If IsObject(searchHits) And searchHits.Exists("data") Then
		thisCdId = -1
		thisRegId = -1
		
		Set results = searchHits.Get("data")
		If IsObject(results) Then
			cleanResultsJson = cleanRelativeStereoHits(inputMol, "", JSON.Stringify(results), jChemRegDB, regSaltsTable)
			Set cleanResults = JSON.Parse(cleanResultsJson)
			regError = False
			numResults = cleanResults.Length
		End If
	End If
	
	If regError Then
		errorText = errorText & "There was an error searching for duplicate salts. "
	End If
	
	If numResults > 0 Then
		regError = True
		errorText = errorText & "Structure already exists.  "
	End if

	If Not regError then
		molTypeId = request.Form("addSaltType")
		newCdId = addToSaltTable(request.Form("addSaltName"),molTypeId,inputMol,request.Form("addSaltCode"))
	End if
End if
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<div class="registrationPage">
<h1><%=addSaltLabel%></h1>

<div id="addStructureContainer" style="<%If regError or request.Form("addSaltSubmit") = "" then%><%else%>display:none;<%End if%>">

<div class="chemDrawWin">
<div id="adminAddSaltAspChemBox">
</div>
<script type="text/javascript">
	hasMarvin = <%=LCase(CStr(session("useMarvin"))) %>

	<%If session("useChemDrawForLiveEdit") Then%>
		useChemDrawForLiveEdit = true;
	<%End If%>
    getChemistryEditorMarkup("addSaltCDX", "", "", 400, 300, false).then(function (theHtml) {
        $("#adminAddSaltAspChemBox").html(theHtml);
    });
</script>
</div>
<br>
<%If regError then%>
<div class="regErrorDiv" style="color:red;">
	<%=errorText%>
</div>
<%End if%>
<form action="adminAddSalt.asp" method="post" onsubmit="getChemistryEditorChemicalStructure('addSaltCDX').then(function(cdxdata){document.getElementById('addSaltCdxmlData').value = cdxdata;document.getElementById('addSaltMolData').value = cdxdata;document.getElementById('addSaltChemicalName').value = cdxdata;return true;});">
<table cellspacing="0" cellpadding="0">
<tr>
	<td>
		<label for="addSaltName">Name*:</label>
	</td>
	<td>
		<input type="text" name="addSaltName" id="addSaltName" value="<%=request.Form("addSaltName")%>">
	</td>
</tr>
<tr>
	<td>
		<label for="addSaltType">Type*:</label>
	</td>
	<td>
		<input type="radio" name="addSaltType" id="addSaltType" value="1" checked>Salt
		<input type="radio" name="addSaltType" id="addSaltType" value="2">Solvate
	</td>
</tr>
<tr>
	<td>
		<label for="addSaltCode">Code*:</label>
	</td>
	<td>
		<input type="text" name="addSaltCode" id="addSaltCode" value="<%=request.Form("addSaltCode")%>">
		<input type="submit" name="addSaltSubmit" id="addSaltSubmit" value="ADD">
	</td>
</tr>
</table>
<input type="hidden" name="addSaltMolData" id="addSaltMolData" value="">
<input type="hidden" name="addSaltCdxmlData" id="addSaltCdxmlData" value="">
<input type="hidden" name="addSaltChemicalName" id="addSaltChemicalName" value="">
<input type="hidden" name="oldCDX" id="oldCDX" value="<%=replace(oldCdxml,"""","&quot;")%>">
</form>

<%If request.Form("addSaltSubmit") <> "" And regError then%>
<script type="text/javascript">
	$("#addSaltCDX").attr('molData',document.getElementById("oldCDX").value.replace(/&quot;/,'"'));
	getUpdatedLiveEditStructureImage("addSaltCDX");
</script>
<%end if%>

</div>

<%If Not regError And request.Form("addSaltSubmit") <> "" then%>
<div id="addStructureContainer">
	<div class="regSuccessDiv">
		Molecule Added
		<input type="button" onclick="window.location.href=window.location.href" value="ADD ANOTHER">
	</div>
</div>
<%End if%>
<h2>Salts</h2>
<%
Const dbName = 0
Const sortDbName = 1
Const displayName = 2
Const sortable = 3
Const doDisplay = 4
Const htmlTrans = 5

Dim fields()

reDim fields(4)
fields(0) = split("molecule:::false:true:",":")
fields(1) = Split("name:name:Name:true:true:",":")
fields(2) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
fields(3) = split("salt_code:salt_code:Code:true:true:",":")
fields(4) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")

tableStrQuery = "SELECT * FROM "&regSaltsTable

whichTable = regSaltsTable
defaultSort = "cd_timestamp"
defaultSortDirection = "DESC"
pageName = "adminAddSalt.asp?"
defaultRpp = 5
%>
	<!-- #INCLUDE file="_inclds/chemTable.asp" -->
</div>
<!-- #include file="../_inclds/footer-tool.asp"-->