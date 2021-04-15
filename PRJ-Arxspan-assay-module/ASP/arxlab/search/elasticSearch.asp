<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->


<%
	hasAnalExperiment = getCompanySpecificSingleAppConfigSetting("hasAnalyticalExperiments", session("companyId"))
	hasFreeExperiment = getCompanySpecificSingleAppConfigSetting("hasFreeExperiments", session("companyId"))

    Set expDefaultRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT useDefaultExperimentTypes FROM companySettings WHERE companyId="&SQLClean(session("companyId"),"T","S")
	expDefaultRec.open strQuery,conn,0,-1
	
	loadDefaultExperiments = True
	If Not expDefaultRec.eof Then
		If expDefaultRec("useDefaultExperimentTypes") = 0 Or expDefaultRec("useDefaultExperimentTypes") = "0" Then
			loadDefaultExperiments = False
		End If
	End If

    expDefaultRec.close

	' 6933 - Split the requestTypeNames string without forcibly turning the ASP var into a JS var using quotation marks
	' to allow request type names to use whatever quote types they want in request type names.
	requestTypeNamesArr = split(session("requestTypeNames"), ",")
	set requestTypeNamesJSONList = JSON.parse("[]")

	for each requestTypeName in requestTypeNamesArr
		requestTypeNamesJSONList.push(requestTypeName)
	next
    
%>

<link href="<%=mainAppPath%>/search/elasticSearch/jQuery-QueryBuilder-2.4.3/css/query-builder.dark.min.css" rel="stylesheet" type="text/css">
<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" crossorigin="anonymous">
<link href="<%=mainAppPath%>/search/elasticSearch/nobootstrap.css" rel="stylesheet" type="text/css">

<script type="text/javascript">
hasMarvin = <%=LCase(CStr(session("useMarvin")))%>;
var interfaceLanguage = '<%=interfaceLanguage%>';
var loadDefaultExperiments = "<%=loadDefaultExperiments%>" == "True";
var hasChem = '<%=session("hasChemistry")%>' == 'True';
var hideNonCollab = '<%=session("hideNonCollabExperiments")%>' == 'True';
var hasMUF = '<%=session("hasMUFExperiment")%>' == 'True';
var hasFree = '<%=hasFreeExperiment%>' == '1';
var hasAnal = '<%=hasAnalExperiment%>' == '1';
var requestTypeIdsStr = "<%=session("requestTypeIds")%>";
var requestTypeNames = <%=JSON.stringify(requestTypeNamesJSONList)%>;
var requestTypeIds = requestTypeIdsStr.split(",");

</script>
<!-- Libs -->
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/jquery-3.2.1.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/bootstrap-3.3.7-dist/js/bootstrap.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/doT.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/jQuery.extendext.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/moment.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/jQuery-QueryBuilder-2.4.3/js/query-builder.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/_inclds/experiments/chem/js/getRxn.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/query-builder-elasticsearch.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/defiant.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/imgCrop.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/encoder.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>



<div>
<h1><%=advancedSearchLabel%></h1>

<div id="builder"></div>

<button id="btn-get-es" class="query-builder btn btn-xl btn-search" data-target="basic">Search</button>

<span id="pageCount" style="float: right;"></span>


</div>
<br />
<table class="experimentsTable elasticTable" id="elasticExperimentsTable" style="display:none">

</table>
<table class="experimentsTable" id="elasticPagingTable" style="display:none">
    <tbody id="pagingTableBody">

    </tbody>
</table>

<div id="JSONoutputdiv">
</div>

<script>
	var hasChem = '<%=session("hasChemistry")%>' == 'True';
	var hideNonCollab = '<%=session("hideNonCollabExperiments")%>' == 'True';
	var hasMUF = '<%=session("hasMUFExperiment")%>' == 'True';
	var hasFree = '<%=hasFreeExperiment%>' == '1';
	var hasAnal = '<%=hasAnalExperiment%>' == '1';
	
	var jwt = "<%=session("jwtToken")%>";
</script>

<!-- Main Logic Here (needs to go at the end) -->
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch.js?<%=jsRev%>"></script>
<script type="text/javascript">
	<%If session("useChemDrawForLiveEdit") Then%>
		useChemDrawForLiveEdit = true;
	<%End If%>
</script>

<!-- #include file="../_inclds/footer-tool.asp"-->
