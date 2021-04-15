<script>

    /**
     * Submit abandon request to be processed 
     */
	function abandonExperimentSubmit()
	{
		killIntervals();
		var experimentId = <%=experimentId%>;
		if (typeof(experimentJSON) == "undefined") {
			var experimentJSON = {};
		}
		experimentJSON["experimentId"] = experimentId;
		experimentJSON["notebookId"] = "<%=notebookId%>";	// Need double-quotes around the variable since it would crash when it is an empty string.
		experimentJSON["hungSaveSerial"] = "<%=hungSaveSerial%>";

		if (!document.getElementById("aVerify").checked){
			swal("Error", decodeDoubleByteString("<%=notPursuedVerificationErrorLabel%>"), "error");
			return;
		}
		
		var requesteeValue = document.getElementById("requesteeIdBox").options[document.getElementById("requesteeIdBox").selectedIndex].value;
		if (requesteeValue == -2) {
			swal("Error", decodeDoubleByteString("<%=selectWitnessLabel%>"), "error");
			return;
		}

        var reasonVal = document.getElementById("abandonReasonBox").value;
        if (!reasonVal) {
            swal("Error", "Please enter a reason.", "error");
			return;
        }

		hidePopup("abandonmentDiv");
		showPopup("savingDiv");

		var abandonmentType = "full";
		if (parseInt(statusId) != 10 && requesteeValue != -1) {
			abandonmentType = "pending";
		}
		else if (parseInt(statusId) == 10) {
			abandonmentType = "witness"
		}

		experimentJSON["signEmail"] = document.getElementById("signEmail").value;
		experimentJSON["password"] = document.getElementById("password").value;
		experimentJSON["typeId"] = document.getElementById("typeId").value;
		experimentJSON["signStatus"] = document.getElementById("signStatusBox").options[document.getElementById("signStatusBox").selectedIndex].value;
		experimentJSON["requesteeId"] = requesteeValue;
		experimentJSON["e_name"] = "<%=experimentName%>";
		experimentJSON["abandonmentType"] = abandonmentType;
		experimentJSON["experimentType"] = experimentType;
        experimentJSON["reason"] = reasonVal;

		var requestTypeId = $("#requestTypeId").val();
		if (requestTypeId) {
			experimentJSON["requestTypeId"] = requestTypeId;
		}
		
		if(document.getElementById("isSsoUser").value === "true" && document.getElementById("ssoSignValue").value === "true" && document.getElementById("isSsoCompany").value === "true") {
			experimentJSON["password"] = "";
			experimentJSON["signEmail"] = "";
			experimentJSON["typeId"] = document.getElementById("ssoTypeId").value;
			experimentJSON["signStatus"] = document.getElementById("ssoSignStatusBox").options[document.getElementById("ssoSignStatusBox").selectedIndex].value;
			experimentJSON["requesteeId"]  = requesteeValue;
			experimentJSON["verifyState"] = document.getElementById("ssoVerify").checked;
		}
		
		experimentJSON["hungSaveSerial"] = "<%=hungSaveSerial%>";

		console.log("Json Before Save: ", experimentJSON);
		$.ajax({
			url: "<%=mainAppPath%>/experiments/abandonExperiment.asp",
			data: {hiddenExperimentJSON: JSON.stringify(experimentJSON)},
			type: "POST"
		}).done(function(res) {

			console.log(res);
			hidePopup("savingDiv");
			
			if (res != "Success") {
				swal("Warning", res);
			} else {
				window.location = "dashboard.asp?id=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=revisionNumber+1%>";
			}
		}).fail(function(res)  {
			console.warn("Abandonment Error: ", res);
			swal("Error", "Something went wrong. Please try again.", "error");
		}); 
	}


	/**
     * Show the correct abandon dialog
     * @param {bool} isWitness is this the witness dialog 
     */
	function abandonExperiment(isWitness = false) {
		const companySSOStatus = "<%=companyUsesSso()%>";
		const ssoUser = "<%=session("isSsoUser")%>";

		if (companySSOStatus === "True" && ssoUser === "True") {
			showAbandonPopup("ssoSignDiv", isWitness);
		} else {
			showAbandonPopup("signDiv", isWitness);
		}
	}

    /**
     * Show abandon popup
     * @param {string} signingProcess sso vs normal signing div
     * @param {bool} isWitness is this the witness dialog 
     */
    function showAbandonPopup(signingProcess, isWitness){
        if ((signingProcess == 'signDiv' || signingProcess == 'ssoSignDiv')){
            signButtonsDiv = "abanSignDivButtons";
            requesteeDivName = 'abanRequesteeIdBoxDiv';
            loadingMessageDiv = "abanWitnessListLoadingMessage";
            if(signingProcess == 'ssoSignDiv') {
                signButtonsDiv = "abanSsoSignDivButtons";
                //sso does not need email and PW
                $("#emailSection").hide();
                $("#passwordSection").hide();
                // and we need to display correct signing btn
                $("#aSignDivSignButton").hide()
                $("#aSsoSignDivSignButton").show()
            }
            
            $("#"+signButtonsDiv).hide();
            $("#"+loadingMessageDiv).show();
            
            try{
                if (!(experimentId === parseInt(experimentId))){
                    if(experimentId==undefined){
                        experimentId = document.getElementById("experimentId").value;
                        experimentType = document.getElementById("experimentType").value;
                    }else if(experimentId == parseInt(experimentId)){	
                        experimentId = parseInt(experimentId);
                        experimentType = parseInt(experimentType);
                    }else{
                        experimentId = experimentId.value;experimentType = experimentType.value;
                    }
                }
            }catch(err){
                experimentId = document.getElementById("safeExperimentId").value;
                experimentType = document.getElementById("safeExperimentType").value;			
            }

            if (typeof(revisionId) == "undefined")
            {
                //get revision id out of url 
                var url = window.location.href;
                var name = "revisionNumber"
                name = name.replace(/[\[\]]/g, "\\$&");
                var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
                    results = regex.exec(url);
                if (!results) return null;
                if (!results[2]) return '';
                revisionId = decodeURIComponent(results[2].replace(/\+/g, " "))

            }
            
            $.ajax({
                type: "GET",
                async: true,
                url: 'ajax_loaders/getWitnessList.asp?experimentId='+experimentId+"&experimentType="+experimentType+"&r="+revisionId+"&random="+Math.random()
            })
            .done(function(response) {
                document.getElementById(requesteeDivName).innerHTML = response;
                $("#"+loadingMessageDiv).hide();
                $("#"+signButtonsDiv).show();
                
                if(experimentType != 5 && experimentType != '5') {
                    loadedWitnessList = true;
                }
                if (isWitness) {
                    $("#requesteeIdBox").val(-1);
                    $("#abanRequesteeIdBoxDiv").hide();
                }
            })
            .fail(function(response) {
                document.getElementById(requesteeDivName).innerHTML ="<label for='requesteeIdBox'>Witness</label><select name='requesteeIdBox' id='requesteeIdBox' style='width:220px;'><option value='-2'>--Please select a Witness--</option><option value='-1'>--Not Pursued--</option><option value='"+defaultWitnessId+"' SELECTED>"+defaultWitnessName+"</option></select>"
            })
            .always(function() {
                document.getElementById("modalDummy").setAttribute("href",'#abandonmentDiv');
                document.getElementById("modalDummy").click();
            });	
        }
    }

	/**
	 * Uses sso login for auth check. 
	 */
    function ssoAbandonSign() {
        killIntervals();
		hidePopup("ssoSignDiv");
		keyString = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
		var signAuthUrl = "https://<%=rootAppServerHostName%><%=ssoFolderName%>sign.asp?state=SIGN&key="+keyString;
		console.log('signAuthUrl: ' + signAuthUrl);
		window.signingPopupWindow = window.open(signAuthUrl,"_blank");
		showPopup('ssoTokenDiv');

		// Looking at other tabs doesnt work for IE11
		var isIE11 = !!window.MSInputMethodContext && !!document.documentMode;
		
		window.repeatedlyCheckIfSigningPopupWindowClosed = setInterval(function(){
			
			if (checkForSSOKeyCookie(keyString)){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				ssoSignFinalize(keyString, true);
			}else if(window.signingPopupWindow.closed && !isIE11){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				//Double check to make sure that we didn't pick up on the closing of the window before we noticed the cookie
				if (checkForSSOKeyCookie(keyString)){
					ssoSignFinalize(keyString, true);
				}
			}
			else if(!$('#ssoTokenDiv').is(':visible')){
				window.signingPopupWindow.close();
			}
		},200);
    }

</script>