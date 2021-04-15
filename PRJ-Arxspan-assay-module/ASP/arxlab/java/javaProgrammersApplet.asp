<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%'412015%>

<script type="text/javascript">
function doCheckOut_chrome(attachmentId, experimentType){
	
	//check if its a chemistry cdx file or experiment attachment
	if (attachmentId.split("_").length > 1 && attachmentId.split("_")[1].length > 0){
		attId = attachmentId.split("_")[0];
		document.getElementById('checkInChrome_'+attId+'_cdx').style.display='inline';
		document.getElementById('discardChrome_'+attId+'_cdx').style.display='inline';
		document.getElementById('checkOutChrome_'+attId+'_cdx').style.display='none';
		console.log("upload reaction class :: "+$("#uploadReaction").attr("class"));
		$.get( "<%=mainAppPath%>/experiments/ajax/do/setChemExperimentCDXCheckedOut.asp", {"state":"1","experimentId":attachmentId.split("_")[0],"experimentType":experimentType}, function(){
			updateBottomButtons(experimentJSON.thisRevisionNumber);
			reInitializeDropZone();
		} );
		$("#uploadReaction").css("display","none")
	}
	else{
		document.getElementById('checkInChrome_'+attachmentId).style.display='inline';
		document.getElementById('discardChrome_'+attachmentId).style.display='inline';
		document.getElementById('checkOutChrome_'+attachmentId).style.display='none';
		$.get( "<%=mainAppPath%>/experiments/ajax/do/setAttachmentCheckedOut.asp", {"state":"1","attachmentId":attachmentId,"experimentType":experimentType}, function(){
			updateBottomButtons(experimentJSON.thisRevisionNumber);
			reInitializeDropZone();
		});
		//reloadAttachmentTable();
	}
	
	return false;
}

function doCheckIn_chrome(attachmentId, experimentType){
	if (attachmentId.split("_").length > 1 && attachmentId.split("_")[1].length > 0){
		$("#uploadReaction").css("disaply", "in-line");
		$.get( "<%=mainAppPath%>/experiments/ajax/do/setChemExperimentCDXCheckedOut.asp", {"state":"0","experimentId":attachmentId.split("_")[0],"experimentType":experimentType}, function(){
			updateBottomButtons(experimentJSON.thisRevisionNumber);
			reInitializeDropZone();
		} );
	}else{
		$.get( "<%=mainAppPath%>/experiments/ajax/do/setAttachmentCheckedOut.asp", {"state":"0","attachmentId":attachmentId,"experimentType":experimentType}, function(){
			updateBottomButtons(experimentJSON.thisRevisionNumber);
			reInitializeDropZone();
		} );
		
		reloadAttachmentTable();
		//Check for the extension and native messaging host and show the buttons accordingly 9/8/16
		
	liveEditor.addInstalledCallback(function(args) {
			console.log("btnDisplayCheck...");
			$(".liveEdit").addClass("makeVisible");
			$(".noLiveEdit").hide();
			return true;
		}, {});
		
		//return false;
	}
	
}

function doDiscard_chrome(attachmentId, experimentType){
	if (attachmentId.split("_").length > 1 && attachmentId.split("_")[1].length > 0){
		$.get( "<%=mainAppPath%>/experiments/ajax/do/setChemExperimentCDXCheckedOut.asp", {"state":"0","experimentId":attachmentId.split("_")[0],"experimentType":experimentType}, function(){
			updateBottomButtons(experimentJSON.thisRevisionNumber);
			reInitializeDropZone();
		} );
		document.getElementById('checkInChrome_'+attachmentId.split("_")[0]+'_cdx').style.display='none';
		document.getElementById('discardChrome_'+attachmentId.split("_")[0]+'_cdx').style.display='none';
		document.getElementById('checkOutChrome_'+attachmentId.split("_")[0]+'_cdx').style.display='inline';
		document.getElementById('uploadReaction').style.display='inline';
		
	}else{
		$.get( "<%=mainAppPath%>/experiments/ajax/do/setAttachmentCheckedOut.asp", {"state":"0","attachmentId":attachmentId,"experimentType":experimentType}, function(){
			updateBottomButtons(experimentJSON.thisRevisionNumber);
			reInitializeDropZone();
		} );
		reloadAttachmentTable();
		//Check for the extension and native messaging host and show the buttons accordingly 9/8/16
		
		liveEditor.addInstalledCallback(function(args) {
				console.log("btnDisplayCheck...");
				$(".liveEdit").addClass("makeVisible");
				$(".noLiveEdit").hide();
				return true;
			}, {});
			
		//return false;
	}
}
</script>
<%'/412015%>