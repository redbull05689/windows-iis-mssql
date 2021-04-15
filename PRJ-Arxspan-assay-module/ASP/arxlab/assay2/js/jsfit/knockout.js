function KnockoutPlot(field,viewState){
	this.field = field;
	this.wellData = [];
	this.paramRows = [];
	this.hasChanged = false;
	this.viewState = viewState;

	this.curve = {};
	if(field.hasOwnProperty('value') && field.value.length)
		this.curve = JSON.parse(field.value);
	this.fitter = new arxFit(this.curve.fitType);
	
	this.drawExcludePoint = function cross(ctx, x, y, radius, shadow) {
					   var size = radius * Math.sqrt(Math.PI) / 2;
						ctx.moveTo(x - size, y - size);
						ctx.lineTo(x + size, y + size);
						ctx.moveTo(x - size, y + size);
						ctx.lineTo(x + size, y - size);
					};

	this.initPlotData();
}

KnockoutPlot.prototype.initPlotData = function(){
	var self = this;
	if(!self.curve.hasOwnProperty("pointData")){
		//handle error
	}
	self.curve["actualParams"] = self.curve["initialParams"];
	self.pointData = self.curve;
	self.pointData["data"] = self.curve["pointData"];
	self.numPoints = self.pointData["data"].length;
	if(!self.pointData.hasOwnProperty("enabled")){
		self.pointData["enabled"] = [];
	}
	self.pointData["enabled"] = self.getEnabledPoints();
	if(!self.pointData.hasOwnProperty("outliers")){
		self.pointData["outliers"] = [];
		for(var i=0;i<self.numPoints;i++)
			self.pointData["outliers"].push([self.ensureString(self.pointData["data"][i][0]), self.ensureString(self.pointData["data"][i][1])]);
	}
	if(!self.pointData.hasOwnProperty("curvePoints"))
		self.pointData["curvePoints"] = [];

	// Setup the plot data
	self.dataPlot = {
		label: 'Data',
		data: self.pointData["data"],
		highlightColor: "rgb(255, 0, 0)",
		points: {
			radius:5,
			symbol:"circle",
			fill:true,
			fillColor:"rgb(255, 191, 0)",
			lineWidth:1}
	};
	self.outlierPlot = {
		label: 'Outliers',
		data: self.pointData["outliers"],
		highlightColor: "rgb(255, 191, 0)",
		points:{
			radius:5,
			fill:true,
			lineWidth:4,
			fillColor:"rgb(255, 0, 0)",
			symbol: self.drawExcludePoint
		}
	};
	self.doCurveFit();
	self.curvePlot = {
		label: 'Fit',
		clickable: false,
		hoverable: false,
		lines: {show:true,lineWidth:1},
		points: {show:false},
		data: self.pointData["curvePoints"]
	};
	// Make the plot
	self.plotOptions = {
		canvas:true,
		series:{
			lines:{show:false},
			points:{show:true}},
		grid:{clickable:true, hoverable:true,margin:{bottom:5}},
		xaxis:{autoscaleMargin:0.05},
		yaxis:{autoscaleMargin:0.05},
		colors:["rgb(255, 191, 0)", "rgb(255, 0, 0)", "rgb(51, 173, 255)"]};

	self.plotData = [self.dataPlot, self.outlierPlot, self.curvePlot];
}

KnockoutPlot.prototype.paramTableAddFields = function(tableRow,fieldNames,parentFieldId,rowId){
	var self = this;
	$.each(fieldNames,function(i,fieldName){
		thisField = self.field.parentField.getFieldByName(fieldName);
		if(thisField){
			thisTD = $("<td/>");
			thisTD.append(thisField.theO);
			tableRow.append(thisTD);
			thisField.hide();
		}else{
			console.log("Cannot find field:",fieldName);
		}
	});

	//Add spot for the calculated outputs
	tableRow.append($("<td><p id='calout_" + parentFieldId + "_" + rowId + "'></p></td>"));
}

KnockoutPlot.prototype.takeField = function(fieldName){
	var self = this;
	thisField = self.field.parentField.getFieldByName(fieldName);
	thisField.hide();
	return thisField.theO;
}

KnockoutPlot.prototype.processCurveRow = function(name,theRow){
	D = {};
	D["name"] = name;
	if(theRow && theRow !== undefined){
		D["fixed"] = theRow.children('td').eq(2).children('input').prop("checked");
		min = theRow.children('td').eq(3).children('input').val();
		if(!isNaN(min) && min!=""){
			D["minVal"] = Number.parseFloat(min);
		}
		max = theRow.children('td').eq(4).children('input').val();
		if(!isNaN(max) && max!=""){
			D["maxVal"] = Number.parseFloat(max);
		}
	}
	return D;
}

KnockoutPlot.prototype.getInitialParameters = function(){
	var self = this;
	var L = [];
	rows = self.paramRows;
	$.each(rows,function(i,row){
		if(row && row !== undefined) {
			var v = row.children("td").eq(1).children('input').val();
			if (!isNaN(v) && v!=""){
				L.push(Number.parseFloat(v));
			}else{
				L.push(undefined);
			}
		}
	})
	return L;
}

KnockoutPlot.prototype.getParamTable = function(parentDiv){
	var self = this;

	if(self.field.parentField.getFieldByName('Heat Map'))
		self.field.parentField.getFieldByName('Heat Map').hide();

	var paramNames = self.curve.fitType.curveParameterNames;
	var paramConfig = self.curve.fitType.parameterDisplayConfig;
	self.paramTable = $("<table class='arxFitParamTable'/>");
	
	if(paramNames && paramNames.length > 0)
	{
		var paramTableHtml = "<tr><th></th>";
		for(var i in self.curve.fitType.curveParameterConditions)
			paramTableHtml += "<th>"+self.curve.fitType.curveParameterConditions[i]+"</th>";
		paramTableHtml += "</tr>";
		self.paramTable.append($(paramTableHtml));
		
		self.paramRows = [];

		// find the parentField id to pass in for table fields		
		var parentFieldId = self.field.parentField.id;

		for(var i in paramNames)
		{
			var thisRow = $('<tr><td>'+paramConfig[paramNames[i]]['label']+'</td></tr>');
			self.paramTableAddFields(thisRow, paramConfig[paramNames[i]]['conditions'], parentFieldId, i);
			self.paramTable.append(thisRow);
			self.paramRows.push(thisRow);
		}
	}

	var dataRowHtml = "<tr class='dataRow'><td colspan='5' align='right'><table><tr><td class='refitCurveButton'></td>"
	var displayParams = self.curve.fitType.displayParameters;

	// if(displayParams && displayParams.length > 0)
	// {
	// 	for(var i in displayParams)
	// 	{
	// 		var className = displayParams[i]+'TD';
	// 		var displayName = paramConfig[displayParams[i]]['label'];
	// 		dataRowHtml += '<td class="dataRowLabel">'+displayName+'</td><td class='+className+'></td>';
	// 	}
	// }
	
	var dataRow = $(dataRowHtml + "</tr></table></td></tr>");
	if(displayParams && displayParams.length > 0)
	{
		for(var i in displayParams)
		{
			var className = '.'+displayParams[i]+'TD';
			var displayName = paramConfig[displayParams[i]]['label'];
			dataRow.find(className).append(self.takeField(displayName))
		}
	}
	
	if(self.viewState == "edit"){
		self.refitButton = $("<button>Refit Curve</button>");
		self.refitButton.on('click',(function(self){
			return function(){
				self.hasChanged = true;
				self.refitCurve.call(self)
			}
		})(self))
		dataRow.find('.refitCurveButton').append(self.refitButton);
	}

	self.paramTable.append(dataRow);
	
	$( "<style>.arxFitParamTable input{width:60px!important;}</style>" ).appendTo( "head" )
	parentDiv.append(self.paramTable);
}

KnockoutPlot.prototype.getFitOptions = function(){
	var self = this;
	var L = [];
	var paramNames = self.curve.fitType.curveParameterNames;
	if(paramNames && paramNames.length > 0)
		for(var i in paramNames)
			L.push(self.processCurveRow(paramNames[i],self.paramRows[i]));
	return L;
}

KnockoutPlot.prototype.refitCurve = function(){
	var self = this;
	if (self.viewState == "edit"){
		self.curve["fitOptions"] = self.getFitOptions();
		self.curve["initialParams"] = self.getInitialParameters();
	}
	self.doCurveFit();
	self.redraw();
}

KnockoutPlot.prototype.doCurveFit = function(){
	var self = this;
	var fitResults = {}
	var wasError = false;
	try{
		fitResults = self.fitter.fitCurve(self.onlyIncluded(self.pointData["data"], 0), self.onlyIncluded(self.pointData["data"], 1), self.curve["initialParams"], self.curve["fitOptions"]);
	}catch(err){
		// remove curve points and empty actualParams since the fit did not converge
		self.replaceArray(self.pointData["curvePoints"],[]);
		self.curve["actualParams"] = [];
		wasError = true
	}
	
	if(!wasError){
		self.curve["actualParams"] = fitResults["params"];
		r = self.fitter.arxFitPlotCurve(Math.min(...self.onlyIncluded(self.pointData["data"], 0)), Math.max(...self.onlyIncluded(self.pointData["data"], 0)), function(x){ return window[self.curve.fitType.type]['curveFunction'](x, fitResults['params'])}, 500);
		rData = [];
		for(var i in r["x"])
			rData.push([r["x"][i],r["y"][i]]);
		self.replaceArray(self.pointData["curvePoints"],rData);
	}

	if(self.viewState !== "getImage")
	{
		var displayParams = self.curve.fitType.displayParameters;
		if(displayParams && displayParams.length > 0)
		{
			var paramNames = self.curve.fitType.curveParameterNames;
			var paramConfig = self.curve.fitType.parameterDisplayConfig;
			
			for(var i in displayParams)
			{
				var paramPos = paramNames.indexOf(displayParams[i]);
				var displayName = paramConfig[displayParams[i]]['label'];

				var newVal = Number();
				if(self.curve.hasOwnProperty('actualParams') && self.curve['actualParams'].length >= paramPos)
				{
					if(displayParams[i] === 'hillSlope')
						newVal = self.curve['actualParams'][paramPos].toFixed(2);
					else if(displayParams[i] === 'inflectionPoint')
						newVal = Math.pow(10, self.curve["actualParams"][paramPos]).toPrecision(3);
				}
				
				self.field.parentField.getFieldByName(displayName).value = newVal;
				self.field.parentField.getFieldByName(displayName).theO.val(newVal);
			}
		}
		// Set a timeout with no time to put this at the end of the queue (or it doesn't work on the first page load)
		var parentFieldId = self.field.parentField.id;		

		setTimeout(function(){
			// loop the actual vaules and put them in the calulated outputs
			for (var ip in self.curve["actualParams"]){
				// 2 == inflectionPoint, and we need to do some extra math to it
				if (ip == 2){
					$("#calout_" + parentFieldId + "_" + ip).text(Math.pow(10,self.curve["actualParams"][ip]).toPrecision(3));
				} else{
					$("#calout_" + parentFieldId + "_" + ip).text(self.curve["actualParams"][ip].toFixed(2));
				}	
			}
		});
	}
}

KnockoutPlot.prototype.draw = function(){
	var self = this;
	self.wrapperDiv = $("<div/>");
	self.plotDiv = $("<div/>");
	$(self.wrapperDiv).css({position:'relative'});
	$(self.plotDiv).css({width:'600px',height:'300px',position:'relative','margin-bottom':'25px'});
	self.wrapperDiv.append(self.plotDiv);

	if(self.viewState == "edit"){

		self.plotDiv.bind('plotclick', function(event, pos, item) {
			if(item && item.hasOwnProperty("dataIndex") && item["dataIndex"] >= 0 && item["dataIndex"] < item["series"]["data"].length){
				self.toggleCurvePoint(item["dataIndex"]);
			}
		});
	}
	else{
		self.plotData[0]["clickable"] = false;
		self.plotData[0]["hoverable"] = false;
		self.plotData[1]["clickable"] = false;
		self.plotData[1]["hoverable"] = false;
	}

	self.thePlot = $.plot(self.plotDiv, self.plotData, self.plotOptions);
	self.getParamTable(self.wrapperDiv);
	self.refitCurve();
	return self.wrapperDiv;
}

KnockoutPlot.prototype.updatePlateMap = function(){
	var self = this;
	var wellRows = self.field.parentField.getFieldByName('Well Row').value;
	var wellColumns = self.field.parentField.getFieldByName('Well Column').value;
	var wellAddresses = self.field.parentField.getFieldByName('Well Address').value;
	
	if(self.wellData.length === 0 && wellAddresses && wellRows && wellColumns)
	{
		$.each(self.pointData["data"],function(i,point){
			var thisCell = {};
			if(wellRows.length === wellAddresses.length)
				thisCell['wellRow'] = wellRows[i];
			else
				thisCell['wellRow'] = wellRows;
			
			if(wellColumns.length === wellAddresses.length)
				thisCell['wellColumn'] = wellColumns[i];
			else
				thisCell['wellColumn'] = wellColumns;

			thisCell['result'] = self;
			thisCell['resultIndex'] = i;
			thisCell['wellAddress'] = wellAddresses[i];
			thisCell['displayValue'] = self.ensureNumber(point[1]);
			thisCell['id'] = Math.floor(Math.random() * 1500) + Date.now();
			self.wellData.push(thisCell);
		});
	}
	else
	{
		$.each(self.wellData, function(i, well) {
			if(well && well.hasOwnProperty('heatMapCell'))
				$(well.heatMapCell).trigger('knockout-refresh');
		});
	}
	
	return self.wellData;
}

KnockoutPlot.prototype.getImage = function(cb){
	var self = this;
	if(self.plotData && self.plotOptions)
	{
		var wrapperDiv = $("<div/>");
		var plotDiv = $("<div/>");
		$(wrapperDiv).css({position:'relative'});
		$(plotDiv).css({width:'200px',height:'100px',position:'relative'});
		wrapperDiv.append(plotDiv);

		var imgPlotData = JSON.parse(JSON.stringify(self.plotData));
		imgPlotData[0]["points"]["radius"] = 2;
		imgPlotData[1]["points"]["radius"] = 2;
		imgPlotData[1]["points"]["lineWidth"] = 2;
		imgPlotData[1]["points"]["symbol"] = this.drawExcludePoint;

		var imgPlot = $.plot(plotDiv, imgPlotData, self.plotOptions);

		var canvas = imgPlot.getCanvas();
		if(canvas)
			return canvas.toDataURL();
	}

	return '';
}

KnockoutPlot.prototype.redraw = function(){
	var self = this;
	if(self.thePlot)
	{
		self.thePlot.setData(self.plotData);
		self.thePlot.draw();
		self.updatePlateMap();
		self.curve["image"] = self.getImage();
		self.dataChanged();
	}
}

KnockoutPlot.prototype.onlyIncluded = function(L, idx){
	var L2 = [];
	for (var i=0;i<L.length;i++){
		if(!L[i][idx].substring){
			L2.push(L[i][idx]);
		}
	}
	return L2;
}

KnockoutPlot.prototype.onlyExcluded = function(L){
	var L2 = [];
	for (var i=0;i<L.length;i++){
		if(L[i].substring){
			L2.push(L[i]);
		}
	}
	return L2;
}

KnockoutPlot.prototype.getEnabledPoints = function(){
	var self = this;
	var L = [];
	$.each(self.pointData["data"],function(i,thisPoint){
		if(thisPoint[1].toString().substring(0,1)=="x" || thisPoint[1].substring){
			L.push(false);
		}else{
			L.push(true);
		}
	});
	return L;
}

KnockoutPlot.prototype.ensureString = function(inStr){
	var self = this;
	if(inStr.toString().substring(0,1)=="x"){
		return inStr;
	}else{
		return 'x'+inStr;
	}
}

KnockoutPlot.prototype.ensureNumber = function(inStr){
	var self = this;
	if(inStr.toString().substring(0,1)=="x"){
		return Number.parseFloat(inStr.toString().replace("x",""));
	}else{
		return Number.parseFloat(inStr);
	}
}

KnockoutPlot.prototype.toggleString = function(inStr){
	var self = this;
	if(inStr.toString().substring(0,1)=="x" || inStr.substring){
		return Number.parseFloat(inStr.toString().replace("x",""));
	}else{
		return 'x'+inStr
	}
}

KnockoutPlot.prototype.toggleCurvePoint = function(pointNumber){
	var self = this;
	self.hasChanged = true;
	self.pointData["data"][pointNumber][0] = self.toggleString(self.pointData["data"][pointNumber][0]);
	self.pointData["data"][pointNumber][1] = self.toggleString(self.pointData["data"][pointNumber][1]);
	self.pointData["outliers"][pointNumber][0] = self.toggleString(self.pointData["outliers"][pointNumber][0]);
	self.pointData["outliers"][pointNumber][1] = self.toggleString(self.pointData["outliers"][pointNumber][1]);
	self.pointData["enabled"] = self.getEnabledPoints();
	self.doCurveFit();
	self.redraw();
	if(typeof window.popupHeatmapWindow !== 'undefined'){
		var html = $(".heatMapHolder").html();
		$(window.popupHeatmapWindow.document.body).html('<link rel="stylesheet" type="text/css" href="https://dev.arxspan.com/arxlab/assay2/js/jsfit/jsFit.css">' + html);
		$(".heatMapCell", window.popupHeatmapWindow.document).click(function(e){
			var heatMapCellId = $(e.target).attr('data-heatmapcellid');
			$('.heatMapCell[data-heatmapcellid="'+heatMapCellId+'"]').click();
		});
	}
}

KnockoutPlot.prototype.replaceArray = function(a,b){
	var self = this;
	//allows b to be assinged to a without replacing reference
	a.splice(0,a.length,...b)
}

KnockoutPlot.prototype.getValue = function(){
	var self = this;
	return (function(self){
		return function(){
			var r = $.extend(true,{},self.curve);
			delete r["pointData"]["curvePoints"];
			return JSON.stringify(r);
		}
	})(self);
}

KnockoutPlot.prototype.dataChanged = function(){
	var self = this;
	if (self.hasChanged){
		if(self.wrapperDiv[0].onchange){
			self.wrapperDiv[0].onchange();
		}
	}
}