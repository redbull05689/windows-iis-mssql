	function isNumber(n) {
	  return !isNaN(parseFloat(n)) && isFinite(n);
	}
	function fixBool(x){
		if (x=="false" || x=="true"){
			if(x=="true"){
				return true;
			}else{
				return false;
			}
		}else{
			return x;
		}
	}

	var groups = []
	var firstLoad = true;

	function finalizeSearch()
	{
		L = []
		for (i=0;i<groups.length ;i++ )
		{
			for(j=0;j<groups[i].length;j++)
			{
				el = document.getElementById("field_"+i+"_"+j)
				if (el != null)
				{
					L.push(i+"_"+j)
					ft = document.createElement("input")
					ft.setAttribute("type","hidden")
					ft.setAttribute("id","fieldType_"+i+"_"+j)
					ft.setAttribute("name","fieldType_"+i+"_"+j)
					ft.setAttribute("value",document.getElementById("fieldType_"+document.getElementById("field_"+i+"_"+j).selectedIndex).value)
					document.getElementById("advancedSearchHolder").appendChild(ft)
				}
			}
		}
		document.getElementById("fieldsForSearch").value = L.join();
		savedSearch = []
		for (i=0;i<groups.length ;i++ )
		{
			groupData = {}
			theFields = []
			for(j=0;j<groups[i].length;j++)
			{
				el = document.getElementById("field_"+i+"_"+j)
				if (el != null)
				{
					f = el.options[el.selectedIndex].value;
					qEl = document.getElementById("qualifier_"+i+"_"+j);
					q = qEl.options[qEl.selectedIndex].value;
					vEl = document.getElementById("value_"+i+"_"+j);
					if (vEl.options){
						v = vEl.options[vEl.selectedIndex].value;
					}else{
						v = vEl.value;
					}
					if (el.options[el.selectedIndex].getAttribute("resultDefinition")){
						r = true;
					}else{
						r = false;
					}
					D = {"field":f,"qualifier":q,"value":v,"resultDefinition":r}
					if (j>0){
						cEl = document.getElementById("contraction_"+i+"_"+j);
						c = cEl.options[cEl.selectedIndex].value;
						D["contraction"] = c;
					}
					if (el.options[el.selectedIndex].getAttribute("type")){
						D["type"] = el.options[el.selectedIndex].getAttribute("type");
					}else{
						D["type"] = false;
					}
					theFields.push(D)
				}
				groupContractionField = document.getElementById("contraction_"+i)
				if(groupContractionField != null){
					groupData["contraction"] = groupContractionField.options[groupContractionField.selectedIndex].value
				}
			}
			groupData["fields"] = theFields;
			savedSearch.push(groupData)
		}
		//alert(JSON.stringify(savedSearch));
		document.getElementById("savedSearchForSearch").value = JSON.stringify(savedSearch);
	}

	function makeMongoQuery(chemIframeId,chemTableArg,chemSearchDbNameArg) {
		return new Promise(function (resolve, reject) {
			ss = JSON.parse(document.getElementById("savedSearchForSearch").value);
			outer = {};
			outerAnds = [];
			outerOrs = [];
			L = [];

			var chemPromises = [];
			if (!chemIframeId && qs()["c"] != "experiments") {
				chemPromises.push(new Promise(function (resolve, reject) {
					chemData = "";
					hasChemdraw().then(function (isInstalled) {
						try {
							if (isInstalled) {
								chemData = cd_getData("mycdx", "chemical/x-mdl-molfile");
							} else {
								chemData = document.marvinObject.evaluateChemicalTerms("mass()");
								if (chemData != 0) {
									chemData = document.getElementById("marvinObject").getMol("mol");
								} else {
									chemData = "";
								}
							}

							if (chemData != "") {
								el = document.getElementById("searchTypeForSearch");
								searchType = el.options[el.selectedIndex].value;
								cdIds = restCall("/getCdIds/", "POST", { 'tableName': chemTable, 'structure': chemData, 'searchType': searchType });
								X = {};
								Y = {};
								X[chemSearchDbName] = { "$in": cdIds };
								Y[chemSearchDbName2] = { "$in": cdIds };
								outerAnds.push({ "$or": [X, Y] });
							}
						}
						catch (e) {
							resolve(true);
						}

						resolve(true);
					});
				}));
			} else {
				chemPromises.push(new Promise(function (resolve, reject) {
					chemData = "";
					hasChemdraw().then(function (isInstalled) {
						try {
							if (isInstalled) {
								chemData = window.parent.document.getElementById(chemIframeId).contentWindow.cd_getData("mycdx", "chemical/x-mdl-molfile");
							} else {
								chemData = window.parent.document.getElementById(chemIframeId).contentWindow.document.marvinObject.evaluateChemicalTerms("mass()");
								if (chemData != 0) {
									chemData = window.parent.document.getElementById(chemIframeId).contentWindow.document.getElementById("marvinObject").getMol("mol");
								} else {
									chemData = "";
								}
							}
						}
						catch (e) {
							resolve(true);
						}

						if (chemData != "") {
							el = window.parent.document.getElementById(chemIframeId).contentWindow.document.getElementById("searchTypeForSearch");
							searchType = el.options[el.selectedIndex].value;
							cdIds = restCall("/getCdIds/", "POST", { "tableName": chemTableArg, "structure": chemData, "searchType": searchType });
							X = {};
							Y = {};
							X[chemSearchDbNameArg[0]] = { "$in": cdIds };
							Y[chemSearchDbNameArg[1]] = { "$in": cdIds };
							outerAnds.push({ "$or": [X, Y] });
						}

						resolve(true);
					});
				}));
			}

			Promise.all(chemPromises(function() {
				for(var i=0;i<ss.length;i++){
					group = ss[i];
					inner = {};
					ors = [];
					ands = [];
					for(var j=0;j<group.fields.length;j++){
						c = group.fields[j];
						if(isNumber(c["value"])){
							c["value"] = parseFloat(c["value"]);
						}
						if(c["type"]=="date"){
							c["value"] = new Date(c["value"]);
						}
						c["value"] = fixBool(c["value"]);
						if(c["resultDefinition"]){
							D = {};
							D2 = {};
							o = {}
							o[c["qualifier"]] = c["value"];
							regObj = {'value':o};
							o = {}
							o[c["qualifier"]] = c["value"];
							multiObj = {'$elemMatch':o};
							if(c["qualifier"] == "$eq"){
								o = {};
								o["$in"] = [c["value"]];
								multiObj = {'$elemMatch':o};
								if(!isNumber(c["value"]) && c["value"] !== true && c["value"] !== false){
									o = {};
									o["$regex"] = "^"+c["value"]+"$"
									o['$options'] = '-i';
									regObj = {'value':o}
								}else{
									regObj = {};
									regObj['value'] = c["value"];
								}
							}else{
								if(c["qualifier"]=="$regex"){
									o = {}
									o["$regex"] = c["value"]
									o['$options'] = '-i';
									regObj = {'value':o};
									o = {};
									o["$in"] = [c["value"]];
									multiObj = {'$elemMatch':o};
								}

								if(c["qualifier"]=="$notregex"){
									o = {};
									o["$regex"] = "^((?!"+c["value"]+").)*$"
									o['$options'] = '-i';
									regObj = {'value':o};
									o = {};
									o["$nin"] = [c["value"]]
									multiObj = {'$elemMatch':o};
								}
								if(!isNumber(c["value"]) && c["value"] !== true && c["value"] !== false){
									if(c["qualifier"]=="$ne"){
										o = {}
										o["$regex"] = "^(?!^"+c["value"]+"$)"
										o['$options'] = '-i';
										regObj = {'value':o};
										o = {};
										o["$nin"] = [c["value"]];
										multiObj = {'$elemMatch':o};
									}
								}
							}
							o = {};
							o["$elemMatch"] = multiObj["$elemMatch"]
							multiObj["value"] = o;
							delete multiObj["$elemMatch"];
							multiObj["multi"] = true;
							multiObj["name"] = c["field"];
							regObj["multi"] = false;
							regObj["name"] = c["field"];
							l = [multiObj,regObj];
							D1 = {};
							D1["$or"] = l;
							D2 = {};
							D2["$elemMatch"] = D1;
							D = {};
							D["results"] = D2;
						}else{
							D = {};
							D2 = {}
							D2[c["qualifier"]] = c["value"]
							if(c["qualifier"] == "$eq"){
								if(!isNumber(c["value"]) && c["value"] !== true && c["value"] !== false){
									D[c["field"]] = {"$regex":"^"+c["value"]+"$",'$options':'-i'};
								}else{
									D[c["field"]] = c["value"];
								}
							}else{
								D[c["field"]] = D2;
								if(c["qualifier"]=="$regex"){
									D[c["field"]] = {"$regex":c["value"],'$options':'-i'};
								}

								if(c["qualifier"]=="$notregex"){
									D[c["field"]] = {"$regex":"^((?!"+c["value"]+").)*$",'$options':'-i'};
								}
								if(!isNumber(c["value"]) && c["value"] !== true && c["value"] !== false){
									if(c["qualifier"]=="$ne"){
										D[c["field"]] = {"$regex":"^(?!^"+c["value"]+"$)",'$options':'-i'};
									}
								}
							}
						}
						if(c.contraction){
							if(c.contraction=="AND"){
								ands.push(D);
							}else{
								ors.push(D)
							}
						}else{
							ors.push(D)
						}
					}
					if(ands.length){
						inner["$and"] = ands;
					}
					if(ors.length){
						inner["$or"] = ors;
					}

					if(group.contraction){
						if(group.contraction=="AND"){
							outerAnds.push(inner);
						}else{
							outerOrs.push(inner);
						}
					}else{
						outerOrs.push(inner);
					}
				}
				if(outerAnds.length){
					outer["$and"] = outerAnds;
				}
				if(outerOrs.length){
					outer["$or"] = outerOrs;
				}
				//window.parent.document.getElementById("temp").innerHTML = JSON.stringify(outer);
				//alert(JSON.stringify(outer))
				resolve(outer);
			}));
		});
	}

	function newGroup()
	{
		groups.push([])
		groupNumber = groups.length -1
		groupId = "groupHolder_"+groupNumber
		groupDiv = document.createElement("div")
		groupDiv.setAttribute("id",groupId)
		groupDiv.setAttribute("name",groupId)
		groupDiv.className = "groupHolder"

		isFirstGroup = true
		for (i=groupNumber-1;i>=0;i-- )
		{
			if (document.getElementById("groupHolder_"+i) != null)
			{
				isFirstGroup = false
			}
		}

		if (!isFirstGroup)
		{
			contractionSelect = getContractionSelect()
			contractionSelect.setAttribute("id","contraction_"+groupNumber)
			contractionSelect.setAttribute("name","contraction_"+groupNumber)
			groupDiv.appendChild(contractionSelect)
		}
		else
		{
			for (i=0;i<searchFieldList.length;i++)
			{
				theHidden = document.createElement("input")
				theHidden.setAttribute("type","hidden")
				theHidden.setAttribute("id","fieldType_"+i)
				theHidden.setAttribute("name","fieldType_"+i)
				theHidden.setAttribute("value",searchFieldList[i].type)
				document.getElementById("advancedSearchHolder").appendChild(theHidden)
			}
		}

		document.getElementById("advancedSearchHolder").insertBefore(groupDiv,document.getElementById("newGroupLink"))
		
		newCriteria(groupNumber)
	}

	function newCriteria(groupNumber)
	{
		//alert(groups[groupNumber])
		fieldNumber = groups[groupNumber].length
		L = []
		fieldId = "fieldHolder_"+groupNumber+"_"+fieldNumber 
		fieldDiv = document.createElement("span")
		fieldDiv.setAttribute("id",fieldId)
		fieldDiv.setAttribute("name",fieldId)
		fieldDiv.className = "fieldHolder"

		fieldSelect = document.createElement("select")
		fieldSelect.setAttribute("id","field_"+groupNumber+"_"+fieldNumber)
		fieldSelect.setAttribute("name","field_"+groupNumber+"_"+fieldNumber)
		fieldSelect.onchange = function(){fieldChanged(this);}//setAttribute("onchange","fieldChanged(this);") qqq
		firstReal = false;
		for (i=0;i<searchFieldList.length;i++)
		{
			theOption = document.createElement("option")
			theText = document.createTextNode(searchFieldList[i].fName)
			theOption.appendChild(theText)
			theOption.setAttribute("value",searchFieldList[i].name)
			//should be dbtype
			if(searchFieldList[i]["type"]){
				theOption.setAttribute("type",searchFieldList[i]["type"]);
			}
			if(searchFieldList[i]["resultDefinition"]){
				theOption.setAttribute("resultDefinition",true);
			}
			firstNonNoneFieldIndex = 0;
			//firstReal = true;
			fieldSelect.appendChild(theOption)

			if (firstLoad)
			{
				if (searchFieldList[i].options)
				{
					k = []
					l = []
					selectList = searchFieldList[i].options.slice(0);
					for (j=0;j<selectList.length ;j++ )
					{
						k.push(selectList[j][0])
						l.push(selectList[j][1])
					}
					theHidden = document.createElement("input")
					theHidden.setAttribute("type","hidden")
					theHidden.setAttribute("id","selectValues_"+i)
					theHidden.setAttribute("name","selectValues_"+i)						
					theHidden.value = k
					document.getElementById("advancedSearchHolder").appendChild(theHidden)
					theHidden = document.createElement("input")
					theHidden.setAttribute("type","hidden")
					theHidden.setAttribute("id","selectTexts_"+i)
					theHidden.setAttribute("name","selectTexts_"+i)						
					theHidden.value = l
					document.getElementById("advancedSearchHolder").appendChild(theHidden)
					theHidden = document.createElement("input")
					theHidden.setAttribute("type","hidden")
					theHidden.setAttribute("id","isSelect_"+i)
					theHidden.setAttribute("name","isSelect_"+i)						
					theHidden.value = "1"
					document.getElementById("advancedSearchHolder").appendChild(theHidden)
				}
				theHidden = document.createElement("input")
				theHidden.setAttribute("type","hidden")
				theHidden.setAttribute("id","fieldType_"+i)
				theHidden.setAttribute("name","fieldType_"+i)
			}
		}
		firstLoad = false;

		isFirstField = true
		for (i=fieldNumber-1;i>=0;i-- )
		{
			if (document.getElementById("value_"+groupNumber+"_"+i) != null)
			{
				isFirstField = false
			}
		}

		gh = document.getElementById("groupHolder_"+groupNumber)

		if (isFirstField && document.getElementById("endParenHolder_"+groupNumber) == null)
		{
			theSpan = document.createElement("span")
			theSpan.className = "paren"
			theText = document.createTextNode("(")
			theSpan.appendChild(theText)
			document.getElementById("groupHolder_"+groupNumber).appendChild(theSpan)

			

			theSpan = document.createElement("span")
			theSpan.className = "paren"
			theSpan.setAttribute("id","endParen_"+groupNumber)
			theSpan.setAttribute("name","endParen_"+groupNumber)
			theText = document.createTextNode(")")
			theSpan.appendChild(theText)

			theA = document.createElement("a")
			theImg = document.createElement("img")
			theImg.src = "images/add.gif"
			theImg.setAttribute("title","Add Field")
			theA.appendChild(theImg)
			theA.onclick = function(){newCriteria(groupNumber)}

			theA2 = document.createElement("a")
			theImg = document.createElement("img")
			theImg.src = "images/delete.gif"
			theImg.setAttribute("title","Remove Group")
			theA2.appendChild(theImg)
			theA2.onclick = (function(groupNumber){
				return function(){removeGroup(groupNumber)}
			})(groupNumber);
			//theA2.setAttribute("onclick","removeGroup('"+groupNumber+"')")

			theDiv = document.createElement("div")
			theDiv.setAttribute("id","endParenHolder_"+groupNumber)
			theDiv.setAttribute("name","endParenHolder_"+groupNumber)
			theDiv.className = "endParenHolder"
			theDiv.appendChild(theA)
			theDiv.appendChild(theSpan)
			theDiv.appendChild(theA2)

			document.getElementById("groupHolder_"+groupNumber).appendChild(theDiv)
		}

		ep = document.getElementById("endParenHolder_"+groupNumber)

		if (!isFirstField)
		{
			contractionSelect = getContractionSelect()
			contractionSelect.setAttribute("id","contraction_"+groupNumber+"_"+fieldNumber)
			contractionSelect.setAttribute("name","contraction_"+groupNumber+"_"+fieldNumber)

			//gh.insertBefore(contractionSelect,ep)
			fieldDiv.appendChild(contractionSelect)
		}

		//gh.insertBefore(fieldSelect,ep)
		fieldSelect.selectedIndex = firstNonNoneFieldIndex
		fieldDiv.appendChild(fieldSelect)

		thisType = searchFieldList[firstNonNoneFieldIndex].type
		if (searchFieldList[firstNonNoneFieldIndex].options){thisType = "custom_select"}

		qualifierSelect = getQualifierSelect(thisType)
		qualifierSelect.setAttribute("id","qualifier_"+groupNumber+"_"+fieldNumber)
		qualifierSelect.setAttribute("name","qualifier_"+groupNumber+"_"+fieldNumber)

		//gh.insertBefore(qualifierSelect,ep)
		fieldDiv.appendChild(qualifierSelect)

		//valueText = document.createElement("input")
		//valueText.setAttribute("type","text")
		//valueText.setAttribute("id","value_"+groupNumber+"_"+fieldNumber)
		//valueText.setAttribute("name","value_"+groupNumber+"_"+fieldNumber)
			if (thisType == 'custom_select')
			{valueObject = getCustomSelect(groupNumber,fieldNumber,firstNonNoneFieldIndex)
			}else{
			valueObject = getValueBox(groupNumber,fieldNumber)}

		//gh.insertBefore(valueText,ep)
		fieldDiv.appendChild(valueObject)

		theA = document.createElement("a")
		theA.setAttribute("id","barcodeLink_"+groupNumber+"_"+fieldNumber)
		theA.setAttribute("name","barcodeLink_"+groupNumber+"_"+fieldNumber)
		theA.onclick = function(){getBarcodes("value_"+groupNumber+"_"+fieldNumber)}
		theImg = document.createElement("img")
		theImg.src = "images/barcode.gif"
		theImg.setAttribute("title","Enter Barcodes")
		theA.style.display = "none";
		theA.appendChild(theImg)
		fieldDiv.appendChild(theA)

		theA = document.createElement("a")
		theA.setAttribute("id","removeFieldLink_"+groupNumber+"_"+fieldNumber)
		theA.setAttribute("name","removeFieldLink_"+groupNumber+"_"+fieldNumber)
		theImg = document.createElement("img")
		theImg.src = "images/delete.gif"
		theImg.setAttribute("title","Remove Field")
		theA.appendChild(theImg)
		//theA.setAttribute("onclick","removeCriteria('"+groupNumber+"_"+fieldNumber+"')")
		theA.onclick = (function(groupNumber,fieldNumber){
			return function(){removeCriteria(groupNumber,fieldNumber)}
		})(groupNumber,fieldNumber);
		//gh.insertBefore(theA,ep)
		fieldDiv.appendChild(theA)

		gh.insertBefore(fieldDiv,ep)
		groups[groupNumber].push(L)

		fieldSelect.onchange();
	}

	function fieldChanged(el)
	{
		thisName = el.options[el.selectedIndex].value
		groupNumber = el.id.replace(/field_/,"").split("_")[0]
		fieldNumber = el.id.replace(/field_/,"").split("_")[1]

		isSelect = document.getElementById("isSelect_"+el.selectedIndex)
		document.getElementById("value_"+groupNumber+"_"+fieldNumber).parentNode.removeChild(document.getElementById("value_"+groupNumber+"_"+fieldNumber))
		thisType2 = document.getElementById("fieldType_"+el.selectedIndex).value;

		if (thisName == "salt"){
			valueObject = getSaltSelect(groupNumber,fieldNumber)
		}else{
			if (thisName == "groupId")
			{
				valueObject = getFieldGroupSelect(groupNumber,fieldNumber)
			}else{
				if (isSelect)
				{
					valueObject = getCustomSelect(groupNumber,fieldNumber,el.selectedIndex)
				}else{
					if (thisType2=="bool")
					{
						valueObject = getBoolSelect(groupNumber,fieldNumber)
					}else{
						valueObject = getValueBox(groupNumber,fieldNumber)}
					}
				}
		}
		document.getElementById("removeFieldLink_"+groupNumber+"_"+fieldNumber).parentNode.insertBefore(valueObject,document.getElementById("removeFieldLink_"+groupNumber+"_"+fieldNumber))
		document.getElementById("barcodeLink_"+groupNumber+"_"+fieldNumber).parentNode.insertBefore(valueObject,document.getElementById("barcodeLink_"+groupNumber+"_"+fieldNumber))

		thisType = document.getElementById("fieldType"+"_"+el.selectedIndex).value
		if (isSelect){thisType="custom_select";}
		groupNumber = el.id.replace(/field_/,"").split("_")[0]
		fieldNumber = el.id.replace(/field_/,"").split("_")[1]

		document.getElementById("qualifier_"+groupNumber+"_"+fieldNumber).parentNode.removeChild(		document.getElementById("qualifier_"+groupNumber+"_"+fieldNumber))

		qualifierSelect = getQualifierSelect(thisType)
		qualifierSelect.setAttribute("id","qualifier_"+groupNumber+"_"+fieldNumber)
		qualifierSelect.setAttribute("name","qualifier_"+groupNumber+"_"+fieldNumber)

		document.getElementById("value_"+groupNumber+"_"+fieldNumber).parentNode.insertBefore(qualifierSelect,document.getElementById("value_"+groupNumber+"_"+fieldNumber))

		if (thisType == 'date')
		{
			Calendar.setup(
			{
			  inputField  : "value_"+groupNumber+"_"+fieldNumber,         // ID of the input field
			  ifFormat    : "%m/%d/%Y",    // the date format
			  showsTime   : false,
			  timeFormat  : "12",
			  electric    : false
			});
			var the_height= window.parent.document.getElementById("advSearchFrame").contentWindow.document.body.scrollHeight;
			if(the_height<230){
				window.parent.document.getElementById("advSearchFrame").height= 230;
			}
			//document.getElementById("value_"+groupNumber+"_"+fieldNumber).onclick = function(){dt.select(this,'dummyA','MM/dd/yyyy');}
		}
		else
		{
			document.getElementById("value_"+groupNumber+"_"+fieldNumber).onclick = function(){;}
		}
	}

	function removeGroup(groupNumber)
	{
		groupNumber = parseInt(groupNumber)

		isFirstGroup = true
		for (i=groupNumber-1;i>=0;i-- )
		{
			if (document.getElementById("groupHolder_"+i) != null)
			{
				isFirstGroup = false
			}
		}

		el = document.getElementById("groupHolder_"+groupNumber)
		el.parentNode.removeChild(el)

		if (isFirstGroup)
		{
			nextGroup = groupNumber + 1
			while (document.getElementById("groupHolder_"+nextGroup)==null)
			{
				nextGroup += 1
				if (nextGroup == 100)
				{
					break
				}
			}
			//alert(nextField)
			if (document.getElementById("groupHolder_"+nextGroup) != null)
			{
				el = document.getElementById("contraction_"+nextGroup)
				el.parentNode.removeChild(el)
			}
		}

	}




	function removeCriteria(groupNumber,fieldNumber)
	{
		//alert(groupField)
		//groupNumber = parseInt(groupField.split("_")[0])
		//fieldNumber = parseInt(groupField.split("_")[1])

		isFirstField = true
		for (i=fieldNumber-1;i>=0;i-- )
		{
			if (document.getElementById("value_"+groupNumber+"_"+i) != null)
			{
				isFirstField = false
			}
		}

		if (!isFirstField)
		{
			el = document.getElementById("contraction_"+groupNumber+"_"+fieldNumber)
			el.parentNode.removeChild(el)
		}
			el = document.getElementById("field_"+groupNumber+"_"+fieldNumber)
			el.parentNode.removeChild(el)
			el = document.getElementById("qualifier_"+groupNumber+"_"+fieldNumber)
			el.parentNode.removeChild(el)
			el = document.getElementById("value_"+groupNumber+"_"+fieldNumber)
			el.parentNode.removeChild(el)
			el = document.getElementById("removeFieldLink_"+groupNumber+"_"+fieldNumber)
			el.parentNode.removeChild(el)
			el = document.getElementById("barcodeLink_"+groupNumber+"_"+fieldNumber)
			el.parentNode.removeChild(el)
		if (isFirstField)
		{
			//alert("first Files")
			nextField = fieldNumber + 1
			//alert("value_"+groupNumber+"_"+nextField)
			//alert(document.getElementById("value_"+groupNumber+"_"+nextField)==null)
			while (document.getElementById("value_"+groupNumber+"_"+nextField)==null)
			{
				nextField += 1
				if (nextField == 100)
				{
					break
				}
			}
			//alert(nextField)
			if (document.getElementById("value_"+groupNumber+"_"+nextField) != null)
			{
				el = document.getElementById("contraction_"+groupNumber+"_"+nextField)
				el.parentNode.removeChild(el)
			}
		}
		el = document.getElementById("fieldHolder_"+groupNumber+"_"+fieldNumber)
		el.parentNode.removeChild(el)

	}

	function getContractionSelect()
	{
		theSelect = document.createElement("select")

		theOption = document.createElement("option")
		theText = document.createTextNode("AND")
		theOption.appendChild(theText)
		theOption.setAttribute("value","AND")
		theSelect.appendChild(theOption)

		theOption = document.createElement("option")
		theText = document.createTextNode("OR")
		theOption.appendChild(theText)
		theOption.setAttribute("value","OR")
		theSelect.appendChild(theOption)

		return theSelect
	}

	function getValueBox(groupNumber,fieldNumber)
	{
		valueText = document.createElement("input")
		valueText.setAttribute("type","text")
		valueText.setAttribute("id","value_"+groupNumber+"_"+fieldNumber)
		valueText.setAttribute("name","value_"+groupNumber+"_"+fieldNumber)
		return valueText
	}

	function getBoolSelect(groupNumber,fieldNumber)
	{
		theSelect = document.createElement("select")
		theSelect.setAttribute("name","value_"+groupNumber+"_"+fieldNumber)
		theSelect.setAttribute("id","value_"+groupNumber+"_"+fieldNumber)

		theOption = document.createElement("option")
		theText = document.createTextNode("false")
		theOption.appendChild(theText)
		theOption.setAttribute("value",false)
		theSelect.appendChild(theOption)

		theOption = document.createElement("option")
		theText = document.createTextNode("true")
		theOption.appendChild(theText)
		theOption.setAttribute("value",true)
		theSelect.appendChild(theOption)

		return theSelect
	}


	function getFieldGroupSelect(groupNumber,fieldNumber)
	{
		optionList = eval(getFile(advancedSearchFieldGroupFile))
		theSelect = document.createElement("select")
		theSelect.setAttribute("name","value_"+groupNumber+"_"+fieldNumber)
		theSelect.setAttribute("id","value_"+groupNumber+"_"+fieldNumber)

		for (i=0;i<optionList.length;i++)
		{
			theOption = document.createElement("option")
			theText = document.createTextNode(optionList[i][1])
			theOption.appendChild(theText)
			theOption.setAttribute("value",optionList[i][0])
			theSelect.appendChild(theOption)
		}

		return theSelect
	}

	function getCustomSelect(groupNumber,fieldNumber,fieldTypeNumber)
	{
		optionList = []
		k = document.getElementById("selectValues_"+fieldTypeNumber).value.split(",")
		l = document.getElementById("selectTexts_"+fieldTypeNumber).value.split(",")
		for (i=0;i<k.length ;i++ )
		{
			optionList.push([k[i],l[i]])
		}
		theSelect = document.createElement("select")
		theSelect.setAttribute("name","value_"+groupNumber+"_"+fieldNumber)
		theSelect.setAttribute("id","value_"+groupNumber+"_"+fieldNumber)

		for (i=0;i<optionList.length;i++)
		{
			theOption = document.createElement("option")
			theText = document.createTextNode(optionList[i][1])
			theOption.appendChild(theText)
			theOption.setAttribute("value",optionList[i][0])
			theSelect.appendChild(theOption)
		}

		return theSelect
	}


	function getQualifierSelect(thisType)
	{
		theSelect = document.createElement("select")

		//theOption = document.createElement("option")
		//theText = document.createTextNode("--")
		//theOption.appendChild(theText)
		//theOption.setAttribute("value","")
		//theSelect.appendChild(theOption)

		if (thisType != 'text' && thisType != 'drop_down' && thisType != 'custom_select' && thisType != 'bool')
		{
			theOption = document.createElement("option")
			theText = document.createTextNode("<")
			if (thisType=='date'){theText = document.createTextNode("Before")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","$lt")
			theSelect.appendChild(theOption)

			theOption = document.createElement("option")
			theText = document.createTextNode("<=")
			if (thisType=='date'){theText = document.createTextNode("Before or on")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","$lte")
			theSelect.appendChild(theOption)

			theOption = document.createElement("option")
			theText = document.createTextNode(">")
			if (thisType=='date'){theText = document.createTextNode("After")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","$gt")
			theSelect.appendChild(theOption)

			theOption = document.createElement("option")
			theText = document.createTextNode(">=")
			if (thisType=='date'){theText = document.createTextNode("On or after")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","$gte")
			theSelect.appendChild(theOption)
		}

		theOption = document.createElement("option")
		if (thisType == 'custom_select'){theText = document.createTextNode("Is")}
		else{theText = document.createTextNode("Equals")}
		if (thisType=='date'){theText = document.createTextNode("On")}
		theOption.appendChild(theText)
		theOption.setAttribute("value","$eq")
		theSelect.appendChild(theOption)
	
		theOption = document.createElement("option")
		if (thisType == 'custom_select'){theText = document.createTextNode("Is Not")}
		else{theText = document.createTextNode("Not Equals")}
		if (thisType=='date'){theText = document.createTextNode("Not on")}
		theOption.appendChild(theText)
		theOption.setAttribute("value","$ne")
		theSelect.appendChild(theOption)

		if (thisType == 'text' || thisType == 'drop_down')
		{
			theOption = document.createElement("option")
			theText = document.createTextNode("Contains")
			theOption.appendChild(theText)
			theOption.setAttribute("value","$regex")
			theSelect.appendChild(theOption)

			theOption = document.createElement("option")
			theText = document.createTextNode("Doesn't Contain")
			theOption.appendChild(theText)
			theOption.setAttribute("value","$notregex")
			theSelect.appendChild(theOption)

			//theOption = document.createElement("option")
			//theText = document.createTextNode("In List")
			//theOption.appendChild(theText)
			//theOption.setAttribute("value","in")
			//theSelect.appendChild(theOption)

			theSelect.onchange = function(){
				if(this.options[this.selectedIndex].value=="in"){
					coords = this.id.replace("qualifier_","")
					document.getElementById("barcodeLink_"+coords).style.display = "inline";
				}else{
					coords = this.id.replace("qualifier_","")
					document.getElementById("barcodeLink_"+coords).style.display = "none";
				}
			}

			}

		return theSelect

	}

function setSelectByText(selId,val){
	var i
	el = document.getElementById(selId)
	for (i=0; i<el.options.length; i++) {
		if (el.options[i].value == val) {
			el.selectedIndex = i;
		}
	}
}

function setSelectByValue(selId,val){
	var i
	el = document.getElementById(selId)
	for (i=0; i<el.options.length; i++) {
		if (el.options[i].value == val) {
			el.selectedIndex = i;
		}
	}
}

function buildSavedSearch(savedSearch){
	if(savedSearch[0]["fields"].length==0){
		return false;
	}
	var i,j
	for (i=0;i<savedSearch.length;i++ ){
		newGroup();
		if("contraction" in savedSearch[i]){
			setSelectByValue("contraction_"+i,savedSearch[i]["contraction"])
		}
		for (j=0;j<savedSearch[i]["fields"].length;j++ ){
			if (j>0){
				newCriteria(i);
				setSelectByValue("contraction_"+i+"_"+j,savedSearch[i]["fields"][j]["contraction"])
			}
			setSelectByText("field_"+i+"_"+j,savedSearch[i]["fields"][j]["field"])
			document.getElementById("field_"+i+"_"+j).onchange()
			setSelectByValue("qualifier_"+i+"_"+j,savedSearch[i]["fields"][j]["qualifier"])
			if (document.getElementById("value_"+i+"_"+j).options){
				setSelectByValue("value_"+i+"_"+j,savedSearch[i]["fields"][j]["value"])
			}else{
				document.getElementById("value_"+i+"_"+j).value = savedSearch[i]["fields"][j]["value"];
			}
		}
	}
}
