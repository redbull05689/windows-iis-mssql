<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header-frame.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
inventoryIgnoreTableFields = checkBoolSettingForCompany("ignoreTableFieldsInInventory", session("companyId"))
%>
<style type="text/css">@import url(js/jscalendar/calendar-win2k-1.css);</style>
<script src='js/jquery-1.11.1.js?<%=jsRev%>' type="text/javascript"></script>
<script type="text/javascript" src="js/jscalendar/calendar.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jscalendar/lang/calendar-en.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jscalendar/calendar-setup.js?<%=jsRev%>"></script>

<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/arxOne.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/getFile.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/promisePolyfill.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/advancedSearch.js?<%=jsRev%>"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="/arxlab/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<script src="<%=mainAppPath%>/js/promisePolyfill.min.js?<%=jsRev%>"></script>

<script type="text/javascript">
<%If session("useChemDrawForLiveEdit") Then%>
	useChemDrawForLiveEdit = true;
<%End If%>
hasMarvin = <%=LCase(CStr(session("useMarvin")))%>
</script>

<script type="text/javascript">
ignoreTableFields = false;
<%if inventoryIgnoreTableFields then%>
ignoreTableFields = true;
<%end if%>
</script>

<script type="text/javascript">
function loadSearch(){
    return new Promise(function (resolve, reject) {
        finalizeSearch();
        makeMongoQuery('<%=request.querystring("chemistryFrameId")%>', '<%=request.querystring("chemTable")%>', '<%=request.querystring("chemSearchDbName")%>').then(function (retVal) {
            resolve(retVal);
        });
    });
}

function loadSearchVars(){
	return ['<%=request.querystring("chemistryFrameId")%>','<%=request.querystring("chemTable")%>','<%=request.querystring("chemSearchDbName")%>'];
}


</script>

<div id="advancedSearchHolder">
	<span>Advanced Search</span>
	<a href="#" style="display:none;" id="dummyA"></a>
	<a href="javascript:void(0);" onclick="newGroup()" id="newGroupLink" title="Add Group"><img src="images/add.gif" style="margin-top:3px;" /></a>
	<input type="hidden" value="submitted" name="advancedSearchSubmitted">
	<input type="hidden" name="fieldsForSearch" id="fieldsForSearch" value="">
	<input type="hidden" name="savedSearchForSearch" id="savedSearchForSearch" value="">
	<input type="hidden" name="molData" id="molData" value="<%=molData%>">
</div>
<!-- #include file="_inclds/footer-frame.asp"-->