function getSorted(B, A) {
	var all = [];
	for (var i = 0; i < B.length; i++) {
	    all.push({ 'A': A[i], 'B': B[i] });
	}

	all.sort(function(a, b) {
		return a.A - b.A;
	});
	A = [];
	B = [];

	for (var i = 0; i < all.length; i++) {
	   A.push(all[i].A);
	   B.push(all[i].B);
	}
	return B;
}

numToLetter = ['','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK','AL','AM','AN','AO','AP','AQ','AR','AS','AT','AU','AV','AW','AX','AY','AZ']
function getNextLabel(){
	num = parseInt(document.getElementById("currLetter").value);
	num += 1;
	document.getElementById("currLetter").value = num;
	sendAutoSave("currLetter",num);
	letter = numToLetter[num];
	return document.getElementById("e_name").value.replace(/\s/g,"")+"-"+letter;
}

function getNumArray(str){
	if (str === null){
		return [];
	}
	arr = str.split(" ");
	for(var i=0;i<arr.length;i++){
		arr[i] = parseFloat(arr[i]);
	}
	return arr;
}

function getMaxX(node){
	max = 0;
	els = node.getElementsByTagName("*");
	for(var i=0;i<els.length;i++){
		el = els[i];
		if(el.getAttribute("BoundingBox")){
			arr = getNumArray(el.getAttribute("BoundingBox"));
			if (arr[0]>max){
				max = arr[0];
			}
			if (arr[2]>max){
				max = arr[2];
			}
		}
		if(el.getAttribute("p")){
			arr = getNumArray(el.getAttribute("p"));
			if (arr[0]>max){
				max = arr[0];
			}
		}
	}
	return max;
}

/**
 * Gets max x value of P attribute.
 * @param {any} node cdxml node containing P attrs
 */
function getMaxXPonly(node) {
	max = 0;
	els = node.getElementsByTagName("*");
	for (var i = 0; i < els.length; i++) {
		el = els[i];
		
		if (el.getAttribute("p")) {
			arr = getNumArray(el.getAttribute("p"));
			if (arr[0] > max) {
				max = arr[0];
			}
		}
	}
	return max;
}

/**
 * Gets min x coordinate value
 * @param {any} node cdxml node
 * @param {any} pOnly if set to true, exclues BoundingBox element attrs
 */
function getMinX(node, pOnly) {
	min = getMaxX(node, pOnly);
	els = node.getElementsByTagName("*");
	for (var i = 0; i < els.length; i++) {
		el = els[i];
		if (el.getAttribute("BoundingBox") && !pOnly) {
			arr = getNumArray(el.getAttribute("BoundingBox"));
			if (arr[0] < min) {
				min = arr[0];
			}
			if (arr[2] < min) {
				min = arr[2];
			}
		}
		if (el.getAttribute("p")) {
			arr = getNumArray(el.getAttribute("p"));
			if (arr[0] < min) {
				min = arr[0];
			}
		}
	}
	return min; 
}

/**
 * Gets max y coordinate value
 * @param {any} node cdxml node
 * @param {any} pOnly if set to true, exclues BoundingBox element attrs
 */
function getMaxY(node, pOnly) {
	max = 0;
	els = node.getElementsByTagName("*");
	for (var i = 0; i < els.length; i++) {
		el = els[i];
		if (el.getAttribute("BoundingBox") && !pOnly) {
			arr = getNumArray(el.getAttribute("BoundingBox"));
			if (arr[1] > max) {
				max = arr[1];
			}
			if (arr[3] > max) {
				max = arr[3];
			}
		}
		if (el.getAttribute("p")) {
			arr = getNumArray(el.getAttribute("p"));
			if (arr[1] > max) {
				max = arr[1];
			}
		}
	}
	return max;
}

/**
 * Gets min y coordinate value
 * @param {any} node cdxml node
 * @param {any} pOnly if set to true, exclues BoundingBox element attrs
 */
function getMinY(node, pOnly) {
	min = getMaxY(node, false);
	els = node.getElementsByTagName("*");
	for (var i = 0; i < els.length; i++) {
		el = els[i];
		if (el.getAttribute("BoundingBox") && !pOnly) {
			arr = getNumArray(el.getAttribute("BoundingBox"));
			if (arr[1] < min) {
				min = arr[1];
			}
			if (arr[3] < min) {
				min = arr[3];
			}
		}
		if (el.getAttribute("p")) {
			arr = getNumArray(el.getAttribute("p"));
			if (arr[1] < min) {
				min = arr[1];
			}
		}
	}
	return min;
}



function getMaxXList(items,mainXML){
	maxX = 0;
	for (var i=0;i<items.length;i++){
		thisMaxX = getMaxX(getElementByIdXML(mainXML,items[i]));
		if (thisMaxX>maxX){
			maxX = thisMaxX;
		}
	}
	return maxX;
}

function getBoundingBox(node){
	if(node === undefined){
		console.error("Bounding Box undefined");
	}
	else
	{
		if(node.getAttribute("BoundingBox")){
			arr = getNumArray(node.getAttribute("BoundingBox"));
			return arr;
		}else{
			return [];
		}
	}
}

/**
 * Subtracts xOffset and yOffset from x and y coordinates of select attributes
 * @param {any} node
 * @param {any} xOffset
 * @param {any} yOffset
 * @param {any} pOnly if set to true  - only works with P tag
 */
function trimNode(node, xOffset, yOffset, pOnly) {
	var i;
	var j;
	var els;

	if (!pOnly) {
		tagNames = ["p", "Head3D", "Tail3D", "Center3D", "MajorAxisEnd3D", "MinorAxisEnd3D"];
	}
	else {
		tagNames = ["p"];
    }
	
	els = node.getElementsByTagName("*");
	for (var i = 0; i < els.length; i++) {
		el = els[i];
		if (el.getAttribute("BoundingBox")) {

			if (el.tagName != "fragment" && !pOnly) {
				arr = getNumArray(el.getAttribute("BoundingBox"));
				arr[0] += xOffset;
				arr[1] += yOffset;
				arr[2] += xOffset;
				arr[3] += yOffset;
				for (var j = 0; j < arr.length; j++) {
					arr[j] = arr[j].toFixed(2);
				}
				el.setAttribute("BoundingBox", arr.join(" "));
			}
			
		}
		for (var k = 0; k < tagNames.length; k++) {
			if (el.getAttribute(tagNames[k])) {
				arr = getNumArray(el.getAttribute(tagNames[k]));
				arr[0] += xOffset;
				arr[1] += yOffset;
				for (var j = 0; j < arr.length; j++) {
					arr[j] = arr[j].toFixed(2);
				}
				el.setAttribute(tagNames[k], arr.join(" "));
			}
		}
	}
}

function offsetNode(node,xOffset,yOffset){
	var i;
	var j;
	var els;
	tagNames = ["p","Head3D","Tail3D","Center3D","MajorAxisEnd3D","MinorAxisEnd3D"];
	if(typeof node.getAttribute !== "unknown" && node.getAttribute){
		//this is because the root node is not included when searching tagnames(*)
		el = node;
		if(el.getAttribute("BoundingBox")){
			arr = getNumArray(el.getAttribute("BoundingBox"));
			arr[0] += xOffset;
			arr[1] += yOffset;
			arr[2] += xOffset;
			arr[3] += yOffset;
			for(var j=0;j<arr.length;j++){				
				arr[j] = arr[j].toFixed(2);				
			}
			el.setAttribute("BoundingBox",arr.join(" "));
		}
		for(var k=0;k<tagNames.length;k++){
			if(el.getAttribute(tagNames[k])){
				arr = getNumArray(el.getAttribute(tagNames[k]));
				arr[0] += xOffset;
				arr[1] += yOffset;
				for(var j=0;j<arr.length;j++){
					arr[j] = arr[j].toFixed(2);
				}
				el.setAttribute(tagNames[k],arr.join(" "));
			}
		}
	}
	els = node.getElementsByTagName("*");
	for(var i=0;i<els.length;i++){
		el = els[i];
		if(el.getAttribute("BoundingBox")){
			arr = getNumArray(el.getAttribute("BoundingBox"));
			arr[0] += xOffset;
			arr[1] += yOffset;
			arr[2] += xOffset;
			arr[3] += yOffset;
			for(var j=0;j<arr.length;j++){
				arr[j] = arr[j].toFixed(2);
			}
			el.setAttribute("BoundingBox",arr.join(" "));
		}
		for(var k=0;k<tagNames.length;k++){
			if(el.getAttribute(tagNames[k])){
				arr = getNumArray(el.getAttribute(tagNames[k]));
				arr[0] += xOffset;
				arr[1] += yOffset;
				for(var j=0;j<arr.length;j++){
					arr[j] = arr[j].toFixed(2);
				}
				el.setAttribute(tagNames[k],arr.join(" "));
			}
		}
	}
}

function increaseArrowLength(node,arrowLengthIncrease){
	arr = getNumArray(node.getAttribute("BoundingBox"));
	//arrow direction is defined bysequence of X-coordinates, so X1<X2 is not always true
	if (arr[2] > arr[0]) {
		arr[2] += arrowLengthIncrease;
	}
	else {
		arr[0] += arrowLengthIncrease;
    }
	for(var j=0;j<arr.length;j++){
		arr[j] = arr[j].toFixed(2);
	}
	node.setAttribute("BoundingBox",arr.join(" "));
	arr = getNumArray(node.getAttribute("Head3D"));
	arr[0] += arrowLengthIncrease;
	for(var j=0;j<arr.length;j++){
		arr[j] = arr[j].toFixed(2);
	}
	node.setAttribute("Head3D",arr.join(" "));
	arr = getNumArray(node.getAttribute("Center3D"));
	arr[0] += arrowLengthIncrease;
	for(var j=0;j<arr.length;j++){
		arr[j] = arr[j].toFixed(2);
	}
	node.setAttribute("Center3D",arr.join(" "));
}

function increaseArrowContainerLength(node,arrowLengthIncrease){
	arr = getNumArray(node.getAttribute("BoundingBox"));
	arr[0] += arrowLengthIncrease;
	for(var j=0;j<arr.length;j++){
		arr[j] = arr[j].toFixed(2);
	}
	node.setAttribute("BoundingBox",arr.join(" "));
}

function normalizeFragment(xml){
	if(xml.getElementsByTagName("group").length!=0){
		fragmentNode = xml.getElementsByTagName("group")[0];
	}else{
		fragmentNode = xml.getElementsByTagName("fragment")[0];
	}
	if(fragmentNode === undefined){
		console.error("Can not normalize Fragment");
		return [0,0];
	}
	fragmentBoundingBox = getNumArray(fragmentNode.getAttribute("BoundingBox"));	
	globalOffsetX = -1*fragmentBoundingBox[0];
	globalOffsetY = -1*fragmentBoundingBox[1];
	offsetNode(xml, globalOffsetX, globalOffsetY)

	//additional trim to remove whitespace around the molecule
	offsetX = -1 * getMinX(fragmentNode, true);
	offsetY = -1 * getMinY(fragmentNode, true);
	trimNode(fragmentNode, offsetX, offsetY, true);

	w = getMaxXPonly(fragmentNode) - getMinX(fragmentNode);
	h = getMaxY(fragmentNode, true) - getMinY(fragmentNode);

	
	return [w,h];
}

function getDims(xml){
	try{
		if(xml.getElementsByTagName("group").length!=0){
			fragmentNode = xml.getElementsByTagName("group")[0];
		}else if(xml.getElementsByTagName("fragment").length!=0){
			fragmentNode = xml.getElementsByTagName("fragment")[0];
		}
		else if (xml.nodeName == "arrow") {
			fragmentNode = xml;
        }
		fragmentBoundingBox = getNumArray(fragmentNode.getAttribute("BoundingBox"));
	}catch(err){
		fragmentBoundingBox = getNumArray(xml.getAttribute("BoundingBox"));
	}
	w = Math.abs(fragmentBoundingBox[2] - fragmentBoundingBox[0]);
	h = Math.abs(fragmentBoundingBox[3] - fragmentBoundingBox[1]);
	return [w,h];
}

function spaceBetween(xml,xml2){
	//space between right of first element and left of second element
	try{
		if(xml.getElementsByTagName("group").length!=0){
			fragmentNode = xml.getElementsByTagName("group")[0];
		}else if (xml.getElementsByTagName("fragment").length!=0){
			fragmentNode = xml.getElementsByTagName("fragment")[0];
		}
		bb1 = getNumArray(fragmentNode.getAttribute("BoundingBox"));
	}catch(err){
		bb1 = getNumArray(xml.getAttribute("BoundingBox"));
	}

	try{
		if(xml2.getElementsByTagName("group").length!=0){
			fragmentNode = xml2.getElementsByTagName("group")[0];
		}else if (xml2.getElementsByTagName("fragment").length!=0){
			fragmentNode = xml2.getElementsByTagName("fragment")[0];
		}
		bb2 = getNumArray(fragmentNode.getAttribute("BoundingBox"));
	}catch(err){
		bb2 = getNumArray(xml2.getAttribute("BoundingBox"));
	}
	return bb2[0]-bb1[2];
}

function spaceBetween2(xml,xml2){
	//space between right of first element and right of second element
	try{
		if(xml.getElementsByTagName("group").length!=0){
			fragmentNode = xml.getElementsByTagName("group")[0];
		}else if (xml.getElementsByTagName("fragment").length!=0){
			fragmentNode = xml.getElementsByTagName("fragment")[0];
		}
		bb1 = getNumArray(fragmentNode.getAttribute("BoundingBox"));
	}catch(err){
		bb1 = getNumArray(xml.getAttribute("BoundingBox"));
	}

	try{
		if(xml2.getElementsByTagName("group").length!=0){
			fragmentNode = xml2.getElementsByTagName("group")[0];
		}else if (xml2.getElementsByTagName("fragment").length!=0){
			fragmentNode = xml2.getElementsByTagName("fragment")[0];
		}
		bb2 = getNumArray(fragmentNode.getAttribute("BoundingBox"));
	}catch(err){
		bb2 = getNumArray(xml2.getAttribute("BoundingBox"));
	}
	return bb2[2]-bb1[2];
}

function myTrim(x) {
	if(x){
	    return x.replace(/^\s+|\s+$/gm,'');
	}else{
		return "";
	}
}

function theyExist(theArr){
	r = true;
	if(theArr.length==0){
		r = false;
	}else{
		if(theArr[0]==""){
			r = false;
		}
	}
	return r;
}

function insertFragment(loc,fragmentXML,mainXML,label){
	return new Promise(function(resolve, reject) {

		fragmentSidePadding = 10;
		fragmentBottomPadding = 20;
		fragmentXML = loadXML(fragmentXML);
		
		var fragmentToProcess = null;
		var groups = fragmentXML.getElementsByTagName("group");
		var fragments = fragmentXML.getElementsByTagName("fragment");

		console.log("found: ", groups.length, " groups");
		console.log("found: ", fragments.length, " fragments");
		
		if(groups.length > 0)
			fragmentToProcess = groups[0];
		else if(fragments.length > 0)
			fragmentToProcess = fragments[0];

		if(fragmentToProcess == null)
		{
			console.log("nothing to process... skipping");
			resolve({});
			return;
		}
		
		// The rest of this function relies on the target fragment being named fragmentXML;
		fragmentXML = loadXML(xmlToString(fragmentToProcess));
		 
		//set (top left?) coordinates to 0,0 get Fragment Dimensions
		wh = normalizeFragment(fragmentXML);
		fragmentWidth = wh[0];
		fragmentHeight = wh[1];

		console.log("fragmentWidth: " + fragmentWidth);
		console.log("fragmentHeight: " + fragmentHeight);

		//if there is nothing drawn yet in the xml make a blank xml with nothing in it
		if(mainXML == null || mainXML==""){
			mainXML = '<?xml version="1.0" encoding="UTF-8" ?><!DOCTYPE CDXML SYSTEM "http://www.cambridgesoft.com/xml/cdxml.dtd" ><CDXML CreationProgram="ChemDraw 16.0.1.4" Name="just an arrow.cdxml" BoundingBox="117.54 330.38 449.46 342.63" WindowPosition="0 0" WindowSize="0 1073741824" WindowIsZoomed="yes" FractionalWidths="yes" InterpretChemically="yes" ShowAtomQuery="yes" ShowAtomStereo="no" ShowAtomEnhancedStereo="yes" ShowAtomNumber="no" ShowResidueID="no" ShowBondQuery="yes" ShowBondRxn="yes" ShowBondStereo="no" ShowTerminalCarbonLabels="no" ShowNonTerminalCarbonLabels="no" HideImplicitHydrogens="no" Magnification="1333" LabelFont="3" LabelSize="10" LabelFace="96" CaptionFont="4" CaptionSize="12" HashSpacing="2.70" MarginWidth="2" LineWidth="1" BoldWidth="4" BondLength="30" BondSpacing="12" ChainAngle="120" LabelJustification="Auto" CaptionJustification="Left" AminoAcidTermini="HOH" ShowSequenceTermini="yes" ShowSequenceBonds="yes" ResidueWrapCount="40" ResidueBlockCount="10" ResidueZigZag="yes" NumberResidueBlocks="no" PrintMargins="36 36 36 36" MacPrintInfo="00030000025802580000000019081340FFA0FFA01968138C0367052803FC00020000025802580000000019081340000100640064000000010001010100000001270F000100010000000000000000000000000002001901900000000000600000000000000000000100000000000000000000000000000000" ChemPropName="" ChemPropFormula="Chemical Formula: " ChemPropExactMass="Exact Mass: " ChemPropMolWt="Molecular Weight: " ChemPropMOverZ="m/z: " ChemPropAnalysis="Elemental Analysis: " ChemPropBoilingPt="Boiling Point: " ChemPropMeltingPt="Melting Point: " ChemPropCritTemp="Critical Temp: " ChemPropCritPres="Critical Pres: " ChemPropCritVol="Critical Vol: " ChemPropGibbs="Gibbs Energy: " ChemPropLogP="Log P: " ChemPropMR="MR: " ChemPropHenry="Henry&apos;s Law: " ChemPropEForm="Heat of Form: " ChemProptPSA="tPSA: " ChemPropCLogP="CLogP: " ChemPropCMR="CMR: " ChemPropLogS="LogS: " ChemPropPKa="pKa: " ChemPropID="" color="0" bgcolor="1" RxnAutonumberStart="1" RxnAutonumberConditions="no" RxnAutonumberStyle="Roman" RxnAutonumberFormat="(#)"><colortable><color r="1" g="1" b="1"/><color r="0" g="0" b="0"/><color r="1" g="0" b="0"/><color r="1" g="1" b="0"/><color r="0" g="1" b="0"/><color r="0" g="1" b="1"/><color r="0" g="0" b="1"/><color r="1" g="0" b="1"/></colortable><fonttable><font id="3" charset="iso-8859-1" name="Arial"/><font id="4" charset="iso-8859-1" name="Times New Roman"/></fonttable><page id="8" BoundingBox="0 0 540 720" HeaderPosition="36" FooterPosition="36" PrintTrimMarks="yes" HeightPages="1" WidthPages="1"><graphic id="6" SupersededBy="9" BoundingBox="449.46 337.01 117.54 337.01" Z="3" GraphicType="Line" ArrowType="FullHead" HeadSize="2250"/><scheme  id="85" ><step  id="86"  ReactionStepReactants=""  ReactionStepProducts=""  ReactionStepArrows="6"  ReactionStepObjectsAboveArrow="" /></scheme><arrow id="9" BoundingBox="117.54 330.38 449.46 342.63" Z="3" FillType="None" ArrowheadHead="Full" ArrowheadType="Solid" HeadSize="2250" ArrowheadCenterSize="1969" ArrowheadWidth="563" Head3D="449.46 337.01 0" Tail3D="117.54 337.01 0" Center3D="508.22 505.51 0" MajorAxisEnd3D="840.14 505.51 0" MinorAxisEnd3D="508.22 837.43 0"/></page></CDXML>';
		}

		mainXML = loadXML(mainXML);
		if (mainXML.getElementsByTagName("step").length==1||1==1){// is reaction
			numFragments = mainXML.getElementsByTagName("fragment").length;
			
			if(mainXML.getElementsByTagName("step").length==1){
				//get ids of fragments to move
				step = mainXML.getElementsByTagName("step")[0];
				reactantIds = myTrim(step.getAttribute("ReactionStepReactants")).split(" ");
				reagentIds = myTrim(step.getAttribute("ReactionStepObjectsAboveArrow")).split(" ");
				productIds = myTrim(step.getAttribute("ReactionStepProducts")).split(" ");
				solventIds = myTrim(step.getAttribute("ReactionStepObjectsBelowArrow")).split(" ");
				arrowIds = myTrim(step.getAttribute("ReactionStepArrows")).split(" ");
			}else{
				if(mainXML.getElementsByTagName("arrow").length!=0){
					arrowIds = [mainXML.getElementsByTagName("arrow")[0].getAttribute("id")];
					arrowY = getBoundingBox(getElementByIdXML(mainXML,arrowIds[0]))[1];
					reactantIds = [];
					productIds = [];
					reagentIds = [];
					reagentXs = [];
					solventIds = [];
					solventXs = [];
					groupIds = [];
					els = mainXML.getElementsByTagName("fragment");
					els2 = [];
					for(var i=0;i<els.length;i++){
						if (els[i].parentNode.tagName=="page"){
							els2.push(els[i])
						}
						if(els[i].parentNode.tagName=="group"){
							foundIt = false;
							for(var j=0;j<groupIds.length;j++){
								if(els[i].parentNode.getAttribute("id")==groupIds[j]){
									foundIt = true;
								}
							}
							if(!foundIt){
								els2.push(els[i].parentNode);
								groupIds.push(els[i].parentNode.getAttribute("id"));
							}
						}
					}
					els = els2;
					for (var i=0;i<els.length;i++){
						bb = getBoundingBox(els[i]);
						if(bb[1]>arrowY){
							solventIds.push(els[i].getAttribute("id"));
							solventXs.push(bb[0]);
						}
						if(bb[1]<arrowY){
							reagentIds.push(els[i].getAttribute("id"));
							reagentXs.push(bb[0]);
						}
					}
					reagentIds = getSorted(reagentIds,reagentXs);
					solventIds = getSorted(solventIds,solventXs);
				}else{
					reactantIds = [];
					productIds = [];
					reagentIds = [];
					solventIds = [];
					reactantXs = [];
					groupIds = [];
					els = mainXML.getElementsByTagName("fragment");
					els2 = [];
					for(var i=0;i<els.length;i++){
						if (els[i].parentNode.tagName=="page"){
							els2.push(els[i])
						}
						if(els[i].parentNode.tagName=="group"){
							foundIt = false;
							for(var j=0;j<groupIds.length;j++){
								if(els[i].parentNode.getAttribute("id")==groupIds[j]){
									foundIt = true;
								}
							}
							if(!foundIt){
								els2.push(els[i].parentNode);
								groupIds.push(els[i].parentNode.getAttribute("id"));
							}
						}
					}
					els = els2;
					for (var i=0;i<els.length;i++){
						bb = getBoundingBox(els[i]);
						reactantIds.push(els[i].getAttribute("id"));
						reactantXs.push(bb[0]);
					}
					reactantIds = getSorted(reactantIds,reactantXs);
					arrowWidth = 100;
					bb = getBoundingBox(getElementByIdXML(mainXML,reactantIds[reactantIds.length-1]));
					graphicXML = '<graphic  id="100000"  SupersededBy="100001"  BoundingBox="375.12 120.75 256.5 120.75"  Z="1"  GraphicType="Line"  ArrowType="FullHead"  HeadSize="2250" />';
					schemeXML = '<scheme  id="100002" ><step  id="100003"  ReactionStepReactants=" '+reactantIds.join(" ")+'"  ReactionStepArrows=" 100001" /></scheme>';
					arrowXML = '<arrow  id="100001"  BoundingBox="'+bb[0].toFixed(2)+' '+bb[1].toFixed(2)+' '+(bb[0]+arrowWidth).toFixed(2)+' '+(bb[1]+10).toFixed(2)+'"  Z="1"  FillType="None"  ArrowheadHead="Full"  ArrowheadType="Solid"  HeadSize="2250"  ArrowheadCenterSize="1969"  ArrowheadWidth="563"  Head3D="'+(bb[0]+arrowWidth).toFixed(2)+' '+(bb[1]+5).toFixed(2)+' 0"  Tail3D="'+(bb[0]).toFixed(2)+' '+(bb[1]+5).toFixed(2)+' 0"  Center3D="503.37 181.13 0"  MajorAxisEnd3D="621.98 181.13 0"  MinorAxisEnd3D="503.37 299.74 0" />';
					graphicXML = loadXML(graphicXML);
					schemeXML = loadXML(schemeXML);
					arrowXML = loadXML(arrowXML);
					offsetNode(arrowXML,bb[2]-bb[0]+fragmentSidePadding,(bb[3]-bb[1])/2);
					mainXML.getElementsByTagName("page")[0].appendChild(graphicXML.documentElement);
					mainXML.getElementsByTagName("page")[0].appendChild(schemeXML.documentElement);
					mainXML.getElementsByTagName("page")[0].appendChild(arrowXML.documentElement);
					
					//updateLiveEditStructureData("mycdx", xmlToString(mainXML), "cdxml");
					//cd_putData("mycdx","text/xml",xmlToString(mainXML));
					//sendAutoSave("cdxml",cd_getData("mycdx","text/xml"));
					arrowIds = ["100001"];
					step = mainXML.getElementsByTagName("step")[0];
				}
			}

			//get arrow width
			var realArrowId;
			var arrowContainer;
			arrowIds.forEach(function(arrowid){
				realArrowId = arrowid;
				if(getElementByIdXML(mainXML,arrowid).getAttribute("SupersededBy")){
					realArrowId = getElementByIdXML(mainXML,arrowid).getAttribute("SupersededBy");
					arrowContainer = arrowid;
				}
			});
			
			arrowWidth = getDims(getElementByIdXML(mainXML,realArrowId))[0];
		
			//get space between last reactant and arrow
			if(theyExist(reactantIds)){
				lastReactant = getElementByIdXML(mainXML,reactantIds[reactantIds.length-1]);
				arrow = getElementByIdXML(mainXML,realArrowId);
				spaceBetweenReactantsAndArrow = spaceBetween(lastReactant,arrow);
			}

			//don't offset arrow if there is already enough space
			arrowOffsetAmount = 0;
			if(loc=="left"){
				if(theyExist(reactantIds)){
					if(spaceBetweenReactantsAndArrow<(fragmentWidth+(fragmentSidePadding*2))){
						arrowOffsetAmount = fragmentWidth+(fragmentSidePadding*2);
					}
				}
			}

			//offset products if necessary
			productOffsetAmount = 0;
			if(loc == "left" && arrowOffsetAmount!=0){
				productOffsetAmount = fragmentWidth+(fragmentSidePadding*2);
			}

			arrowLengthIncrease = 0;
			if(loc=="bottom"){
				if(theyExist(solventIds)){
					mx = getMaxXList(solventIds,mainXML);
					bb = getBoundingBox(getElementByIdXML(mainXML, realArrowId));
					//arrow direction is defined bysequence of X-coordinates, so X1<X2 is not always true
					arrowMx = bb[2]>bb[0]?bb[2]:bb[0];
					if(  arrowMx<(mx+fragmentWidth+(fragmentSidePadding*2)) ){
						arrowLengthIncrease = mx + (fragmentWidth+(fragmentSidePadding*2)) - arrowMx;
					}
				}else{
					if(arrowWidth<(fragmentWidth+(fragmentSidePadding*2))){
						arrowLengthIncrease = (fragmentWidth+(fragmentSidePadding*2)) - arrowWidth;
					}
				}
			}
			if(loc=="top"){
				if(theyExist(reagentIds)){
					mx = getMaxXList(reagentIds,mainXML);
					bb = getBoundingBox(getElementByIdXML(mainXML,realArrowId));
					//arrow direction is defined bysequence of X-coordinates, so X1<X2 is not always true
					arrowMx = bb[2] > bb[0] ? bb[2] : bb[0];
					if(  arrowMx<(mx+fragmentWidth+(fragmentSidePadding*2)) ){
						arrowLengthIncrease = mx + (fragmentWidth+(fragmentSidePadding*2)) - arrowMx;
					}
				}else{
					if(arrowWidth<(fragmentWidth+(fragmentSidePadding*2))){
						arrowLengthIncrease = (fragmentWidth+(fragmentSidePadding*2)) - arrowWidth;
					}
				}
			}
			//the products offset needs to be increased by the amount that we 
			//increased the size of the arrow
			productOffsetAmount += arrowLengthIncrease;

			if(arrowLengthIncrease){
				increaseArrowLength(getElementByIdXML(mainXML,realArrowId),arrowLengthIncrease);
				if(arrowContainer !== undefined){
					increaseArrowContainerLength(getElementByIdXML(mainXML,arrowContainer),arrowLengthIncrease);
				}
			}
			
			//offset each product by the right amount
			if(theyExist(productIds)){
				for(var i=0;i<productIds.length;i++ ){
					offsetNode(getElementByIdXML(mainXML,productIds[i]),productOffsetAmount,0);
				}
				prefixes = getExistingPrefixes("p");
				productCodes = [];
				for (var i=0;i<prefixes.length;i++){
					productCodes.push(document.getElementById(prefixes[i]+"_trivialName").value);
				}
				els = mainXML.getElementsByTagName("t");
				for (var i=0;i<els.length;i++){
					for (var j=0;j<productCodes.length;j++){
						if(els[i].getElementsByTagName("s")[0].childNodes[0].nodeValue==productCodes[j]){
							offsetNode(els[i],productOffsetAmount,0);
						}
					}
				}
			}
			
			//offset the arrow
			if(arrowOffsetAmount){
				//inside this if because offsetting an arrow by 0 moves it for some reason
				for(var i=0;i<arrowIds.length;i++ ){
					if(getElementByIdXML(mainXML,arrowIds[i]).getAttribute("SupersededBy")){
						offsetNode(getElementByIdXML(mainXML,getElementByIdXML(mainXML,arrowIds[i]).getAttribute("SupersededBy")),fragmentWidth+(fragmentSidePadding*2),0);				
						offsetNode(getElementByIdXML(mainXML,arrowIds[i]),arrowOffsetAmount,0);
					}else{
						offsetNode(getElementByIdXML(mainXML,arrowIds[i]),arrowOffsetAmount,0);
					}
				}
				if(theyExist(solventIds)){
					for(var i=0;i<solventIds.length;i++){
						offsetNode(getElementByIdXML(mainXML,solventIds[i]),arrowOffsetAmount,0);
					}
				}
				if(theyExist(reagentIds)){
					for(var i=0;i<reagentIds.length;i++){
						offsetNode(getElementByIdXML(mainXML,reagentIds[i]),arrowOffsetAmount,0);
					}
				}
			}		


			//get coords for new item
			if(loc=="left"){
				idTagName = "ReactionStepReactants";
				if(theyExist(reactantIds)){
					lastReactantId = reactantIds[reactantIds.length-1];
					xOffset = getMaxX(getElementByIdXML(mainXML,lastReactantId));
					bb = getBoundingBox(getElementByIdXML(mainXML,lastReactantId));
					if(bb[2]-bb[0]<11*6){
						xOffset += 11*6-(bb[2]-bb[0])
					}
					yOffset = bb[1] + ((bb[3] - bb[1])/2) - fragmentHeight/2;
				}else{
					bb = getBoundingBox(getElementByIdXML(mainXML,realArrowId));
					xOffset = bb[0]-fragmentSidePadding*2-fragmentWidth;
					yOffset = bb[1]-fragmentHeight/2
				}
			}
			if(loc=="top"){
				idTagName = "ReactionStepObjectsAboveArrow";
				if(theyExist(reagentIds)){
					xOffset = getMaxXList(reagentIds,mainXML);
					lastReagentId = reagentIds[reagentIds.length-1];
					bb = getBoundingBox(getElementByIdXML(mainXML,lastReagentId));
					if(bb[2]-bb[0]<11*6){
						xOffset += 11*6-(bb[2]-bb[0]);
					}
				}else{
					bb = getBoundingBox(getElementByIdXML(mainXML, realArrowId));
					//arrow direction is defined bysequence of X-coordinates, so X1<X2 is not always true
					xOffset = bb[0]<bb[2]?bb[0]:bb[2];
				}
				bb = getBoundingBox(getElementByIdXML(mainXML,realArrowId));
				yOffset = bb[1]-fragmentHeight-fragmentBottomPadding;
			}
			if(loc=="bottom"){
				idTagName = "ReactionStepObjectsBelowArrow";
				if(theyExist(solventIds)){
					xOffset = getMaxXList(solventIds,mainXML)
					lastSolventId = solventIds[solventIds.length-1];
					bb = getBoundingBox(getElementByIdXML(mainXML,lastSolventId));
					if(bb[2]-bb[0]<11*6){
						xOffset += 11*6-(bb[2]-bb[0])
					}
				}else{
					bb = getBoundingBox(getElementByIdXML(mainXML, realArrowId));
					//arrow direction is defined bysequence of X-coordinates, so X1<X2 is not always true
					xOffset = bb[0] < bb[2] ? bb[0] : bb[2];
				}
				bb = getBoundingBox(getElementByIdXML(mainXML,realArrowId));
				yOffset = bb[3]+fragmentBottomPadding;
			}
			//add new fragment to cdxml
			offsetNode(fragmentXML,xOffset+fragmentSidePadding,yOffset);
			newFragmentId = 1000*(numFragments+1);
			if(mainXML.getElementsByTagName("step").length==1){
				if(step.getAttribute(idTagName)){
					step.setAttribute(idTagName,step.getAttribute(idTagName)+" "+newFragmentId);
				}else{
					step.setAttribute(idTagName,newFragmentId);
				}
			}

			fragmentXML.documentElement.setAttribute("id",newFragmentId);

			mainXML.getElementsByTagName("page")[0].appendChild(fragmentXML.documentElement);
			//if(label){
				//drawLabel(label,newFragmentId,mainXML);
			//}
			//document.getElementById("testArea").value = xmlToString(fragmentXML.documentElement)
			
			updateLiveEditStructureData("mycdx", xmlToString(mainXML), "cdxml");

			//cd_putData("mycdx","text/xml",xmlToString(mainXML));
			//sendAutoSave("cdxml",cd_getData("mycdx","text/xml"));
			resolve({'fragmentId':newFragmentId, 'reactionData':xmlToString(mainXML), 'reactionFormat':'cdxml', 'reactionElement':'mycdx'});
			return;
		}else{
			numFragments = mainXML.getElementsByTagName("fragment").length;
			offsetNode(fragmentXML,(fragmentWidth+(fragmentSidePadding*2))*numFragments,0);
			fragmentId = 1000*(numFragments+1);
			fragmentXML.documentElement.setAttribute("id",fragmentId);
			mainXML.getElementsByTagName("page")[0].appendChild(fragmentXML.documentElement);
			arrowXML = '<graphic id="70000" SupersededBy="280000" BoundingBox="375.12 120.75 256.5 120.75"  Z="10"  GraphicType="Line"  ArrowType="FullHead"  HeadSize="2250" /><scheme  id="29" ><step  id="300000"  ReactionStepReactants=" '+fragmentId+'"  ReactionStepArrows=" 70000" /></scheme><arrow  id="280000"  BoundingBox="256.5 116.62 375.12 124.13"  Z="1"  FillType="None"  ArrowheadHead="Full"  ArrowheadType="Solid"  HeadSize="2250"  ArrowheadCenterSize="1969"  ArrowheadWidth="563"  Head3D="375.12 120.75 0"  Tail3D="256.5 120.75 0"  Center3D="503.37 181.13 0"  MajorAxisEnd3D="621.98 181.13 0"  MinorAxisEnd3D="503.37 299.74 0" />';
			mainXML.getElementsByTagName("page")[0].appendChild(loadXML(arrowXML).documentElement);
			//if(label){
				//drawLabel(label,fragmentId,mainXML);
			//}

			updateLiveEditStructureData("mycdx", xmlToString(mainXML), "cdxml");

			//cd_putData("mycdx","text/xml",xmlToString(mainXML));
			//sendAutoSave("cdxml",cd_getData("mycdx","text/xml"));
			resolve({});
			return;
		}
	});
}

function drawLabel(label,fragmentId,mainXML){
	var bb;
	numFragments = mainXML.getElementsByTagName("fragment").length;
	fragmentXML = getElementByIdXML(mainXML,fragmentId);
	fragmentWidth = getDims(fragmentXML)[0]
	bb = getBoundingBox(fragmentXML);
	labelX = bb[0]+(fragmentWidth/2) -(label.length*6/2)+5;
	labelY = getBoundingBox(fragmentXML)[3]+15;
	labelXML = 	'<t id="'+(numFragments*1000-1)+'" p="'+(labelX).toFixed(2)+' '+(labelY).toFixed(2)+'" BoundingBox="'+(labelX).toFixed(2)+' '+(labelY).toFixed(2)+' '+(labelX + label.length*6).toFixed(2)+' '+(labelY+12).toFixed(2)+'" Z="107" Warning="This label has conflicting or unassignable charges." LineHeight="auto"><s font="3" size="10" face="1">'+label+'</s></t>'
	labelXML = loadXML(labelXML);
	mainXML.getElementsByTagName("page")[0].appendChild(labelXML.documentElement);
	return false;
}

function arrowSpace(fragmentId,mainXML){
	fragmentXML = getElementByIdXML(mainXML,fragmentId);
	arrowIds = [mainXML.getElementsByTagName("arrow")[0].getAttribute("id")];
	arrowY = getBoundingBox(getElementByIdXML(mainXML,arrowIds[0]))[1];
	fragmentY = getBoundingBox(fragmentXML)[3];
	if(arrowY-fragmentY<20){
		offsetNode(fragmentXML,0,-1*(20-(arrowY-fragmentY)))
	}
}

function getExistingPrefixes(prefix){
	var r = [];
	for (var i=0;i<30 ;i++ ){
		if (document.getElementById(prefix+i+"_body")){
			r.push(prefix+i)
		}
	}
	return r;
}

function getExistingPrefixesList(L){
	var r = [];
	for(var i=0;i<L.length;i++){
		x = getExistingPrefixes(L[i]);
		for(var j=0;j<x.length;j++){
			r.push(x[j]);
		}
	}
	return r;
}

function getFragmentIds(L){
	var r = [];
	for(var i=0;i<L.length;i++){
		r.push(document.getElementById(L[i]+"_fragmentId").value);
	}
	return r;
}

function inList(item,L){
	flag = false;
	for(var i=0;i<L.length;i++){
		if(L[i]==item){
			flag = true;
		}
	}
	return flag;
}

function getMolType(fragmentId,mainXML){
	if(mainXML.getElementsByTagName("step").length==1){
		step = mainXML.getElementsByTagName("step")[0];
		reactantIds = myTrim(step.getAttribute("ReactionStepReactants")).split(" ");
		//change for reagent swap
		reagentIds = myTrim(step.getAttribute("ReactionStepObjectsAboveArrow")).split(" ");
		productIds = myTrim(step.getAttribute("ReactionStepProducts")).split(" ");
		//change for reagent swap		
		solventIds = myTrim(step.getAttribute("ReactionStepObjectsBelowArrow")).split(" ");
		if(inList(fragmentId,reactantIds)){
			return "reactant";
		}
		if(inList(fragmentId,reagentIds)){
			return "reagent";
		}
		if(inList(fragmentId,productIds)){
			return "product";
		}
		if(inList(fragmentId,solventIds)){
			return "solvent";
		}
	}else{
		if(mainXML.getElementsByTagName("arrow").length!=0){
			arrowIds = [mainXML.getElementsByTagName("arrow")[0].getAttribute("id")];
			arrowBB = getBoundingBox(getElementByIdXML(mainXML,arrowIds[0]));
			bb = getBoundingBox(getElementByIdXML(mainXML,fragmentId));
			if(bb[0]<arrowBB[0]){
				return "reactant";
			}
			if(bb[0]>arrowBB[2]){
				return "product";
			}
			if(bb[0]>arrowBB[0]&&bb[1]<arrowBB[1]){
				//change for reagent swap
				return "reagent";
			}
			if(bb[0]>arrowBB[0]&&bb[1]>arrowBB[1]){
				//change for reagent swap
				return "solvent";
			}
		}else{
			return "reactant";
		}
	}
}

//remove doc type for 14
cdxStart = '<?xml version="1.0" encoding="UTF-8" ?><CDXML><page>';
cdxEnd = '</page></CDXML>';
molUpdatePrefix = "";
molUpdateCdxml = "";
firstRunForSave = true;
hasMadeInvChanges = false;
isForSign = false;
overrideSaveForChemdrawInsert = false;

var inventoryAddArguments = {};
var inventoryDataChanged = false;
var inventoryAddCallback = undefined;

// Huge hack because inventory integration is so fucked up and I don't have time to rewrite it right now
var inventoryExistingMassToUseFromGrid = undefined;
var inventoryExistingVolumeToUseFromGrid = undefined;

function validateBarcodes()
{
	var validateBarcodesPromise = new Promise(function(resolve, reject) {
		getChemistryEditorChemicalStructure("mycdx",false).then(function(mainXML){
			if(mainXML==""){
				blankCdxmlStart = '<?xml version="1.0" encoding="UTF-8" ?><!DOCTYPE CDXML SYSTEM "http://www.cambridgesoft.com/xml/cdxml.dtd" ><CDXML CreationProgram="ChemDraw 12.0.2.1076" Name="Untitled Document" BoundingBox="0 0 0 0" WindowPosition="0 0" WindowSize="0 0" FractionalWidths="yes" InterpretChemically="yes" ShowAtomQuery="yes" ShowAtomStereo="no" ShowAtomEnhancedStereo="yes" ShowAtomNumber="no" ShowBondQuery="yes" ShowBondRxn="yes" ShowBondStereo="no" ShowTerminalCarbonLabels="no" ShowNonTerminalCarbonLabels="no" HideImplicitHydrogens="no" LabelFont="3" LabelSize="10" LabelFace="96" CaptionFont="3" CaptionSize="10" HashSpacing="2.5" MarginWidth="1.6" LineWidth="0.6" BoldWidth="2" BondLength="14.4" BondSpacing="18" ChainAngle="120" LabelJustification="Auto" CaptionJustification="Left" AminoAcidTermini="HOH" ShowSequenceTermini="yes" ShowSequenceBonds="yes" PrintMargins="36 36 36 36" MacPrintInfo="0003000001200120000000000B6608A0FF84FF880BE309180367052703FC0002000001200120000000000B6608A0000100640064000000010001010100000001270F000100010000000000000000000000000002001901900000000000600000000000000000000100000000000000000000000000000000" color="0" bgcolor="1"><colortable><color r="1" g="1" b="1"/><color r="0" g="0" b="0"/><color r="1" g="0" b="0"/><color r="1" g="1" b="0"/><color r="0" g="1" b="0"/><color r="0" g="1" b="1"/><color r="0" g="0" b="1"/><color r="1" g="0" b="1"/></colortable><fonttable><font id="3" charset="iso-8859-1" name="Arial"/></fonttable><page id="8" BoundingBox="0 0 645 719.75" HeaderPosition="36" FooterPosition="36" PrintTrimMarks="yes" HeightPages="1" WidthPages="1">';
				blankCdxmlEnd = '</page></CDXML>';
				mainXML = blankCdxmlStart + blankCdxmlEnd;
			}
			mainXML = loadXML(mainXML);
			
			// Make sure everything in the diagram has an Inventory barcode associated with it.
			var allPrefixes = getExistingPrefixesList(["r","rg","s","p"]);
			
			for(var i=0;i<allPrefixes.length;i++){
				thisPrefix = allPrefixes[i];
				var elem = document.getElementById(thisPrefix+"_inventoryItems");
				
				if(elem == null || elem.value=="")
				{
					justLetter = thisPrefix.replace(/\d/g,"");
					molUpdatePrefix = thisPrefix;
	
					inventoryExistingMassToUseFromGrid = "0";
					inventoryExistingVolumeToUseFromGrid = null;
					
					if(justLetter != "p") {
						if(document.getElementById(thisPrefix+"_sampleMass").value != "") {
							inventoryExistingMassToUseFromGrid = document.getElementById(thisPrefix+"_sampleMass").value;
						}
						
						if(document.getElementById(thisPrefix+"_volume").value != "") {
							inventoryExistingVolumeToUseFromGrid = document.getElementById(thisPrefix+"_volume").value;
						}
					}
					else
					{
						if(document.getElementById(thisPrefix+"_measuredMass").value != "") {
							inventoryExistingMassToUseFromGrid = document.getElementById(thisPrefix+"_measuredMass").value;
						}
					}
					
					fragmentId = document.getElementById(thisPrefix+"_fragmentId").value;
					fragment = getElementByIdXML(mainXML,fragmentId);
					molUpdateCdxml = cdxStart+xmlToString(fragment)+cdxEnd;
					
					inventoryAddCallback = function() {
						//Sorry, I don't know when the promise is done
						setTimeout(function(){
							validateBarcodes();
						},1000);
					};
	
					if(justLetter == "p")
					{
						console.log("showing inventory add popup");
						showInventoryPopupAdd(thisPrefix);
					}
					else
					{
						console.log("showing inventory popup");
						showInventoryPopup(false);
					}
	
					inventoryDataChanged = true;
	
					return false;
				}
			}
	
			inventoryAddCallback = undefined;
			inventoryExistingMassToUseFromGrid = undefined;
			inventoryExistingVolumeToUseFromGrid = undefined;
			
			resolve(true);
		});
	})
	.then(function() {
		return(reconcileInventoryAmounts());
	});
}

function reconcileInventoryAmounts()
{
	return new Promise(function(resolve, reject) {
		$.ajax({
		  async:false,
		  method: "POST",
		  url: "/arxlab/experiments/ajax/do/reconcileInventoryAmounts.asp",
		  data: { experimentType:inventoryAddArguments['expType'],experimentId:inventoryAddArguments['expId'] }	})
		.done(function(response) {
			console.log("inventory containers reconciled");
			
			if(inventoryDataChanged)
			{
				showPopup('savingDiv');
				oldrevnum = experimentJSON["thisRevisionNumber"];
				experimentSubmit(false,false,false,true)
				.then(function(retval) {				
					console.log("experiment saved");
					redirectToSignPDF(parseInt(oldrevnum) + 1);
				});
			}
			else
			{
				redirectToSignPDF(experimentJSON["thisRevisionNumber"]);
			}
			
			resolve(true);
		})
		.fail(function() {
			console.log("inventory reconciliation failed");
			swal("There was an error with Inventory reconciliation. Please try again.")
			reject(false);
		})
		.always(function() {
			inventoryDataChanged = false;
		});
	});
}

function redirectToSignPDF(revNumber)
{
	if(inventoryAddArguments['useSafeSigning'] == "True")
	{
		var newPage = inventoryAddArguments['mainAppPath']+"/experiments/makePDFVersion.asp?experimentId="+experimentId+"&experimentType="+experimentType+"&revisionNumber="+revNumber+"&makeSafeVersion=false&fromSign=true";
		console.log("redirecting to ", newPage);
		window.location = newPage;
	}
	else if(inventoryAddArguments['useSso'] == "True")
	{
		checkForEmptyRequiredFields(inventoryAddArguments['expType'],'ssoSignDiv');
	}
	else
	{
		checkForEmptyRequiredFields(inventoryAddArguments['expType'],'signDiv');
	}
}

function getElementByIdXML(the_node,the_id){
	node_tags = the_node.getElementsByTagName('*');
	for (i=0;i<node_tags.length;i++){
		if (node_tags.item(i).getAttributeNode('id')){
			if (node_tags.item(i).getAttributeNode('id').value == the_id.toString()){
				return node_tags.item(i); 
			}
		}
	}
}