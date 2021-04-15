<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	ssoFolderName = getCompanySpecificSingleAppConfigSetting("ssoFolderPathName", Session("companyId"))
	maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
	rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
%>

<script>
	// This is a copied function from experimentSaveButtons.asp.
	function clickSign() {
		$("#signDivSignButton").prop("disabled", true);
		try {
			unsavedChanges=false;
		} catch(err) {
			$("#signDivSignButton").prop("disabled", false);
		}
		if ("<%=experimentType%>" == "5") {
			experimentSubmit(false, true, false, undefined, $("#requestId").val(), $("#requestRevisionId").val());
		} else {
			experimentSubmit(false,true,false);
		}
	}
	
	// This is also a copied function from experimentCommonJS.asp

function ssoSign()
{
	err = false;
	if ($("#requesteeIdBox").val() == -2 && $("#ssoSignStatusBox").val() == "2") {
		swal("Please select a Witness");
		err = true;
	}
	
	if (!document.getElementById("ssoVerify").checked)
	{
		alert("Please click reviewed to continue.");
		err = true;
	}
	
	el = document.getElementById("ssoSignStatusBox");
	keepOpen = el.options[el.selectedIndex].value;
	el = document.getElementById("requesteeIdBox")
	requesteeId = el.options[el.selectedIndex].value;
	
	if (requesteeId == "-1")
		requesteeId = "0";

	if(keepOpen=="1")
		keepOpenFlag = "1"
	else
		keepOpenFlag = "0"

	if(!err)
	{
		killIntervals();
		hidePopup("ssoSignDiv");
		keyString = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
		var signAuthUrl = "https://<%=rootAppServerHostName%><%=ssoFolderName%>sign.asp?state=SIGN&key="+keyString;
		console.log('signAuthUrl: ' + signAuthUrl);
		window.signingPopupWindow = window.open(signAuthUrl,"_blank");
		// Successful sign-in will call the experimentSubmit function to finalize the signing
		showPopup('ssoTokenDiv');

		// Looking at other tabs doesnt work for IE11
		var isIE11 = !!window.MSInputMethodContext && !!document.documentMode;
		
		window.repeatedlyCheckIfSigningPopupWindowClosed = setInterval(function(){
			
			if (checkForSSOKeyCookie(keyString)){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				ssoSignFinalize(keyString);

			}else if(window.signingPopupWindow.closed && !isIE11){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				//Double check to make sure that we didn't pick up on the closing of the window before we noticed the cookie
				if (checkForSSOKeyCookie(keyString)){
					ssoSignFinalize(keyString);
				}
			}
			else if(!$('#ssoTokenDiv').is(':visible')){
				window.signingPopupWindow.close();
			}
		},200);
	}
}

/**
* Grabs the cookie and kicks off the sign of the experiment, then deletes the cookie
* @param {string} cookieId - A random string used to find the unique cookie (does not include "ssoKey")
*/
function ssoSignFinalize(cookieId){
	pattern = new RegExp("(?:(?:^|.*;\\s*)ssoKey" + cookieId + "\\s*\\=\\s*([^;]*).*$)|^.*$");
	cookieValue = document.cookie.match(pattern);

	if (cookieValue[1] == "sign"){
		experimentSubmit(false,true,false, undefined, undefined, undefined);
	}else if (cookieValue[1] == "type5"){
		// Better check to make sure the signing statuses are checked properly.
		if (!["4", "5"].includes(experimentStatusId)) {
			experimentSubmit(false,true,false, undefined, $("#requestId").val(), $("#requestRevisionId").val());
		} 
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

function ssoCoAuthorSign()
{
	err = false;
	if (!document.getElementById("ssoCoAuthorVerify").checked)
	{
		alert("Please click reviewed to continue.");
		err = true;
	}
	
	el = document.getElementById("ssoCoAuthorSignStatusBox");
	keepOpen = el.options[el.selectedIndex].value;
	requesteeId = "0";

	if(keepOpen=="1")
		keepOpenFlag = "1"
	else
		keepOpenFlag = "0"

	if(!err)
	{
		killIntervals();
		hidePopup("ssoCoAuthorSignDiv");
		keyString = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
		var signAuthUrl = "https://<%=rootAppServerHostName%><%=ssoFolderName%>sign.asp?state=SIGN&key="+keyString;
		console.log('signAuthUrl: ' + signAuthUrl);
		window.signingPopupWindow = window.open(signAuthUrl,"_blank");
		// Successful sign-in will call the addCoAuthorSignature function to finalize the signing
		showPopup('ssoTokenDiv');
		var isIE11 = !!window.MSInputMethodContext && !!document.documentMode;
		window.repeatedlyCheckIfSigningPopupWindowClosed = setInterval(function(){
			if (checkForSSOKeyCookie(keyString)){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				addCoAuthorSignature();
			}else if(window.signingPopupWindow.closed && !isIE11){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				//Double check to make sure that we didn't pick up on the closing of the window before we noticed the cookie
				if (checkForSSOKeyCookie(keyString)){
					addCoAuthorSignature();
				}
			}
			else if(!$('#ssoTokenDiv').is(':visible')){
				window.signingPopupWindow.close();
			}
		},200);
	}
}

</script>
<%'5 - signed - closed, 6 - witnessed, 10 - pending abandonment, 11 - abandoned
If CStr(revisionNumber)=CStr(maxRevisionNumber) And (ownsExperiment(experimentType,experimentId,session("userId")) or isCoAuthor) And statusId<>5 And statusId<>6 And statusId <> 10 And statusId <> 11 then%>
		<%
			pdfRevisionId = revisionNumber
			experimentTypeName = GetAbbreviation(experimentType)
		%>
		<%If hasUnsavedChanges then%>
			<a href="javascript:void(0);" onclick="alert('Experiment cannot be signed with unsaved changes.  Please return to experiment view and save.');return false;" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
		<%else%>
			<%If (Not session("useGoogleSign")) And (Not session("useSAFE")) And (Not session("hasCrais")) Then%>
				<% if session("isSsoUser") then%>
					<a href="javascript:void(0);" onclick="showPopup('ssoSignDiv');return false;" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
				<% else %>
					<%If Not (session("hasInventoryIntegration") Or session("hasCompoundTracking")) then%>
						<a href="javascript:void(0);" onclick="showPopup('signDiv');return false;" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
					<%End if%>
				<% End if %>
			<%End if%>
		<%End if%>		
<%End if%>