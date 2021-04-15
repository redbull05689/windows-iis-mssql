<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<script type="text/javascript">
	attachmentJSON = [];
	attachmentTableTimeStamps = [];

	/**
	 * This function is used in experiment attachment table to save the hidden value for including the uploaded file in PDF or not.
	 * @param {string} key - The id of the hidden field
	 */
	function saveHiddenVal(key) {
		unsavedChanges = true;
		
		var hidden = $("#"+key).is(":checked");
		return sendAutoSave(key+"InPdf", hidden);
	}

    /**
	 * This function is used in experiment attachment table to check out an attachment.
	 * @param {string} attachmentId - The id of the attachment
	 * @param {int} experimentType - The experiment type
	 * @param {string} extension - The extension of the attachment
	 */
	function attachmentCheckOut(attachmentId, experimentType, extension, experimentId)
	{
		liveEditor.setIsCheckedOutCallback(function(msg, args) {
			console.log("Hide Checkout btn and show checkin btn..");
			doCheckOut_chrome(msg['attachmentId'], msg['experimentType']);
		}, {});
		
		unsavedChanges = true;		
		sendAutoSave('experimentId', experimentId);

		window.postMessage({
			message_type: 'checkout',
			url: window.location.protocol + '//' + window.location.hostname + '/arxlab/experiments/ajax/load/getSourceFile.asp?id='+attachmentId+'&experimentType='+experimentType,
			cookies: document.cookie,
			attachmentId: attachmentId,
			experimentType: experimentType,
			ext: extension},
			'*');
	}

	/**
	 * This function is used in experiment attachment table to check in an attachment.
	 * @param {int} experimentId - The experiment id
	 * @param {int} experimentType - The experiment type
	 * @param {int} attachmentId - The attachment id
	 * @param {string} attachmentFileName - The attachment file name
	 * @param {string} attachmentName - The name of the attachment
	 * @param {string} attachmentDescription - The attachment description
	 * @param {int} attachmentSort - The sort order for the attachment table
	 * @param {string} attachmentFolder - The attachment folder
	 * @param {string} extension - The attachment extension
	 */
	function attachmentCheckIn(experimentId, experimentType, attachmentId, attachmentFileName, attachmentName, attachmentDescription, attachmentSort, attachmentFolder, extension)
	{
		attachmentFileName = encodeIt(attachmentFileName)
		attachmentName = encodeIt(attachmentName)
		attachmentDescription = atob(attachmentDescription)
		attachmentDescription = encodeIt(attachmentDescription)
		unsavedChanges = true;
		
		liveEditor.setReceivingDataCallback(function (msg, theArgs) {
			if ($('#Loading_'+msg['attachmentId'])[0].style.display == "none"){
				$('#Loading_'+msg['attachmentId'])[0].style.display="inline";
			}
		}, {});
		
		liveEditor.setCheckInUploadCallback(function (msg, uploadFileData, theArgs) {
			//See if the file has been changed
			var uploadMD5 = md5(_base64ToArray(uploadFileData)).toUpperCase();
			
			var oReq = new XMLHttpRequest();
			oReq.addEventListener("load", function(){
				var sourceMD5 = this.responseText;
				if (sourceMD5 == uploadMD5){
          			swal({
						title: "File Unchanged",
						text: "Looks like you are trying to check in an unchanged file. Are you sure?",
						type: "warning",
						showCancelButton: true,
						confirmButtonColor: "#DD6B55",
						confirmButtonText: "Check In",
						cancelButtonText: "Cancel",
					}, function (isConfirm) {
						if (isConfirm) {
							checkinUploadCallbackPart2(msg, uploadFileData, theArgs);
						} else {
							setTimeout(function(){
								swal({
									title: "Canceled",
									text: "Check In Cancled",
									type: "info",
									timer: 2000
								});
							},200); //If I don't have the timeout, both sweet alerts get killed at the same time
						}
					});
				}else{
					checkinUploadCallbackPart2(msg, uploadFileData, theArgs);
				}
				
			});
			oReq.open("GET", window.location.protocol + '//' + window.location.hostname + '/arxlab/experiments/ajax/load/getFileMD5.asp?id='+attachmentId+'&experimentType='+experimentType);
			oReq.send();

			var checkinUploadCallbackPart2 = function(msg, uploadFileData, theArgs){
				buf = _base64ToArrayBuffer(uploadFileData);
				var http = new XMLHttpRequest();
				
				formData = new FormData();
				var blob = new Blob([buf], {type : "text/plain"});
				//check if its a chemistry cdx file or experiment attachment
				if ((msg['attachmentId']).split("_").length > 1){
					formData.append(msg['attachmentId'], blob);
					unsavedChanges=false;
					//rxnSubmit();
					waitForRXN(); //maybe?
				}
				else {
					formData.append('file1_'+msg['attachmentId'], blob, msg['filename']);
					
					formData.append('fileLabel', msg['filelabel']);
					formData.append('description', Encoder.htmlEncode(msg['description']));
					formData.append('sortOrder', msg['sortOrder']);
					//url = "/arxlab/experiments/upload-file.asp?PID=12ED929112DF442E&experimentId=27323&experimentType=2&attachmentId=139762&path=F1/F2/F3/&random=0.3735362"
					//Need to get this from native messaging host variable but as a work around getting it from the URL
					formData.append('path', ((msg['url'].split("&"))[4].split("="))[1]);
				}
				
				http.onreadystatechange = function () {
					if (this.readyState == 4 && this.status == 200) {
						var response = this.responseText;
						//post the message to delete the file
						if ((msg['attachmentId']).split("_").length > 1){
							window.postMessage({ message_type: 'delete', file: msg.experimentType + '-' + msg.attachmentId}, '*');
						}else{
							window.postMessage({ message_type: 'delete', file: msg.experimentType + '-' + msg.attachmentId + msg.ext}, '*');
						}
						
						//Update the status of the file and toggle the buttons
						doCheckIn_chrome(msg['attachmentId'], msg['experimentType']);
					}
				}
				http.open("POST", msg['url'], false);
				//http.onprogress = updateProgress;
				http.send(formData);
				if ($('#Loading_'+msg['attachmentId']).length != 0 && $('#Loading_'+msg['attachmentId'])[0].style.display == "inline"){
					$('#Loading_'+msg['attachmentId'])[0].style.display="none";  
				}
			};
			
		});

		unsavedChanges = true;
		//call unsavedChangesCheck now to make sure the unsaved changes flag gets added to top of screan 
		unsavedChangesCheck();
		sendAutoSave('experimentId', experimentId);
		
		window.postMessage({
			message_type: 'checkin',
			url: window.location.protocol + "//" + window.location.hostname + "/arxlab/experiments/upload-file.asp?PID=12ED929112DF442E&experimentId=" + experimentId + "&experimentType="+ experimentType +"&attachmentId=" + attachmentId + "&path=&random=" + Math.random().toString(),
			filename: attachmentFileName,
			filelabel: attachmentName,
			attachmentId: attachmentId,
			description: attachmentDescription,
			experimentType: experimentType,
			sort: attachmentSort,
			folderId: attachmentFolder,
			chunk: 1,
			ext: extension
			}, '*');
	}

/* ELN-1137 : document.ready is not working ie because console.log(...) isn't defined in IE unless the dev tools are enabled*/
if (typeof console === "undefined") {
    console={};
    console.log = function(){};
}

/**
 * This function is used in experiment attachment table to show/hide the inline view of the attachment content.
 * @param {string} dataId - The file id of the attachment
 */
function toggleNodeViewInlineAttachment(dataId){
	var tree = $("#sortable").fancytree("getTree");
	node = tree.getActiveNode();
	/* Check if we have to add a node or delete the node - toggle the view */
	refNode =  tree.getNodeByKey(dataId);
	if (refNode){
		refNode.remove();
	}
	else {
		$("body").css("cursor", "progress");
		chemImagePromise = [];
		if (typeof window[dataId+"_getChemImage"] === "function") {
    		chemImagePromise.push(window[dataId+"_getChemImage"]());
		}
		Promise.all(chemImagePromise).then(function(values) {
  			fancytreeShowAttachment(dataId);
			trVal = $('#'+dataId).html();
			newData = {title: "New Node", trVal: "<td colspan='7'>"+trVal+"</td>", trId: dataId, key:dataId};
			newSibling = node.appendSibling(newData);
			$("body").css("cursor", "default");
		});

	}
}

/**
 * Helper function to create a unique list.
 * @param {array} list - The original list
 */
function uniqueArray(list) {
	var result = [];
	$.each(list, function(i, e) {
		if ($.inArray(e, result) == -1) result.push(e);
	});
	return result;
}

/**
 * Helper function to sort an array by a given key.
 * @param {array} array - The array to sort
 * @param {string} key - The key for sorting
 */
function sortByKey(array, key) {
	return array.sort(function(a, b) {
		var x = parseInt(a[key]); 
		var y = parseInt(b[key]);
		return ((x < y) ? -1 : ((x > y) ? 1 : 0));
		/*
		var sortVal = 0;
		$("#tree tbody tr.attRow .sortOrder").each(function () {
			sortVal += 1;
			$(this).val(sortVal);
			if(typeof sendAutoSave !== "undefined"){
				unsavedChanges = true;
				sendAutoSave($(this).attr("id"), sortVal);
			}
		});
		*/
	});
}	

/**
* Helper function to pop a child from an array of node objects.
* @param {object} child - The child node
* @param {array} nodes - Array of node objects
*/
function popChild(child, nodes) {
    for (var i = 0; i < nodes.length; i++) {
        if (nodes[i].folderId == child.folderId) {
			nodes.splice(i, 1);
			break;
        }
    }
}

/**
* Helper function to get the parent of a child node from an array of node objects.
* @param {object} child - The child node
* @param {array} nodes - Array of node objects
 */
function getParent(child, nodes) {
    var parent = null;
	for (var i = 0; i < nodes.length; i++) {
        if (nodes[i].folderId == child.parentFolderId) {
            return nodes[i];
        }
    }
	return parent;
}	

/**
 * Helper function to get a child node of a given parent node from an array of node objects.
 * @param {object} parent - The parent node
 * @param {array} nodes - Array of node objects
 * @param {object} child - The default child to return if it doesn't find a child from the given parent
 */
function getChild(parent, nodes, child) {
	var child = child;
	var found = false;
	for (var j = 0; j < nodes.length; j++){
		var obj = (nodes[j]);
		if (obj.parentFolderId == parent.folderId) {
			found = true;
			child = obj;
			return getChild(obj, nodes, child);
			break;
		}
	}
	if(found == false){
		return child;
	}
}
</script>
