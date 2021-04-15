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
<h1>Problem Structure Search</h1>
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
<div class="chemDrawWin" id="chemDrawWinRegSearch" style="width:550px;height:300px">
<div id="findRegHitsAspChemBox">
</div>
<script type="text/javascript">
getChemistryEditorMarkup("searchCDX", "", "", 550, 300, false).then(function (theHtml) {
    $("#findRegHitsAspChemBox").html(theHtml);
});

function searchSubmitFunction()
{
	$("#searchSubmit").attr('value', 'Processing structure...');
	$("#searchSubmit").html('Processing structure...');
	getChemistryEditorChemicalStructure("searchCDX", false, "mol:V3").then(function(cdx){
		var molData = cdx;
		var molDataStr = unescape(molData);
		
		molDataType = getFileFormat(molData);
		if(molDataType == ""){
			//try again with the escaped one
			molDataType = getFileFormat(molDataStr);
		}

		if(molDataType == 'cdxml' && isCdxml(molDataStr)) {
			molDataStr = truncateCdxmlProlog(molDataStr);
		}

		var theData = JSON.stringify({"structure": molDataStr,
								  "parameters": "mol:V3",
								  "inputFormat": molDataType});
		$.ajax({
			method: "POST",
			url: window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport",
			data: theData,
			dataType: "json",
			contentType: "application/json",
			async: true
		}).done(function(msg) {
			if(msg.hasOwnProperty("structure"))
			{
				document.getElementById('molData').value = msg['structure'];	
				$("#searchSubmit").attr('value', 'Searching...');
				$("#searchSubmit").html('Searching...');
				$('#searchForm').submit();
			}
		}).fail(function(msg) {
			swal("","No structure found; please try again.","warning");
		}).always(function(){
			// nothing for now
		});
	});
}
</script>
</div>

<div class="regSearchForm">
<form method="post" action="showRegHits.asp" id="searchForm">
<input type="hidden" name="molData" id="molData" value="">
<input type="button" name="searchSubmit" id="searchSubmit" onclick="searchSubmitFunction();" value="<%=searchLabel%>">
</form>
</div>
</div>
<!-- #include file="../_inclds/footer-tool.asp"-->
