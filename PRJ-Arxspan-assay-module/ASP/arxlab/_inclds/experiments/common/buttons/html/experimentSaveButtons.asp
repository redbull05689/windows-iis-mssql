<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../functions/fnc_getWorkflowRequestId.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include virtual="/arxlab/_inclds/experiments/common/js/abandonExperimentFncs.asp"-->

<%
companyHasMoveExperimentButton = getCompanySpecificSingleAppConfigSetting("canMoveExperiments", session("companyId"))
elnWebsiteUrl = getCompanySpecificSingleAppConfigSetting("elnWebsiteUrl", session("companyId"))
prefix = GetPrefix(experimentType)
expPage = GetExperimentPage(prefix)

If currentRevisionNumber = maxRevisionNumber then%>
	<%
		If revisionId = "" Then
			pdfRevisionId = getExperimentRevisionNumber(experimentType,experimentId)
			currentFlag = True
		Else
			pdfRevisionId = revisionId
		End if		
		If ( ownsExperiment(experimentType,experimentId,session("userId")) or isCoAuthor) and (experimentType <> 5 or canWrite) Then
		%>
		<a href="javascript:void(0);" onclick="clickSave();" class="createLink"><%=saveButtonLabel%></a>
		<% checkedOutFiles = getListOfCheckedOutFiles(experimentType,experimentId)%>
		<%if checkedOutFiles <> "" then%>
			<a href="#" class="createLink" onclick="swal('Please Check-In or Discard Checked-Out Files', 'Currently Checked Out: <%=checkedOutFiles%>' , 'error');" id="signExperimentButton"><%=signExperimentButtonLabel%></a>	
		<%elseIf session("useSAFE") And Not session("useGoogleSign") then%>
			<%safeSignFileName = uploadRoot & "\" & expUserId & "\" & experimentId & "\" & pdfRevisionId & "\" & experimentTypeName & "\sign-sign.pdf"%>
			<%
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			If fs.fileexists(safeSignFileName) Then
			%>
				<a href="signed.asp?id=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=pdfRevisionId%>&safeVersion=true" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
			<%else%>
				<%If session("softToken") then%>
					<%craisError = false
					If session("hasCrais") And experimentType="1" then
						If craisStatusId=3 Or craisStatusId=0 Then
							craisError = True
						End if
					End if%>
					<%If Not craisError then%>
						<%if (session("hasInventoryIntegration")) And experimentType=1 then%>
							<script type="text/javascript">
								inventoryAddArguments['mainAppPath'] = "<%=mainAppPath%>";
								inventoryAddArguments['expId'] = "<%=experimentId%>";
								inventoryAddArguments['expType'] = "<%=experimentType%>";
								inventoryAddArguments['pdfRevisionNumber'] = "<%=pdfRevisionId%>";
								inventoryAddArguments['makeSafeVersion'] = "false";
								inventoryAddArguments['fromSign'] = "true";
								inventoryAddArguments['useSafeSigning'] = "<%=session("useSAFE")%>";
								inventoryAddArguments['useSso'] = "<%=companyUsesSso() And session("isSsoUser")%>";
							</script>
							<a href="javascript:void(0);" onclick="validateBarcodes();" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
						<%else%>
							<a href="<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=pdfRevisionId%>&makeSafeVersion=false&fromSign=true" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
						<%End if%>
					<%else%>
							<a href="javascript:void(0)" onclick="alert('Experiment cannot be signed without passing regulatory check.')"  class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
					<%End if%>
				<%End if%>
			<%
			End If
			Set fs = nothing
			%>
		<%else%>
			<%If session("useGoogleSign") then%>
				<a href="<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=pdfRevisionId%>&makeSafeVersion=false&fromSign=true" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
			<%else%>
				<%craisError = false
				If session("hasCrais") And experimentType="1" then
					If craisStatusId=3 Or craisStatusId=0 Then
						craisError = True
					End if
				End if%>
				<%If Not craisError then%>
					<%If (session("hasInventoryIntegration")) And experimentType="1" then%>
						<script type="text/javascript">
							inventoryAddArguments['mainAppPath'] = "<%=mainAppPath%>";
							inventoryAddArguments['expId'] = "<%=experimentId%>";
							inventoryAddArguments['expType'] = "<%=experimentType%>";
							inventoryAddArguments['pdfRevisionNumber'] = "<%=pdfRevisionId%>";
							inventoryAddArguments['makeSafeVersion'] = "false";
							inventoryAddArguments['fromSign'] = "true";
							inventoryAddArguments['useSafeSigning'] = "<%=session("useSAFE")%>";
							inventoryAddArguments['useSso'] = "<%=companyUsesSso() And session("isSsoUser")%>";
						</script>
						<a href="javascript:void(0);" onclick="validateBarcodes();" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
					<%else%>
						<%If Not (experimentType="3" And session("hasMUFExperiment")) then%>
							<%If companyUsesSso() And session("isSsoUser") Then%>
								<a href="javascript:void(0);" onclick="checkForEmptyRequiredFields(<%=experimentType%>,'ssoSignDiv');return false;" class="createLink" id="signExperimentButton">Sign</a>
							<%Else%>
								<a href="javascript:void(0);" onclick="checkForEmptyRequiredFields(<%=experimentType%>,'signDiv');return false;" class="createLink" id="signExperimentButton">Sign</a>
							<%End If%>
						<%End If%>
					<%End if%>
				<%else%>
						<a href="javascript:void(0)" onclick="alert('Experiment cannot be signed without passing regulatory check.')"  class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
				<%End if%>
			<%End if%>
		<%End if%>
		
	<%End if%>
<%End if%>
<%If session("role") = "Admin" And companyHasMoveExperimentButton = 1 then%>
	<a href="javascript:void(0);" onclick="showPopup('moveDiv');return false;" class="createLink" id="moveExperimentButton"><%=moveExperimentButtonLabel%></a>
<%End if%>

<script>
	function clickSave() {

		if (!$("#submitRow").is(":visible")) {
			console.log("Saving is not allowed yet!");
			return false;
		}

		showPopup('savingDiv');

		try { unsavedChanges=false; } catch(err) { }
		if ("<%=experimentType%>" == "5") {
			handleCustExpSaving(false);
		} else {
			if ("<%=experimentType%>" == "4") {
				if (!checkEMAnnotations()) {
					swal("You have unfilled annotations in the EM Data tab.");
				} else {
					experimentSubmit(false,false,false);
				}
			} else {
				experimentSubmit(false,false,false);
			}
		}
		
	}

	function clickSign() {
		$("#signDivSignButton").prop("disabled", true);
		if ($("#requesteeIdBox").val() == -2 && $("#signStatusBox").val() == "2") {
			$("#signDivSignButton").prop("disabled", false);
			swal("Please select a Witness");
			return;
		}

		showPopup('savingDiv');
		
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

	function handleCustExpSaving(isForSign, forPdf) {
		// Since we're in a custom experiment, we know that we have an IFrame,
		// so make the submit request and let that handle the rest.
		var iframe = window.frames["tocIframe"].contentWindow;
		var requestId = $("#requestId").val();
		var maxRevisionNumber = "<%=maxRevisionNumber%>";
		var returnVal = false;

		window.parent.showPopup("savingDiv");
		
		var saveCallbackFunction = function(saveRequestId, saveRevisionId) {

			window.parent.$("#requestRevisionId").val(saveRevisionId);

			// Only do this for the first actual save of a cust exp.
			if (saveRevisionId == 2) {
				var indivReqSrc = "/arxlab/workflow/viewIndividualRequest.asp?base=false&inFrame=true&requestid=" + saveRequestId + "&currentPageMode=custExp";
				$("#tocIframe").attr("src", indivReqSrc);
			}

			if(isForSign && saveRequestId != false)
			{
				if (forPdf) {
					window.parent.location = "<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=pdfRevisionId%>";
				} else {
					window.parent.hidePopup("savingDiv");
					<%If companyUsesSso() And session("isSsoUser") Then%>
					// AFter the save is finished, call the ssoSignDiv
					var afterSaveCallbackFn = function(){
						window.parent.showPopup("ssoSignDiv");
					}
					window.parent.experimentSubmit(false, false, false, undefined, saveRequestId, saveRevisionId, afterSaveCallbackFn);
					
					<%Else%>
					window.parent.showPopup("signDiv");
					<%End If%>
				}
			}
			else
			{
				if (saveRequestId == 0 || saveRequestId === null || saveRequestId === undefined) {
					$("#experimentDiv_tab").click();
					//swal("Error saving the experiment!");
					return false;
				}
				experimentSubmit(false, false, false, undefined, saveRequestId, saveRevisionId);
			}
		}

		// These two functions use the isForSign variable twice because if we're here, we want to validate the fields and submit all of them.
		if(requestId == "" || maxRevisionNumber == undefined) {
			returnVal = iframe.requestEditorHelper.getStructuresAndSubmit(null, isForSign, isForSign, saveCallbackFunction, window.thisRequestType, window.versionedRequestItems, window.versionedFields);
		} else {
			returnVal = iframe.requestEditorHelper.getStructuresAndSubmit(parseInt(requestId), isForSign, isForSign, saveCallbackFunction, window.thisRequestType, window.versionedRequestItems, window.versionedFields);
		}
		
		return returnVal;
	}

</script>