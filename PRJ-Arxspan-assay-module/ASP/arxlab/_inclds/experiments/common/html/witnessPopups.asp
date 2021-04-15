<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<div id="witnessSignDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Witness Experiment</div>
<form name="sign_form" method="post" action="<%=mainAppPath%>/experiments/ajax/do/witness.asp" target="submitFrame"  id="witnessForm" class="popupForm">
	<section>
		<label for="signEmail">Email</label>
		<input type="text" id="signEmail" name="signEmail" value="">
	</section>
	<section>
		<label for="password"><%If session("companyId") <> "4" then%><%=passwordLabel%><%else%>Employee Id<%End if%></label>
		<input type="password" name="password" id="password" value="" autocomplete="off">
	</section>
	<section class="bottomDisclaimer">	
		<input type="checkbox" name="verify" id="verify2" class="<%If bCheck<>"IE 8.0" Then%>css-checkbox<%else%>css-checkbox-ie8<%End if%>">
		<label for="verify2" class="css-label checkboxLabel" style="font-size:12px!important;font-weight:normal;max-width:300px;margin-bottom:40px;">*Checking this box and entering your <%If session("companyId") <> "4" then%>password<%else%>employee id<%End if%> indicates that you have reviewed the work as described.</label>
	</section>
	<section class="bottomButtons checkbox">
		<button id="witnessSubmitButton">Witness</button>
		<button onclick="this.disabled=true;hidePopup('witnessSignDiv');" id="witnessSubmitCancelButton">Cancel</button>
	</section>
	<input type="hidden" name="experimentId" value="<%=experimentId%>">
	<input type="hidden" name="experimentType" value="<%=experimentType%>">
	<input type="hidden" name="sign" id="sign" value="true">
</form>
</div>

<div id="ssoWitnessSignDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Witness Experiment</div>
<form name="sso_witness_form" method="post" action="<%=mainAppPath%>/experiments/ajax/do/witness.asp" target="submitFrame"  id="ssoWitnessForm" class="popupForm">
	<section class="bottomDisclaimer">
		<input type="checkbox" name="ssoWitnessVerify" id="ssoWitnessVerify" class="<%If bCheck<>"IE 8.0" Then%>css-checkbox<%else%>css-checkbox-ie8<%End if%>">	
		<label for="ssoWitnessVerify" class="css-label checkboxLabel" style="font-size:12px!important;font-weight:normal;max-width:300px;margin-bottom:40px;">Checking this box and entering your authentication credentials indicates that you have reviewed the work as described.</label>
	</section>
	<section class="bottomButtons checkbox">
		<button onclick="this.disabled=true;ssoWitness()" id="witnessSubmitButtonSSO">Witness</button>
		<button onclick="this.disabled=true;hidePopup('ssoWitnessSignDiv');" id="witnessSubmitCancelButton2SSO">Cancel</button>
	</section>
	<input type="hidden" name="experimentId" value="<%=experimentId%>">
	<input type="hidden" name="experimentType" value="<%=experimentType%>">
	<input type="hidden" name="ssoWitnessValue" id="ssoWitnessValue" value="true">
</form>
</div>

<div id="reasonDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Reject Witness</div>
<form name="deny_form" method="post" action="<%=mainAppPath%>/experiments/denyWitness.asp" OnSubmit="return false;" class="popupForm">
	<section class="popupTextareaSection">
		<label for="noteText">Please Enter a Reason for Rejecting (required)</label>
		<textarea name="reasonBox" id="reasonBox" rows="9" cols="25" style="margin-left:10px;width:200px;" onkeyup="enterReasonForReopenOrReject(document.getElementById('reasonBox').value, 'rejectSubmitButton')"></textarea>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<button onclick="denyWitness()" id="rejectSubmitButton">Reject</button>
	</section>
</form>
</div>

<div id="reopenDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Reopen Experiment</div>
<form name="reopenform" method="post" action="<%=mainAppPath%>/experiments/denyWitness.asp?reopen=true" OnSubmit="return false;" class="popupForm">
	<section class="popupTextareaSection">
		<label for="noteText">Please Enter a Reason for Reopening (required)</label>
		<textarea name="reasonBox" id="reasonBox2" rows="9" cols="25" style="margin-left:10px;width:200px;" onkeyup="enterReasonForReopenOrReject(document.getElementById('reasonBox2').value, 'reopenSubmitButton')"></textarea>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<button onclick="reopen()" disabled id="reopenSubmitButton">Reopen</button>
	</section>
</form>
</div>

<div id="coAuthorSignDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Sign Experiment</div>
<form name="sign_form" method="post" action="sign-experiment.asp" OnSubmit="return false;" class="popupForm" z-index="-1">
	<section>
		<label for="signCoAuthorEmail">Email</label>
		<input type="text" id="signCoAuthorEmail" name="signCoAuthorEmail" value="" style="box-sizing: content-box;">
	</section>
	<section>
		<label for="coAuthorPassword"><%If session("companyId") <> "4" then%><%=passwordLabel%><%else%>Employee Id<%End if%></label>
		<input type="password" name="coAuthorPassword" id="coAuthorPassword" value=""  autocomplete="off" style="box-sizing: content-box;">
	</section>
	<section class="bottomDisclaimer">
		<div>
		*Checking this box and entering your <%If session("companyId") <> "4" then%>password<%else%>employee id<%End if%> indicates that you have performed the work as described.
		</div>
	</section>

	<section class="bottomButtons checkbox">	
		<input type="checkbox" name="coAuthorVerify" id="coAuthorVerify" class="<%If bCheck<>"IE 8.0" Then%>css-checkbox<%else%>css-checkbox-ie8<%End if%>">
		<label for="coAuthorVerify" class="css-label checkboxLabel">Reviewed*</label>
		<button id="coAuthorSignDivSignButton" onclick="addCoAuthorSignature()">Sign</button>
	</section>

	<input type="hidden" name="coAuthorVerifyState" id="coAuthorVerifyState" value="">
	<input type="hidden" name="coAuthorExperimentId" id="coAuthorExperimentId" value="<%=experimentId%>">
	<input type="hidden" name="coAuthorTypeId" id="coAuthorTypeId" value="<%=experimentType%>">
	<input type="hidden" name="coAuthorSign" id="coAuthorSign" value="true">
</form>
</div>

<div id="ssoCoAuthorSignDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Sign Experiment</div>
<form name="sign_form" method="post" action="sign-experiment.asp" OnSubmit="return false;" class="popupForm">
	<section>
		<label for="ssoCoAuthorSignStatusBox" class="select-style-label">Status</label>
		<div class="select-style">
			<select name="ssoCoAuthorSignStatusBox" id="ssoCoAuthorSignStatusBox" style='margin-top:3px;' onchange="if(this.options[this.selectedIndex].value == 1){document.getElementById('ssoRequesteeIdBoxDiv').style.display='none'}else{document.getElementById('ssoRequesteeIdBoxDiv').style.display='block'}">
				<option value="2">Sign and Close</option>
				<option value="1">Sign and Keep Open</option>
			</select>
		</div>
	</section>
	<section>
		<div id="ssoCoAuthorRequesteeIdBoxDiv">
		</div>
	</section>
	<input type="hidden" name="ssoCoAuthorRequesteeIdBox" id="ssoCoAuthorRequesteeIdBox" value="">
	<section class="bottomDisclaimer">	
		<input type="checkbox" name="ssoCoAuthorVerify" id="ssoCoAuthorVerify" class="<%If bCheck<>"IE 8.0" Then%>css-checkbox<%else%>css-checkbox-ie8<%End if%>">
		<label for="ssoCoAuthorVerify" class="css-label checkboxLabel" style="font-size:12px!important;font-weight:normal;max-width:300px;margin-bottom:40px;">Checking this box and entering your <%If session("companyId") <> "4" then%>authentication credentials<%else%>employee id<%End if%> indicates that you have performed the work as described.</label>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<button onclick="try{unsavedChanges=false;}catch(err){} ssoCoAuthorSign();">Sign</button>
		<button onclick="hidePopup('ssoCoAuthorSignDiv');">Cancel</button>
	</section>

	<input type="hidden" name="verifyState" id="verifyState2" value="">
	<input type="hidden" name="experimentId" value="<%=experimentId%>">
	<input type="hidden" name="ssoTypeId" id="ssoTypeId2" value="<%=experimentType%>">
	<input type="hidden" name="ssoSignValue" id="ssoSignValue2" value="true">
	<input type="hidden" name="isSsoCompany" id="isSsoCompany2" value="<%=LCase(companyUsesSso())%>">
	<input type="hidden" name="isSsoUser" id="isSsoUser2" value="<%=LCase(session("isSsoUser"))%>">
</form>
</div>
<div id="rejectAbandonReasonDiv" class="popupDiv popupBox">
<div class="popupFormHeader"><%=rejectNotPursuedLabel%></div>
<form name="deny_form" method="post" action="<%=mainAppPath%>/experiments/denyWitness.asp" OnSubmit="return false;" class="popupForm">
	<section class="popupTextareaSection" style="padding-bottom: 9px;">
		<label for="noteText"><%=notPursuedReasonLabel%></label>
		<br>
		<textarea name="abandonReasonBox" id="abandonRejectReasonBox" rows="9" cols="25" style="margin-left:10px;width:90%;" onkeyup="enterReasonForReopenOrReject(document.getElementById('abandonReasonBox').value, 'rejectSubmitButton')"></textarea>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<button onclick="denyWitness(true)" id="rejectSubmitButton">Reject</button>
	</section>
</form>
</div>