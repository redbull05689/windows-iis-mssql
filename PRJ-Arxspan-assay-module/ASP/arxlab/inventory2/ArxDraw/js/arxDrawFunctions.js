/** Updating the history for UNDO REDO **/
function updateModifications(savehistory, val) {
    if (savehistory === true) {
        state.push(val);
    }
}

function updateModificationsCanvas2(savehistory, val) {
    if (savehistory === true) {
        stateCanvas2.push(val);
    }
}

/** Updating the canvas with UNDO and REDO **/
function undoRedoCanvasUpdate(canvasState, c){
    console.log("Clicked UNDO: "+canvasState+", --"+c);
    var canvasUpdate = canvasState.split("&"); 
    var undoVal = canvasUpdate[0].split("#"); 
    
    if (undoVal[0] == "reDraw") { // "reDraw"+"#"+startId+"#"+endId+"#"+updatedHelmArr+"#"+helmArrPos+"#"+ty+"#"+iLeft+"#"+a+"#"+b+"#"+r
        canvas.clear();
        canvas2.clear();
        drawBackground();
        //drawNucleotides(startId,endId,helmArr, helmCounter, type,left)
        a = parseInt(undoVal[7]);
        b = parseInt(undoVal[8]);
        r = parseInt(undoVal[9]);
        		
        if (undoVal[3] && undoVal[3].constructor != Array) { /* array is converted into a string when its joined to a string */
            var mList = undoVal[3].split(",");
            var helmArr = [];
            for(var m = 0; m < mList.length ; m++){
                helmArr.push(mList[m]);
            }
        }
        var pL = helmArr[undoVal[4] - 1].split("-")[1];

		if (c == "canvas"){
			drawNucleotides(undoVal[1], undoVal[2], undoVal[3], undoVal[4], undoVal[5], undoVal[6]);
			wrapCanvasText(startId2, endId2, pL, 1, undoVal[3], undoVal[4], undoVal[5], false);
		}
		else {
            if (endId < pL.length) {
                drawNucleotides(startId, pL.length, undoVal[3], undoVal[4], undoVal[5], undoVal[6]);
            }
            else {
                drawNucleotides(startId, endId, undoVal[3], undoVal[4], undoVal[5], undoVal[6]);
            }
			
			wrapCanvasText(undoVal[1], undoVal[2], pL, 1, undoVal[3], undoVal[4], undoVal[5], false);
		}
    }
    console.log("Canvas Update: "+canvasUpdate[1]);
    if (canvasUpdate[1] != 0) { // this._activeObject.id+"#"+this._activeObject.left+"#"+this._activeObject.top;
        var objects = canvas.getObjects();
        console.log("objMoveArr: "+objMoveArr);
        for (var k = 0; k < canvasUpdate[1]; k++) {
            var undoMove = objMoveArr[k].split("#");
            console.log("undoMove: "+undoMove);
            for (var i = 0; i < objects.length; i++) { 
                if( i == undoMove[0]){
                    console.log( "item to move: "+i );
                    objects[i].setLeft( parseInt(undoMove[1]) );
                    objects[i].setTop( parseInt(undoMove[2]) );
                    objects[i].setCoords();
                    canvas.renderAll();
                    joinAttachedLines( undoMove[0], canvas.item(undoMove[0]).item(0).attachPoints );
                    //return;
                }
            }
        }
        
    }
    canvas.renderAll();
}    

/** Toggle the display of complementary items **/
function toggleDisplayComplementary() {
    //For canvas2
    for (var j = 0; j < ribbonCompArray.length; j++) {
        console.log(canvas2.item(ribbonCompArray[j]-1).type);
        canvas2.item(ribbonCompArray[j] - 1).toggle("visible");
        //var visible = canvas2.item(ribbonCompArray[j]-1).visible;
    }
    canvas2.renderAll();
}

/** Toggle the canvas display from drawing view to ribbon view **/
var autoScroll = false;
function toggleScreen() {
    $("#arxD_mapViewCanvas").toggle();
    $("#arxD_sequenceViewCanvas").toggle();
	$("#arxD_mapViewControl").toggle();
	$("#sequenceviewcontrol").toggle();
	
    if (document.getElementById("arxD_sequenceViewCanvas").style.display == 'block') {
        console.log("Updating the scroll bar");
        autoScroll = true;
        $("#arxD_wrapper").mCustomScrollbar("update");
        $("#arxD_wrapper").mCustomScrollbar("scrollTo",draggerTop);
    }
       
    //Check for the blobs
    if ($('#imageDialog').length){
        $('#imageDialog').remove();
    }
    else if ($('#featureDetails').length){
        $('#featureDetails').remove();
    }
}


/** Validating the peptides **/
function isValidPeptide(p, objPeptide) {
    var validPeptide = 1;
    for (var j = 0; j < objPeptide.length; j++) {
        if (p.toUpperCase() == objPeptide[j].Symbol) {
            validPeptide = 1;
            break;
        }
        else {
            validPeptide = 0;
        }
    }
    return validPeptide;
}

/** Validating the nucleotides **/
function isValidNucleotide(p, objNucleotide) {
    var validNucleotide = 1;
    for (var j = 0; j < objNucleotide.length; j++) {
        if (p.toUpperCase() == objNucleotide[j].Symbol) {
            validNucleotide = 1;
            break;
        }
        else {
            validNucleotide = 0;
        }
    }
    // "T" & "U" can't stay together
    return validNucleotide;
}

/** Finding the item numbers related to the monomer - used to change/update the monomer **/
function compArray(id, i , p){
    var complementary = [];
    if (i < p-1) {
        complementary.push(id + 0);
        complementary.push(id + 2);
        complementary.push(id + 9);
        complementary.push(id + 4);
        complementary.push(id + 6);
        complementary.push(id + 10);
    }
    else if (i == (p - 1)){
        complementary.push(id + 0);
        complementary.push(id + 2);
        complementary.push(id + 4);
        complementary.push(id + 6);
    }
    //console.log("complementary: "+complementary);
   return complementary;
}

function reverse(s) {
    for (var i = s.length - 1, o = ''; i >= 0; o += s[i--]) { }
    return o;
}

function getComplementaryStr(hStr) {
    var s = "";
    for (var x = 0 ; x < hStr.length ; x++) {
        if (hStr[x] == "A") {
            s = s + "T";
        }
        else if (hStr[x] == "C") {
            s = s + "G";
        }
        else if (hStr[x] == "G") {
            s = s + "C";
        }
        else if (hStr[x] == "T") {
            s = s + "A";
        }
        else if (hStr[x] == "\n") {
            s = s + "\n";
        }
        else if (hStr[x] == String.fromCharCode(8201)) {
            s = s + String.fromCharCode(8201);
        }
    }
    return s;
}


/** Map restricted enzymes in ribbon view **/

var objRestEnz = JSON.parse(restrictedEnzymes);
function mapRestrictedEnzymes(mList){
    //console.log("inside mapRestrictedEnzymes: "+mList);
    var reArray = [];
    
    for(var i = 0; i < objRestEnz.length; i++) {
        var obj = objRestEnz[i];
        mapRE(obj.Sequence, obj.Enzyme, mList, reArray, i, obj.Cut, obj.CutType, obj.CutPosition);
    }
    console.log("reArray length: "+reArray.length);
    return reArray;
}

function mapRE(sequence, enzyme, mList, reArray, i, cut, cutType, cutPosition) {
    var startIndex = 0;
    var seqLen = sequence.length;
    var index;
    while ((index = mList.indexOf(sequence, startIndex)) > -1) {
        startIndex = index + seqLen;
        var overLap = 1;
        if (i > 1) {
            for (var j = 0; j <reArray.length ; j++) {
                var overLapPos = reArray[j]['overLap'];
                var startPos = reArray[j]['startPos'];
                var endPos = reArray[j]['endPos'];
                if (index > startPos && index < endPos) {
                    if (overLap < (parseInt(overLapPos) + 1)) {
                       overLap = parseInt(overLapPos) + 1; 
                    }
                }
                if (startIndex > startPos && startIndex < endPos) {
                    if (overLap < (parseInt(overLapPos) + 1)) {
                       overLap = parseInt(overLapPos) + 1; 
                    }
                }
            }
        }
        var reArr = { 'startPos' : index, 'endPos' : startIndex, 'enzyme' : enzyme, 'sequence' : sequence, 'overLap' : overLap, 'cut' : cut,  'cutType' : cutType,  'cutPosition' : cutPosition };
        reArray.push(reArr);
    }
}

/** Display the restricted enzyme mapping on the canvas Sequence View **/
//function displayREMapping(mappingArray, words, startId2, endId2, a, b, fontSize, lineBreak, itemsBtwRow){
function displayREMapping(mappingArray, words, a, b, fontSize, lineBreak, itemsBtwRow){
    console.log("displayREMapping - inside display mapping: "+startId2+", "+ endId2+", "+ mappingArray.length);
    //[1816-1822#Test#ATTAAG#1#CCC^GGG#blunt]
    //console.log("displayREMapping: "+mappingArray);
    for (var j = 0; j <mappingArray.length ; j++){
        var startPos = mappingArray[j]['startPos'];
        var endPos = mappingArray[j]['endPos'];
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        
        if ( (getTheStartRow == startId2 || getTheStartRow >= startId2) && getTheStartRow < endId2 ){
            
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var enzyme = mappingArray[j]['enzyme'];
                var sequence = mappingArray[j]['sequence'];
                var getTheEndPos = getTheStartPos + sequence.length;
                
                var cutStartPos = mappingArray[j]['cut'].indexOf("^");
                var cutEndPos = mappingArray[j]['cut'].length - cutStartPos - 1;
                var cutType = mappingArray[j]['cutType'];
                
                var x1 = offsetArray[getTheStartPos - 1];
                var x2 = offsetArray[getTheEndPos - 1];
                var y1 = lineBreak[getTheStartRow - startId2];
                var n =  mappingArray[j]['overLap'];
				
                var mappingInfo = getTheStartRow+"#"+getTheStartRow+"#"+getTheStartPos+"#"+getTheEndPos+"#"+getTheStartRow+"-"+cutStartPos+"#"+getTheStartRow+"-"+cutEndPos+"#"+cutType+"#"+lineBreak+"#"+itemsBtwRow;
                
                drawMapping(x1, y1, x2, y1, a, b, enzyme, n, mappingInfo);
            }
            else { // The enzyme sequence broken between two lines
            
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = 120;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                var enzyme = mappingArray[j]['enzyme'];
                
                var cutStartPos = mappingArray[j]['cut'].indexOf("^");
                var cutEndPos = mappingArray[j]['cut'].length - cutStartPos - 1;
                var cutEndPos1;
                
                if (parseInt(cutStartPos) <= (seqBreak1 - getTheStartPos) ) {
                    var cutStartRow = parseInt(getTheStartRow);
                }
                else{
                    var cutStartRow = parseInt(getTheEndRow);
                    cutStartPos = cutStartPos - (120 - getTheStartPos);
                }
                if (parseInt(cutEndPos) <= (seqBreak1 - getTheStartPos) ) {
                    var cutEndRow = parseInt(getTheStartRow);
                }
                else{
                    var cutEndRow = parseInt(getTheEndRow);
                    cutEndPos1 = cutEndPos - cutStartPos - (120 - (getTheStartPos+cutStartPos));
                }
                
                var cutType = mappingArray[j]['cutType'];
                
                var x1 = offsetArray[getTheStartPos - 1];
                var x2 = offsetArray[parseInt(words)];
                var x3 = offsetArray[0];
                var x4 = offsetArray[getTheEndPos - 1];
                var y1 = lineBreak[getTheStartRow - startId2];
                var y2 = lineBreak[getTheEndRow - startId2];
                var n =  mappingArray[j]['overLap'];
                var mappingInfo = getTheStartRow+ "#" +getTheEndRow+ "#" +getTheStartPos+ "#" +getTheEndPos+ "#" +cutStartRow+ "-" +cutStartPos+ "#" +cutEndRow+ "-" +cutEndPos1+ "#" +cutType+ "#" +lineBreak+ "#" +itemsBtwRow;
                
                drawBreakMapping(x1, x2, x3, x4, y1, y2, a, b, enzyme, n, mappingInfo);
            }
        }
    }
}

/** Finding the offsets of each char in IText **/
function makeArrayOffsets(){
    var ctx = canvas2.getContext();

    text1 = ("TTGATGTTCTGCAGACACCTGCAGGGCAGGGAAACTTGCTGGCAGCTCCTCCCAGCAGATCCCATTCGCATCTCCCAATCCTTGATAGATACAAGATCCACATCGTCCTTGTTTACTGTGG");
    text1 = text1.split("");
    var newText = "";
    var offsetArray1= [80];
    
    var text = new fabric.Text("", { 
        left: 80, 
        top: 80, 
        fontFamily: 'Courier',
        fontSize: 16
    });
    canvas2.add(text);
    var bound = canvas2.item(0).getBoundingRect();
    
    offsetArray1.push(canvas2.item(0).left + bound.width);
    canvas2.item(0).remove();
        
    for (var q = 0; q < text1.length; q++){
        a = 80;
        b = 80;
        newText = newText + text1[q];
        
        var text = new fabric.Text(newText, { 
            left: a , 
            top: b , 
            fontFamily: 'Courier',
            fontSize: 16
        });
        canvas2.add(text);
        
        canvas2.renderAll();
        
        var bound = canvas2.item(0).getBoundingRect();
        
        offsetArray1.push(canvas2.item(0).left + bound.width);
        
        canvas2.item(0).remove();
    }
    console.log("offsetArray1: "+offsetArray1);
    return offsetArray1;
}

function jsonArraySearch(fStrJSON, seg) { //searching for CDS with the same feature segment as a gene
    var segFound = false;
    for (var n = 0; n < fStrJSON.length; n++) {
        //console.log(n);
        if(fStrJSON[n]['feature'] == "CDS" && fStrJSON[n]['segment'] == seg) {
            segFound = true;
            break;
        }
    }
    return segFound;
}

function highLightString(i, s, e, c) {
console.log("highlight: "+i+", "+s+", "+e);
    if (i >= 0) {
		var ss = "";
		for (var p = s+1; p <= e; p++){
			ss = ss + '"'+p+'": {"textBackgroundColor": "'+c+'"}';
			if(p < e){
				ss = ss + ",";
			}
		}
		return (i+"#"+ss);
    }
}

function findFMAOverlap(object) {
    for (var l = 1; l< object.length; l++){
        var fStart = object[l -1]['startPos'];
        var fEnd = object[l -1]['endPos'];
        var s = object[l]['startPos'];
        var e = object[l]['endPos'];
        
        if ((fStart <= s && fEnd >= e) || (fStart >= s && fEnd <= e) || (fStart >= s && fEnd >= e && fStart <= e)|| (fStart <= s && fEnd >= s && fEnd <= e)){
            object[l]['overLap'] = parseInt(object[l-1]['overLap']) + 1 ;
        }
        else {
            object[l]['overLap'] = parseInt(object[l-1]['overLap']) ;
        }
    }
}

function findFMAOverlap_mapView(object) {
    var overLap = 1;
    //First row assign the overlap = 1 l< object.length
    if (object.length > 0) {
        object[0]['overLap'] = overLap;
        
        for (var l = 1; l< object.length; l++){
            var s = object[l]['startPos'];
            var e = object[l]['endPos'];
            var check = 0;
            
            for (var m = l-1; m >= 0; m--) {
                var fStart = object[m]['startPos'];
                var fEnd = object[m]['endPos'];
                
                if (parseInt(fEnd) > parseInt(s)) {
                    object[l]['overLap'] = object[m]['overLap'] + 1;
                    check = 1;
                }
                else if (parseInt(fEnd) < parseInt(s)) {
                    object[l]['overLap'] = object[m]['overLap'];
                }
                
                if (object[m]['overLap'] == 1 || check == 1) {
                    break;
                }
            }
        }
    }
}


function findFMAObjects(obj, key, val) {  //(featureMappingArray, "startRow", q)
    var objects = [];
   
    for (var i = 0; i < obj.length; i++) {
        if (obj[i][key] == val) {
           objects.push(obj[i]);
        }
    }
    
    objects.sort(sort_by('lengthOfFeature', true, parseInt));    
    findFMAOverlap(objects);
       
    return objects;
}

var sort_by = function(field, reverse, primer){

   var key = primer ? 
       function(x) {return primer(x[field])} : 
       function(x) {return x[field]};

   reverse = !reverse ? 1 : -1;

   return function (a, b) {
       return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
     } 
} 

function mapRE1(sequence, enzyme, mList, reArray, i, cut, cutType) {
    var startIndex = 0;
    var seqLen = sequence.length;
    var index;
    
    while ((index = mList.indexOf(sequence, startIndex)) > -1) {
        startIndex = index + seqLen;
        var overLap = 1;
        if (i > 1){
            for (var j = 0; j <reArray.length ; j++){
                var monomerPos = reArray[j].split("#")[0];
                var overLapPos = reArray[j].split("#")[3];
                var startPos = monomerPos.split("-")[0];
                var endPos = monomerPos.split("-")[1];
                if (index > startPos && index < endPos){
                    if (overLap < (parseInt(overLapPos) + 1)){
                       overLap = parseInt(overLapPos) + 1; 
                    }
                }
                if (startIndex > startPos && startIndex < endPos){
                    if (overLap < (parseInt(overLapPos) + 1)){
                       overLap = parseInt(overLapPos) + 1; 
                    }
                }
            }
        }
        reArray.push(index+"-"+startIndex+"#"+enzyme+"#"+sequence+"#"+overLap+"#"+cut+"#"+cutType);
    }
}


function getRandomColor() {
    var letters = '0123456789ABCDEF'.split('');
    var color = '#';
    for (var i = 0; i < 6; i++ ) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

function showTranslations(id, subMenuId) {
    $('#'+id).is(':checked'); 
    arxD_showSubMenu();
	
    if (canvas2.getObjects().length > 0) {
        startSpinner();
		setTimeout(function(){
		    var text = canvas2.item(2).totalText;
            wrapCanvasText(startId2, endId2, text, 1, false);
		},35); 
    }
}

function findHeight(r, angle){ // triangle with 2 sides as r and third side as c with an angle 'angle'
    var c = Math.sqrt((2*r*r)*(1 + Math.cos(angle)));
    var s = (r + r + c)/2;
    var area = s * (s - r) * (s - r) * (s - c);
    var h = (2 * Math.sqrt(area))/r;
    return h;
}


function findCoordinates(a, b, r, angle1, zoom) {
    var t = (1.5 * 3.145)+((angle1 * 2 * 3.145)/360);
    var left1 = a + ((r + 10) * zoom * (Math.cos(t))); // Adding 10 to the radius because to draw the numbers outside the circle
    var top1 = (b * zoom) + ((r + 10) * zoom * (Math.sin(t)));
    return[left1, top1];
}

function showHideFeatures() {
	if ( $("#arxD_showHideFeatures").text() == 'Show Features' ) {
		$("#arxD_showHideFeatures").text('Hide Features');
	}
	else {
		$("#arxD_showHideFeatures").text('Show Features');
	}
	
	if (canvas2.getObjects().length > 0) {
		var text = canvas2.item(2).totalText;
		wrapCanvasText(startId2, endId2, text, 1, true);
	}
}

function showHideRE() {
    console.log("arxD_showHideRE: -"+$("#arxD_showHideRE").text()+"-" );
	if ( $("#arxD_showHideRE").text() == 'Show Enzymes' ) {
		$("#arxD_showHideRE").text('Hide Enzymes');
        totalBP = canvas4.item(0).item(1).text;
    }
	else {
		$("#arxD_showHideRE").text('Show Enzymes');
    }
    
    if (canvas2.getObjects().length > 0) {
        wrapCanvasText(startId2, endId2, result, 1, true);
    }
}

function arxD_checkLeftMenuTabs(show, id) {
    $("#arxD_EView").attr("style", "display: none");
    $("#arxD_FView").attr("style", "display: none");
    $('#arxD_MSLView').attr("style", "display: block");
    
    if ( show == 1 && $('#arxD_trans').is(":visible") && $('#arxD_amino').is(":visible") ) {
        $('#arxD_trans').toggle();
        $('#arxD_amino').toggle();
    }
    else if ( show == 2 && !$('#arxD_trans').is(":visible") && !$('#arxD_amino').is(":visible")) {
        $('#arxD_trans').toggle();
        $('#arxD_amino').toggle();
    }
    
    if (id == "arxD_mapView") {
        $('#arxD_mapView').addClass('active');
        $('#arxD_sequenceView').removeClass('active');
        $('#arxD_linearView').removeClass('active');
    } 
    else if (id == "arxD_sequenceView") {
        $('#arxD_sequenceView').addClass('active');
        if ( $('#arxD_mapView').length > 0 ) {
            $('#arxD_mapView').removeClass('active');
        }
        $('#arxD_linearView').removeClass('active');
    }
    else if (id == "arxD_linearView") {
        $('#arxD_linearView').addClass('active');
        $('#arxD_sequenceView').removeClass('active');
        if ( $('#arxD_mapView').length > 0 ) {
            console.log("M A P V I E W: "+ $('#arxD_mapView').length);
            $('#arxD_mapView').removeClass('active');
        }
    }
}

function arxD_showFeaturesTab() {
    //console.log("showFeaturesTab");
    $("#arxD_MSLView").attr("style", "display: none");
    $("#arxD_EView").attr("style", "display: none");
    $("#arxD_FView").attr("style", "display: block");
}

function arxD_showEnzymesTab() {
    //console.log("arxD_showEnzymesTab");
    $("#arxD_MSLView").attr("style", "display: none");
    $("#arxD_FView").attr("style", "display: none");
    $("#arxD_EView").attr("style", "display: block");
}

function ORF(allTranslations) {
    var orf1 = [];
    var orf2 = [];
    var orf3 = [];
    var orf4 = [];
    var orf5 = [];
    var orf6 = [];
    
    orf1 = findORF(allTranslations[0], 1);
    orf2 = findORF(allTranslations[1], 1);
    orf3 = findORF(allTranslations[2], 1);
    orf4 = findORF(allTranslations[3], 2);
    orf5 = findORF(allTranslations[4], 2);
    orf6 = findORF(allTranslations[5], 2);
    
    return [orf1, orf2, orf3, orf4, orf5, orf6];
}

function findORF(transArray, dir) {
    var startCodon = false;
    var orfJSON = [];
    
    if (dir == 1) {
        for (var i = 0; i < transArray.length; i++) {
            if (transArray[i][1] == 29 && !startCodon){
                startCodon = true;
                var orfStartPos = transArray[i][0];
            }
            
            if ((transArray[i][1] == 62 || transArray[i][1] == 63 || transArray[i][1] == 64) && startCodon){
                startCodon = false;
                if ((transArray[i][0] - orfStartPos) > 250) {
                    var orfDetails = { 'startPos' : orfStartPos, 'endPos' : transArray[i][0], 'basePairs' : (transArray[i][0] - orfStartPos) };
                    orfJSON.push(orfDetails);
                    //console.log("orfStartPos: "+orfStartPos +" , "+ transArray[i][0]);
                }
            }
        }
    }
    else {
        for (var i = transArray.length-1; i >= 0 ; i--) {
            if (transArray[i][1] == 29 && !startCodon){
                startCodon = true;
                var orfStartPos = transArray[i][0];
            }
            
            if ((transArray[i][1] == 62 || transArray[i][1] == 63 || transArray[i][1] == 64) && startCodon){
                startCodon = false;
                if ( (orfStartPos - transArray[i][0]) > 250 ) { // minimum length of orf set for 250
                    var orfDetails = { 'startPos' : transArray[i][0], 'endPos' : orfStartPos, 'basePairs' : (orfStartPos - transArray[i][0]) };
                    orfJSON.push(orfDetails);
                    //console.log("orfStartPos: "+orfStartPos +" , "+ transArray[i][0]);
                }
            }
        }
    }
    
    return(orfJSON);
}


var objAmenoAcid = JSON.parse(aminoAcidDescription);
function getAllAmenoAcidTranslations(tStringWithoutSpaces, wordsInALine){
    var plus1 = [], plus2 = [], plus3 = [], minus1 = [], minus2 = [], minus3 =[];
    
    var splitStr = tStringWithoutSpaces.split("");
    
    for (var i = 0; i < splitStr.length; i += 3) {
        var checkPlus1 = (splitStr[i]+splitStr[i+1]+splitStr[i+2]).toUpperCase();
        var checkMinus1 = reverse(getComplementaryStr(checkPlus1));
        var check1 = 0;
        var check2 = 0;
        //console.log(checkPlus1+" , "+getComplementaryStr(checkPlus1));
        for (var j = 0; j < objAmenoAcid.length; j++) {
            if (objAmenoAcid[j]['Codon'] == checkPlus1){
                plus1.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check1 = check1+1;
            }
            if (objAmenoAcid[j]['Codon'] == checkMinus1){
                minus1.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check2 = check2+1;
            }
            if (check1 == 1 && check2 == 1){
                break;
            }
        }
    }
    
    for (var i = 1; i < splitStr.length; i += 3) {
        var checkPlus2 = (splitStr[i]+splitStr[i+1]+splitStr[i+2]).toUpperCase();
        var checkMinus2 = reverse(getComplementaryStr(checkPlus2));
        var check1 = 0;
        var check2 = 0;
        
        for (var j = 0; j < objAmenoAcid.length; j++) {
            
            if (objAmenoAcid[j]['Codon'] == checkPlus2){
                plus2.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check1 = check1+1;
            }
            
            if (objAmenoAcid[j]['Codon'] == checkMinus2){
                minus2.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check2 = check2+1;
            }
            if (check1 == 1 && check2 == 1){
                break;
            }
        }
    }
    
    for (var i = 2; i < splitStr.length; i += 3) {
        var checkPlus3 = (splitStr[i]+splitStr[i+1]+splitStr[i+2]).toUpperCase();
        var checkMinus3 = reverse(getComplementaryStr(checkPlus3));
        var check1 = 0;
        var check2 = 0;
        
        for (var j = 0; j < objAmenoAcid.length; j++) {
            
            if (objAmenoAcid[j]['Codon'] == checkPlus3){
                plus3.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check1 = check1+1;
            }
            
            if (objAmenoAcid[j]['Codon'] == checkMinus3){
                minus3.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check2 = check2+1;
            }
            if (check1 == 1 && check2 == 1){
                break;
            }
        }
    }
    //console.log(plus1.length+", "+minus3.length+", "+minus2.length+", "+plus2.length+", "+plus3.length+", "+minus1.length);
    return [plus1, plus2, plus3, minus1, minus2, minus3];
}


function displayFeatures(fStrJSON, n) {  //3: "{ "feature" : "CDS", "segment" : "complement(11295..12017)", " /label" : "tnpA_5 CD", " /ApEinfo_revcolor" : "#b1ff67", " /ApEinfo_fwdcolor" : "#b1ff67"}"
    var tableHeader = "";
	var tableRow = "";
	var tableData = "";
    
    var table = document.createElement('table');
    table.setAttribute('id', 'features');
    table.setAttribute('class', 'table table-striped');
    var thead = document.createElement('thead');
    var tr = document.createElement('tr');
    var th = document.createElement('th');
	var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("No:"));
	th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Feature"));
	th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Location"));
	th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Size (bp)"));
	th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Color"));
	th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Direction"));
	th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Type"));
	th.appendChild(spanText);
    tr.appendChild(th);
    thead.appendChild(tr);
    table.appendChild(thead);
    var tbody = document.createElement('tbody');

	for (var i = 0; i < fStrJSON.length; i++) { //{"startPos":"217","endPos":"2200","featureName":"misc_feature","arrayConn":1,"overLap":1,"color":"#02E524","lengthOfFeature":1983,"direction":-1}
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        var text = i + 1;
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        var td = document.createElement('td');
        var text = fStrJSON[i]["featureName"];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        var td = document.createElement('td');
        var text = fStrJSON[i]["startPos"]+" .. " +fStrJSON[i]["endPos"];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        var td = document.createElement('td');
        var text = fStrJSON[i]['lengthOfFeature'];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "<div class='htmlColorBox' id='htmlColorBox' style='background-color:"+fStrJSON[i]['color']+"'></div>"; 
        tr.appendChild(td);
        
        var td = document.createElement('td');
        if (fStrJSON[i]['direction'] === -1){
            td.innerHTML = "<b>&#8594;</b>";
        }
        else {
            td.innerHTML = "<b>&#8592;</b>";
        }
        
        tr.appendChild(td);
        
        var td = document.createElement('td');
        var text = fStrJSON[i]["featureName"];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        tbody.appendChild(tr);
	}
    
	for (var j = i; j < n; j++) {
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        tbody.appendChild(tr);
    }
    
    table.appendChild(tbody);
    $('#arxD_FView').append(table);
}

function asc_sort(a, b){
    return ($(b).text()) < ($(a).text()) ? 1 : -1;    
}

$.extend({
    distinct : function(anArray) {
       var result = [];
       $.each(anArray, function(i,v){
           if ($.inArray(v, result) == -1) result.push(v);
       });
       return result;
    }
});

Array.prototype.unique = function() {
    var n = {},UniqueRE=[];
    for(var i = 0; i < REmappingArray.length; i++) 
    {
        if (!n[REmappingArray[i]['enzyme']]) 
        {
            n[REmappingArray[i]['enzyme']] = true; 
            UniqueRE.push(REmappingArray[i]['enzyme']); 
        }
    }
    return UniqueRE;
}

function displayEnzymes(REmappingArray, n) {
    var keyArr = [];
    
    //var UniqueRE= $.unique(REmappingArray.map(function (d) {
    //return d.enzyme;}));
    UniqueRE = REmappingArray.unique();
    
    for (var i = 0; i < UniqueRE.length; i ++) {
        var count = 0;
        var numberArr = [];
        for (var j = 0; j < REmappingArray.length; j ++) {
            if (UniqueRE[i] == REmappingArray[j]['enzyme']) {
                count = count + 1;
                numberArr.push(REmappingArray[j]['startPos']);
            }
            if (j == REmappingArray.length - 1) {
                var s = {'enzyme' : UniqueRE[i], 'count' : count, 'startPos' : numberArr};
                keyArr.push(s);
            }
        }
    }
    
    keyArr.sort(function(a, b){
        if(a.enzyme < b.enzyme) return -1;
        if(a.enzyme > b.enzyme) return 1;
        return 0;
    })
    
    var outerTable = document.createElement('table');
    outerTable.setAttribute('id', 'arxD_outerEnzymes');
    var outerTr = document.createElement('tr');
    var outerTd1 = document.createElement('td');
    
        var table = document.createElement('table');
        table.setAttribute('id', 'arxD_enzymesList');
        table.setAttribute('width', screen.availWidth*0.1);
            var tr = document.createElement('tr');
                var thead = document.createElement('thead');
                var th = document.createElement('th');
                    var spanText = document.createElement('span');
                    spanText.appendChild(document.createTextNode("Enzymes"));
                th.appendChild(spanText);
            tr.appendChild(th);
        
                var th = document.createElement('th');
                    var spanText = document.createElement('span');
                    spanText.appendChild(document.createTextNode("Sites"));
                th.appendChild(spanText);
            tr.appendChild(th);
        
        thead.appendChild(tr);
        table.appendChild(thead);
        
        var tbody = document.createElement('tbody');
        
        for (var i = 0; i < keyArr.length; i++) { //3: "{ "enzyme" : "CDS", "count" : 3, "startPos" : "2213, 2345, 7689" }"
            var tr = document.createElement('tr');   
            var td = document.createElement('td');
            var text = keyArr[i]["enzyme"];
            var spanText = document.createElement("span");
            spanText.appendChild(document.createTextNode(text));
            td.appendChild(spanText);
            tr.appendChild(td);
            
            var td = document.createElement('td');
            var text = keyArr[i]["count"];
            var spanText = document.createElement("span");
            spanText.appendChild(document.createTextNode(text));
            td.appendChild(spanText);
            tr.appendChild(td);
            
            tbody.appendChild(tr);
        }    
        
        for (var j = i; j < n; j++) {
            var tr = document.createElement('tr');   
            var td = document.createElement('td');
            td.innerHTML = "&nbsp;";
            tr.appendChild(td);
            
            var td = document.createElement('td');
            tr.appendChild(td);
            
            tbody.appendChild(tr);
        }
        
        table.appendChild(tbody);
    outerTd1.appendChild(table);
    outerTr.appendChild(outerTd1);
    
    var outerTd2 = document.createElement('td');
    
    
    var div = document.createElement('div');
    var ul = document.createElement('ul');
    ul.setAttribute('id', 'arxD_displayEnzymeTabs');
    var li = document.createElement('li');
    li.setAttribute('id', 'arxD_displayEnzymeLocTabs');
    li.setAttribute('class', 'active');
    li.innerHTML = "<a href='#' onclick='arxD_checkDisplayEnzymesTabs(2);'>Location</a>"; 
    ul.appendChild(li);
    var li = document.createElement('li');
    li.setAttribute('id', 'arxD_displayEnzymeLinesTabs');
    li.innerHTML = "<a href='#' onclick='arxD_checkDisplayEnzymesTabs(1);'>Lines</a>"; 
    ul.appendChild(li);
    div.appendChild(ul);
    
    
    var div1 = document.createElement('div');
    div1.setAttribute('id', 'arxD_enzymeDetails');
    
    var div2 = document.createElement('div');
    div2.setAttribute('id', 'arxD_enzymeLoc');
    
    var t1 = document.createElement('table');
    t1.setAttribute('id', 'arxD_enzymeLocTable');
    t1.setAttribute('width', screen.availWidth*0.9);
    //t1.setAttribute('border', '1');
    
    var t1body = document.createElement('tbody');
    
    for (var i = 0; i < keyArr.length; i++) { //3: "{ "enzyme" : "CDS", "count" : 3, "startPos" : "2213, 2345, 7689" }"
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        var text = keyArr[i]["startPos"];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        t1body.appendChild(tr);
    }
    
    for (var j = i; j < n; j++) {
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        t1body.appendChild(tr);
    }
    t1.appendChild(t1body);
    
    div2.appendChild(t1);
    
    var div3 = document.createElement('div');
    div3.setAttribute('id', 'arxD_enzymeLines');
    div3.style.display = 'none';
    
    var t2 = document.createElement('table');
    t2.setAttribute('id', 'arxD_enzymeLinesTable');
    t2.setAttribute('width', screen.availWidth*0.9);
    var t2body = document.createElement('tbody');
    
    for (var i = 0; i < keyArr.length; i++) { //3: "{ "enzyme" : "CDS", "count" : 3, "startPos" : "2213, 2345, 7689" }"
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        //draw lines
        prevX = 0;
        
        for (var j=0; j < keyArr[i]["startPos"].length; j++) {
            x = (keyArr[i]["startPos"][j] - prevX)*screen.availWidth*0.85/basePairs ;
            prevX = keyArr[i]["startPos"][j];
            x = x +"px;";
            td.innerHTML = td.innerHTML + "<div class='verticalLine' title='Pos: "+prevX+"' style='margin-left:"+x+"'>&nbsp;</div>"; 
        }
        tr.appendChild(td);
        
        t2body.appendChild(tr);
    }
    
    for (var j = i; j < n; j++) {
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        t2body.appendChild(tr);
    }
    t2.appendChild(t2body);
    
    div3.appendChild(t2);
    
    div1.appendChild(div2);
    div1.appendChild(div3);
    
    div.appendChild(div1);
    
    outerTd2.appendChild(div);
    outerTr.appendChild(outerTd2);
    
    outerTable.appendChild(outerTr);
    
    $('#arxD_EView').append(outerTable);
}

function arxD_checkDisplayEnzymesTabs(i) {
    if (i == 1) {
        $("#arxD_enzymeLines").attr("style", "display: block");
        $("#arxD_enzymeLoc").attr("style", "display: none");
        //Remove the class active
        $("#arxD_displayEnzymeLocTabs").removeClass("active");
        $("#arxD_displayEnzymeLinesTabs").addClass("active");
    }
    if (i == 2) {
        $("#arxD_enzymeLines").attr("style", "display: none");
        $("#arxD_enzymeLoc").attr("style", "display: block");
        $("#arxD_displayEnzymeLocTabs").addClass("active");
        $("#arxD_displayEnzymeLinesTabs").removeClass("active");
    }
}


function save() {
    console.log("fileName: "+fileName);
   
    if ( fileName != "" && fileName != "undefined" ) {
        var type = fileName.split(".")[1];
         console.log("Save: "+type);
        if (type == "sdf") {
            saveSDF();
        }
        else {
            saveToHelm();
        }
    }
    else {
        console.log("No file selected");
    }
}

function saveToHelm() { 
    var basePairString = result;
    var basePairList = basePairString.split("");
    
    var s3 = "RNA1"+"{";
    for (var j = 0; j < basePairList.length; j ++) {
        
        if (j == basePairList.length-1){
        s3 = s3+"R("+basePairList[j].toUpperCase()+")}";
        }
        else{
        s3 = s3+"R("+basePairList[j].toUpperCase()+")P."
        }
    }
        
    helmString = s3 +"$$$$";
    //console.log("HELM:"+helmString);
    d = new Date();
    fName = d.getMonth()+1+"-"+d.getDate()+"-"+d.getFullYear()+"-"+d.getHours()+'-'+d.getMinutes();
    var blob = new Blob([helmString], {type: "text/plain;charset=utf-8"});
    saveAs(blob, fName+".helm");
}


/** Populating the links from database in the right nav **/
function getUserFiles (){
    $.ajax({
        type: "POST",
        url: 'dbHelm.asp',
        data: 'send the user details',
        dataType: "json",
        success: function(response) {
            $('#arxD_rightNav').html(response.html);
            
            $("#arxD_rightNav").mCustomScrollbar( {
                axis:"yx",
                theme:"3d",
                scrollbarPosition:"inside",
            } );
        },
        error: function() {
            alert("error");
        }
    });
}

/** Sending the request to parse the data **/
function sendParseRequest(file) {
    var extension = "";
    var jsonData;
    
    if (!isNaN(file)) { 
        jsonData = {filename : "", fileID : file}; 
    }
    else {
        extension = file.split('.').pop().toLowerCase();
        jsonData = {filename : file, fileID : ""}; 
    }
    
	if(extension == 'sdf') {
		postUrl = "../SDEdit/sdfParser.py";
	}else {
		postUrl = "ajax.asp";
	}

	console.log("Sending request to process the file: "+file);
	startTime = new Date()/1000;
	$.ajax({
        type: "POST",
        url: postUrl,
        data: jsonData,
        dataType: 'json',
        success: function(response) {
            console.log("success"+ response);
            if (extension == 'sdf') {
                displayResponse(response.query);
            } else if (extension != "") { //Other file types like genbank and text files
				$('#arxD_display').show();
                
                var r = response.query;
                displayName = r[0]['name'];
                basePairs = r[0]['basePairs'];
                isPlasmid = r[0]['isPlasmid'];
                result = r[0]['result'];
                fStrJSON = r[0]['fStrJSON'];
                featureMappingArray = r[0]['featureMappingArray'];
                //allTranslations = r[0]['allTranslations'];
                //allORFs = r[0]['allORFs'];
                featuresInMapView = r[0]['featuresInMapView'];
                
                if (isPlasmid != true || isPlasmid != 1 || isPlasmid != "1") {
                   /* $("#arxD_displayTabs li:eq(0)").hide();
                    $('#arxD_mapView').remove();
                    $('#arxD_sequenceView').show(); */
                }
                
                console.log(r);
                console.log("featuresInMapView length: "+featuresInMapView.length);
                featuresInMapView.sort(sort_by('startPos', false, parseInt)); 
                findFMAOverlap_mapView(featuresInMapView);
                                
                wrapCanvasText(0, 20, result, 1, true);
                getUserFiles();
                
                $('#goToBasePair').val("");
                $('#basePairInfo').html( displayName + "&nbsp; &nbsp; &nbsp; &nbsp;" + basePairs +" bp" );
                $('#bases').html( basePairs );
                                
                allTranslations = getAllAmenoAcidTranslations(result, wordsInALine);
                allORFs = ORF(allTranslations);
                
                var noOfRows = Math.floor(window.innerHeight / 20); //20 is td height
                displayFeatures(featuresInMapView, noOfRows);
                displayEnzymes(REmappingArray, noOfRows);
            }
            else { // When the files are opened from right pannel
                clearcan();
                var r = response.query;
                displayName = r[0]['name'];
                basePairs = r[0]['basePairs'];
                isPlasmid = r[0]['isPlasmid'];
                result = r[0]['result'];
                fStrJSON = r[0]['fStrJSON'];
                featureMappingArray = r[0]['featureMappingArray'];
                featuresInMapView = r[0]['featuresInMapView'];
                
                featuresInMapView.sort(sort_by('startPos', false, parseInt)); 
                findFMAOverlap_mapView(featuresInMapView);
                
                if (isPlasmid != true || isPlasmid != 1) {
                    $('#mapViewLi').remove();
                    $('#arxD_mapViewCanvas').remove();
                }
                
                               
                wrapCanvasText(0, 20, result, 1, true);
                startId2 = 0;
                //Reset the zoom, rotation and scroll bars to default
                $('#R').bootstrapSlider("refresh");
                $('#Z').bootstrapSlider("refresh");
                $('#Z4').bootstrapSlider("refresh");
                $('#goToBasePair').val("");
                
                var bottomTop = (((document.getElementById('arxD_sequenceViewCanvas').style.height).split("px")[0]) * (startId2))/fText.length;
                var bottomTop1 = (((document.getElementById('arxD_sequenceViewCanvas').style.height).split("px")[0]) * (startId2))/fText.length;
                
                console.log("scroll bar: "+startId2+", "+bottomTop+", "+bottomTop1);
                document.getElementById('arxD_canvasPushDiv').style.height = parseInt(bottomTop1)+'px';
                $("#arxD_wrapperXY").mCustomScrollbar("update");
                $('#arxD_wrapperXY').mCustomScrollbar("scrollTo", (bottomTop));
                
                
                $('#basePairInfo').html( displayName + "&nbsp; &nbsp; &nbsp; &nbsp;" + basePairs );
                
                allTranslations = getAllAmenoAcidTranslations(result, wordsInALine);
                allORFs = ORF(allTranslations);
                
                var noOfRows = Math.floor(window.innerHeight / 20); //20 is td height
                displayFeatures(featuresInMapView, noOfRows);
                displayEnzymes(REmappingArray, noOfRows);
            }
        },
        error: function(xhr) {
            console.log("error"+xhr.responseText);
        }
    });
}

/** Upload the selected file to the server and send the request back to parse **/
function uploadFile(files) {
    var fileTypes = ['gb', 'helm', 'txt', 'sdf'];
    
    var extension = files[0].name.split('.').pop().toLowerCase();
     
    if (extension == 'gb' || extension == 'helm' || extension == 'sdf' || extension == 'txt') {
        console.log("extension: "+extension);
			var fd = new FormData();
			fd.append("fileToUpload", files[0]);
            $.ajax({
                type: "POST",
                url: 'upload.asp',
                data: fd,
				enctype: 'multipart/form-data',
				processData: false,
				contentType: false,
				dataType: 'json',
				success: function(response) {
                    dropzone.remove();
					// Now that file is successfully uploaded, send another ajax to parse the file
					console.log("success:" + JSON.stringify(response));
					console.log("Sending Parse request");
					sendParseRequest(files[0].name)
				},
                error: function() {
                    alert("error");
                }
            });
    }
    else {
        alert(files[0].name +" is not allowed!!");
        stopSpinner();
    }
}


function undo() {
    //console.log("Undo :"+document.getElementById('showRibbonView').checked)
    if (document.getElementById('showRibbonView').checked == false) {
        console.log(state);
        if (mods < state.length) {
            var H = parseInt(state.length - 2 - mods);
            //console.log("undo : "+mods+" "+state.length);
            //console.log(state[H]);
            if (H >= 0) {
                undoRedoCanvasUpdate(state[H],"canvas");
                mods += 1;
            }
        }
    }
    else {
        if (modsCanvas2 < stateCanvas2.length) {
            console.log(stateCanvas2);
            var H = parseInt(stateCanvas2.length - 2 - modsCanvas2);
            //console.log("undo : "+mods+" "+state.length);
            //console.log(state[H]);
            if (H >= 0) {
                undoRedoCanvasUpdate(stateCanvas2[H], "canvas2");
                modsCanvas2 += 1;
            }
        }
    }
    
}

function redo() {
    if (document.getElementById('showRibbonView').checked == false) {
        if (mods > 0) {
            var H = [state.length - 1 - mods + 1];
            if (H > 0) {
                undoRedoCanvasUpdate(state[H],"canvas");
                mods -= 1;
            }
        }
    }
    else {
        if (modsCanvas2 > 0) {
            var H = [stateCanvas2.length - 1 - modsCanvas2 + 1];
            if (H > 0) {
                undoRedoCanvasUpdate(stateCanvas2[H],"canvas2");
                modsCanvas2 -= 1;
            }
        }
    }
}

function clearcan() {
    
    helmArr = [];
    helmCounter = 0;
    compIdArr = [];
    objMoveArr = [];
    state = [];
    
    mods = 0;
    modsCanvas2 = 0;		
    canvas2.clear().renderAll();
    fText = [];
    drawCutArray = [];
    result = "";
    stateCanvas2 = [];
    featureMappingArray = [];
    FArray = [];
    REmappingArray = [];
    //r = 20;
    //document.getElementById("files").value = "";
    drawBackground();
    
    canvas3.clear().renderAll();
    isPlasmid = false;
    fArr = [];
    fStrJSON = [];
    fStr = "";
    featuresInMapView = [];
    bLW = [0]; // keep track of the spacing between the rows
    itemsBtwRow = [0]; // how many items present between each row
}

function gc(s, c) {
    var resultStr = result.slice(s,c).split("");
    var gcCount = 0;
    for (var i = 0; i < resultStr.length; i++) {
        if (resultStr[i] == 'g' || resultStr[i] == 'c') {
            gcCount = gcCount + 1;
        }
    }
    return ((gcCount * 100)/resultStr.length).toFixed(2);
}

function startSpinner() {
    console.log("S P I N N E R -- S T A R T E D");
    arxD_spinnerDiv.style.display = 'block';
    if(arxD_spinner == null) {
        arxD_spinner = new Spinner(opts).spin(arxD_spinnerDiv);
    } else {
        arxD_spinner.spin(arxD_spinnerDiv);
    }
}

function stopSpinner() {
    console.log("S P I N N E R -- S T O P");
    if (arxD_spinner != null) {
        arxD_spinner.stop(arxD_spinnerDiv);
        arxD_spinnerDiv.style.display = 'none'; 
    }
}

function addRemoveClassActive (id) {
    $("#"+id).parent().children("li.active").removeClass("active");
    $("#"+id).addClass("active");
}