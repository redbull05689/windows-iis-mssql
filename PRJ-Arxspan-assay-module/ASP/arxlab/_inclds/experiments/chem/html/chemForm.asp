<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/workflow/_inclds/Workflow_Includes.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	gridCutoff = getCompanySpecificSingleAppConfigSetting("stoichGridFeatureCutoverPoint", session("companyId"))
	gridCutoff = normalizeIntSetting(gridCutoff)
	updateMolWeightOnSigDigChange = checkBoolSettingForCompany("updateMolWeightOnSigDigChange", session("companyId"))
	hasCombi = checkBoolSettingForCompany("hasCombi", session("companyId"))
	hasCombiPlate = checkBoolSettingForCompany("hasCombiPlate", session("companyId"))
	useRegDataBaseOverWorkflowRequests = getCompanySpecificSingleAppConfigSetting("useSunovionWorkflow", session("companyId"))
%>
<script type="text/javascript" src="<%=mainAppPath%>/js/chemdrawInsert.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/marvinInsert.js?<%=jsRev%>"></script>
<form action="<%=mainAppPath%>/experiments/saveExperiment.asp" method="post" id="experimentForm" onsubmit="return false;">
	<input type="hidden" name="hungSaveSerial" value="<%=hungSaveSerial%>">
	<table cellpadding="0" cellspacing="0" style="width:100%;">
	<tr>
		<td colspan="2">
			<table class="caseTable expHeader" style="table-layout:fixed;height:34px; padding-left: 8px; vertical-align: center; width:100%; border:none;">
                <tr>
                    <td style="width:30%">
                        <div id="experimentTopLeftNavContainer" class="headerNavLinks" style="font-size:80%; font-weight: bold; padding-left: 8px;"></div>
                    </td>
                    <td style="width:70%">
                        <div id="topRightFunctionsAsp" display="block;" style="height:30px;"></div>
                    </td>
                </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="left" style="background-color:transparent;padding-bottom:none!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2>Experiment Details</h2></div>
				<table cellpadding="0" cellspacing="0" style="table-layout:fixed;width:100%;">
					<tr class="caseInnerTitle expBoxText" >
						<td style="width:30%;height:24px; font-weight: bold; padding-top: 4px; padding-left: 8px; padding-right:10px; border-bottom-left-radius: 3px;">
							Notebook Page:  <%=experimentName%>
							<input type="hidden" name="e_name" id="e_name" value="<%=draftSet("e_name",experimentName)%>">
						</td>
						<%If session("canChangeExperimentNames") then%>
							<td  style="width:15%;">
								<span style="float:right;"><%=experimentNameLabel%>:</span>
							</td>
							<td  style="width:55%; border-bottom-right-radius: 3px;">
								<% If revisionId = "" and canWrite And ownsExp then %>	
									<input type="text" style="width:97%;margin-left:5px;" name="e_userAddedName" id="e_userAddedName" value="<%=draftSet("e_userAddedName",userExperimentName)%>">
								<% Else %>
									<span style="width:97%;padding-left:8px;" name="e_userAddedName" id="e_userAddedName"><%=draftSet("e_userAddedName",userExperimentName)%></span>
								<% End If %>
							</td>
						<%End If%>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<tr>
		<td align="left" style="background-color:transparent;padding-bottom:none!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2><%=experimentDescriptionLabel%><span class="requiredExperimentFieldNotice" data-fieldname="e_details">*</span></h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<%If revisionId = "" and canWrite And ownsExp then%>
							<td class="caseInnerTitle expBoxText" valign="top">
								<textarea name="e_details" id="e_details" style="resize:vertical;height:48px;width:99%;margin:0;"><%=draftSet("e_details",experimentDetails)%></textarea>
							</td>
						<%else%>
							<td class="caseInnerTitle expBoxText multiLineSpacing" valign="top">
								<%=Replace(experimentDetails,vbcrlf,"<br/>")%>
							</td>
						<%End if%>
					</tr>
				</table>
			</div>
		</td>
	</tr>

	<%If session("hasAccordInt") then%>
		<%if useRegDataBaseOverWorkflowRequests = 1 then%>
			<%
			Call getConnectedJchemReg
			Set reca = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT cd_id FROM accMols WHERE notebookId="&SQLClean(notebookId,"N","S")&" AND included=1"
			reca.open strQuery,jchemRegConn,3,3
			If Not reca.eof Then
				%>
					<tr>
						<td colspan="2">
							<a href="javascript:void(0);" id="showTOCLink" onclick="document.getElementById('tocIframe').src='<%=mainAppPath%>/accint/frame-show-toc.asp?notebookId=<%=notebookId%>&notebookName=<%=notebookName%>';this.style.display='none';">Show TOC</a>
							<iframe id="tocIframe" width="880" height="1" style="width:880px;height:1px;" scrolling="no" frameborder="0" style="border:none;" src="javascript:void(0);"></iframe>
						</td>
					</tr>
				<%
			End if
			reca.close
			Set reca = nothing
			Call disconnectJchemReg
			%>
		<%else

			' The first magic number is the parent type code, the second is the target type code, and the third is the depth of the family tree we want.
			' Type Codes:
			' 1 - Request
			' 2 - Reg
			' 3 - Project
			' 4 - Notebook
			' 5 - Experiment
			' 6 - Inventory
			' 7 - Assay
			LinkSvcResp = getChildLinks(4, notebookId, "ELN", 1, 1)
			set linkSvcData = JSON.parse(linkSvcResp)

			if linkSvcData.get("result") = "success" then
				set linksArr = JSON.parse(linkSvcData.get("data"))
				requestId = linksArr.get(0).get("targetId")

				if requestId <> "" then
					url = "/requests/{requestId}/requestTypeId"
					url = Replace(url, "{requestId}", mapReq("requestId"))
					requestResp = appServiceGet(url)

					Set requestJson = JSON.parse(requestResp)
					requestStr = requestJson.get("data")

					Set requestObj = JSON.parse(requestStr)
					requestTypeId = requestObj.get("requestTypeId")

					currTime = Now()
					currYear = Year(currTime)
					currMon = Month(currTime)
					currDay = Day(currTime)
					currHour = Hour(currTime)
					currMin = Minute(currTime)
					currSec = Second(currTime)

					formattedTime = currYear & "-" & currMon & "-" & currDay & " " & currHour & ":" & currMin & ":" & currSec

					serviceUrl = "/requesttypes"
					serviceUrl = serviceUrl & "?requestTypeId=" & requestTypeId
					serviceUrl = serviceUrl & "&connectionId=" & session("servicesConnectionId")
					serviceUrl = serviceUrl & "&userId=" & session("userId")
					serviceUrl = serviceUrl & "&includeDisabled=false"
					serviceUrl = serviceUrl & "&intents="
					serviceUrl = serviceUrl & "&forcedGroupIds="
					serviceUrl = serviceUrl & "&isConfigPage=false"
					serviceUrl = serviceUrl & "&appName=ELN"
					serviceUrl = serviceUrl & "&AsOfDate=" & formattedTime

					requestTypeData = configGet(serviceUrl)

					set requestTypeDataP = JSON.parse(requestTypeData)				
					set requestName =  requestTypeDataP.get(0)
					CheckComReq = requestName.get("checkIfStructIsRequestedBeforeReg")
					%>

					<tr>
						<td colspan="2">
							<a href="javascript:void(0);" id="showTOCLink" CheckComReq="<%=CheckComReq%>" requestID="<%=requestId%>" onClick="showReq(<%=requestId%>)">Show TOC</a>
							<iframe id="tocIframe" style="width:100%;height:600px;display:none;" frameborder="0" style="border:none;" src="javascript:void(0);"></iframe>
						</td>
					</tr>
				<%end if
			end if
		End if
	End if%>

	<tr id="sectionRow">
		<td>
			<div class="tabs expTabs"><ul id="sectionTabs"><li><a href="javascript:void(0);" onClick="showMainDiv('reactionDiv');return false;" id="reactionDiv_tab" class="tabSelected selectedTab" style=""><%=reactionTabLabel%></a></li>
			<li><a href="javascript:void(0);" onClick="showMainDiv('attachmentTable');return false;" id="attachmentTable_tab" style="<%if Not hasAttachments then%>display:none;<%End if%>"><%=attachmentsTableLabel%></a></li>
			<li><a href="javascript:void(0);" onClick="showMainDiv('noteTable');return false;" id="noteTable_tab" style="<%If Not hasNotes then%>display:none;<%End if%>"><%=notesTableLabel%></a></li>
			<%If revisionId = "" And canWrite And ownsExp then%>
			<%If session("useResumableFileUploader") = true then%>
				<li><a href="javascript:void(0);" onClick="showPopup('addResumableFileDiv');return false;" id="addFile_tab" <%If experimentId = "" then%>style="display:none;"<%End if%>> <span class="plus">+</span> <span id="addFileButton"><%=addFileLabel%></span></a></li>
			<%else%>
				<li><a href="javascript:void(0);" onClick="showPopup('addFileDiv');return false;" id="addFile_tab" <%If experimentId = "" then%>style="display:none;"<%End if%>> <span class="plus">+</span> <span id="addFileButton"><%=addFileLabel%></span></a></li>
			<%end if%>
			<li><a href="javascript:void(0);" onClick="newNote();return false;" id="addNote_tab" <%If experimentId = "" then%>style="display:none;"<%End if%>> <span class="plus">+</span> <span id="addNoteButton"><%=addNoteLabel%></span></a> </li>
			<%If bCheck <> "IE 8.0" then%>
			<li><a href="javascript:void(0);" onClick="newSketch();return false;" id="addSketch_tab" <%If experimentId = "" then%>style="display:none;width:100px;"<%else%>style="width:100px;"<%End if%>> <span class="plus">+</span> <span id="addSketchButton"><%=addSketchLabel%></span></a> </li>
			<%End if%>
			<%End if%>
			</ul></div>
		</td>
	</tr>
	</table>

	<div style="position:relative;" id="tabBodyContainer" class="tabBodyContainer">
	<table cellpadding="0" cellspacing="0" style="width:100%;position:relative;" id="reactionDiv">
	<tr id="cdxRow" <%If Not session("noChemDraw") then%>onmouseover="if(!startSmilesSet){checkForChemistryChanges(false);}chemDrawHasFocus=true"<%End if%> onmouseout="chemDrawHasFocus=false">
		<td colspan="2"  class="reactionBox elnObjectContainer elnDashObj" style="position:relative;"><span class="requiredExperimentFieldNotice chemdrawNotice" data-fieldname="e_cdxData">* Required</span>
			<div id="chemdrawHolder" class="background">
			<center>
			  <script type="text/javascript" src="/arxlab/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
			  <script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
				<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
			  <script type="text/javascript">
				<%If session("useChemDrawForLiveEdit") Then%>
					useChemDrawForLiveEdit = true;
				<%End If%>
				
				<%if revisionId = "" And canWrite And ownsExp then%>
					readOnly = false;
				<%else%>
					var readOnly = true;
				<%end if%>

				<%
				Call getconnected
				strQuery = "SELECT checkedOut FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
				Set rec = server.CreateObject("ADODB.RecordSet")
				rec.open strQuery,conn,3,3
				%>
				expIsCheckedOut = <% if  isNull(rec("checkedOut")) then response.write("null") else response.write("'" + rec("checkedOut") + "'") end if%>;
				//expIsCheckedOut = (<%=rec("checkedOut")%> == 1) ? <%=experimentId%> : expIsCheckedOut; //TODO: check that the experiment ID is the right thing //This is for backward compatibilty
				<%	
				rec.close
				Set rec = nothing
				%>

				<%If session("useMarvin") THEN%>
				var marvinReady = false;
				document.write("<table style='background-color:white;width:100%;height:400px;'><tr><td align='center' valign='center' id='chemEditorHolder'></td></tr></table>");
				$.ajax({
					url: "<%=mainAppPath%>/experiments/ajax/load/getCDXorMRV.asp",
					type: "GET",
					data: "id=<%=experimentId%>&random="+Math.random(),
				})
				.done(function(response) {
                    getChemistryEditorMarkup("mycdx", "mainChemReaction", response, "100%", 400, readOnly, function () { }, function (event, msg, args) { }, function (msg, args) { }, expIsCheckedOut, true, "reaction").then(function (theHtml) {
                        $("#chemEditorHolder").html(theHtml);
					});
				});
				<%else%>
					//Thanks IE
					var cdxData = "<%
						result = cdxData
						result = replace(result, "\", "\\")
						result = replace(result, """", "\""")
						result = replace(result, vbcr, "\r")
						result = replace(result, vblf, "\n")
						result = replace(result, vbtab, "\t")
						response.write(result)
					%>";
					cdxData = cdxData.replace(/\\\\/g, "\\");
					cdxData = cdxData.replace(/\\\"/g, "\"");
					cdxData = cdxData.replace(/\\r/g, "\r");
					cdxData = cdxData.replace(/\\n/g, "\n");
					cdxData = cdxData.replace(/\\t/g, "\t");

					document.write("<table style='background-color:lightGray;width:100%;height:300px;'><tr><td align='center' valign='center'>");
					document.write("<div id='chemFormAspChemBox'></div>")
					document.write("</td></tr></table>");
					$(document).ready(function () {
                        getChemistryEditorMarkup("mycdx", "mainChemReaction", cdxData, "100%", 300, readOnly, function () {
							//Checkin
							if (doChemChangeCheck) {
								//Mark the experiment as checkedin
								setChemExperimentAsCheckedOut(0);

								//Clean up
								experimentSubmit(false, false, true, false, false);
							}
						}, function (event, msg, args) {
							//Checkout
							//This is the main chem reaction, mark the experiment as checkedout
							setChemExperimentAsCheckedOut(args.fileId);
						}, function (msg, args) {
							//Discard
							setChemExperimentAsCheckedOut(0);
						}, expIsCheckedOut, false, "reaction")
						.then(function (theHtml) {
							$("#chemFormAspChemBox").html(theHtml);
						});
                    });
				<%end if%>

			  </script>
			</center>
			</div>
				<%If session("hasCrais") Then
					Select Case craisStatusId
						Case 0
							craisStatus = "Not Run"
						Case 1
							craisStatus = "Passed"
						Case 2
							craisStatus = "Passed With Warnings"
						Case 3
							craisStatus = "Failed"
						Case 4
							craisStatus = "Failed With Admin Override"
					End Select
					%>
					<input type="hidden" name="craisStatus" id="craisStatus" value="<%=craisStatus%>">
					<%
					If craisStatusId <> 0 Then
					%>
					<input type="hidden" name="craisCheckRun" id="craisCheckRun" value="1">
					<%
					End if
				End if%>
				<%If session("hasInventoryIntegration") Or session("hasCompoundTracking") then%>
					<input type="hidden" name="currLetter" id="currLetter" value="<%=currLetter%>">
				<%End if%>
				<%If hasCombi and hasCombiPlate then%>
					<input type="hidden" name="resultSD" id="resultSD" value="<%=resultSD%>">
				<%End if%>
				<%If session("hasInventoryIntegration") Or session("hasCompoundTracking") then%>
					<input type="hidden" name="trivialNameInQuickView" id="trivialNameInQuickView" value="1">
				<%else%>
					<input type="hidden" name="trivialNameInQuickView" id="trivialNameInQuickView" value="0">
				<%End if%>
				<%
				cdxDataNoAmp = replace(cdxData, "&", "&amp;")
				%>
				<input type="hidden" name="sigdigText" id="sigdigText" value="">
				<input type="hidden" name="tempRxn" id="tempRxn" value="">
				<input type="hidden" name="tempCdx" id="tempCdx" value="<%=replace(replace(cdxDataNoAmp,"\""","&quot;"),"""","&quot;")%>">
				<input type="hidden" name="cdxData" id="cdxData" value="<%=replace(replace(cdxDataNoAmp,"\""","&quot;"),"""","&quot;")%>">
				<input type="hidden" name="xmlData" id="xmlData" value="<%=replace(replace(cdxDataNoAmp,"\""","&quot;"),"""","&quot;")%>">
				<input type="hidden" name="molData" id="molData" value="<%=replace(molData,"""","&quot;")%>">
				<input type="hidden" name="mrvData" id="mrvData" value="<%=replace(mrvData,"""","&quot;")%>">
				<input type="hidden" name="reactants" id="reactants" value="">
				<input type="hidden" name="reagents" id="reagents" value="">
				<input type="hidden" name="products" id="products" value="">
				<input type="hidden" name="solvents" id="solvents" value="">
				<input type="hidden" name="attachments" id="attachments" value="">
				<input type="hidden" name="approve" id="approve" value="">
				<input type="hidden" name="experimentId" id="experimentId" value="<%=request.querystring("id")%>">
				<input type="hidden" name="experimentType" id="experimentType" value="<%=experimentType%>">
				<input type="hidden" name="notebookId" id="notebookId" value="<%=notebookId%>">
				<input type="hidden" name="chemDrawChanged" id="chemDrawChanged" value="<%=draftSet("chemDrawChanged","0")%>">
			<input type="hidden" name="thisRevisionNumber" id="thisRevisionNumber" value="<%=maxRevisionNumber%>">
		</td>
	</tr>
	<tr id="populateRow"><td align="right" colspan="2">
	<%If revisionId="" And canWrite And ownsExp then%>
		<div class="buttonHolder" style="float:left;">
			<%
			Call getconnected
			strQuery = "SELECT checkedOut FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
			Set rec = server.CreateObject("ADODB.RecordSet")
			rec.open strQuery,conn,3,3
			%>
				<a href="javascript:void(0);" onclick="showPopup('uploadRXNDiv');return false;" class="createLink" id="uploadReaction" style="margin-top:10px;margin-bottom:10px;<%If IsNull(rec("checkedOut")) then%>display:inline;<%else%>display:none;<%End if%>"><%=uploadReactionLabel%></a>
			<%	
			rec.close
			Set rec = nothing
			%>
			
		</div>	
	<%End If%>

	<script type="text/javascript">
		function makeNextStep(){
			fullMol = "$RXN V3000\n\n  ARXSPAN NEW RXN\n\n";
			numProducts = 0;
			for (i=0;i<30 ;i++ ){
				prefix = "p"+i;
				if (document.getElementById(prefix+"_tab")){
					numProducts += 1;
				}
			}
			fullMol+= "M  V30 COUNTS "+numProducts+" 0\nM  V30 BEGIN REACTANT";
			for (i=0;i<30 ;i++ ){
				prefix = "p"+i;
				if (document.getElementById(prefix+"_tab")){
					md = document.getElementById(prefix+"_molData3000").value;
					if(md){
						ctab = md.match(/M  V30 BEGIN CTAB[\s\S]*M  V30 END CTAB/gi);
						fullMol += "\n"+ctab;
					}else{
						md = getFile("<%=mainAppPath%>/ajax_doers/getMol3000.asp?molData="+encodeURIComponent(document.getElementById(prefix+"_molData").value))
						ctab = md.match(/M  V30 BEGIN CTAB[\s\S]*M  V30 END CTAB/gi);
						fullMol += "\n"+ctab;
					}
				}
			}
			fullMol+= "\nM  V30 END REACTANT\nM  END\n";
			
			var cdxml = '';
			var cdxmlUrl = '<%=mainAppPath%>/ajax_doers/setNextStepRxn.asp';
			
			// get a cdxml of the whole rxn file
			$.ajax({
				url: cdxmlUrl,
				type: 'POST',
				async: false,
				data: {rxnFile: fullMol},
			})
			.done(function(data, textStatus, jqXHR) {
				console.log("success: setNextStepRxn");
			})
			.fail(function(jqXHR, textStatus, errorThrown) {
				console.log("setNextStepRxn error: ", errorThrown);
			})
			.always(function() {
				showPopup('newExperimentNextStepDiv')
				$("#nextStepExperimentType").change(function(){
					if($("#nextStepExperimentType").val() == "")
					{
						$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > button").attr("disabled", true);
						$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > button").hide();
						$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > label").show();
					}
					else 
					{
						$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > button").attr("disabled", false);
						$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > button").show();
						$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > label").hide();
					}
				});
			});
		}
	</script>
	</div>

	<div class="buttonHolder" style="float:right;">
	<% if session("useMarvin") THEN %>
		<a href="<%=mainAppPath%>/experiments/ajax/load/getMRV.asp?id=<%=experimentId%>&revisionNumber=<%=revisionId%>&attachment=true&qs=removeUIDs" class="createLink" id="addUpdateLink">Download Reaction</a>
	<% ELSE %>
		<a href="<%=mainAppPath%>/experiments/ajax/load/getCDX.asp?id=<%=experimentId%>&revisionNumber=<%=revisionId%>&attachment=true" class="createLink" id="addUpdateLink">Download Reaction</a>
	<% END IF %>
	</div>

	<div class="buttonHolder" style="float:right;" id="makeNextStepButton">
		<a href="javascript:void(0);" onclick="makeNextStep()" class="createLink" id="makeNextStepLink" style="margin-top:10px;margin-bottom:10px;"><%=addNextStepLabel%></a>
	</div>
	
	<%If revisionId="" And canWrite And ownsExp then%>
		<%If session("hasCrais") then%>
		<script type="text/javascript">
			function runCraisCheck(){
				if(unsavedChanges){
					alert("Regulatory check cannot be run while there are unsaved changes.  Please save your changes and try again.")
					return false;
				}else{
					showPopup('savingDiv');
					window.location = '<%=mainAppPath%>/crais/runCraisCheck.asp?experimentId=<%=experimentId%>';
				}
			}
		</script>
		<div class="buttonHolder" style="float:right;"><a href="javascript:void(0);" onclick="killIntervals();runCraisCheck();return false;" class="createLink" id="runCraisLink" style="margin-top:10px;margin-bottom:10px;">CRAIS Check</a>
		</div>
		<%End if%>
		<%'start combi%>
		<%If hasCombi Then%>
		<div class="buttonHolder" style="float:right;display:none;"><a href="javascript:void(0);" onclick="showPopup('uploadCombiDiv');return false;" class="createLink" id="uploadCombiLink" style="margin-top:10px;margin-bottom:10px;">Upload Combi</a>
		</div>
		<%End if%>
		<%'end combi%>
	<%End if%>
	<%If session("hasCrais") And session("role")="Admin" And revisionId="" then%>
		<%If craisStatusId=3 then%>
			<div class="buttonHolder" style="float:right;"><a href="javascript:void(0);" onclick="window.location='<%=mainAppPath%>/crais/craisOverride.asp?experimentId=<%=experimentId%>';return false;" class="createLink" id="runCraisLink" style="margin-top:10px;margin-bottom:10px;">CRAIS Override</a>
			</div>
		<%End if%>
		</td></tr>
	<%End if%>
	<%If revisionId="" And canWrite And ownsExp then%>
		</td></tr>
	<%End if%>

	<tr id="reactionRow">
		<td align="center" colspan="2">
			<table cellpadding="0" cellspacing="0" class="reactionContainerTable">
			<tr>
			<td align="left" style="background-color:transparent;">
			<div class="tabs expTabs"><ul id="reactionTabs"><div style="background-color:white;"><%If revisionId <> "" then%><span style="font-size:18px;padding:4px;">Loading</span><%End if%></div></ul></div>
			</td>
			</tr>
			<tr>
				<td align="left" width="100%" valign="top">
					<div id="formDiv" align="left" class="reactionFormDiv elnObjectContainer elnDashObj rxnContainer">
						<%If experimentId = "" then%>
						<div style="background-color:white;margin-bottom:5px;padding:4px;"><h1 style="display:inline;">Loading...</h1></div>
						<%End if%>
						<div id="qv_body_container"></div>
						<table class="caseTable expHeader" cellpadding="0" cellspacing="0" style="width:100%;display:none;margin-bottom:0px;" id="rc_body">
							<tr>
								<td class="caseInnerTitle expBoxText" valign="top" style="width:70px; text-shadow: none;" nowrap>
									Reaction&nbsp;Molarity<span class="requiredExperimentFieldNotice simpleAbsolute" data-fieldname="e_Molarity">*</span>
								</td>
								<td class="caseInnerData" >
									<%If revisionId = "" and canWrite And ownsExp then%>
										<div style="position:relative;z-index:10000;">
										<div class='unitsDiv' id='e_Molarity_units' style='display:none;z-index:1000;'>
										<ul>
										<li><a id='e_Molarity_units_num_0' onmouseover='clearSelectedClass(this)' onclick="appendUnits('&micro;M')">&micro;M</a></li>
										<li><a id='e_Molarity_units_num_1' onmouseover='clearSelectedClass(this)' onclick="appendUnits('mM')">mM</a></li>
										<li><a id='e_Molarity_units_num_2' onmouseover='clearSelectedClass(this)' onclick="appendUnits('M')">M</a></li>
										</ul>
										</div></div>
										<span id='e_Molarity_dummy_width' style='position:absolute;left:-4000px;'></span>
										<span id='e_Molarity_du' style='position:absolute;left:-4000px;'>M</span>

										<div style='position:relative;'>
										<input style='z-index:10;' type="text" name="e_Molarity" id='e_Molarity' value="<%=draftSet("e_Molarity",reactionMolarity)%>" onKeyUp='units(this)' onfocus='units(this)'>
										<a href='javascript:void(0)' id='e_Molarity_down_image' style='position:absolute;top:5px;left:-4000px;z-index:10;' onclick='units(this);return false;'><img src='images/down.gif' border='0'></a>
										</div>
									<%else%>
										<div class='reactionPropertiesDiv' style='width:130px;'><%=reactionMolarity%></div>
									<%End if%>
								</td>
							</tr>
							<tr>
								<td class="caseInnerTitle expBoxText" valign="top" style="width:70px; text-shadow: none;">
									Pressure<span class="requiredExperimentFieldNotice simpleAbsolute" data-fieldname="e_pressure">*</span>
								</td>
								<td class="caseInnerData">
									<%If revisionId = "" and canWrite And ownsExp then%>
										<div style='position:relative;z-index:10000;'>
										<div class='unitsDiv' id='e_pressure_units' style='display:none;z-index:10000;'>
										<ul>
										<li><a id='e_pressure_units_num_0' onmouseover='clearSelectedClass(this)' onclick="appendUnits('kPa')">kPa</a></li>
										<li><a id='e_pressure_units_num_1' onmouseover='clearSelectedClass(this)' onclick="appendUnits('Pa')">Pa</a></li>
										<li><a id='e_pressure_units_num_2' onmouseover='clearSelectedClass(this)' onclick="appendUnits('atm')">atm</a></li>
										<li><a id='e_pressure_units_num_3' onmouseover='clearSelectedClass(this)' onclick="appendUnits('torr')">torr</a></li>
										<li><a id='e_pressure_units_num_4' onmouseover='clearSelectedClass(this)' onclick="appendUnits('bar')">bar</a></li>
										<li><a id='e_pressure_units_num_5' onmouseover='clearSelectedClass(this)' onclick="appendUnits('mbar')">mbar</a></li>
										<li><a id='e_pressure_units_num_6' onmouseover='clearSelectedClass(this)' onclick="appendUnits('psi')">psi</a></li>
										</ul>
										</div></div>
										<span id='e_pressure_dummy_width' style='position:absolute;left:-4000px;'></span>
										<span id='e_pressure_du' style='position:absolute;left:-4000px;'>atm</span>

										<div style='position:relative'>
										<input type="text" name="e_pressure" id="e_pressure" value="<%=draftSet("e_pressure",pressure)%>" style='position:relative;z-index:10;' onKeyUp='units(this)' onfocus='units(this)'>
										<a href='javascript:void(0)' id='e_pressure_down_image' style='position:absolute;top:5px;z-index:10;left:-4000px;' onclick='units(this);return false;'><img src='images/down.gif' border='0'></a>
										</div>
									<%else%>
										<div class='reactionPropertiesDiv' style='width:130px;'><%=pressure%></div>
									<%End if%>
								</td>
							</tr>
							<tr>
								<td class="caseInnerTitle expBoxText" valign="top" style="width:70px; text-shadow: none;">
									Temperature<span class="requiredExperimentFieldNotice simpleAbsolute"data-fieldname="e_temperature">*</span>
								</td>
								<td class="caseInnerData">
									<%If revisionId = "" and canWrite And ownsExp then%>
										<div style='position:relative;z-index:10000;'>
										<div class='unitsDiv' id='e_temperature_units' style='display:none;z-index:10000;'>
										<ul>
										<li><a id='e_temperature_units_num_1' onmouseover='clearSelectedClass(this)' onclick="appendUnits('&deg;C')">&deg;C</a></li>
										<li><a id='e_temperature_units_num_0' onmouseover='clearSelectedClass(this)' onclick="appendUnits('K')">K</a></li>
										<li><a id='e_temperature_units_num_2' onmouseover='clearSelectedClass(this)' onclick="appendUnits('&deg;F')">&deg;F</a></li>
										</ul>
										</div>
										<span id='e_temperature_dummy_width' style='position:absolute;left:-4000px;'></span>
										<span id='e_temperature_du' style='position:absolute;left:-4000px;'>&deg;C</span>
										</div>
										<div style="position:relative;">
										<input type="text" name="e_temperature" id="e_temperature" value="<%=draftSet("e_temperature",temperature)%>" style='position:relative;z-index:10;' onKeyUp='units(this)' onfocus='units(this)'>
										<a href='javascript:void(0)' id='e_temperature_down_image' style='position:absolute;top:5px;z-index:10;left:-4000px;' onclick='units(this);return false;'><img src='images/down.gif' border='0'></a>
										</div>
									<%else%>
										<div class='reactionPropertiesDiv' style='width:130px;'><%=temperature%></div>
									<%End if%>												
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			</table>

		</td>

	</tr>
	<%If revisionId="" then%>
	<tr>
		<%If ownsExp And experimentId < gridCutoff then%>
		<td style="padding-top:2px;">
			<a href="javascript:void(0);" onclick="if(confirm('Are you sure you wish to clear all the calculated fields in the stochiometry grid?')){clearGrid()};return false;" class="createLink" id="uploadReactionLink" style="padding-top:4px;width:80px;height:16px;">
			Reset Grid
			</a>
			<a href="javascript:void(0);" onclick="runLimittingOnChange();window.setTimeout('populateQuickView()',2000);unsavedChanges=true;return false;" class="createLink" id="uploadReactionLink" style="padding-top:4px;width:80px;height:16px;">
			Update
			</a>
		</td>
		<%End if%>
		<td align="right" <%If Not ownsExp then%>colspan="2"<%End if%>>
			<table>
				<tr>
					<td>
						<label for="sigdig">Significant Digits:</label>
					</td>
					<td>
						<select name="sigdig" id="sigdig" onchange="if(this.options[this.selectedIndex].value != ''){sigdigs = this.options[this.selectedIndex].value;}<%If updateMolWeightOnSigDigChange then%>if(this.options[this.selectedIndex].value != ''){updateMolWeights();}<%End if%>" style="width:60px;padding-left:5px;">
							<option value='3'<%If sigdigs = "3" then%> SELECTED<%End if%>>3</option>
							<option value='4'<%If sigdigs = "4" then%> SELECTED<%End if%>>4</option>
							<option value='5'<%If sigdigs = "5" then%> SELECTED<%End if%>>5</option>
							<option value='6'<%If sigdigs = "6" then%> SELECTED<%End if%>>6</option>
							<option value='7'<%If sigdigs = "7" then%> SELECTED<%End if%>>7</option>
							<option value='8'<%If sigdigs = "8" then%> SELECTED<%End if%>>8</option>
							<option value='9'<%If sigdigs = "9" then%> SELECTED<%End if%>>9</option>
							<option value='10'<%If sigdigs = "10" then%> SELECTED<%End if%>>10</option>
						</select>
						<script type="text/javascript">
							sigdigs = document.getElementById('sigdig').options[document.getElementById('sigdig').selectedIndex].value;
							function updateMolWeights(){
								allPrefixes = getExistingPrefixesList(["r","rg","p"]);
								mainXML = cd_getData("mycdx","text/xml");
								mainXML = loadXML(mainXML);
								for (var i=0;i<allPrefixes.length;i++){
									fragmentId = document.getElementById(allPrefixes[i]+"_fragmentId").value;
									fragment = mainXML.getElementById(fragmentId);
									newMolWeight = '';
									try
									{
										cd_putData("compcdx","text/xml",cdxStart+xmlToString(fragment)+cdxEnd);
										newMolWeight = cd_getMolWeight("compcdx");
									}
									catch(err)
									{
										console.log("ChemDraw does not appear to be active in the browser!");
									}
									if(newMolWeight != "")
										document.getElementById(allPrefixes[i]+"_molecularWeight").value = newMolWeight.toFixed(2);
								}
								foundIt = false;
								for(var i=0;i<30;i++)
								{
									try
									{
										if(document.getElementById("r"+i+"_limit").checked)
										{
											foundIt = true;
										}
									}
									catch(err){}
								}
								for(var i=0;i<30;i++)
								{
									try
									{
										if(document.getElementById("rg"+i+"_limit").checked)
										{
											foundIt = true;
										}
									}
									catch(err){}
								}
								if(!foundIt){
									for(var i=0;i<30;i++)
									{
										if(document.getElementById("r"+i+"_limit")){
											document.getElementById("r"+i+"_limit").checked = true;
											break;
										}
									}
								}
								for(i=0;i<30;i++)
								{
									try
									{
										if(document.getElementById("r"+i+"_limit").checked)
										{
											if(UAStates["r"+i]["sampleMass"]){
												gridFieldChanged(document.getElementById("r"+i+"_sampleMass"))
											}
											if(UAStates["r"+i]["volume"]){
												gridFieldChanged(document.getElementById("r"+i+"_volume"))
											}
											if(UAStates["r"+i]["moles"]){
												gridFieldChanged(document.getElementById("r"+i+"_moles"))
											}
											if(UAStates["r"+i]["equivalents"]){
												gridFieldChanged(document.getElementById("r"+i+"_equivalents"))
											}
										}
									}
									catch(err){}
								}
								for(i=0;i<30;i++)
								{
									try
									{
										if(document.getElementById("rg"+i+"_limit").checked)
										{
											if(UAStates["rg"+i]["sampleMass"]){
												gridFieldChanged(document.getElementById("rg"+i+"_sampleMass"))
											}
											if(UAStates["rg"+i]["volume"]){
												gridFieldChanged(document.getElementById("rg"+i+"_volume"))
											}
											if(UAStates["rg"+i]["moles"]){
												gridFieldChanged(document.getElementById("rg"+i+"_moles"))
											}
											if(UAStates["rg"+i]["equivalents"]){
												gridFieldChanged(document.getElementById("rg"+i+"_equivalents"))
											}
										}
									}
									catch(err){}
								}
								populateQuickView();
							}
						</script>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%End if%>
	<tr>
		<td>
			&nbsp;
			<!--<textarea id="testArea" style=""></textarea>-->
		</td>
		<td>
		</td>
	</tr>
	<tr>
		<td colspan="2">
		<%If session("hasInventoryIntegration") Or session("hasCompoundTracking") then%>
			<div style="position:absolute;left:-5000px;">
			<script type="text/javascript">
				cd_insertObject("text/xml", 300, 300, "compcdx",""<%if revisionId <> "" or not ownsExp or not canWrite then%>,true<%else%>,false<%end if%>,true);
			</script>
			</div>
		<%End if%>
		</td>
	<tr>
	<tr>
		<td valign="top">
			<table style="width:100%;" id="prepTable">
				<tr>
					<td valign="top">
						<table cellpadding="0" cellspacing="0" style="table-layout:fixed;width:100%;">
						<tr>
							<td align="left" style="background-color:transparent;padding-bottom:none!important;">
								<div class="elnObjectContainer elnDashObj">
									<div class="tabs elnHead"><h2><%=reactionPreparationLabel%><span class="requiredExperimentFieldNotice" data-fieldname="e_preparation">*</span></h2></div>
									<table cellpadding="0" cellspacing="0" style="width:100%;">
										<tr>
											<td class="caseInnerData">
												<%If revisionId = "" and canWrite And ownsExp then%>
													<textarea cols="60" name="e_preparation" id="e_preparation" style="width:100%!imporant;padding-right:none;"><%=htmlspecialchars(draftSet("e_preparation",prepText))%></textarea>
													<script type="text/javascript">
														CKEDITOR.replace('e_preparation',{allowedContent:true,toolbar : 'arxspanToolbarPrepTemplates',extraPlugins:'arx_onchange,arx_autoText,arx_chemistryPreparationTemplates,ajax,arx_degreeButton,arx_timeStampButton'});
														if(userOptions['chem_e_preparation_height']){
															CKEDITOR.instances['e_preparation'].config.height = userOptions['chem_e_preparation_height'];
														}
														CKEDITOR.instances.e_preparation.config.keystrokes = [];
														CKEDITOR.instances['e_preparation'].on('resize',function(){positionButtons();updateCkEditorSize('chem_e_preparation_height','e_preparation');})
														//CKEDITOR.instances['e_preparation'].on('paste',function(e){})
														CKEDITOR.instances['e_preparation'].on( 'contentDom', function(ev){ev.editor.document.on( 'paste', function(e){pasteHandler(e.data.$,'e_preparation');});});
														CKEDITOR.on('DOMContentLoaded',
														function( evt ) {
															editor = CKEDITOR.instances['e_preparation'];
															console.log("CKE alreadyLoaded = ", editor.alreadyLoaded);
															if(editor.alreadyLoaded == undefined){
																editor.execCommand('arxautotextcommand');
															}
															positionButtons();
														}
														);

													</script>
												<%else%>
													<%="<p>"&HTMLDecode(Replace(prepText,vbcrlf,"</p><p>"))&"</p>"%>
												<%End if%>
											</td>
										</tr>
									</table>
								</div>
							</td>
						</tr>
						</table>
					</td>
					<td>

					</td>
				</tr>
			</table>
		</td>
		
	</tr>


	<%If session("hasInv") Then%>
	<tr>
		<td align="left" style="padding-bottom:0!important;" id="invLinks" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2>Inventory Items</h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<td class="caseInnerTitle expBoxText" valign="top" id="inventoryLinksTD">
							<%
							strQuery = "SELECT inventoryId, name, amount FROM inventoryLinks WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
							Set lRec = server.CreateObject("ADODB.RecordSet")
							lRec.open strQuery,conn
							Do While Not lRec.eof
								%>
									<a href="<%=mainAppPath%>/inventory2/index.asp?id=<%=lRec("inventoryId")%>"><%=lRec("name")%>&nbsp;<%=lRec("amount")%></a><br/>
								<%
								lRec.moveNext
							loop
							%>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<%End If%>

	<tr>
		<td align="left" style="background-color:transparent;padding-bottom:0!important;" valign="top" colspan="2" class="experimentSection_experimentLinks_header">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2><div class="experimentLinksSectionHeader"><%=experimentLinksLabel%></div><div class="experimentLinkMapButtonContainer"><a href="javascript:void(0)" title="View Experiment Link Map" id="showExperimentLinkMapButton" class="showExperimentLinkMapButton">View Experiment Link Map</a></div></h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<td class="caseInnerTitle expBoxText" valign="top" id="linksTD">
							<% ' Removed for ELN-933 %>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	
	<%If session("registerFromBio") Or session("companyId")="1" then%>
	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
			<div class="invButtons">
				<a href="javascript:void(0)" onclick="toggleRegLinkTable();return false;" id="regLinkToggle" title="Show/Hide Link Table"><img id="toggleRegLinkImg" src="images/triangle_down_1x.png" class="png" style="position:absolute;right:25px;" border="0"></a>
			</div>
			<div class="tabs elnHead"><h2>Registration Links</h2></div>
			<table cellpadding="0" cellspacing="0" style="width:100%;">
				<tr>
					<td class="caseInnerTitle expBoxText" valign="top" id="regLinksTD">
						<% ' Removed for ELN-933 %>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%End if%>

	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
			<div class="tabs elnHead"><h2><%=projectLinksLabel%><span class="requiredExperimentFieldNotice projectLinksNotice" data-fieldname="e_projectLinks">*</span></h2></div>
			<table cellpadding="0" cellspacing="0" style="width:100%;">
				<tr>
					<td class="caseInnerTitle expBoxText" valign="top" id="projectLinksTD">
						<% ' Removed for ELN-933 %>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
		<div class="elnObjectContainer elnDashObj">
			<div class="tabs elnHead"><h2>Request Links</h2></div>
			<table cellpadding="0" cellspacing="0" style="width:100%;">
				<tr>
					<td class="caseInnerTitle expBoxText" valign="top" id="reqLinksTD">
						
					</td>
				</tr>
			</table>
		</div>
		</td>
	</tr>

</table>

<div style="position:absolute;left:-5000px;top:0;" id="attachmentTable" class="chemAddTable experimentAttachmentTable">
<!-- #include file="../../../attachments/html/resumableFileUploader.asp"-->
<div id="attachmentTableList">
<script>
$( document ).ready(function() {
	$.ajax({
		url: "<%=mainAppPath%>/_inclds/attachments/html/showAttachmentTableWrapper.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionId=<%=revisionId%>",
		type: "GET",
		async: true,
		cache: false,
		dataType: "html"
	})
	.success(function(r) {
		$("#attachmentTableList").html(r);
	})
	.fail(function() {
		alert("Unable to load attachments table. Please contact support@arxspan.com.");
	});
});
</script>
</div>
</div>
<div style="position:absolute;left:-5000px;top:0;" id="noteTable" class="chemAddTable experimentNotesTable">
<script>
$( document ).ready(function() {
	$.ajax({
		url: "<%=mainAppPath%>/_inclds/notes/html/showNoteTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionId=<%=revisionId%>",
		type: "GET",
		async: true,
		cache: false,
		dataType: "html"
	})
	.success(function(r) {
		$("#noteTable").html(r);
	})
	.fail(function() {
		alert("Unable to load notes table. Please contact support@arxspan.com.");
	});
});
</script>
</div>

<%'this submit button is added bc for IE .submit can not be called in frame bc I think there is a naming conflict with fck%>
<input type="submit" id="subTest" value = "hello" style="height:1px;width:1px;visibility:hidden;">
</form>

</div>

<form name="addLinkForm" id="addLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/newExperimentLink.asp" target="submitFrame2">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>

<form name="deleteLinkForm" id="deleteLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/deleteExperimentLink.asp" target="submitFrame2">
<input type="hidden" name="delLinkType" id="delLinkType" value="">
<input type="hidden" name="delLinkId" id="delLinkId" value="">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>

<form name="deleteRegLinkForm" id="deleteRegLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/deleteExperimentRegLink.asp" target="submitFrame2">
<input type="hidden" name="delRegNumber" id="delRegNumber" value="">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>

<form name="deleteRequestLinkForm" id="deleteRequestLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/deleteExperimentRequestLink.asp" target="submitFrame2">
<input type="hidden" name="delRequestId" id="delRequestId" value="">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>

<%If session("fromNextStep") then%>
<%session("fromNextStep") = false%>
<%End if%>
<%'412015%>
<script type="text/javascript">
// Load notebook nav links
$.ajax({
	url: '/arxlab/_inclds/experiments/common/html/experimentTopLeftNav.asp?notebookId=<%=notebookId%>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>',
	type: 'GET',
	async: true
})
.done(function(response) {
	$('#experimentTopLeftNavContainer').html(response);
})
.fail(function(jqXHR, textStatus, errorThrown) {
	console.log("experimentTopLeftNav error: ", errorThrown);
})
.always(function() {
	console.log("experimentTopLeftNav error ran");
});

	<% if session("useResumableFileUploader") = true then %>
		addResumableJSUploader();
	<% end if %>
</script>
<!-- #include file="../../../../java/javaProgrammersApplet.asp"-->
<%'/412015%>