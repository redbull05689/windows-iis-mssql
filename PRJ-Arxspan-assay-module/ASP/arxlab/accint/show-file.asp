<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%server.scriptTimeout=300
Response.AddHeader "Content-Type", "text/html;charset=UTF-8"
Response.CodePage = 65001
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="../registration/_inclds/lib_reg.asp"-->
<!-- #include file="_inclds/fnc_getLocalRegNumber.asp"-->
<!-- #include file="_inclds/fnc_searchStructureInReg.asp"-->
<!-- #include file="_inclds/fnc_searchAccordStructures.asp"-->
<!-- #INCLUDE file="../_inclds/users/functions/fnc_hasAutoNumberNotebooks.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
groupNameInNotebook = getCompanySpecificSingleAppConfigSetting("addGroupNameToNotebookName", session("companyId"))
Call getconnected
autoNumberNotebooks = hasAutoNumberNotebooks()
%>
<%
If Not(session("hasAccordInt") And session("regRoleNumber") <= 15) Then
	response.redirect("logout.asp")
End If
%>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="/arxlab/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<script type="text/javascript">
	hasMarvin = <%=LCase(CStr(session("useMarvin"))) %>

	<%If session("useChemDrawForLiveEdit") Then%>
		useChemDrawForLiveEdit = true;
	<%End If%>
</script>

<script type="text/javascript">
	var unchangedList = [];

	function loadStructuresToPopup(counter,numHits){
		for (i=1;i<numHits+1;i++ ){
			updateLiveEditStructureData("mol_mycdx_"+counter+"_"+i,document.getElementById("mol_"+counter+"_"+i+"_molData").value,"chemical/x-mdl-molfile")
		}
	}

function showPopupAccordIntegration(popupId){
	//show transparent black div that covers page.  frame is there to help with pesky elements that ignore z-index
	document.getElementById("blackDiv2").style.position = "fixed"
	document.getElementById("blackDiv2").style.height = document.body.clientHeight+"px";
	document.getElementById("blackDiv2").style.display = "block";

	//not used
	divH = 340
	divW = 340

	//document.getElementById(popupId).style.height=document.getElementById(popupId).parentNode.parentNode.parentNode.offsetHeight+"px";

	t = ((document.documentElement.offsetHeight) / 2 - (divH/2))
	l = (document.documentElement.clientWidth) / 2 - (divW/2)

	//show popup
	document.getElementById(popupId).style.display = "block";
	structureNumber = popupId.split("_")[2]
	window.onscroll = function(){loadStructuresToPopup(structureNumber,document.getElementById('mol_'+structureNumber+"_num_hits"))}
}

function hidePopupAccordIntegration(popupId){	
	//hide popup and black div and frame
	document.getElementById("blackDiv2").style.display = "none";
	document.getElementById("blackFrame2").style.display = "none";
	document.getElementById(popupId).style.display = "none"
	window.onscroll = function(){};
}
function selectNewCompound(x,hc){
	document.getElementById('mol_'+x+'_newCompound').value='true';hidePopupAccordIntegration('mol_popup_'+x);
	for(i=0;i<50;i++){
		if(document.getElementById('mol_'+x+'_'+i+'_frn_text')){
			document.getElementById('mol_'+x+'_'+i+'_frn_text').className = document.getElementById('mol_'+x+'_'+i+'_frn_text').className.replace('selected','').trim();
		}
	}
	document.getElementById('mol_'+x+'_'+hc+'_frn_text').className += ' selected';
	document.getElementById('mol_'+x+'_frn').value = "";
	updateLiveEditStructureData('mol_mycdx_'+x,document.getElementById('mol_'+x+'_molData_original').value,'chemical/x-mdl-molfile');
	document.getElementById('mol_'+x+'_molData').value = document.getElementById('mol_'+x+'_molData_original').value;
}

function selectRegNumber(c,hc){
	updateLiveEditStructureData('mol_mycdx_'+c,document.getElementById('mol_'+c+'_'+hc+'_molData').value,'chemical/x-mdl-molfile');
	for(i=0;i<50;i++){
		if(document.getElementById('mol_'+c+'_'+i+'_frn_text')){
			document.getElementById('mol_'+c+'_'+i+'_frn_text').className = document.getElementById('mol_'+c+'_'+i+'_frn_text').className.replace("selected","").trim();
		}
	}
	document.getElementById('mol_'+c+'_'+hc+'_frn_text').className += ' selected';
	document.getElementById('mol_selected_reg_number_'+c).value = hc;
	document.getElementById('mol_'+c+'_frn').value = document.getElementById('mol_'+c+'_'+hc+'_frn_text').innerHTML;
	document.getElementById('mol_'+c+'_molData').value = document.getElementById('mol_'+c+'_'+hc+'_molData').value
}

function formValidate(){
	document.getElementById("submitRequestButton").disabled = true;
	document.getElementById("submitRequestButton").value = "Processing...";

	errorStr = "";
	noNotebookGroupError = false;
	noRegSelectedError = false;
	noNotebookError = false;

	$.each($(".accord_compound_row"), function(j, obj) {
		var i = j+1;
		var newCompound = "true";
		if(document.getElementById("mol_"+i+"_newCompound") !== null)
			newCompound = document.getElementById("mol_"+i+"_newCompound").value;
		included = document.getElementById("mol_"+i+"_included").checked;
		if(newCompound != "true"){
			selectedRegNumber = document.getElementById("mol_selected_reg_number_"+i).value
			if (selectedRegNumber == "0" && !noRegSelectedError && included){
				noRegSelectedError = true;
				errorStr += "Please select a reg number for all selected compounds.<br/>"
			}
		}
	});
	
	notebookId = document.getElementById("notebookId").value;
	if (notebookId == "-1" && !noNotebookError && included){
		noNotebookError = true;
		errorStr += "Please select a Notebook<br/>"
	}
	
	<%
	requireGroupFieldForNotebook = checkBoolSettingForCompany("requireGroupNameInNotebookName", session("companyId"))
	If requireGroupFieldForNotebook Or (autoNumberNotebooks And groupNameInNotebook) then%>
	notebookGroupId = document.getElementById("notebookGroup").value;
	if (notebookGroupId == "-1" && !noNotebookGroupError && included){
		noNotebookGroupError = true;
		errorStr += "Please select a Group for your Notebook<br/>"
	}
	<%End If%>
	
	document.getElementById("errorDiv").innerHTML = errorStr;
	if(errorStr != ""){
		document.getElementById("submitRequestButton").disabled = false;
		document.getElementById("submitRequestButton").value = "Submit";
		window.scrollTo(0,0);
	}
	else{
		document.getElementById("theForm").submit();
	}
}

</script>

<h1><%=requestCompoundsLabel%></h1>

<%
fid = request.querystring("fid")
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT m.id, m.structure from accMols m INNER JOIN accUploads u ON m.uploadId = u.id WHERE u.fid="&SQLClean(fid,"T","S")&" AND u.userId="&SQLClean(session("userId"),"N","S")
rec.open strQuery,jchemRegConn,3,3
%>
<iframe style="display:none;background-color:black;z-index:99;width:100%;height:100%;top:0;left:0;position:absolute;background:rgba(1,0,0,.7);filter: alpha(opacity = 0);border:none;" id="blackFrame2" src="javascript:false;"></iframe>
<div style="display:none;background-color:black;z-index:100;width:100%;height:100%;top:0;left:0;position:absolute;background:rgba(0,0,0,.7);filter: alpha(opacity = 80);" id="blackDiv2"></div>
<form method="post" action="register_compounds.asp" id="theForm">
<table class="experimentsTable">
	<tr>
		<th>
			Structure
		</th>
		<th>
			Foreign Reg Number
		</th>
		<th>
			CpdId/Notebooks
		</th>
		<th>
			Include
		</th>
	</tr>
	<tr>
		<td colspan="4">
			<div id="errorDiv" style="color:red;">
			
			</div>
		</td>
	</tr>
<%
counter = 0
Do While Not rec.eof
	counter = counter + 1
	%>
	<tr class="accord_compound_row">
		<td>
		  <script type="text/javascript">
			var thisId = "mol_mycdx_<%=counter%>";
			var holderDivId = "mol_mycdx_<%=counter%>_holder";
			document.write('<div id="'+holderDivId+'"></div>');
			
			$.ajax({
				url: '<%=mainAppPath%>/accint/getCDXRegistrar.asp?id=<%=rec("id")%>',
				type: 'GET',
                thisId1: thisId,
                holderDivId1: holderDivId, 
				success: function(data)
				{
					console.log("getCDXRegistrar success");
                    var holderDivId2 = this.holderDivId1;
                    getChemistryEditorMarkup(this.thisId1, "", data, 200, 200, true).then(function (theHtml) {
                        $("#" + holderDivId2).html(theHtml);
                    });
				},
				error: function(error, textStatus, errorThrown)
				{
					console.error("ERROR in getCDXRegistrar.asp");
					//nothing for now
				},
				complete: function()
				{
				}
			 });
          </script>
		</td>
		<td>
			<input type="hidden" id="mol_<%=counter%>_id" name="mol_<%=counter%>_id" value="<%=rec("id")%>">
			<input type="hidden" id="mol_<%=counter%>_molData" name="mol_<%=counter%>_molData">
			<input type="hidden" id="mol_<%=counter%>_molData_original" name="mol_<%=counter%>_molData_original" value='<%=Server.HTMLEncode(rec("structure"))%>'>
			<%
			structure = rec("structure")
			xmlStr = searchAccordStructures(structure)
			'response.write("z"&xmlStr&"z")
			Set xml = server.CreateObject("Microsoft.XMLDOM")
			xml.loadXML(xmlStr)
			'response.write(xmlStr)
			For Each oNode In xml.SelectNodes("/results")
				For Each subNode In oNode.getElementsByTagName("result")
					Set existNodes = subNode.getElementsByTagName("exists")
					If existNodes.length = 1 Then
						If LCase(existNodes(0).childNodes(0).nodeValue) = "true" Then
							%>
							<input type="hidden" class="accord_new_compound" name="mol_<%=counter%>_newCompound" id="mol_<%=counter%>_newCompound" value="false">
							<%
							Set hitsNode = subNode.getElementsByTagName("hits")
							If hitsNode.length = 1 Then
								hitCounter = 0
								numHits = hitsNode(0).getElementsByTagName("hit").length
								For Each hitNode In hitsNode(0).getElementsByTagName("hit")
									hitCounter = hitCounter + 1
									Set foreignRegNumberNode = hitNode.getElementsByTagName("foreignRegNumber")
									Set structureNode = hitNode.getElementsByTagName("structure")
									If foreignRegNumberNode.length = 1 And structureNode.length = 1 then
										foreignRegNumber = foreignRegNumberNode(0).childNodes(0).nodeValue
										molData = structureNode(0).childNodes(0).nodeValue
										%>
											<div id="mol_<%=counter%>_<%=hitCounter%>_frn_text" class="selectFromPopupText<%If numHits=1 then%> selected<%End if%>"><%=foreignRegNumber%></div>
											<input type="hidden" id="mol_<%=counter%>_<%=hitCounter%>_molData" name="mol_<%=counter%>_<%=hitCounter%>_molData" value="<%=molData%>">
										<%
									End if
								Next
								If numHits >= 1 Then
									%>
									<%If numHits > 1 then%>
										<input type="hidden" id="mol_<%=counter%>_frn" name="mol_<%=counter%>_frn" value="">
										<input type="hidden" class="mol_selected_reg_number" id="mol_selected_reg_number_<%=counter%>" name="mol_selected_reg_number_<%=counter%>" value="0">
									<%else%>
										<script type="text/javascript">
											
											var b = function(){
												updateLiveEditStructureData("mol_mycdx_<%=counter%>",document.getElementById("mol_<%=counter%>_1_molData").value,"chemical/x-mdl-molfile");
												document.getElementById("mol_<%=counter%>_molData").value = document.getElementById("mol_<%=counter%>_1_molData").value;
												};
											unchangedList.push(b)
										</script>
										<input type="hidden" id="mol_selected_reg_number_<%=counter%>" name="mol_selected_reg_number_<%=counter%>" value="1">
										<input type="hidden" id="mol_<%=counter%>_frn" name="mol_<%=counter%>_frn" value="<%=foreignRegNumber%>">
									<%End if%>
									<div id="mol_<%=counter%>_<%=hitCounter+1%>_frn_text" class="selectFromPopupText">New Compound</div>
									<input type="button" value="SELECT" style="margin-top:10px;padding:3px;" onclick="window.scrollTo(0,0);showPopupAccordIntegration('mol_popup_<%=counter%>');loadStructuresToPopup(<%=counter%>,<%=numHits%>);">
									<%
								%>
<div style="width:850px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0px;z-index:101;" id="mol_popup_<%=counter%>" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopupAccordIntegration('mol_popup_<%=counter%>');return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif"></a>
									<table class="experimentsTable">
										<tr>
											<th>
												Structure
											</th>
											<th>
												Metadata
											</th>
											<th>
												&nbsp;
											</th>
										</tr>

									<%
									hitCounter = 0
									For Each hitNode In hitsNode(0).getElementsByTagName("hit")
										hitCounter = hitCounter + 1
										Set foreignRegNumberNode = hitNode.getElementsByTagName("foreignRegNumber")
										Set structureNode = hitNode.getElementsByTagName("structure")
										If foreignRegNumberNode.length = 1 And structureNode.length = 1 then
											foreignRegNumber = foreignRegNumberNode(0).childNodes(0).nodeValue
											molData = structureNode(0).childNodes(0).nodeValue
											%>
												<tr>
													<td style="width:210px;">
														<div id="holder_mol_mycdx_<%=counter%>_<%=hitCounter%>">
														</div>
														<script type="text/javascript">
                                                            getChemistryEditorMarkup("mol_mycdx_<%=counter%>_<%=hitCounter%>", "", "", 200, 200, true).then(function (theHtml) {
                                                                $("#holder_mol_mycdx_<%=counter%>_<%=hitCounter%>").html(theHtml);
                                                            });
                                                        </script>
													</td>
													<td>
														<table>
															<tr>
																<td>
																	Reg Number
																</td>
																<td>
																	<%=foreignRegNumber%>
																</td>
															</tr>
															<%
															For Each fieldNode In hitNode.getElementsByTagName("field")
																%>
																<tr>
																	<td>
																		<%=fieldNode.getElementsByTagName("name")(0).childNodes(0).nodeValue%>
																	</td>
																	<td>
																		<%=fieldNode.getElementsByTagName("value")(0).childNodes(0).nodeValue%>
																	</td>
																</tr>
																<%
															next
															%>
														</table>
													</td>
													<td>
														<input type="button" value="SELECT" style="margin-top:10px;padding:3px;" onclick="selectRegNumber(<%=counter%>,<%=hitCounter%>);hidePopupAccordIntegration('mol_popup_<%=counter%>');">
													</td>
												</tr>
											<%
										End if
									Next
									%>
									<tr>
										<td colspan="3" align="right">
											<input type="button" style="margin-top:10px;padding:3px;" value="New Compound" onclick="selectNewCompound(<%=counter%>,<%=hitCounter+1%>)">
										</td>
									</tr>
									<tr>
										<td colspan="3">
											<iframe style="background-color:white;z-index:103;width:100%;height:<%=205*rec.recordCount-counter%>px;border:none;" src="javascript:false;"></iframe>
										</td>
									</tr>
									</table>
									</div>
									<%
								End if
							End if
						Else
							%>
							<div id="mol_<%=counter%>_<%=hitCounter%>_frn_text" class="selectFromPopupText selected">New Compound</div>
							<input type="hidden" id="mol_<%=counter%>_newCompound" name="mol_<%=counter%>_newCompound" value="true">
							<script type="text/javascript">
								b = function(){
									document.getElementById("mol_<%=counter%>_molData").value = '<%=replace(rec("structure"),vbcrlf,"\n")%>';
								};
								unchangedList.push(b)
							</script>
							<%
						End If
						%>
						<%If numHits <> 0 then%>
							<input type="hidden" id="mol_<%=counter%>_newCompound" name="mol_<%=counter%>_newCompound" value="false">
						<%End if%>
						<input type="hidden" id="mol_<%=counter%>_num_hits" name="mol_<%=counter%>_num_hits" value="<%=numHits%>">
						<%
					End if
				Next
			Next
			%>
		</td>
		<td>
			<%
			s = rec("structure")
			Set strucSearchResults = JSON.parse(searchStructureInReg(s))
			localRegNumber = strucSearchResults.get("localRegNumber")
			Set notebookNames = strucSearchResults.get("notebookNames")
			%>
			<%=localRegNumber%><br/>
			<%
			for notebookIndex = 0 to len(notebookNames)
				notebookName = notebookNames.get(notebookIndex)
				if notebookName <> "" then
					%>
					<%=notebookName%><br/>
					<%
				end if
			next
			%>
		</td>
		<td>
			<input type="checkbox" class="accord_compound_included" id="mol_<%=counter%>_included" name="mol_<%=counter%>_included" checked>
		</td>
	</tr>
	<%
	rec.movenext
loop
Call disconnectJchemReg
%>
<tr>
	<td colspan="4">
		<div style="float:right;">
			<label for="notebookId">Notebook</label>
			<select name="notebookId" id="notebookId" style="margin-left:10px;width:220px;" onchange="if(this.options[this.selectedIndex].value=='0'){document.getElementById('notebookDescriptionRow').style.display='table-row';document.getElementById('notebookGroupRow').style.display='table-row'}else{{document.getElementById('notebookDescriptionRow').style.display='none';document.getElementById('notebookGroupRow').style.display='none';}}">
				<option value="-1">---SELECT---</option>
				<%If canCreateNotebook(session("user")) And hasAutoNumberNotebooks then%>
					<option value="0">NEW NOTEBOOK</option>
				<%End if%>
				<%
				Call getconnected
				Set notebookRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM notebookView where companyId="&SQLClean(session("companyId"),"N","S")
				If session("email") <> "support@arxspan.com" Then
					strQuery = strQuery & " AND userId="&SQLClean(session("userId"),"N","S")
				End If
				strQuery = strQuery & " ORDER BY name"
				notebookRec.open strQuery,conn,3,3
				Do While Not notebookRec.eof
					%>
						<option value="<%=notebookRec("id")%>"><%=notebookRec("name")%></option>
					<%
					notebookRec.movenext
				Loop
				Call disconnect
				%>
			</select>
		</div>
		<div style="height:0px;clear:both;"></div>
	</td>
</tr>

<tr id="notebookGroupRow">
<%
useGroupFieldForNotebook = checkBoolSettingForCompany("useGroupNameInNotebookName", session("companyId"))
If useGroupFieldForNotebook then
%>
	<td colspan="4">
		<div style="float:right;">
			<label for=""><span >Group<%If requireGroupFieldForNotebook Or (autoNumberNotebooks And groupNameInNotebook) then%>*<%End if%></span></label>
			<br/>
			<select name="notebookGroup" id="notebookGroup" style="width:300px;margin-left:12px;">
				<%thisGroupId= request.Form("notebookGroup")%>
				<!-- #include file="../_inclds/selects/groupSelectOptions.asp"-->
			</select>
			<br/>
		</div>
		<div style="height:0px;clear:both;"></div>
	</td>
<%End if%>
</tr>

<tr id="notebookDescriptionRow" id="notebookDescriptionRow" style="display:none;">
	<td colspan="4">
		<div style="float:right;">
			<div><label for="notebookDescription" style="padding-top:3px;vertical-align:top;">Notebook Description</label>
			<textarea id="notebookDescription" name="notebookDescription" style="margin-left:10px;width:210px;height:40px;display:inline;"></textarea>
			</div>
		</div>
		<div style="height:0px;clear:both;"></div>
	</td>
</tr>

<tr>
	<td colspan="4">
		<div style="float:right;">
			<label for="notebookId">Project</label>
			<select name="projectName" id="projectName" style="margin-left:10px;width:220px;">
				<option value="NONE">---SELECT---</option>
				<option value="856NG">856NG</option>
				<option value="ADENOSINE">ADENOSINE</option>
				<option value="AFRAXIS01">AFRAXIS01</option>
				<option value="ALPHA7">ALPHA7</option>
				<option value="ANTI-BACTERIAL">ANTI-BACTERIAL</option>
				<option value="ANTI-FUNGAL">ANTI-FUNGAL</option>
				<option value="ANTI-INFLAMMATORY">ANTI-INFLAMMATORY</option>
				<option value="BARR2">BARR2</option>
				<option value="CGRP">CGRP</option>
				<option value="CHARYBDIS">CHARYBDIS</option>
				<option value="CLINICAL">CLINICAL</option>
				<option value="CNS">CNS</option>
				<option value="COMT">COMT</option>
				<option value="DAAO">DAAO</option>
				<option value="DEVELOPMENT">DEVELOPMENT</option>
				<option value="DNG">DNG</option>
				<option value="DOPAMINE D2">DOPAMINE D2</option>
				<option value="DRD01 - TAAR1">DRD01 - TAAR1</option>
				<option value="EVOTEC SCREEN">EVOTEC SCREEN</option>
				<option value="FXR">FXR</option>
				<option value="GABA-A">GABA-A</option>
				<option value="GABA-B">GABA-B</option>
				<option value="GLIAL ACTIVATION">GLIAL ACTIVATION</option>
				<option value="H1">H1</option>
				<option value="H3">H3</option>
				<option value="Ion channel PCL">Ion channel PCL</option>
				<option value="LEGACY">LEGACY</option>
				<option value="LIBRARY - PHENOTYPIC">LIBRARY – PHENOTYPIC</option>
				<option value="LUNESTA">LUNESTA</option>
				<option value="MGLUR5 NAM">MGLUR5 NAM</option>
				<option value="MGLUR5 PAM">MGLUR5 PAM</option>
				<option value="NONE">NONE</option>
				<option value="NOP">NOP</option>
				<option value="NPS">NPS</option>
				<option value="OREXIN">OREXIN</option>
				<option value="P2X3">P2X3</option>
				<option value="P2X4">P2X4</option>
				<option value="P2X7">P2X7</option>
				<option value="PANLABS SCREEN">PANLABS SCREEN</option>
				<option value="PDE10">PDE10</option>
				<option value="PDE1B">PDE1B</option>
				<option value="PGI">PGI</option>
				<option value="PGI00 - LIBRARY">PGI00 - LIBRARY</option>
				<option value="PGI01 - PSYCHOSIS">PGI01 - PSYCHOSIS</option>
				<option value="PGI02 - PSYCHOSIS">PGI02 - PSYCHOSIS</option>
				<option value="PGI03 - TRD">PGI03 - TRD</option>
				<option value="PGI04 - BD">PGI04 - BD</option>
				<option value="PGI05 - 856 BU">PGI05 - BU</option>
				<option value="PGI06 - PS LIBRARY">PGI06 - PS LIBRARY</option>
				<option value="PGI07 - UNKN">PGI07 - UNKN</option>
				<option value="PGI08 - POLYPHARM">PGI08 - POLYPHARM</option>
				<option value="PGI09 - EPILEPSY">PGI09 - EPILEPSY</option>
				<option value="PGI10 - EXPLORATORY">PGI10 - EXPLORATORY</option>
				<option value="PGI11 - EXSCIENTIA">PGI11 – EXSCIENTIA</option>
				<option value="PGI12 - AD SYMPTOM">PGI12 - AD SYMPTOM</option>
				<option value="POLYPHARMACOLOGY">POLYPHARMACOLOGY</option>
				<option value="PROTEASE">PROTEASE</option>
				<option value="REFERENCE">REFERENCE</option>
				<option value="SULPRIDES">SULPRIDES</option>
				<option value="TAP">TAP</option>
				<option value="ZNG">ZNG</option>
			</select>
		</div>
		<div style="height:0px;clear:both;"></div>
	</td>
</tr>

</table>
<input type="hidden" name="numMols" id="numMols" value="<%=counter%>">
<div width="800" align="right">
<input type="button" value="Submit" style="margin-top:10px;padding:2px;" onclick="formValidate();return false;" id="submitRequestButton"/>
</div>
</form>
<script type="text/javascript">
	function runUnchangedList(){
		for (i=0;i<unchangedList.length ;i++){
			unchangedList[i]();
		}
	}
	
	getChemistryEditorChemicalStructure("mol_mycdx_<%=counter%>",false).then(function(md){
		if (md != ""){
				for (i=0;i<unchangedList.length ;i++){
					unchangedList[i]();
				}
		}
	});
</script>
<!-- #include file="../_inclds/footer-tool.asp"-->