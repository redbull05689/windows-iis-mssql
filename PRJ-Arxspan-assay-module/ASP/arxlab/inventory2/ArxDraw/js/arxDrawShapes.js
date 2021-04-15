//** ITEXT spacing **//
/*
fabric.util.object.extend(fabric.Text.prototype, {
    letterSpace: 2,
    _renderChars: function (method, ctx, chars, left, top) {
        if (!this.letterSpace) {
            ctx[method](chars, left, top);
            return;
        }
        var characters = String.prototype.split.call(chars, '');
     	if(this.textAlign == 'left'){
        	var charShift = 0;
            for (var i = 0; i < chars.length; i++) {
                if (i > 0) {
                    charShift += this.letterSpace + ctx.measureText(chars.charAt(i - 1)).width;
                }
                ctx[method](chars.charAt(i), left + charShift, top);
            }  
            
        } else if(this.textAlign == 'right'){
            characters.reverse();
            chars = characters.join('');
        	var charShift = 0;
            for (var i = 0; i < chars.length; i++) {
                if (i > 0) {
                    charShift += this.letterSpace + ctx.measureText(chars.charAt(i - 1)).width;
                }
                ctx[method](chars.charAt(i), left - charShift, top);
            }    
        } else if(this.textAlign == 'center'){
            var totalWidth = 0;
            for (var i = 0; i < characters.length; i++) {
                totalWidth += (ctx.measureText(characters[i]).width + this.letterSpace);
            }
            var currentPosition = left - (totalWidth / 2);
            
            var charShift = 0;
            for (var i = 0; i < chars.length; i++) {
                if (i > 0) {
                    charShift += this.letterSpace + ctx.measureText(chars.charAt(i - 1)).width;
                }
                ctx[method](chars.charAt(i), currentPosition + left + charShift, top);
            }    
        }
    },
    _getLineWidth: function (ctx, lineIndex) {
        var lineLength = this._textLines[lineIndex].length;
        var additionalSpaceSum = 0
        if (lineLength > 0) {
            additionalSpaceSum = this.letterSpace * (lineLength - 1);
        }
        this.__lineWidths[lineIndex] = ctx.measureText(this._textLines[lineIndex]).width + additionalSpaceSum;
        //console.log("line width: "+this.__lineWidths[lineIndex]);
        return this.__lineWidths[lineIndex];
    },
    _renderExtended: function (ctx) {
        this.clipTo && fabric.util.clipContext(this, ctx);
        this.extendedRender = true;
        this._renderTextBackground(ctx);
        this._renderText(ctx);
        this._renderTextDecoration(ctx);
        this.clipTo && ctx.restore();
    }
});
*/

//Arrays to hold the items on the canvas
var canvas2ItemArray = [];
var canvas3ItemArray = [];
var canvas4ItemArray = [];

/** with row numbers **/
function fabric_hDashedLine(x1, y1, x2, y2, visible, q, w) {
    var line = new fabric.Line([x1,y1,x2,y2], {
        stroke: 'black',
        strokeDashArray: [6, 6],
        strokeWidth: 1,
        visible: visible,
    });
    
    var t1 = (q+1).toString();
    var t2 = (q+1).toString();
    
    var text1 = new fabric.Text(t1, {
        fontSize: 10,
        fillStyle: 'blue',
        left: x1 - 25,
        top: y1 - 10,
        hasBorders: true,
        textAlign: 'right',
    });
    
    var text2 = new fabric.Text(t2, {
        fontSize: 10,
        fillStyle: 'blue',
        left: offsetArray[wordsInALine] + 25,
        top: y1 - 10,
        textAlign: 'left',
    });
     
    var name = new fabric.Group([ text1, line, text2], {
        originX: 'center',
        originY: 'center',
        hasControls: false,
        hasBorders: false,
        visible: visible,
        selectable: false,
    });
    
    canvas2.add(name);
}

/** Guide line with numbers **/
function fabric_guideLine(n, q, by) {
    var line = new fabric.Line([offsetArray[0], by + b, offsetArray[n], by + b], {
        stroke: 'green',
        strokeWidth: 1,
        selectable: false,
    });
    
    var group = new fabric.Group(); 
    group.add(line); 
    
    var value = ((q+1)*10 + q*(wordsInALine - 10));
    
    for (var j=10; j < n; j=j+10){
        var t = value+j-10;
        group.add(new fabric.Text(t.toString(), {
            fontSize: 8,
            fillStyle: 'blue',
            left: offsetArray[j-1],
            top: (b+3)+by,
            hasBorders: true,
            textAlign: 'right',
            backgroundColor: 'pink',
            selectable: false,
        }));
    }
    
    canvas2.add(group);
}    

/** Guide line with markings in between ameno acid translations **/
function fabric_guideLine2(n, q, offSet, tran) {
    var check = 0;
    if (tran == 6 || tran == 3) {
        var y = offSet + (3 * 15) + (1 * 10);
    }
    else if (tran == 1) {
        var y = offSet + (1 * 15) + (1 * 10);
    }
    else if (tran == -3) {
        var y = offSet ;
    }
    y = y - 20;
    
    var line1 = new fabric.Line([offsetArray[0], y, offsetArray[n], y], {
        stroke: 'green',
        strokeWidth: 1,
        selectable: false,
    });
    
    var line2 = new fabric.Line([offsetArray[0], y + 3, offsetArray[n], y + 3], {
        stroke: 'green',
        strokeWidth: 1,
        selectable: false,
    });
    
    if (tran == 1 || tran == 3 || tran == 6){
        var group = new fabric.Group(); 
        group.add(line1); 
        
        for (var j=0; j < n+1; j++){
            var y1 = y - 3;
            var y2 = y;
            
            if (check == 5) {
                y1 = y - 5;
            }
            else if (check == 10) {
                y1 = y - 7;
                check = 0;
            }
            else if (check == 0) {
                y1 = y - 7;
            }
            check = check + 1;
            
            group.add(new fabric.Line([offsetArray[j], y1, offsetArray[j], y2], {
                stroke: 'green',
                strokeWidth: 1,
                selectable: false,
            }));
        }
        
        canvas2.add(group);
    }
    
    if (tran == -3 || tran == 6){
        var group1 = new fabric.Group(); 
        group1.add(line2); 
        
        check = 0;
        for (var j=0; j < n+1; j++){
            var y1 = y + 3;
            var y2 = y + 6;
            
            if (check == 5) {
                y2 = y + 8;
            }
            else if (check == 10) {
                y2 = y + 10;
                check = 0;
            }
            else if (check == 0) {
                y2 = y + 10;
            }
            check = check + 1;
            group1.add(new fabric.Line([offsetArray[j], y1, offsetArray[j], y2], {
                stroke: 'green',
                strokeWidth: 1,
                selectable: false,
            }));
        }
        
        canvas2.add(group1);
    }
}    

function fabric_text(t,id,visible,a,b) {
	var nameOffset = new fabric.IText(t, { 
        id: id,
		fontFamily: 'Courier', 
		left: a, 
		top: b,
		fontSize: 16,
        visible: visible,
        selectable: true,
        perPixelTargetFind: true,
		fill: 'black'
	});
	canvas2.add(nameOffset);
}

function fabric_iText(t,id,visible,a,b,tText,fs) {
    var iText = new fabric.IText(t, { 
        id: id,
		fontFamily: 'Courier', 
		left: a, 
		top: b,
		fontSize: fs,
        visible: visible,
        selectable: true,
		fill: 'black'
	});
   
    //to add the custom variable to the IText
    fabric.IText.prototype.toObject = (function(toObject) {
        return function() {
            return fabric.util.object.extend(toObject.call(this), {
                totalText: this.totalText,
            });
        };
	})(fabric.IText.prototype.toObject);
    
    iText.totalText = tText;
       
    iText.async = true;
    
	canvas2.add(iText);
}

function fabric_TextBox(t, id, visible, a, b, tText, fs) {
    var Textbox = new fabric.Textbox(t, { 
        id: id,
		fontFamily: 'Courier', 
		width: offsetArray[wordsInALine],
        left: a, 
		top: b,
		fontSize: fs,
        visible: visible,
        selectable: false,
		fill: 'black',
        textAlign: 'left',
	});
   
    //to add the custom variable to the IText
    fabric.Textbox.prototype.toObject = (function(toObject) {
        return function() {
            return fabric.util.object.extend(toObject.call(this), {
                totalText: this.totalText,
            });
        };
	})(fabric.Textbox.prototype.toObject);
    
    Textbox.totalText = tText;
       
    Textbox.async = true;
    
	canvas2.add(Textbox);
}


function fabric_complementaryText(t,visible,a,b) {
	var name = new fabric.IText(t, {
        id: 2,
		fontFamily: 'Courier', 
		left: a, 
		top: b + 20,
		fontSize: 14,
        visible: visible,
		fill: 'black'
	});
	canvas2.add(name);
}

function drawline(x1,y1,x2,y2) {
    var name = new fabric.Line([x1,y1,x2,y2], {
        id:canvasObjCount,
        stroke: 'blue',
        selectable: false,
        strokeWidth: 3
    });
    canvas.add(name);
    canvasObjCount = canvasObjCount+1;
}

function drawMapping(x1,y1,x2,y2,a,b,enzyme,n,info){
    var line = new fabric.Line([0,0,(x2-x1),0], {
        stroke: 'blue',
        strokeWidth: 1,
    });
    
    var vline1 = new fabric.Line([0,0,0,7], {
        stroke: 'blue',
        strokeWidth: 1,
    });
    
    var vline2 = new fabric.Line([(x2-x1),0,(x2-x1),7], {
        stroke: 'blue',
        strokeWidth: 1,
    });
    
    var text = new fabric.Text(enzyme, {
        fontSize: 11,
        stroke: '#ff1318',
        originX: 'center', 
        originY: 'bottom' ,
        left  : (x2-x1)*6/11,
    });
    
    //to add the custom variable to the Text
    fabric.Text.prototype.toObject = (function(toObject) {
	  return function() {
	    return fabric.util.object.extend(toObject.call(this), {
	      info: this.info,
          highLightIds: this.highLightIds
        });
	  };
	})(fabric.Text.prototype.toObject);
    
    text.info = info;
    text.highLightIds = startId2+"#"+endId2+"#"+canvas2.getObjects().length;
    text.async = true;
    
    var highlightRect = (new fabric.Rect({
        id: 10,
        left: (x1),
        top: b+y1,
        width: (x2-x1),
        height: 45, // 20 + 20 + 5 (itext height + comp itext height + space inbetween)
        fill: '#009900',
        visible: false,
        hasControls: false,
        opacity: 0.2,
        selectable: false,
    })); 
    
    var name = new fabric.Group([ text, line, vline1, vline2], {
        id: 222,
        left: (x1 - 5), //Subtracting 5 because to move the line bracket in match with the highlighting part
        top: b+y1-22*n,
        visible: true,
        perPixelTargetFind: true,
        selectable: false,
    });
    canvas2.add(highlightRect);
    canvas2.add(name);
    var pushStr = {'canvasId':canvas2.getObjects().length , 'start':x1, 'end':x2, 'highLightId':(canvas2.getObjects().length - 1), 'type':"restictionEnzyme"}
    canvas2ItemArray.push(pushStr);
}

function drawBreakMapping(x1,x2,x3,x4,y1,y2,a,b,enzyme,n,info){
    var line1 = new fabric.Line([0,0,(x2-x1),0], {
        stroke: 'blue',
        strokeWidth: 1,
        left: x1
    });
    
    var vline1 = new fabric.Line([0,0,0,7], {
        stroke: 'blue',
        strokeWidth: 1,
        left: x1
    });
    
    var line2 = new fabric.Line([x3,(y2 - y1),(x4),(y2 - y1)], {
        stroke: 'blue',
        strokeWidth: 1,
        left: x3
    });
    
    var vline2 = new fabric.Line([(x4),(y2 - y1),(x4),(y2 - y1 + 7)], {
        stroke: 'blue',
        strokeWidth: 1,
        left: (x4)
    });
    
    var text = new fabric.Text(enzyme, {
        fontSize: 11,
        stroke: '#ff1318',
        originX: 'center', 
        originY: 'bottom' ,
        left  : x1 + (x2 - x1)*6/11,
        top: 0
    });
    
    //to add the custom variable to the Text
    fabric.Text.prototype.toObject = (function(toObject) {
	  return function() {
	    return fabric.util.object.extend(toObject.call(this), {
	      info: this.info,
          highLightIds: this.highLightIds
        });
	  };
	})(fabric.Text.prototype.toObject);
    
    text.info = info;
    text.highLightIds = startId2+"#"+endId2+"#"+canvas2.getObjects().length+"#"+(canvas2.getObjects().length+1);
    text.async = true;
    
    var highlightRect1 = (new fabric.Rect({
        id: 10,
        left: (x1),
        top: b+y1,
        width: (x2-x1),
        height: 45,
        fill: '#009900',
        visible: false,
        hasControls: false,
        opacity: 0.2,
        selectable: false,
    })); 
    
    var highlightRect2 = (new fabric.Rect({
        id: 10,
        left: (x3),
        top: b+y2,
        width: (x4-x3),
        height: 45,
        fill: '#009900',
        visible: false,
        hasControls: false,
        opacity: 0.2,
        selectable: false,
    })); 
    
    var name = new fabric.Group([ text, line1, vline1, line2, vline2], {
        id : 222,
        left : x3,
        top : b+y1-19*n,
        visible : true,
        perPixelTargetFind : true,
        targetFindTolerance : 10,
        hasControls : false,
        hasBorders : false,
        selectable: false,
        
    });
    canvas2.add(highlightRect1);
    canvas2.add(highlightRect2);
    canvas2.add(name);
    var pushStr = {'canvasId':canvas2.getObjects().length , 'start':x1, 'end':x2, 'highLightId':(canvas2.getObjects().length - 1), 'type':"restictionEnzyme"}
    canvas2ItemArray.push(pushStr)
}

var drawCutArray = [];
function drawBluntCut(x1,y1,x2,y2,left,top) {
    var drawCut = new fabric.Line([x1,y1,x2,y2], {
        stroke: 'red',
        selectable: false,
        left: left,
        top: top,
        strokeWidth: 2
    });
    canvas2.add(drawCut);
    drawCut.bringToFront();
    drawCutArray.push(canvas2.getObjects().length);
}

 
function drawCut(x1,y1,x2,y2,left,top) {
    var drawCut = new fabric.Line([x1,y1,x2,y2], {
        stroke: 'red',
        selectable: false,
        left: left,
        top: top,
        strokeWidth: 2
    });
    canvas2.add(drawCut);
    drawCut.bringToFront();
    drawCutArray.push(canvas2.getObjects().length);
}

function fabric_FMA(start, wordsInALine, by, fmaCount, fmaStringsArr) { //(0, wordsInALine, by, fmaStringsArr.length, fmaStringsArr)
    //Gave an id to the group 100 to differentiate from other groups when highlighting
    
    for (var j = 0; j < fmaStringsArr.length; j ++){      //0#1#120#"ChtC2"#1#1##A5F3BE*0#1#120#miscellaneous#2#2##94FB74#"begin"#fSegArr  ROW#STARTID#ENDID#NAME#ARRAYID#OVERLAP#COLOR#"begin"#FSEGARRAY
        //{"startRow":1,"startPos":0,"endPos":120,"featureName":"mphA misc_feature","arrayConn":118,"overLap":1,"color":"#A7730A","typeOfRow":"","featureSegDetails":"","lengthOfFeature":120},
        var fma = fmaStringsArr[j];
        var spacing = 15;
        var drawRect = false;
        var drawLine = false;
    
        
        var highlightRect = (new fabric.Rect({
            id: 10,
            left: offsetArray[parseInt(fma['startPos'])],
            top: by,
            width: offsetArray[parseInt(fma['endPos'])] - offsetArray[parseInt(fma['startPos'])],
            height: 45,
            fill: '#FFCC00',
            visible: false,
            hasControls: false,
            opacity: 0.2,
            //perPixelTargetFind: true,
            selectable: false,
        })); 
        
        
        if (fma['featureSegDetails'].length > 0){
            var fSegArr = fma['featureSegDetails'].split(",")[1].split("--"); //18,2~120--0~2
            if (typeof fSegArr[0] != 'undefined' && fSegArr[0].length > 0) {
                var rect = (new fabric.Rect({
                    id: 10,
                    left: offsetArray[parseInt(fSegArr[0].split("~")[0])],
                    top: by + parseInt(spacing) * parseInt(fma['overLap']) + 55 + (parseInt(fma['overLap'])*12),
                    width: offsetArray[parseInt(fSegArr[0].split("~")[1])] - offsetArray[parseInt(fSegArr[0].split("~")[0])],
                    height: 12,
                    fill: fma['color'],
                    stroke: '#000000',
                    strokeWidth: 1,
                    //visible: true,
                    hasControls: false,
                    perPixelTargetFind: true,
                    selectable: false,
                })); 
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        arrId: this.arrId,
                        highLightId: this.highLightId});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rect.arrId = fma['arrayConn'];
                rect.highLightId = startId2+"#"+endId2+"#"+canvas2.getObjects().length+"#"+(canvas2.getObjects().length+2);
                
                rect.async = true;
                drawRect = true;
            }
            
            if (typeof fSegArr[1] != 'undefined') {
                var x1 = offsetArray[parseInt(fSegArr[1].split("~")[0])];
                var y1 = by + parseInt(spacing)*parseInt(fma['overLap']) + 55 + (parseInt(fma['overLap'])*12)+ 6;
                var x2 = offsetArray[parseInt(fSegArr[1].split("~")[1])];
                var y2 = by + parseInt(spacing)*parseInt(fma['overLap']) + 55 + (parseInt(fma['overLap'])*12)+6;
                
                if (fSegArr[1] != ""){
                    var line = new fabric.Line([x1, y1, x2, y2], {
                        id: canvasObjCount,
                        stroke: 'blue',
                        strokeDashArray: [6, 5],
                        strokeWidth: 2,
                        selection: false
                    });
                }
                
                //to add the custom variable to the line
                fabric.Line.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        arrId: this.arrId,
                        highLightId: this.highLightId});
                    };
                })(fabric.Line.prototype.toObject);
                
                line.arrId = fma['arrayConn'];
                line.highLightId = startId2+"#"+endId2+"#"+canvas2.getObjects().length+"#"+(canvas2.getObjects().length+2);
                
                line.async = true;
                drawLine = true;
            }
            
            var txt = (new fabric.Text(fma['featureName'], {
                fontSize: 10,
                fillStyle: 'black',
                fontWeight: 'bold',
                left:  offsetArray[parseInt(fma['startPos'])] + (offsetArray[parseInt(fma['endPos'])] - offsetArray[parseInt(fma['startPos'])])/2,
                top:   by + parseInt(spacing)*parseInt(fma['overLap']) + 55 + (parseInt(fma['overLap'])*12) + 12,
                textAlign: 'center',
            }));
            
            if (drawRect && !drawLine) {
                var name = new fabric.Group([rect, txt], {
                    id: 100,
                    originX: 'center',
                    originY: 'center',
                    hasControls: false,
                    hasBorders: false,
                    perPixelTargetFind: true,
                    selection: false
                });
                canvas2.add(highlightRect);
                canvas2.add(name);
            }
            else if (drawLine && drawRect) {
                var name = new fabric.Group([rect, line, txt], {
                    id: 100,
                    originX: 'center',
                    originY: 'center',
                    hasControls: false,
                    hasBorders: false,
                    perPixelTargetFind: true,
                    selectable: false,
                });
                canvas2.add(highlightRect);
                canvas2.add(name);
            }
            else if (drawLine && !drawRect) {
                var name = new fabric.Group([line, txt], {
                    id: 100,
                    originX: 'center',
                    originY: 'center',
                    hasControls: false,
                    hasBorders: false,
                    perPixelTargetFind: true,
                    selectable: false,
                });
                canvas2.add(highlightRect);
                canvas2.add(name);
            }
            var pushStr = {'canvasId':canvas2.getObjects().length, 'start':fma['startPos'], 'end':fma['endPos'], 'highLightId':(canvas2.getObjects().length - 1), 'type':"feature"};
            canvas2ItemArray.push(pushStr);
        }
        else {
            var rect = (new fabric.Rect({
                id: 10,
                left: offsetArray[parseInt(fma['startPos'])],
                top: by + parseInt(spacing)*parseInt(fma['overLap']) + 55 + (parseInt(fma['overLap'])*12),
                width: offsetArray[parseInt(fma['endPos'])] - offsetArray[parseInt(fma['startPos'])],
                height: 12,
                fill: fma['color'],
                stroke: '#000000',
                strokeWidth: 1,
                hasControls: false,
                perPixelTargetFind: true,
                borderColor: 'red',
                selectable: false,
            })); 
            
            //to add the custom variable to the rectangle
            fabric.Rect.prototype.toObject = (function(toObject) {
                return function() {
                    return fabric.util.object.extend(toObject.call(this), {
                    arrId: this.arrId,
                    highLightId: this.highLightId});
                };
            })(fabric.Rect.prototype.toObject);
            
            rect.arrId = fma['arrayConn'];
            rect.highLightId = startId2+"#"+endId2+"#"+canvas2.getObjects().length+"#"+(canvas2.getObjects().length+2);
            rect.async = true;
            
            var txt = (new fabric.Text(fma['featureName'], {
                fontSize: 10,
                fillStyle: 'black',
                fontWeight: 'bold',
                left:  offsetArray[parseInt(fma['startPos'])] + (offsetArray[parseInt(fma['endPos'])] - offsetArray[parseInt(fma['startPos'])])/2,
                top:   by + parseInt(spacing)*parseInt(fma['overLap']) + 55 + (parseInt(fma['overLap'])*12),
                textAlign: 'center',
            }));
            
            
            var name = new fabric.Group([rect, txt], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                perPixelTargetFind: true,
                selectable: false,
            });
            
            canvas2.add(highlightRect);
            canvas2.add(name);
            
            var pushStr = {'canvasId':canvas2.getObjects().length, 'start':fma['startPos'], 'end':fma['endPos'], 'highLightId':(canvas2.getObjects().length - 1), 'type':"feature"};
            canvas2ItemArray.push(pushStr);
        }
        
        //top and bottom lines
        var x1 = offsetArray[parseInt(fma['startPos'])];
        var y1 = by + parseInt(spacing)*parseInt(fma['overLap']) + 55 + (parseInt(fma['overLap'])*12);
        var x2 = offsetArray[parseInt(fma['endPos'])];
        
        var line1 = new fabric.Line([x1, (y1 - 2), x2, (y1 - 2)], {
            stroke: 'red',
            strokeWidth: 1,
        });
        
        var line2 = new fabric.Line([x1, (y1 + 12), x2, (y1 + 12)], {
            stroke: 'red',
            strokeWidth: 1,
        });
        
        //check if its the beginning or end of feature rectangle
        var chkType = fma['typeOfRow'];
        
        if (chkType == "begin") {
            var lineV1 = new fabric.Line([x1-2, (y1-2), x1-2, (y1+12)], {
                stroke: 'red',
                strokeWidth: 1,
            }); 

            var lineGroup = new fabric.Group([line1, line2, lineV1], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                visible: false,
                perPixelTargetFind: true,
                selectable: false,
            });
        }
        else if (chkType == "begin&end") {
            var lineV1 = new fabric.Line([x1-2, (y1-2), x1-2, (y1+12)], {
                stroke: 'red',
                strokeWidth: 1,
            });                 
            
            var lineV2 = new fabric.Line([x2, (y1-2), x2, (y1+12)], {
                stroke: 'red',
                strokeWidth: 1,
            }); 

            var lineGroup = new fabric.Group([line1, line2, lineV1, lineV2], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                visible: false,
                perPixelTargetFind: true,
                selectable: false,
            });
        }
        else if(chkType == "end") {
            var lineV2 = new fabric.Line([x2, (y1-2), x2, (y1+12)], {
                stroke: 'red',
                strokeWidth: 1,
            });
            
            var lineGroup = new fabric.Group([line1, line2, lineV2], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                visible: false,
                perPixelTargetFind: true,
                selectable: false,
            });
        }
        else {
            var lineGroup = new fabric.Group([line1, line2], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                visible: false,
                perPixelTargetFind: true,
                selectable: false,
            });
        }
            
        canvas2.add(lineGroup);   
        
        /** Updating the high lighting ids with display of every row, we need to highlight all the rows with the feature band  **/
        var count = 0;
        for (var k = 0; k < canvas2.getObjects().length; k ++){
            var obj = canvas2.item(k);
            
            if (obj.isType('group') && (obj.id == 100) && obj.item(0).arrId == fma['arrayConn']) { 
                if (count == 0) {
                    if (obj.item(0).highLightId.split("#")[2] == (canvas2.getObjects().length - 3)) {
                        var hId = obj.item(0).highLightId;
                    }
                    else {
                        var hId = obj.item(0).highLightId +"#"+ (canvas2.getObjects().length - 3) +"#"+ (canvas2.getObjects().length-1 );
                    }
                }
                obj.item(0).highLightId = hId;
                count = count + 1;
            }
        }
        
	}
}


function fabric_ORFs(o1, o2, o3, o4, o5, o6, howManyTranslations, transOffset, words, by, lineBreak) {
    for (var i = 0; i < o1.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o1[i]['startPos'];
        var endPos = o1[i]['endPos'];
        console.log("ORF1s pos: "+ startPos +", "+ endPos);
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        
        if ((getTheStartRow == startId2 || getTheStartRow >= startId2) && getTheStartRow < endId2) {
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = offsetArray[getTheStartPos];
                var e = offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    //top: b+y1 - 65,
                    top: b+y1 - (Math.abs(howManyTranslations) * 12 + (Math.abs(howManyTranslations)) * 10), // 12 is height and 10 is the spacing between the translation
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum });
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF1: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 1;
                rectangle.async = true;
                
                canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words) * getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words) * getTheEndRow;
                
                var x1 = offsetArray[getTheStartPos];
                var x2 = offsetArray[parseInt(words)];
                var x3 = offsetArray[0];
                var x4 = offsetArray[getTheEndPos + 3];
                var y1 = lineBreak[getTheStartRow - startId2];
                var y2 = lineBreak[getTheEndRow - startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j == getTheStartRow) {
                        var s = x1;
                        var e = x2; // +3 nucleotide pairs
                    }
                    else if (j == getTheEndRow) {
                        var s = x3;
                        var e = x4;
                    }
                    else {
                        var s = x3;
                        var e = x2;
                    }
                    var y1 = lineBreak[j - startId2 + 1];
                    var rectangle = (new fabric.Rect({
                        id: 111,
                        left: s,
                        top: b+y1 - (Math.abs(howManyTranslations) * 12 + (Math.abs(howManyTranslations)) * 10),
                        width: (e - s),
                        height: 12,
                        fill: '#FF3333',
                        stroke: '#484848',
                        strokeWidth: 1,
                        opacity: 0.2,
                        hasControls: false,
                        selectable: false,
                    }));
                    
                    //to add the custom variable to the rectangle
                    fabric.Rect.prototype.toObject = (function(toObject) {
                        return function() {
                            return fabric.util.object.extend(toObject.call(this), {
                            orfDetails: this.orfDetails,
                            orfRow: this.orfRow,
                            orfNum: this.orfNum });
                        };
                    })(fabric.Rect.prototype.toObject);
                    
                    rectangle.orfDetails = "ORF1: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                    rectangle.orfRow = j;
                    rectangle.orfNum = 1;
                    rectangle.async = true;
                    
                    canvas2.add(rectangle);
                    var obj = canvas2.item(canvas2.size());
                    
                    //var pushStr = {'canvasId':canvas2.getObjects().length, 'start':startPos, 'end':endPos, 'highLightId':(canvas2.getObjects().length - 1), 'type':"orf"};
                    //canvas2ItemArray.push(pushStr);
                }
            }
        }
    }
    
    for (var i = 0; i < o2.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        var startPos = o2[i]['startPos'];
        var endPos = o2[i]['endPos'];
        console.log("ORF2s pos: "+ startPos +", "+ endPos);
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        
        if ((getTheStartRow == startId2 || getTheStartRow >= startId2) && getTheStartRow < endId2){
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = offsetArray[getTheStartPos];
                var e = offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    //top: b+y1 - 65,
                    top: b+y1 - (Math.abs(howManyTranslations - 1) * 12 + (Math.abs(howManyTranslations)) * 10) + 5,
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF2: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 2;
                rectangle.async = true;
                
                canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = offsetArray[getTheStartPos];
                var x2 = offsetArray[parseInt(words)];
                var x3 = offsetArray[0];
                var x4 = offsetArray[getTheEndPos + 3];
                var y1 = lineBreak[getTheStartRow - startId2];
                var y2 = lineBreak[getTheEndRow - startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j == getTheStartRow) {
                        var s = x1;
                        var e = x2; // +3 nucleotide pairs
                    }
                    else if (j == getTheEndRow) {
                        var s = x3;
                        var e = x4;
                    }
                    else {
                        var s = x3;
                        var e = x2;
                    }
                    var y1 = lineBreak[j - startId2 + 1];
                    
                    var rectangle = (new fabric.Rect({
                        id: 111,
                        left: s,
                        //top: b+y1 - 50,
                        top: b+y1 - (Math.abs(howManyTranslations - 1) * 12 + (Math.abs(howManyTranslations)) * 10) + 5,
                        width: (e - s),
                        height: 12,
                        fill: '#FF3333',
                        stroke: '#484848',
                        strokeWidth: 1,
                        opacity: 0.2,
                        hasControls: false,
                        selectable: false,
                    }));
                    
                    //to add the custom variable to the rectangle
                    fabric.Rect.prototype.toObject = (function(toObject) {
                        return function() {
                            return fabric.util.object.extend(toObject.call(this), {
                            orfDetails: this.orfDetails,
                            orfRow: this.orfRow,
                            orfNum: this.orfNum});
                        };
                    })(fabric.Rect.prototype.toObject);
                    
                    rectangle.orfDetails = "ORF2: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                    rectangle.orfRow = j;
                    rectangle.orfNum = 2;
                    rectangle.async = true;
                    canvas2.add(rectangle);
                }
            }
        }
    }
    
    for (var i = 0; i < o3.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o3[i]['startPos'];
        var endPos = o3[i]['endPos'];
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        console.log("ORF3s pos: "+ startPos +", "+ endPos + ", "+ startId2 + ", "+ getTheStartRow);
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        
        if ((getTheStartRow == startId2 || getTheStartRow >= startId2) && getTheStartRow < endId2){
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = offsetArray[getTheStartPos];
                var e = offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    //top: b+y1 - 65,
                    top: b+y1 - (Math.abs(howManyTranslations - 2) * 12 + (Math.abs(howManyTranslations - 1)) * 10),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF3: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 3;
                rectangle.async = true;
                
                canvas2.add(rectangle);
            }
            else {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = offsetArray[getTheStartPos];
                var x2 = offsetArray[parseInt(words)];
                var x3 = offsetArray[0];
                var x4 = offsetArray[getTheEndPos + 3];
                var y1 = lineBreak[getTheStartRow - startId2];
                var y2 = lineBreak[getTheEndRow - startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j == getTheStartRow) {
                        var s = x1;
                        var e = x2; // +3 nucleotide pairs
                    }
                    else if (j == getTheEndRow) {
                        var s = x3;
                        var e = x4;
                    }
                    else {
                        var s = x3;
                        var e = x2;
                    }
                    var y1 = lineBreak[j - startId2 + 1];
                    
                    var rectangle = (new fabric.Rect({
                        id: 111,
                        left: s,
                        top: b+y1 - (Math.abs(howManyTranslations - 2) * 12 + (Math.abs(howManyTranslations - 1)) * 10),
                        width: (e - s),
                        height: 12,
                        fill: '#FF3333',
                        stroke: '#484848',
                        strokeWidth: 1,
                        opacity: 0.2,
                        hasControls: false,
                        selectable: false,
                    }));
                    
                    //to add the custom variable to the rectangle
                    fabric.Rect.prototype.toObject = (function(toObject) {
                        return function() {
                            return fabric.util.object.extend(toObject.call(this), {
                            orfDetails: this.orfDetails,
                            orfRow: this.orfRow,
                            orfNum: this.orfNum});
                        };
                    })(fabric.Rect.prototype.toObject);
                    
                    rectangle.orfDetails = "ORF3: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                    rectangle.orfRow = j;
                    rectangle.orfNum = 3;
                    rectangle.async = true;
                    canvas2.add(rectangle);
                }
            }
        }
    }
    
    for (var i = 0; i < o4.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o4[i]['startPos'];
        var endPos = o4[i]['endPos'];
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        
        console.log("ORF4s pos: "+ startPos +", "+ endPos +", "+ getTheStartRow +", "+getTheEndRow+", "+startId2 +", "+ endId2);
                
        if ((getTheStartRow == startId2 || getTheStartRow >= startId2) && getTheStartRow < endId2) {
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = offsetArray[getTheStartPos];
                var e = offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    top: b+y1 - (Math.abs(howManyTranslations - 2) * 12 + (Math.abs(howManyTranslations - 1)) * 10),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF4: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 4;
                rectangle.async = true;
                
                canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = offsetArray[getTheStartPos - 1];
                var x2 = offsetArray[parseInt(words)];
                var x3 = offsetArray[0];
                var x4 = offsetArray[getTheEndPos + 2];
                var y1 = lineBreak[getTheStartRow - startId2];
                var y2 = lineBreak[getTheEndRow - startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j == getTheStartRow) {
                        var s = x1;
                        var e = x2; // +3 nucleotide pairs
                    }
                    else if (j == getTheEndRow) {
                        var s = x3;
                        var e = x4;
                    }
                    else {
                        var s = x3;
                        var e = x2;
                    }
                    var y1 = lineBreak[j - startId2 + 1];
                    
                    var rectangle = (new fabric.Rect({
                        id: 111,
                        left: s,
                        top: b+y1 - (Math.abs(howManyTranslations - 3) * 12 + (Math.abs(howManyTranslations - 2)) * 10) + 10,
                        width: (e - s),
                        height: 12,
                        fill: '#009900',
                        stroke: '#484848',
                        strokeWidth: 1,
                        opacity: 0.2,
                        hasControls: false,
                        selectable: false,
                    }));
                    
                    //to add the custom variable to the rectangle
                    fabric.Rect.prototype.toObject = (function(toObject) {
                        return function() {
                            return fabric.util.object.extend(toObject.call(this), {
                            orfDetails: this.orfDetails,
                            orfRow: this.orfRow,
                            orfNum: this.orfNum});
                        };
                    })(fabric.Rect.prototype.toObject);
                    
                    rectangle.orfDetails = "ORF4: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                    rectangle.orfRow = j;
                    rectangle.orfNum = 4;
                    rectangle.async = true;
                    canvas2.add(rectangle);
                }
            }
        }
    }
    
    for (var i = 0; i < o5.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o5[i]['startPos'];
        var endPos = o5[i]['endPos'];
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        console.log("ORF5s pos: "+ startPos +", "+ endPos +", "+ getTheStartRow +", "+getTheEndRow+", "+startId2 +", "+ endId2);
        
        if ((getTheStartRow == startId2 || getTheStartRow >= startId2) && getTheStartRow < endId2){
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = offsetArray[getTheStartPos];
                var e = offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    top: b+y1 - (Math.abs(howManyTranslations - 4) * 12 + (Math.abs(howManyTranslations - 3)) * 10),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF5: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 5;
                rectangle.async = true;
                
                canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = offsetArray[getTheStartPos - 1];
                var x2 = offsetArray[parseInt(words)];
                var x3 = offsetArray[0];
                var x4 = offsetArray[getTheEndPos + 2];
                var y1 = lineBreak[getTheStartRow - startId2];
                var y2 = lineBreak[getTheEndRow - startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j == getTheStartRow) {
                        var s = x1;
                        var e = x2; // +3 nucleotide pairs
                    }
                    else if (j == getTheEndRow) {
                        var s = x3;
                        var e = x4;
                    }
                    else {
                        var s = x3;
                        var e = x2;
                    }
                    var y1 = lineBreak[j - startId2 + 1];
                    
                    var rectangle = (new fabric.Rect({
                        id: 111,
                        left: s,
                        //top: b+y1 - (Math.abs(howManyTranslations - 3) * 12 + (Math.abs(howManyTranslations - 2)) * 10) + 10
                        top: b+y1 - (Math.abs(howManyTranslations - 4) * 12 + (Math.abs(howManyTranslations - 3)) * 10),
                        width: (e - s),
                        height: 12,
                        fill: '#99002e',
                        stroke: '#484848',
                        strokeWidth: 1,
                        opacity: 0.2,
                        hasControls: false,
                        selectable: false,
                    }));
                    
                    //to add the custom variable to the rectangle
                    fabric.Rect.prototype.toObject = (function(toObject) {
                        return function() {
                            return fabric.util.object.extend(toObject.call(this), {
                            orfDetails: this.orfDetails,
                            orfRow: this.orfRow,
                            orfNum: this.orfNum});
                        };
                    })(fabric.Rect.prototype.toObject);
                    
                    rectangle.orfDetails = "ORF5: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                    rectangle.orfRow = j;
                    rectangle.orfNum = 5;
                    rectangle.async = true;
                    
                    canvas2.add(rectangle);
                }
            }
        }
    }
    
    for (var i = 0; i < o6.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o6[i]['startPos'];
        var endPos = o6[i]['endPos'];
        
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        console.log("ORF6s pos: "+ startPos +", "+ endPos +", "+ getTheStartRow +", "+getTheEndRow+", "+startId2 +", "+ endId2);
        
        if ((getTheStartRow == startId2 || getTheStartRow >= startId2) && getTheStartRow < endId2){
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = offsetArray[getTheStartPos];
                var e = offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    top: b+y1 - (Math.abs(howManyTranslations - 5) * 12 + (Math.abs(howManyTranslations - 4)) * 10),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF6: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 6;
                rectangle.async = true;
                
                canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = offsetArray[getTheStartPos - 1];
                var x2 = offsetArray[parseInt(words)];
                var x3 = offsetArray[0];
                var x4 = offsetArray[getTheEndPos + 2];
                var y1 = lineBreak[getTheStartRow - startId2];
                var y2 = lineBreak[getTheEndRow - startId2];
                
                if(getTheStartRow < startId2) {
                    var jj = startId2;
                }
                else {
                    var jj = getTheStartRow;
                }
                //Only display orf's until endId2 
                if(getTheEndRow+1 < endId2) {
                    var jjj = getTheEndRow+1;
                }
                else {
                    var jjj = endId2+1;
                }
                console.log("ORF 6: "+ startId2 +", "+ endId2 +", "+ getTheStartRow +", "+ getTheEndRow);
                for (var j = jj; j < jjj ; j++) {
                    if (j == jj) {
                        var s = x1;
                        var e = x2; // +3 nucleotide pairs
                    }
                    else if (j == jjj-1 ) {
                        var s = x3;
                        var e = x4;
                    }
                    else {
                        var s = x3;
                        var e = x2;
                    }
                    var y1 = lineBreak[j - startId2 + 1];
                    
                    var rectangle = (new fabric.Rect({
                        id: 111,
                        left: s,
                        //top: b+y1 - (Math.abs(howManyTranslations - 3) * 12 + (Math.abs(howManyTranslations - 2)) * 10) + 10
                        top: b + y1 - ( Math.abs(howManyTranslations - 5) * 12 + (Math.abs(howManyTranslations - 4)) * 10 ),
                        width: (e - s),
                        height: 12,
                        fill: '#001299',
                        stroke: '#484848',
                        strokeWidth: 1,
                        opacity: 0.2,
                        hasControls: false,
                        selectable: false,
                    }));
                    
                    //to add the custom variable to the rectangle
                    fabric.Rect.prototype.toObject = (function(toObject) {
                        return function() {
                            return fabric.util.object.extend(toObject.call(this), {
                            orfDetails: this.orfDetails,
                            orfRow: this.orfRow,
                            orfNum: this.orfNum});
                        };
                    })(fabric.Rect.prototype.toObject);
                    
                    rectangle.orfDetails = "ORF6: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                    rectangle.orfRow = j;
                    rectangle.orfNum = 6;
                    rectangle.async = true;
                    canvas2.add(rectangle);
                }
            }
        }
    }
}

var amenoAcidIds = {};
function fabric_amenoAcidTranslations(p1, p2 ,p3 ,m1 ,m2, m3, q, howManyTranslations, transOffset, wordsInALine, by, translationType) {
    //Place a rect with width of 3 base pairs and move it according to the appropriate position
    var plus1 = p1;
    var minus1 = m1;
    var plus2 = p2;
    var minus2 = m2;
    var plus3 = p3;
    var minus3 = m3;
    
    var startPos = (q) * wordsInALine;
    var aIds1 = [], aIds2 = [], aIds3 = [], aIds4 = [], aIds5 = [], aIds6 = [];
    
    var highlightRect = (new fabric.Rect({
        id: 10,
        left: offsetArray[0],
        top: by,
        width: (offsetArray[5] - offsetArray[2]), // +5 to make the rect little wider
        height: 20,
        fill: '#FFCC00',
        visible: false,
        hasControls: false,
        opacity: 0.4,
        selectable: false,
        stroke: 'black',
        strokeWidth: 1
    })); 
    canvas2.add(highlightRect); 
    var highlightTopId = canvas2.getObjects().length - 1;
    
    var highlightBottomRect = (new fabric.Rect({
        id: 10,
        left: offsetArray[0],
        top: by + 22,
        width: (offsetArray[5] - offsetArray[2]), // +5 to make the rect little wider
        height: 20,
        fill: '#FFCC00',
        visible: false,
        hasControls: false,
        opacity: 0.4,
        selectable: false,
        stroke: 'black',
        strokeWidth: 1
    })); 
    canvas2.add(highlightBottomRect); 
    var highlightBottomId = canvas2.getObjects().length - 1;
    
    if (howManyTranslations == 1) {
        
        for (var i = 0; i < plus1.length; i++) {
            if (translationType == "single"){
               var t1 = plus1[i][3];
            }
            else if (translationType == "three"){
                var t1 = plus1[i][2];
            }
            
            var iText = new fabric.IText(t1, { 
                id: 200,
                fontFamily: 'Courier', 
                left: offsetArray[(plus1[i][0] - startPos)], 
                top: transOffset - 20,
                fontSize: 12,
                visible: true,
                selectable: false,
                fill: 'black'
            });
           
            //to add the custom variable to the IText
            fabric.IText.prototype.toObject = (function(toObject) {
                return function() {
                    return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                    });
                };
            })(fabric.IText.prototype.toObject);
            
            if ((plus1[i][0] - startPos) == 0){
                var p = 0;
            }
            else {
                var p = (plus1[i][0] - startPos);
            }
            iText.movePos = offsetArray[p];
            iText.highlightId = highlightTopId;
            iText.name = objAmenoAcid[plus1[i][1]]['AminoAcid'];
            iText.three = objAmenoAcid[plus1[i][1]]['ThreeLetterCode'];
            iText.one = objAmenoAcid[plus1[i][1]]['OneLetterCode'];
            iText.amenoRow = q;
            iText.left = offsetArray[(plus1[i][0] - startPos)];
            iText.top = transOffset - 20;
            iText.right = offsetArray[(plus1[i][0] - startPos)] + (offsetArray[2] - offsetArray[0]);
            iText.bottom = transOffset - 8;
            iText.async = true;
            
            canvas2.add(iText);
            aIds1.push(canvas2.getObjects().length-1);
        }
        amenoAcidIds[q+"_1"] = aIds1;   
    }
    else { 
        if (howManyTranslations == 3 || howManyTranslations == 6) {
            
            for (var i = 0; i < plus1.length; i++) {
                if (translationType == "single"){
                   var t1 = plus1[i][3];
                }
                else if (translationType == "three"){
                    var t1 = plus1[i][2];
                }
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: offsetArray[(plus1[i][0] - startPos)], 
                    top: transOffset - 20,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                       });
                    };
                })(fabric.IText.prototype.toObject);
                
                if (plus1[i][0] == startPos) {
                    var p = 0;
                }
                else {
                    var p = (plus1[i][0] - startPos);
                }
                iText.movePos = offsetArray[p];
                iText.highlightId = highlightTopId;
                iText.name = objAmenoAcid[plus1[i][1]]['AminoAcid'];
                iText.three = objAmenoAcid[plus1[i][1]]['ThreeLetterCode'];
                iText.one = objAmenoAcid[plus1[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = offsetArray[(plus1[i][0] - startPos)];
                iText.top = transOffset - 20;
                iText.right = offsetArray[(plus1[i][0] - startPos)] + (offsetArray[2] - offsetArray[0]) + 5;
                iText.bottom = transOffset - 8;
                iText.async = true;
                
                canvas2.add(iText);
                aIds1.push(canvas2.getObjects().length-1);
            }
            
            amenoAcidIds[q+"_1"] = aIds1; 
            
            for (var i = 0; i < plus2.length; i++) {
                if (translationType == "single"){
                    var t1 = plus2[i][3];
                }
                else if (translationType == "three"){
                    var t1 = plus2[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: offsetArray[(plus2[i][0] - startPos)], 
                    top: transOffset + 15 - 20,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                            highlightId: this.highlightId,
                            movePos: this.movePos,
                            name: this.name,
                            one: this.one,
                            three: this.three,
                            amenoRow: this.amenoRow,
                            left: this.left,
                            top: this.top,
                            right: this.right,
                            bottom: this.bottom
                        });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((plus2[i][0] - startPos) == 1){
                    var p = 1;
                }
                else {
                    var p = (plus2[i][0] - startPos);
                }
                iText.movePos = offsetArray[p];
                iText.highlightId = highlightTopId;
                iText.name = objAmenoAcid[plus2[i][1]]['AminoAcid'];
                iText.three = objAmenoAcid[plus2[i][1]]['ThreeLetterCode'];
                iText.one = objAmenoAcid[plus2[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = offsetArray[(plus2[i][0] - startPos)];
                iText.top = transOffset + 15 - 20;
                iText.right = offsetArray[(plus2[i][0] - startPos)] + (offsetArray[2] - offsetArray[0]) + 5;
                iText.bottom = transOffset + 15 - 8;                   
                iText.async = true;
                
                canvas2.add(iText);
                aIds2.push(canvas2.getObjects().length-1);
            }
            
            amenoAcidIds[q+"_2"] = aIds2; 
            
            for (var i = 0; i < plus3.length; i++) {
                if (translationType == "single"){
                   var t1 = plus3[i][3];
                }
                else if (translationType == "three"){
                    var t1 = plus3[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: offsetArray[(plus3[i][0] - startPos)], 
                    top: transOffset + 30 - 20,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                            highlightId: this.highlightId,
                            movePos: this.movePos,
                            name: this.name,
                            one: this.one,
                            three: this.three,
                            amenoRow: this.amenoRow,
                            left: this.left,
                            top: this.top,
                            right: this.right,
                            bottom: this.bottom
                        });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((plus3[i][0] - startPos) == 2){
                    var p = 2;
                }
                else {
                    var p = (plus3[i][0] - startPos);
                }
                iText.movePos = offsetArray[p];
                
                iText.highlightId = highlightTopId;
                iText.name = objAmenoAcid[plus3[i][1]]['AminoAcid'];
                iText.three = objAmenoAcid[plus3[i][1]]['ThreeLetterCode'];
                iText.one = objAmenoAcid[plus3[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = offsetArray[(plus3[i][0] - startPos)];
                iText.top = transOffset + 30 - 20;
                iText.right = offsetArray[(plus3[i][0] - startPos)] + (offsetArray[2] - offsetArray[0]) + 5;
                iText.bottom = transOffset + 30 - 8;  
                iText.async = true;
                
                canvas2.add(iText);
                aIds3.push(canvas2.getObjects().length-1);
            }
            
            amenoAcidIds[q+"_3"] = aIds3; 
        }
        
        if (howManyTranslations == -3 || howManyTranslations == 6) {
            for (var i = 0; i < minus1.length; i++) {
               if (translationType == "single"){
                   var t1 = minus1[i][3];
                }
                else if (translationType == "three"){
                    var t1 = minus1[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: offsetArray[(minus1[i][0] - startPos)], 
                    top: transOffset + (Math.abs(howManyTranslations) - 3)*15 ,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                       });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((minus1[i][0] - startPos) == 0){
                    var p = 0;
                }
                else {
                    var p = (minus1[i][0] - startPos);
                }
                iText.movePos = offsetArray[p];
                
                //iText.movePos = offsetArray[(minus1[i][0] - startPos) - 1];
                iText.highlightId = highlightBottomId;
                iText.name = objAmenoAcid[minus1[i][1]]['AminoAcid'];
                iText.three = objAmenoAcid[minus1[i][1]]['ThreeLetterCode'];
                iText.one = objAmenoAcid[minus1[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = offsetArray[(minus1[i][0] - startPos)];
                iText.top = transOffset + (Math.abs(howManyTranslations) - 3)*15;
                iText.right = offsetArray[(minus1[i][0] - startPos)] + (offsetArray[2] - offsetArray[0]) + 5;
                iText.bottom = transOffset + (Math.abs(howManyTranslations) - 3)*15 + 12;  
                iText.async = true;
                canvas2.add(iText);
                aIds4.push(canvas2.getObjects().length-1);
            }
            
            amenoAcidIds[q+"_4"] = aIds4; 
            
            for (var i = 0; i < minus2.length; i++) {
                if (translationType == "single"){
                   var t1 = minus2[i][3];
                }
                else if (translationType == "three"){
                    var t1 = minus2[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: offsetArray[(minus2[i][0] - startPos)], 
                    top: transOffset + (Math.abs(howManyTranslations) - 3)*15 + 15,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                       });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((minus2[i][0] - startPos) == 1){
                    var p = 1;
                }
                else {
                    var p = (minus2[i][0] - startPos);
                }
                iText.movePos = offsetArray[p];
                iText.highlightId = highlightBottomId;
                iText.name = objAmenoAcid[minus2[i][1]]['AminoAcid'];
                iText.three = objAmenoAcid[minus2[i][1]]['ThreeLetterCode'];
                iText.one = objAmenoAcid[minus2[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = offsetArray[(minus2[i][0] - startPos)];
                iText.top = transOffset + (Math.abs(howManyTranslations) - 3)*15 + 15;
                iText.right = offsetArray[(minus2[i][0] - startPos)] + (offsetArray[2] - offsetArray[0]) + 5;
                iText.bottom = transOffset + (Math.abs(howManyTranslations) - 3)*15 + 12;   
                iText.async = true;
                canvas2.add(iText);
                aIds5.push(canvas2.getObjects().length-1);
            }
            
            amenoAcidIds[q+"_5"] = aIds5; 
            
            for (var i = 0; i < minus3.length; i++) {
                if (translationType == "single"){
                   var t1 = minus3[i][3];
                }
                else if (translationType == "three"){
                    var t1 = minus3[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: offsetArray[(minus3[i][0] - startPos)], 
                    top: transOffset + (Math.abs(howManyTranslations) - 3)*15 + 30,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                       });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((minus3[i][0] - startPos) == 2){
                    var p = 2;
                }
                else {
                    var p = (minus3[i][0] - startPos);
                }
                iText.movePos = offsetArray[p];
                
                iText.highlightId = highlightBottomId;
                iText.name = objAmenoAcid[minus3[i][1]]['AminoAcid'];
                iText.three = objAmenoAcid[minus3[i][1]]['ThreeLetterCode'];
                iText.one = objAmenoAcid[minus3[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = offsetArray[(minus3[i][0] - startPos)], 
                iText.top = transOffset + (Math.abs(howManyTranslations) - 3)*15 + 30;
                iText.right = offsetArray[(minus3[i][0] - startPos)] + (offsetArray[2] - offsetArray[0]) + 5;
                iText.bottom = transOffset + (Math.abs(howManyTranslations) - 3)*15 + 12;   
                iText.async = true;
                canvas2.add(iText);
                aIds6.push(canvas2.getObjects().length-1);
            }
            amenoAcidIds[q+"_6"] = aIds6; 
        }
    }
}


function drawCircularMap(fStrJSON, totalBP, r, zoom, displayName, basePairs, REmappingArray){
    //REmappingArray -- {"startPos":2611,"endPos":2617,"enzyme":"BamH1","sequence":"GGATCC","overLap":1,"cut":"G^GATCC","cutType":"sticky","cutPosition":2}
    var rAng = $("#arxD_rotationSlider").slider("value"); 
    canvas3.clear();
    //Dividing the outer circle into 9 parts and finding that close to 1000..
    var markOuterCircle = [50, 100, 200, 500, 700, 900, 1000, 1200, 1300, 1500, 1800, 2000, 2200, 2500, 2700, 3000, 3200, 3500, 3700, 3900, 4000, 4200, 4300, 4500, 4700, 5000, 6000, 7500, 10000, 12000, 15000, 16000, 18000, 20000, 22000, 25000, 27500, 30000, 32000, 35000, 37000, 40000];
    target = Math.abs(parseInt(totalBP) / 9);
    
    r = (parseInt(r) * zoom);
    
    if ( !displayName ) {
        displayName = "";
    }
    if ( !basePairs ) {
        basePairs = "";
    }
    
    var L = ($(window).width() - r)/2;
    
    var iTextName = new fabric.IText(displayName, { 
        fontFamily: 'Courier', 
        left: L,
        top: 1.2 * r,
        originX: 'center', 
        originY: 'center',
        fontSize: 20,
        visible: true,
        fill: 'black'
    });
    var iTextBP = new fabric.IText(basePairs.toString()+ " bp", { 
        fontFamily: 'Courier', 
        left: L,
        top: 1.2 * r + 20,
        originX: 'center', 
        originY: 'center',
        fontSize: 16,
        visible: true,
        fill: 'black'
    });
    
    var name = new fabric.Group([ iTextName, iTextBP], {
        id: 110011,
        selectable: false,
    });
    
    //to add the custom variable to the IText
    fabric.Group.prototype.toObject = (function(toObject) {
        return function() {
            return fabric.util.object.extend(toObject.call(this), {
                rotation: this.rotation,
                zoom: this.zoom
            });
        };
    })(fabric.Group.prototype.toObject);
    
    name.rotation = rAng;
    name.zoom = zoom;
    name.async = true;
    
    canvas3.add(name);
    for (var k=1; k<markOuterCircle.length; k++) {
        // As soon as a number bigger than target is found, return the previous or current
        if (parseInt(markOuterCircle[k]) > target) {
            var p = markOuterCircle[k-1];
            var c = markOuterCircle[k];
            var num = Math.abs( p-target ) < Math.abs( c-target ) ? p : c;
            break;
        }
    }

    if (num == ""){
        var num = markOuterCircle[markOuterCircle.length-1];
    }

    var markAngle = ((2 * parseInt(num))/ parseInt(totalBP));
    
    var circle = new fabric.Circle({
        id: totalBP,
        radius: r,
        left: L,
        top: 1.2 * r,
        originX: 'center', 
        originY: 'center',
        stroke: '#000',
        strokeWidth: 2,
        fill: '',
        selectable: false,
    });

    var circle1 = new fabric.Circle({
        id: 2,
        radius: r - 6,
        left: L,
        top: 1.2 * r,
        originX: 'center', 
        originY: 'center',
        stroke: '#000',
        strokeWidth: 2,
        fill:'',
        selectable: false,
    });
    canvas3.add(circle, circle1);

    for (var j = 0; j < 9; j++){
        var startAngle = Math.PI * (1.5 + (parseFloat(markAngle) * j) + (parseInt(rAng)*2/360) );
        var endAngle = Math.PI * ((1.5 + (parseFloat(markAngle) *j))+ (parseInt(rAng)*2/360) + 0.008);
        var c = '#000';
        if (j == 0){ c = 'red';}
        
        var mark = new fabric.Circle({
            radius: r - 6,
            left: L,
            top: 1.2 * r,
            originX: 'center', 
            originY: 'center',
            startAngle: startAngle,
            endAngle: endAngle,
            stroke: c,
            strokeWidth: 10,
            selectable: false,
        });
        canvas3.add(mark);
        
        var t = (parseInt(num)*j).toString();
        var angle1 = ((360 * parseInt(num) * j)/parseInt(totalBP)) + (parseInt(rAng)) ; 
        var angle = Math.PI * ((parseFloat(markAngle) * j) + ((2 * (parseInt(rAng)))/360));
        
        var coords = findCoordinates(L, (1.2*r), 0.9*r, angle1, 1);
        var left1 = coords[0]; 
        var top1 = coords[1]; 
        
        var text = new fabric.IText(t, { 
            id: 1111, //to differentiate from other elements when rotating 
            left: left1,
            top: top1,
            fontSize: 14,
            fill: 'black',
            originX: 'center', 
            originY: 'center',
            angle: angle1,
            selectable: false,
        });
        
        //to add the custom variable to the IText
        fabric.IText.prototype.toObject = (function(toObject) {
            return function() {
                return fabric.util.object.extend(toObject.call(this), {
                    objAngle: this.objAngle,
                    markAngle: this.markAngle
                });
            };
        })(fabric.IText.prototype.toObject);
        
        text.objAngle = angle1;
        text.markAngle = angle;
        text.async = true;
        
        canvas3.add(text);
    }
    
    if (fStrJSON.length > 0 && $("#arxD_showHideFeatures").text() == 'Hide Features' ) {
        // Draw red lines to show the selection
        var x1 = cx + r * Math.cos(angle_rad);
        var y1 = cy + r * Math.sin(angle_rad);
        var x2 = cx + r1 * Math.cos(angle_rad);
        var y2 = cy + r1 * Math.sin(angle_rad);
        
        var line = new fabric.Line([x1,y1,x2,y2], {
            stroke: 'black',
            strokeWidth: 1,
            selectable: false,
        });
        
        for (var i = 0; i < fStrJSON.length; i++) {
            var overLap = fStrJSON[i]['overLap'];
            var dir = fStrJSON[i]['direction'];
            
            if ((r - parseInt(overLap) * 20) > 10) {
                var cx = L;
                var cy = 1.2 * r;
                var angle = (parseInt(fStrJSON[i]['startPos'])/ parseInt(totalBP))*360;
                var dangle = ((parseInt(fStrJSON[i]['endPos']) - parseInt(fStrJSON[i]['startPos'])) * 360)/parseInt(totalBP);
                var radius = ((.95 * r) - (parseInt(overLap) * 20));
                var thickness = 14;
                var add_factor = 0.3;
                
                var angle_rad = 1.5 * Math.PI + angle * Math.PI / 180 + ((2 * Math.PI * rAng)/360);    //1.5 * Math.PI - to start drawing arcs from the angle 270
                var dangle_rad = dangle * Math.PI / 180;
                var total_rad = angle_rad + dangle_rad;
                
                var r1 = radius - 0.5*thickness - 0.5*add_factor*thickness;
                var r2 = radius + 0.5*thickness + 0.5*add_factor*thickness;
                var r3 = radius;
                
                var tri_rad = ( thickness + (thickness * add_factor) )/r3;
                
                var angle1, angle2;
                if ( ( 1/3*dangle_rad ) > tri_rad) {  // <) ( thickness + (thickness * add_factor) )/r3
                    var f1 = tri_rad/dangle_rad;
                    var f2 = (dangle_rad - tri_rad)/dangle_rad;
                    
                    if(dir === -1) {
                        angle1 = angle_rad + f2*dangle_rad;
                        angle2 = angle_rad + 3/3*dangle_rad;
                        
                        sAngle = angle_rad + 0/3*dangle_rad;
                        eAngle = angle_rad + f2*dangle_rad;
                    } else {
                        angle1 = angle_rad + f1*dangle_rad;
                        angle2 = angle_rad + 0/3*dangle_rad;
                        
                        sAngle = angle_rad + f1*dangle_rad;
                        eAngle = angle_rad + 3/3*dangle_rad;
                    }
                }
                else {
                    if(dir === -1) {
                        angle1 = angle_rad + 2/3*dangle_rad;
                        angle2 = angle_rad + 3/3*dangle_rad;
                        
                        sAngle = angle_rad + 0/3*dangle_rad;
                        eAngle = angle_rad + 2/3*dangle_rad;
                    } else {
                        angle1 = angle_rad + 1/3*dangle_rad;
                        angle2 = angle_rad + 0/3*dangle_rad;
                        
                        sAngle = angle_rad + 1/3*dangle_rad;
                        eAngle = angle_rad + 3/3*dangle_rad;
                    }
                }

                var x1 = cx + r1 * Math.cos(angle1);
                var y1 = cy + r1 * Math.sin(angle1);
                var x2 = cx + r2 * Math.cos(angle1);
                var y2 = cy + r2 * Math.sin(angle1);
                var x3 = cx + r3 * Math.cos(angle2);
                var y3 = cy + r3 * Math.sin(angle2);
                
                var circle2 = new fabric.Circle({
                    id : 100,
                    radius: ((.95 * r) - (parseInt(overLap) * 20)),
                    left: cx,
                    top: cy,
                    startAngle: sAngle,
                    endAngle: eAngle,
                    originX: 'center', 
                    originY: 'center',
                    stroke: fStrJSON[i]['color'],
                    strokeWidth: thickness,
                    fill: '',
                });
            
                //to add the custom variable to the Circle
                fabric.Circle.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        fName: this.fName,
                        sigment: this.sigment
                       });
                    };
                })(fabric.Circle.prototype.toObject);

                circle2.fName = fStrJSON[i]['featureName'];
                circle2.sigment = fStrJSON[i]['startPos'] + " .. " + fStrJSON[i]['endPos'] + " = " + fStrJSON[i]['lengthOfFeature'];
                circle2.async = true;

                var t2 = new fabric.Polygon(
                    [{x:x1,y:y1},{x:x2,y:y2},{x:x3,y:y3}],
                    {fill:fStrJSON[i]['color']}
                );
                
                var name = new fabric.Group([ circle2, t2], {
                    id: 100,
                    perPixelTargetFind: true,
                    selectable: false
                });
     
                canvas3.add(name);
                
                var pushStr = {'canvasId':canvas3.getObjects().length, 'start':fStrJSON[i]['startPos'], 'end':fStrJSON[i]['endPos'], 'highLightId':(canvas2.getObjects().length - 1), 'type':"feature"};
                canvas3ItemArray.push(pushStr);
                
            }
            else {
                console.log("Need check: "+ i);
            }
        }
    }
    
    if ( $("#arxD_showHideRE").text() == "Hide Enzymes" ) {
        drawRECircularMap(r, L, totalBP, $("#arxD_rotationSlider").slider("value"));
    }
    canvas3.renderAll();
}

function drawRECircularMap(r, L, totalBP, rotation) {
    var prevAngle = 4.71; // 1.5 * PI = 4.71
    
    for (var j = 0; j < REmappingArray.length; j++) { //REmappingArray -- {"startPos":2611,"endPos":2617,"enzyme":"BamH1","sequence":"GGATCC","overLap":1,"cut":"G^GATCC","cutType":"sticky"}
        var angle = (parseInt(REmappingArray[j]['startPos'])/ parseInt(totalBP))*360;
        angle = angle + Number(rotation);
        var angle_rad = 1.5 * Math.PI + angle * Math.PI / 180;  
        var cx = L;
        var cy = 1.2 * r;
        
        var x1 = cx + r * Math.cos(angle_rad);
        var y1 = cy + r * Math.sin(angle_rad);
        
        //(9.947073846723887 - 9.909290047053965 = 0.0378) 
        // (1.5 + 1)*PI = 7.855
        if ( (angle_rad > 4.71 && angle_rad < 7.855) || (angle_rad > 10.99 && angle_rad < 14.13 ) )  {
            var dir = 'left';
        }
        else if ( (angle_rad > 7.855 && angle_rad < 10.99 ) || (angle_rad > 14.13 && angle_rad < 17.27 ) ) {
            var dir = 'right';
        }
        
        if ( prevAngle == 4.71 || (angle_rad - prevAngle) > 0.0378 ) {
            var r1 = r + ( (50) * REmappingArray[j]['overLap'] );
            var x2 = cx + r1 * Math.cos(angle_rad);
            var y2 = cy + r1 * Math.sin(angle_rad);
            
            var line = new fabric.Line([x1,y1,x2,y2], {
                stroke: 'black',
                strokeWidth: 1,
                selectable: false,
            });
        }
        else if ( (prevAngle - angle_rad) > 1.573 ) {
            var r1 = r + ( (100) * REmappingArray[j]['overLap'] );
            var x2 = cx + r1 * Math.cos(angle_rad);
            var y2 = cy + r1 * Math.sin(angle_rad);
            
            var line = new fabric.Line([x1,y1,x2,y2], {
                stroke: 'black',
                strokeWidth: 1,
                selectable: false,
            });
        }
        else if ( ( angle_rad > prevAngle ) &&  (angle_rad - prevAngle) < 0.0378 ) { //the lines are too close by so draw the line with an angle
            var r1 = r + ( (25) * REmappingArray[j]['overLap'] );
            var x3 = cx + r1 * Math.cos(angle_rad);
            var y3 = cy + r1 * Math.sin(angle_rad);
            
            angle_rad = prevAngle  + 0.0378;
            var r2 = r + ( (50) * REmappingArray[j]['overLap'] );
            var x2 = cx + r2 * Math.cos(angle_rad);
            var y2 = cy + r2 * Math.sin(angle_rad);
            
            var line = new fabric.Polyline(
                [{x:x1,y:y1},{x:x3,y:y3},{x:x2,y:y2}], {
                stroke: 'black',
                fill: '',
            });
        }
        else {
            var r1 = r + ( (50/2) * REmappingArray[j]['overLap'] );
            var x2 = cx + r1 * Math.cos(angle_rad);
            var y2 = cy + r1 * Math.sin(angle_rad);
            
            var line = new fabric.Line([x1,y1,x2,y2], {
                stroke: 'black',
                strokeWidth: 1,
                selectable: false,
            });
        }
        
        //itext styles
        var iStyle = "";
        for (k=0; k < REmappingArray[j]['enzyme'].length; k++) {
            iStyle = iStyle + '"'+k+'": {"stroke": "black", "fontWeight": "bold"},';
        }
        
        iStyle = iStyle.substring(0, (iStyle.length - 1) );
        iStyle = JSON.parse('{"0":{' + iStyle + '}}')
        
        var text = new fabric.IText(REmappingArray[j]['enzyme'] + " ("+REmappingArray[j]['startPos']+")", { 
            id: 11011, //to differentiate from other elements when rotating 
            left: x2,
            top: y2,
            fontSize: 12,
            fill: 'black',
            originX: dir, 
            originY: dir,
            styles: iStyle
        });
        
        //to add the custom variable to the IText
        fabric.IText.prototype.toObject = (function(toObject) {
            return function() {
                return fabric.util.object.extend(toObject.call(this), {
                    sequence: this.sequence ,
                    cutPosition: this.cutPosition,
                    cut: this.cut,
                });
            };
        })(fabric.IText.prototype.toObject);
        
        text.sequence = REmappingArray[j]['sequence'];
        text.cutPosition = REmappingArray[j]['cutPosition'];
        text.cut = REmappingArray[j]['cut'];
        text.async = true;
        
        
        text.async = true;
        
        var name = new fabric.Group([ line, text], {
            id: 200,
            perPixelTargetFind: true,
            selectable: false,
        });
        canvas3.add(name);
        prevAngle = angle_rad;
        
        var pushStr = {'canvasId':canvas3.getObjects().length, 'start':REmappingArray[j]['startPos'], 'end':REmappingArray[j]['endPos'], 'highLightId':(canvas2.getObjects().length - 1), 'type':"restictionEnzyme"};
        canvas3ItemArray.push(pushStr);
    }
    canvas3.renderAll();
}

function drawLinearMap(fStrJSON, totalBP, mapWidth, displayName, basePairs) {
    var x = 50;
    var y = 500;
    canvas4.clear();
    var num = "";
    var markBaseLine = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 100, 200, 500, 700, 900, 1000, 1200, 1300, 1500, 1800, 2000, 2200, 2500, 2700, 3000, 3200, 3500, 3700, 3900, 4000, 4200, 4300, 4500, 4700, 5000, 6000, 7500, 10000, 12000, 15000, 16000, 18000, 20000, 22000, 25000, 27500, 30000, 32000, 35000, 37000, 40000];
    target = Math.abs(parseInt(totalBP) / 5);
    
    if (displayName == "" || typeof displayName == 'undefined' || !displayName) {
        displayName = "Test Sequence";
    }
    var iTextName = new fabric.IText(displayName, { 
        fontFamily: 'Courier', 
        left: (document.getElementById('c4').width)/2,
        top: 50,
        originX: 'center', 
        originY: 'center',
        fontSize: 20,
        visible: true,
        fill: 'black'
    });
    
    var iTextBP = new fabric.IText(basePairs.toString()+ " bp", { 
        fontFamily: 'Courier', 
        left: (document.getElementById('c4').width)/2,
        top: 50 + 20,
        originX: 'center', 
        originY: 'center',
        fontSize: 16,
        visible: true,
        fill: 'black'
    });
    
    var name = new fabric.Group([ iTextName, iTextBP ], {
        id: 110011,
        selectable: false,
    });
    canvas4.add(name);
    
    for (var k=1; k<markBaseLine.length; k++) {
        // As soon as a number bigger than target is found, return the previous or current
        if (parseInt(markBaseLine[k]) > target) {
            var p = markBaseLine[k-1];
            var c = markBaseLine[k];
            num = Math.abs( p-target ) < Math.abs( c-target ) ? p : c;
            break;
        }
    }
    if (num == ""){
        var num = markBaseLine[markBaseLine.length-1];
    }
    
    var line = new fabric.Line([x, y, x+mapWidth, y], {
        id: totalBP,
        stroke: 'blue',
        strokeWidth: 3,
        selectable: false,
    });
    canvas4.add(line);
    
    var line1 = new fabric.Line([x,y+5,x+mapWidth,y+5], {
        stroke: 'blue',
        strokeWidth: 3,
        selectable: false,
    });
    canvas4.add(line1);

    for (var j = 0; j < 6; j++){
        
        var t = (parseInt(num)*j).toString();
        var x1 = x + (mapWidth)*num*j/parseInt(totalBP);
        if (j == 5) {
            t = totalBP.toString();
            x1 = x + mapWidth;
        }
        var line2 = new fabric.Line([x1,y+5,x1,y+12], {
            stroke: 'blue',
            strokeWidth: 3,
            selectable: false,
        });
        canvas4.add(line2);
        
        var text = new fabric.IText(t, { 
            left: x1,
            top: y + 21,
            fontSize: 14,
            fill: 'black',
            originX: 'center', 
            originY: 'center',
            selectable: false,
        });
        canvas4.add(text);
    }
    
    if (fStrJSON.length > 0 && $("#arxD_showHideFeatures").text() == 'Hide Features' ) {
        for (var i = 0; i < fStrJSON.length; i++) {
            var s = parseInt(fStrJSON[i]['startPos'])*mapWidth/ parseInt(totalBP);
            var e = parseInt(fStrJSON[i]['endPos'])*mapWidth/ parseInt(totalBP);
            
            var overLap = fStrJSON[i]['overLap'];
            var dir = fStrJSON[i]['direction'];
            
            if (dir === -1) {
                var rectangle = (new fabric.Rect({
                    id: 100,
                    left: x + s,
                    top: y + 20 + (22*overLap),
                    width: (e - s)*(2/3),
                    height: 12,
                    fill: fStrJSON[i]['color'],
                    stroke: '#484848',
                    strokeWidth: 1,
                    perPixelTargetFind: true
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        fName: this.fName,
                        sigment: this.sigment
                       });
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.fName = fStrJSON[i]['featureName'];
                rectangle.sigment = fStrJSON[i]['startPos'] + " .. " + fStrJSON[i]['endPos'] + " = " + fStrJSON[i]['lengthOfFeature'];
                   
                rectangle.async = true;

                var t1 = new fabric.Triangle({    //originX: 'left',
                    width: 12 + 3 + 3,
                    height: (e - s)*(1/3),
                    selectable: false,
                    fill: fStrJSON[i]['color'],
                    stroke: '#484848',
                    strokeWidth: 1,
                    left: x + s + (e - s),
                    top: y + 20 + (22*overLap) - 3,
                    angle: 90
                });
            }
            else {
                var rectangle = (new fabric.Rect({
                    id: 100,
                    left: x + s + (e - s)*(1/3),
                    top: y + 20 + (22*overLap),
                    width: (e - s)*(2/3),
                    height: 12,
                    fill: fStrJSON[i]['color'],
                    stroke: '#484848',
                    strokeWidth: 1,
                    perPixelTargetFind: true
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        fName: this.fName,
                        sigment: this.sigment
                       });
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.fName = fStrJSON[i]['featureName'];
                rectangle.sigment = fStrJSON[i]['startPos'] + " .. " + fStrJSON[i]['endPos'] + " = " + fStrJSON[i]['lengthOfFeature'];
                   
                rectangle.async = true;

                var t1 = new fabric.Triangle({    //originX: 'left',
                    width: 12 + 3 + 3,
                    height: (e - s)*(1/3),
                    selectable: false,
                    fill: fStrJSON[i]['color'],
                    stroke: '#484848',
                    strokeWidth: 1,
                    left: x + s ,
                    top: y + 20 + (22*overLap) + 12 + 4,
                    angle: -90
                });
            }
            var name = new fabric.Group([ rectangle, t1], {
                id: 100,
                selectable: false,
            });
            canvas4.add(name);
        }
    }
    
    if ( $("#arxD_showHideRE").text() == "Hide Enzymes" ) {
        drawRELinearMap(mapWidth, totalBP);
    }
   
    canvas4.renderAll();
}

function drawRELinearMap(mapWidth, totalBP) {
    var x = 50;
    var y = 500;
    var prevLine = 0; 
    var y2 = y - 20;
    
    for (var j = 0; j < REmappingArray.length; j++) { //REmappingArray -- {"startPos":2611,"endPos":2617,"enzyme":"BamH1","sequence":"GGATCC","overLap":1,"cut":"G^GATCC","cutType":"sticky"}
        var x1 = x + parseInt(REmappingArray[j]['startPos'])*mapWidth/ parseInt(totalBP);
        
        if ( prevLine == 0 || (parseInt(REmappingArray[j]['startPos']) - prevLine) > 1000 ) {
            y2 = y - 20;
        }
        else {
            y2 = y2 - 12;
        }
        
        var line2 = new fabric.Line([x1,y,x1,y2], {
            stroke: 'gray',
            strokeWidth: 1,
            selectable: false,
        });
        
        //itext styles
        var iStyle = "";
        for (k=0; k < REmappingArray[j]['enzyme'].length; k++) {
            iStyle = iStyle + '"'+k+'": {"stroke": "black", "fontWeight": "bold"},';
        }
        
        iStyle = iStyle.substring(0, (iStyle.length - 1) );
        iStyle = JSON.parse('{"0":{' + iStyle + '}}')
        
        var text = new fabric.IText(REmappingArray[j]['enzyme'] + " ("+REmappingArray[j]['startPos']+")", { 
            id: 11011, //to differentiate from other elements when rotating 
            left: x1,
            top: y2 - 3,
            fontSize: 12,
            fill: 'black',
            originX: 'left', 
            originY: 'left',
            styles: iStyle
        });
        
        //to add the custom variable to the IText
        fabric.IText.prototype.toObject = (function(toObject) {
            return function() {
                return fabric.util.object.extend(toObject.call(this), {
                    sequence: this.sequence ,
                    cutPosition: this.cutPosition,
                    cut: this.cut,
                });
            };
        })(fabric.IText.prototype.toObject);
        
        text.sequence = REmappingArray[j]['sequence'];
        text.cutPosition = REmappingArray[j]['cutPosition'];
        text.cut = REmappingArray[j]['cut'];
        text.async = true;
        
        var name = new fabric.Group([line2, text], {
            id: 200,
            perPixelTargetFind: true,
            selectable: false,
        });
        canvas4.add(name);
        prevLine = REmappingArray[j]['startPos'];
    }
    canvas4.renderAll();
}

