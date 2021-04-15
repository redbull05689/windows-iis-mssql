<script type="text/javascript">
	var statusId = "<%=statusId%>";	
	var isCurrRev = "<%=currentRevisionNumber = maxRevisionNumber%>" == "True";
	var canWrite = "<%=canWrite%>" == "True" && ["5", "6"].indexOf(statusId) < 0 && isCurrRev;
</script>
<script src="/arxlab/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
