<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header-frame.asp"-->
<style type="text/css">@import url(js/jscalendar/calendar-win2k-1.css);</style>
<script type="text/javascript" src="js/jscalendar/calendar.js"></script>
<script type="text/javascript" src="js/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="js/jscalendar/calendar-setup.js"></script>
<script type="text/javascript" src="js/arxOne.js"></script>
<script type="text/javascript" src="js/getFile.js"></script>
<script type="text/javascript" src="js/advancedSearch.js"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->

<script type="text/javascript">
	function loadSearch() {
		return new Promise(function (resolve, reject) {
			finalizeSearch();
			makeMongoQuery('<%=request.querystring("chemistryFrameId")%>', '<%=request.querystring("chemTable")%>', ['<%=request.querystring("chemSearchDbName")%>', '<%=request.querystring("chemSearchDbName2")%>']).then(function (retVal) {
				resolve(retVal);
			});
		});
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