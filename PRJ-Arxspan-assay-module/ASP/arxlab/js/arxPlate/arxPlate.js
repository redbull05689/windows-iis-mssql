$.widget( "arx.plateMap", {
    options: { 
        plateWidth: 12,
        plateHeight: 8,
		wellSize: '30px',
        plateContents: [],
		selectedWells: {},
		plateDisplayId: '',
		wellConfigurations: [],
		plateType: 'cherryPick',
		allowFileUpload:false,
		allowInteractiveEdit:true,
		defaultWellConfigurationKey: 'empty',
		rowLabels: ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','AA','AB','AC','AD','AE','AF'],
		columnLabels: ['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50'],
		mappingTemplate: {'samplePattern':{'primaryLayout':'topToBottom'}}
    },
	
	getPlateContents:function(includeEmptyWells) {
		var plateContents = this.options.plateContents;
		
		if(includeEmptyWells !== undefined && includeEmptyWells)
		{
			var plateMap = this;
			var emptyWellObj = {};
			emptyWellObj['numComponents'] = 0;
			
			$('.plate-well-display').each(function() {
				if(Object.keys(plateMap.getWellDataById(this.id)).length == 0)
				{
					thisWellObj = emptyWellObj;
					thisWellObj['id'] = this.id;
					plateContents.push(thisWellObj);
				}
			});
		}
		
		var retVal = this.options;
		retVal['plateContents'] = plateContents;
		return retVal;
	},
	
	setPlateContents:function(newContents) {
		var thePlate = this;
		$each(newContents, function(index, value) {
			if(value.hasOwnProperty('id'))
				thePlate.setWellDataById(value['id'], value);
			else if(value.hasOwnProperty('rowNum') && value.hasOwnProperty('colNum'))
				thePlate.setWellDataByCoords(value['rowNum'], value['colNum'], value);
			else
				alert('Unable to locate well for data: ' + JSON.stringify(this));
		});
		
		this._refresh(false);
	},
	
	getWellConfigurations:function() {
		this.options.wellConfigurations.sort( function(a,b) {
			return a.displayOrder - b.displayOrder;
		});
		
		return this.options.wellConfigurations;
	},

	isWellIdEmpty:function(wellId) {		
		var wellDataKeys = Object.keys(this.getWellDataById(wellId));
		return !(wellDataKeys.length > 1 || (wellDataKeys.length == 1 && wellDataKeys[0] != this.options.defaultWellConfigurationKey));
	},
	
	isWellEmptyByCoords:function(row, col) {
		return this.isWellIdEmpty(this.getWellIdByCoords(row, col));
	},
	
	getWellDataById:function(wellId) {
		for(var i = 0, len = this.options.plateContents.length; i < len; i++)
			if(this.options.plateContents[i].hasOwnProperty('id') && this.options.plateContents[i]['id'] == wellId)
				return this.options.plateContents[i];
			
		return {};
	},
	
	getWellDataByCoords:function(row, col) {
		return getWellDataById(getWellIdByCoords(row, col));
	},
	
	clearWellDataById:function(wellId) {
		var itemToRemove = -1;

		for(var i = 0, len = this.options.plateContents.length; i < len; i++)
		{
			if(this.options.plateContents[i].hasOwnProperty('id') && this.options.plateContents[i]['id'] == wellId)
			{
				itemToRemove = i;
				break;
			}
		}

		if(itemToRemove >= 0)
			this.options.plateContents.splice(itemToRemove, 1);
	},
	
	clearWellDataByCoords:function(row, col) {
		return clearWellDataById(getWellIdByCoords(row, col));
	},
	
	setWellDataById:function(wellId, wellData) {
		this.clearWellDataById(wellId);
		
		// Explicitly set the id
		wellData['id'] = Number(wellId);
		
		// Explicitly set the number of components
		var plateMap = this;
		var numComponents = 0;
		$.each(plateMap.options.wellConfigurations, function(index, value) {
			var keyName = value['keyName'];
			if(keyName != plateMap.options.defaultWellConfigurationKey && wellData.hasOwnProperty(keyName))
				numComponents += wellData[keyName].length;
		});
		
		wellData['numComponents'] = numComponents;		
		var rowNum = $('#'+wellId).attr('rowNum');
		var colNum = $('#'+wellId).attr('colNum')
		wellData['wellCoordinates'] = {'rowNum':rowNum,'colNum':colNum};
		wellData['wellAddress'] = this.options.rowLabels[rowNum-1] + this.options.columnLabels[colNum-1];
		wellData['wellRow'] = this.options.rowLabels[rowNum-1];
		wellData['wellColumn'] = this.options.columnLabels[colNum-1];

		this.options.plateContents.push(wellData);
		this._refresh(false);
	},
	
	setWellDataByCoords:function(row, col, wellData) {
		return this.setWellDataById(this.getWellIdByCoords(row, col), wellData);
	},
	
	getWellIdByCoords:function(row, col) {
		return $('[rowNum='+row+'][colNum='+col+']').attr('id');
	},
	
	clearSelection: function() {
		var plateMap = this;
		$.each(Object.keys(this.options.selectedWells), function(index, value){ plateMap._clearWellSelection(value); });
	},
	
	clearPlateContents: function() {
		while(this.options.plateContents.length > 0) {
			this._deselectWell(this.options.plateContents[0]['id']);
			this.clearWellDataById(this.options.plateContents[0]['id']);
		}
		
		this._refresh(false);
	},
	
	clearSelectedWellData: function() {
		var plateMap = this;
		$.each(Object.keys(this.options.selectedWells), function(index, value){
			plateMap.clearWellDataById(value);
			plateMap._deselectWell(value);
		});
		
		this._refresh(false);
	},
	
	_clearWellSelection: function(wellId) {
		if(wellId in this.options.selectedWells)
		{
			delete this.options.selectedWells[wellId];
			$('#'+wellId).removeClass('ui-selected');
			this._checkSelectAllButtons(wellId);
			this._checkButtonVisibility();
		}
	},
	
	_deselectWell: function(wellId) {
		if(wellId in this.options.selectedWells)
		{
			if(this.options.selectedWells[wellId] == 1)
				this._clearWellSelection(wellId);
			else
				this.options.selectedWells[wellId] -= 1;
		}
	},
	
	_selectWell: function(wellId) {
		if(wellId in this.options.selectedWells && this.options.selectedWells[wellId] > 0)
		{
			this.options.selectedWells[wellId] += 1;
		}
		else
		{
			$('#'+wellId).addClass('ui-selected');
			this.options.selectedWells[wellId] = 1;
			this._checkSelectAllButtons(wellId);
			this._checkButtonVisibility();
		}
	},
	
	_enableLassoSelect:function() {
		if(!this.options.allowInteractiveEdit)
			return;
		
		var plateMap = this;
		$("table").selectable( {
			appendTo: '#'+this.options.plateDisplayId,
			filter: 'canvas',
			tolerance: 'touch',
			distance: 1,
			selected: function(event, ui)
			{
				plateMap._selectWell(ui.selected.id);
			},
			unselected: function(event, ui)
			{
				if(ui.unselected.id in plateMap.options.selectedWells)
				{
					plateMap._clearWellSelection(ui.unselected.id);
					plateMap._selectWell(ui.unselected.id);
				}
			}
		});
	},
    
	_enableClickSelect:function() {
		if(!this.options.allowInteractiveEdit)
			return;
		
        //Register click handlers for select row and column buttons
		var plateMap = this;
		$('.plate-well-display').each(function() {
			$(this).click({id: this.id, plateMap: plateMap}, function(event) {
				if(event.data.id in plateMap.options.selectedWells)
					plateMap._clearWellSelection(event.data.id);
				else
					plateMap._selectWell(event.data.id);
				
				$('#'+event.data.id).blur();
			})
		});
	},

	_enableSelectAll:function() {
		if(!this.options.allowInteractiveEdit)
			return;
		
		var plateMap = this;
		$('.select-all-button').each(function() {
			$(this).click({id: this.id, plateMap: plateMap}, function(event) {
				var buttonId = event.data.id;
				var plateMap = event.data.plateMap;
				var rowNum = $('#'+buttonId).attr('rowNum');
				var colNum = $('#'+buttonId).attr('colNum');
				var thisSelection = [];

				if(rowNum === '0')
					$('.plate-well-display[colNum='+colNum+']').each(function(){thisSelection.push(this.id);});
				else if(colNum === '0')
					$('.plate-well-display[rowNum='+rowNum+']').each(function(){thisSelection.push(this.id);});
				else
					alert('Error making selection, please try again.');
				
				if($('#'+buttonId).hasClass('select-all-off'))
					$.each(thisSelection, function(index, value){plateMap._selectWell(value);});
				else if($('#'+buttonId).hasClass('select-all-on'))
					$.each(thisSelection, function(index, value){plateMap._deselectWell(value);});
			})
		});
        
	},
	
    _create: function() {
		// Setup default values
		if(this.options.wellConfigurations.length === 0)
		{
			//console.log('Setting wellConfigurations to default');
			this.options.wellConfigurations = [
				{'displayName':'Compound','keyName':'compound','displayColor':'blue','displayOrder':1,'data':[
					{'keyName':'regNumber','displayName':'Reg Number','dataType':'text','isRequired':true,'isArray':false},
					{'keyName':'concentration','displayName':'Concentration','dataType':'number','isRequired':true,'isArray':false}]},
				{'displayName':'Control','keyName':'control','displayColor':'green','displayOrder':2,'data':[
					{'keyName':'regNumber','displayName':'Reg#','dataType':'text','isRequired':true,'isArray':false},
					{'keyName':'concentration','displayName':'Concentration (ug/ml)','dataType':'number','isRequired':true,'isArray':false}]},
				{'displayName':'Reserved','keyName':'reserved','displayColor':'red','displayOrder':3,'data':[]},
				{'displayName':'Empty','keyName':'empty','displayColor':'gray','displayOrder':4,'data':[]}];
		}
							
        //console.log('arx.plateMap._create(): id=' + this.options.plateDisplayId + ' width=' + this.options.plateWidth + ' height=' + this.options.plateHeight + ' data=' + JSON.stringify(this.options.plateData) + ' wellConfigurations=' + JSON.stringify(this.options.wellConfigurations));
		this._refresh(true);
	},
	
	_refresh: function(reinitialize) {
		if(reinitialize === undefined)
			reinitialize = false;
		
		if(reinitialize)
		{
			if($('#arxPlateMapDiv').length > 0)
				$('#arxPlateMapDiv').remove();
			
			// Build the plate and update its data with anything that was passed in
			this.element.append(this._buildPlate(this.options.plateHeight, this.options.plateWidth));
			$('#arxPlateMapDiv').width($('#'+this.options.plateDisplayId).width());

			// Setup the plate, the lasso selector and individual well select handlers
			this._buildContentDivs();
			this._enableLassoSelect();
			this._enableClickSelect();
			this._enableSelectAll();
		}
		
		// Draw the plate and make sure the correct buttons are showing
		this.clearSelection();
		this._updatePlateDisplay();
		this._checkButtonVisibility();
		this._trigger('change', null, this.getPlateContents(false));
	},

	_destroy: function() {
		console.log("arx.plateMap _destroy()");
	},

	_checkSelectAllButtons:function(wellId) {
		// see if the entire row is selected and if yes, toggle the row header
		completedRow = false;
		rowId = $('#'+wellId).attr('rowNum');
		colId = $('#'+wellId).attr('colNum');
		rowSelectAllButton = $('.select-all-button[rowNum='+rowId+'][colNum=0]')[0];
		colSelectAllButton = $('.select-all-button[colNum='+colId+'][rowNum=0]')[0];
		
		// Check the row selector
		if($('.plate-well-display.ui-selected[rowNum='+rowId+']').length == this.options.plateWidth)
		{
			$.each($('.select-all-button.select-all-off[rowNum='+rowId+'][colNum=0]'), function(index, value) {
				$('#'+value.id).removeClass('select-all-off');
				$('#'+value.id).addClass('select-all-on');
				completedRow = true;
			});
		}
		else
		{
			$.each($('.select-all-button.select-all-on[rowNum='+rowId+'][colNum=0]'), function(index, value) {
				$('#'+value.id).removeClass('select-all-on');
				$('#'+value.id).addClass('select-all-off');
			});
		}				
		
		// Check the column selector
		plateMap = this;
		if($('.plate-well-display.ui-selected[colNum='+colId+']').length == this.options.plateHeight)
		{
			$.each($('.select-all-button.select-all-off[colNum='+colId+'][rowNum=0]'), function(index, value) {
				$('#'+value.id).removeClass('select-all-off');
				$('#'+value.id).addClass('select-all-on');
				
				// IMPORTANT: If we already lit up a row select-all button and now we also
				// have to light up a column select-all button, then we need to create one more
				// reference count so that if the row or column is subsequently unselected using
				// the unselect all, then the other (row or col) will still remain selected
				// Basically: don't touch this unless you know what you're doing
				if(completedRow)
					plateMap._selectWell(wellId);
			});
		}
		else
		{
			$.each($('.select-all-button.select-all-on[colNum='+colId+'][rowNum=0]'), function(index, value) {
				$('#'+value.id).removeClass('select-all-on');
				$('#'+value.id).addClass('select-all-off');
			});
		}				
	},
	
    _checkButtonVisibility:function() {
		if(!this.options.allowInteractiveEdit)
			return;
		
		// Only show the 'clear plate contents' button if there are wells with stuff in them
		if(this.options.plateContents.length > 0)
		{
			$('#arxPlateMapContentButtons').show();
			$('#uploadFileButtonDiv').hide();
		}
		else
		{
			$('#arxPlateMapContentButtons').hide();
			$('#uploadFileButtonDiv').show();
		}
		
		if (Object.keys(this.options.selectedWells).length > 0) {
			// Only show arxPlateMapClearSelectedWellsButton if there is content in at least one of the selected wells
			$('#arxPlateMapClearSelectedWellsButton').hide();
			
			if(this.options.plateContents.length > 0)
			{
				var selectedWells = Object.keys(this.options.selectedWells);
				for(var i = 0; i < selectedWells.length; i++)
				{
					var wellData = this.getWellDataById(selectedWells[i]);
					if(wellData.hasOwnProperty('numComponents') && wellData['numComponents'] > 0)
					{
						$('#arxPlateMapClearSelectedWellsButton').show();
						break;
					}
				}
			}
		
			// Show the div with the buttons
			$('#arxPlateMapSelectionButtons').show();  
		}
		else if ((Object.keys(this.options.selectedWells).length == 0) && ($('#arxPlateMapSelectionButtons').is(':visible')) ) {
			// Nothing selected; hide div with buttons that control selection
			$('#arxPlateMapSelectionButtons').hide();  
		}
		
		$('#arxPlateMapAddDataButtonOptionsContainer').removeClass('arx-plate-add-data-button-options');
    },
	
	_buildPlate:function(numRows, numCols) {
		if(this.options.plateDisplayId === '')
			this.options.plateDisplayId = Math.floor(Date.now());

		var div = $('<div/>').attr({'id':'arxPlateMapDiv'});
		var table = $('<table/>').attr({'id':this.options.plateDisplayId});

		for (wellId = 1, r = 0; r <= numRows; r++)
		{
			var row = $('<tr/>');
			for (var c = 0; c <= numCols; c++)
			{
				if(r == 0 && c == 0)
				{
					row.append($('<th/>').attr({'id':id,'rowNum':r,'colNum':c}));
				}
				else if (r == 0)
				{
					var id = 'select-col-' + c;
					var rowDisplay = $('<button/>')
						.attr({'id':id,'rowNum':r,'colNum':c,'type':'button','class':'select-all-button select-all-off'})
						.html(this.options.columnLabels[c-1])
						.css({'width':this.options.wellSize,'height':this.options.wellSize,'line-height':this.options.wellSize-2});
						
					if(!this.options.allowInteractiveEdit)
						rowDisplay.prop('disabled', 'true');
						
					row.append($('<td/>').attr({'class':'select-all'}).append(rowDisplay));
				}
				else if (c == 0)
				{
					var id = 'select-row-' + r;
					var colDisplay = $('<button/>')
						.attr({'id':id,'rowNum':r,'colNum':c,'type':'button','class':'select-all-button select-all-off'})
						.html(this.options.rowLabels[r-1])
						.css({'width':this.options.wellSize,'height':this.options.wellSize,'line-height':this.options.wellSize-2});
						
					if(!this.options.allowInteractiveEdit)
						colDisplay.prop('disabled', 'true');
						
					row.append($('<td/>').attr({'class':'select-all'}).append(colDisplay));
				}
				else
				{
					var id = wellId++;
					row.append($('<td/>').attr({'class':'plate-well'})
						.append($('<canvas/>').attr({'id':id,'rowNum':r,'colNum':c,'width':this.options.wellSize,'height':this.options.wellSize,'class':'plate-well-display'})));
				}
			}
			
			table.append(row);
		}
		
		return div.append(table);
	},
	
	_prepareDataPropId:function(cfgKey, fieldKey) {
		return 'plate-data-prop-name-' + cfgKey + '-' + fieldKey;
	},
	
	_buildFillCategoryDivs:function() {
		var plateMap = this;
		var wellConfigurations = this.getWellConfigurations();
		var categoryDivs = $('<div/>').attr({'id':'dialog-category-data-forms'});
		
		$.each(wellConfigurations, function(index, cfgObj) {
			var cfgNameKey = cfgObj['keyName'];
			var cfgName = cfgObj['displayName'];
			
			// Setup the div for this configuration
			var thisDiv = $('<div/>').attr({'id':'category-'+ cfgNameKey +'-div','class':'dialog-category-data'});
			
			// Add the data fieldset
			var fieldArray = cfgObj['data'];
			$.each(fieldArray, function(index, fieldCfg) {
				var fieldType = fieldCfg['dataType'];
				var fieldIdName = plateMap._prepareDataPropId(cfgNameKey, fieldCfg['keyName']);
				
				var defaultValue = undefined;
				if(fieldCfg.hasOwnProperty('defaultValue'))
					defaultValue = fieldCfg['defaultValue'];
				
				var labelDisplayName = fieldCfg['displayName'];
				if(fieldCfg.hasOwnProperty('isRequired') && fieldCfg['isRequired'])
					labelDisplayName += '*';
				
				var dataField;
				if(fieldCfg.hasOwnProperty('isSelect') && fieldCfg.hasOwnProperty('selectValues') && fieldCfg['isSelect'])
				{
					dataField = $('<select/>').attr({'id':fieldIdName,'class':'dialog-category-item-input'})
						.append($('<option/>').attr({'id':fieldIdName + '-dialog-select-none','value':'Select One'}).html('Select One'));
						
					var options = [];
					$.each(fieldCfg['selectValues'], function(index, value) {
						var optionId = fieldIdName + '-' + value['keyName'];
						options.push($('<option/>').attr({'id':fieldIdName + '-' + value['keyName'],'value':value['displayName']}).html(value['displayName']));
					});

					$.each(options, function(index, value) {
						if(defaultValue !== undefined && defaultValue === value.attr('value'))
							value.prop('selected', true);
						
						dataField.append(value);
					});
				}
				else
				{
					dataField = $('<input/>').attr({'id':fieldIdName,'class':'dialog-category-item-input','type':fieldType});				
					if(defaultValue !== undefined)
						dataField.attr('value', defaultValue);
				}
				
				thisDiv.append($('<div/>').attr({'class':'dialog-category-item'})
					.append($('<label/>').attr({'class':'dialog-category-item-label'}).html(labelDisplayName))
					.append(dataField));
			});
			
			// Add to the list of divs for the different categories
			categoryDivs.append(thisDiv);
		});
		return categoryDivs;
	},
	
	_buildButtonPanel:function() {
		var plateMap = this;
		
		// This builds the div for the buttons that appear when something is selected on the plate
		$('#arxPlateMapDiv')
			.append($('<div/>').attr({'id':'arxPlateMapSelectionButtons','class':'plate-button-display'})
			.append($('<button/>').attr({'id':'arxPlateMapClearSelectedWellsButton','class':'plate-control-button'}).html('Empty Wells'))
			.append($('<button/>').attr({'id':'arxPlateMapClearSelectionButton','class':'plate-control-button'}).html('Cancel Selection')));
			
		var addDataButton = $('<button/>').attr({'id':'arxPlateMapAddDataButtonOptionFill','class':'plate-control-button'}).html('Add Data');
		var uploadFileDataButton = $('<div/>').attr({'id':'uploadFileButtonDiv'}).append($('<button/>').attr({'id':'arxPlateMapAddDataButtonOptionUpload','class':'plate-control-button'}).html('Upload Data'));
		
		if(this.options.allowFileUpload)
			$('#arxPlateMapDiv').append(uploadFileDataButton);
		
		if(this.options.allowInteractiveEdit)
		{
			if(this.options.plateType == 'cherryPick')
				$('#arxPlateMapSelectionButtons').append(addDataButton);
			else if(this.options.plateType == 'doseResponse')
				$('#arxPlateMapSelectionButtons')
					.append(($('<div/>').attr({'id':'arxPlateMapAddDataButtonContainer','class':'arx-plate-add-data-dropdown'}))
					.append(addDataButton.attr({'id':'arxPlateMapAddDataButton','class':'plate-control-button'}))
					.append($('<div/>').attr({'id':'arxPlateMapAddDataButtonOptionsContainer','class':'arx-plate-add-data-dropdown-content'})
					.append($('<a/>').attr({'id':'arxPlateMapAddDataButtonOptionFill','href':'#'}).html('Fill'))
					.append($('<a/>').attr({'id':'arxPlateMapAddDataButtonOptionDilute','href':'#'}).html('Dilution'))));
		}

		// This builds the div for the buttons that appear when one or more wells on the plate have content in them
		$('#arxPlateMapDiv')
			.append($('<div/>').attr({'id':'arxPlateMapContentButtons','class':'plate-button-display'})
			.append($('<button/>').attr({'id':'arxPlateMapClearPlateContentsButton','class':'plate-control-button'}).html('Empty Plate')));
			
        // Dialog button handlers
		$('#arxPlateMapAddDataButton').click(function(event) {
			if($('#arxPlateMapAddDataButtonOptionsContainer').hasClass('arx-plate-add-data-button-options'))
				$('#arxPlateMapAddDataButtonOptionsContainer').removeClass('arx-plate-add-data-button-options');
			else
				$('#arxPlateMapAddDataButtonOptionsContainer').addClass('arx-plate-add-data-button-options');
		});
		
        $('#arxPlateMapAddDataButtonOptionFill').click(function(event) {
			plateMap._processAddDataButtonClick(event);
		});

        $('#arxPlateMapAddDataButtonOptionDilute').click(function(event) {
			makePlateMaps();
			//plateMap._processAddDataButtonClick(event);
		});
		
		$('#arxPlateMapAddDataButtonOptionUpload').click(function(event) {
			$('#selectedFileToUpload').click();
		});

		$('#arxPlateMapClearSelectionButton').click(function(event) {
			plateMap.clearSelection();
        });
		
		$('#arxPlateMapClearSelectedWellsButton').click(function(event) {
			plateMap.clearSelectedWellData();
        });
		
		$('#arxPlateMapClearPlateContentsButton').click(function(event) {
			plateMap.clearSelection();
			plateMap.clearPlateContents();
        });
	},
	
	_buildFillDialog:function() {
		// Select list for data type
		var categorySelect = $('<select/>').attr({'id':'arxPlateMapFillDialogCategorySelect'})
			.append($('<option/>').attr({'id':'dialog-select-none','value':'Select One'}).html('Select One'));
			
		var plateMap = this;
		$.each(this.options.wellConfigurations, function(index, value) {
			var keyName = value['keyName'];
			
			if(value['keyName'] != plateMap.options.defaultWellConfigurationKey)
				categorySelect.append($('<option/>').attr({'id':'plate-dialog-select-' + keyName ,'value':keyName}).html(value['displayName']));
		});

		var categoryDivs = this._buildFillCategoryDivs();
		
		// This is the content pane of the dialog we build below
		var dialogContent = $('<div/>').attr({'id':'arxPlateMapFillDialogData','class':'arx-well-configuration-select'})
			.append($('<label/>').attr({'for':'arxPlateMapFillDialogCategorySelect','class':'arx-plate-select-label'}).html('Data Type: ')
			.append(categorySelect));
			
		// This is the dialog that pops up when you add data to the selected wells
		$('#arxPlateMapDiv')
			.append($('<div/>').attr({'id':'arxPlateMapFillDialog','class':'ui-dialog','class':'arx-plate-map-dialog','title':'Fill Wells'})
			.append(dialogContent)
			.append(categoryDivs)
			.append($('<div/>').attr({'class':'ui-dialog-buttonpane'})
			.append($('<button/>').attr({'id':'arxPlateMapSaveFillDataButton','class':'ui-dialog-buttonset'}).html('Save'))));

        // Dialog button handlers
        $('#arxPlateMapSaveFillDataButton').click({plateMap: this}, function(event) {
			var optionData = {};
			var idsToDefault = [];
			var blankRequiredFields = [];			
			var plateMap = event.data.plateMap;
			
			var selectedId = $('#arxPlateMapFillDialogCategorySelect option:selected').attr('id');
			var selectedCfgKey = $('#arxPlateMapFillDialogCategorySelect option:selected').val();
			var selectedCfgObj = plateMap._getWellConfigurationByKeyName(selectedCfgKey);
			var selectedCfgName = plateMap._getConfigNameByKey(selectedCfgKey);
			
			if($('#arxPlateMapFillDialog #category-' + selectedCfgKey + '-div').length > 0)
			{
				$.each(selectedCfgObj['data'], function(dataIndex, dataValue) {
					var displayKey = dataValue['keyName'];
					var displayType = dataValue['dataType'];
					var displayName = dataValue['displayName'];
					var isRequiredField = dataValue['isRequired'];
					var isArray = dataValue.hasOwnProperty('isArray') && dataValue['isArray'];
					
					var dataFieldId = plateMap._prepareDataPropId(selectedCfgKey, displayKey);
					var displayVal = $('#' + dataFieldId).val();
					
					// If this is a required field and it's blank, save and skip.
					if(isRequiredField && displayVal.length == 0)
					{
						blankRequiredFields.push(displayName);
						return;
					}

					// Store default values
					idsToDefault.push({'id':dataFieldId,'config':dataValue});

					// If this is supposed to be a number, convert it from the text
					if(displayType === 'number')
						displayVal = Number(displayVal);
					
					// If this field is an array, allow multiple values. Otherwise not.
					if(isArray)
					{
						if(!(displayName in optionData))
							optionData[displayKey] = [];
							
						optionData[displayKey].push(displayVal);
					}
					else
					{
						optionData[displayKey] = displayVal;
					}
				});
			}
			
			// Make pretty
			// If any required fields are blank, then tell the user and stop.
			if(blankRequiredFields.length > 0)
			{
				alert('The following fields are required: ' + blankRequiredFields);
				return;
			}
			
			if(selectedId != 'dialog-select-none')
			{
				$.each(Object.keys(plateMap.options.selectedWells), function(index, value) {
					var thisWellData = plateMap.getWellDataById(value);
					
					if(!(selectedCfgKey in thisWellData))
						thisWellData[selectedCfgKey] = [];
					
					if(selectedCfgObj['data'].length > 0)
					{
						thisWellData[selectedCfgKey].push(optionData);
						plateMap.setWellDataById(value, thisWellData);
					}
				});
			}

			// Repopulate default values
			plateMap._resetFillDialogDefaultValues(idsToDefault);
			
			// Reset the dialog
			$.each($('#arxPlateMapFillDialog [class=dialog-category-data]'), function(index, value) { $(value).hide(); });
			$('#arxPlateMapFillDialog #dialog-select-none').prop('selected', true);
            $('#arxPlateMapFillDialog').dialog('close');
			
			// Refresh the display and send change event
			plateMap._refresh(false);
        });
		
		$('#arxPlateMapFillDialogCategorySelect').change( function(event) {
			var selectedVal = $('#arxPlateMapFillDialogCategorySelect option:selected').val();
			var selectedId = $('#arxPlateMapFillDialogCategorySelect option:selected').attr('id');

			$.each($('[id^=plate-dialog-select-]'), function(index, value) {
				var categoryDivName = 'category-' + $(value).val() + '-div';
				if($('#'+categoryDivName).length > 0)
				{
					if($(value).prop('id') == selectedId)
						$('#'+categoryDivName).show();
					else
						$('#'+categoryDivName).hide();
				}
			});
		});
	},
		
	_buildFileUploadDialog:function() {
		var hiddenInput = $('<div/>').attr({'id':'arxPlateHiddenFileUploadDiv'})
			.append($('<input/>').attr({'id':'selectedFileToUpload','type':'file','style':'display:none;'}));
			
		$('#arxPlateMapDiv').append(hiddenInput);
		
		var thePlate = this;
		$('#selectedFileToUpload').change(function() {
			if($(this).val().length <= 0)
				return;
			
			$('#arxPlateMapAddDataButtonOptionUpload').attr('disabled', 'true');
			
			formData = new FormData();
			formData.append('plateData', this.files[0], $(this).val().split('/').pop().split('\\').pop());

			$.ajax({
				type:'POST', 
				async: true,
				cache: false,
				data: formData,
				url: '/uploadPlateContents',
				processData: false,
				contentType: false,			
				xhr: function() {  // custom xhr for progress bar
					myXhr = $.ajaxSettings.xhr();
					if(myXhr.upload)
						myXhr.upload.addEventListener('progress',
							function(evt) {
								//console.log('updateProgress');
								if (evt.lengthComputable)
								{
									var percentComplete = evt.loaded / evt.total;
									//console.log(percentComplete);
								}
								else
								{
									// Unable to compute progress information since the total size is unknown
									//console.log('unable to update upload progress');
								}
							},
							false);
					return myXhr;
				},
				complete: function(response) {
					// Re-enable the button.
					$('#arxPlateMapAddDataButtonOptionUpload').removeAttr('disabled');
				},
				success: function(response) {
					if(response['result'] === 'success')
					{
						if(response.hasOwnProperty('plateData'))
							thePlate.setPlateContents(response['plateData']);
						else if(response.hasOwnProperty('fileData'))
							thePlate.setPlateContentsFromFileData(response['fileData'])
						else
							alert('Unable to process response: ' + JSON.stringify(response));
					}
					else
					{
						alert("We were unable to upload this data set. Please try again.");
					}
				},
				error: function(response) {
					alert("There was an unexpected error while uploading the data. Please try again.");
				}
			});		
		});
	},
		
	_buildDilutionDialog:function() {			
		var plateMap = this;

		// Select list for data type
		var categorySelect = $('<select/>').attr({'id':'arxPlateMapDilutionDialogCategorySelect'});
		$.each(this.options.wellConfigurations, function(index, value) {
			var keyName = value['keyName'];
			
			if(value['keyName'] != plateMap.options.defaultWellConfigurationKey)
				categorySelect.append($('<option/>').attr({'id':'plate-dialog-dilution-select-' + keyName ,'value':keyName}).html(value['displayName']));
		});
		categorySelect = $('<label/>').attr({'for':'arxPlateMapDilutionDialogCategorySelect','class':'arx-plate-select-label'}).html('Material*: ').append(categorySelect);
		
		var numComponents = $('<label/>').attr({'for':'arxPlateMapDilutionDialogNumComponents','class':'dialog-category-item-label'}).html('Number*: ')
			.append($('<input/>').attr({'id':'arxPlateMapDilutionDialogNumComponents','type':'number','class':'dialog-category-item-input'}).html('1'));
			
		var topConc = $('<label/>').attr({'for':'arxPlateMapDilutionDialogTopConc','class':'dialog-category-item-label'}).html('Top Conc*: ')
			.append($('<input/>').attr({'id':'arxPlateMapDilutionDialogTopConc','type':'number','class':'dialog-category-item-input'}));
			
		var numDilutions = $('<label/>').attr({'for':'arxPlateMapDilutionDialogNumDilutions','class':'dialog-category-item-label'}).html('Dilutions*: ')
			.append($('<input/>').attr({'id':'arxPlateMapDilutionDialogNumDilutions','type':'number','class':'dialog-category-item-input'}));
			
		var foldDilution = $('<label/>').attr({'for':'arxPlateMapDilutionDialogFoldDilution','class':'dialog-category-item-label'}).html('Fold*: ')
			.append($('<input/>').attr({'id':'arxPlateMapDilutionDialogFoldDilution','type':'number','class':'dialog-category-item-input'}));
			
		var numReplicates = $('<label/>').attr({'for':'arxPlateMapDilutionDialogNumReplicates','class':'dialog-category-item-label'}).html('Replicates*: ')
			.append($('<input/>').attr({'id':'arxPlateMapDilutionDialogNumReplicates','type':'number','class':'dialog-category-item-input'}));
			
		var numIllustrations = $('<label/>').attr({'for':'arxPlateMapDilutionDialogNumIllustrations','class':'dialog-category-item-label'}).html('Number of Illustrations*: ')
			.append($('<input/>').attr({'id':'arxPlateMapDilutionDialogNumIllustrations','type':'number','class':'dialog-category-item-input'}).html('1'));
			
		var concUnitsSelect = $('<select/>').attr({'id':'arxPlateMapDilutionDialogConcentrationUnitsSelect','class':'dialog-category-item-input'});
		concUnitsSelect.append($('<option/>').attr({'id':'arxPlateMapDilutionDialogConcUnitsugPerml','value':'ugml'}).html('ug/ml'));
		concUnitsSelect.append($('<option/>').attr({'id':'arxPlateMapDilutionDialogConcUnitsmgPerml','value':'mgml'}).html('mg/ml'));
		var concUnits = $('<label/>').attr({'for':'arxPlateMapDilutionDialogConcentrationUnitsSelect','class':'dialog-category-item-label'}).html('Concentration Units*: ').append(concUnitsSelect);
			
		var dilutionPatternSelect = $('<select/>').attr({'id':'arxPlateMapDilutionDialogDilutionPatternSelect','class':'dialog-category-item-input'});
		dilutionPatternSelect.append($('<option/>').attr({'id':'arxPlateMapDilutionDialogDilutionPatternHorizontal','value':'horizontal'}).html('Horizontal'));
		dilutionPatternSelect.append($('<option/>').attr({'id':'arxPlateMapDilutionDialogDilutionPatternVertical','value':'vertical'}).html('Vertical'));
		var dilutionPattern = $('<label/>').attr({'for':'arxPlateMapDilutionDialogDilutionPattern','class':'dialog-category-item-label'}).html('Dilution Pattern*: ').append(dilutionPatternSelect);
			
		var fillPatternSelect = $('<select/>').attr({'id':'arxPlateMapDilutionDialogFillPatternSelect','class':'dialog-category-item-input'});
		fillPatternSelect.append($('<option/>').attr({'id':'arxPlateMapDilutionDialogFillPatternT2B','value':'topToBottom'}).html('Top To Bottom'));
		fillPatternSelect.append($('<option/>').attr({'id':'arxPlateMapDilutionDialogFillPatternL2R','value':'leftToRight'}).html('Left To Right'));
		fillPatternSelect.append($('<option/>').attr({'id':'arxPlateMapDilutionDialogFillPatternR2L','value':'rightToLeft'}).html('Right To Left'));
		fillPatternSelect.append($('<option/>').attr({'id':'arxPlateMapDilutionDialogFillPatternB2T','value':'bottomToTop'}).html('Bottom To Top'));
		var fillPattern = $('<label/>').attr({'for':'arxPlateMapDilutionDialogFillPattern','class':'dialog-category-item-label'}).html('Fill Pattern*: ').append(fillPatternSelect);
			
		// This is the content pane of the dialog we build below
		var dialogContent = $('<div/>').attr({'id':'arxPlateMapDilutionDialogData','class':'arx-well-configuration-select'})
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(categorySelect))
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(numComponents))
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(topConc))
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(concUnits))
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(numDilutions))
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(foldDilution))
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(numReplicates))
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(dilutionPattern))
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(fillPattern))
			.append($('<div/>').attr({'class':'arx-well-dilution-dialog-input'}).append(numIllustrations));
			
		// This is the dialog that pops up when you add data to the selected wells
		$('#arxPlateMapDiv')
			.append($('<div/>').attr({'id':'arxPlateMapDilutionDialog','class':'ui-dialog','class':'arx-plate-map-dialog','title':'Setup Dilution'})
			.append(dialogContent)
			.append($('<div/>').attr({'class':'ui-dialog-buttonpane'})
			.append($('<button/>').attr({'id':'arxPlateMapSaveDilutionDataButton','class':'ui-dialog-buttonset'}).html('Save'))));

        // Dialog button handlers
        $('#arxPlateMapSaveDilutionDataButton').click({plateMap: this}, function(event) {
			// Get the values entered by the user and set them back to thier default values (blank for now)
			var categoryVal = $('#arxPlateMapDilutionDialogCategorySelect option:selected').val();
			$('#arxPlateMapDilutionDialogCategorySelect').val($('#arxPlateMapDilutionDialogCategorySelect option:first').val());
			
			var dilutionPatternVal = $('#arxPlateMapDilutionDialogDilutionPattern option:selected').val();
			$('#arxPlateMapDilutionDialogDilutionPattern').val($('#arxPlateMapDilutionDialogDilutionPattern option:first').val());

			var fillPatternVal = $('#arxPlateMapDilutionDialogFillPattern option:selected').val();
			$('#arxPlateMapDilutionDialogFillPattern').val($('#arxPlateMapDilutionDialogFillPattern option:first').val());

			var concUnitsVal = $('#arxPlateMapDilutionDialogConcentrationUnitsSelect option:selected').val();
			$('#arxPlateMapDilutionDialogConcentrationUnitsSelect').val($('#arxPlateMapDilutionDialogConcentrationUnitsSelect option:first').val());

			var topConc = $('#arxPlateMapDilutionDialogTopConc').val();
			$('#arxPlateMapDilutionDialogTopConc').val('');
			
			var foldDilution = $('#arxPlateMapDilutionDialogFoldDilution').val();
			$('#arxPlateMapDilutionDialogFoldDilution').val('');
			
			var numDilutions = $('#arxPlateMapDilutionDialogNumDilutions').val();
			$('#arxPlateMapDilutionDialogNumDilutions').val('');
			
			var numComponents = $('#arxPlateMapDilutionDialogNumComponents').val();
			$('#arxPlateMapDilutionDialogNumComponents').val('');
			
			var numReplicates = $('#arxPlateMapDilutionDialogNumReplicates').val();
			$('#arxPlateMapDilutionDialogNumReplicates').val('');
			
			var numIllustrations = $('#arxPlateMapDilutionDialogNumIllustrations').val();
			$('#arxPlateMapDilutionDialogNumIllustrations').val('');

			if(topConc === '' || foldDilution === '' || numDilutions === '' || numComponents === '' || numReplicates === '' || numIllustrations === '')
			{
				alert('Please fill in all fields; all fields are required.');
				return;
			}
			
			var plateMap = event.data.plateMap;
			var startWellId = Object.keys(plateMap.options.selectedWells)[0];
			var startWell = $('#' + startWellId)[0];
			//console.log(startWell);
			var startRow = $(startWell).attr('rowNum');
			var startCol = $(startWell).attr('colNum');
			var dilutionRowDelta=0, dilutionColDelta=0, replicateRowDelta=0, replicateColDelta=0;
			
			if(dilutionPatternVal === 'horizontal')
				dilutionColDelta = 1;
			else if(dilutionPatternVal === 'vertical')
				rowDelta = 1;
			/*
			if(selectedId != 'dialog-select-none')
			{
				$.each(Object.keys(plateMap.options.selectedWells), function(index, value) {
					var thisWellData = plateMap.getWellDataById(value);
					
					if(!(selectedCfgKey in thisWellData))
						thisWellData[selectedCfgKey] = [];
					
					if(selectedCfgObj['data'].length > 0)
					{
						thisWellData[selectedCfgKey].push(optionData);
						plateMap.setWellDataById(value, thisWellData);
					}
				});
			}

			// Repopulate default values
			plateMap._resetFillDialogDefaultValues(idsToDefault);
			
			// Reset the dialog
			$.each($('#arxPlateMapFillDialog [class=dialog-category-data]'), function(index, value) { $(value).hide(); });
			$('#arxPlateMapFillDialog #dialog-select-none').prop('selected', true);
            $('#arxPlateMapFillDialog').dialog('close');
			*/
			// Refresh the display and send change event
			plateMap._refresh(false);
        });
	},
		
	_buildContentDivs:function() {
		// Buttons end user operations
		this._buildButtonPanel();
		
		// Fill dialog
		this._buildFillDialog();
		
		if(this.options.plateType == 'doseResponse')
			this._buildDilutionDialog();

		if(this.options.allowFileUpload)
			this._buildFileUploadDialog();
	},
	
	_resetFillDialogDefaultValues:function(theFields) {
		$.each(theFields, function(fieldIndex, field) {
			var defaultValue = undefined;
			if(field['config'].hasOwnProperty('defaultValue'))
				defaultValue = field['config']['defaultValue'];
			
			if(field['config'].hasOwnProperty('isSelect') && field['config']['isSelect'])
			{
				if(defaultValue === undefined)
				{
					$('#arxPlateMapFillDialog #'+field['id']+'-dialog-select-none').prop('selected', true);
					return;
				}
				
				var theOptions = $('#arxPlateMapFillDialog [id^='+field['id']+'-]');
				for(var i = 0; i < theOptions.length; i++) {
					if($(theOptions[i]).attr('value') === defaultValue) {
						$(theOptions[i]).prop('selected', true);
						return;
					}
				}
			}
			else
			{
				if(defaultValue === undefined)
					defaultValue = '';
				
				$('#arxPlateMapFillDialog #'+field['id']).val(defaultValue);
			}
		});
	},
	
	_drawWell:function(theWell, configKeys) {
		// Get some metrics on the canvas element
		var centerX = theWell.width / 2;
		var centerY = theWell.height / 2;
		var radius = Math.min(theWell.height, theWell.width) / 2;
		
		// Figure out how many segments need to be drawn
		var wellData = this.getWellDataById(theWell.id);
		
		// Get the key values of the wellConfigurations if they weren't passed in
		if(configKeys == undefined)
			configKeys = this._getWellConfigurationKeyNames();
		
		var numComponents = 0;
		$.each(configKeys, function(index, value) {
			if(value in wellData)
				numComponents += 1;
		});
		
		// Use the default configuration if there's no data for this well
		if(numComponents == 0 || Object.keys(wellData).length == 0)
		{
			numComponents = 1;
			wellData[this.options.defaultWellConfigurationKey] = [];
		}

		// Setup some things before we start rendering
		var pieData = [];
		var startAngle = 0;
		var plateMap = this;
		var ctx = theWell.getContext("2d");
		var segmentArea = Math.PI * 2 * (1 / numComponents);

		// Add some transparency so the selection rectangle is visible, and clear the area before drawing
		ctx.globalAlpha = 0.75;
		ctx.clearRect(0, 0, theWell.height, theWell.width);
		
		$.each(Object.keys(wellData), function(index, value) {
			// Only process values that are wellConfigurations keyNames
			if($.inArray(value, configKeys) == -1)
				return;
			
			// Set end angle and fill color
			var endAngle = startAngle + segmentArea;
			ctx.fillStyle = plateMap._getWellConfigurationByKeyName(value)['displayColor'];
			
			// Store the data for rendering in the hover window
			pieData.push({'startAngle':startAngle,'endAngle':endAngle,'configKey':value,'configData':wellData[value]});
			
			// Draw this segment of the circle
			ctx.beginPath();
			ctx.moveTo(centerX, centerY);
			ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
			ctx.fill();
			
			// Update the start point for the next drawing segment
			startAngle = endAngle;
		});
		
		// Remove handlers. If we need them, we'll set them up below.
		$('#'+theWell.id).off('mouseout');
		$('#'+theWell.id).off('mousemove');
		
		// If any of the segments have data associated with them, setup the hover areas for tool tips
		if(!this.isWellIdEmpty(theWell.id))
		{		
			//console.log('not empty; id: ' + theWell.id);
			$('#'+theWell.id).mousemove(function(e) {
				// Figure out where the center of the well is, in page coordinates
				var wellOffset = $('#'+theWell.id).offset();
				var centerPageX = wellOffset.left + (theWell.width / 2);
				var centerPageY = wellOffset.top + (theWell.height / 2);
	
				// Figure out where the pointer is in the circle so we know which slice it's in
				angle = Math.atan2(e.pageY - centerPageY, e.pageX - centerPageX);
				
				// Flip the sign if needed
				if(angle < 0)
					angle = 2 * Math.PI + angle;
				
				for (var i in pieData)
				{
					// If the pointer is in this slice of the pie, show this tool tip
					if (angle >= pieData[i]['startAngle'] && angle <= pieData[i]['endAngle'])
					{
						if ($('#arxPlateWellHoverWindow').length > 0)
							$('#arxPlateWellHoverWindow').remove();
						
						// Setup a div to hold the popup content
						$('#arxPlateMapDiv').append($('<div/>').attr({'id':'arxPlateWellHoverWindow','class':'arx-plate-well-hover-window'}));
						
						// Get the data we need to display
						var configKey = pieData[i]['configKey'];
						var hoverData = pieData[i]['configData'];
						var configName = plateMap._getConfigNameByKey(configKey);

						//console.log('configKey: ' + configKey);
						//console.log('configName: ' + configName);
						//console.log('hoverData: ' + JSON.stringify(hoverData));

						// Add the config name to the hover window
						$('#arxPlateWellHoverWindow').append($('<div/>').attr({'class':'arx-plate-hover-window-data-type'}).html(configName));

						if(wellData[configKey].length > 0)
						{
							// Build a table with the parameters for this class of object
							var tableId = 'arxPlateWellHoverWindow' + configName;
							var dataFields = plateMap._getWellConfigurationByKeyName(configKey)['data'];
							var dataTable = $('<table/>').attr({'id':tableId, 'class':'arx-plate-hover-window-table'});
							var headerRow = $('<tr/>');

							// Put the table headers in using the displayName value from the object configuration
							$.each(dataFields, function(index, value) {
								var displayName = value['displayName'];
								headerRow.append($('<th/>').attr({'class':'arx-plate-hover-window-table-header'}).html(value['displayName']));
							});

							dataTable.append(headerRow);
							
							// Now put the table values in
							$.each(hoverData, function(dataIndex, dataValue) {
								var thisRow = $('<tr/>');
								$.each(dataFields, function(fieldIndex, fieldValue) {
									var keyName = fieldValue['keyName'];
									if(fieldValue.dataType!="image"){
										thisRow.append($('<td/>').attr({'class':'arx-plate-hover-window-table-data'}).html(dataValue[keyName]));
									}else{
										//todo: the blank join is because the image data is being split into an array
										//do not have time or inclination to figure out why at the moment jmh
										//console.log("image",keyName,dataValue[keyName])
										w = fieldValue.width ? fieldValue.width : '100px';
										h = fieldValue.width ? fieldValue.height : '100px';
										thisRow.append($('<td/>').attr({'class':'arx-plate-hover-window-table-data'}).append($("<img>", {
											"src": "data:image/png;base64," + dataValue[keyName].join(""),
											"width": w, "height": h
										})));
									}
								});
								dataTable.append(thisRow);
							});
							
							$('#arxPlateWellHoverWindow').append(dataTable);
						}
						
						// Set the div position and show it
						//console.log(e.pageX,e.pageY)
						$('#arxPlateWellHoverWindow').css({position:'fixed',top: e.pageY + 10-$(window).scrollTop(), left: e.pageX + 10-$(window).scrollLeft()});
						$('#arxPlateWellHoverWindow').show();
						return;
					}
				}
			});
			
			// When the mouse leaves the canvas, remove the tool tip
			$('#'+theWell.id).mouseout(function(e) {
				if ($('#arxPlateWellHoverWindow').length)
					$('#arxPlateWellHoverWindow').remove();
			});
		}
	},

	_updatePlateDisplay:function() {
		var plateMap = this;
		var configKeys = this._getWellConfigurationKeyNames();
		
		$('.plate-well-display').each(function() {
			if(this !== null && this !== undefined)
				plateMap._drawWell(this, configKeys);
		});
	},

	_setOption:function(option, value) {
		if(option in this.options)
		{
			if(value == undefined)
				return this.options[option];
			else
			{
				this.options[option] = value;
				this._super( "_setOption", option, value );
			}
		}
	},
	
	_setOptions:function(settings) {
		var plateMap = this;
		$.each(settings, function(key, value) {
			plateMap._setOption(key, value);
		});
		
		this._refresh(true);
	},
	
	_getConfigNameByKey:function(keyName) {
		var theConfig = this._getWellConfigurationByKeyName(keyName);
		
		if(theConfig !== undefined && theConfig.hasOwnProperty('displayName'))
			return theConfig['displayName'];
		
		console.log('Warning: returning defaultWellConfigurationKey from _getConfigNameByKey()');
		return this._getWellConfigurationByKeyName(this.options.defaultWellConfigurationKey)['displayName'];
	},
	
	_getWellConfigurationKeyNames:function() {
		var keyNames = [];
		var plateMap = this;
		$.each(plateMap.options.wellConfigurations, function(index, value) {
			keyNames.push(value['keyName']);
		});
		return keyNames;
	},

	_getWellConfigurationByKeyName:function(keyName) {
		for(var i = 0, len = this.options.wellConfigurations.length; i < len; i++)
			if(this.options.wellConfigurations[i].hasOwnProperty('keyName') && this.options.wellConfigurations[i]['keyName'] == keyName)
				return this.options.wellConfigurations[i];
			
		return {};
	},
	
	_processAddDataButtonClick:function(event) {
		var selectedWellIds = Object.keys(this.options.selectedWells);
		
		if(selectedWellIds.length <= 0)
		{
			alert('Please select wells to populate.');
			return;
		}

		if(event.currentTarget.id === 'arxPlateMapAddDataButtonOptionFill')
		{
			$('#arxPlateMapFillDialog').dialog({
				modal:'true',
				open: function(){
					// Click on background should exit
					$('.ui-widget-overlay').bind('click',function() {
						$('#arxPlateMapFillDialog').dialog('close');
					})
				}
			});
		}
		else if(event.currentTarget.id === 'arxPlateMapAddDataButtonOptionDilute')
		{
			if(selectedWellIds.length != 1)
			{
				alert('Only one well can be selected to start a dilution.');
				return;
			}
			
//			$('#arxPlateMapDilutionDialog').dialog({
//				modal:'true',
//				open: function(){
//					// Click on background should exit
//					$('.ui-widget-overlay').bind('click',function() {
//						$('#arxPlateMapDilutionDialog').dialog('close');
//					})
//				}
//			});
			
			this._addDilution();
		}
	},
	
	_addDilution:function(event) {
		// Static data for testing
		var sampleList = ['ABC-123','DEF-345','GHI-678'];
		
		var topConc = 1;
		var numDilutions = 4;
		var numReplicates = 8;
		var foldDilution = 10;
		var dilutionJumpControlStep = 1;
		
		var wrapDilutions = false;
		var stackReplicates = true;
		var repsCanSpanPlates = false;
		var dilutionsJumpControls = false;
		
		var startPos = {'x':1,'y':1};
		var dilutionStep = {'x':1,'y':0};
		var sampleStep = {'x':1,'y':0};
		var replicateStep = {'x':1,'y':0};
		
		var currPos = startPos;
		
		// Iterate over samples
		for(var sampleIndex = 0; sampleIndex < sampleList.length; sampleIndex++)
		{
			if(sampleIndex > 0)
			{
				currPos['x'] += sampleStep['x'];
				currPos['y'] += sampleStep['y'];
				
				if(currPos['x'] > this.options.plateWidth)
				{
					currPos['y'] += 1;
					currPos['x'] = 1;
					
					if(stackReplicates)
						currPos['x'] += numDilutions;
				}
			}
			
			var sampleName = sampleList[sampleIndex];
			
			// Iterate over the replicates of this sample
			for(var repIndex = 0; repIndex < numReplicates; repIndex++)
			{
				if(repIndex > 0)
				{
					currPos['x'] += replicateStep['x'];
					currPos['y'] += replicateStep['y'];
				
					if(currPos['x'] > this.options.plateWidth)
					{
						currPos['y'] += 1;
						currPos['x'] = 1;
						
						if(stackReplicates)
							currPos['x'] += numDilutions;
					}				
				}
			
				var concentration = topConc;
				
				// Iterate over dilutions
				for(var dilutionIndex = 0; dilutionIndex < numDilutions; dilutionIndex++)
				{
					concentration /= foldDilution;
					if(dilutionIndex > 0)
					{
						currPos['x'] += dilutionStep['x'];
						currPos['y'] += dilutionStep['y'];
				
						if(currPos['x'] > this.options.plateWidth)
						{
							currPos['y'] += 1;
							currPos['x'] = 1;
							
							if(stackReplicates)
								currPos['x'] += numDilutions;
						}				
					}

					//console.log('sampleIndex: ' + sampleIndex + '; repIndex: ' + repIndex + '; dilutionIndex: ' + dilutionIndex + '; wellCoords: ' + JSON.stringify(currPos) + '; sampleName: ' + sampleName + '; concentration: ' + concentration);
				}
			}
		}
	},

	setPlateContentsFromFileData:function(fileData) {
		if(!fileData.hasOwnProperty('mimeType')) {
			alert('Key mimeType not found in fileData: ' + JSON.stringify(fileData));
			return;
		}
		
		if(!fileData.hasOwnProperty('objectType')) {
			alert('Key objectType not found in fileData: ' + JSON.stringify(fileData));
			return;
		}
		
		theData = [];
		if(fileData['mimeType'] === 'chemical/x-mdl-sdfile') {
			sdfReader = new SDFReader(fileData['fileContents']);
			theData = sdfReader.getMolecules();
		}
		else {
			alert('Unknown mimeType: ' + fileData['mimeType']);
			return;
		}
		
		var thePlate = this;
		var dataByWellId = {};
		var previousWellCoords = {'rowNum':0, 'colNum':0};
		
		$.each(theData, function(index, value) {
			var id;
			if(value['attrList'].indexOf('id') > -1) {
				id = value['attrVals']['id'][0];
			} else if(thePlate.options.hasOwnProperty('mappingTemplate')) {
				id = thePlate._getNextWellId(previousWellCoords);
			} else {
				id = index + 1;
			}
			
			console.log('got wellId: ' + id);
			if(!dataByWellId.hasOwnProperty('id'))
				dataByWellId[id] = [];
			
			dataObj = value['attrVals'];
			dataObj['molFile'] = value['molFile'];
			dataByWellId[id].push(dataObj);
		});
		
		var objectType = fileData['objectType'];
		$.each(Object.keys(dataByWellId), function(index, value) {
			var theObj = {};
			theObj[objectType] = dataByWellId[value];
			thePlate.setWellDataById(value, theObj);
		});
	},
	
	getPlateContentsAsFileData:function(mimeType) {
		if(mimeType === 'chemical/x-mdl-sdfile') {
			sdfWriter = new SDFWriter(this.options.plateContents);
			return sdfWriter.getSDFile();
		}
		else
			return 'Unknown mimeType: ' + mimeType;
	},
	
	_getNextWellId:function(previousWellCoords) {
		console.log('_getNextWellId() previousWellCoords: ' + JSON.stringify(previousWellCoords));
		if(previousWellCoords['rowNum'] == 0 && previousWellCoords['colNum'] == 0)
		{
			previousWellCoords['rowNum'] = 1;
			previousWellCoords['colNum'] = 1;
		}
		else if(this.options.mappingTemplate.length == 0 ||
			!this.options.mappingTemplate.hasOwnProperty('samplePattern') ||
			!this.options.mappingTemplate['samplePattern'].hasOwnProperty('primaryLayout') ||
			this.options.mappingTemplate['samplePattern']['primaryLayout'] === 'topToBottom')
		{
			console.log('g1');
			if(previousWellCoords['colNum'] + 1 <= this.options.plateWidth)
			{
				previousWellCoords['colNum'] = previousWellCoords['colNum'] + 1;
			}
			else
			{
				previousWellCoords['colNum'] = 1;
				previousWellCoords['rowNum'] = previousWellCoords['rowNum'] + 1;
			}
		}
		else if(this.options.mappingTemplate['samplePattern']['primaryLayout'] === 'leftToRight')
		{
			if(previousWellCoords['rowNum'] + 1 <= this.options.plateHeight)
			{
				previousWellCoords['rowNum'] = previousWellCoords['rowNum'] + 1;
			}
			else
			{
				previousWellCoords['rowNum'] = 1;
				previousWellCoords['colNum'] = previousWellCoords['colNum'] + 1;
			}
		}

		console.log('returning coords: ' + JSON.stringify(previousWellCoords));
		return this.getWellIdByCoords(previousWellCoords['rowNum'], previousWellCoords['colNum']);
	}
	
});
	