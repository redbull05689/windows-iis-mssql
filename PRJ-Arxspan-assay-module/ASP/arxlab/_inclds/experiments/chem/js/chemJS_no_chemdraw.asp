<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
hasCombi = checkBoolSettingForCompany("hasCombi", session("companyId"))
if ownsExp and revisionId = "" then%>
<%'add grid calculations%>
<script type="text/javascript">
var defaultMolUnits = '<%=session("defaultMolUnits")%>';
</script>
<script type="text/javascript" src="<%=mainAppPath%>/js/newGrid.js?<%=jsRev%>" charset="utf-8"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/big.min.js?<%=jsRev%>"></script>
<%

 gridCutoff = getCompanySpecificSingleAppConfigSetting("stoichGridFeatureCutoverPoint", session("companyId"))
 gridCutoff = normalizeIntSetting(gridCutoff)
 if session("useMarvin") THEN %>
	<script type="text/javascript" src="<%=mainAppPath%>/_inclds/experiments/chem/js/rxnSubmit.js?<%=jsRev%>"></script>
<% end if %>
<%else%>
<script type="text/javascript">
var UAStates = {};
function loadUAStates(prefix){
	var stateString = '{}';
	var obj = document.getElementById(prefix + "_UAStates");
	if (obj) {
		stateString = obj.value;
    }
	if (!stateString || stateString == '{}'){
		UAStates[prefix] = {};
	}else{
		UAStates[prefix] = eval('('+stateString+')');
	}
	setRowColors(prefix);
}

function setRowColors(prefix){
	for(textboxId in UAStates[prefix]){
		if(UAStates[prefix][textboxId]){
			el = document.getElementById(prefix+"_"+textboxId).parentNode
			for (i=0;i<el.childNodes.length;i++){
				if (el.childNodes[i].className=="stochDataDiv"){
					el2 = el.childNodes[i];
					el2.style.color = "green";
					el2.style.fontWeight = "bold";
				}
			}
		}else{
			el = document.getElementById(prefix+"_"+textboxId).parentNode
			for (i=0;i<el.childNodes.length;i++){
				if (el.childNodes[i].className=="stochDataDiv"){
					el2 = el.childNodes[i];
					el2.style.color = "black";
					el2.style.fontWeight = "normal";
				}
			}
		}
	}
    var obj = document.getElementById(prefix + "_UAStates");
	if (obj) {
		obj.value = JSON.stringify(UAStates[prefix]);
	}
}
</script>
<%End if%>
<script type="text/javascript">
<%If hungSaveSerial = "" Then%>
var hungSaveSerial = Math.random().toString().replace('.','');
<%Else%>
var hungSaveSerial = <%=hungSaveSerial%>;
<%End If%>
function getSaveSerial()
{
	return hungSaveSerial;
}
<%if session("showFullChemicalNameInQuickView") then%>
	var fullChemicalName = true;
<%else%>
	var fullChemicalName = false;
<%end if%>
<%if revisionId = "" then%>
<% 
set nrRec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT id FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")
if not ownsExp then
	strQuery = strQuery & " and (isDraft<>1 or isDraft is null)"
end if
nrRec.open strQuery,conn,3,3
%>
var numReactants = <%=nrRec.RecordCount%>;
<%
nrRec.close
strQuery = "SELECT id FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
if not ownsExp then
	strQuery = strQuery & " and (isDraft<>1 or isDraft is null)"
end if
nrRec.open strQuery,conn,3,3
%>
var numReagents = <%=nrRec.RecordCount%>;
<%
nrRec.close
strQuery = "SELECT id FROM products WHERE experimentId="&SQLClean(experimentId,"N","S")
if not ownsExp then
	strQuery = strQuery & " and (isDraft<>1 or isDraft is null)"
end if
nrRec.open strQuery,conn,3,3
%>
var numProducts = <%=nrRec.RecordCount%>;
<%
nrRec.close
strQuery = "SELECT id FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S")
if not ownsExp then
	strQuery = strQuery & " and (isDraft<>1 or isDraft is null)"
end if
nrRec.open strQuery,conn,3,3
%>
var numSolvents = <%=nrRec.RecordCount%>;
<%
nrRec.close
set nrRec = nothing
%>
<%else%>
<% 
set nrRec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT id FROM reactants_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " and revisionId=" & SQLClean(revisionId,"N","S")
nrRec.open strQuery,conn,3,3
%>
var numReactants = <%=nrRec.RecordCount%>;
<%
nrRec.close
strQuery = "SELECT id FROM reagents_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " and revisionId=" & SQLClean(revisionId,"N","S")
nrRec.open strQuery,conn,3,3
%>
var numReagents = <%=nrRec.RecordCount%>;
<%
nrRec.close
strQuery = "SELECT id FROM products_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " and revisionId=" & SQLClean(revisionId,"N","S")
nrRec.open strQuery,conn,3,3
%>
var numProducts = <%=nrRec.RecordCount%>;
<%
nrRec.close
strQuery = "SELECT id FROM solvents_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " and revisionId=" & SQLClean(revisionId,"N","S")
nrRec.open strQuery,conn,3,3
%>
var numSolvents = <%=nrRec.RecordCount%>;
<%
nrRec.close
set nrRec = nothing
%>
<%end if%>

var saveInProgress = false;
var chemDrawChanged = false;

<!-- #include file="../../common/js/experimentLinksJS.asp"-->
<!-- #include file="../../common/js/experimentCommonJS.asp"-->
<!-- #include file="../../../common/js/uploadJS.asp"-->

var startSmiles = ""
var startSmilesSet = false

var doChemChangeCheck = true
<%if cdxData = "" then%>
	startedBlank = true
	startSmilesSet = true
<%else%>
	startedBlank = false
	startSmiles = ""
	startSmilesSet = false
<%end if%>

<%if draftSet("chemDrawChanged","0")="1" then%>
	doChemChangeCheck = false;
	unsavedChanges = true 
	chemDrawChanged = true
<%end if%>

chemDrawHasFocus = false
var gssInterval = window.setInterval("checkForChemistryChanges(false)",2000);

function convertToMarvin(){
	getChemistryEditorChemicalStructure("mycdx", false, "mrv").then(function (mrvData) {
		$.post("/arxlab/_inclds/experiments/chem/asp/chemDataMarvin.asp",{mrvData: mrvData, molData: "", experimentId: <%=experimentId%>, experimentJSON: JSON.stringify(experimentJSON)});
	});
}

<% if session("useMarvin") THEN %>
$(function() {
	var convertToMarvinInterval = null;
	convertToMarvinInterval = setInterval(function(){
		//console.log("Are we ready yet?");
		if (marvinReady){
			//console.log("Ready!");
			clearInterval(convertToMarvinInterval);
			
			if (!mrvData) {  // only call convert to Marvin if we dont have mrvData already...
				convertToMarvin();
			}
		}
	},200);
});

<% END IF %>

function setChemDrawChanged(hasChanged)
{
	if(hasChanged)
	{
		unsavedChanges = true;
		chemDrawChanged = true;
		sendAutoSave("chemDrawChanged","1");
		experimentJSON["chemDrawChanged"] = "1";
		document.getElementById("chemDrawChanged").value = "1";
		document.getElementById("makeNextStepButton").style.display = "none";
	}
	else
	{
		chemDrawChanged = false;
		experimentJSON["chemDrawChanged"] = "0";
		document.getElementById("chemDrawChanged").value = "0";
		document.getElementById("makeNextStepButton").style.display = "block";
	}
}

function initializeChemistryChanges()
{
	return new Promise(function(resolve, reject) {
		try
		{
			getChemistryEditorChemicalStructure("mycdx", false).then(function(currentSmiles){
				gssInterval = window.setInterval("checkForChemistryChanges(false)",1000);
				startSmiles = currentSmiles;
				setChemDrawChanged(false);
				draftHasUnsavedChanges = false;
				unsavedChanges = false;
				hideUnsavedChanges();	
				resolve();
			});
			
		}
		catch(err)
		{
			console.log("initializeChemistryChanges() - chemdraw not active");
			reject();
		}
	});
}

function checkForChemistryChanges(override)
{
return new Promise(function(resolve, reject) {
	<%If canWrite And ownsExp Then%>
		if(doChemChangeCheck && (!chemDrawHasFocus || override == true))
		{
			try{
				getChemistryEditorChemicalStructure("mycdx", false).then(function(currentSmiles){
					autoSavePromiseArray = [];
					if(currentSmiles == null || currentSmiles == "<cml><MDocument></MDocument></cml>"){
						currentSmiles = "";
					}
					
					firstChar = currentSmiles.substring(0,1);

					if (firstChar == "#")
					{
                        unsavedChanges = false;
						doChemChangeCheck = false;
						alert("Your version of the ChemDraw Plugin is not supported. Please use the Upload File button to add a reaction.")
						window.location.replace(window.location.href.replace("experiment.asp", "experiment_no_chemdraw.asp"));
					}

					if (startedBlank && !chemDrawChanged && currentSmiles != "")
					{
		//				console.log("checkForChemistryChanges case 1");
						setChemDrawChanged(true);
						if (currentSmiles != "" && startedBlank)
						{
		//					console.log("checkForChemistryChanges case 1a");
							startedBlank = false;
							startSmiles = currentSmiles;
							autoSavePromiseArray.push(sendAutoSave("cdxml",currentSmiles));
							<% if session("useMarvin") THEN %>
								autoSavePromiseArray.push(sendAutoSave("mrvData" , currentSmiles));
							<% else %>
								autoSavePromiseArray.push(sendAutoSave("mrvData" , "")); //Clear this out so marvin uses the cdxml
							<% end if %>
						}
					}
					if (currentSmiles != "" && !startedBlank && !startSmilesSet)
					{
		//				console.log("checkForChemistryChanges case 2");
						startSmiles = currentSmiles
						startSmilesSet = true
					}
					if (startSmilesSet)
					{
		//				console.log("checkForChemistryChanges case 3");
						if (currentSmiles != startSmiles)
						{
		//					console.log("checkForChemistryChanges case 3a");
							setChemDrawChanged(true);
		//					console.log("checkForChemistryChanges case 3b");
							startedBlank = false;
							startSmiles = currentSmiles;
							autoSavePromiseArray.push(sendAutoSave("cdxml",currentSmiles));
							<% if session("useMarvin") THEN %>
								autoSavePromiseArray.push(sendAutoSave("mrvData" , currentSmiles));
							<% else %>
								autoSavePromiseArray.push(sendAutoSave("mrvData" , "")); //Clear this out so marvin uses the cdxml
							<% end if %>
							
						}
					}
					Promise.all(autoSavePromiseArray).then(function(){
						resolve();
					})
				}).catch(function(error){
					console.log("checkForChemistryChanges getChemistryEditorChemicalStructure error: ", error);
				});
			}
			catch(err)
			{
		//		console.log("checkForChemistryChanges error: ", err);
			}
		}
	<%else%>
	//	console.log("checkForChemistryChanges returns true");
		resolve(false);
	<%end if%>
	});
}

experimentTypeName = "<%=GetAbbreviation(experimentType)%>"
</script>
<script type="text/javascript">
	function newDraftMol(type,fragmentId,labelName){
		return new Promise(function(resolve, reject) {
			if (!(experimentId === parseInt(experimentId))){
				if(experimentId==undefined){
					experimentId = document.getElementById("experimentId").value;
					experimentType = document.getElementById("experimentType").value;
				}else{
					experimentId = experimentId.value;experimentType = experimentType.value;
				}
			}
			
			$.ajax({
				method: "POST",
				url: "<%=mainAppPath%>/experiments/ajax/do/newDraftMol.asp",
				data: {"type":type,"experimentId":experimentId,"fragmentId":fragmentId,"labelName":labelName},
			})
			.done(function(response) {
				resolve(true);
			});
		});
	}
</script>

<script type="text/javascript">
	var attachments = [];
	var mainTabs = ['reactionDiv'];
	var notes = []
	<%if hasAttachments then%>
		mainTabs.push('attachmentTable')
	<%end if%>
	<%if hasNotes then%>
		mainTabs.push('noteTable')
	<%end if%>

	var reactants = [];
	var products = [];
	var reagents = [];
	var mols = [];
	var currentTab = "";
	var currentMainTab = "";
	var mainTabSelected = "reactionDiv";
	<%if request.querystring("id") <> "" then%>
		var id = <%=request.querystring("id")%>;
	<%else%>
		var id = '';
	<%end if%>
	<%if request.querystring("revisionId") <> "" then%>
		var revisionId = <%=request.querystring("revisionId")%>;
	<%else%>
		var revisionId = '';
	<%end if%>


function showMainDiv(divId)
{
	foundIt = false
	for (i=0;i<mainTabs.length ;i++ )
	{
		if (mainTabs[i] != divId)
		{
			try
			{
				document.getElementById(mainTabs[i]).style.left='-5000px';
				document.getElementById(mainTabs[i]+"_tab").className = ""
			}
			catch(err){}
		}
		else
		{
			try
			{
				foundIt = true
				document.getElementById(mainTabs[i]).style.left='0px';
				document.getElementById(mainTabs[i]+"_tab").className = "tabSelected selectedTab"
				currentMainTab = mainTabs[i]
				helpId = '4'
				if (currentMainTab == 'noteTable')
				{
					helpId = '6'
				}
				if (currentMainTab == 'attachmentTable')
				{
					helpId = '5'
					<%if ownsExp then%>
						el = document.getElementById("uploadFormHolder");
						if (el) {
							elRow = document.getElementById("attachmentTableFileUploadRow")
							if (elRow) {
								elRow.appendChild(el.parentNode.removeChild(el));
							}
							el.style.display = "block";
						}
					<%end if%>
				}

				try
				{
					el = document.getElementById(mainTabs[i]+"_att")
					newSrc = document.getElementById(mainTabs[i]+"_src").innerHTML.replace("&amp;","&")
					oldSrc = el.src.substring(el.src.lastIndexOf('/')+1)
					if (oldSrc == "loading.html" || oldSrc == "loading.gif")
					{
						el.src = newSrc
					}
				}
				catch(err){}
			}
			catch(err){alert(err)}
		}
	}
	if(!foundIt){showMainDiv(mainTabs[0])}	
	mainTabSelected = divId
	positionButtons()
	
	Array.prototype.forEach.call(document.querySelectorAll("iFrame.cke_wysiwyg_frame"), function(element, index, array){
        element.style.width='100%';
    });
}

	/*new*/

	function clearGrid()
	{
		for (i=1;i<=numReactants ;i++ )
		{
			molNode = document.getElementById("r"+i+"_body")
			inputs = molNode.getElementsByTagName("input")
			for(j=0;j<inputs.length;j++)
			{
				if (inputs[j].getAttribute("type") == "text")
				{
					id = inputs[j].getAttribute("id")
					if (id != "r"+i+"_name" && id != "r"+i+"_molecularWeight" && id != "r"+i+"_molecularFormula")
					{
						inputs[j].value = ""
					}
				}
			}
		document.getElementById("r"+i+"_equivalents").value = "1.0"
		}

		for (i=1;i<=numReagents ;i++ )
		{
			molNode = document.getElementById("rg"+i+"_body")
			inputs = molNode.getElementsByTagName("input")
			for(j=0;j<inputs.length;j++)
			{
				if (inputs[j].getAttribute("type") == "text")
				{
					id = inputs[j].getAttribute("id")
					if (id != "rg"+i+"_name" && id != "rg"+i+"_molecularWeight" && id != "rg"+i+"_molecularFormula")
					{
						inputs[j].value = ""
					}
				}
			}
		document.getElementById("rg"+i+"_equivalents").value = "1.0"
		}

		for (i=1;i<=numProducts ;i++ )
		{
			molNode = document.getElementById("p"+i+"_body")
			inputs = molNode.getElementsByTagName("input")
			for(j=0;j<inputs.length;j++)
			{
				if (inputs[j].getAttribute("type") == "text")
				{
					id = inputs[j].getAttribute("id")
					if (id != "p"+i+"_name" && id != "p"+i+"_molecularWeight" && id != "p"+i+"_molecularFormula")
					{
						inputs[j].value = ""
					}
				}
			}
		document.getElementById("p"+i+"_equivalents").value = "1.0"
		}

		for (i=1;i<=numSolvents ;i++ )
		{
			molNode = document.getElementById("s"+i+"_body")
			inputs = molNode.getElementsByTagName("input")
			for(j=0;j<inputs.length;j++)
			{
				if (inputs[j].getAttribute("type") == "text")
				{
					id = inputs[j].getAttribute("id")
					if (id != "s"+i+"_name")
					{
						inputs[j].value = ""
					}
				}
			}
		}

	}

	function showForms()
	{
		<%'show all forms that are hidden before there is a reaction drawn%>
		theTab = "qv";
		if(currentTab != "")
			theTab = currentTab;
		try{displayTab(theTab)}catch(err){}
		document.getElementById("prepTable").style.display="block";
		//document.getElementById("conditionsTable").style.display="block";
		showTR("reactionRow");
		showTR("cdxRow");
	}




	// this is what I care about to fix the quick view data
	function populateWithNewCounts(updateData, autoSave, onSave){
		$.get( "<%=mainAppPath%>/_inclds/experiments/chem/js/getMolCounts.asp", { experimentId: <%=experimentId%>, experimentType: 1, revisionId: "", random: $.now() } )
		.done(function( data ) {
			//console.log("data: " + data);
			numReactants = parseInt(data.numReactants);
			numReagents = parseInt(data.numReagents);
			numProducts = parseInt(data.numProducts);
			numSolvents = parseInt(data.numSolvents);

			populate(updateData, autoSave, onSave);
			$("#marvinLoading").hide();
   		});
	}

	function ensureExperimentLoaded() {
	<%if revisionId = "" then%>
		return new Promise(function (resolve, reject) {
			(function waitForLoaded(){
				result = getFile("<%=mainAppPath%>/ajax_checkers/experimentLoading.asp?id="+<%=experimentId%>+"&rand="+Math.random());
				if (result != "yes"){ 
					return resolve(result);
				}
				setTimeout(waitForLoaded, 100);
			})();
		});
	<% else %>
		return Promise.resolve('{"numReactants": '+ numReactants + ',"numReagents": '+ numReagents + ',"numSolvents": '+ numSolvents + ',"numProducts": '+ numProducts + ',"currLetter": 0}');
	<% end if %>
	}

	function waitPopulate(forceReactionRefresh, populateRevisionId)
	{
		return ensureExperimentLoaded().then(function(result){
			doChemChangeCheck = false;
			//console.log("SET TO FALSE!! doChemChangeCheck = ", doChemChangeCheck);
			
			resultJson = JSON.parse(result);
			numReactants = resultJson["numReactants"];
			numReagents = resultJson["numReagents"];
			numSolvents = resultJson["numSolvents"];
			numProducts = resultJson["numProducts"];
			currLetter = resultJson["currLetter"];

			<%if session("hasInventoryIntegration") Or session("hasCompoundTracking") then%>
				if (typeof experimentJSON == 'undefined'){
					experimentJSON = {};
				}			
				experimentJSON["currLetter"] = currLetter;
				document.getElementById("currLetter").value = currLetter;
			<%end if%>
			
			//console.log("numReactants: ", numReactants);
			//console.log("numReagents: ", numReagents);
			//console.log("numSolvents: ", numSolvents);
			//console.log("numProducts: ", numProducts);
			
			a = result.split(",");
			
			populate(false,false);
			showMainDiv(mainTabSelected);
		}).then(function() {
			populateChemistryDataFields(forceReactionRefresh, populateRevisionId);
		}).then(function() {
				<%if session("hasInventoryIntegration") then%>
				isForSign = false;
				firstRunForSave = true;
				hasMadeInvChanges = false;
				overrideSaveForChemdrawInsert = false;
				<%End If%>
				doChemChangeCheck = true;
				//console.log("SET TO TRUE!! doChemChangeCheck = ", doChemChangeCheck);
				if( typeof CKEDITOR.instances["e_preparation"] !== 'undefined' ) {
					CKEDITOR.instances["e_preparation"].on("change",ckChange);
				}
		});
	}

	function populateChemistryDataFields(forceReload, populateRevisionId)
	{
		return new Promise(function(resolve, reject) {
			if(chemDrawChanged || forceReload)
			{
				$.ajax({
					<% if session("useMarvin") THEN %>
						url: "<%=mainAppPath%>/experiments/ajax/load/getMRV.asp?id=<%=experimentId%>"+"&rand="+Math.random(),
					<% ELSE %>
						url: "<%=mainAppPath%>/experiments/ajax/load/getCDX.asp?id=<%=experimentId%>"+"&rand="+Math.random(),
					<% END IF %>
					type: "GET",
					cache: false
				})
				.success(function(cdxData) {
					document.getElementById("tempCdx").value = cdxData;
					document.getElementById("cdxData").value = cdxData;
					document.getElementById("xmlData").value = cdxData;
					document.getElementById("molData").value = cdxData;
					updateLiveEditStructureData("mycdx",cdxData,"cdxml", true)
					.then(function() {
						initializeChemistryChanges().then(resolve(true));
					}).catch(function() {
						showOverMessage("networkProblem");
						unsavedChanges = true;
					});
				})
				.fail(function() {
					resolve(true);
				});
			}
			else
			{
				resolve(true);
			}
		});
	}

	function setLimitingReagentGridData(key)
	{
		limittingMoles = document.getElementById(key+"_moles").value;
		limittingEquivalents = document.getElementById(key+"_equivalents").value;
		return key;
	}


	/**
	 * Create grid table.
	 *
	 * @param {string} index
	 * @param {string} prefix
	 * @param {string} formParam
	 */
	function addGridTab(index, prefix, formParam)
	{
        divId = prefix + "TableHolder_" + index;
		newEL = document.createElement("div");
        newEL.setAttribute("class", "newEL");
        newEL.setAttribute("id", divId);
        insertAfter(document.getElementById("formDiv"), newEL, document.getElementById("rc_body"));

        return getForm(prefix, index, divId, formParam);
	}

	lastReactants = numReactants;
	lastReagents = numReagents;
	lastSolvents = numSolvents;
	lastProducts = numProducts;
	function populate(updateData, autoSave, onSave)
	{
		//Default parameters, the IE way.
		onSave = onSave || true; 

		// Clear out existing grid tabs
		var prefixes = ["r","rg","s","p"];
		for(var i = 0; i < prefixes.length; i++)
		{
			var j = 0;
			while(true)
			{
				j += 1;
				var bodyId = prefixes[i] + j + "_body";
				
				if($("#"+bodyId).length)
				{
					//console.log("removing existing grid tab");
					$("#"+bodyId).remove();
				}
				else
				{
					break;
				}
			}
		}

        var gridPromises = [];
		var tabsAddedForEdit = [];
		var limitingReagentKey = "";
		document.getElementById("reactionTabs").innerHTML = "";

		for (i = 0; i < numReactants; i++)
		{
			// Get the data from the db, as an HTML table
            gridPromises.push(addGridTab(i + 1, "Reactant", i + 1 > lastReactants));

			<%if ownsExp and revisionId = "" then%>
				tabsAddedForEdit.push("r" + (i+1) + "_body");
			<%end if%>
		}

		for (i = 0; i < numReagents; i++)
		{
			// Get the data from the db, as an HTML table
            gridPromises.push(addGridTab(i + 1, "Reagent", i + 1 > lastReagents));

			<%if ownsExp and revisionId = "" then%>
				tabsAddedForEdit.push("rg" + (i+1) + "_body");
			<%end if%>
		}

		for (i = 0; i < numSolvents; i++)
		{
			// Get the data from the db, as an HTML table
            gridPromises.push(addGridTab(i + 1, "Solvent", i + 1 > lastSolvents));
			
			<%if ownsExp and revisionId = "" then%>
				tabsAddedForEdit.push("s" + (i+1) + "_body");
			<%end if%>
		}

		for (i = 0; i < numProducts; i++)
		{
			// Get the data from the db, as an HTML table
            gridPromises.push(addGridTab(i + 1, "Product", i + 1 > lastProducts));
			
			<%if ownsExp and revisionId = "" then%>
				tabsAddedForEdit.push("p" + (i+1) + "_body");
			<%end if%>
		}

		Promise.all(gridPromises).then(function ()
		{
			document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<li><a href='javascript:void(0)' class='gridTabs' onClick=\"displayTab('qv');return false;\" id='qv_tab' '><%=quickViewLabel%></a></li>";
			document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<li><a href='javascript:void(0)' class='gridTabs' onClick=\"displayTab('rc');return false;\" id='rc_tab' '><%=reactionConditionsLabel%></a></li>";
			for (i = 0; i < numReactants; i++)
			{
				limitStyle = "display:none;";
				try{
					if (document.getElementById("r" + (i + 1) + "_limit").checked) {
                        limitingReagentKey = setLimitingReagentGridData("r" + (i + 1));
						limitStyle = "";
					}
				}catch(err){}
                document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<li><div class='gridTabDiv' onClick=\"displayTab('r"+(i+1)+"');fadeHighlightAtom('r"+(i+1)+"');return false;\" id='r"+(i+1)+"_tab' '><span id='r"+(i+1)+"_tab_text'>Reactant "+(i+1)+"</span><input style='display:none;' type='text' id='r"+(i+1)+"_tab_input'><%if ownsExp and revisionId="" then%><a id='r"+(i+1)+"_tab_link' href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='editTabName(\"r"+(i+1)+"_tab\")'><img id='r"+(i+1)+"_tab_image' border='0' src='images/btn_edit.gif'></a><a href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='deleteTab(\"r"+(i+1)+"\");return false;'><img border='0' style='width:12px;height:12px;' src='images/delete.png' class='png'></a><%end if%></div><span id='r"+(i+1)+"_tabLimit' class='gridTabLimitSpan' style='"+limitStyle+"'>(L)</span></li>"
                if (document.getElementById("r" + (i + 1) +"_trivialName").value != "")
				{
					document.getElementById("r"+(i+1)+"_tab_text").innerHTML = document.getElementById("r"+(i+1)+"_trivialName").value;
				}
			}

            for (i = 0; i < numReagents; i++)
			{
				limitStyle = "display:none;";
				try{
					if (document.getElementById("rg" + (i + 1) + "_limit").checked) {
                        limitingReagentKey = setLimitingReagentGridData("rg" + (i + 1));
						limitStyle = "";
					}
				}catch(err){}
                document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<li><div class='gridTabDiv' onClick=\"displayTab('rg" + (i + 1) + "');fadeHighlightAtom('rg" + (+1) + "');return false;\" id='rg" + (i + 1) + "_tab' '><span id='rg" + (i + 1) + "_tab_text'>Reagent " + (i + 1) + "</span><input style='display:none;' type='text' id='rg" + (i + 1) + "_tab_input'><%if ownsExp and revisionId="" then%><a id='rg" + (i + 1) + "_tab_link' href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='editTabName(\"rg" + (i + 1) + "_tab\")'><img id='rg" + (i + 1) + "_tab_image' border='0' src='images/btn_edit.gif'></a><a href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='deleteTab(\"rg" + (i + 1) + "\");return false;'><img border='0' style='width:12px;height:12px;' src='images/delete.png' class='png'></a><%end if%></div><span id='rg" + (i + 1) + "_tabLimit' class='gridTabLimitSpan' style='" + limitStyle + "'>(L)</span></li>"
                if (document.getElementById("rg" + (i + 1) + "_trivialName").value != "") {
                    document.getElementById("rg" + (i + 1) + "_tab_text").innerHTML = document.getElementById("rg" + (i + 1) + "_trivialName").value;
                }
			}

			for (i = 0; i < numSolvents; i++)
			{
                document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<li><div class='gridTabDiv' onClick=\"displayTab('s"+(i+1)+"');fadeHighlightAtom('s"+(i+1)+"');return false;\" id='s"+(i+1)+"_tab' '><span id='s"+(i+1)+"_tab_text'>Solvent "+(i+1)+"</span><input style='display:none;' type='text' id='s"+(i+1)+"_tab_input'><%if ownsExp and revisionId="" then%><a id='s"+(i+1)+"_tab_link' href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='editTabName(\"s"+(i+1)+"_tab\")'><img id='s"+(i+1)+"_tab_image' border='0' src='images/btn_edit.gif'></a><a href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='deleteTab(\"s"+(i+1)+"\");return false;'><img border='0' style='width:12px;height:12px;' src='images/delete.png' class='png'></a><%end if%></div></li>"
				if (document.getElementById("s"+(i+1)+"_trivialName").value != "")
				{
					document.getElementById("s"+(i+1)+"_tab_text").innerHTML = document.getElementById("s"+(i+1)+"_trivialName").value;
				}
			}

			for (i = 0; i < numProducts; i++)
			{
                document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<li><div class='gridTabDiv' onClick=\"displayTab('p"+(i+1)+"');fadeHighlightAtom('p"+(i+1)+"');return false;\" id='p"+(i+1)+"_tab' '><span id='p"+(i+1)+"_tab_text'>Product "+(i+1)+"</span><input style='display:none;' type='text' id='p"+(i+1)+"_tab_input'><%if ownsExp and revisionId="" then%><a id='p"+(i+1)+"_tab_link' href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='editTabName(\"p"+(i+1)+"_tab\")'><img id='p"+(i+1)+"_tab_image' border='0' src='images/btn_edit.gif'></a><a href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='deleteTab(\"p"+(i+1)+"\");return false;'><img border='0' style='width:12px;height:12px;' src='images/delete.png' class='png'></a><%end if%></div></li>"
				if (document.getElementById("p"+(i+1)+"_trivialName").value != "")
				{
					document.getElementById("p"+(i+1)+"_tab_text").innerHTML = document.getElementById("p"+(i+1)+"_trivialName").value;
				}
			}

			<%if revisionId = "" then%>
				<%if session("hasInventoryIntegration") then%>
					document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<li><a id='addMolInv_tab' href='javascript:void(0)' class='gridTabs' style='width:70px;' onClick=\"showPopup('addMolDivInv');return false;\"  '>+</a></li>"
				<%else%>
					document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<li><a id='addMol_tab' href='javascript:void(0)' class='gridTabs' style='width:20px;' onClick=\"molTypeChange();showPopup('addMolDiv');$('#lean_overlay').hide();$('#overlay_select2Compatible').addClass('makeVisible');return false;\"  '>+</a></li>"
				<%end if%>
				<%if session("hasBarcodeChooser") then%>
                    document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<li><a id='addMolMultiInv_tab' href='javascript:void(0)' class='gridTabs' style='width:70px;' onClick=\"showMultiAddInventoryPopup();return false;\"  '><img src='<%=mainAppPath%>/images/barcode.gif' height='16' style='margin-top:2px;'></a></li>"
				<%end if%>
				<% if session("useMarvin") THEN %>
                    document.getElementById("reactionTabs").innerHTML = document.getElementById("reactionTabs").innerHTML + "<img id='marvinLoading' src='<%=mainAppPath%>/images/loading.gif' class='gridTabs' style='display: none; height: 20px; width: 20px; padding-left: 5px; padding-top: 5px;' />"
				<% end if%>
			<%end if%>

			showForms();
			<%If request.querystring("revisionId") = "" and ownsExp Then%>
				//console.log("checking for limitingReagentKey: ", limitingReagentKey);
		
				<%' Had to add a timeout to make sure the UAStates was loaded before we started using the data. %>
				window.setTimeout("checkForGridChanges('" + limitingReagentKey + "')",600);
		
				$.each(tabsAddedForEdit, function(t, val) {
					attachEdits(document.getElementById(val));
				});

				window.setTimeout("populateQuickView()",100)
			<%end if%>
		
			// Update to the new totals
			lastReactants = numReactants;
			lastReagents = numReagents;
			lastSolvents = numSolvents;
			lastProducts = numProducts;
        });
	}

	function checkForGridChanges(limitingReagentKey){
		if(limitingReagentKey != "" && UAStates[limitingReagentKey])
		{
			//console.log("checking ua states");
			if(UAStates[limitingReagentKey]["sampleMass"]) {
				var fncStr = "gridFieldChanged(document.getElementById('" + limitingReagentKey + "_sampleMass" + "'))"
				//console.log("triggering sampleMass function: ", fncStr);
				window.setTimeout(fncStr,500);
			}
			if(UAStates[limitingReagentKey]["volume"]) {
				var fncStr = "gridFieldChanged(document.getElementById('" + limitingReagentKey + "_volume" + "'))"
				//console.log("triggering volume function: ", fncStr);
				window.setTimeout(fncStr,500);
			}

			if(UAStates[limitingReagentKey]["moles"]) {
				var fncStr = "gridFieldChanged(document.getElementById('" + limitingReagentKey + "_moles" + "'))"
				//console.log("triggering moles function: ", fncStr);
				window.setTimeout(fncStr,500);
			}

			if(UAStates[limitingReagentKey]["equivalents"]) {
				var fncStr = "gridFieldChanged(document.getElementById('" + limitingReagentKey + "_equivalents" + "'))"
				//console.log("triggering equivalents function: ", fncStr);
				window.setTimeout(fncStr,500);
			}
		}
	}

	function experimentSubmit(approve,sign,autoSave,saveOverride,refreshPageAfterSave)
	{
		return new Promise(function(resolve, reject) {
			console.log("CHEMJS_NO_CHEMDRAW.ASP experimentSubmit()");
			prefixes = ['r','rg','s','p'];

			useMarvin = false;
			<% if session("useMarvin") then %>
				useMarvin = true;
			<% end if %>			

			for(var k=0;k<prefixes.length;k++){
				for (i=0;i<30 ;i++ ){
					prefix = prefixes[k]+i;
					if (document.getElementById(prefix+"_tab")){
						experimentJSON[prefix+"_UAStates"] = JSON.stringify(UAStates[prefix]);
						els = document.getElementById(prefix+"_body").getElementsByTagName("input")
						for(j=0;j<els.length;j++){
							if(els[j].getAttribute("type")=="text" || (els[j].id==prefix+"_UAStates" && !useMarvin)) {
								experimentJSON[els[j].id] = els[j].value;
							}
							if(els[j].getAttribute("type")=="checkbox"){
								if(els[j].checked){
									experimentJSON[els[j].id] = "CHECKED";
								}else{
									experimentJSON[els[j].id] = "";
								}
							}
						}
					}
				}	
			}
			
			experimentId = <%=experimentId%>;
			experimentType = <%=experimentType%>;
			
			experimentJSON["experimentId"] = experimentId;
			experimentJSON["hungSaveSerial"] = hungSaveSerial;

			killIntervals();
			<%if session("hasInventoryIntegration") Or session("hasCompoundTracking") then%>
				experimentJSON["currLetter"] = document.getElementById("currLetter").value;
			<%end if%>
			window.clearInterval(usi)
			tempTab = mainTabSelected;
			if (mainTabSelected != "reactionDiv")
			{
				showMainDiv("reactionDiv")
			}
			hidePopup('signDiv')
			showPopup('savingDiv')
			mainTabSelected = tempTab
			chemDrawHasFocus = false;
			checkForChemistryChanges(true).then(function(){
				<% if session("useMarvin") then %>
					if(document.getElementById("mrvData").value == "" && document.getElementById("cdxData").value != ""){
						chemDrawChanged = true; <% ' This is for the case where you frist switch over to marvin from chemdraw/liveedit %>
					}
				<% end if %>
				if(chemDrawChanged || <%If session("hasCompoundTracking") Then response.write("true") Else response.write("false") End If%>)
				{
					if(chemDrawChanged){
						experimentJSON["chemDrawChanged"] = "1";
					}
					var promiseArray = [];

					promiseArray.push(getChemistryEditorChemicalStructure("mycdx", false, "cdx").then(function(newCdxData){
						document.getElementById("cdxData").value = newCdxData;
						experimentJSON["cdxData"] = document.getElementById("cdxData").value;	
					}));
					
					<% if session("useMarvin") THEN %>
						promiseArray.push(getChemistryEditorChemicalStructure("mycdx", false, "mrv").then(function(newMrvData){
							document.getElementById("mrvData").value = newMrvData;
							experimentJSON["mrvData"] = document.getElementById("mrvData").value;
						}));
					<% else %>
						document.getElementById("mrvData").value = "";
						experimentJSON["mrvData"] = "";
					<% end if %>

					Promise.all(promiseArray).then(function() {
						resolve(experimentSubmitPart2(approve,sign,autoSave,saveOverride,refreshPageAfterSave));
					});

					
				}else{
					resolve(experimentSubmitPart2(approve,sign,autoSave,saveOverride,refreshPageAfterSave));
				}
			});
			
		});
	}

	// include the file that contains the server save function
	<!-- #include file="../../common/js/serverSaveExperimentJS.asp"-->

	// This is split out to deal with the getChemistryEditorChemicalStructure promise.
	function experimentSubmitPart2(approve,sign,autoSave,saveOverride,refreshPageAfterSave){
		/*new*/
		<%'create a string of the reactants present on the form for processing by the 
		'save experiment form ie, r1,r2,r3,r4
		%>
		reactantsString = ""
		for (i=0;i<30 ;i++ )
		{
			if (document.getElementById("r"+i+"_tab"))
			{
				reactantsString += "r"+i+","
			}
		}

		experimentJSON["reactants"] = reactantsString.substring(0,reactantsString.length-1);
		reagentsString = ""
		for (i=0;i<30 ;i++ )
		{
			if (document.getElementById("rg"+i+"_tab"))
			{
				reagentsString += "rg"+i+","
			}
		}

		experimentJSON["reagents"] = reagentsString.substring(0,reagentsString.length-1);

		productsString = ""
		for (i=0;i<30 ;i++ )
		{
			if (document.getElementById("p"+i+"_tab"))
			{
				productsString += "p"+i+","
			}
		}

		experimentJSON["products"] = productsString.substring(0,productsString.length-1);

		solventsString = ""
		for (i=0;i<30 ;i++ )
		{
			if (document.getElementById("s"+i+"_tab"))
			{
				solventsString += "s"+i+","
			}
		}

		experimentJSON["solvents"] = solventsString.substring(0,solventsString.length-1);

		/*/new*/

		<%'create a string of the attachment names present on the form for processing by the 
		'save experiment form ie, name 1,name 2,name 3%>
		attachmentsString = ""
		for (i=0;i<attachments.length ;i++ )
		{
			attachmentsString += attachments[i]
			if (i < attachments.length - 1)
			{
				attachmentsString += ","
			}
		}
		experimentJSON["attachments"] = attachmentsString;
		<%'set form value for approval%>
		if (approve)
		{
			experimentJSON["approve"] = "true";
		}
		
		<%'take form and put the whole form into the hidden iframe for background saving%>
		experimentJSON["sigdigText"] = document.getElementById("sigdig").options[document.getElementById("sigdig").selectedIndex].value;

		if (sign){
			var signSignEmail = document.getElementById("signEmail").value;
			var signPassword = document.getElementById("password").value;
			var signTypeId = document.getElementById("typeId").value;
			var signSign = document.getElementById("sign").value;
			var signSignStatus = document.getElementById("signStatusBox").options[document.getElementById("signStatusBox").selectedIndex].value;
			var signRequesteeId = document.getElementById("requesteeIdBox").options[document.getElementById("requesteeIdBox").selectedIndex].value;
			var signVerifyState = document.getElementById("verify").checked
			
			if(document.getElementById('isSsoUser').value === 'true' && document.getElementById('ssoSignValue').value === 'true' && document.getElementById('isSsoCompany').value === 'true')
			{
				signPassword = "";
				signSignEmail = "";
				signTypeId = document.getElementById("ssoTypeId").value;
				signSign = document.getElementById("ssoSignValue").value;
				signSignStatus = document.getElementById("ssoSignStatusBox").options[document.getElementById("ssoSignStatusBox").selectedIndex].value;
				signRequesteeId = document.getElementById("requesteeIdBox").options[document.getElementById("requesteeIdBox").selectedIndex].value;
				signVerifyState = document.getElementById("ssoVerify").checked
			}

			experimentJSON["signEmail"] = signSignEmail;
			experimentJSON["password"] = signPassword;
			experimentJSON["typeId"] = signTypeId;
			experimentJSON["sign"] = signSign;
			experimentJSON["signStatus"] = signSignStatus;
			experimentJSON["requesteeId"] = signRequesteeId;
			experimentJSON["verifyState"] = signVerifyState;
		}

		//ck wont pass data to post right unless you put the data into the form field before copying its value
		if(CKEDITOR.instances.e_preparation.hasChanges){
			experimentJSON["e_preparation"] = CKEDITOR.instances.e_preparation.getData()
		}
		experimentJSON["sigdigText"] = document.getElementById("sigdig").options[document.getElementById("sigdig").selectedIndex].value;

		tas = document.getElementsByTagName("textarea");
		for (i=0;i<tas.length;i++)
		{
			//console.log("checking... ", tas[i]);
			if(tas[i].id.length)
			{
//				console.log("checking id: ", tas[i].id);
				try { document.getElementById(tas[i].id).value = CKEDITOR.instances[tas[i].id].getData(); }
				catch(err) { console.log("unable to get data from CKEDITOR"); }
				
				try { experimentJSON[tas[i].id] = document.getElementById(tas[i].id).value; }
				catch(err) { console.log("unable to get value for: ", tas[i].id, " from document"); }
			}
		}
		
		<%if revisionId = "" then%>
            hasChemdraw().then(function(isInstalled) {
                if (isInstalled) {
                    experimentJSON["chemDrawChanged"] = document.getElementById("chemDrawChanged").value;
                }
            });
		<%end if%>

		//Clear all the timeouts so it doesn't draft save after saving
		if (Array.isArray(editorsOnTimeout)){
			editorsOnTimeout.forEach(function(e){
				window.clearTimeout(e);
			});
		}
		
		theForm = document.createElement("form");
		theForm.method = "POST"
		theForm.action = "<%=mainAppPath%>/experiments/saveExperiment.asp";
		hiddenExperimentJSON = document.createElement("input");
		hiddenExperimentJSON.setAttribute("type","hidden")
		hiddenExperimentJSON.setAttribute("id","hiddenExperimentJSON")
		hiddenExperimentJSON.setAttribute("name","hiddenExperimentJSON")
		for (var key in experimentJSON) {
			if (experimentJSON.hasOwnProperty(key)) {
				if (key.startsWith("note_") && (key.endsWith("_name") || key.endsWith("_description"))){
					experimentJSON[key] = Encoder.htmlEncode(fixHTMLForCKEditor(experimentJSON[key]));
				}
				if (key.startsWith("file_") && key.endsWith("_description")){
					hiddenExperimentJSON[key] = Encoder.htmlEncode(fixHTMLForCKEditor(experimentJSON[key]));
				}
				if (typeof experimentJSON[key] == "string"){
					experimentJSON[key] = encodeJSON(experimentJSON[key]);
				}
			}
		}
		
		//ELN-1331 Get the forceChemistryProcessing from experimentJSON and assign itto experimentJSON on the form
		experimentJSON["forceChemistryProcessing"] = "<%=experimentJSON.get("forceChemistryProcessing")%>";
		hiddenExperimentJSON.setAttribute("value",JSON.stringify(experimentJSON))
		//console.log(hiddenExperimentJSON);
		theForm.appendChild(hiddenExperimentJSON)
		
		CKEDITOR.instances['e_preparation'].removeListener('change',ckChange);
		
		// ajax call to the server to save experiment
		doServerSaveExperiment("<%=mainAppPath%>/experiments/saveExperiment.asp",$(theForm).serialize(),sign);
	}
    function updateAttachments(){
       	//$('#formresetbutton').click();
		el = document.getElementById("uploadFormHolder");
        if (el) {
            el.style.display = "none";
            elHolder = document.getElementById("uploadFormHolderHolder");
            if (elHolder) {
                elHolder.appendChild(el.parentNode.removeChild(el));
            }
        }

        htmlStr = getFile("/arxlab/ajax_loaders/getAttachmentTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand="+Math.random());
        document.getElementById("attachmentTable").innerHTML = htmlStr;
        for (k=0;k<tableItemsToRemove.length ;k++ )
        {
            try{document.getElementById(tableItemsToRemove[k]).style.display = 'none';}catch(err){}
        }
        delayedRunJS(htmlStr);

		el = document.getElementById("uploadFormHolder");
        if (el) {
            elRow = document.getElementById("attachmentTableFileUploadRow")
            if (elRow) {
                elRow.appendChild(el.parentNode.removeChild(el));
            }
            el.style.display = "block";
        }
        positionButtons();
        $(".droptouploadtext").text("Drag files to upload");
	    $(".droptouploadtextIEonly").text("Drag files to upload");
		
		//ELN-1184 Reinitialize blueimp fileupload dropzone
		reInitializeDropZone()
    }
    function updateNotes(){
         $.get("<%=mainAppPath%>/experiments/ajax/load/getNoteTable.asp?experimentId="+experimentId+"&experimentType="+experimentType+"&time="+$.now(), function(data) {
            //console.log(data);
            $("#noteTable").html(data);
         });
    }


    function updateBottomButtons(thisRevisionNumber){
        notebookId = document.getElementById("notebookId").value
		//console.log("updateBottomButtons revisionNumber: ", thisRevisionNumber, " notebookId: ", notebookId, " experimentId: ", experimentId, " experimentType: ", experimentType);
        $.get("<%=mainAppPath%>/_inclds/experiments/common/buttons/html/ajaxExperimentBottomButtons.asp?experimentId="+experimentId+"&experimentType="+experimentType+"&notebookId="+notebookId+"&time="+$.now(), function(data) {
            //console.log(data);
            $("#bottomButtons").html(data);
            positionButtons();
            document.getElementById("submitRow").style.display = 'block';
            updateShowPDFButton(thisRevisionNumber);
         });
    }

    function updateShowPDFButton(revNumber){
		//console.log("updateShowPDFButton revNumber: ", revNumber);
        $('#makePDFLink').attr('href',"<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=" + revNumber);
        $('#makeShortPDFLink').attr('href',"<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber="+ revNumber +"&short=1");
    }

	function hideUnsavedChanges(){
		us = document.getElementById("unsavedChanges");
		us.style.display = "none";
		us = document.getElementById("unsavedChanges2");
		us.style.display = "none";
	}
	
	window.requiredFieldsJSON = <%
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT experimentConfigJson FROM companies WHERE id="&SQLClean(session("companyId"),"N","S")&" AND experimentConfigJson is not null"
	rec.open strQuery,connAdm,3,3
	experimentConfigJson = "{}"
	If Not rec.eof Then
		experimentConfigJson = rec("experimentConfigJson")
	End If
	response.write experimentConfigJson
	%>
	indicateRequiredFields();

	function removeNonUserAddedMolecules()
	{
		for(i=0;i<30;i++)
		{
			try
			{
				prefix = "r"+i;
				tab = document.getElementById(prefix+"_tab")
				if(tab)
				{
					userAdded = document.getElementById(prefix+"_userAdded").value;
					if (userAdded != "1")
					{
						body = document.getElementById(prefix+"_body")
						tab.parentNode.removeChild(tab)
						body.parentNode.removeChild(body)
					}
				}
			}
			catch(err){}
		}
		for(i=0;i<30;i++)
		{
			try
			{
				prefix = "rg"+i;
				tab = document.getElementById(prefix+"_tab")
				if(tab)
				{
					userAdded = document.getElementById(prefix+"_userAdded").value;
					if (userAdded != "1")
					{
						body = document.getElementById(prefix+"_body")
						tab.parentNode.removeChild(tab)
						body.parentNode.removeChild(body)
					}
				}
			}
			catch(err){}
		}
		for(i=0;i<30;i++)
		{
			try
			{
				prefix = "p"+i;
				tab = document.getElementById(prefix+"_tab")
				if(tab)
				{
					userAdded = document.getElementById(prefix+"_userAdded").value;
					if (userAdded != "1")
					{
						body = document.getElementById(prefix+"_body")
						tab.parentNode.removeChild(tab)
						body.parentNode.removeChild(body)
					}
				}
			}
			catch(err){}
		}
		for(i=0;i<30;i++)
		{
			try
			{
				prefix = "s"+i;
				tab = document.getElementById(prefix+"_tab")
				if(tab)
				{
					userAdded = document.getElementById(prefix+"_userAdded").value;
					if (userAdded != "1")
					{
						body = document.getElementById(prefix+"_body")
						tab.parentNode.removeChild(tab)
						body.parentNode.removeChild(body)
					}
				}
			}
			catch(err){}
		}
	}

	/*new*/
	function getLastReactantNumber()
	{
		num = 0
		for(i=0;i<30;i++)
		{
			try
			{
				crap = document.getElementById("r"+i+"_tab").innerHTML
				num = i
			}
			catch(err){}
		}
		return num;
	}

	function getLastReagentNumber()
	{
		num = 0
		for(i=0;i<30;i++)
		{
			try
			{
				crap = document.getElementById("rg"+i+"_tab").innerHTML
				num = i
			}
			catch(err){}
		}
		return num;
	}

	function getLastProductNumber()
	{
		num = 0
		for(i=0;i<30;i++)
		{
			try
			{
				crap = document.getElementById("p"+i+"_tab").innerHTML
				num = i
			}
			catch(err){}
		}
		return num;
	}

	function getLastSolventNumber()
	{
		num = 0
		for(i=0;i<30;i++)
		{
			try
			{
				crap = document.getElementById("s"+i+"_tab").innerHTML
				num = i
			}
			catch(err){}
		}
		return num;
	}

	function insertAfter(parent, node, referenceNode) {
	  parent.insertBefore(node, referenceNode.nextSibling);
	}

	function runLimittingOnChange()
	{
		for(i=0;i<30;i++)
		{
			try
			{
				if(document.getElementById("r"+i+"_limit").checked)
				{
					document.getElementById("r"+i+"_moles").onchange()
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
					document.getElementById("rg"+i+"_moles").onchange()
				}
			}
			catch(err){}
		}
	}

	function setLimitingIfNone(){
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
	}

	function updateGrid(){
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
		foundLimitCheck = false;
		for(i=0;i<30;i++)
		{
			try
			{
				if(document.getElementById("r"+i+"_limit").checked)
				{
					if(UAStates["r"+i]["sampleMass"]){
						gridFieldChanged(document.getElementById("r"+i+"_sampleMass"))
						foundLimitCheck = true;
					}
					if(UAStates["r"+i]["volume"]){
						gridFieldChanged(document.getElementById("r"+i+"_volume"))
						foundLimitCheck = true;
					}
					if(UAStates["r"+i]["moles"]){
						gridFieldChanged(document.getElementById("r"+i+"_moles"))
						foundLimitCheck = true;
					}
					if(UAStates["r"+i]["equivalents"]){
						gridFieldChanged(document.getElementById("r"+i+"_equivalents"))
						foundLimitCheck = true;
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
						foundLimitCheck = true;
					}
					if(UAStates["rg"+i]["volume"]){
						gridFieldChanged(document.getElementById("rg"+i+"_volume"))
						foundLimitCheck = true;
					}
					if(UAStates["rg"+i]["moles"]){
						gridFieldChanged(document.getElementById("rg"+i+"_moles"))
						foundLimitCheck = true;
					}
					if(UAStates["rg"+i]["equivalents"]){
						gridFieldChanged(document.getElementById("rg"+i+"_equivalents"))
						foundLimitCheck = true;
					}
				}
			}
			catch(err){}
		}
		if(!foundLimitCheck){
			for(i=0;i<30;i++)
			{
				try
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
				catch(err){}
			}
			for(i=0;i<30;i++)
			{
				try
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
				catch(err){}
			}
		}
		populateQuickView();
	}

	function makeInvLinks(prefix,inventoryItems){
		return new Promise(function(resolve, reject) {
			var el = document.getElementById(prefix+"_inventoryItems").parentNode;
			if (inventoryItems.length > 1) {
				// if we have more than 1 link we want to add it to the links section instead... so direct there
				var a = document.createElement("a");
				a.innerHTML = "Go to Links";
				a.setAttribute("href","#invLinks")
				el.appendChild(a);
				el.appendChild(document.createElement("br"));
			}
			else if (inventoryItems.length = 1) {
				// just add the link
				var a = document.createElement("a");
				a.setAttribute("target","_new");
				a.innerHTML = inventoryItems[0]["name"];
				a.setAttribute("href","<%=mainAppPath%>/inventory2/index.asp?id="+inventoryItems[0]["id"])
				el.appendChild(a);
				el.appendChild(document.createElement("br"));
				
			}
			for(var i=0;i<inventoryItems.length;i++){
				$.ajax({
					method: "POST",
					url: "<%=mainAppPath%>/experiments/ajax/do/newMolLink.asp",
					data: {"experimentId":"<%=experimentId%>","inventoryId":inventoryItems[i]["id"],"inventoryName":inventoryItems[i]["name"],"molName":document.getElementById(prefix+"_trivialName").value},
				})
				.done(function(response) {
					unsavedChanges = true;
					sendAutoSave(prefix+"_inventoryItems",JSON.stringify(inventoryItems))
					.then(function() {
						var prefixInvItem = document.getElementById(prefix + "_inventoryItems");
						if (prefixInvItem) {
							prefixInvItem.value = JSON.stringify(inventoryItems);
						};
						resolve(true);
					})
				})
				.fail(function(response) {
					resolve(true);
				})
			}
			
		});
	}
	
	function removeInvLinks(prefix){
		return new Promise(function(resolve, reject) {
			var el = document.getElementById(prefix+"_inventoryItems").parentNode;
			var els = el.getElementsByTagName("a");
			for(var i=0;i<els.length;i++){
				el.removeChild(els[i]);
			}
			els = el.getElementsByTagName("br");
			for(var i=0;i<els.length;i++){
				el.removeChild(els[i]);
			}
			resolve(true);
		});
	}

	function addReactant(name,MW,Formula,cas,labelName,fragmentId,inReaction,purity,amount,equivalents,inventoryItems,productId,volume,density)
	{
		/*new*/
		return new Promise(function (resolve, reject) {
			<%'add a solvent get the display data and update solvent variables%>
			newReactantNumber = getLastReactantNumber() + 1
			prefix = "r" + (newReactantNumber)

			getForm("Reactant", newReactantNumber, "formDiv").then(function (value) {
				numReactants += 1;

				labelText = "";
				if (labelName != undefined) {
					labelText = labelName;
					sendAutoSave("r" + (newReactantNumber) + "_trivialName", labelText);
				} else {
					if (name != undefined) {
						labelText = name.substr(0, 20);
					}
				}

				newTab = "<div class='gridTabDiv' onClick=\"displayTab('r" + (newReactantNumber) + "');return false;\" id='r" + (newReactantNumber) + "_tab' '><span id='r" + (newReactantNumber) + "_tab_text'>" + (labelText) + "</span><input style='display:none;' type='text' id='r" + (newReactantNumber) + "_tab_input'/><a id='r" + (newReactantNumber) + "_tab_link' href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='editTabName(\"r" + (newReactantNumber) + "_tab\")'><img id='r" + (newReactantNumber) + "_tab_image' border='0' src='images/btn_edit.gif'/></a><a href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='deleteTab(\"r" + (newReactantNumber) + "\");return false;'><img border='0' style='width:12px;height:12px;' src='images/delete.png' class='png'></a></div>"

				document.getElementById("r" + (newReactantNumber) + "_trivialName").value = labelText;

				newLI = document.createElement("li")
				newLI.innerHTML = newTab
				newTab = newLI

				if (getLastReactantNumber() != 0) {
					insertAfter(document.getElementById("r" + getLastReactantNumber() + "_tab").parentNode.parentNode, newTab, document.getElementById("r" + getLastReactantNumber() + "_tab").parentNode)
				}
				else {
					insertAfter(document.getElementById("rc_tab").parentNode.parentNode, newTab, document.getElementById("rc_tab").parentNode)
				}

				if (name != undefined) {
					document.getElementById(prefix + "_name").value = name;
				}
				if (MW != undefined) {
					document.getElementById(prefix + "_molecularWeight").value = MW;
				}
				if (Formula != undefined) {
					document.getElementById(prefix + "_molecularFormula").value = Formula;
				}
				document.getElementById(prefix + "_equivalents").value = "1.0"
				if (cas != undefined) {
					document.getElementById(prefix + "_cas").value = cas
				}
				if (productId) {
					document.getElementById(prefix + "_productId").value = productId;
				}
				if (fragmentId != undefined) {
					document.getElementById(prefix + "_fragmentId").value = fragmentId
				}
				if (purity || amount || equivalents || volume) {
					if (!UAStates[prefix]) {
						UAStates[prefix] = {};
					}
				}
				if (purity) {
					document.getElementById(prefix + "_percentWT").value = purity;
					UAStates[prefix]["percentWT"] = true;
				}
				if (amount) {
					document.getElementById(prefix + "_sampleMass").value = amount;
					UAStates[prefix]["sampleMass"] = true;
				}
				if (volume) {
					document.getElementById(prefix + "_volume").value = volume;
					UAStates[prefix]["volume"] = true;
				}
				if (density) {
					document.getElementById(prefix + "_density").value = density;
					UAStates[prefix]["density"] = true;
				}
				if (equivalents) {
					document.getElementById(prefix + "_equivalents").value = equivalents;
					UAStates[prefix]["equivalents"] = true;
				}
				if (purity || amount || equivalents || volume) {
					document.getElementById(prefix + "_UAStates").value = JSON.stringify(UAStates[prefix]);
				}
				if (inventoryItems != undefined) {
					//document.getElementById(prefix+"_inventoryItems").value = inventoryItems;
					makeInvLinks(prefix, JSON.parse(inventoryItems));
					document.getElementById(prefix + "_hasChanged").value = "1"
				}
				if (inReaction) {
					document.getElementById(prefix + "_userAdded").value = "0";
				} else {
					document.getElementById(prefix + "_userAdded").value = "1";
				}

				attachEdits(document.getElementById(prefix + "_body"))
					<%if experimentId > gridCutoff then %>
				if (name != undefined) {
					if (purity || amount) {
						window.setTimeout('gridFieldChanged(document.getElementById(prefix+"_sampleMass"))', 1000)
					} else {
						if (volume) {
							window.setTimeout('gridFieldChanged(document.getElementById(prefix+"_volume"))', 1000)
						} else {
							window.setTimeout('gridFieldChanged(document.getElementById(prefix+"_moles"))', 1000)
						}
					}
				}
				<%else%>
					runLimittingOnChange()
				<% end if%>
			
				displayTab(prefix)
				unsavedChanges = true
				if (fragmentId != undefined) {
					setChemDrawChanged(true);
					newDraftMol("reactant", fragmentId, labelName)
				}
			});

			resolve(prefix);
		});
	}


	function addReagent(name,MW,Formula,cas,labelName,fragmentId,inReaction,purity,amount,equivalents,inventoryItems,productId,volume,density)
	{
		/*new*/
		return new Promise(function (resolve, reject) {
			<%'add a Reagent get the display data and update Reagent variables%>
			newReagentNumber = getLastReagentNumber() + 1
			prefix = "rg" + (newReagentNumber)

			getForm("Reagent", newReagentNumber, "formDiv").then(function (value) {
				numReagents += 1;

				labelText = "";
				if (labelName != undefined) {
					labelText = labelName;
					sendAutoSave("rg" + (newReagentNumber) + "_trivialName", labelText);
				} else {
					if (name != undefined) {
						labelText = name.substr(0, 20);
					}
				}

				newTab = "<div class='gridTabDiv' onClick=\"displayTab('rg" + (newReagentNumber) + "');return false;\" id='rg" + (newReagentNumber) + "_tab' '><span id='rg" + (newReagentNumber) + "_tab_text'>" + (labelText) + "</span><input style='display:none;' type='text' id='rg" + (newReagentNumber) + "_tab_input'/><a id='rg" + (newReagentNumber) + "_tab_link' href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='editTabName(\"rg" + (newReagentNumber) + "_tab\")'><img id='rg" + (newReagentNumber) + "_tab_image' border='0' src='images/btn_edit.gif'/></a><a href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='deleteTab(\"rg" + (newReagentNumber) + "\");return false;'><img border='0' style='width:12px;height:12px;' src='images/delete.png' class='png'></a></div>"

				document.getElementById("rg" + (newReagentNumber) + "_trivialName").value = labelText;

				newLI = document.createElement("li")
				newLI.innerHTML = newTab
				newTab = newLI

				if (getLastReagentNumber() != 0) {
					insertAfter(document.getElementById("rg" + getLastReagentNumber() + "_tab").parentNode.parentNode, newTab, document.getElementById("rg" + getLastReagentNumber() + "_tab").parentNode)
				}
				else if (getLastReactantNumber() != 0) {
					insertAfter(document.getElementById("r" + getLastReactantNumber() + "_tab").parentNode.parentNode, newTab, document.getElementById("r" + getLastReactantNumber() + "_tab").parentNode)
				}
				else {
					insertAfter(document.getElementById("rc_tab").parentNode.parentNode, newTab, document.getElementById("rc_tab").parentNode)
				}

				if (name != undefined) {
					document.getElementById(prefix + "_name").value = name
				}
				if (MW != undefined) {
					document.getElementById(prefix + "_molecularWeight").value = MW
				}
				if (Formula != undefined) {
					document.getElementById(prefix + "_molecularFormula").value = Formula
				}
				document.getElementById(prefix + "_equivalents").value = "1.0"
				if (cas != undefined) {
					document.getElementById(prefix + "_cas").value = cas;
				}
				if (productId) {
					document.getElementById(prefix + "_productId").value = productId;
				}
				if (fragmentId != undefined) {
					document.getElementById(prefix + "_fragmentId").value = fragmentId
				}
				document.getElementById(prefix + "_userAdded").value = "1"

				if (purity || amount || equivalents || volume) {
					if (!UAStates[prefix]) {
						UAStates[prefix] = {};
					}
				}
				if (purity) {
					document.getElementById(prefix + "_percentWT").value = purity;
					UAStates[prefix]["percentWT"] = true;
				}
				if (amount) {
					document.getElementById(prefix + "_sampleMass").value = amount;
					UAStates[prefix]["sampleMass"] = true;
				}
				if (volume) {
					document.getElementById(prefix + "_volume").value = volume;
					UAStates[prefix]["volume"] = true;
				}
				if (density) {
					document.getElementById(prefix + "_density").value = density;
					UAStates[prefix]["density"] = true;
				}
				if (equivalents) {
					document.getElementById(prefix + "_equivalents").value = equivalents;
					UAStates[prefix]["equivalents"] = true;
				}
				if (purity || amount || equivalents || volume) {
					document.getElementById(prefix + "_UAStates").value = JSON.stringify(UAStates[prefix]);
				}
				if (inventoryItems != undefined) {
					//document.getElementById(prefix+"_inventoryItems").value = inventoryItems;
					makeInvLinks(prefix, JSON.parse(inventoryItems));
					document.getElementById(prefix + "_hasChanged").value = "1"
				}
				if (inReaction) {
					document.getElementById(prefix + "_userAdded").value = "0";
				} else {
					document.getElementById(prefix + "_userAdded").value = "1";
				}

				attachEdits(document.getElementById(prefix + "_body"))
				<%if experimentId > gridCutoff then %>
					if (name != undefined) {
						if (purity || amount) {
							window.setTimeout('gridFieldChanged(document.getElementById(prefix+"_sampleMass"))', 1000)
						} else {
							if (volume) {
								window.setTimeout('gridFieldChanged(document.getElementById(prefix+"_volume"))', 1000)
							} else {
								window.setTimeout('gridFieldChanged(document.getElementById(prefix+"_moles"))', 1000)
							}
						}
					}
				<%else%>
					runLimittingOnChange()
				<% end if%>

				displayTab(prefix)
				unsavedChanges = true
				if (fragmentId != undefined) {
					setChemDrawChanged(true);
					newDraftMol("reagent", fragmentId, labelName)
				}
			});

			resolve(prefix);
		});
	}

	function addProduct(name,MW,Formula,labelName,fragmentId)
	{
		/*new*/
		return new Promise(function (resolve, reject) {
			<%'add a Product get the display data and update Product variables%>
			newProductNumber = getLastProductNumber() + 1
			prefix = "p" + (newProductNumber)

			getForm("Product",newProductNumber,"formDiv").then(function (value) {
				numProducts += 1;

				labelText = "";
				if(labelName!=undefined){
					labelText = labelName;
					sendAutoSave("p"+(newProductNumber)+"_trivialName",labelText);
				}else{
					if(name!=undefined){
						labelText = name.substr(0,20);
					}
				}

				newTab = "<div class='gridTabDiv' onClick=\"displayTab('p"+(newProductNumber)+"');return false;\" id='p"+(newProductNumber)+"_tab' '><span id='p"+(newProductNumber)+"_tab_text'>"+(labelText)+"</span><input style='display:none;' type='text' id='p"+(newProductNumber)+"_tab_input'/><a id='p"+(newProductNumber)+"_tab_link' href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='editTabName(\"p"+(newProductNumber)+"_tab\")'><img id='p"+(newProductNumber)+"_tab_image' border='0' src='images/btn_edit.gif'/></a><a href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='deleteTab(\"p"+(newProductNumber)+"\");return false;'><img border='0' style='width:12px;height:12px;' src='images/delete.png' class='png'></a></div>"

				document.getElementById("p"+(newProductNumber)+"_trivialName").value = labelText;

				newLI = document.createElement("li")
				newLI.innerHTML = newTab
				newTab = newLI

				if(getLastSolventNumber() != 0)
				{
					insertAfter(document.getElementById("s"+getLastSolventNumber()+"_tab").parentNode.parentNode,newTab,document.getElementById("s"+getLastSolventNumber()+"_tab").parentNode)
				}
				else if(getLastProductNumber() !=0)
				{
					insertAfter(document.getElementById("p"+getLastProductNumber()+"_tab").parentNode.parentNode,newTab,document.getElementById("p"+getLastProductNumber()+"_tab").parentNode)
				}
				else if(getLastReagentNumber() != 0)
				{
					insertAfter(document.getElementById("rg"+getLastReagentNumber()+"_tab").parentNode.parentNode,newTab,document.getElementById("rg"+getLastReagentNumber()+"_tab").parentNode)
				}
				else if(getLastReactantNumber() != 0)
				{
					insertAfter(document.getElementById("r"+getLastReactantNumber()+"_tab").parentNode.parentNode,newTab,document.getElementById("r"+getLastReactantNumber()+"_tab").parentNode)
				}
				else
				{
					insertAfter(document.getElementById("rc_tab").parentNode.parentNode,newTab,document.getElementById("rc_tab").parentNode)
				}

				document.getElementById(prefix+"_name").value = name
				document.getElementById(prefix+"_molecularWeight").value = MW
				document.getElementById(prefix+"_molecularFormula").value = Formula
				document.getElementById(prefix+"_equivalents").value = "1.0"
				if(fragmentId!=undefined){
					document.getElementById(prefix+"_fragmentId").value = fragmentId
				}
				document.getElementById(prefix+"_userAdded").value = "1"
				attachEdits(document.getElementById(prefix+"_body"))
				<%if experimentId > ridCutoff then%>
					window.setTimeout('gridFieldChanged(document.getElementById("' + prefix + '_theoreticalMoles"))',1000)
				<%else%>
					runLimittingOnChange()
				<%end if%>
				displayTab(prefix)
				unsavedChanges = true
				if(fragmentId!=undefined){
					setChemDrawChanged(true);
					newDraftMol("product",fragmentId,labelName)
				}
			});

			resolve(prefix);
		});
	}

	function addSolvent(name,labelName,fragmentId,inReaction,inventoryItems,volume)
	{
		/*new*/
		return new Promise(function (resolve, reject) {
			<%'add a solvent get the display data and update solvent variables%>
			newSolventNumber = getLastSolventNumber() + 1
			prefix = "s" + (newSolventNumber)

			getForm("Solvent",newSolventNumber,"formDiv").then(function (value) {
				numSolvents += 1;

				labelText = "";
				if(labelName!=undefined){
					labelText = labelName;
					sendAutoSave("s"+(newSolventNumber)+"_trivialName",labelText);
				}else{
					if(name!=undefined){
						labelText = name.substr(0,20);
					}
				}

				newTab = "<div class='gridTabDiv' onClick=\"displayTab('s"+(newSolventNumber)+"');return false;\" id='s"+(newSolventNumber)+"_tab' '><span id='s"+(newSolventNumber)+"_tab_text'>"+(labelText)+"</span><input style='display:none;' type='text' id='s"+(newSolventNumber)+"_tab_input'/><a id='s"+(newSolventNumber)+"_tab_link' href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='editTabName(\"s"+(newSolventNumber)+"_tab\")'><img id='s"+(newSolventNumber)+"_tab_image' border='0' src='images/btn_edit.gif'/></a><a href='javascript:void(0)' style='z-index:1000;padding:2px;' class='gridTabPencil' onclick='deleteTab(\"s"+(newSolventNumber)+"\");return false;'><img border='0' style='width:12px;height:12px;' src='images/delete.png' class='png'></a></div>"

				document.getElementById("s"+(newSolventNumber)+"_trivialName").value = labelText;

				newLI = document.createElement("li")
				newLI.innerHTML = newTab
				newTab = newLI

				if(getLastProductNumber() !=0)
				{
					insertAfter(document.getElementById("p"+getLastProductNumber()+"_tab").parentNode.parentNode,newTab,document.getElementById("p"+getLastProductNumber()+"_tab").parentNode)
				}
				else if(getLastReagentNumber() != 0)
				{
					insertAfter(document.getElementById("rg"+getLastReagentNumber()+"_tab").parentNode.parentNode,newTab,document.getElementById("rg"+getLastReagentNumber()+"_tab").parentNode)
				}
				else if(getLastReactantNumber() != 0)
				{
					insertAfter(document.getElementById("r"+getLastReactantNumber()+"_tab").parentNode.parentNode,newTab,document.getElementById("r"+getLastReactantNumber()+"_tab").parentNode)
				}
				else
				{
					insertAfter(document.getElementById("rc_tab").parentNode.parentNode,newTab,document.getElementById("rc_tab").parentNode)
				}

				if(name!=undefined){
					document.getElementById(prefix+"_name").value = name
				}
				if(fragmentId!=undefined){
					document.getElementById(prefix+"_fragmentId").value = fragmentId
				}
				document.getElementById(prefix+"_userAdded").value = "1"
				if(volume){
					if(!UAStates[prefix]){
						UAStates[prefix] = {};
					}
				}
				if(inventoryItems!=undefined){
					//document.getElementById(prefix+"_inventoryItems").value = inventoryItems;
					makeInvLinks(prefix,JSON.parse(inventoryItems));
					document.getElementById(prefix+"_hasChanged").value = "1"
				}
				if(volume){
					document.getElementById(prefix+"_volume").value = volume;
					UAStates[prefix]["volume"] = true;
				}
				if(inReaction){
					document.getElementById(prefix+"_userAdded").value = "0";
				}else{
					document.getElementById(prefix+"_userAdded").value = "1";
				}
				if(volume){
					document.getElementById(prefix+"_UAStates").value = JSON.stringify(UAStates[prefix]);
				}

				attachEdits(document.getElementById(prefix+"_body"))
		
				<%if experimentId > gridCutoff then%>
					if(inventoryItems!=undefined){
						if(volume){
							window.setTimeout('gridFieldChanged(document.getElementById(prefix+"_volume"))',1000);
						}else{
							window.setTimeout('gridFieldChanged(document.getElementById(prefix+"_moles"))',1000);
						}
					}
				<%else%>
					runLimittingOnChange()
				<%end if%>
				displayTab(prefix)
				unsavedChanges = true
				if(fragmentId!=undefined){
					setChemDrawChanged(true);
					newDraftMol("solvent",fragmentId,labelName)
				}
			});

			resolve(prefix);
		});
	}

	function deleteSolvent(solventId)
	{
		<%'delete a solvent: make it disappear and renumber solvents%>
		document.getElementById(solventId + "_name").value = "";
		document.getElementById(solventId + "_ratio").value = "";
		document.getElementById(solventId + "_volume").value = "";
		document.getElementById(solventId + "_table").style.display = "none";
		numberSolvents();
		unsavedChanges = true;
	}

	function numberSolvents()
	{<%'reorder solvents to number them sequentially in case one in the middle is deleted%>
		counter = 1;
		for (i=1;i<=numSolvents ;i++ )
		{
			try
			{
				el = document.getElementById("s"+i+"_table");
				if (el.style.display != "none")
				{
					el = document.getElementById("s"+i+"_heading");
					el.innerHTML = "Solvent "+counter;
					counter += 1;
				}
			}
			catch (err)
			{
			}
		}
	}

	function notebookChange()
	{
		experimentName = getFile("<%=mainAppPath%>/experiments/ajax/load/nextExperimentName.asp?notebookId=<%=notebookId%>&random"+Math.random())
		document.getElementById("e_name").value = experimentName;
		showTR("sectionRow");
	}

	function signSubmit()
	{
		return true;
	}

	<% if not session("useMarvin") THEN %>
	var numWaits = 0;
	function rxnSubmit()
	{
		killIntervals();
		sForm = document.getElementById("uploadRXNForm");
		sForm.action = "<%=mainAppPath%>/experiments/echo.asp?experimentId="+experimentId+"&experimentType="+experimentType+"&serial="+getSaveSerial();
		sForm.submit();
		numWaits = 0;
		waitForRXN();
	}
	<% end if %>

	function waitForExperimentLoading(){
			return new Promise(function (resolve, reject) {
			(function waitForLoaded(){
				result = getFile("<%=mainAppPath%>/ajax_checkers/experimentLoading.asp?id="+<%=experimentId%>+"&rand="+Math.random());
				if (result != "yes"){ 
					return resolve(result);
				}
				setTimeout(waitForLoaded, 100);
			})();
		});
	}

	function waitForRXN()
	{
		$.ajax({
			url: "<%=mainAppPath%>/experiments/ajax/check/serialAck.asp",
			type: "GET",
            data: { serial: getSaveSerial(),
					rand: Math.random()},
			success: function(data)
			{
				console.log("rxnSubmit success");
				if(data != "")
				{
					numWaits = 90;
				}
			},
			error: function(error, textStatus, errorThrown)
			{
				//nothing for now
			},
			complete: function()
			{
				console.log("numWaits=",numWaits);
				if(numWaits++ == 90){
					waitForExperimentLoading().then(function(){
						window.location = '<%=session("expPage")%>?id=<%=experimentId%>&tab='+mainTabSelected;
					});
				}
				else{
					setTimeout(function() { waitForRXN(); }, 500);
				}
			}
		 });
		 
		return false;
	}

	// state 0 = checkedin
	// state 1 = checkedout in legacy app
	// state <anythingElse> = checked out and this is the live edit file ID that we need to check it back in.
	function setChemExperimentAsCheckedOut(state){
		
		
		$.get( "<%=mainAppPath%>/experiments/ajax/do/setChemExperimentCDXCheckedOut.asp", {"experimentId":<%=experimentId%>,"experimentType":1, "state": state}, function(){
			updateBottomButtons(experimentJSON.thisRevisionNumber);
			reInitializeDropZone();
		});

		

	}

<%If hasCombi Then%>
<%'start combi%>

	function combiSubmit()
	{
			killIntervals();
			sForm = document.getElementById("uploadCombiForm");
			sForm.submit();
			waitForCombi();
			return false;
	}

	function waitForCombi()
	{
		try
		{
			result = window.frames["upload_frame"].document.getElementById("resultsDiv").innerHTML
			if(result == "")
			{
				setTimeout(function() { waitForCombi(); }, 50);
			}
			else
			{
				if(result != "success")
				{
					swal({
					  title: "Error",
					  text: result,
					  confirmButtonText: "OK"
					},
					function(isConfirm){
						if(isConfirm)
							window.location = window.location;
					});
				}
			}
		}
		catch(err)
		{
			//alert(err)
			setTimeout(function() { waitForCombi(); }, 50);
		}
	}

<%'end combi%>
<%end if%>
	function putData(extension,data)
	{
		window.location = window.location
	}
<%If request.querystring("revisionId") = "" and ownsExp Then%>
addLoadEvent(function(){
	attachEdits(document.getElementById("pageContentTD"))
});
<%end if%>

var molTimeout = null;
var mrvTimeout = null;
var getObjectCallBacks = [];
function updateOnMolChange(){
	//if (marvinReady) {
		getChemistryEditorChemicalStructure("mycdx", false, "mrv").then(function (mrvData) {
			clearTimeout(mrvTimeout); 
			mrvTimeout = setTimeout(function(){
				//We set a timeout so we don't hammer this function call (this can be an issue if you make the 3d thing spin)
				$("#marvinLoading").show();
				callMarvinDispatch(mrvData, experimentId, experimentJSON, marvinCallbackFn).then(function() {
				//Also update the CDX so we can go back to chemdraw if we want
					getChemistryEditorChemicalStructure("mycdx", false, "cdx").then(function (cdxData) {
						
						//console.log(cdxData);
						experimentJSON.cdxData = cdxData;
						document.getElementById("cdxData").value = cdxData;
						sendAutoSave("cdxData", cdxData);
						experimentJSON.cdxml = cdxData;
						sendAutoSave("cdxml", cdxData);
					});
				});
			}, 200);
		});
}

/**
 * Callback function extracted from the above function so that the callMarvinDispatch
 * function could be its own discrete function call that lives in liveEditHelperFunctions.
 * @param {string} mrvData The MRV chemistry reaction.
 */
function marvinCallbackFn(mrvData) {
	//console.log("MRV Data! " + data);
	// update the grid data by making a callback function that getObjectForm will call when its done
	$.each(UAStates, function(fieldPrefixName, fieldPrefix){
		$.each(fieldPrefix, function(fieldName, fieldChanged){
			if(fieldChanged == true){
				getObjectCallBacks[fieldPrefixName] = function(){
					gridFieldChanged(document.getElementById(fieldPrefixName + "_" + fieldName));
				}
			}
		});
	});
	//Waiting for the scripts from getObjectForm to finish.

	populateWithNewCounts(false, false); //Update the grid
	marvinReady = true;
	//Update the expiermentJSON (and mark unsaved changes)
	if (experimentJSON.mrvData != mrvData && marvinReady) {
		unsavedChanges=true;
		sendAutoSave("mrvData",mrvData);
		experimentJSON.chemDrawChanged = 1;
		$('#mrvData').text(mrvData);
	}
}

function addMolMarvin()
{
	var structureData = {
		"fields": [],
		"prefix" : "",
		"addType": "",
		"molType": "",
		"name": "",
		"MW": "",
		"Formula": "",
		"reagentCdxml": "",
		"experimentCdxml": "",
		"cas": "",
		"label": "",
		"fragLocation": "",
		"addStructureToDiagram": true,
		"newFragmentId": -1
	};
	
	// Are we supposed to add the structure to the diagram?
	structureData["addStructureToDiagram"] = document.getElementById("addStructureToReaction").checked;
	
	el = document.getElementById("molType")
	molTypeVal = el.options[el.selectedIndex].value
	structureData["molType"] = assignMolType(molTypeVal);

	el = document.getElementById("molAddType")
	addTypeVal = el.options[el.selectedIndex].value
	structureData["addType"] = assignCasDataSource(addTypeVal);
	
	if(structureData["addType"].length <= 0 || structureData["molType"].length <= 0)
		return false;

	if(structureData["addType"] === 'reagentDb')
	{
		el = document.getElementById("newcomSingularitySelect")
		if (el.options[el.selectedIndex].value == '0') 
		{
			alert("You must select a reagent.")
			resetAddMolBtn();
			return false;
		}
	}
	
	if (structureData["addType"] === "manual" && structureData["molType"] !== "solvent")
	{
		if(document.getElementById("addMolMW").value == "")
		{
			alert("You must enter a molecular weight.")
			resetAddMolBtn();
			return false;
		}
	}

	if(structureData["addType"] == "manual")
	{
		structureData["name"] = document.getElementById("addMolName").value
		structureData["MW"] = document.getElementById("addMolMW").value
		structureData["Formula"] = document.getElementById("addMolFormula").value
	}
	else if(structureData["addType"] == "reagentDb")
	{
		structureData["fields"] = eval("("+getFile("<%=mainAppPath%>/misc/ajax/load/getNewcomSingularityData.asp?id="+document.getElementById("newcomSingularitySelect").options[document.getElementById("newcomSingularitySelect").selectedIndex].value)+")")
		structureData["cas"] = structureData["fields"].cas
		structureData["name"] = structureData["fields"].name
		structureData["MW"] = structureData["fields"].molecularWeight
		structureData["Formula"] = structureData["fields"].molecularFormula
	}
	else
	{	
		//CAS structure conversion
		molData = ""
        if (document.getElementById("mycdxSearch")) {
            hasChemdraw().then(function (isInstalled) {
                if (isInstalled) {
                    molData = cd_getData("mycdxSearch", "chemical/x-mdl-molfile");
                }
            });
        }
		
		if ($("#addCasCdId").val().length == 0 && document.getElementById("addMolCAS").value == "" && document.getElementById("addCasName").value == "" && molData[0] == undefined) {
			alert("Please Enter a CAS Number or Name or Structure")
			resetAddMolBtn()
			return false;
		}
		else
		{
			document.getElementById("addMolbtn").innerText = "Searching..";
            hasChemdraw().then(function (isInstalled) {
                if (isInstalled) {
					structureData["experimentCdxml"] = experimentJSON["mrvData"];			
				}
            });
			var args = "";
			if($("#addCasCdId").val().length > 0)
			{
				args = '&casCdId='+$("#addCasCdId").val();
			}
			else
			{
				args = '&casId='+document.getElementById('addMolCAS').value+'&casName='+encodeURIComponent(document.getElementById('addCasName').value)+'&molStr='+encodeURIComponent(molData);
			}
			
			casDoc = getFile('<%=mainAppPath%>/ajax_loaders/getCasData.asp?experimentType='+<%=experimentType%>+'&experimentId='+<%=experimentId%>+args+'&searchType=exactSearch&random='+Math.random());
			jsonCas = JSON.parse(casDoc);
			
			if (jsonCas.hasOwnProperty("data") && jsonCas.data.length > 0)
			{
				if (jsonCas.currentSize == 1)
				{
					//**Exact search returned single record**//
					var casJson = (jsonCas.data)[0];
					if (casJson.hasOwnProperty("cdxml"))
					{
						structureData["Formula"] = casJson["cd_formula"];
						structureData["name"] = casJson["traditional_name"];
						structureData["MW"] = casJson["cd_molweight"];
						structureData["reagentCdxml"] = casJson["cdxml"]
						structureData["cas"] = casJson["cas"];
					}
				}
				else
				{	//**Exact search returned multiple records**//
					jList = jsonCas.currentSize;
					window.casJsonData = jsonCas["data"];
					resultHTML = casReturnResultTable(jsonCas);
					
					if (resultHTML != "")
					{
						document.getElementById("chemAxonResultDiv").innerHTML = resultHTML;
						resetAddMolBtn();
						document.getElementById("addMolDiv").style.display="none";
						showPopup("showCasResultsDiv");
						
						//**Reset the div height depending upon the table height**//
						var table = document.getElementById("displayResults");
						var div = document.getElementById("chemAxonResultDiv");
						
						if(div.offsetHeight > table.offsetHeight)
						{
							div.style.height = table.style.height;
						}
						
						return false;
					}
					else
					{
						alert("There is an error occured during the Search. Please try again..");
						resetAddMolBtn();
						return false;
					}
				}
			}
			else
			{
				//** Exact search did not give any results.. Send another request with sub-search **//
				casDocSubSearch = getFile('<%=mainAppPath%>/ajax_loaders/getCasData.asp?experimentType='+<%=experimentType%>+'&experimentId='+<%=experimentId%>+'&casId='+document.getElementById('addMolCAS').value+'&casName='+encodeURIComponent(document.getElementById('addCasName').value)+'&molStr='+encodeURIComponent(molData)+'&searchType=subSearch&random='+Math.random());
				jsonCas = JSON.parse(casDocSubSearch);
				
				if (jsonCas.currentSize > 1)
				{
					jList = jsonCas.currentSize;
					window.casJsonData = jsonCas["data"];
					resultHTML = casReturnResultTable(jsonCas, jList);
					
					if (resultHTML != "")
					{
						document.getElementById("chemAxonResultDiv").innerHTML = resultHTML;
						resetAddMolBtn();
						document.getElementById("addMolDiv").style.display="none";
						showPopup("showCasResultsDiv");
						
						//**Reset the div height depending upon the table height**//
						var table = document.getElementById("displayResults");
						var div = document.getElementById("chemAxonResultDiv");
						if(div.offsetHeight > table.offsetHeight)
						{
							div.style.height = table.style.height;					
							document.getElementById("extraMolData").style.display = "none";
							el = document.getElementById("molType")
							el.selectedIndex = 0
							el = document.getElementById("molAddType")
							el.selectedIndex = 0
							molTypeChange();
							hidePopup("addMolDiv")
							document.getElementById("lean_overlay").style.display = "none";
							document.getElementById("addMolName").value = "";
							document.getElementById("addMolMW").value = "";
							document.getElementById("addMolFormula").value = "";
							document.getElementById("addMolCAS").value = "";
							document.getElementById("addMolbtn").disabled = false;
							document.getElementById("addMolbtn").style.color = "black";
							document.getElementById("addMolbtn").innerText = "<%=addLabel%>";
						}
						
						return false;
					}
					else
					{
						alert("There is an error occured during the Search. Please try again.");
						resetAddMolBtn();
						return false;
					}
				}
				else
				{
					alert("CAS number not found. Please try another.")
					resetAddMolBtn();
					return false;
				}
			}
		}
	}

	addToReactionMarvin(structureData).then(function() {
		window.parent.experimentSubmit(false,false,false,false,false).then(function(){
			resetAddMolBtn();
		});
	});
}

/**
 * Add reaction using Marvin editor.
 * 
 * @param {collection} structureData - Collection of structure data
 * @param {string} experimentJSON - Experiment data in JSON format
 *
 */
function addToReactionMarvin_async(structureData, experimentJSON)
{
	return new Promise(function(resolve, reject) {
		if(structureData["addStructureToDiagram"] == true && structureData["molType"] != "solvent" && structureData["reagentCdxml"].length > 0)
		{
			if(structureData["molType"] == "reactant")
				structureData["fragLocation"] = "left";
			else if(structureData["molType"] == "reagent")
				structureData["fragLocation"] = "top";
				
			//console.log("starting cdxml: ", structureData["reagentCdxml"]);
		
			$.ajax({
				method: "POST",
				url: "/arxlab/ajax_doers/getCDXTemplate.asp",
				data: { "originCDXML": structureData["reagentCdxml"], "templateCdxml": structureData["experimentCdxml"] },
				async: false
			})
			.done(function(response) {
				console.log("returned cdxml: ", response);
				if(response != null && response.length > 0) {
                    structureData["reagentCdxml"] = truncateCdxmlProlog(response);
				}
			})
			.fail(function() {
				console.log("cas lookup template application failed");
			})
			.always(function() {
				console.log("cas lookup template application always");
			});

			//structureData["newFragmentId"] = window.parent.insertFragment(structureData["fragLocation"],structureData["reagentCdxml"],structureData["experimentCdxml"],structureData["label"]);
		}

		if(structureData["addStructureToDiagram"] == true && structureData["reagentCdxml"].length > 0)
		{
			// Paste into the marvin sketch. Null format so it recognizes it automatically
			marvinSketcherInstance.pasteStructure(null, structureData["reagentCdxml"]);
		}

		var prefix = structureData["prefix"];
		if(!window.parent.UAStates.hasOwnProperty(prefix))
		{
			window.parent.UAStates[prefix] = {};
		}

		promiseArray = [];

		window.parent.document.getElementById(prefix+"_UAStates").value = JSON.stringify(window.parent.UAStates[prefix]);
		promiseArray.push(window.parent.sendAutoSave(prefix+"_UAStates",JSON.stringify(window.parent.UAStates[prefix])));
		
		if(structureData["molType"] !== "solvent")
		{
			thisFieldName = prefix+"_cas";
			window.parent.UAStates[prefix]["cas"] = true;
			window.parent.document.getElementById(thisFieldName).value = structureData["cas"];
			promiseArray.push(window.parent.sendAutoSave(thisFieldName,structureData["cas"]));
			window.parent.document.getElementById(prefix+"_molecularWeight").value = structureData["MW"];
			promiseArray.push(window.parent.sendAutoSave(prefix+"_molecularWeight",structureData["MW"]));
			window.parent.document.getElementById(prefix+"_molecularFormula").value = structureData["Formula"];
			promiseArray.push(window.parent.sendAutoSave(prefix+"_molecularFormula",structureData["Formula"]));

			if(structureData["newFragmentId"] > 0)
			{
				window.parent.newDraftMol(molType,structureData["newFragmentId"],structureData["name"]);
				window.parent.document.getElementById(prefix+"_userAdded").value = "0";
				promiseArray.push(window.parent.sendAutoSave(prefix+"_userAdded","0"));
				window.parent.document.getElementById(prefix+"_hasChanged").value = "1";
				promiseArray.push(window.parent.sendAutoSave(prefix+"_hasChanged","1"));
			}
			else
			{
				window.parent.document.getElementById(prefix+"_userAdded").value = "1";
				promiseArray.push(window.parent.sendAutoSave(prefix+"_userAdded","1"));
				structureData["newFragmentId"] = Math.floor(Math.random() * 2000000)
			}
		}else{
			//if is solvent, and has no fragment, lets give it one.
			if(structureData["newFragmentId"] <= 0){
				structureData["newFragmentId"] = Math.floor(Math.random() * 2000000)
			}
		}

		window.parent.document.getElementById(prefix+"_name").value = structureData["name"];
		promiseArray.push(window.parent.sendAutoSave(prefix+"_name",structureData["name"]));
		window.parent.document.getElementById(prefix+"_trivialName").value = structureData["name"].substr(0,20);
		promiseArray.push(window.parent.sendAutoSave(prefix+"_trivialName",structureData["name"].substr(0,20)));
		window.parent.document.getElementById(prefix+"_tab_text").innerHTML = structureData["name"].substr(0,20);
		window.parent.document.getElementById(prefix+"_fragmentId").value = structureData["newFragmentId"];
		promiseArray.push(window.parent.sendAutoSave(prefix+"_fragmentId",structureData["newFragmentId"]));
	
		resetMolDiv();
	
		Promise.all(promiseArray).then(function() {
			if(!structureData["addStructureToDiagram"]){
				$.post( "<%=mainAppPath%>/experiments/saveStructure.asp", {
					experimentJSON: JSON.stringify(experimentJSON),
					experimentType: experimentType,
					experimentId: experimentId,
					revisionNumber: revisionNumber,
					molType: structureData["molType"],
					prefix: structureData["prefix"]})
				.done(function( data ) {
					hidePopup("showCasResultsDiv");
					resolve();
				});
			}else{
				hidePopup("showCasResultsDiv");
				resolve();
			}
		});
	});
}

/**
 * Add reaction using Marvin editor.
 * 
 * @param {collection} structureData - Collection of structure data
 */
function addToReactionMarvin(structureData) {
    return new Promise(function (resolve, reject) {
        // Create a new tab in the grid
        if (structureData["molType"] === "reactant") {
            addReactant().then(function (prefix) {
                structureData["prefix"] = prefix;
                experimentJSON.reactants = (experimentJSON.reactants == "" ? structureData["prefix"] : experimentJSON.reactants + "," + structureData["prefix"]);
                addToReactionMarvin_async(structureData, experimentJSON).then(function () { resolve() });
            });
        }
        else if (structureData["molType"] === "reagent") {
            addReagent().then(function (prefix) {
                structureData["prefix"] = prefix;
                experimentJSON.reagents = (experimentJSON.reagents == "" ? structureData["prefix"] : experimentJSON.reagents + "," + structureData["prefix"]);
                addToReactionMarvin_async(structureData, experimentJSON).then(function () { resolve() });
            });
        }
        else if (structureData["molType"] === "solvent") {
            addSolvent(structureData["name"]).then(function (prefix) {
                structureData["prefix"] = prefix;
                experimentJSON.solvents = (experimentJSON.solvents == "" ? structureData["prefix"] : experimentJSON.solvents + "," + structureData["prefix"]);
                addToReactionMarvin_async(structureData, experimentJSON).then(function () { resolve() });
            });
        }
        else {
            resolve();
        }
    });
}

arrayOfTimeouts = [];
function fadeHighlightAtom(molId){
	if (typeof marvinSketcherInstance != 'undefined'){
		for (var i = 0; i < arrayOfTimeouts.length; i++) {
			clearTimeout(arrayOfTimeouts[i]);
		}
		marvinSketcherInstance.setHighlight();
		for (x = 100; x >= 0; x-=1){
			if (x == 0){ //zero opacity is treated a full opacity for some odd reason
				arrayOfTimeouts.push(window.setTimeout(marvinSketcherInstance.setHighlight(), 1000));
			}else{
				arrayOfTimeouts.push(window.setTimeout(hightlightAtom,(100-x)*10, molId, x/100));
			}
		}
	}
}


function hightlightAtom(molId, opacity){
	try{
		uuidStr = $('#'+ molId +'_uuidList').val();
		uuidArray = uuidStr.split(":::")
		uuidArray.splice(-1,1)
		//console.log(uuidArray);

		var highlight = {};
		highlight.uids = {};
		highlight.uids.atoms = uuidArray;
		//highlight.uids.bonds = [];

		highlight.style = {}
		highlight.style.color = "#308ef4"
		highlight.style.opacity = opacity;
		var size = "1";
		highlight.style.size = size;

		//console.log(highlight);

		marvinSketcherInstance.setHighlight(highlight);
	}catch(e){
		console.log("Can't highlight " + molId);
	}

}


</script>