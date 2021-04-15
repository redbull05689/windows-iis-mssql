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
		document.getElementById("fields").value = L.join();

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
					f = el.options[el.selectedIndex].text;
					qEl = document.getElementById("qualifier_"+i+"_"+j);
					q = qEl.options[qEl.selectedIndex].value;
					vEl = document.getElementById("value_"+i+"_"+j);
					if (vEl.options){
						v = vEl.options[vEl.selectedIndex].value;
					}else{
						v = vEl.value;
					}
					D = {"field":f,"qualifier":q,"value":v}
					if (j>0){
						cEl = document.getElementById("contraction_"+i+"_"+j);
						c = cEl.options[cEl.selectedIndex].value;
						D["contraction"] = c;
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
		document.getElementById("savedSearch").value = JSON.stringify(savedSearch);

	}

	function newGroup()
	{
		document.getElementById("advancedSearchHolder").style.display = "block";
		document.getElementById("addNewGroup").style.display = "inline-block";
		document.getElementById("searchButton2").style.display = "inline-block";
		groups.push([])
		groupNumber = groups.length -1
		groupId = "groupHolder_"+groupNumber
		groupDiv = document.createElement("div")
		groupDiv.setAttribute("id",groupId)
		groupDiv.setAttribute("name",groupId)
		groupDiv.setAttribute("class","groupHolder")

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
			div = document.createElement("div");
			div.setAttribute("class","selectHolder");
			div.appendChild(contractionSelect);
			groupDiv.appendChild(div);
		}
		else
		{
			console.log(getFile(advancedSearchItemsFile))
			optionList = JSON.parse(getFile(advancedSearchItemsFile+"?rand="+Math.random()))
			for (i=0;i<optionList.length;i++)
			{
				theHidden = document.createElement("input")
				theHidden.setAttribute("type","hidden")
				theHidden.setAttribute("id","fieldType_"+i)
				theHidden.setAttribute("name","fieldType_"+i)
				theHidden.setAttribute("value",optionList[i][2])
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
		fieldDiv = document.createElement("div")
		fieldDiv.setAttribute("id",fieldId)
		fieldDiv.setAttribute("name",fieldId)
		fieldDiv.setAttribute("class","fieldHolder")

		fieldSelect = document.createElement("select")
		fieldSelect.setAttribute("id","field_"+groupNumber+"_"+fieldNumber)
		fieldSelect.setAttribute("name","field_"+groupNumber+"_"+fieldNumber)
		fieldSelect.onchange = function(){fieldChanged(this);}//setAttribute("onchange","fieldChanged(this);") qqq
		optionList = eval(getFile(advancedSearchItemsFile))
		firstReal = false;
		for (i=0;i<optionList.length;i++)
		{
			theOption = document.createElement("option")
			//theText = document.createTextNode(optionList[i][1])
			//theOption.appendChild(theText)
			theOption.innerHTML = optionList[i][1]
			theOption.setAttribute("value",optionList[i][0])
			if (optionList[i][2] !='none' && !firstReal)
			{
				firstNonNoneFieldIndex = i;
				firstReal = true;
			}
			fieldSelect.appendChild(theOption)

			if (firstLoad)
			{
				if (optionList[i].length > 3)
				{
					k = []
					l = []
					selectList = optionList[i][3]
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
			theSpan.setAttribute("class","paren")
			//Tyler Style
			//theText = document.createTextNode("(")
			//theSpan.appendChild(theText)
			document.getElementById("groupHolder_"+groupNumber).appendChild(theSpan)

			

			theSpan = document.createElement("span")
			theSpan.setAttribute("class","paren")
			theSpan.setAttribute("id","endParen_"+groupNumber)
			theSpan.setAttribute("name","endParen_"+groupNumber)
			//Tyler Style
			//theText = document.createTextNode(")")
			//theSpan.appendChild(theText)

			//theA = document.createElement("a")
			//theImg = document.createElement("img")
			//theImg.src = "/arxlab/images/add.gif"
			//theImg.setAttribute("title","Add Field")
			//theA.appendChild(theImg)
			//theA.onclick = function(){newCriteria(groupNumber)}

			//theA2 = document.createElement("a")
			//theImg = document.createElement("img")
			//theImg.src = "/arxlab/images/delete.gif"
			//theImg.setAttribute("title","Remove Group")
			//theA2.appendChild(theImg)
			//theA2.onclick = (function(groupNumber){
			//	return function(){removeGroup(groupNumber)}
			//})(groupNumber);

			wrapDiv = document.createElement("div");
			wrapDiv.setAttribute("class","fieldHolder fieldHolderBottomOfGroup")
			
			addDiv = document.createElement("div");
			addDiv.setAttribute("id","buttonAddToGroup");
			addDiv.setAttribute("class","buttonAddToGroup");
			a = document.createElement("a");
			a.setAttribute("class","buttonAddToGroupIcon");
			a.innerHTML = "+";
			a.onclick = function(){newCriteria(groupNumber)};
			addDiv.appendChild(a);
			a = document.createElement("a");
			a.setAttribute("class","buttonAddToGroupText");
			a.innerHTML = "Add a field";
			a.onclick = function(){newCriteria(groupNumber)};
			addDiv.appendChild(a);
			
			wrapDiv.appendChild(addDiv);

			removeDiv = document.createElement("div");
			removeDiv.setAttribute("id","buttonRemoveThisGroup");
			removeDiv.setAttribute("class","buttonRemoveThisGroup");
			a = document.createElement("a");
			a.setAttribute("class","buttonRemoveThisGroupText");
			a.innerHTML = "Remove this group";
			a.onclick = (function(groupNumber){
				return function(){removeGroup(groupNumber)}
			})(groupNumber);
			removeDiv.appendChild(a);
			a = document.createElement("a");
			a.setAttribute("class","buttonRemoveThisGroupIcon");
			a.innerHTML = "-";
			a.onclick = (function(groupNumber){
				return function(){removeGroup(groupNumber)}
			})(groupNumber);
			removeDiv.appendChild(a);
			
			wrapDiv.appendChild(removeDiv);

			theDiv = document.createElement("div")
			theDiv.setAttribute("id","endParenHolder_"+groupNumber)
			theDiv.setAttribute("name","endParenHolder_"+groupNumber)
			theDiv.setAttribute("class","endParenHolder")
			//theDiv.appendChild(theA)
			theDiv.appendChild(wrapDiv);
			theDiv.appendChild(theSpan)

			document.getElementById("groupHolder_"+groupNumber).appendChild(theDiv)
		}

		ep = document.getElementById("endParenHolder_"+groupNumber)

		if (!isFirstField)
		{
			contractionSelect = getContractionSelect()
			contractionSelect.setAttribute("id","contraction_"+groupNumber+"_"+fieldNumber)
			contractionSelect.setAttribute("name","contraction_"+groupNumber+"_"+fieldNumber)
			div = document.createElement("div");
			div.setAttribute("class","selectHolder");
			div.appendChild(contractionSelect);
			//gh.insertBefore(contractionSelect,ep)
			gh.insertBefore(div,ep)
		}

		//gh.insertBefore(fieldSelect,ep)
		fieldSelect.selectedIndex = firstNonNoneFieldIndex
		fieldDiv.appendChild(fieldSelect)

		thisType = optionList[firstNonNoneFieldIndex][2]
		if (optionList[firstNonNoneFieldIndex].length > 3){thisType = "custom_select"}

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
				valueObject.style.maxWidth="300px";
			}else{
			valueObject = getValueBox(groupNumber,fieldNumber)}

		//gh.insertBefore(valueText,ep)
		fieldDiv.appendChild(valueObject)

		theA = document.createElement("a")
		theA.setAttribute("id","barcodeLink_"+groupNumber+"_"+fieldNumber)
		theA.setAttribute("name","barcodeLink_"+groupNumber+"_"+fieldNumber)
		theA.onclick = function(){getBarcodes("value_"+groupNumber+"_"+fieldNumber)}
		theImg = document.createElement("img")
		theImg.src = "/arxlab/images/barcode.gif"
		theImg.setAttribute("title","Enter Barcodes")
		theA.style.display = "none";
		theA.appendChild(theImg)
		fieldDiv.appendChild(theA)

		//theA = document.createElement("a")
		//theA.setAttribute("id","removeFieldLink_"+groupNumber+"_"+fieldNumber)
		//theA.setAttribute("name","removeFieldLink_"+groupNumber+"_"+fieldNumber)
		//theImg = document.createElement("img")
		//theImg.src = "/arxlab/images/delete.gif"
		//theImg.setAttribute("title","Remove Field")
		//theA.appendChild(theImg)
		removeButton = document.createElement("div");
		removeButton.setAttribute("id","removeFieldLink_"+groupNumber+"_"+fieldNumber);
		removeButton.setAttribute("name","removeFieldLink_"+groupNumber+"_"+fieldNumber);
		removeButton.setAttribute("class","removeButton");
		removeButton.innerHTML = "-";
		removeButton.onclick = (function(groupNumber,fieldNumber){
			return function(){removeCriteria(groupNumber,fieldNumber)}
		})(groupNumber,fieldNumber);
		//gh.insertBefore(theA,ep)
		//fieldDiv.appendChild(theA)

		gh.insertBefore(removeButton,ep)
		gh.insertBefore(fieldDiv,removeButton)
		groups[groupNumber].push(L)
	}

	function fieldChanged(el)
	{
		thisName = el.options[el.selectedIndex].value
		groupNumber = el.id.replace(/field_/,"").split("_")[0]
		fieldNumber = el.id.replace(/field_/,"").split("_")[1]

		isSelect = document.getElementById("isSelect_"+el.selectedIndex)
		document.getElementById("value_"+groupNumber+"_"+fieldNumber).parentNode.removeChild(document.getElementById("value_"+groupNumber+"_"+fieldNumber))

		if (thisName == "salt"){
			valueObject = getSaltSelect(groupNumber,fieldNumber)
		}else{
			if (thisName == "groupId" || thisName == "projectId")
			{
				if (thisName == "groupId"){
					valueObject = getFieldGroupSelect(groupNumber,fieldNumber)
				}
				if (thisName == "projectId"){
					valueObject = getProjectSelect(groupNumber,fieldNumber)
				}
			}else{
				if (isSelect)
				{
					valueObject = getCustomSelect(groupNumber,fieldNumber,el.selectedIndex)
				}else{
				valueObject = getValueBox(groupNumber,fieldNumber)}
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
			document.getElementById("value_"+groupNumber+"_"+fieldNumber).onclick = function(){dt.select(this,'dummyA','MM/dd/yyyy');}
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

	function getSaltSelect(groupNumber,fieldNumber)
	{
		optionList = eval(getFile(advancedSearchSaltsFile))
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

	function getProjectSelect(groupNumber,fieldNumber)
	{
		optionList = eval(getFile(advancedSearchProjectsFile))
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

		if (thisType != 'text' && thisType != 'long_text' && thisType != 'drop_down' && thisType != 'custom_select')
		{
			theOption = document.createElement("option")
			theText = document.createTextNode("<")
			if (thisType=='date'){theText = document.createTextNode("Before")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","lt")
			theSelect.appendChild(theOption)

			theOption = document.createElement("option")
			theText = document.createTextNode("<=")
			if (thisType=='date'){theText = document.createTextNode("Before or on")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","lte")
			theSelect.appendChild(theOption)

			theOption = document.createElement("option")
			theText = document.createTextNode(">")
			if (thisType=='date'){theText = document.createTextNode("After")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","gt")
			theSelect.appendChild(theOption)

			theOption = document.createElement("option")
			theText = document.createTextNode(">=")
			if (thisType=='date'){theText = document.createTextNode("On or after")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","gte")
			theSelect.appendChild(theOption)
		}

		if (thisType != 'long_text'){
			theOption = document.createElement("option")
			if (thisType == 'custom_select'){theText = document.createTextNode("Is")}
			else{theText = document.createTextNode("Equals")}
			if (thisType=='date'){theText = document.createTextNode("On")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","eq")
			theSelect.appendChild(theOption)
		
			theOption = document.createElement("option")
			if (thisType == 'custom_select'){theText = document.createTextNode("Is Not")}
			else{theText = document.createTextNode("Not Equals")}
			if (thisType=='date'){theText = document.createTextNode("Not on")}
			theOption.appendChild(theText)
			theOption.setAttribute("value","neq")
			theSelect.appendChild(theOption)
		}

		if (thisType == 'text' || thisType == 'long_text' || thisType == 'drop_down')
		{
			theOption = document.createElement("option")
			theText = document.createTextNode("Contains")
			theOption.appendChild(theText)
			theOption.setAttribute("value","like")
			theSelect.appendChild(theOption)

			theOption = document.createElement("option")
			theText = document.createTextNode("Doesn't Contain")
			theOption.appendChild(theText)
			theOption.setAttribute("value","not_like")
			theSelect.appendChild(theOption)

			theOption = document.createElement("option")
			theText = document.createTextNode("In List")
			theOption.appendChild(theText)
			theOption.setAttribute("value","in")
			theSelect.appendChild(theOption)

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
		if (el.options[i].text == val) {
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
	if(savedSearch.length > 0 && savedSearch[0]["fields"].length==0){
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
