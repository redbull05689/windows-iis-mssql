<%'signing div%>
<div id="signDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Sign Experiment</div>
<form name="sign_form" method="post" action="sign-experiment.asp" OnSubmit="return false;" class="popupForm" z-index="-1">
	<section>
		<label for="signEmail">Email</label>
		<input type="text" id="signEmail" name="signEmail" value="" style="box-sizing: content-box;">
	</section>
	<section>
		<label for="password"><%If session("companyId") <> "4" then%><%=passwordLabel%><%else%>Employee Id<%End if%></label>
		<input type="password" name="password" id="password" value=""  autocomplete="off" style="box-sizing: content-box;">
	</section>
	<section>
		<label for="signStatusBox" class="select-style-label">Status</label>
		<div class="select-style">
			<select name="signStatusBox" id="signStatusBox" style='margin-top:3px;' onchange="if(this.options[this.selectedIndex].value == 1){document.getElementById('requesteeIdBoxDiv').style.display='none'}else{document.getElementById('requesteeIdBoxDiv').style.display='block'}">
				<option value="2">Sign and Close</option>
				<option value="1">Sign and Keep Open</option>
			</select>
		</div>
	</section>
	<section>
		<div id="witnessListLoadingMessage">Loading witness list...</div>
		<div id="requesteeIdBoxDiv">
		</div>
	</section>
	<input type="hidden" name="requesteeId" id="requesteeId" value="">
	<section class="bottomDisclaimer">
		<div>
		<input type="checkbox" name="verify" id="verify" class="<%If bCheck<>"IE 8.0" Then%>css-checkbox<%else%>css-checkbox-ie8<%End if%>">
		<label for="verify" class="css-label checkboxLabel" style="font-size:12px!important;font-weight:normal;max-width:300px;margin-bottom:40px;">Checking this box and entering your <%If session("companyId") <> "4" then%>password<%else%>employee id<%End if%> indicates that you have performed the work as described.</label>
		</div>
	</section>

	<input type="hidden" name="signStatus" id="signStatus" value="">

	<section id="signDivButtons" class="bottomButtons checkbox">
		<button id="signDivSignButton" onclick="clickSign();">Sign</button>
		<button onclick="hidePopup('signDiv');">Cancel</button>
	</section>

	<input type="hidden" name="verifyState" id="verifyState" value="">
	<input type="hidden" name="experimentId" value="<%=experimentId%>">
	<input type="hidden" name="typeId" id="typeId" value="<%=experimentType%>">
	<input type="hidden" name="sign" id="sign" value="true">
</form>
</div>

<%
'sso signing div
%>
<div id="ssoSignDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Sign Experiment</div>
<form name="sign_form" method="post" action="sign-experiment.asp" OnSubmit="return false;" class="popupForm">
	<section>
		<label for="ssoSignStatusBox" class="select-style-label">Status</label>
		<div class="select-style">
			<select name="ssoSignStatusBox" id="ssoSignStatusBox" style='margin-top:3px;' onchange="if(this.options[this.selectedIndex].value == 1){document.getElementById('ssoRequesteeIdBoxDiv').style.display='none'}else{document.getElementById('ssoRequesteeIdBoxDiv').style.display='block'}">
				<option value="2">Sign and Close</option>
				<option value="1">Sign and Keep Open</option>
			</select>
		</div>
	</section>
	<section>
		<div id="ssoWitnessListLoadingMessage">Loading witness list...</div>
		<div id="ssoRequesteeIdBoxDiv">
		</div>
	</section>
	<input type="hidden" name="requesteeId" id="requesteeIdSSO" value="">
	<section class="bottomDisclaimer">	
		<input type="checkbox" name="ssoVerify" id="ssoVerify" class="<%If bCheck<>"IE 8.0" Then%>css-checkbox<%else%>css-checkbox-ie8<%End if%>">
		<label for="ssoVerify" class="css-label checkboxLabel" style="font-size:12px!important;font-weight:normal;max-width:300px;margin-bottom:40px;">Checking this box and entering your <%If session("companyId") <> "4" then%>authentication credentials<%else%>employee id<%End if%> indicates that you have performed the work as described.</label>
	</section>
	<section id="ssoSignDivButtons" class="bottomButtons buttonAlignedRight">
		<button onclick="try{unsavedChanges=false;}catch(err){} ssoSign();">Sign</button>
		<button onclick="hidePopup('ssoSignDiv');">Cancel</button>
	</section>

	<input type="hidden" name="verifyState" id="verifyState" value="">
	<input type="hidden" name="experimentId" value="<%=experimentId%>">
	<input type="hidden" name="ssoTypeId" id="ssoTypeId" value="<%=experimentType%>">
	<input type="hidden" name="ssoSignValue" id="ssoSignValue" value="true">
	<input type="hidden" name="isSsoCompany" id="isSsoCompany" value="<%=LCase(companyUsesSso())%>">
	<input type="hidden" name="isSsoUser" id="isSsoUser" value="<%=LCase(session("isSsoUser"))%>">
</form>
</div>

<%
'sso auth div
%>
<div id="ssoTokenDiv" class="popupDiv popupBox">
	<div class="popupFormHeader">Sign/Witness Experiment</div>
	<div class="popupFormContent popupFormContentCentered">
		Please verify your identity using the SSO popup page.
		<hr class="popupHR">
		If you don't see the login window/tab, it may have been blocked by your browser.
	</div>
</div>


<div id="abandonmentDiv" class="popupDiv popupBox">
<div class="popupFormHeader"><%=experimentNotPursuedLabel%></div>
<form name="abandon_form" method="post" action="abandonExperiment.asp" OnSubmit="return false;" class="popupForm" z-index="-1">
	<section id="emailSection">
		<label for="signEmail">Email</label>
		<input type="text" id="signEmail" name="signEmail" value="" style="box-sizing: content-box;">
	</section>
	<section id="passwordSection">
		<label for="password"><%If session("companyId") <> "4" then%><%=passwordLabel%><%else%>Employee Id<%End if%></label>
		<input type="password" name="password" id="password" value=""  autocomplete="off" style="box-sizing: content-box;">
	</section>
	<section>
		<div id="abanWitnessListLoadingMessage">Loading witness list...</div>
		<div id="abanRequesteeIdBoxDiv">
		</div>
	</section>
	<input type="hidden" name="requesteeId" id="requesteeId" value="">
	<section class="reasonSection">
		<label for="abandonReasonBox" style="float: left;">Reason</label>
		<textarea name="abandonReasonBox" id="abandonReasonBox" rows="9" cols="25" style="margin-left:10px;width: 234px;margin-top: 0px;"></textarea>
	</section>
	<section class="bottomDisclaimer">
		<div>
		<input type="checkbox" name="aVerify" id="aVerify" class="<%If bCheck<>"IE 8.0" Then%>css-checkbox<%else%>css-checkbox-ie8<%End if%>">
		<label for="aVerify" class="css-label checkboxLabel" style="font-size:12px!important;font-weight:normal;max-width:300px;margin-bottom:40px;"><%=experimentNotPursuedWarningLabel%></label>
		</div>
	</section>

	<input type="hidden" name="signStatus" id="signStatus" value="">

	<section id="abanSignDivButtons" class="bottomButtons checkbox">
		<button id="aSsoSignDivSignButton" style="display:none;" onclick="ssoAbandonSign();">Sign</button>
		<button id="aSignDivSignButton" onclick="abandonExperimentSubmit();">Sign</button>
		<button onclick="hidePopup('abandonmentDiv');">Cancel</button>
	</section>

	<input type="hidden" name="verifyState" id="verifyState" value="">
	<input type="hidden" name="experimentId" value="<%=experimentId%>">
	<input type="hidden" name="typeId" id="typeId" value="<%=experimentType%>">
	<input type="hidden" name="abandon" id="abandon" value="true">
</form>
</div>