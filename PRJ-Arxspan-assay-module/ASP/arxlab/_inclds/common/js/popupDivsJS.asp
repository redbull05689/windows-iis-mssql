<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<script type="text/javascript">

invAddType = "";
<%
	expPrefix = getPrefix(experimentType)
	theExpPage = GetExperimentPage(expPrefix)
	theLink = mainAppPath & "/" & theExpPage & "?id=" & experimentId
	theLink = "<a href='"&theLink&"'>"&experimentName&"</a>"
%>

function addMolInv(){
	el = document.getElementById("molTypeInv")
	val = el.options[el.selectedIndex].value;
	if(val==""){
		alert("Please Select a Type")
	}else{
		invAddType = val;
		hidePopup('addMolDivInv');
		showInventoryPopup(false);
	}
}

function showAddStructureCheckbox()
{
	molAddTypeElem = document.getElementById("molAddType");
	molAddTypeVal = molAddTypeElem.options[molAddTypeElem.selectedIndex].value;
	if(molAddTypeVal == 1 || ($('#molType :selected').text() == "Solvent" && "<%=session("useMarvin")%>" == "True"))
	{
		// Hide for manual additions and marvin solvents
		hideAddStructureCheckbox();
	}
	else
	{
		document.getElementById("addStructureToReaction").checked = true;
		document.getElementById("addStructureToReaction").style.visibility="visible";
		document.getElementById("addStructureToReactionLabel").style.visibility="visible";
	}
}

function hideAddStructureCheckbox()
{
	document.getElementById("addStructureToReaction").checked = false;
	document.getElementById("addStructureToReaction").style.visibility="hidden";
	document.getElementById("addStructureToReactionLabel").style.visibility="hidden";
}

function addToReaction(structureData)
{
    var promiseFunc;
	// Create a new tab in the grid
	if (structureData["molType"] === "reactant") {
		promiseFunc = addReactant();
	}
	else if (structureData["molType"] === "reagent") {
		promiseFunc = addReagent();
    }
	else if (structureData["molType"] === "solvent") {
        promiseFunc = addSolvent(structureData["name"]);
	}

    promiseFunc.then(function (prefix) {
		structureData["prefix"] = prefix;

        structureData["newFragmentInfo"] = {};
        var myPromise = new Promise(function (resolve, reject) {
            if (structureData["addStructureToDiagram"] == true && structureData["molType"] != "solvent" && structureData["reagentCdxml"].length > 0) {
                if (structureData["molType"] == "reactant")
                    structureData["fragLocation"] = "left";
                else if (structureData["molType"] == "reagent")
                    structureData["fragLocation"] = "top";

                //console.log("starting cdxml: ", structureData["reagentCdxml"]);

                $.ajax({
                    method: "POST",
                    url: "/arxlab/ajax_doers/getCDXTemplate.asp",
                    data: { "originCDXML": structureData["reagentCdxml"], "templateCdxml": structureData["experimentCdxml"] },
                })
                    .done(function (response) {
                        console.log("returned cdxml: ", response);
                        if (response != null && response.length > 0) {
                            structureData["reagentCdxml"] = response;
                            window.parent.insertFragment(structureData["fragLocation"], structureData["reagentCdxml"], structureData["experimentCdxml"], structureData["label"])
                                .then(function (fragmentInfo) {
                                    structureData["newFragmentInfo"] = fragmentInfo;
                                    resolve(true);
                                });
                        }
                        else {
                            resolve(true);
                        }
                    })
                    .fail(function () {
                        resolve(true);
                        console.log("cas lookup template application failed");
                    })
                    .always(function () {
                        console.log("cas lookup template application always");
                    });
            }
            else {
                resolve(true);
            }
        })
        .then(function () {
            var promiseChain = [];
            var prefix = structureData["prefix"];
            if (!window.parent.UAStates.hasOwnProperty(prefix)) {
                window.parent.UAStates[prefix] = {};
            }

            window.parent.document.getElementById(prefix + "_UAStates").value = JSON.stringify(window.parent.UAStates[prefix]);
            promiseChain.push(window.parent.sendAutoSave(prefix + "_UAStates", JSON.stringify(window.parent.UAStates[prefix])));

            if (structureData["molType"] !== "solvent") {
                thisFieldName = prefix + "_cas";
                window.parent.UAStates[prefix]["cas"] = true;
                window.parent.document.getElementById(thisFieldName).value = structureData["cas"];
                promiseChain.push(window.parent.sendAutoSave(thisFieldName, structureData["cas"]));
                window.parent.document.getElementById(prefix + "_molecularWeight").value = structureData["MW"];
                promiseChain.push(window.parent.sendAutoSave(prefix + "_molecularWeight", structureData["MW"]));
                window.parent.document.getElementById(prefix + "_molecularFormula").value = structureData["Formula"];
                promiseChain.push(window.parent.sendAutoSave(prefix + "_molecularFormula", structureData["Formula"]));

                if (structureData.hasOwnProperty("newFragmentId") && structureData["newFragmentId"] > 0) {
                    promiseChain.push(window.parent.newDraftMol(molType, structureData["newFragmentInfo"]["fragmentId"], structureData["name"]));
                    window.parent.document.getElementById(prefix + "_userAdded").value = "0";
                    promiseChain.push(window.parent.sendAutoSave(prefix + "_userAdded", "0"));
                    window.parent.document.getElementById(prefix + "_hasChanged").value = "1";
                    promiseChain.push(window.parent.sendAutoSave(prefix + "_hasChanged", "1"));
                }
                else {
                    window.parent.document.getElementById(prefix + "_userAdded").value = "1";
                    promiseChain.push(window.parent.sendAutoSave(prefix + "_userAdded", "1"));
                }
            }

            window.parent.document.getElementById(prefix + "_name").value = structureData["name"];
            promiseChain.push(window.parent.sendAutoSave(prefix + "_name", structureData["name"]));
            window.parent.document.getElementById(prefix + "_trivialName").value = structureData["name"].substr(0, 20);
            promiseChain.push(window.parent.sendAutoSave(prefix + "_trivialName", structureData["name"].substr(0, 20)));
            window.parent.document.getElementById(prefix + "_tab_text").innerHTML = structureData["name"].substr(0, 20);

            if (structureData.hasOwnProperty("newFragmentInfo") && structureData["newFragmentInfo"].hasOwnProperty("fragmentId") && structureData["newFragmentInfo"]["fragmentId"] > 0) {
                window.parent.document.getElementById(prefix + "_fragmentId").value = structureData["newFragmentInfo"]["fragmentId"];
                promiseChain.push(window.parent.sendAutoSave(prefix + "_fragmentId", structureData["newFragmentInfo"]["fragmentId"]));
            }

            resetMolDiv();
            hidePopup("showCasResultsDiv");

            if (structureData.hasOwnProperty("newFragmentInfo") && structureData["newFragmentInfo"].hasOwnProperty("fragmentId") && structureData["newFragmentInfo"]["fragmentId"] > 0) {
                promiseChain.push(window.parent.sendAutoSave("cdxml", structureData["newFragmentInfo"]["reactionData"]));

                Promise.all(promiseChain)
                    .then(function () {
                        updateLiveEditStructureData(structureData["newFragmentInfo"]["reactionElement"], structureData["newFragmentInfo"]["reactionData"], structureData["newFragmentInfo"]["reactionFormat"])
                            .then(function () {
                                try {
                                    $('[liveEditId="' + structureData["newFragmentInfo"]["reactionElement"] + '"]').trigger('chemistryChanged');
                                }
                                catch (e) {
                                    console.log("error calling chemistryChanged... ", e);
                                }
                            });
                    });
            } else {
                Promise.all(promiseChain)
                    .then(function () {
                        checkForChemistryChanges(true).then(function () {
                            experimentSubmit(false, false, true, false, false);
                        });
                    });
            }
        });
	});
}	

function casReturnResultTable(obj)
{
	var resultHTML = "";
	//Change the width of the div showCasResultsDiv
	var windowWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
	document.getElementById("showCasResultsDiv").style.width = (parseInt(windowWidth) - 100)+"px";
	console.log("obj: ", obj);
	
	if (obj["data"].length > 0)
	{
		resultHTML = "<table id='displayResults'><tr class='stochHeadRow'><th>CAS Number</th><th>Formula</th><th>Name</th><th>Structure</th><th></th></tr>"
		for(j=0; j < obj["data"].length; j++)
		{
			cls = isOdd(j);
			var displayCas = "";
			var casJSON = obj["data"][j];
			
			if (!casJSON.hasOwnProperty("cas") || casJSON["cas"] == undefined)
			{
				displayCas = "";
			}
			else
			{
				displayCas = casJSON["cas"];
			}
			
			if (casJSON.hasOwnProperty("cdxml"))
			{
				var imgData = null;
				if(casJSON.hasOwnProperty("cd_structure") && casJSON["cd_structure"].hasOwnProperty("image") && casJSON["cd_structure"]["image"].hasOwnProperty("image"))
					imgData = casJSON["cd_structure"]["image"]["image"];
				else if(casJSON.hasOwnProperty("structureData") && casJSON["structureData"].length == 1 && casJSON["structureData"][0].hasOwnProperty("cd_structure") && casJSON["structureData"][0]["cd_structure"].hasOwnProperty("image") && casJSON["structureData"][0]["cd_structure"]["image"].hasOwnProperty("image"))
					imgData = casJSON["structureData"][0]["cd_structure"]["image"]["image"];
				
				resultHTML += "<tr class="+cls+"><td class='caseInnerData'>"+displayCas+"</td><td class='caseInnerData'>" + casJSON["cd_formula"] +"</td><td class='caseInnerData'>" + casJSON["traditional_name"] + "</td><td>";
				
				if(imgData !== null)
					resultHTML += "<img src='data:image/png;base64,"+imgData+"'></img>";
					
				resultHTML += "</td><td class='caseInnerData' align='center'><button id='addResultMolbtn' class='bottomButtons' onclick='addMolFromList("+j+");'><%=addLabel%></button></td></tr>";
			}
		}
		resultHTML += "</table>"
	}

	return resultHTML;
}

function addMolFromList(casJson_itemId){
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
		"addStructureToDiagram": true,
		"newFragmentId": -1
	};
	
	// Are we supposed to add the structure to the diagram?
	structureData["addStructureToDiagram"] = document.getElementById("addStructureToReaction").checked;
	
	console.log("casJson_itemId::", casJson_itemId);
	console.log("chosenListItemCasJson::", window.casJsonData);
	chosenListItemCasJson = window.casJsonData[casJson_itemId];
	console.log("chosenListItemCasJson::", chosenListItemCasJson);
	
	//**Disable all the buttons on the result div**//
	var el = document.getElementById("chemAxonResultDiv");
    all = el.getElementsByTagName("button");
	
    for(i=0; i<all.length; i++)
	{
		if (i == casJson_itemId)
		{
			all[i].innerText = "Adding..."
		}
		
		all[i].disabled = true;
		all[i].style.color = "grey";
	}
	
	el = document.getElementById("molType")
	val = el.options[el.selectedIndex].value
	
	if(val == "1"){
		structureData["molType"] = "reactant";
	}
	if(val == "2"){
		structureData["molType"] = "reagent";
	}
	

	getChemistryEditorChemicalStructure("mycdx", false).then(function(mycdx){
		structureData["experimentCdxml"] = mycdx;

		if (chosenListItemCasJson.hasOwnProperty("cdxml"))
		{
			structureData["name"] = chosenListItemCasJson["traditional_name"];
			structureData["Formula"] = chosenListItemCasJson["cd_formula"];
			structureData["reagentCdxml"] = chosenListItemCasJson["cdxml"];
			structureData["MW"] = chosenListItemCasJson["cd_molweight"];
			structureData["cas"] = chosenListItemCasJson["cas"];
		}
		<% if session("useMarvin") THEN %>
			addToReactionMarvin(structureData);
		<% ELSE %>
			addToReaction(structureData); 
		<% END IF %>		
	});
}

function resetMolDiv(){
	document.getElementById('extraMolData').style.display = 'none'
	molTypeChange();
	hidePopup('addMolDiv')

	document.getElementById('lean_overlay').style.display = "none";
	document.getElementById('addMolName').value = ''
	document.getElementById('addMolMW').value = ''
	document.getElementById('addCasCdId').value = ''
	document.getElementById('addMolFormula').value = ''
	
	if(document.getElementById('addMolCAS'))
	{
		document.getElementById('addMolCAS').value = ''
		document.getElementById('addCasName').value = ''
	}
}	

function isOdd(num) { 
	var cls = ""
	if(num % 2 == 1){
		cls = 'stochOdd'
	}
	else {
		cls = 'stochEven'
	}
	return cls
}

function resetAddMolBtn() {
	if (document.getElementById("addMolbtn").innerText = "Searching..") {
		document.getElementById("addMolbtn").innerText = "<%=addLabel%>"
	}
	document.getElementById("addMolbtn").disabled = false
	document.getElementById("addMolbtn").style.color = 'black'
}

function assignMolType(molTypeVal)
{
	molType = "";
	if(molTypeVal === '1')
		molType = 'reactant';
	else if (molTypeVal === '2')
		molType = 'reagent';
	else if (molTypeVal === '4')
		molType = 'solvent';
		
	return molType;
}

function assignCasDataSource(addTypeVal)
{
	var addType = "";
	if(addTypeVal === '1')
		addType = 'manual';
	else if (addTypeVal === '2')
		addType = 'casNumber';
	else if (addTypeVal === '3')
		addType = 'reagentDb';
		
	return addType;
}

<%If experimentType Then %>
function addMol()
{
	waitForCas = false;

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
		el = document.getElementById("reagentDatabaseSelect")
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
		structureData["fields"] = eval("("+getFile("<%=mainAppPath%>/misc/ajax/load/getReagentDatabaseData.asp?id="+document.getElementById("reagentDatabaseSelect").options[document.getElementById("reagentDatabaseSelect").selectedIndex].value)+")")
		structureData["cas"] = structureData["fields"].cas
		structureData["name"] = structureData["fields"].name
		structureData["MW"] = structureData["fields"].molecularWeight
		structureData["Formula"] = structureData["fields"].molecularFormula
	}
	else
	{	
		//CAS structure conversion
		waitForCas = true;
		molData = "";
		getChemistryEditorChemicalStructure("mycdxSearch", false).then(function(searchMolData){

			molData = searchMolData;
		}).catch(function(){
			console.log("No CDX Search data");
            if (document.getElementById("mycdxSearch")) {
                hasChemdraw().then(function (isInstalled) {
                    if (isInstalled) {
                        molData = cd_getData("mycdxSearch", "chemical/x-mdl-molfile");
                    }
                });
            }
		}).then(function(){
			getChemistryEditorChemicalStructure("mycdx", false).then(function(experimentCdxml){
				if ($("#addCasCdId").val().length == 0 && document.getElementById("addMolCAS").value == "" && document.getElementById("addCasName").value == "" && molData == "") {
					alert("Please Enter a CAS Number or Name or Structure")
					resetAddMolBtn()
					return false;
				}else{
					structureData["experimentCdxml"] = experimentCdxml;
					document.getElementById("addMolbtn").innerText = "Searching..";
					
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
			addToReaction(structureData);
			resetAddMolBtn();
			});
		});
	}

	if(!waitForCas){
		addToReaction(structureData);
		resetAddMolBtn();
	}
}
<%End If%>

function molTypeChange()
{
	document.getElementById('addMolName').value = ''
	document.getElementById('addMolMW').value = ''
	document.getElementById('addMolFormula').value = ''
	
	molAddTypeElem = document.getElementById("molAddType");
	molAddTypeVal = molAddTypeElem.options[molAddTypeElem.selectedIndex].value;
	if(molAddTypeVal == 1)
	{
		// For manual additions, don't show the "Include Structure" checkbox
		hideAddStructureCheckbox();
	}
	else
	{
		// Do show it for other selections
		showAddStructureCheckbox();
	}
	
	el = document.getElementById("molType")
	val = el.options[el.selectedIndex].value
	if (val == '0')
	{
		document.getElementById("molAddType").selectedIndex = 0;
	}
	else
	{
		el = document.getElementById("molAddType")
		val2 = el.options[el.selectedIndex].value
		if (val2 == '0')
		{
			el.selectedIndex = 1;
		}
	}
	if (val=='2')
	{
		document.getElementById("reagentDatabaseOption").disabled = false
	}
	else
	{
		document.getElementById("reagentDatabaseOption").disabled = true
	}
	if (val == '1' || val == '2' || val == '3')
	{
		el = document.getElementById("molAddType")
		val = el.options[el.selectedIndex].value
		if (val == '2')
		{
			document.getElementById('extraMolData').style.display = 'none'
			document.getElementById('extraMolData2-1').style.display = 'none'
			document.getElementById('extraMolData2-2').style.display = 'none'
			document.getElementById('reagentDatabaseDiv').style.display = 'none'
			document.getElementById('casDiv').style.display = 'block';
			document.getElementById('casDiv-1').style.display = 'block';
			document.getElementById('addMolbtn').innerText = "<%=searchLabel%>";
		}
		if (val == '1')
		{
			document.getElementById('extraMolData').style.display = 'block'
			document.getElementById('extraMolData2-1').style.display = 'block'
			document.getElementById('extraMolData2-2').style.display = 'block'
			document.getElementById('reagentDatabaseDiv').style.display = 'none'
			document.getElementById('casDiv').style.display = 'none';
			document.getElementById('casDiv-1').style.display = 'none';
		}
		if (val == '3')
		{
			document.getElementById('extraMolData').style.display = 'none'
			document.getElementById('extraMolData2-1').style.display = 'none'
			document.getElementById('extraMolData2-2').style.display = 'none'
			document.getElementById('reagentDatabaseDiv').style.display = 'block'
			document.getElementById('casDiv').style.display = 'none';
			document.getElementById('casDiv-1').style.display = 'none';
			selectObject = eval('('+getFile("<%=mainAppPath%>/misc/ajax/load/getReagentDatabaseSelect.asp?rand="+Math.random())+')')
			el = document.getElementById('reagentDatabaseSelectLabel')
			wrappedSelect = document.createElement("div");
			wrappedSelect.setAttribute("class","select-style");
			wrappedSelect.appendChild(createSelect(selectObject));
			if(!document.getElementById("reagentDatabaseSelect"))
			{
				insertAfter(el.parentNode,wrappedSelect,el)
			}
		}
	}
	else
	{
		el = document.getElementById("molAddType")
		val = el.options[el.selectedIndex].value
		if (val == '2')
		{
			document.getElementById('extraMolData').style.display = 'none'
			document.getElementById('extraMolData2-1').style.display = 'none'
			document.getElementById('extraMolData2-2').style.display = 'none'
			document.getElementById('reagentDatabaseDiv').style.display = 'none'
			document.getElementById('casDiv').style.display = 'block';
			document.getElementById('casDiv-1').style.display = 'block';
			document.getElementById('addMolbtn').innerText = "<%=searchLabel%>";
		}
		if (val == '1')
		{
			document.getElementById('extraMolData').style.display = 'block'
			document.getElementById('extraMolData2-1').style.display = 'none'
			document.getElementById('extraMolData2-2').style.display = 'none'
			document.getElementById('reagentDatabaseDiv').style.display = 'none'
			document.getElementById('casDiv').style.display = 'none';
			document.getElementById('casDiv-1').style.display = 'none';
		}
	}
}

function splitCustomExperimentTypeAndRequestTypeId()
{
	var selectList = document.getElementById("nextStepExperimentType");
	var selectedValue = selectList.options[selectList.selectedIndex].value;
	var colonPos = selectedValue.indexOf(":");
	
	if(colonPos != -1)
	{
		var newExperimentType = selectedValue.substr(0,colonPos);
		var requestId = selectedValue.substr(colonPos + 1, selectedValue.length);
		console.log("experimentType:", newExperimentType, "; requestId: ", requestId);
		selectList.options[selectList.selectedIndex].value = newExperimentType;
		document.getElementById("nextStepRequestTypeId").value = requestId;
	}
}

function newProjectLink(){
	el = document.getElementById('linkProjectId2');
	projectId = el.options[el.selectedIndex].value;
	projectName = el.options[el.selectedIndex].getAttribute('projectName');
	projectDescription = el.options[el.selectedIndex].getAttribute('projectDescription');
	if (projectId != "x"){
		r = getFile('ajax_doers/addProjectLinkToExperiment.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&projectId='+projectId);
		if (r == "success"){
			theTD = document.getElementById("projectLinksTD");
			div = document.createElement("div");
			div.setAttribute("id","projectList_"+projectId)
			a = document.createElement("a");
			a.href = "show-project.asp?id="+projectId;
			a.innerHTML = projectName;
			div.appendChild(a);
			a = document.createElement("a");
			a.setAttribute("href","<%=mainAppPath%>/projects/project-remove-experiment.asp?projectId="+projectId+"&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&fromExperiment=1");
			a.setAttribute("target","submitFrame")
			a.className="deleteObjectLink";
			a.onclick = function(){
				if(confirm('Are you sure you wish to remove this experiment?')){
					document.getElementById('projectList_'+projectId).style.display='none';
					return true;
				}
			}
			img = document.createElement("img");
			img.setAttribute("border","0");
			img.src = "images/delete.png";
			img.className = "png";
			img.setAttribute("width","12");
			img.setAttribute("height","12");
			a.appendChild(img);
			div.appendChild(a);
			p = document.createElement("p");
			p.className="linkDescription"
			p.innerHTML = projectDescription;
			div.appendChild(a);
			theTD.appendChild(div);
			hidePopup('projectLinkDiv');
		}else{
			alert(r);
		}
	}else{
		alert("This project has tabs. Please select the tab that you would like to link to.")
	}
}

/**
	* Function to set the URL of the inventory search frame before displaying it.
	* @param {boolean} createItem Are we creating a new item?
	*/
function showInventoryPopup(createItem){

	// Instantiate the inventory URL. If we're creating an item, add the appropriate flag to the querystring.
	var url = '<%=mainAppPath%>/inventory2/index.asp?inFrame=true&link='+encodeURIComponent("<%=theLink%>")+"&experimentType=<%=experimentType%>"
	if (createItem) {
		url += "&addFromNonChemELN=true";
	}
	document.getElementById("inventorySearchFrame").src = url;
	showPopup("inventoryPopup");
}

function showInventoryPopupAdd(prefix){
	if(document.getElementById(prefix+"_measuredMass").value!=""){
	amount = document.getElementById(prefix+"_measuredMass").value.split(" ")[0];
	amountUnits = document.getElementById(prefix+"_measuredMass").value.split(" ")[1];
	if(amountUnits==undefined){
	try{
	a = document.getElementById(prefix+"_measuredMass").value.match(/[a-zA-Z]+|[0-9\.]+/g);
	amount = a[0];
	amountUnits = a[1];
	}catch(err){}
	}
	molUpdateCdxml2 = $("#"+prefix+"_molData3000").val();
	molUpdateCdxml = $("#"+prefix+"_molData").val();
	trivialName = document.getElementById(prefix+"_trivialName").value
	$("#inventorySearchFrame").attr("scrolling","no").attr("seamless","seamless");
	//Note this is for testing revert before commit!
	document.getElementById("inventorySearchFrame").src = '<%=mainAppPath%>/inventory2/index.asp?inFrame=true&addFromEln=true&link='+encodeURIComponent("<%=theLink%>")+"&experimentType=<%=experimentType%>&amount="+amount+"&amountUnits="+amountUnits+"&prefix="+prefix+"&trivialName="+trivialName;
	showPopup("inventoryPopup");
	}else{
	alert("Products must have an measured mass before being added to inventory.")
	}
}

/**
 * Add new reg id to grid and close reg popup
 * @param {string} regFieldId The Id used to correctly add to the grid
 * @param {string} wholeRegNumber New reg id to add
 * @param {object} $btn Btn to disable to prevent double clicking by user
 **/
function addRegIdToGridAndClose(regFieldId, wholeRegNumber, $btn = null) {
	if (wholeRegNumber){
		if ($btn) {
			$btn.attr('disabled', 'disabled');
			$btn.val('WAIT');
		}
		
		window.parent.document.getElementById(regFieldId).value = wholeRegNumber;
		window.parent.experimentJSON[regFieldId] = wholeRegNumber;
		window.parent.unsavedChanges = false;
		window.parent.experimentSubmit(false,false,false);
	}
	window.parent.hidePopup('regDiv');
}

/**
 * Show inv popup used for after reg 
 * @param {string} prefix The prefix of the fragment in the grid 
 **/
function addToInvPopup(prefix, regId){
	var massField = window.top.$(`#${prefix}_measuredMass`);
	if(!massField || !massField.val()){ 
		massField = window.top.$(`#${prefix}_sampleMass`);
	} 
	if(massField && massField.val()){
		amount = massField.val().split(" ")[0];
		amountUnits = massField.val().split(" ")[1];
		if(amountUnits==undefined){
			try{
				a = massField.val().match(/[a-zA-Z]+|[0-9\.]+/g);
				amount = a[0];
				amountUnits = a[1];
			}catch(err){}
		}
		molUpdateCdxml2 = window.top.$(`#${prefix}_molData3000`).val();
		molUpdateCdxml = window.top.$(`#${prefix}_molData`).val();
		trivialName = window.top.$(`#${prefix}_measuredMass`).val();
		document.getElementById("inventorySearchFrame").src = `<%=mainAppPath%>/inventory2/index.asp?inFrame=true&addAfterRegFromELN=true&link=${encodeURIComponent("<%=theLink%>")}&experimentType=<%=experimentType%>&amount=${amount}&amountUnits=${amountUnits}&prefix=${prefix}&trivialName=${trivialName}&regId=${regId}`;
		showPopup("inventoryPopup");
	}else{
		swal("Error!", "You must enter a mass value before you can add this item to inventory.", "error");
	}

}

function showMultiAddInventoryPopup(){
	<%if experimentType="1" then%>
		if (!useChemDrawForLiveEdit) {
			hasChemdraw().then(function (isInstalled) {
				if (!isInstalled) {
					alert("ChemDraw is required to use this functionality.")
					return false;
				}
			});
		}
	<%end if%>
	console.log("redirecting to: ", '<%=mainAppPath%>/inventory2/index.asp?inFrame=true&barcodeChooser=true&link='+encodeURIComponent("<%=theLink%>")+"&experimentType=<%=experimentType%>");
	document.getElementById("inventorySearchFrame").src = '<%=mainAppPath%>/inventory2/index.asp?inFrame=true&barcodeChooser=true&link='+encodeURIComponent("<%=theLink%>")+"&experimentType=<%=experimentType%>";
	showPopup("inventoryPopup");
}

/**
	* Reads the value from the inventoryLinkDiv radio button and determines which popup to display.
	*/
function submitInventoryLinkDiv() {
	var invLinkVal = $("input[name=inventoryLinkRadio]:checked").val();

	if (invLinkVal == "existingItem") {
		hidePopup("inventoryLinkSelectorDiv");
		showInventoryPopup(false);
	} else if (invLinkVal == "newItem") {
		hidePopup("inventoryLinkSelectorDiv");
		showInventoryPopup(true);
	} else {
		swal("", "Please select an option.");
	}
}

function clearExpList() {
	$('[name="newExperimentType"]').html('<option value="">--- SELECT ---</option>');
}

function expListIsEmpty() {
	return $("#newExperimentTypeList").children().length <= 1;
}

function getExperimentSelectValue(useTypeIds, requestTypeId)
{
	var selectValue = "<%=mainAppPath%>/cust-experiment.asp?r=" + requestTypeId;
	if(useTypeIds)
		selectValue = "5:" + requestTypeId;
	return selectValue;
}

function getWorkflowRequestTypes(useTypeIds) {
	return new Promise(function(resolve, reject) {
		getWorkflowRequestTypesCall().then(function(response) {
			console.log("success");
			clearExpList();
				
			populateDefaultExperimentTypes(useTypeIds);
			if(typeof response !== "undefined"){
				console.log(response);
				responseData = JSON.parse(response["data"]);
				reqNames = [];
				reqIds = [];

				if (responseData.length > 0) {
					$("[name='newExperimentType']").show();
				}
				
				$.each(responseData, function(index, reqObj) {
					console.log("calling getExperimentSelectValue with useTypeIds: ", useTypeIds);
					reqNames.push(reqObj["displayName"]);
					reqIds.push(reqObj["id"]);
					appendToExpList(getExperimentSelectValue(useTypeIds, reqObj["id"]), reqObj["displayName"], false);
				});
				if (window.defExpType){
					$("#newExperimentTypeList").val(window.defExpType);
				}
				saveReqTypes(reqNames, reqIds);

				resolve(responseData);
			}
		})
	})
}

function getWorkflowRequestTypesCall() {
	return new Promise(function(resolve, reject) {
		serviceUrl = "/requesttypes/requestTypeNamesByPermissionType?"
		serviceUrl += "appName=ELN"
		serviceUrl += "&permissionType=canAdd"
		serviceUrl += "&includeDisabled=false";

		$.ajax({
			url: "<%=mainAppPath%>/workflow/invp.asp",
			type: "POST",
			dataType: "json",
			data: {
				verb: "GET",
				url: encodeURI(serviceUrl),
				config: true,
				serialUUID: uuidv4()
			}
		}).done(function(response) {
			window.experimentTypeDropDownTypeList = response;
			resolve(response);
		});

	});
}

function populateDefaultExperimentTypes(useTypeIds)
{
<%
	Set expDefaultRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT useDefaultExperimentTypes FROM companySettings WHERE companyId="&SQLClean(session("companyId"),"T","S")
	expDefaultRec.open strQuery,conn,0,-1
	
	loadDefaultExperiments = True
	If Not expDefaultRec.eof Then
		If expDefaultRec("useDefaultExperimentTypes") = 0 Or expDefaultRec("useDefaultExperimentTypes") = "0" Then
			loadDefaultExperiments = False
		End If
	End If
	
	If loadDefaultExperiments Then
%>
		var hasChem = '<%=session("hasChemistry")%>' == 'True';
		var hideNonCollab = '<%=session("hideNonCollabExperiments")%>' == 'True';
		var hasMUF = '<%=session("hasMUFExperiment")%>' == 'True';
		var hasFree = '<%=hasFreeExperiment%>' == '1';
		var hasAnal = '<%=hasAnalExperiment%>' == '1';
		var blockNewColab = '<%=blockNewColab%>' == '1';

		$("#newExperimentTypeList").empty();
		appendToExpList("", "--- SELECT ---", true);

		if (hasChem && !hideNonCollab) {
			var theVal = '<%=mainAppPath%>/<%=session("expPage")%>';
			if(useTypeIds)
				theVal = "1";
			appendToExpList(theVal, "Chemistry", true);
		}

		if (!hideNonCollab) {
			var theVal = "<%=mainAppPath%>/bio-experiment.asp";
			if(useTypeIds)
				theVal = "2";
			appendToExpList(theVal, "Biology", true);
		}
		
		if (hasFree && !blockNewColab) {
			var freeName = "Concept";
			if (hasMUF)
				freeName = "<%=mufName%>";
			var theVal = "<%=mainAppPath%>/free-experiment.asp";
			if(useTypeIds)
				theVal = "3";
			appendToExpList(theVal, freeName, true);
		}

		if (hasAnal && !hideNonCollab) {
			var theVal = "<%=mainAppPath%>/anal-experiment.asp";
			if(useTypeIds)
				theVal = "4";
			appendToExpList(theVal, "Analytical", true);
		}
<%
	End If
%>	
	// If there is only one choice in the list, select it by default
	if($("#newExperimentTypeList").children().length == 2)
	{
		$("#newExperimentTypeList :nth-child(2)").prop("selected", true);
	}
	else
	{
		<%
		' VBScript block to figure out what the selected dropdown option should be and set a connectionId.
		defExpType = session("defaultExperimentType")
		If defExpType <> "" Then
			If defExpType >= 5000 Then
				defRequestTypeId = defExpType - 5000
				defExpType = 5
			End If

			defExpPage = defExpType
			If Len(defExpType) = 1 Then
				prefix = GetPrefix(defExpType)
				defExpPage = GetExperimentPage(prefix)

				If defExpType = 5 Then
					defExpPage = defExpPage & "?r=" & defRequestTypeId
				End If
			End If
		%>
			window.defExpType = "<%=mainAppPath & "/" & defExpPage%>";
			$("#newExperimentTypeList").val("<%=mainAppPath & "/" & defExpPage%>");
		<%
		End If
		%>
	}
}

function saveReqTypes(reqNames, reqIds) {
	$.ajax({
		url: "<%=mainAppPath%>/_inclds/common/asp/saveReqTypes.asp",
		type: 'POST',
		data: {
			"reqNames": reqNames.join(","),
			"reqIds": reqIds.join(",")
		}
	})
	.done(function() {
		console.log("Saved request types");
	})
}

function appendToExpList(expPage, title, newExpDiv) {
	selected = '';
	if (typeof experimentType !== 'undefined') {
		if (expPage == experimentType){
			selected = 'selected';
		}
	}
	var selectorString = '[name="newExperimentType"]';
	if (newExpDiv) {
		selectorString = ".selectStyles" + selectorString;
	}
	$(selectorString).append('<option value="' + expPage + '" ' + selected + ' >' + title + '</option>');
		$("#nextStepExperimentType").trigger("change");
}

// Set up experiment type dropdown.
function populateExpTypes(useTypeIds) {
	return getWorkflowRequestTypes(useTypeIds);
}

function getDateForService() {
		var now = new Date();
		var year = now.getUTCFullYear();
		var month = now.getUTCMonth() + 1;
		var day = now.getUTCDate();
		var hours = now.getUTCHours();
		var minutes = now.getUTCMinutes();
		var seconds = now.getSeconds();

		var formatStr =  "{year}-{month}-{day} {hours}:{minutes}:{seconds}";
		formatStr = formatStr.replace("{year}", year);
		formatStr = formatStr.replace("{month}", month);
		formatStr = formatStr.replace("{day}", day);
		formatStr = formatStr.replace("{hours}", hours);
		formatStr = formatStr.replace("{minutes}", minutes);
		formatStr = formatStr.replace("{seconds}", seconds);

		return formatStr;
}

</script>