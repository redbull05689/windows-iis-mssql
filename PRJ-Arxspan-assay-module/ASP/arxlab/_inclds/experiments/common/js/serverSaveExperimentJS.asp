<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

if (typeof waitPopulate === 'undefined') {
	window.waitPopulate = function() {
		return new Promise(function(resolve,reject) { 
			console.log("DEFAULT WAIT POP");
			resolve(''); 
		});
	}
}

//
//
//	
function cancelOverlays() {
	hidePopup('savingDiv');
	hideOverMessage("savingDraft");
	hideOverMessage("networkProblem");
	hideOverMessage("networkProblem2");
}

function getSaveSerial()
{
	return hungSaveSerial;
}

//
//
//	
function doServerSaveExperiment(theURL,theData,signFlag,timeout,retryCnt, afterSaveCallbackFn) {
	afterSaveCallbackFn = afterSaveCallbackFn || function(){};

	console.log("EXP SERVER SAVE, theURL: ",theURL," theData: ",theData," signFlag: ",signFlag);

	// default values
	var retries = 3;
	var timeoutMillis = 300000;
	
	if (typeof timeout !== 'undefined') {
		timeoutMillis = timeout;
	}

	if (typeof retryCnt !== 'undefined') {
		retries = retryCnt;
	}
	
	console.log("EXP SERVER SAVE, TIMEOUT: ",timeoutMillis," RETRIES: ",retries);
	
	$.ajax({
		url: theURL,
		type: "POST",
		data: theData,
		contentType: "application/x-www-form-urlencoded; charset=iso-8859-1",
		dataType : 'json',
		tryCount : 0,
		thisRevisionNumber : experimentJSON["thisRevisionNumber"],
		retryLimit : retries,
		cache: false,
		succeeded: false,
		doShow: false,
		dontRefresh: false,
		sign: signFlag,
		success: function(data)
		{
			console.log("save returns: ", data);
			hungSaveSerial = data["hungSaveSerial"]; //set the HSS to the new one from the server
			experimentJSON["hungSaveSerial"] = hungSaveSerial;
			experimentJSON["thisRevisionNumber"] = data["revisionNumber"]; //set the revisionNumber to the new one from the server
			draftHasUnsavedChanges = false;
			unsavedChanges = false;
			hideUnsavedChanges();
			this.thisRevisionNumber = experimentJSON["thisRevisionNumber"];
			
			var draftSaveUrl = "/arxlab/experiments/ajax/do/saveDraft.asp?experimentId="+experimentId+"&experimentType="+experimentType;
			
			// checks for a WorkFlow variable defined outside function scope
			if (typeof canWrite !== 'undefined' && canWrite) {
				draftSaveUrl += "&c=" + true;
			}

			//This updates the draft set unsavedChanges to false
            $.post( draftSaveUrl, {thePairs: JSON.stringify([{}])});
			
			if (typeof setChemDrawChanged !== 'undefined') {
				hasChemdraw().then(function(isInstalled) {
					if(isInstalled) {
						setChemDrawChanged(false);
					}
				});
			}
			
			//Update history table
			getFileA('<%=mainAppPath%>/ajax_loaders/nav/experimentHistory.asp?id=<%=request.querystring("id")%>&revisionId=<%=rId%>&subSectionId=<%=subSectionId%>&draftHasUnsavedChanges=False&random='+Math.random(),function(r){document.getElementById('navRecentHistoryHolder').innerHTML = r;delayedRunJS(r);});
			
			//Update the popup divs for replace attachments
			replacePopupDivStr = getFile('<%=mainAppPath%>/ajax_doers/popupDivsToReplaceAttachments.asp?<%=PID%>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand='+Math.random());
			
			document.getElementById("replacingFiles").innerHTML = replacePopupDivStr;
			
			//Reset the "Unsaved Changes" in any text fields		
			if(lastTextFieldChanged != undefined)
			{
				editCheckStart(lastTextFieldChanged);
			}
			
			//Clear UAStates 
			if (typeof UAStates !== 'undefined') {
				UAStates = {};
			}
			
			//flag for complete callback
			this.doShow = true;
			this.succeeded = true;
		},
		error: function(error, textStatus, errorThrown)
		{
			if (textStatus == 'timeout') {
				console.log("SERVER SAVE, TIMEOUT");
				this.tryCount++;
				if (this.tryCount <= this.retryLimit) {
					//try again
					if (this.tryCount == 1) {
						showOverMessage("networkProblem");
					}else{
						showOverMessage("networkProblem2");
					}
					this.timeout *= 2;
					$.ajax(this);
					document.getElementById("hungSaveForm").hungSaveSerial = getSaveSerial();
					document.getElementById("hungSaveForm").submit();	
				}else{
					console.error("ERROR ", error);
					swal("Save Timeout", "Please try your request again.", "error");
						this.doShow=true;
				}
			} else if (textStatus == 'parsererror'){
				console.log("PARSE ERROR");
				if(error.responseText == "processing")
				{
					console.log("SERVER SAVE, PROCESSING PREVIOUS REQUEST");
					this.tryCount++;
					if (this.tryCount <= this.retryLimit) {
						//try again
						if (this.tryCount == 1) {
							showOverMessage("networkProblem");
						}else{
							showOverMessage("networkProblem2");
						}
						this.timeout *= 2;
						console.log("RETRYING SAVE, this.tryCount: ",tryCount," timeout: ",this.timeout, " retryLimit: ",retryLimit);
						$.ajax(this);
						document.getElementById("hungSaveForm").hungSaveSerial = getSaveSerial();
						document.getElementById("hungSaveForm").submit();	
					}
					else{
						console.error("ERROR ", error);
						swal("Save Timeout", "Please try your request again.", "error");
						this.doShow=true;
					}
				}
				else
				{
					var errorText = $("<div/>").html(error.responseText).text();
 					
					// Step into this block if the cust-saveExperiment script determines that we're missing workflow IDs.
					// We're doing this up here before the sweet alert is called to make sure that this gets logged.
					if (errorText == "Error saving request data.") {

						// Package up some info to write into the aspErrors table.
						var custErrorJson = {
							isCoAuthor: "<%=checkCoAuthors(experimentId, experimentType, """")%>",
							reqId: experimentJSON.requestId,
							reqRev: experimentJSON.workflowRevisionId,
							isSsoUser: "<%=session("isSsoUser")%>",
							ssoCompany: "<%=companyUsesSso()%>",
						};
						logCustExpError(custErrorJson);
					}

					this.dontRefresh = true;
					this.doShow=true;
					console.log("save error! ", error);
					swal({
						"title": "Sorry",
						"text": errorText,
						"type": "error"
					},
					function () {
						if (errorText == "Invalid email or password") {
							location.reload() // reloading the page because after the user enters an incorrect pw, a correct pw refreshes the page w/out signing
						}
					})
					$('body').append(error.responseText);
				}
			}else{
				console.error("ERROR ", error);
				cancelOverlays();
				swal({
					"title":"ERROR!",
					"type":"error",
					"text":errorThrown + "\n Reload of page is required.\nIf problems persist, please contact Arxspan Support."
					},
					function() {
						location.reload();
					}
				);
				return(false);
			}
		},
		complete: function()
		{
			console.log("RUNNING COMPLETE CB sign: ",this.sign," this: ",this);

			if(this.succeeded && this.sign && (!this.dontRefresh || refreshPageAfterSave)){
				location.reload(); //After signing, this will show the dashboard with the "Your PDF is being processed" message
				hidePopup('signDiv');
				return(true);
			}
			
			if (this.doShow) {
				cancelOverlays();
			}
			
			if (this.succeeded) {
				hasChemdraw().then(function(isInstalled) {
					if(isInstalled) {
						forceReactionRefresh = true;
					}
					else {
						forceReactionRefresh = false;
					}

					waitPopulate(forceReactionRefresh, this.thisRevisionNumber).then(function(){
						console.log("WAIT POP RESOLVED");
						updateAttachments();
						updateNotes();
						unsavedChanges = false;
						updateBottomButtons(experimentJSON["thisRevisionNumber"]);
						$("#lean_overlay").hide();
						afterSaveCallbackFn();
						return(true);
					});
				});
			}

			return true;
		},
		timeout:timeoutMillis
	});
}

/**
 * Packages up the given data into a string and makes an Ajax call to log it, along with the current page we're on.
 * @param data {JSON} The data to send.
 */
function logCustExpError(data) {
	var dataDescription = "CUST ERR: ";
	var dataDescArray = Object.keys(data).map(function(key) {return key + ": " + data[key]});

	var logData = {
		location: window.top.location.pathname + window.top.location.search, 
		description: dataDescription + dataDescArray.join("|"),
	};
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: "/arxlab/ajax_doers/logCustExpError.asp",
			type: "POST",
			data: logData,
		}).then(function(resp) { resolve(resp); });
	});
}