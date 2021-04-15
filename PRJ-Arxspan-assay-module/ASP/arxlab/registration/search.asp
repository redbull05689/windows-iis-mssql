<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<%
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Expires = -1
%>
<%dontResize=True%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<%
sectionId = "reg"
subSectionId = "search"

if (Not (session("regRegistrar") Or session("regUser")) Or session("regRestrictedUser")) Then
	response.redirect("logout.asp")
End If

If request.querystring("inFrame") = "true" Then
	inFrame = True
Else
	inFrame = false
End If

If request.querystring("inApiFrame") = "true" Then
	inApiFrame = True
	Call getconnectedJchemReg
	strQuery = "INSERT INTO searchKeys(searchKey,userId) values("&SQLClean(request.querystring("searchKey"),"T","S")&","&SQLClean(session("userId"),"N","S")&")"
	jchemRegConn.execute(strQuery)
	Call disconnectJchemReg
Else
	inApiFrame = false
End If

%>
<%
If request.Form("searchSubmit") <> "" then
	session("regSearchMolData") = request.Form("molData")
	session("regSearchType") = request.Form("searchType")
	session("regStrSearch") = request.Form("strSearch")
	session("regSearchNumRecords") = ""
	session("regSearchNumPages") = ""
	session("lastRegSearch") = request.Form("savedSearch")
	If IsNumeric(request.Form("sim")) then
		If CInt(request.Form("sim")) >= 30 And CInt(request.Form("sim")) <= 100 Then
			session("sim") = CInt(request.Form("sim"))
		Else
			session("sim") = 80
		End If
	Else
		session("sim") = 80
	End if
	If request.Form("fields") <> "" Then
		%>
		<!-- #include file="../_inclds/common/asp/searchMaker.asp"-->
		<%
		session("regSearchSQL") = qStr
		'response.write(qStr)
	Else
		session("regSearchSQL") = ""
	End if
	response.redirect("searchResults.asp?fieldsToShow="&request.querystring("fieldsToShow")&"&inframe="&request.querystring("inFrame")&"&inApiFrame="&request.querystring("inApiFrame")&"&searchKey="&request.querystring("searchKey"))
End if
%>
<%If inframe Or inApiFrame then%>
<%isRegSearch=True%>
<!-- #include file="../_inclds/frame-header-tool.asp"-->
<!-- #include file="../_inclds/frame-nav_tool.asp"-->

<div class="registrationPage" style="padding:10px;">
<style type="text/css">
.contentTable{
	width:850px!important;
}
.pageContent{
	width:850px!important;
}
</style>
<%else%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<%End if%>
<!-- #INCLUDE file="../_inclds/common/html/popupDivBarcode.asp" -->
<SCRIPT type="text/javascript" SRC="<%=mainAppPath%>/js/calendar.js?<%=jsRev%>"></SCRIPT>
<SCRIPT type="text/javascript">
	var dt = new CalendarPopup();
</SCRIPT>
<script type="text/javascript">
	var advancedSearchItemsFile ="getFields.asp";
	var advancedSearchSaltsFile ="getSalts.asp";
	var advancedSearchFieldGroupFile ="getFieldGroups.asp";
	var advancedSearchProjectsFile = "getProjects.asp"
</script>
<script type="text/javascript" src="<%=mainAppPath%>/js/advancedSearch.js?<%=jsRev%>"></script>
<div class="registrationPage">
<h1>Registration Search</h1>
<%If session("hasChemistry") then%>
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
<%End if%>
<%If session("hasChemistry") then%>
<div class="chemDrawWin" id="chemDrawWinRegSearch" style="width:550px;height:300px">
<%End if%>
<div id="searchAspChemBox">
</div>
<script type="text/javascript">
<%If session("hasChemistry") then%>
    getChemistryEditorMarkup("searchCDX", "", "", 550, 300, false).then(function (theHtml) {
        $("#searchAspChemBox").html(theHtml);
    });
<%end if%>
function searchSubmitFunction()
{
	$("#searchSubmit").attr('value', 'Searching...');
	$("#searchSubmit").html('Searching...');
	finalizeSearch();
	<%If session("hasChemistry") then%>
	getChemistryEditorChemicalStructure("searchCDX", false, "mol:V3").then(function(cdx){
		document.getElementById('molData').value = cdx;	
		$('#searchForm').submit();
	});
	<%else%>
		$('#searchForm').submit();
	<%end if%>
}
</script>
<%If session("hasChemistry") then%>
</div>
<%End if%>

<div class="regSearchForm">
<form method="post" action="search.asp?fieldsToShow=<%=request.querystring("fieldsToShow")%>&inFrame=<%=request.querystring("inFrame")%>&inApiFrame=<%=request.querystring("inApiFrame")%>&searchKey=<%=request.querystring("searchKey")%>" id="searchForm">

<a href="#" style="display:none;" id="dummyA"></a>
<div class="regSearch_topSection">
<%If session("hasChemistry") then%>
<div class="regSearchTop_searchTypeRow">
<label for="searchType"><%=searchTypeLabel%></label>
<select id="searchType" name="searchType" onchange="if(this.options[this.selectedIndex].value=='SIMILARITY'){document.getElementById('simDiv').style.display='block';}else{document.getElementById('simDiv').style.display='none';}">
	<option value="SUBSTRUCTURE" <%If session("regSearchType") = "SUBSTRUCTURE" Then%>selected<%End if%>>Substructure Search</option>
	<option value="DUPLICATE" <%If session("regSearchType") = "DUPLICATE" Then%>selected<%End if%>>Exact Search</option>
	<option value="SIMILARITY" <%If session("regSearchType") = "SIMILARITY" Then%>selected<%End if%>>Similarity Search</option>
	<option value="SUPERSTRUCTURE" <%If session("regSearchType") = "SUPERSTRUCTURE" Then%>selected<%End if%>>Superstructure Search</option>
</select>
</div>
<%End if%>

<div id="simDiv" style="<%If session("regSearchType") <> "SIMILARITY" Then%>display:none;<%End if%>" class="regSearchTop_searchSimilarity">
<label for="sim">Similarity(0-100)</label>
<input type="text" name="sim" id="sim" value="">
</div>

<div class="regSearchTop_searchTypeRow">
<label for="strSearch">Search</label>
<input type="text" name="strSearch" id="strSearch" value="<%=session("regStrSearch")%>">
<input type="button" name="searchSubmit" id="searchSubmit" onclick="searchSubmitFunction();" value="<%=searchLabel%>">
</div>

<script type="text/javascript">
$("#strSearch").keyup(function(event) {
    if (event.keyCode === 13) {
        $("#searchSubmit").click();
    }
});
</script>

<input type="hidden" name="molData" id="molData" value="<%=molData%>">
<input type="hidden" name="fields" id="fields" value="">
<input type="hidden" name="savedSearch" id="savedSearch" value="">
<input type="hidden" name="searchSubmit" id="searchSubmitHidden" value="searchSubmit">





<div class="regSearchTop_advancedSearchButton">
	<div id="buttonAdvancedSearch" name="buttonAdvancedSearch" class="buttonAdvancedSearch">      
      <a class="buttonAdvancedSearchIcon" href="javascript:void(0);" onclick="newGroup()">+</a><a class="buttonAdvancedSearchText" href="javascript:void(0);" onclick="newGroup();this.onclick=null;">Advanced Search</a>
    </div>
</div>


</div>
<div id="advancedSearchHolder" style="display:none;">
<h2>Match the following rules:</h2>
</div>
<div id="addNewGroup" onclick="newGroup()" name="addToGroup" class="fieldHolder fieldHolderAddNewGroup" style="display:none;float:left;">
	<a class="addNewGroupButton">+</a><a class="addNewGroupButtonText">Add new group</a>        
</div>

<div id="searchButton2" onclick="$('#searchSubmit').click()" name="addToGroup" class="fieldHolder fieldHolderAddNewGroup" style="display:none;margin-left:540px;">
	<a class="addNewGroupButtonText">Search</a>        
</div>
<div style="height:0px;clear:both;"></div>

</form>
</div>
<%If session("regSearchMolData") <> "" then%>
<script type="text/javascript">
function loadMol(molData)
{
	$("#searchCDX").attr('molData',"<%=regSearchMolData%>");
	getUpdatedLiveEditStructureImage("searchCDX");
}
</script>
<%End if%>
<script type="text/javascript">
	el = document.getElementById("searchType");
	if(el)
		el.onchange()
</script>
</div>
<%If session("lastRegSearch") <> "" then%>
<script type="text/javascript">
	$(document).ready(function () {
		buildSavedSearch(JSON.parse('<%=session("lastRegSearch")%>'))
	});
</script>
<%End if%>
<script type="text/javascript">
	$(document).ready(function () {
		$( window ).unload(function(){});
    });
</script>
<%If inframe Or inApiFrame then%>
</div>
<!-- #include file="../_inclds/frame-footer-tool.asp"-->
<%else%>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%End if%>