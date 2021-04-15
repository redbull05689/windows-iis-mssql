String.prototype.endsWith = function(suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

if (!Array.prototype.indexOf)
{
  Array.prototype.indexOf = function(elt /*, from*/)
  {
    var len = this.length >>> 0;

    var from = Number(arguments[1]) || 0;
    from = (from < 0)
         ? Math.ceil(from)
         : Math.floor(from);
    if (from < 0)
      from += len;

    for (; from < len; from++)
    {
      if (from in this &&
          this[from] === elt)
        return from;
    }
    return -1;
  };
}

	Number.prototype.toFixed = function(precision) {
        var power = Math.pow(10, precision || 0);
        return String(Math.round(this * power)/power);
    }
	if ( !Array.prototype.forEach ) {
	  Array.prototype.forEach = function(fn, scope) {
		for(var i = 0, len = this.length; i < len; ++i) {
		  fn.call(scope, this[i], i, this);
		}
	  }
	}

	Array.prototype.max = function() {
	return Math.max.apply(null, this);
	};

	Array.prototype.min = function() {
	return Math.min.apply(null, this);
	};

	Number.prototype.autoRound = function(units,sigdigs,fixedUnit){
		theNumber = this;
		if (isNaN(theNumber)){
			return "";
		}

		if(fixedUnit==undefined){
			fixedUnit = "";
		}
		sigdigs = parseInt(sigdigs);
		if(sigdigs<3){
			sigdigs = 3;
		}
		//sigdigs += 1;
		var unitNames = units.unitNames;
		var unitNamesLowerCase = [];
		for (var i=0;i<unitNames.length;i++){
			unitNamesLowerCase.push(unitNames[i].toLowerCase())
		}
		var unitMultipliers = units.unitMultipliers;
		var defaultIndex = units.defaultIndex;
		newIndex = false;
		for (var i=0;i<unitMultipliers.length;i++){
			intLen = parseInt((theNumber/unitMultipliers[i]).toFixed()).toString().length;
			theInt = parseInt((theNumber/unitMultipliers[i]).toFixed());
			if(intLen>0 && intLen<=3 && theInt!=0){
				newIndex = i;
				break; 
			}
		}
		if(newIndex === false){
			if(theNumber<unitMultipliers.min()){
				newIndex = unitMultipliers.indexOf(unitMultipliers.min());
			}
			if(theNumber>unitMultipliers.max()){
				newIndex = unitMultipliers.indexOf(unitMultipliers.max());
			}
		}
		if(fixedUnit!=""){
			newIndex = unitNames.indexOf(fixedUnit);
			if(newIndex==-1){
				newIndex = unitNamesLowerCase.indexOf(fixedUnit);
			}
		}
		numPart = Big(theNumber/unitMultipliers[newIndex]).toFixed(20);
		sigdigs = parseInt(sigdigs)
		if(/\./.test(numPart.toString())){
			sigdigs = parseInt(sigdigs) + 1;
		}
		if(numPart.toString().substr(0,1)=="0"){
			sigdigs = parseInt(sigdigs) + 1;
		}
		if(fixedUnit=="" || (numPart<(Math.pow(10,sigdigs)) && numPart>1/(Math.pow(10,sigdigs)))){
			if(numPart>1){
				rStr = numPart.toString().substr(0,sigdigs);
			}else{
				firstDigit = 0;
				ns = (theNumber/unitMultipliers[newIndex]).toFixed(20);
				for(var i=0;i<ns.length;i++){
					if(ns.substr(i,1)!="0" && ns.substr(i,1)!="."){
						firstDigit = i;
						break;
					}
				}
				rStr = ns.substr(0,firstDigit+sigdigs-1);
			}

		}else{
			if(numPart>1){
				rStr = parseFloat(numPart).toFixed(0);
			}else{
				firstDigit = 0;
				ns = (theNumber/unitMultipliers[newIndex]).toFixed(20);
				for(var i=0;i<ns.length;i++){
					if(ns.substr(i,1)!="0" && ns.substr(i,1)!="."){
						firstDigit = i;
						break;
					}
				}
				rStr = ns.substr(0,firstDigit+sigdigs-1);
			}
		}
		//if(rStr.indexOf(".")!=-1){
		//	numDecimals = rStr.substr(rStr.indexOf(".")+1,rStr.length).length-1;
		//	if(numDecimals+1>=sigdigs){
		//		rStr = roundAndFix(rStr,numDecimals).toString()
		//	}
		//}
		if(rStr.endsWith(".")){
			rStr = rStr.replace(".","");
		}
		rStr += ' '+unitNames[newIndex];
		return rStr 
	}

	function roundAndFix (n, d) {
		var m = Math.pow (10, d);
		return Math.round (n * m) / m;
	}

	function getAmountFromEquivalentsAndMolecularWeight(equivalents,molWeight,purity,units){
		var firstCalcRow = findMolesCalcRow();
		var purityBase = getBaseNumber(purity);
		var rowMoles = $$$(firstCalcRow+"_moles");
		var rowEquivalents = $$$(firstCalcRow+"_equivalents");
		
		var rawAmount = (rowMoles * equivalents / rowEquivalents * molWeight) / purityBase;
		var cleanAmount = rawAmount.autoRound(unitD.mass,sigdigs,units);
		
		return cleanAmount; 
	}

	function getAmountFromEquivalentsAndMolecularWeightVolume(equivalents,molWeight,density,units){
		console.log("equivalents: ", equivalents, " molWeight: ", molWeight, " density: ", density, " units: ", units);
		var firstCalcRow = findMolesCalcRow();
		var densityBase = getBaseNumber(density);
		var rowMoles = $$$(firstCalcRow+"_moles");
		var rowEquivalents = $$$(firstCalcRow+"_equivalents");
		console.log("densityBase: ", densityBase, " rowMoles: ", rowMoles, " rowEquivalents: ", rowEquivalents);
		
		var rawAmount = (rowMoles * equivalents / rowEquivalents * molWeight) / densityBase;
		var cleanAmount = rawAmount.autoRound(unitD.volume,sigdigs,units);
		
		return cleanAmount; 
	}

	function hasLimittingMoles(){
		if(findMolesCalcRow()){
			return true;
		}else{
			return false;
		}
	}

	var prefixes = [];
	var UAStates = {};
	var imps = [
		"reactantMass",
		"sampleMass",
		"volume",
		"moles",
		"theoreticalMass",
		"theoreticalMoles"
	];
	var prodImps = [
		"actualMass",
		"actualMoles",
		"yield",
		"measuredMass"
	];
	var calcFields = [
		"equivalents",
		"weightRatio",
		"sampleMass",
		"volume",
		"moles",
		"percentWT",
		"molarity",
		"density",
		"reactantMass",
		"theoreticalMass",
		"theoreticalMoles",
		"purity",
		"actualMass",
		"actualMoles",
		"yield",
		"limit",
		"reactionMolarity",
		"measuredMass",
		"volumes"
	];
	var clearFields = [
		"sampleMass",
		"weightRatio",
		"volume",
		"moles",
		"percentWT",
		"molarity",
		"density",
		"reactantMass",
		"theoreticalMass",
		"theoreticalMoles",
		"purity",
		"actualMass",
		"actualMoles",
		"yield",
		"reactionMolarity",
		"volumes"
	];
	var limittingMoles = "";
	var limittingEquivalents = "1.0";
	var unitD = {
					moles: {
						unitNames:['µmol','mmol','mol'],
						unitMultipliers:[.000001,.001,1],
						defaultIndex:1
					},
					mass: {
						unitNames:['µg','mg','g','kg'],
						unitMultipliers:[.000001,.001,1,1000],
						defaultIndex:2
					},
					volume: {
						unitNames:['µL','mL','L'],
						unitMultipliers:[.000001,.001,1],
						defaultIndex:1
					},
					molarity: {
						unitNames:['µM','mM','M','molar'],
						unitMultipliers:[.000001,.001,1,1],
						defaultIndex:2
					},
					percent: {
						unitNames:['%'],
						unitMultipliers:[.01],
						defaultIndex:0
					},
					volumes: {
						unitNames:['µL/g', 'mL/g', 'L/g'],
						unitMultipliers:[.000001,.001,1],
						defaultIndex:1
					},
				};

	function setRowColors(prefix){
		for(textboxId in UAStates[prefix]){
			try{
				if(UAStates[prefix][textboxId]){
					document.getElementById(prefix+"_"+textboxId).style.color = "green";
					document.getElementById(prefix+"_"+textboxId).style.fontWeight = "bold";
				}else{
					document.getElementById(prefix+"_"+textboxId).style.color = "black";
					document.getElementById(prefix+"_"+textboxId).style.fontWeight = "normal";
				}
			} catch(err){
				console.log("Failed to update grid color");
			}

		}
		document.getElementById(prefix+"_UAStates").value = JSON.stringify(UAStates[prefix]);
	}

	function clearImpsExcept(prefix,except){
		imps.forEach(function(imp){
			if(document.getElementById(prefix+"_"+imp)){
				// 7636 - Make sure solvent volume isn't cleared when moles are being updated.
				if(UAStates[prefix][imp] && imp != except && !(except == "moles" && prefix.substr(0,1) == "s" && imp == "volume")){
					UAStates[prefix][imp] = false;
					document.getElementById(prefix+"_"+imp).value = '';
				}
			}
		});
		setRowColors(prefix);
	}

	function clearProdImpsExcept(prefix,except){
		prodImps.forEach(function(imp){
			if(document.getElementById(prefix+"_"+imp)){
				if(UAStates[prefix][imp] && imp != except){
					UAStates[prefix][imp] = false;
					document.getElementById(prefix+"_"+imp).value = '';
				}
			}
		});
		setRowColors(prefix);
	}

	function putLimittingFirst(){
		for(i=0;i<prefixes.length;i++){
			if(document.getElementById(prefixes[i]+"_limit")){
				if(document.getElementById(prefixes[i]+"_limit").checked){
					limittingEquivalents = document.getElementById(prefixes[i]+"_equivalents").value;
					prefixes.unshift(prefixes.splice(i,1)[0]);
				}
			}
		}
	}

	function loadUAStates(prefix){
		stateString = document.getElementById(prefix+"_UAStates").value;
		if (!stateString || stateString == '{}'){
			UAStates[prefix] = {};
		}else{
			UAStates[prefix] = eval('('+stateString+')');
		}
		prefixes.push(prefix);
		setRowColors(prefix);
	}

	function rowsExcept(prefix){
		otherRows = [];
		prefixes.forEach(function(loopPrefix){
			if(loopPrefix != prefix){
				otherRows.push(loopPrefix);
			}
		});
		return otherRows;
	}

	function getPrefixes(){
		prefixes = []
		prefixes2 = ['r','rg','s','p'];

		for(var k=0;k<prefixes2.length;k++){
			for (var i=0;i<30 ;i++ ){
				var prefix = prefixes2[k]+i;
				if (document.getElementById(prefix+"_tab")){
					prefixes.push(prefix)
				}
			}	
		}
	}

    /**
     * Gets any UAStates of the previous limiting reagent and swaps them with the new current limiting reagent
     * @param {string} currentPrefix The prefix of the current limiting reagent.
     */	
	function swapPreviousLimitReagentUAStates(currentPrefix) {
		
		// first we need to find the previous reagent input
		els = document.getElementsByTagName("input")
		var previousLimitReagent;
		for(i=0;i<els.length;i++)
		{
			var type = els[i].getAttribute("type");
			if (type && type.toLowerCase() == "checkbox")
			{
				if (els[i].className == "limit" && els[i].id != currentPrefix + "_limit" && els[i].checked == true)
				{
					previousLimitReagent = els[i];
					break;
				}
			}
		}

		// if found, swap the UA States of Limit Reagent's non-limit items
		if (previousLimitReagent) {
			previousPrefix = previousLimitReagent.id.split("_")[0];

			if (UAStates[previousPrefix] && UAStates[currentPrefix]) {

				for(textboxId in UAStates[previousPrefix]){
					if (textboxId != "limit" && UAStates[previousPrefix][textboxId]) {
						
						UAStates[currentPrefix][textboxId] = true;
						UAStates[previousPrefix][textboxId] = false;
						
						// we have to update the experimentJSON as well...
						if (experimentJSON[previousPrefix + "_UAStates"] && experimentJSON[currentPrefix + "_UAStates"]) {

							experimentJSON[previousPrefix + "_UAStates"] = JSON.stringify(UAStates[previousPrefix]);
							experimentJSON[currentPrefix + "_UAStates"] = JSON.stringify(UAStates[currentPrefix]);
						}
						
						// ...and the hidden inputs on the form that get used later on in saving...
						hiddenFormPreviousUAStates = document.getElementById(previousPrefix + "_UAStates")
						hiddenFormCurrentUAStates = document.getElementById(currentPrefix + "_UAStates")

						if (hiddenFormPreviousUAStates) {
							hiddenFormPreviousUAStates.value = JSON.stringify(UAStates[previousPrefix]);
						}

						if (hiddenFormCurrentUAStates) {
							hiddenFormCurrentUAStates.value = JSON.stringify(UAStates[currentPrefix]);
						}
						
					}
				}
			}
		}
	}

	function gridFieldChanged(that){
		getPrefixes()
		var id = "";
		var prefix = that.id.split("_")[0];
		id = that.id.split("_")[1];
		if (UAStates[prefix] == null){
			UAStates[prefix] = {};
		}
		if(document.getElementById(prefix+"_"+id).value != ''){
			UAStates[prefix][id] = true;
		}else{
			UAStates[prefix][id] = false;
		}
		if  (id=='sampleMass' || id=='reactantMass' || id=='volume' || id=='moles'){
			if(prefix.substring(0,1) != 's'){
				//If the user changes non limiting reagents sampleMass let the system calculate the equivalent even though its user entered value
				if(!document.getElementById(prefix+"_limit").checked && document.getElementById(prefix+"_"+id).value != ''){
					UAStates[prefix]["equivalents"] = false;
					UAStates[prefix]["weightRatio"] = false;
				}
			}
		}

		if (id=='equivalents'){
			//If the user changes non limiting reagents equivalent let the system calculate the mass even though its user entered value

			if(prefix.substring(0,1) == 'p'){
				if(document.getElementById(prefix+"_"+id).value != ''){
					UAStates[prefix]["theoreticalMass"] = false;
				}
			}else{
				if(document.getElementById(prefix+"_"+id).value != ''){
					// If the user sets the equivalents, we can overwrite their weightRatio
					UAStates[prefix]["weightRatio"] = false;

					if(!document.getElementById(prefix+"_limit").checked){
						UAStates[prefix]["sampleMass"] = false;
						UAStates[prefix]["reactantMass"] = false;
						UAStates[prefix]["volume"] = false;
						UAStates[prefix]["moles"] = false;
					}
				}
			}

			if(document.getElementById(prefix+"_"+id).value == ''){
				UAStates[prefix]["equivalents"] = false;
				if(!canCalcMoles(prefix)){
					document.getElementById(prefix+"_equivalents").value = "1.0";
				}else{
					document.getElementById(prefix+"_equivalents").value = "";
				}
			}


		}
		if (id=='weightRatio'){
			//If the user changes non limiting reagents weightRatio let the system calculate the mass and equivalents even though its user entered value
			if (prefix.substring(0,1)=='r'){
				if(document.getElementById(prefix+"_"+id).value != ''){
					if(!document.getElementById(prefix + "_limit").checked){
						UAStates[prefix]["reactantMass"] = false;
						UAStates[prefix]["sampleMass"] = false;
						UAStates[prefix]["moles"] = false;
						UAStates[prefix]["volume"] = false;
					}
				}
			}
			//If the user sets the weightRatio, we can overwrite their equivalents
			if(document.getElementById(prefix+"_"+id).value != ''){
				UAStates[prefix]["equivalents"] = false;
				document.getElementById(prefix+"_equivalents").value = "";
			}
		}
		if (id=='molarity'){
			UAStates[prefix]["percentWT"] = false;
			document.getElementById(prefix+"_percentWT").value = "";
		}
		if (id=='percentWT'){
			UAStates[prefix]["molarity"] = false;
			document.getElementById(prefix+"_molarity").value = "";
		}
		if (id=='limit'){
			
			// we need to check the previous limiting agent for any user entered values
			// and flag the corresponding values in the new limiting agent to true
			swapPreviousLimitReagentUAStates(prefix);

			uncheckClass('limit');
			document.getElementById(prefix+"_limit").checked=true;
			unsavedChanges = true;
			els = document.getElementsByTagName("span");
			for(var i=0;i<els.length;i++){
				if(els[i].className=="gridTabLimitSpan"){
					els[i].style.display = "none";
				}
			}

			// 6285 - Suppressing a race condition where the grid could be reloading when this block of code is hit,
			// from the barcode chooser and thus is unable to operate on the prefix+"_tabLimit" element.
			try {
				document.getElementById(prefix+"_tabLimit").style.display = "block";
			} catch(err) {
				console.log("Failed to display the (L).");
			}
		}
		if (prefix.substring(0,1)=='s'){
			if (id=='volume'){
				UAStates[prefix]["reactionMolarity"] = false;
				UAStates[prefix]["moles"] = false;
				UAStates[prefix]["volumes"] = false;
			}
			if (id=='reactionMolarity'){
				UAStates[prefix]["volume"] = false;
				UAStates[prefix]["volumes"] = false;
			}
			if (id=='moles'){
				UAStates[prefix]["volume"] = false;
			}
			if (id == "volumes") {
				UAStates[prefix]["volume"] = false;
			}
		}
		setRowColors(prefix);
		if(imps.indexOf(id) != -1){
			clearImpsExcept(prefix,id);
		}
		if(prodImps.indexOf(id) != -1){
			clearProdImpsExcept(prefix,id);
		}
		if(calcFields.indexOf(id) != -1){
			if(UAStates[prefix]["equivalents"]&& canCalcMoles(prefix)){
				otherRows = rowsExcept(prefix);
				otherRows.forEach(function(loopPrefix){
					if(UAStates[loopPrefix]["equivalents"]){
						clearImpsExcept(loopPrefix);
					}
				});
			}else if(UAStates[prefix]["weightRatio"]&& canCalcMass(prefix)){
				otherRows = rowsExcept(prefix);
				otherRows.forEach(function(loopPrefix){
					if(UAStates[loopPrefix]["weightRatio"]){
						clearImpsExcept(loopPrefix);
					}
				});
			}
			clearNonUAData();
			putLimittingFirst();
			if(canCalcMoles(prefix)){
				//tabs other than limiting reagent
				if(prefix != prefixes[0]){
					otherCanCalc = false;
					otherRows = rowsExcept(prefix);
					otherRows.forEach(function(loopPrefix){
						//if(!UAStates[loopPrefix]["equivalents"] && canCalcMoles(loopPrefix)){
						//Change the non limiting reagents equvalent value even though its manually entered by the user
						if(canCalcMoles(loopPrefix)){
							otherCanCalc = true;
							if(UAStates[prefix]["equivalents"]){
								if(document.getElementById(loopPrefix+"_equivalents")){
									//Don't change the limiting reagents equivalent value
									if(!document.getElementById(loopPrefix+"_limit").checked){
										document.getElementById(loopPrefix+"_equivalents").value = '';
									}
								}
							}
						}
					});
					if(otherCanCalc && !UAStates[prefix]["equivalents"]){
						if(document.getElementById(prefix+"_equivalents")){
							document.getElementById(prefix+"_equivalents").value = '';
						}
					}
				}else{
					otherRows = rowsExcept(prefix);
					otherRows.forEach(function(loopPrefix){
						//if(!UAStates[loopPrefix]["equivalents"] && canCalcMoles(loopPrefix)){
						//Change the non limiting reagents equvalent value even though its manually entered by the user
						if(canCalcMoles(loopPrefix)){
							if(document.getElementById(loopPrefix+"_limit")){
								if(document.getElementById(loopPrefix+"_equivalents")){
									document.getElementById(loopPrefix+"_equivalents").value = '';
								}
							}
						}
					});
					if(findMolesCalcRow2()!=prefix){
						//Don't change the limiting reagents equivalent value
						if(!document.getElementById(prefix+"_limit").checked){
							document.getElementById(prefix+"_equivalents").value = '';
						}
					}
				}
			}
			//Same as above, expect for weightRatio this time
			if(canCalcMass(prefix)){
				//tabs other than limiting reagent
				if(prefix != prefixes[0]){
					otherCanCalc = false;
					otherRows = rowsExcept(prefix);
					otherRows.forEach(function(loopPrefix){
						//Change the non limiting reagents Weight Ratio value even though its manually entered by the user
						if(canCalcMass(loopPrefix)){
							otherCanCalc = true;
							if(UAStates[prefix]["weightRatio"]){
								if(document.getElementById(loopPrefix+"_weightRatio")){
									//Don't change the limiting reagents equivalent value
									if(!document.getElementById(loopPrefix+"_limit").checked){
										document.getElementById(loopPrefix+"_weightRatio").value = '';
									}
								}
							}
						}
					});
					if(otherCanCalc && !UAStates[prefix]["weightRatio"]){
						if(document.getElementById(prefix+"_weightRatio")){
							document.getElementById(prefix+"_weightRatio").value = '';
						}
					}
				}else{
					otherRows = rowsExcept(prefix);
					otherRows.forEach(function(loopPrefix){
						//Change the non limiting reagents weight Ratio value even though its manually entered by the user
						if(canCalcMass(loopPrefix)){
							if(document.getElementById(loopPrefix+"_limit")){
								if(document.getElementById(loopPrefix+"_weightRatio")){
									document.getElementById(loopPrefix+"_weightRatio").value = '';
								}
							}
						}
					});
					if(findMolesCalcRow2()!=prefix){
						//Don't change the limiting reagents equivalent value
						if(!document.getElementById(prefix+"_limit").checked){
							document.getElementById(prefix+"_weightRatio").value = '';
						}
					}
				}
			}
			firstCalcRow = findMolesCalcRow();
			if(firstCalcRow){
				calcRow(firstCalcRow);
				if(!canCalcMoles(prefixes[0])){
					if(firstCalcRow.substring(0,1) == 'p'){
						document.getElementById(prefixes[0]+"_moles").value = ($$$(firstCalcRow+"_theoreticalMoles")*$$$(prefix+"_equivalents")/$$$(firstCalcRow+"_equivalents")).autoRound(unitD.moles,sigdigs,defaultMolUnits);
					}else{
						document.getElementById(prefixes[0]+"_moles").value = ($$$(firstCalcRow+"_moles")*$$$(prefix+"_equivalents")/$$$(firstCalcRow+"_equivalents")).autoRound(unitD.moles,sigdigs,defaultMolUnits);
					}
					doCkAutoFill(document.getElementById(prefixes[0]+"_moles"));
				}
				if(!canCalcMass(prefixes[0])){
					if(firstCalcRow.substring(0,1) == 'p'){
						document.getElementById(prefixes[0]+"_reactantMass").value = ($$$(firstCalcRow+"_theoreticalMass")*$$$(prefix+"_weightRatio")/$$$(firstCalcRow+"_weightRatio")).autoRound(unitD.mass,sigdigs);
					}else{
						document.getElementById(prefixes[0]+"_reactantMass").value = ($$$(firstCalcRow+"_sampleMass")*$$$(prefix+"_weightRatio")/$$$(firstCalcRow+"_weightRatio")).autoRound(unitD.mass,sigdigs);
					}
					doCkAutoFill(document.getElementById(prefixes[0]+"_reactantMass"));
				}
				otherRows = rowsExcept(firstCalcRow);
				calcMolesAndMass(firstCalcRow);	
			}
		}
		try{window.clearTimeout(gridSaveTimeout)}catch(err){}
		gridSaveTimeout = setTimeout(sendGridAutoSave,1000);
		doCkAutoFill(that);
	}

	/**
	 * Does the math for mass and moles
	 * @param {string} firstCalcRow - The name id (ex: "r1") of the limiting reagent
	 */
	function calcMolesAndMass(firstCalcRow){
		otherRows.forEach(function(prefix){
			if(!canCalcMoles(prefix)){
				if(firstCalcRow.substring(0,1) == 'p'){
					sourceName = "theoreticalMoles";
				}else{
					sourceName = "moles";
				}
				if(prefix.substring(0,1) == 'p'){
					destName = "theoreticalMoles";
				}else{
					destName = "moles";
				}
				if(prefix.substring(0,1) != 's'){
					document.getElementById(prefix+"_"+destName).value = ($$$(firstCalcRow+"_"+sourceName)*$$$(prefix+"_equivalents")/$$$(firstCalcRow+"_equivalents")).autoRound(unitD.moles,sigdigs);
				}
				doCkAutoFill(document.getElementById(prefix+"_"+destName));
			}
			calcRow(prefix);
		});	

	 }


	function doCkAutoFill(that){
		try{
			CKEDITOR.instances['e_preparation'].removeListener('change',ckChange);
			var prefix = that.id.split("_")[0];
			editor = CKEDITOR.instances['e_preparation'];
			arr = editor.document.getBody().getElementsByTag('a');
			for (var i = 0; i < arr.count(); i++) {
				var element = arr.getItem(i);
				if (element.hasClass("autoFill")||element.getAttribute("id").indexOf("autofill_link")>=0||element.getAttribute("id").indexOf("autoFill_link")>=0){
					if (element.getAttribute("selectedmol")+"_"+element.getAttribute("formname") == that.id){
						editor.execCommand(prefix+"_"+element.getId().replace("autoFill_link_","")+"_command")
					}
				}
			}
		}catch(err){}
		finally {
			CKEDITOR.instances['e_preparation'].on('change',ckChange);
		}
	}

	function findMolesCalcRow(){
		theRow = false
		for(i=0;i<prefixes.length;i++){
			if(canCalcMoles(prefixes[i]) || canCalcMass(prefixes[i]) || canCalcVolumes(prefixes[i])){
				theRow = prefixes[i];
				break;
			}
		}
		if(!theRow){
			for(i=0;i<prefixes.length;i++){
				if((canCalcMoles(prefixes[i]) && UAStates[prefixes[i]]["equivalents"]) ||
					(canCalcMass(prefixes[i]) && UAStates[prefixes[i]]["weightRatio"]) ||
					(canCalcMoles(prefixes[i]) && UAStates[prefixes[i]]["weightRatio"])){
					theRow = prefixes[i];
					break;
				}
			}
		}
		return theRow;
	}

	function findMolesCalcRow2(){
		//this is the original version of the function.  It is important for when equivalents are blanked because more than one row can calculate moles
		theRow = false
		for(i=0;i<prefixes.length;i++){
			if(canCalcMoles(prefixes[i])){
				theRow = prefixes[i];
				break;
			}
		}
		for(i=0;i<prefixes.length;i++){
			if(canCalcMoles(prefixes[i]) && UAStates[prefixes[i]]["equivalents"]){
				theRow = prefixes[i];
				break;
			}
		}
		return theRow;
	}

	/**
	 * Looks at all the tabs and finds the first row that can have the mass calculated by weightRatio
	 */
	function findMassCalcRow(){
		theRow = false
		for(i=0;i<prefixes.length;i++){
			if(canCalcMass(prefixes[i])){
				theRow = prefixes[i];
				break;
			}
		}
		if(!theRow){
			for(i=0;i<prefixes.length;i++){
				if(canCalcMass(prefixes[i]) && UAStates[prefixes[i]]["weightRatio"]){
					theRow = prefixes[i];
					break;
				}
			}
		}
		return theRow;
	}
	/**
	 * checks if this tab has the correct data inorder to have the mass calculated by weightRatio
	 * @param {string} prefix - The prefix of the tab to check
	 */
	function canCalcMass(prefix){
		if(prefix.substring(0,1) == 'p'){
			if(UAStates.hasOwnProperty(prefix) && (UAStates[prefix].hasOwnProperty("theoreticalMass") && UAStates[prefix]["theoreticalMass"])){
				return true;
			}
		}
		
		if(prefix.substring(0,1) == 'r'){
			if(UAStates.hasOwnProperty(prefix) &&
				(
					(UAStates[prefix].hasOwnProperty("reactantMass") && UAStates[prefix]["reactantMass"])
					||
					(UAStates[prefix].hasOwnProperty("moles") && UAStates[prefix]["moles"])
					||
					(UAStates[prefix].hasOwnProperty("sampleMass") && UAStates[prefix]["sampleMass"])
				)){
				return true;
			}
		}
		return false;
	}


	/**
	 * checks if this tab has the correct data inorder to have the mols
	 * @param {string} prefix - The prefix of the tab to check
	 */
	function canCalcMoles(prefix){
		if(prefix.substring(0,1) == 'p'){
			if(UAStates.hasOwnProperty(prefix) &&
				(
					(UAStates[prefix].hasOwnProperty("theoreticalMoles") && UAStates[prefix]["theoreticalMoles"])
					||
					(UAStates[prefix].hasOwnProperty("theoreticalMass") && UAStates[prefix]["theoreticalMass"])
				)){
				return true;
			}
		}
		
		if(prefix.substring(0,1) == 'r'){
			if(UAStates.hasOwnProperty(prefix) &&
				(
					(UAStates[prefix].hasOwnProperty("reactantMass") && UAStates[prefix]["reactantMass"])
					||
					(UAStates[prefix].hasOwnProperty("moles") && UAStates[prefix]["moles"])
					||
					(UAStates[prefix].hasOwnProperty("sampleMass") && UAStates[prefix]["sampleMass"])
					||
					(
						(UAStates[prefix].hasOwnProperty("volume") && UAStates[prefix]["volume"])
						&&
						(UAStates[prefix].hasOwnProperty("density") && UAStates[prefix]["density"])
					)
					||
					(
						(UAStates[prefix].hasOwnProperty("volume") && UAStates[prefix]["volume"])
						&&
						(UAStates[prefix].hasOwnProperty("molarity") && UAStates[prefix]["molarity"])
					)
				)){
				return true;
			}
		}
		return false;
	}

	/**
	 * Can we calculate Volumes for the given prefix?
	 * @param {string} prefix The fragment prefix to check.
	 */
	function canCalcVolumes(prefix) {

		var canCalc = false;

		if (prefix in UAStates) {
			var prefixState = UAStates[prefix];
			var limitingPrefix = getLimitingReactant();
			
			if (limitingPrefix) {
				if (prefix.substring(0, 1) == "r" && limitingPrefix == prefix) {
					
					// If the thing changed is the limiting reactant sample mass, then we can calc solvent volumes.	
					canCalc = prefixState["sampleMass"];

				} else if (prefix.substring(0, 1) == "s") {
					
					// Otherwise if this is the solvent, if either volume or volumes were updated, we can do calculations
					// as long as there is a limiting mass.
					var limitingMassExists = document.getElementById(limitingPrefix + "_sampleMass").value != "";
					canCalc = (prefixState["volume"] && limitingMassExists) ||
								(prefixState["volumes"] && limitingMassExists);

				}
			}
		}

		return canCalc;
	}

	function clearNonUAData(){
		prefixes.forEach(function(prefix){
			clearFields.forEach(function(field){
				if(UAStates[prefix] != null){
					if(!UAStates[prefix][field]){
						// 7636 - solvent moles should /never/ be cleared by the system and subject to recalculation.
						// 7636 - EXCEPT if the limiting reactant moles have been updated.
						var limitingReactantPrefix = getLimitingReactant();
						var preserveSolventMoles = (prefix.substr(0,1) == "s" && field == "moles" && document.getElementById(prefix + "_moles").value == document.getElementById(limitingReactantPrefix + "_moles").value);

						if(document.getElementById(prefix+"_"+field) && !preserveSolventMoles){
							document.getElementById(prefix+"_"+field).value = "";
							document.getElementById(prefix+"_"+field).style.color = "black";
							document.getElementById(prefix+"_"+field).style.fontWeight = "normal";
						}
					}
				}
			});
		});
	}

	function calcRow(prefix){
		max = 6;
		count = 0;
		while(calcRowLoop(prefix) && count < max){
			count += 1;
		}
		calcRowLoopEquivalents(prefix);
	}

	function $$$(id){
		return getBaseNumber(document.getElementById(id).value);
	}

	function gridExists(id){
		return document.getElementById(id).value;
	}

	function calcRowLoop(prefix){
		didCalc = false;
		if(prefix.substring(0,1) == 'r'){
			if(document.getElementById(prefix+"_weightRatio").value=='' && gridExists(prefix+"_sampleMass")){

				theRow = prefixes[0] //use limiting reagents values to back calculate
				if(theRow.substring(0,1) == 'p'){
					sourceName = "theoreticalMass";
				}else{
					sourceName = "reactantMass";
				}
				if(!isNaN(($$$(theRow+"_weightRatio")*$$$(prefix+"_reactantMass")/$$$(theRow+"_"+sourceName)).toFixed(sigdigs))){
					//console.log("548:: "+ prefix +" Limitting checked :: "+document.getElementById(prefix+"_limit").checked + " :: equivalent value set to " + ($$$(theRow+"_equivalents")*$$$(prefix+"_moles")/$$$(theRow+"_"+sourceName)).toFixed(sigdigs));
					document.getElementById(prefix+"_weightRatio").value = ($$$(theRow+"_weightRatio")*$$$(prefix+"_reactantMass")/$$$(theRow+"_"+sourceName)).toFixed(sigdigs);
					didCalc = true;
					doCkAutoFill(document.getElementById(prefix+"_weightRatio"));
				} else if(document.getElementById(prefix+"_limit").checked){
					// Default the weightRatio to 1 if this is the limiting
					document.getElementById(prefix+"_weightRatio").value = 1
					didCalc = true;
					doCkAutoFill(document.getElementById(prefix+"_weightRatio"));
				}
				gridWWSaveTimeout = setTimeout(sendGridAutoSave,1000);

			}
			if(document.getElementById(prefix+"_sampleMass").value=='' && gridExists(prefix+"_volume") && gridExists(prefix+"_density")){
				document.getElementById(prefix+"_sampleMass").value = ($$$(prefix+"_volume")*$$$(prefix+"_density")).autoRound(unitD.mass,sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_sampleMass"));
			}
			if(document.getElementById(prefix+"_volume").value=='' && gridExists(prefix+"_sampleMass") && gridExists(prefix+"_density")){
				document.getElementById(prefix+"_volume").value = ($$$(prefix+"_sampleMass")/$$$(prefix+"_density")).autoRound(unitD.volume,sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_volume"));
			}
			if(document.getElementById(prefix+"_reactantMass").value=='' && gridExists(prefix+"_sampleMass")){
				if(gridExists(prefix+"_percentWT")){
					document.getElementById(prefix+"_reactantMass").value = ($$$(prefix+"_sampleMass")*$$$(prefix+"_percentWT")).autoRound(unitD.mass,sigdigs);
				}else{
					document.getElementById(prefix+"_reactantMass").value = ($$$(prefix+"_sampleMass")).autoRound(unitD.mass,sigdigs);
				}
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_reactantMass"));
			}
			if(document.getElementById(prefix+"_sampleMass").value=='' && gridExists(prefix+"_reactantMass")){
				if(gridExists(prefix+"_percentWT")){
					document.getElementById(prefix+"_sampleMass").value = ($$$(prefix+"_reactantMass")/$$$(prefix+"_percentWT")).autoRound(unitD.mass,sigdigs);
				}else{
					document.getElementById(prefix+"_sampleMass").value = ($$$(prefix+"_reactantMass")).autoRound(unitD.mass,sigdigs);
				}
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_sampleMass"));
			}
			if(document.getElementById(prefix+"_moles").value=='' && gridExists(prefix+"_reactantMass") && gridExists(prefix+"_molecularWeight")){
				var reactantMass = $$$(prefix+"_reactantMass");
				var molecularWeight = $$$(prefix+"_molecularWeight");
				var moles = unitD.moles;
				var sigDigs = sigdigs;
				var munits = defaultMolUnits;
				
				console.log("reactantMass: ", reactantMass, " molecularWeight: ", molecularWeight, " moles: ", moles, " sigDigs: ", sigDigs, " molUnits: ", munits);
				try {
					document.getElementById(prefix+"_moles").value = (reactantMass/molecularWeight).autoRound(unitD.moles,sigdigs,defaultMolUnits);
					didCalc = true;
					doCkAutoFill(document.getElementById(prefix+"_moles"));
				} catch(err) {
					console.log("calculation FAILED!")
				}
			}
			if(document.getElementById(prefix+"_reactantMass").value=='' && gridExists(prefix+"_moles") && gridExists(prefix+"_molecularWeight") && (!gridExists(prefix+"_weightRatio") || (document.getElementById(prefix+"_limit").checked))){  //dont calc reactantMass this way if weightRatio was user added, unless this is the limiting
				document.getElementById(prefix+"_reactantMass").value = ($$$(prefix+"_moles")*$$$(prefix+"_molecularWeight")).autoRound(unitD.mass,sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_reactantMass"));
			}
			if(document.getElementById(prefix+"_volume").value=='' && gridExists(prefix+"_moles") && gridExists(prefix+"_molarity")){
				document.getElementById(prefix+"_volume").value = ($$$(prefix+"_moles")/$$$(prefix+"_molarity")).autoRound(unitD.volume,sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_volume"));
			}
			if(document.getElementById(prefix+"_moles").value=='' && gridExists(prefix+"_volume") && gridExists(prefix+"_molarity")){
				document.getElementById(prefix+"_moles").value = ($$$(prefix+"_volume")*$$$(prefix+"_molarity")).autoRound(unitD.moles,sigdigs,defaultMolUnits);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_moles"));
			}
			if((document.getElementById(prefix+"_reactantMass").value=='') &&  gridExists(prefix+"_reactantMass") && gridExists(prefix+"_molecularWeight")){
				try {
					document.getElementById(prefix+"_moles").value = ($$$(prefix+"_reactantMass")/$$$(prefix+"_molecularWeight")).autoRound(unitD.moles,sigdigs,defaultMolUnits);
					didCalc = true;
					doCkAutoFill(document.getElementById(prefix+"_moles"));
				} catch(err) {
					console.log("calculation FAILED!")
				}
			}
			if(gridExists(prefix+"_weightRatio") && (document.getElementById(prefix+"_reactantMass").value=='')){
				try {
					theRow = prefixes[0] //use limiting reagents values to back calculate

					if(theRow.substring(0,1) == 'p'){
						document.getElementById(prefix+"_reactantMass").value = ($$$(theRow+"_theoreticalMass")*$$$(prefix+"_weightRatio")/$$$(theRow+"_weightRatio")).autoRound(unitD.mass,sigdigs);
					}else{
						document.getElementById(prefix+"_reactantMass").value = ($$$(theRow+"_reactantMass")*$$$(prefix+"_weightRatio")/$$$(theRow+"_weightRatio")).autoRound(unitD.mass,sigdigs);
					}

					didCalc = true;
					doCkAutoFill(document.getElementById(prefix+"_reactantMass"));
				} catch(err) {
					console.log("calculation FAILED!")
				}
			}

		}
		if(prefix.substring(0,1) == 'p'){
			if(document.getElementById(prefix+"_theoreticalMass").value=='' && gridExists(prefix+"_theoreticalMoles") && gridExists(prefix+"_molecularWeight")){
				document.getElementById(prefix+"_theoreticalMass").value = ($$$(prefix+"_theoreticalMoles")*$$$(prefix+"_molecularWeight")).autoRound(unitD.mass,sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_theoreticalMoles"));
			}
			if(document.getElementById(prefix+"_theoreticalMoles").value=='' && gridExists(prefix+"_theoreticalMass") && gridExists(prefix+"_molecularWeight")){
				document.getElementById(prefix+"_theoreticalMoles").value = ($$$(prefix+"_theoreticalMass")/$$$(prefix+"_molecularWeight")).autoRound(unitD.moles,sigdigs,defaultMolUnits);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_theoreticalMoles"));
			}
			if(document.getElementById(prefix+"_yield").value=='' && gridExists(prefix+"_actualMoles") && gridExists(prefix+"_theoreticalMoles")){
				document.getElementById(prefix+"_yield").value = ($$$(prefix+"_actualMass")/$$$(prefix+"_theoreticalMass")).autoRound(unitD.percent,sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_yield"));
			}
			if(document.getElementById(prefix+"_actualMoles").value=='' && gridExists(prefix+"_yield") && gridExists(prefix+"_theoreticalMoles")){
				document.getElementById(prefix+"_actualMoles").value = ($$$(prefix+"_yield")*$$$(prefix+"_theoreticalMoles")).autoRound(unitD.moles,sigdigs,defaultMolUnits);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_actualMoles"));
			}
			if(document.getElementById(prefix+"_actualMoles").value=='' && gridExists(prefix+"_measuredMass") && gridExists(prefix+"_molecularWeight")){
				if (gridExists(prefix+"_purity")){
					document.getElementById(prefix+"_actualMoles").value = ($$$(prefix+"_measuredMass")/$$$(prefix+"_molecularWeight")*$$$(prefix+"_purity")).autoRound(unitD.moles,sigdigs,defaultMolUnits);
				}else{
					document.getElementById(prefix+"_actualMoles").value = ($$$(prefix+"_measuredMass")/$$$(prefix+"_molecularWeight")).autoRound(unitD.moles,sigdigs,defaultMolUnits);
				}
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_actualMoles"));
			}
			if(document.getElementById(prefix+"_actualMass").value=='' && gridExists(prefix+"_actualMoles") && gridExists(prefix+"_molecularWeight")){
				if (gridExists(prefix+"_purity")){
					document.getElementById(prefix+"_actualMass").value = (($$$(prefix+"_measuredMass")*$$$(prefix+"_purity"))).autoRound(unitD.mass,sigdigs);
				}else{
					document.getElementById(prefix+"_actualMass").value = (($$$(prefix+"_measuredMass"))).autoRound(unitD.mass,sigdigs);
				}
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_actualMass"));
			}
		}
		if(prefix.substring(0,1) == 's'){
			if(document.getElementById(prefix+"_volume").value=='' && gridExists(prefix+"_moles") && gridExists(prefix+"_reactionMolarity")){
				document.getElementById(prefix+"_volume").value = ($$$(prefix+"_moles")/$$$(prefix+"_reactionMolarity")).autoRound(unitD.volume,sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_volume"));
			}
			if(document.getElementById(prefix+"_reactionMolarity").value=='' && gridExists(prefix+"_moles") && gridExists(prefix+"_volume")){
				document.getElementById(prefix+"_reactionMolarity").value = ($$$(prefix+"_moles")/$$$(prefix+"_volume")).autoRound(unitD.molarity,sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_reactionMolarity"));
			}
			if(document.getElementById(prefix+"_moles").value=='' && gridExists(prefix+"_reactionMolarity") && gridExists(prefix+"_volume")){
				document.getElementById(prefix+"_moles").value = ($$$(prefix+"_reactionMolarity")*$$$(prefix+"_volume")).autoRound(unitD.moles,sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_moles"));
			}
	
			if(document.getElementById(prefix+"_moles").value == ''){
				if(firstCalcRow.substring(0,1) == 'p'){
					sourceName = "theoreticalMoles";
				}else{
					sourceName = "moles";
				}
				document.getElementById(prefix+"_moles").value = ($$$(firstCalcRow+"_"+sourceName)/$$$(firstCalcRow+"_equivalents")).autoRound(unitD.moles,sigdigs);
				didCalc = true;
			}

			var limitingPrefix = getLimitingReactant();
			if (limitingPrefix) {
				if (document.getElementById(prefix + "_volumes").value == "" && gridExists(prefix + "_volume") && gridExists(limitingPrefix + "_reactantMass")) {
					var volumeVal = $$$(prefix + "_volume");
					var limitingMassVal = $$$(limitingPrefix + "_reactantMass");
					document.getElementById(prefix + "_volumes").value = (volumeVal / limitingMassVal).autoRound(unitD.volumes, sigdigs);
				}
				if (document.getElementById(prefix + "_volume").value == "" && gridExists(prefix + "_volumes") && gridExists(limitingPrefix + "_reactantMass")) {
					var volumesVal = $$$(prefix + "_volumes");
					var limitingMassVal = $$$(limitingPrefix + "_reactantMass");
					document.getElementById(prefix + "_volume").value = (volumesVal * limitingMassVal).autoRound(unitD.volume, sigdigs);
					didCalc = true;
					doCkAutoFill(document.getElementById(prefix + "_volume"));
				}
			}
		}
		return didCalc;
	}

	/**
	 * This will update the values of the equivalents based on other fields. Runs after everything else is done
	 * @param {String} prefix - Name of the current tab we are looking at (ex: "r1")
	 */
	function calcRowLoopEquivalents(prefix){
		if(prefix.substring(0,1) == 'r'){
			if(document.getElementById(prefix+"_equivalents").value=='' && gridExists(prefix+"_moles")){
				theRow = findMolesCalcRow2();
				if(theRow.substring(0,1) == 'p'){
					sourceName = "theoreticalMoles";
				}else{
					sourceName = "moles"
				}
				//ELN-1267 NAN error occurs when conflicting values are added to a single tab in the stoichiometry table
				//if(isNaN($$$(theRow+"_"+sourceName))){
				if (theRow == prefix){		//If theRow and prefix are same the values will conflict and goes into the loop.. In that case use limiting reagents values to back calculate
					theRow = prefixes[0]
				}
				if(isNaN(($$$(theRow+"_equivalents")*$$$(prefix+"_moles")/$$$(theRow+"_"+sourceName)).toFixed(sigdigs))){
					//console.log("543:: "+ prefix +" Limitting checked :: "+document.getElementById(prefix+"_limit").checked +" :: equivalent value set to 1");
					document.getElementById(prefix+"_equivalents").value = 1;

					//Only calc based on the equivalents if the weightRatio isn't already set
					if (document.getElementById(prefix+"_weightRatio").value==''){
						gridFieldChanged(document.getElementById(prefix+"_equivalents"));
					}
				}
				else{
					//console.log("548:: "+ prefix +" Limitting checked :: "+document.getElementById(prefix+"_limit").checked + " :: equivalent value set to " + ($$$(theRow+"_equivalents")*$$$(prefix+"_moles")/$$$(theRow+"_"+sourceName)).toFixed(sigdigs));
					document.getElementById(prefix+"_equivalents").value = ($$$(theRow+"_equivalents")*$$$(prefix+"_moles")/$$$(theRow+"_"+sourceName)).toFixed(sigdigs);
				}
			}
		}
		if(prefix.substring(0,1) == 'p'){
			if(document.getElementById(prefix+"_equivalents").value=='' && gridExists(prefix+"_theoreticalMoles")){
				//it would be better to have all of these functions run after other calcs were done
				//the reason this is like this is because if there is another row that is forcing the equivalents to be changed
				//because of too many imps, the moles for that row can temporarily be Nan
				theRow = findMolesCalcRow2();
				if(theRow.substring(0,1) == 'p'){
					sourceName = "theoreticalMoles";
				}else{
					sourceName = "moles"
				}
				document.getElementById(prefix+"_equivalents").value = ($$$(theRow+"_equivalents")*$$$(prefix+"_theoreticalMoles")/$$$(theRow+"_"+sourceName)).toFixed(sigdigs);
				didCalc = true;
				doCkAutoFill(document.getElementById(prefix+"_equivalents"));
				gridSaveTimeout = setTimeout(sendGridAutoSave,1000);
			}
		}
	}

	/**
	 * Helper function to get the limiting reactant.
	 */
	function getLimitingReactant() {
		return getLimitingPrefix(["r"]);
	}

	/**
	 * Helper function to check all given prefixes for the limiting fragment.
	 * @param {string[]} prefixFilterList The list of prefix filters to check for the limiting fragment.
	 */
	function getLimitingPrefix(prefixFilterList) {
		var limitingPrefix = false;
		var reactantsList = filterPrefixList(prefixFilterList);

		var limitingList = reactantsList.filter(function(prefix) {
			var element = document.getElementById(prefix + "_limit");
			if (element) {
				return element.checked;
			}
			return false;
		});

		if (limitingList.length > 0) {
			limitingPrefix = limitingList[0];
		}

		return limitingPrefix;
	}

	/**
	 * Helper function to limit the list of prefies down to the desired prefixes.
	 * @param {string[]} desiredPrefixList The list of prefix filters to filter prefixes down to.
	 */
	function filterPrefixList(desiredPrefixList) {
		var filteredList = prefixes.filter(function(prefix) {
			return desiredPrefixList.includes(prefix.replace(/[0-9]/g, ''));
		});

		return filteredList
	}
