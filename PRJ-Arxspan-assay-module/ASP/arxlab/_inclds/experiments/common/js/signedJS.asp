<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	ssoFolderName = getCompanySpecificSingleAppConfigSetting("ssoFolderPathName", Session("companyId"))
%>
<script type="text/javascript">
try{unsavedChanges = false;}catch(err){}

function ssoWitness()
{
	<%
	'take form and put the whole form into the hidden iframe for background saving
	rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
	%>
	hidePopup("ssoWitnessSignDiv");
	keyString = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
	var witnessAuthUrl = "https://<%=rootAppServerHostName%><%=ssoFolderName%>sign.asp?state=WITNESS&key="+keyString;
	window.witnessPopupWindow = window.open(witnessAuthUrl,"_blank");
	// Successful sign-in will submit the witness form and set this original window's URL to successfulWitnessRedirectURL
	<%if session("fromWitnessRequestList") then%>
	window.successfulWitnessRedirectURL = "<%=mainAppPath%>/table_pages/show-witnessRequests.asp";
	<%else%>
	window.successfulWitnessRedirectURL = "<%=mainAppPath%>/dashboard.asp?id=<%=request.querystring("id")%>&experimentType=<%=request.querystring("experimentType")%>&revisionNumber=<%=request.querystring("revisionNumber")+1%>&witness=1"
	<%end if%>
	showPopup('ssoTokenDiv');

	// Looking at other tabs doesnt work for IE11
	var isIE11 = !!window.MSInputMethodContext && !!document.documentMode;
	window.repeatedlyCheckIfWitnessPopupWindowClosed = setInterval(function(){
		if (checkForSSOKeyCookie(keyString)){
			hidePopup('ssoTokenDiv');
			clearInterval(window.repeatedlyCheckIfWitnessPopupWindowClosed);
			ssoWitnessFinalize(keyString);

		}else if(window.witnessPopupWindow.closed && !isIE11){
			hidePopup('ssoTokenDiv');
			clearInterval(window.repeatedlyCheckIfWitnessPopupWindowClosed);
			//Double check to make sure that we didn't pick up on the closing of the window before we noticed the cookie
			if (checkForSSOKeyCookie(keyString)){
				ssoWitnessFinalize(keyString);
			}
		}
		else if(!$('#ssoTokenDiv').is(':visible')){
			window.witnessPopupWindow.close();
		}
	},200);

	return false;
}

/**
* Grabs the cookie data and kicks off the witness of the experiment, then deletes the cookie
* @param {string} cookieId - A random string used to find the unique cookie (does not include "ssoKey")
*/
function ssoWitnessFinalize(cookieId){
	pattern = new RegExp("(?:(?:^|.*;\\s*)ssoKey" + cookieId + "\\s*\\=\\s*([^;]*).*$)|^.*$");
	cookieValue = document.cookie.replace(pattern, "$1");

	if (cookieValue == "witness"){
		document.getElementById("ssoWitnessForm").submit();
		document.location.href = window.successfulWitnessRedirectURL;
	}

	//Delete cookie
	document.cookie = "ssoKey" + cookieId + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
}

/**
* Looks at the cookies for the ssoKey
* @param {string} cookieId - A random string used to find the unique cookie (does not include "ssoKey")
* @return {Boolean} True if cookie found. False if not found
*/
function checkForSSOKeyCookie(keyVal){
	if (document.cookie.split(';').filter(function(item) {
		return item.trim().indexOf("ssoKey" + keyString + "=") == 0
	}).length) {
		return true;
	}
	return false;
}

/**
 * Denies a witness request
 * @param {bool} flag for witnessing 'pending abandonment' experiments
 */
function denyWitness(abandonExperiment = false)
{
	var abandonExperimentFlag = abandonExperiment;
	var wForm = document.getElementById("denyForm");
	var theReason;

	// pull out the appropriate reason based on
	if (abandonExperiment) {
		theReason = document.getElementById("abandonRejectReasonBox").value;
	} else {
		 theReason = document.getElementById("reasonBox").value;
		}

	// reason is required for denying and rejecting an experiment
	if (theReason.trim().length < 1)
	{
		swal("Invalid Rejection Reason","Rejection Reason is required.");
		return;
	}
	$.ajax({
		url: $(wForm).attr("action"),
		type: $(wForm).attr("method"),
		cache: false,
		data: {
			experimentId: $(wForm).find('input[name="experimentId"]').val(),
			experimentType: $(wForm).find('input[name="experimentType"]').val(),
			requestId: $(wForm).find('input[name="requestId"]').val(),
			reason: theReason,
			abandonExperiment: abandonExperimentFlag,
		},
		success: function(data)
		{
			swal("Completed", "Rejecting complete." , "success");//strip the html and just alert the text 
			window.location = "dashboard.asp"
		},
		error: function(error, textStatus, errorThrown)
		{
			console.log("witness deny error! ", error);
			swal("Sorry", $("<div/>").html(error.responseText).text() , "error");//strip the html and just alert the text 
		},
		complete: function()
		{
			<%if session("fromWitnessRequestList") then%>
			window.location = "table_pages/show-witnessRequests.asp";
			<%else%>
			window.location = "dashboard.asp?id=<%=request.querystring("id")%>&experimentType=" + $(wForm).find('input[name="experimentType"]').val() + "&revisionNumber=<%=request.querystring("revisionNumber")+1%>&witness=1&reject=1"
			<%end if%>
		}
	 });
}

function reopen()
{
	var wForm = document.getElementById("denyForm");
	var theReason = document.getElementById("reasonBox2").value;

	// reason is required for reopening an experiment
	if (theReason.trim().length < 1)
	{
		swal("Invalid Reason","Reopening Reason is required.");
		return;
	}
	
	$.ajax({
		url: "<%=mainAppPath%>/experiments/denyWitness.asp?reopen=true",
		type: $(wForm).attr("method"),
		cache: false,
		data: {
			experimentId: $(wForm).find('input[name="experimentId"]').val(),
			experimentType: $(wForm).find('input[name="experimentType"]').val(),
			requestId: $(wForm).find('input[name="requestId"]').val(),
			reason: theReason,
		},
		success: function(data)
		{
			swal("Completed", "Reopening complete." , "success");//strip the html and just alert the text 
			window.location = "dashboard.asp"
		},
		error: function(error, textStatus, errorThrown)
		{
			console.log("reopen error! ", error);
			swal("Sorry", $("<div/>").html(error.responseText).text() , "error");//strip the html and just alert the text 
		},
		complete: function()
		{
		}
	 });
}

function requestNewWitness()
{
	console.log("submitNewWitnessRequestForm SUBMIT!!");
	
	<%
	'take form and put the whole form into the hidden iframe for background saving
	%>
	var wForm = $("#submitNewWitnessRequestForm");
	
	$.ajax({
		url: $(wForm).attr("action"),
		type: $(wForm).attr("method"),
		data: $(wForm).serialize(),
		dataType: "json",
		cache: false,
		success: function(data)
		{
			swal("Completed", "Request Sent" , "success");
		},
		error: function(error, textStatus, errorThrown)
		{
			console.log("witnessForm error");
			swal("Sorry", $("<div/>").html(error.responseText).text() , "error");
		},
		complete: function()
		{
		}
	 });

	return false;
}

$(document).ready(function() {
	$("#witnessForm").submit(function(e) {
		<%
		'take form and put the whole form into the hidden iframe for background saving
		%>
		e.preventDefault();
		$("#witnessSubmitButton").prop("disabled", true);
		
		$.ajax({
			url: $(this).attr("action"),
			type: $(this).attr("method"),
            data: $(this).serialize(),
			dataType: "json",
			cache: false,
			success: function(data)
			{
				console.log("witnessForm success");
				console.log("witnessForm complete");
				<%if session("fromWitnessRequestList") then%>
				window.location = "table_pages/show-witnessRequests.asp";
				<%else%>
				window.location = "dashboard.asp?id=" + data.experimentId + "&experimentType=" + data.experimentType + "&revisionNumber=" + (parseInt(data.revisionNumber) + 1) + "&witness=1"
				<%end if%>
			},
			error: function(error, textStatus, errorThrown)
			{
				console.log("witnessForm error");
				$("#witnessSubmitButton").prop("disabled", false);
				swal("Sorry", $("<div/>").html(error.responseText).text() , "error");//strip the html and just alert the text 
			},
			complete: function()
			{
				$(this).disabled = false;
			}
		 });

		 return false;
	});
});


function addCoAuthorSignature() {
	$("#coAuthorSignDivSignButton").prop("disabled", true);
	var userId = "<%=session("userId")%>"
	var userEmail = document.getElementById("signCoAuthorEmail").value;
	var pass = document.getElementById("coAuthorPassword").value;
	var signed = $("#coAuthorVerify").is(":checked") || $("#ssoCoAuthorVerify").is(":checked");

	if (!signed) {
		$("#coAuthorSignDivSignButton").prop("disabled", false);
		swal("Review", "You must review this experiment before signing!", "warning");
		return false;
	}
	
	$.ajax({
		url: "ajax_doers/addCoAuthSignature.asp",
		type: "POST",
		data: {
			userId: userId,
			email: userEmail,
			pass: pass,
			expId: experimentId,
			expType: experimentType,
			expRev: revisionNumber,
			sso: "<%=session("isSsoUser")%>"
		}
	 }).done(function(response) {
		 window.location.href = "dashboard.asp?id=" + experimentId + "&experimentType=5&revisionNumber=" + revisionNumber;
	 }).fail(function(response) {
		$("#coAuthorSignDivSignButton").prop("disabled", false);
		 swal("Invalid User Credentials", "The username or password provided are incorrect. Please try again.", "error");
	 });
}
</script>