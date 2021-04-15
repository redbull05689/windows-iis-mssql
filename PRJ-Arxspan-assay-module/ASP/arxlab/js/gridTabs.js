function getForm(type, number, divId, onSave, overwriteCache)
{
	return new Promise(function (resolve, reject) {	
		//IE doesn't support default parameters...
		onSave = (typeof onSave !== 'undefined') ?  onSave : false;
		overwriteCache = (typeof overwriteCache !== 'undefined') ?  overwriteCache : false;

		//experimentJSON is only empty on the first loading
		if (typeof experimentJSON == 'undefined'){
			experimentJSON = {};
		}
		firstLoad = (JSON.stringify(experimentJSON) == "{}");

		//OverWriteCache tells us its a new mol. So don't bother keeping anything
		if(overwriteCache){
			userEnteredFields = "";
		}else{
			// we usually don't want to overwrite what the user wrote

			//Update UAStates
			var theKeys = Object.keys(experimentJSON);
			uaStatesList = theKeys.filter(function(value){
				return /(r|rg|s|p)\d+_UAStates/.test(value);
			});
			uaStatesList.forEach(function(element){
				theMatch = element.match(/(r|rg|s|p)\d+/);
				if(experimentJSON[element] != "" && typeof experimentJSON[element] != 'undefined'){
					UAStates[theMatch[0]] = JSON.parse(experimentJSON[element]);
				}
			});

			userEnteredFields = getUserEnteredFields(type, number);
		}
		
		$.ajax({
			async: false,	// Setting this to true would cause some issues in Stoichiometry.
			cache: false,
			method: "GET",
			dataType: 'html',
			url: "/arxlab/experiments/ajax/load/getObject.asp?type=" + type + "&number=" + number + "&id=" + id + "&revisionId=" + revisionId + "&userenteredfields=" + userEnteredFields + "&firstload=" + firstLoad + "&onsave=" + onSave,
		})
		.done(function (table) {
			if (divId == "formDiv") {
				// Create a new node if the div id is not the main form "formDiv". This is mainly for the Stoichiometry stuff.
				newEL = document.createElement("div");
				newEL.setAttribute("class", "newEL");
				newEL.innerHTML = table;
				insertAfter(document.getElementById("formDiv"), newEL, document.getElementById('rc_body'));
			} else {
				$("#" + divId).html(table);
			}

			resolve(true);
		});
	});
}

// looks in UAStates and finds the user entered fields for the current mol
function getUserEnteredFields(type, number){
	var retval = [];
	substr = "";
	if (type == "Reactant"){
		substr = "r";
	}else if (type == "Reagent"){
		substr = "rg";
	}else if (type == "Solvent"){
		substr = "s";
	}else if (type == "Product"){
		substr = "p";
	}

	for(field in UAStates[substr + number]){
		if(UAStates[substr + number][field]){
			retval.push(substr + number + "_" + field);
		}
	}
	return retval.join("|");
}

	function populateQuickView()
	{
		trivialNameInQuickView = document.getElementById("trivialNameInQuickView").value;
		if(trivialNameInQuickView=="1"){
			fullChemicalName = false;
		}

		if(document.getElementById("craisCheckRun")){
			craisTd = "<td></td>";
			showCraisText = true;
		}else{
			craisTd = "";
			showCraisText = false;
		}
		
		document.getElementById("qv_body_container").innerHTML = "";
		HTML = "<table class='caseTable' cellpadding='0' cellspacing='0' id='qv_body' style='margin-bottom:0;width:100%;'><tr class='stochHeadRow'>"+craisTd+"<td class='caseInnerData' valign='top'><b>Name</b></td><td class='caseInnerData' valign='top'><b>Molecular Weight</b></td><td class='caseInnerData' valign='top'><b>Molarity/Density</b></td><td class='caseInnerData' valign='top'><b>Moles</b></td><td class='caseInnerData' valign='top'><b>Mass/Volume</b></td><td class='caseInnerData' valign='top'><b>Equivalents</b></td><td class='caseInnerData' valign='top'><b>W/W</b></td><td class='caseInnerData' valign='top'><b>LIMIT</b></td></tr>"

		counter = 0
		foundAType = false;

		for (i=0;i<30 ;i++ )
		{
			if (document.getElementById("r"+i+"_body"))
			{
				if(counter % 2 == 0){
					theClass = "stochEven";
				}else{
					theClass = "stochOdd";
				}
				if(i==1){
					if(foundAType){
						theClass += " quickViewFirstRowOfType";
					}
					foundAType = true;
				}
				if(document.getElementById("craisStatus")){
					if(document.getElementById("r"+i+"_craisClass")){
						if(document.getElementById("r"+i+"_craisClass").value=="CLASS-A"){
							theClass += " craisRed";
							document.getElementById("r"+i+"_tab").className += " craisRed";
						}
						if(document.getElementById("r"+i+"_craisClass").value=="CLASS-B"){
							theClass += " craisYellow";
							document.getElementById("r"+i+"_tab").className += " craisYellow";
						}
					}
				}
				counter += 1
				HTML += "<tr class='"+theClass+"'>"
				if(showCraisText){
					theText = document.getElementById("r"+i+"_craisText").value.replace(/\'/g,"\'").replace(/<br\/>/g,"\n");
					HTML += "<td valign='top'>"
					if(theText!=""){
						HTML += "<a href='javascript:void(0);return false;' title='"+theText+"'><img border='0' src='images/qmark.png'></a>"
					}
					HTML += "</td>"
				}
				if (document.getElementById("r"+i+"_trivialName").value != "")
				{
					if(!fullChemicalName)
					{
						HTML += "<td class='caseInnerData' valign='top' data-source-field='r"+i+"_trivialName'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#r"+i+"_trivialName").val())+"' /></td>";
					}
					else
					{
						HTML += "<td class='caseInnerData' valign='top' data-source-field='r"+i+"_name'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+htmlDecode(escapeHtml($("#r"+i+"_name").val()))+"' /></td>";
					}
				}
				else
				{
					HTML += "<td class='caseInnerData' valign='top' data-source-field='r"+i+"_trivialName'><input " + (readOnly ? "disabled" : "") + " type='text' value='Reactant "+i+"' /></td>";
				}
				HTML += quickViewFieldWithDropdown(i, "r", "molecularWeight");
				if (document.getElementById("r"+i+"_molarity").value != "")
				{
					HTML += quickViewFieldWithDropdown(i, "r", "molarity");
				}
				else
				{
					HTML += quickViewFieldWithDropdown(i, "r", "density");
				}

				HTML += quickViewFieldWithDropdown(i, "r", "moles");
				
				if (document.getElementById("r"+i+"_volume").value != "")
				{
					HTML += quickViewFieldWithDropdown(i, "r", "volume");
				}
				else
				{
					HTML += quickViewFieldWithDropdown(i, "r", "sampleMass");
				}
				HTML += "<td class='caseInnerData' valign='top' data-source-field='r"+i+"_equivalents'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#r"+i+"_equivalents").val())+"' /></td>";

				HTML += "<td class='caseInnerData' valign='top' data-source-field='r"+i+"_weightRatio'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#r"+i+"_weightRatio").val())+"' /></td>";
				
				if(document.getElementById("r"+i+"_limit").checked){
					HTML += "<td class='caseInnerData' valign='top' data-source-field='r"+i+"_limit'><input " + (readOnly ? "disabled" : "") + " type='checkbox' checked='true' /></td>";
				}else{
					HTML += "<td class='caseInnerData' valign='top' data-source-field='r"+i+"_limit'><input " + (readOnly ? "disabled" : "") + " type='checkbox' /></td>";
				}
				HTML += "</tr>";
			}
		}

	
		for (i=0;i<30 ;i++ )
		{
			if (document.getElementById("rg"+i+"_body"))
			{
				if(counter % 2 == 0){
					theClass = "stochEven";
				}else{
					theClass = "stochOdd";
				}
				if(i==1){
					if(foundAType){
						theClass += " quickViewFirstRowOfType";
					}
					foundAType = true;
				}
				if(document.getElementById("craisStatus")){
					if(document.getElementById("rg"+i+"_craisClass")){
						if(document.getElementById("rg"+i+"_craisClass").value=="CLASS-A"){
							theClass += " craisRed";
							document.getElementById("rg"+i+"_tab").className += " craisRed";
						}
						if(document.getElementById("rg"+i+"_craisClass").value=="CLASS-B"){
							theClass += " craisYellow";
							document.getElementById("rg"+i+"_tab").className += " craisYellow";
						}
					}
				}
				counter += 1;
				HTML += "<tr class='"+theClass+"'>";
				if(showCraisText){
					theText = document.getElementById("rg"+i+"_craisText").value.replace(/\'/g,"\'").replace(/<br\/>/g,"\n");
					HTML += "<td valign='top'>";
					if(theText!=""){
						HTML += "<a href='javascript:void(0);return false;' title='"+theText+"'><img border='0' src='images/qmark.png'></a>";
					}
					HTML += "</td>";
				}
				if (document.getElementById("rg"+i+"_trivialName").value != "")
				{
					if(!fullChemicalName)
					{
						HTML += "<td class='caseInnerData' valign='top' data-source-field='rg"+i+"_trivialName'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#rg"+i+"_trivialName").val())+"' /></td>";
					}
					else
					{
						HTML += "<td class='caseInnerData' valign='top' data-source-field='rg"+i+"_name'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+htmlDecode(escapeHtml($("#rg"+i+"_name").val()))+"' /></td>";
					}
				}
				else
				{
					HTML += "<td class='caseInnerData' valign='top' data-source-field='rg"+i+"_trivialName'><input " + (readOnly ? "disabled" : "") + " type='text' value='Reagent "+i+"' /></td>";
				}
				HTML += quickViewFieldWithDropdown(i, "rg", "molecularWeight");
				if (document.getElementById("rg"+i+"_molarity").value != "")
				{
					HTML += quickViewFieldWithDropdown(i, "rg", "molarity");
				}
				else
				{
					HTML += quickViewFieldWithDropdown(i, "rg", "density");
				}
				HTML += quickViewFieldWithDropdown(i, "rg", "moles");
				if (document.getElementById("rg"+i+"_volume").value != "")
				{
					HTML += quickViewFieldWithDropdown(i, "rg", "volume");
				}
				else
				{
					HTML += quickViewFieldWithDropdown(i, "rg", "sampleMass");
				}
				HTML += "<td class='caseInnerData' valign='top' data-source-field='rg"+i+"_equivalents'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#rg"+i+"_equivalents").val())+"' /></td>";

				HTML += "<td class='caseInnerData' valign='top' data-source-field='rg"+i+"_weightRatio'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#rg"+i+"_weightRatio").val())+"' /></td>";

				if(document.getElementById("rg"+i+"_limit").checked){
					HTML += "<td class='caseInnerData' valign='top' data-source-field='rg"+i+"_limit'><input " + (readOnly ? "disabled" : "") + " type='checkbox' checked='true' /></td>";
				}else{
					HTML += "<td class='caseInnerData' valign='top' data-source-field='rg"+i+"_limit'><input " + (readOnly ? "disabled" : "") + " type='checkbox' /></td>";
				}

				HTML += "</tr>";
			}
		}

		for (i=0;i<30 ;i++ )
		{
			if (document.getElementById("s"+i+"_body"))
			{
				if(counter % 2 == 0){
					theClass = "stochEven";
				}else{
					theClass = "stochOdd";
				}
				if(i==1){
					if(foundAType){
						theClass += " quickViewFirstRowOfType";
					}
					foundAType = true;
				}
				if(document.getElementById("craisStatus")){
					if(document.getElementById("s"+i+"_craisClass")){
						if(document.getElementById("s"+i+"_craisClass").value=="CLASS-A"){
							theClass += " craisRed"
							document.getElementById("s"+i+"_tab").className += " craisRed";
						}
						if(document.getElementById("s"+i+"_craisClass").value=="CLASS-B"){
							theClass += " craisYellow"
							document.getElementById("s"+i+"_tab").className += " craisYellow";
						}
					}
				}
				counter += 1;
				HTML += "<tr class='"+theClass+"'>";
				if(showCraisText){
					theText = document.getElementById("s"+i+"_craisText").value.replace(/\'/g,"\'").replace(/<br\/>/g,"\n");
					HTML += "<td valign='top'>";
					if(theText!=""){
						HTML += "<a href='javascript:void(0);return false;' title='"+theText+"'><img border='0' src='images/qmark.png'></a>";
					}
					HTML += "</td>";
				}
				if (document.getElementById("s"+i+"_trivialName").value != "")
				{
					if(!fullChemicalName)
					{
						HTML += "<td class='caseInnerData' valign='top' data-source-field='s"+i+"_trivialName'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#s"+i+"_trivialName").val())+"' /></td>";
					}
					else
					{
						HTML += "<td class='caseInnerData' valign='top' data-source-field='s"+i+"_name'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#s"+i+"_name").val())+"' /></td>";
					}
				}
				else
				{
					HTML += "<td class='caseInnerData' valign='top' data-source-field='s"+i+"_trivialName'><input " + (readOnly ? "disabled" : "") + " type='text' value='Solvent "+i+"' /></td>";
				}
				HTML += "<td class='caseInnerData' valign='top'></td>";
				HTML += "<td class='caseInnerData' valign='top'></td>";
				HTML += quickViewFieldWithDropdown(i, "s", "moles");
				HTML += quickViewFieldWithDropdown(i, "s", "volume");
				HTML += "<td class='caseInnerData' valign='top'></td>";
				HTML += "<td class='caseInnerData' valign='top'></td>";
				HTML += "</tr>";
			}
		}

		for (i=0;i<30 ;i++ )
		{
			if (document.getElementById("p"+i+"_body"))
			{
				if(counter % 2 == 0){
					theClass = "stochEven";
				}else{
					theClass = "stochOdd";
				}
				if(i==1){
					if(foundAType){
						theClass += " quickViewFirstRowOfType";
					}
					foundAType = true;
				}
				if(document.getElementById("craisStatus")){
					if(document.getElementById("p"+i+"_craisClass")){
						if(document.getElementById("p"+i+"_craisClass").value=="CLASS-A"){
							theClass += " craisRed";
							document.getElementById("p"+i+"_tab").className += " craisRed";
						}
						if(document.getElementById("p"+i+"_craisClass").value=="CLASS-B"){
							theClass += " craisYellow";
							document.getElementById("p"+i+"_tab").className += " craisYellow";
						}
					}
				}
				counter += 1;
				HTML += "<tr class='"+theClass+"'>";
				if(showCraisText){
					theText = document.getElementById("p"+i+"_craisText").value.replace(/\'/g,"\'").replace(/<br\/>/g,"\n");
					HTML += "<td valign='top'>";
					if(theText!=""){
						HTML += "<a href='javascript:void(0);return false;' title='"+theText+"'><img border='0' src='images/qmark.png'></a>";
					}
					HTML += "</td>";
				}
				if (document.getElementById("p"+i+"_trivialName").value != "")
				{
					if(!fullChemicalName)
					{
						HTML += "<td class='caseInnerData' valign='top' data-source-field='p"+i+"_trivialName'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+ escapeHtml($("#p"+i+"_trivialName").val())+"' /></td>";
					}
					else
					{
						HTML += "<td class='caseInnerData' valign='top' data-source-field='p"+i+"_name'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+ escapeHtml($("#p"+i+"_name").val())+"' /></td>";
					}
				}
				else
				{
					HTML += "<td class='caseInnerData' valign='top' data-source-field='p"+i+"_trivialName'><input " + (readOnly ? "disabled" : "") + " type='text' value='Product "+i+"' /></td>";
				}
				HTML += quickViewFieldWithDropdown(i, "p", "molecularWeight");
				HTML += "<td class='caseInnerData' valign='top'></td>";
				HTML += quickViewFieldWithDropdown(i, "p", "actualMoles");
				HTML += quickViewFieldWithDropdown(i, "p", "measuredMass");
				HTML += "<td class='caseInnerData' valign='top' data-source-field='p"+i+"_equivalents'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#p"+i+"_equivalents").val())+"' /></td>";
				HTML += "<td class='caseInnerData' valign='top'><input disabled type='text' value='' /></td>"; // Empty cell for product W/W
				HTML += "<td class='caseInnerData' valign='top'></td>";
				HTML += "</tr>";
			}
		}

		if(document.getElementById("craisStatus") && counter !=0){
			if(counter % 2 == 0){
				theClass = "stochEven";
			}else{
				theClass = "stochOdd";
			}
			HTML += "<tr class="+theClass+">";
			cols = 7;
			if(showCraisText){
				HTML += "<td></td>";
			}
			HTML += "<td valign='top' colspan='"+cols+"'><strong> Regulatory Check Status:</strong> "+document.getElementById("craisStatus").value+"</td>";
			HTML += "</tr>";
		}
		if (counter == 0)
		{
			HTML += "<tr><td class='caseInnerData' colspan='7'>No Tabs Added</td></tr>";
		}
		document.getElementById("qv_body_container").innerHTML = HTML;

	//Setup events
		// for all the quickview inputs, trigger the events of their datasource
		var populateTimeout;
		$("#qv_body_container input").on("focus", function(inputEvent){
			sourceField = $(inputEvent.target).parent().data("source-field");
			$('#'+sourceField).trigger("focus");
		});
		$("#qv_body_container input").on("blur", function(inputEvent){
			sourceField = $(inputEvent.target).parent().data("source-field");
			$('#'+sourceField).val($(inputEvent.target).val());
			$('#'+sourceField).trigger("blur");
			//populateQuickView();
		});
		$("#qv_body_container input").on("change", function(inputEvent){
			sourceField = $(inputEvent.target).parent().data("source-field");
			$('#'+sourceField).val($(inputEvent.target).val());
			if ($(inputEvent.target).is(':checked')) {
				$('#'+sourceField).prop('checked', true);
			}
			$('#'+sourceField).trigger("change");
			populateTimeout = setTimeout(populateQuickView,100);
		});
		$("[id$=_qv_down_image]").on("click", function(inputEvent){
			clearTimeout(populateTimeout);
			units(inputEvent.currentTarget);
		});


		//This grabs all the unit dropdown arrows
		$("[id$=qv_units]").each(function(key, theInput){
			$(theInput).find("a").on("click", function(inputEvent){
				sourceField = $(inputEvent.target).parent().parent().parent().parent().data("source-field");
				$('#'+sourceField).val($('#' + sourceField + '_qv').val());
				$('#'+sourceField).trigger("change");
				populateQuickView();
			});
		});

	//Color code based on user edited
		$("#qv_body_container input").each(function(key, theInput){
			sourceField = $(theInput).parent().data("source-field");
			$(theInput).css('color', $('#'+sourceField).css('color'));
			$(theInput).css('font-weight', $('#'+sourceField).css('font-weight'));
		});
	}

	/// function to build the quick view TDs that have dropdowns
	///  example call: quickViewFieldWithDropdown(i, "r", "sampleMass");
	function quickViewFieldWithDropdown(i, fieldType, fieldName){
		try{
			outputHTML = "<td class='caseInnerData' valign='top' data-source-field='" + fieldType + i +"_" + fieldName + "'><div style='position:relative' data-source-field='" + fieldType + i +"_" + fieldName + "'>";
			outputHTML += "<div class='unitsDiv' id='" + fieldType + i +"_" + fieldName + "_qv_units' style='display:none;z-index:10000!important;'>";
			outputHTML += $("#" + fieldType + i + "_" + fieldName + "_units").html().replace(new RegExp("("+ fieldType + i +"_" + fieldName + ")(_units)","g"),"$1_qv$2");
			outputHTML += "</div>";
			outputHTML += "<a href='javascript:void(0)' id='" + fieldType + i +"_" + fieldName + "_qv_down_image' style='position:absolute;top:5px;left:-4000px;z-index:10;'><img src='images/down.gif' border='0'></a>";
			outputHTML += "<input id='" + fieldType + i +"_" + fieldName + "_qv' type='text' onkeyup='units(this)' onfocus='units(this)' value='"+escapeHtml($("#" + fieldType + i + "_" + fieldName).val())+"' />";
			outputHTML += "<span id='" + fieldType + i +"_" + fieldName + "_qv_dummy_width' style='position:absolute;left:-4000px;'/>";
			outputHTML += "</div></td>";
		}catch(e){
			outputHTML = "<td class='caseInnerData' valign='top' data-source-field='" + fieldType + i + "_" + fieldName + "'><input " + (readOnly ? "disabled" : "") + " type='text' value='"+escapeHtml($("#" + fieldType + i + "_" + fieldName).val())+"' /></td>";
		}
		return outputHTML;
	}

	function displayTab(tabName)
	{/*new*/
		if (tabName == 'qv')
		{
			document.getElementById("qv_body_container").style.display = 'block'
			populateQuickView();
		}
		else
		{
			document.getElementById("qv_body_container").style.display = 'none'
		}
		if (currentTab != "")
		{
			// If the current tab doesn't exist anymore, just show the quick view
			if(!document.getElementById(currentTab+"_body")){
				currentTab = '';
				displayTab('qv');
				return;
			}
			try{
			document.getElementById(currentTab+"_body").style.display = "none";
			document.getElementById(currentTab+"_tab").className = "gridTabDiv";
			if(document.getElementById(currentTab+"_craisClass").value=="CLASS-A"){
				document.getElementById(currentTab+"_tab").className += " craisRed"
			}
			if(document.getElementById(currentTab+"_craisClass").value=="CLASS-B"){
				document.getElementById(currentTab+"_tab").className += " craisYellow"
			}
			}catch(err){}
		}
		try{
			// The conditions tab ("rc") is a table. set display = table so we don't get a large blue box where it doesn't cover the background
			if (tabName == "rc"){
				document.getElementById(tabName+"_body").style.display = "table";
			}else{
				document.getElementById(tabName+"_body").style.display = "block";
			}
		
		currentTab = tabName;
		document.getElementById(currentTab+"_tab").className = "tabSelected gridTabDiv selectedTab"
		}catch(err){
			if(document.getElementById(tabName+"_craisClass").value=="CLASS-A"){
				document.getElementById(tabName+"_tab").className += " craisRed"
			}
			if(document.getElementById(tabName+"_craisClass").value=="CLASS-B"){
				document.getElementById(tabName+"_tab").className += " craisYellow"
			}
		}
		positionButtons()
	}

	/*new*/
	function deleteTab(tabName,override)
	{
		if(!override){
			go = confirm("Are you sure you wish to delete this tab?");
		}else{
			go = true;
		}
		if (go){
			if(deleteTabFromCdx){
				changed = false;
				fragmentId = document.getElementById(tabName+"_fragmentId").value;
				mainXML = cd_getData("mycdx","text/xml");
				mainXML = loadXML(mainXML);
				fragment = mainXML.getElementById(fragmentId);
				if(fragment){
					fragment.parentNode.removeChild(fragment);
					changed = true;
				}
				if(changed){
					cd_putData("mycdx","text/xml",xmlToString(mainXML));
					sendAutoSave("cdxml",cd_getData("mycdx","text/xml"));
					if (!(experimentId === parseInt(experimentId))){
						experimentId = experimentId.value;experimentType = experimentType.value;
					}
				}
			}
			justLetter = tabName.replace(/\d/g,"")
			$.post( "/arxlab/experiments/ajax/do/deleteDraftMol.asp", {"type":justLetter,"experimentId":experimentId,"fragmentId":document.getElementById(tabName+"_fragmentId").value,"prefix":tabName} );
			document.getElementById(tabName+"_tab").parentNode.parentNode.removeChild(document.getElementById(tabName+"_tab").parentNode)
			document.getElementById(tabName+"_body").parentNode.removeChild(document.getElementById(tabName+"_body"))
			setTimeout("displayTab('qv')",200)
			unsavedChanges = true;
			showOverMessage("unsavedChanges", "page");
		}
		return false;
	}
	/*/new*/

function htmlDecode(s) {
	s = s.replace(/&apos;/ig,"'");
	return s;
}

function escapeHtml(unsafe) {
	if(unsafe){
		return unsafe
		.replace(/&/g, "&amp;")
		.replace(/</g, "&lt;")
		.replace(/>/g, "&gt;")
		.replace(/"/g, "&quot;")
		.replace(/'/g, "&#039;");
	}else{
		return ""
	}
 }