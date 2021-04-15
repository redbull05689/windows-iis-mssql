function ArxHeatMap(resultSet) {
	this.resultSet = resultSet;
	this.heatMapProperties = {};

	this.heatMapMin = 0;
	this.heatMapMax = 0;
	this.heatMapColorScale = [[0, [5,10,172]], [0.35, [106,137,247]], [0.5, [190,190,190]], [0.6, [220,170,132]], [0.7, [230,145,90]], [1, [178,10,28]]];
}

ArxHeatMap.prototype.makeHeatMap = function(){
	var self = this;
	var resultSet = self.resultSet;

	var queue = [];
	var plateIds = [];
	var results = resultSet.getChildren();
	if(results.length > 0 && results[0].getFieldByName('heatMapProperties'))
		self.heatMapProperties = JSON.parse(results[0].getFieldByName('heatMapProperties').value);

	// Get the unique set of plate ids
	$.each(results, function(i, result) {
		if(self.heatMapProperties.hasOwnProperty('plateIdField') && (self.heatMapProperties.plateIdField.length <= 0 || !result.getFieldByName(self.heatMapProperties.plateIdField).value))
			return;
		
		var plateId = result.getFieldByName(self.heatMapProperties.plateIdField).value;
		if(plateIds.indexOf(plateId) == -1)
			plateIds.push(plateId);
	});

	if(plateIds.length === 0)
	{
		// Assume there is only one plate and name it with the result set name, appending a "-1"
		plateIds.push(resultSet.getFieldByName('name').value + '-1');
	}
	
	//make a div it will get attached to the page
	var holderDiv = $("<div/>");
	var plateSelectHTML = '<div class="popoutPopinButtons popoutButtonVisible"><button class="popinButton">Show Heat Map</button><button class="popoutButton">Pop Heat Map Out of Page</button></div>';
	
	if(plateIds.length > 0)
	{
		plateSelectHTML += '<div class="plateChooser" id="plateChooser"><div class="platePrevNext platePrev" style="visibility:hidden;">&lt; Prev</div><div class="plateSelectHolder"><select id="plateSelect">';
		$.each(plateIds, function(i, thisPlateId) {
			plateSelectHTML += '<option value="' + thisPlateId + '">' + thisPlateId + '</option>';
		});
		plateSelectHTML += '</select></div><div class="platePrevNext plateNext">Next &gt;</div>';
	}

	holderDiv.append(plateSelectHTML);

	$.each(plateIds, function(i, thisPlateId) {
		// div for this plate
		var plateDiv = $("<div/>").attr('plateId',thisPlateId).addClass('individualPlate');
		if(i == 0)
			plateDiv.addClass('visiblePlate');

		plateDiv.append($("<h1>Plate Id: " + thisPlateId + "</h1>"));

		//div that will hold heatmap  could be changed to table
		heatMapHolder = $("<div class='heatMapHolder'></div>");
		heatMapHolderContainer = $("<div class='heatMapHolderContainer'></div>");
		heatMapHolderContainer.append(heatMapHolder)
		plateDiv.append(heatMapHolderContainer);

		// do plate-wide heat map coloring
		var heatMapVals = [];
		$.each(results, function(i, result) {
			if(plateIds.length > 1 && result.getFieldByName(self.heatMapProperties.plateIdField).value !== thisPlateId)
				return;
			curveData = JSON.parse(result.getFieldByName(self.heatMapProperties.curveDataField).value)
			for(var i in curveData["pointData"])
				if(!isNaN(curveData["pointData"][i][1]))
					heatMapVals.push(curveData["pointData"][i][1]);
		})

		var thisPlateMinVal = Math.min(...heatMapVals);
		var thisPlateMaxVal = Math.max(...heatMapVals);
		// end plate-wide heat map coloring

		//get children from result set gets all the child forms (results)
		//iterate through results
		var plateMap = [];
		if(self.heatMapProperties.hasOwnProperty('displayOnlyWells'))
			plateMap = self.heatMapProperties.displayOnlyWells;
		
		$.each(results, function(j, result) {
			if(plateIds.length > 1 && result.getFieldByName(self.heatMapProperties.plateIdField).value !== thisPlateId)
				return;

			if(self.heatMapProperties.hasOwnProperty('readOnlyWells'))
			{
				$.each(self.heatMapProperties.readOnlyWells, function(i, well) {
					var displayVals = result.getFieldByName(well['displayValueField']).value;
					var wellColumns = result.getFieldByName(well['wellColumnField']).value;
					var wellRows = result.getFieldByName(well['wellRowField']).value;
					
					var processDisplayVal = function(j, val) {
						var thisCell = {};
						thisCell['displayValue'] = val;
						
						if(well.hasOwnProperty('heatMap'))
							thisCell['heatMap'] = true;
						
						if(typeof wellColumns === 'string')
							thisCell['wellColumn'] = wellColumns;
						else
							thisCell['wellColumn'] = wellColumns[j];
						
						if(typeof wellRows === 'string')
							thisCell['wellRow'] = wellRows;
						else
							thisCell['wellRow'] = wellRows[j];
						
						var dups = plateMap.filter(function(cell) {
							return cell.wellRow == thisCell.wellRow && cell.wellColumn == thisCell.wellColumn;
						});

						if(dups.length == 0)
							plateMap.push(thisCell);
					}

					if(typeof displayVals == 'string' || typeof displayVals == 'number')
					{
						processDisplayVal(0, displayVals);
					}
					else
					{
						$.each(displayVals, function(i, val) {
							processDisplayVal(i, val);
						});
					}
				});
			}

			var thisPlot = (function(result, plateMap, plateDiv){
				return function(){
					var thisDiv = $("<div class='compoundCurveHolder'><div>");
					//you can get any field values this way result.getFieldByName('Compound ID').value
					if(self.heatMapProperties.hasOwnProperty('curveLabelFields'))
					{
						var curveLabelFields = self.heatMapProperties.curveLabelFields;
						if(curveLabelFields.length > 0)
						{
							var labelDivHtml = "<div class='compoundIdHolder'>";
							$.each(curveLabelFields, function(i, curveLabelField) {
								if(i > 0)
									labelDivHtml += "<br>";
								labelDivHtml += curveLabelField + ": " + result.getFieldByName(curveLabelField).value;
							});
							
							labelDivHtml += "</div>";
							thisDiv.append($(labelDivHtml));
						}
					}
					//hide bottom save/edit buttons on forms
					result.hideButtons = true;
					//hide form headers
					result.showHeader = false;
					//hide the fields that we do not want to see
					if(self.heatMapProperties.hasOwnProperty('fieldsToHide'))
						result.hideFields(self.heatMapProperties.fieldsToHide);
					//draw the form (result) in edit mode
					plateDiv.append(thisDiv);
					result.show(thisDiv,"edit");
					//heat map must be run after show!
					if(self.heatMapProperties.hasOwnProperty('curveDataField'))
					{
						//get the heatmap from the widget on the ic50 curve field and append it to wherever you want it
						var newMap = plateMap.concat(result.getFieldByName(self.heatMapProperties.curveDataField).widget.updatePlateMap());
						plateMap.splice(0,plateMap.length,...newMap);
						//get rid of label for ic50 curve field
						result.getFieldByName(self.heatMapProperties.curveDataField).labelDiv.remove();
					}
				}
			})(result, plateMap, plateDiv);
			if(i==0){
				thisPlot();
			}else{
				queue.push(thisPlot);
			}
		});

		var rows = [], columns = [], displayVals = [], heatMapVals = [];
		$.each(plateMap,function(i, cell) {
			displayVals.push(cell.displayValue);
			if(cell.hasOwnProperty('result') || (cell.hasOwnProperty('heatMap') && cell.heatMap == true))
				heatMapVals.push(cell.displayValue);
			
			if(rows.indexOf(cell.wellRow) == -1)
				rows.push(cell.wellRow);
			
			if(columns.indexOf(cell.wellColumn) == -1)
				columns.push(cell.wellColumn);
		});
		
		rows.sort();
		if(isNaN(columns[0]))
			columns.sort();
		else
			columns.sort(function(a, b){return a-b});
		
		self.heatMapMin = Math.min(...heatMapVals);
		self.heatMapMax = Math.max(...heatMapVals);
		
		var heatMapTable = $('<table></table>');
		if(self.heatMapProperties.hasOwnProperty('columnLabels') && self.heatMapProperties.columnLabels.length == columns.length && columns.length > 0)
		{
			var headerHtml = '<tr>';
			$.each(self.heatMapProperties.columnLabels, function(i, label) {
				headerHtml += '<th>' + label + '</th>';
			});
			headerHtml += '</tr>';
			heatMapTable.append($(headerHtml));
		}
		
		$.each(rows, function(ri, row) {
			var cols = plateMap.filter(function(cell) {
				return cell.wellRow == row;
			});

			var thisRow = $('<tr/>');
			for(colId in columns)
			{
				var theCol = cols.filter(function(cell) {
					return cell.wellColumn == columns[colId];
				});
				
				var thisCell = null;
				var colorInfo = {thisColor:'black',bgColor:'white'};
				
				if(theCol.length == 1)
				{
					var col = theCol[0];

					if(col.hasOwnProperty('result'))
					{
						colorInfo = ArxHeatMap.getHeatMapCellColor(self.getHeatMapColor(col.displayValue), col.result.pointData['enabled'][col.resultIndex]);
						thisCell = $("<td><div class='heatMapCell' data-heatmapcellid='"+col.id+"' style='color:"+colorInfo.thisColor+";background-color:"+colorInfo.bgColor+"'>"+col.displayValue+"</div></td>");
						col.heatMapCell = thisCell;
						
						// handle clicks
						thisCell.on('click',(function(col, thisCell){
							return function(){
								col.result.toggleCurvePoint(col.resultIndex);
							}
						})(col, thisCell));

						// handle refresh (when a point on the plot is clicked)
						thisCell.on('knockout-refresh',(function(col, thisCell){
							return function(){
								var colorInfo = ArxHeatMap.getHeatMapCellColor(self.getHeatMapColor(col.displayValue), col.result.pointData['enabled'][col.resultIndex]);
								var cellDiv = $(thisCell).find('.heatMapCell');
								if(cellDiv.length == 1)
								{
									$(cellDiv)[0].style.background = colorInfo.bgColor;
									$(cellDiv)[0].style.color = colorInfo.thisColor;
								}
							}
						})(col, thisCell));
					}
					else
					{
						// This is one of the read-only wells (controls, etc) that are not "live"
						if(col.hasOwnProperty('heatMap') && col.heatMap == true)
							colorInfo = ArxHeatMap.getHeatMapCellColor(self.getHeatMapColor(col.displayValue), true);
						
						thisCell = $("<td><div class='heatMapCell' style='color:"+colorInfo.thisColor+";background-color:"+colorInfo.bgColor+"'>"+col.displayValue+"</div></td>");
					}
				}
				else
				{
					thisCell = $("<td><div class='heatMapCell' style='color:white;background-color:white'>EMP</div></td>");
				}
				
				if(thisCell)
					thisRow.append(thisCell);
			}
			
			heatMapTable.append(thisRow);
		});
		
		heatMapHolder.append(heatMapTable);
		holderDiv.append(plateDiv);
	});

	var saveButton = $('<button id="saveAnalysisResultsButton" class="plateSaveResultsButton">Save Results</button>');
	saveButton.on('click',(function(results){
		return function(){
			//iterate through results save them if they have changed
			$.each(results,function(i,result){
				if(result.hasChanged){
					console.log('saving result:',result);
					result.save(true);
				}
			});
			//remove my container div
			holderDiv.remove();
			//reload resultSet in view Mode
			makeForm(resultSet.id,"arxOneContainer","view")
		}
	})(results));

	holderDiv.append(saveButton)

	$('body').on('change','#plateSelect', function(event){
		$('.individualPlate').removeClass('visiblePlate');
		$('.individualPlate[plateid="' + $(this).val() + '"]').addClass('visiblePlate');
	
		if($('#plateSelect > option:selected').prev('option').length < 1){
			$('.platePrevNext.platePrev').css('visibility','hidden');
		}
		if($('#plateSelect > option:selected').prev('option').length > 0){
			$('.platePrevNext.platePrev').css('visibility','visible');
		}
		if($('#plateSelect > option:selected').next('option').length > 0){
			$('.platePrevNext.plateNext').css('visibility','visible');
		}
		if($('#plateSelect > option:selected').next('option').length < 1){
			$('.platePrevNext.plateNext').css('visibility','hidden');
		}

		// Maintain popup in case it is open
		if(typeof window.popupHeatmapWindow !== 'undefined'){
			var html = $(".individualPlate.visiblePlate .heatMapHolder").html();
			$(window.popupHeatmapWindow.document.body).html('<link rel="stylesheet" type="text/css" href="https://dev.arxspan.com/arxlab/assay2/js/jsfit/jsFit.css?17">' + html);
			$(".heatMapCell", window.popupHeatmapWindow.document).click(function(e){
				var heatMapCellId = $(e.target).attr('data-heatmapcellid');
				$('.heatMapCell[data-heatmapcellid="'+heatMapCellId+'"]').click();
			});
		}
	});

	$('body').on('click','.platePrevNext.platePrev', function(event){
		if ($('#plateSelect > option:selected').prev('option').length > 0) {
			$('#plateSelect > option:selected').removeAttr('selected').prev('option').attr('selected', 'selected').change();
		}
	});

	$('body').on('click','.platePrevNext.plateNext', function(event){
		if ($('#plateSelect > option:selected').next('option').length > 0) {
			$('#plateSelect > option:selected').removeAttr('selected').next('option').attr('selected', 'selected').change();
		}
	});

	$('body').on('click','.popoutButton', function(event){
		if(typeof window.popupHeatmapWindow !== 'undefined'){
			window.popupHeatmapWindow.close();
		}
		window.popupHeatmapWindow = window.open(null,null,
"height=360,width=710,status=yes,toolbar=no,menubar=no,location=no");
		var html = $(".individualPlate.visiblePlate .heatMapHolder").html();
		$(window.popupHeatmapWindow.document.body).html('<link rel="stylesheet" type="text/css" href="https://dev.arxspan.com/arxlab/assay2/js/jsfit/jsFit.css">' + html);
		
		$(".heatMapCell", window.popupHeatmapWindow.document).click(function(e){
			var heatMapCellId = $(e.target).attr('data-heatmapcellid');
			$('.heatMapCell[data-heatmapcellid="'+heatMapCellId+'"]').click();
		});

		$(".heatMapHolderContainer").addClass('makeHidden');
		$('.popoutPopinButtons').removeClass('popoutButtonVisible').addClass('popinButtonVisible');
	});
	$('body').on('click','.popinButton', function(event){
		if(typeof window.popupHeatmapWindow !== 'undefined'){
		//	window.popupHeatmapWindow.close();
		}
		$(".heatMapHolderContainer").removeClass('makeHidden');
		$('.popoutPopinButtons').addClass('popoutButtonVisible').removeClass('popinButtonVisible');
	});

	window.setTimeout((function(queue){
		function runQueue(){
			if(queue.length){
				queue[0]();
				queue.shift();
				window.setTimeout(runQueue,150)
			}
		}
		return runQueue;
	})(queue),150)

	$(window).on("scroll", function(e) {
		if($(window).scrollTop() > 213){
			$('.heatMapHolderContainer').addClass("makeFixed");
		}
		else{
			$('.heatMapHolderContainer').removeClass("makeFixed");
		}
	});

	return holderDiv;
}


ArxHeatMap.prototype.getHeatMapColor = function(val){
	var self = this;
	var L = [];
	var startIndex = 0;
	var endIndex = 0;
	var percent = (val - self.heatMapMin) / (self.heatMapMax - self.heatMapMin);
	$.each(self.heatMapColorScale,function(i,cScaleItem){
		if(i==self.heatMapColorScale.length-1){
			startIndex = i;
			endIndex = i;
			return false;
		}
		if(percent>=self.heatMapColorScale[i][0] && percent<=self.heatMapColorScale[i+1][0]){
			startIndex = i;
			endIndex = i + 1;
			return false;
		}
	});
	$.each([1,2,3],function(i,x){
		var startRangeNumber = self.heatMapColorScale[startIndex][0]*(self.heatMapMax-self.heatMapMin);
		var endRangeNumber = self.heatMapColorScale[endIndex][0]*(self.heatMapMax-self.heatMapMin);
		var startColor = self.heatMapColorScale[startIndex][1][i];
		var endColor = self.heatMapColorScale[endIndex][1][i];
		var colorRange = Math.abs(startColor-endColor);
		var addAmount = Math.floor( colorRange * (val-startRangeNumber) / (endRangeNumber-startRangeNumber) );
		var finalColor = 0;
		if(startColor>=endColor){
			finalColor = startColor - addAmount
		}else{
			finalColor = startColor + addAmount
		}
		L.push(finalColor);
	});
	return 'rgb('+L.join(',')+')';
}

ArxHeatMap.getHeatMapCellColor = function(heatMapColor, enabled) {
	var bgColor = 'white';
	var thisColor = "black";
	
	if(enabled){
		bgColor = heatMapColor;
		thisColor = "white";
	}
	
	return {bgColor:bgColor,thisColor:thisColor};
}