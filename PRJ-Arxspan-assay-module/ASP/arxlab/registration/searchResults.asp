<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.scripttimeout=180%>
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
chemAxonAllMoleculesTable = getCompanySpecificSingleAppConfigSetting("chemAxonAllMoleculesTable", session("companyId"))
chemAxonDatabaseName = getCompanySpecificSingleAppConfigSetting("chemAxonDatabaseName", session("companyId"))

sectionId = "reg"
subSectionId = "search"
regSearchResultsPage = true

if (Not (session("regRegistrar") Or session("regUser")) Or session("regRestrictedUser")) Then
	response.redirect("logout.asp")
End If

If request.querystring("clear") <> "" Then
	session("regSearchNumRecords") = ""
	session("regSearchNumPages") = ""
End if

If request.querystring("inFrame") = "true" Then
	inFrame = True
Else
	inFrame = false
End If

If request.querystring("inApiFrame") = "true" Then
	inApiFrame = True
Else
	inApiFrame = false
End If
fieldsToShow = request.querystring("fieldsToShow")
%>


<%
Const dbName = 0
Const sortDbName = 1
Const displayName = 2
Const sortable = 3
Const doDisplay = 4
Const htmlTrans = 5

Dim fields()
If Not inFrame then
	reDim fields(11)

	fields(0) = split("molecule:::false:true:",":")
	fields(1) = Split("reg_id:reg_id:Reg Number:true:true:",":")
	fields(2) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
	fields(3) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")
	fields(4) = split("source:source:Registration Source:true:true:",":")
	fields(5) = split("just_batch:::false:false:",":")
	fields(6) = split("just_reg:::false:false:",":")
	fields(7) = split("experiment_id:::false:false:",":")
	fields(8) = split("revision_number:::false:false:",":")
	fields(9) = split("experiment_name:::false:false:",":")
	fields(10) = split("type_id:::false:false:",":")
	fields(11) = split("cd_id:cd_idexport::false:true:<input type='checkbox' class='exportCheck' cd_id='$cd_id$' onchange='updateSearchKeyCdIds(this)'>",":")
Else
	If fieldsToShow = "" then

		reDim fields(7)

		fields(0) = split("molecule:::false:true:",":")
		fields(1) = Split("reg_id:reg_id:Reg Number:true:true:",":")
		fields(2) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
		fields(3) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")


		fields(4) = split("fp_1:selectSearchResult:Select:true:true:<a href='javascript&#58;void(0)' onclick='window.parent.regSelectLink(""$reg_id$"")'>Select</a>",":")
		fields(5) = split("just_batch:::false:false:",":")
		fields(6) = split("just_reg:::false:false:",":")
		fields(7) = split("cd_id:cd_id::false:false:",":")
	Else
		Call getconnectedJchemReg
		fieldList = Split(fieldsToShow,",")
		fieldMax = UBound(fieldList)+4
		ReDim fields(fieldMax)
		For i=0 To UBound(fieldList)
			If fieldList(i)="molecule" Or fieldList(i)="cd_molweight" Or fieldList(i)="user_name" Or fieldList(i)="cd_timestamp" Or fieldlist(i)="source" Or fieldlist(i)="reg_id" Then
				Select Case fieldList(i)
					Case "reg_id"
						fields(i) = Split("reg_id:reg_id:Reg Number:true:true:",":")
					Case "molecule"
						fields(i) = split("molecule:::false:true:",":")
					Case "cd_molweight"
						fields(i) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
					Case "user_name"
						fields(i) = split("user_name:user_name:User Name:true:true:",":")
					Case "cd_timestamp"
						fields(i) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")
					Case "source"
						fields(i) = split("source:source:Source:true:true:",":")
				End select
			Else
				Set rec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM customFields WHERE formName="&SQLClean(fieldlist(i),"T","S")			
				rec.open strQuery,jchemRegConn,3,3
				If Not rec.eof Then
					sStr = rec("actualField")&":"&rec("actualField")&":"&rec("displayName")&":true:true:"
					If fieldList(i) = linkField Then
						sStr = sStr & "<a href='showBatch.asp?regNumber="&wholeRegNumber&"-$just_batch$' target='parent'>$"&rec("actualField")&"$</a>"
					End If
					fields(i) = split(sStr,":")
				End If
			End if
		Next
		fields(i) = split("fp_1:selectSearchResult:Select:true:true:<a href='javascript&#58;void(0)' onclick='window.parent.regSelectLink(""$reg_id$"")'>Select</a>",":")
		fields(i+1) = split("just_batch:::false:false:",":")
		fields(i+2) = split("just_reg:::false:false:",":")
		fields(i+3) = split("cd_id:cd_id::false:false:",":")
		Call disconnectJchemReg
	End if
End if

queryMol = session("regSearchMolData")

inputMolDataJson = analyzeInputMol(queryMol)
Set inputMolData = JSON.Parse(inputMolDataJson)
If IsObject(inputMolData) Then
	queryMol = inputMolData.Get("structure")
	queryMolFormat = inputMolData.Get("molFormat")
End If
queryMol = CX_standardize(queryMol,queryMolFormat,defaultStandardizerConfig,"mol:V3")
queryMolFormat = "mol:V3"

searchType = session("regSearchType")
sim = session("sim")

cdIdStr = ""
doStructureSearch = False

cxInsertResp = CX_addStructure(chemAxonDatabaseName,chemAxonAllMoleculesTable,aspJsonStringify(queryMol),"")
Set respJson = JSON.parse(cxInsertResp)
If IsObject(respJson) Then
	If respJson.Exists("cd_id") Then
		doStructureSearch = True
	End If
End If

If doStructureSearch then
    numResults = 0
    regError = True
	Call getConnectedJchemReg
	%><!-- #include file="_inclds/searchOptionsString.asp"--><%
	Call disconnectJchemReg
    searchParamJson.Set "searchType", searchType
	
	If searchType = "SIMILARITY" And session("sim") <> "" Then
		searchParamJson.Set "similarityThreshold", session("sim")/100
	End If
	
	jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
    searchHitJson = CX_structureSearch(jChemRegDB,regMoleculesTable,aspJsonStringify(queryMol),conditions,JSON.stringify(searchParamJson),"[""cd_id""]",2147483647,0)

	numResults = 0
    Set searchHits = JSON.parse(searchHitJson)
    If IsObject(searchHits) And searchHits.Exists("data") Then
        Set results = searchHits.Get("data")
        If IsObject(results) Then
			If searchType = "DUPLICATE" Then
				cleanResultsJson = cleanRelativeStereoHits(queryMol, queryMolFormat, JSON.Stringify(results), jChemRegDB, regMoleculesTable)
				Set cleanResults = JSON.Parse(cleanResultsJson)
				regError = False
			Else
				Set cleanResults = searchHits.Get("data")
			End If
			
			numResults = cleanResults.Length
        End If
    End If

	Set allSims = JSON.parse("[]")
	Set allCdids = JSON.parse("[]")
	For j = 0 To numResults-1
		Set thisResult = cleanResults.Get(j)
		allCdids.Push(thisResult.Get("cd_id"))
		If searchType = "SIMILARITY" Then
			allSims.Push(thisResult.Get("cd_id"))
		End If
	Next

	If allCdIds.Length > 0 Then
		structureGroups = JSON.parse(getGroupIdsThatHaveStructure())
		cdIdStr = "((groupId is null or groupId in ("&structureGroups&"))"
		cdIdStr = cdIdStr & " and cd_id in ("&allCdIds&"))"
	End If
End if

firstQuery = "("&_
			 "UPPER(cd_smiles) like "&SQLClean(session("regStrSearch"),"L","S")& " or "&_
			 "UPPER(cd_formula) like "&SQLClean(session("regStrSearch"),"L","S")& " or "&_
			 "UPPER(cd_molweight) like "&SQLClean(session("regStrSearch"),"L","S")& " or "&_
			 "UPPER(name) like "&SQLClean(session("regStrSearch"),"L","S")& " or "&_
			 "UPPER(chemical_name) like "&SQLClean(session("regStrSearch"),"L","S")& " or "&_
			 "UPPER(user_name) like "&SQLClean(session("regStrSearch"),"L","S")& " or "&_
			 "UPPER(status) like "&SQLClean(session("regStrSearch"),"L","S")& " or "&_
			 "UPPER(reg_id) like "&SQLClean(session("regStrSearch"),"L","S")& " or "&_
			 "UPPER(source) like "&SQLClean(session("regStrSearch"),"L","S")& " or "&_
			 "UPPER(experiment_name) like "&SQLClean(session("regStrSearch"),"L","S")

Call getconnectedjchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM customFields WHERE dataType <> 'long_text'"
rec.open strQuery,jChemRegConn,3,3
Do While Not rec.eof
	firstQuery = firstQuery & " or UPPER(" & rec("actualField") & ") like " & SQLClean(session("regStrSearch"),"L","S")
	rec.movenext
Loop
rec.close
Set rec = Nothing
Call disconnectJchemReg
firstQuery = firstQuery & ")"

If session("regStrSearch") <> "" then
	tableStrQuery = "SELECT "&top&"* FROM searchView WHERE 1=1 and is_permanent=1 and(status_id=1) and"&firstQuery
Else
	If session("regSearchSQL") = "" then
		tableStrQuery = "SELECT "&top&"* FROM searchView WHERE 1=1 and (status_id=1)"
	Else
		tableStrQuery = "SELECT "&top&"* FROM searchView WHERE 1=1 and (status_id=1) and "&session("regSearchSQL")
	End if
	If session("regRestrictedGroups") <> "" Then
		tableStrQuery = tableStrQuery & " AND groupId not in ("&session("regRestrictedGroups")&")"
	End If
End If

If doStructureSearch Then
	If cdIdStr = "" then
		tableStrQuery = tableStrQuery & " AND 1=2"
	else
		tableStrQuery = tableStrQuery & " AND "&cdIdStr
	End if
End if
session("vTableStr") = vTableStr
session("tableStrQuery") = tableStrQuery
'response.write(session("tableStrQuery"))
%>

<%If inframe Or inApiFrame then%>
<!-- #include file="../_inclds/frame-header-tool.asp"-->
<%else%>
<!-- #include file="../_inclds/header-tool.asp"-->
<%End if%>
<script type="text/javascript">
	function updateSearchKeyCdIds(checkbox){
		theCdId = checkbox.getAttribute("cd_id");
		url = "ajax_loaders/addCdIdsToSearchKey.asp?cdId="+theCdId+"&searchKey=<%=request.querystring("searchKey")%>";
		if(checkbox.checked){
			url += "&value=1";
		}
		getFileA(url);
	}
</script>
<script type="text/javascript">
function beforeExport()
{
	document.getElementById("overrideCdids").value = ""
	cdIdStr = "0"
	els = document.getElementById("regMolTable").getElementsByTagName("input")
	for(i=0;i<els.length;i++)
	{
		if (els[i].getAttribute("type") == "checkbox")
		{
			if (els[i].checked)
			{
				if (els[i].getAttribute("cd_id"))
				{
					cdIdStr += "," + els[i].getAttribute("cd_id")
				}
			}
		}
	}
	if (cdIdStr != "0")
	{
		document.getElementById("overrideCdids").value = "("+cdIdStr+")"
	}
	document.getElementById('exportFid').value = Math.floor(Math.random()*Math.pow(10,12))
}

function checkAllFields(el)
{
	if (el.checked)
	{
		isOn = true
	}
	else
	{
		isOn = false
	}
	els = document.getElementById("exportFieldsDiv").getElementsByTagName("input")
	for(i=0;i<els.length;i++)
	{
		if (els[i].getAttribute("type") == "checkbox")
		{
			els[i].checked = isOn;
		}
	}
}

</script>

<script type="text/javascript">
function setCookie(c_name,value,exdays)
{
var exdate=new Date();
exdate.setDate(exdate.getDate() + exdays);
var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
document.cookie=c_name + "=" + c_value+";"+'path=/';
}

function makeCookie(numFields)
{
	cookieStr = ""
	for (i=1;i<=numFields;i++)
	{
		 var exportCheck = document.getElementById("exportCheck_"+i);
		 if(exportCheck != undefined && exportCheck.checked){
			cookieStr +="1"
		 }else{
			cookieStr +="0"
		 }
		 if (i<numFields){
			 cookieStr +=","
		 }
	}
	setCookie("fieldChecks","",1000)
	setCookie("fieldChecks",cookieStr,1000)
}
</script>

<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM customFields ORDER BY ID ASC"
rec.open strQuery,jchemRegConn,3,3
numFields = 8
Do While Not rec.eof
	numFields = numFields + 1
	rec.movenext
Loop
rec.close
Set rec = nothing
Call disconnectJchemReg
cookieStr = request.Cookies("fieldChecks")
fudgeFactor = 0
For i = UBound(Split(cookieStr,","))+fudgeFactor To numFields
	If i <> 1 Then
		cookieStr = cookieStr & ","
	End if
	cookieStr = cookieStr & "0"
next
checkFlags = Split(cookieStr,",")
%>


<div style="width:380px;height:500px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="exportFieldsDiv" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopup('exportFieldsDiv');return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif" style="border:none;"></a>
<div style="padding:10px;overflow:auto;height:480px;">
<h1 style="margin-bottom:10px;">Select Fields</h1>
<form id="exportFieldsForm" method="post" action="sendExport.asp" target="submitFrame">
<table>
<tr>
<td colspan="2" style="padding-left:5px;padding-bottom:10px;">
	<input type="checkbox" style="display:inline;margin-right:5px;" onclick="checkAllFields(this)">Select All
</td>
</tr>
<tr>
<td style="padding-left:5px;">
	<input type="checkbox" id="exportCheck_1" name="exportCheck_1" style="display:inline;margin-right:5px;" <%If checkFlags(0) = "1" then%>checked<%End if%>>Smiles
	<input type="hidden" id="exportString_1" name="exportString_1" value="cd_smiles:Smiles">
</td>
<td style="padding-left:5px;">
	<input type="checkbox" id="exportCheck_2" name="exportCheck_2" style="display:inline;margin-right:5px;" <%If checkFlags(1) = "1" then%>checked<%End if%>>Formula
	<input type="hidden" id="exportString_2" name="exportString_2" value="cd_formula:Formula">
</td>
</tr>

<tr>
<td style="padding-left:5px;">
	<input type="checkbox" id="exportCheck_3" name="exportCheck_3" style="display:inline;margin-right:5px;" <%If checkFlags(2) = "1" then%>checked<%End if%>>Molecular Weight
	<input type="hidden" id="exportString_3" name="exportString_3" value="cd_molweight:Molecular Weight">
</td>
<td style="padding-left:5px;">
	<input type="checkbox" id="exportCheck_4" name="exportCheck_4" style="display:inline;margin-right:5px;" <%If checkFlags(3) = "1" then%>checked<%End if%>>Date Created
	<input type="hidden" id="exportString_4" name="exportString_4" value="cd_timestamp:Date Created">
</td>
</tr>

<tr>
<%

hideChemicalNameFieldInReg = checkBoolSettingForCompany("hideChemicalNameFieldInReg", session("companyId"))
if not hideChemicalNameFieldInReg then%>
	<td style="padding-left:5px;">
		<input type="checkbox" id="exportCheck_5" name="exportCheck_5" style="display:inline;margin-right:5px;" <%If checkFlags(4) = "1" then%>checked<%End if%>>Chemical Name
		<input type="hidden" id="exportString_5" name="exportString_5" value="chemical_name:Chemical Name">
	</td>
<%end if%>
<td style="padding-left:5px;">
	<input type="checkbox" id="exportCheck_6" name="exportCheck_6" style="display:inline;margin-right:5px;" <%If checkFlags(5) = "1" then%>checked<%End if%>>User Name
	<input type="hidden" id="exportString_6" name="exportString_6" value="user_name:User Name">
</td>
</tr>
<tr>
<td style="padding-left:5px;">
	<input type="checkbox" id="exportCheck_7" name="exportCheck_7" style="display:inline;margin-right:5px;" <%If checkFlags(6) = "1" then%>checked<%End if%>>Salt Codes
	<input type="hidden" id="exportString_7" name="exportString_7" value="salt_codes:salt_codes">
</td>
<td style="padding-left:5px;">
	<input type="checkbox" id="exportCheck_8" name="exportCheck_8" style="display:inline;margin-right:5px;" <%If checkFlags(7) = "1" then%>checked<%End if%>>Salt Multiplicities
	<input type="hidden" id="exportString_8" name="exportString_8" value="salt_multiplicities:salt_multiplicities">
</td>
</tr>

<tr>
<td style="padding-left:5px;">
	<input type="checkbox" id="exportCheck_9" name="exportCheck_9" style="display:inline;margin-right:5px;" <%If checkFlags(8) = "1" then%>checked<%End if%>>Exact Mass
	<input type="hidden" id="exportString_9" name="exportString_9" value="exact_mass:Exact Mass">
</td>

<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM customFields ORDER BY ID ASC"
rec.open strQuery,jchemRegConn,3,3
counter = 9
Do While Not rec.eof
	counter = counter + 1
	If counter - 1 > UBound(checkFlags) Then
		ReDim preserve checkFlags(counter -1)
		checkFlags(counter -1) = 0
	End if
	%><td style="padding-left:5px;">
	<input type="checkbox" id="exportCheck_<%=counter%>" name="exportCheck_<%=counter%>" style="display:inline;margin-right:5px;" <%If checkFlags(counter-1) = "1" then%>checked<%End if%>><%=rec("displayName")%>
	<input type="hidden" id="exportString_<%=counter%>" name="exportString_<%=counter%>" value="<%=rec("actualField")%>:<%=rec("displayName")%>">
	</td><%
	If counter Mod 2 = 0 Then
		%></tr><tr><%
	End If
	hasSpecialPositionFieldReg = checkBoolSettingForCompany("hasSpecialPositionFieldReg", session("companyId"))
	If hasSpecialPositionFieldReg then
		If LCase(rec("displayName")) = "position" Then
			positionCheckId = "exportCheck_"&counter
		End if
	End if
	rec.movenext
Loop
rec.close
Set rec = nothing
Call disconnectJchemReg
%>
<tr>
<td style="padding-left:5px;">
	<%counter = counter + 1%>
	<%
	If counter - 1 > UBound(checkFlags) Then
		ReDim preserve checkFlags(counter -1)
		checkFlags(counter -1) = 0
	End if
	%>
	<input type="checkbox" id="exportCheck_<%=counter%>" name="exportCheck_<%=counter%>" style="display:inline;margin-right:5px;" <%If checkFlags(counter-1) = "1" then%>checked<%End if%>>Smiles w/ Salts
	<input type="hidden" id="exportString_<%=counter%>" name="exportString_<%=counter%>" value="smilesWithSalts:smilesWithSalts">
</td>
<td style="padding-left:5px;">
	<%counter = counter + 1%>
	<%
	If counter - 1 > UBound(checkFlags) Then
		ReDim preserve checkFlags(counter -1)
		checkFlags(counter -1) = 0
	End if
	%>
	<input type="checkbox" id="exportCheck_<%=counter%>" name="exportCheck_<%=counter%>" style="display:inline;margin-right:5px;" <%If checkFlags(counter-1) = "1" then%>checked<%End if%>>MW w/ Salts
	<input type="hidden" id="exportString_<%=counter%>" name="exportString_<%=counter%>" value="mwWithSalts:mwWithSalts">
</td>
</tr>
<input type="hidden" id="positionCheckId" name="positionCheckId" value="<%=positionCheckId%>">
<input type="hidden" id="numExportFields" name="numExportFields" value="<%=counter%>">
<%fid = getRandomNumber(12)%>
<input type="hidden" id="exportFid" name="exportFid" value="<%=fid%>">
<input type="hidden" id="exportCdIdString" name="exportCdIdString" value="<%=cdIdStr%>">
<input type="hidden" id="overrideCdids" name="overrideCdids" value="">
<input type="hidden" id="forAnalysis" name="forAnalysis" value="">
</tr>
</table>
<br/>
<!-- #include file="_inclds/exportButtons.asp"-->
</form>
</div>
</div>

<%If inframe Or inApiFrame then%>
<!-- #include file="../_inclds/frame-nav_tool.asp"-->
<div class="registrationPage" style="padding:10px;width:830px;">
<style type="text/css">
.contentTable{
	width:850px!important;
}
.pageContent{
	width:850px!important;
}
</style>
<%else%>
<!-- #include file="../_inclds/nav_tool.asp"-->
<%End if%>

<div class="registrationPage">
<h1>Registration Search Results</h1> 
<div>
	<div style="float:left;"><p><span id="headerResults"></span><%If Not inFrame And Not inApiFrame then%><a href="javascript:void(0);" onClick="beforeExport();showPopup('exportFieldsDiv')" style="margin-left:5px;">Export Results</a><%End if%></p></div>

	<div style="float:right;">
		<%
			rpp = request.querystring("rpp")
			If Not isInteger(rpp) Then
				rpp = defaultRpp
			Else
				rpp = CInt(rpp)
				If rpp < 5 or rpp > 50 Then
					rpp = defaultRpp
				End if
			End if
		%>
		<%If Not inFrame And Not inApiFrame then%>
		<span class="notebookCreator" style="margin-bottom:5px;"><span class="notebookCreatorTitle">Number of Results:&nbsp;</span>
			<select name="defaultResults" id="defaultResults" style="display:inline;" onchange="window.location.href='searchResults.asp?clear=true&rpp='+this.options[this.selectedIndex].value+'&s=<%=request.querystring("s")%>&d=<%=request.querystring("d")%>&inFrame=<%=request.querystring("inFrame")%>'">
				<option value="5" <%If rpp = 5 then%> SELECTED<%End if%>>5</option>
				<option value="10" <%If rpp = 10 then%> SELECTED<%End if%>>10</option>
				<option value="25" <%If rpp = 25 then%> SELECTED<%End if%>>25</option>
			</select>
		<%End if%>
		</div>
</div>
<div style="height:0px;clear:both;"></div>

<script type="text/javascript">
function toggleSearchTR(just_reg,groupId,cdId)
{
	currentHTML = document.getElementById("div_"+cdId).innerHTML
	if (currentHTML == "")
	{
		html = getFile("searchResultsBatches.asp?groupId="+groupId+"&regNumber="+just_reg+"&cdId="+cdId+"&inFrame=<%=request.querystring("inFrame")%>&rand="+Math.random())
		document.getElementById("div_"+cdId).innerHTML = html;	
	}
	tr = document.getElementById("tr_"+cdId)
	theImg = document.getElementById("img_"+cdId)
	if (tr.style.display == "none")
	{
		try{tr.style.display = "table-row"}
		catch(err){tr.style.display = "block"}
		theImg.src = "<%=mainAppPath%>/images/minus.gif"
	}
	else
	{
		tr.style.display = "none";
		theImg.src = "<%=mainAppPath%>/images/plus.gif"
	}
}
</script>

<script type="text/javascript">
	function waitRegExport(fid)
	{
		res = getFile("exportExists.asp?fid="+fid+"&random="+Math.random()) 
		if (res=="yes")
		{
			window.setTimeout("waitRegExport("+fid+")",1000)
		}
		else
		{
			window.location.href = "exportDownload.asp?fid="+fid+"&random="+Math.random()
			hidePopup('loadingDiv');
		}
	}
</script>




<%
whichTable = "searchView"
defaultSortDirection = "DESC"
defaultSort = "cd_id"
pageName = "searchResults.asp?a=1&inApiFrame="&request.querystring("inApiFrame")&"&searchKey="&request.querystring("searchKey")
defaultRpp = 5


Call getconnectedJchemReg
%>
	<!-- #INCLUDE file="_inclds/chemTable2.asp" -->

</div>
<%'div shown when there when loading white box in middle of screen%>
<div style="width:300px;height:100px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="loadingDiv" class="popupDiv">
<table height="100%" width="100%">
	<tr>
		<td valign="middle" align="center">
			<h1 style="display:inline;">Loading...</h1>
		</td>
	</tr>
</table>
</div>

<!-- #include file="../_inclds/common/html/submitFrame.asp"-->
<%If inframe Or inApiFrame then%>
<script type="text/javascript">
addLoadEvent(function(){
	selectedCdIds = []
	<%
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM searchKeyCdIds WHERE searchKey="&SQLClean(request.querystring("searchKey"),"T","S")
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		%>
		selectedCdIds.push('<%=rec("cdId")%>');
		<%
		rec.movenext
	loop
	%>

	els = document.getElementById("regMolTable").getElementsByTagName("input")
	for(var i=0;i<els.length;i++)
	{
		if (els[i].getAttribute("type") == "checkbox"){
			if(selectedCdIds.indexOf(els[i].getAttribute("cd_id"))>=0){
				els[i].checked = true;
			}
		}
	}
})
</script>
</div>
<!-- #include file="../_inclds/frame-footer-tool.asp"-->
<%else%>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%End if%>