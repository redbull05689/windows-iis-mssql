<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
	Select Case isBatchForAdd
		Case True
			theLink = regPath&"/showBatch.asp?regNumber="&request.querystring("regNumber")
		Case False
			theLink = regPath&"/showReg.asp?regNumber="&request.querystring("regNumber")
	End Select
	theLink = "<a href='"&theLink&"' target='_new'>"&request.querystring("regNumber")&"</a>"
	easyLink = regPath&"/showRegItem.asp?regNumber="&request.querystring("regNumber")
	easyLink = "<a href='"&easyLink&"' target='_new'>"&request.querystring("regNumber")&"</a>"
%>
<script type="text/javascript">
	function showInventoryPopupAddReg(){

		molData = document.getElementById("molDataForAdd").value;
		trivialName = "<%=request.querystring("regNumber")%>";
		

		document.getElementById("inventorySearchFrame").src = '<%=mainAppPath%>/inventory2/index.asp?inFrame=true&addFromReg=true&link='+encodeURIComponent("<%=theLink%>")+"&trivialName="+trivialName+"&molData="+encodeURIComponent(molData)+"&regId="+encodeURIComponent(trivialName);
		showPopup("inventoryPopup");
	}
	function addInventoryLinks(links){
		cdId = document.getElementById("cdIdForAdd").value;
		getFile("addInventoryLinks.asp?cdId="+cdId+"&links="+links);
		getRegInventoryLinks();
	}
	function showInventoryPopupBulkAddReg(regIds){
		document.getElementById("inventorySearchFrame").src = '<%=mainAppPath%>/inventory2/index.asp?inFrame=true&bulkAddFromReg=true&fieldToHide=registrationId&values='+regIds+'&link='+encodeURIComponent("<%=easyLink%>");
		showPopup("inventoryPopup");
	}
	function showInventoryPopupBulkMoveReg(regIds){
		document.getElementById("inventorySearchFrame").src = '<%=mainAppPath%>/inventory2/index.asp?inFrame=true&bulkMoveRegItems=true&fieldName=registrationid&values='+regIds+'&labelName=Registration Ids';
		showPopup("inventoryPopup");
	}
</script>
<%'inventory div%>
<div style="width:850px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0px;z-index:101;" id="inventoryPopup" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopup('inventoryPopup',true);return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif" style="border:none;"></a>
<iframe id="inventorySearchFrame" style="border:none;" width="850" height="800" src="<%=mainAppPath%>/static/blank.html"></iframe>
</div>