var manageRequestsModule = (function () {

	var TF = false;
	/**
	 * this function builds the manage reqyest DataTables
	 * Note: all prossesing is in the back end
	 * @param {number} visibleRequestTypeId request type id that is used to build the table
	 */
	var initManageRequestsTable = function (visibleRequestTypeId) {
		
		if ($.fn.DataTable.isDataTable('table#manageRequestsTable')) {
			$('table#manageRequestsTable').DataTable().destroy()
			$('table#manageRequestsTable tbody, table#manageRequestsTable thead').empty();
		}

		priorityColumnTitle = "Start order";
		var priorityName = "assignedOrder";
		if (window.manageMyRequests) {
			priorityColumnTitle = "Priority";
			priorityName = "requestedOrder";
		}
		//begin building table columns and there render functions
		//this set of column defs is for the default 
		var tableColumns = [
			{ 
				"data": priorityName,
				"name": priorityName,
				"orderable": true,
				"title": priorityColumnTitle,
				"width": "0px", 
				"visible": true,
				"searchable": true
			},
			{
				"className": 'dragHandle',
				"name": "",
				"orderable": false,
				"data": null,
				"defaultContent": '',
				"title": "",
				"render": function(data, type, row) {
					var requestItemDragHandle = $('<div title="Drag Handle" class="manageRequestDragHandle iconHelpr">').append($('<i class="material-icons">').text("reorder"));
					var requestItemDragToReorder = $('<button title="Drag Handle" class="manageRequestDragHandle btn">');
					requestItemDragToReorder.append(requestItemDragHandle);

					if (!window.top.rowReorderLocked && !window.top.rowReorderLockedByReorder)
					{
						if (row["isQueueable"]) {
							return requestItemDragToReorder.prop("outerHTML");
						}
					}
				}
			},
			{
				"className": 'details-control',
				"name": "",
				"orderable": false,
				"data": null,
				"defaultContent": '',
				"title": ""
			},
			{ 
				"data": "requestName",
				"title": "Name",
				"name": "requestName",
				"visible": true,
				"searchable": false,
				"className": 'requestName'
			},
		]
		if (!window.manageMyRequests) {
			tableColumns.push({ "data": "requestorName", "name": "requestor", "title": "Requestor" }, { "data": "requestedOrder", "name": "requestedOrder", "title": "Requestor Priority" })
		}
		tableColumns.push({ "data": "numberOfItems", "name": "numItems", "title": "# of Items" })
		tableColumns.push({
			"data": "dateCreated",
			"name": "dateCreated",
			"title": "Date Created",
			"render": function (data, type, row) {
				return `<div class="dateCellHiddenEpoch"></div><div class='dateCreatedCell'>${moment.utc(data).local().format("MM/DD/YY LT")}</div>`;
			}
		})
		
		
		//now get the request type and set up the dynamic columns

		var activeRequestType = window.requestTypesArray.find(x => x.id == visibleRequestTypeId)
		if (activeRequestType) {
			if (activeRequestType.fields.length > 0){
				activeRequestType.fields = utilities().removeDuplicatedFields(activeRequestType.fields)
				var fieldsICanSee = utilities().checkPerm(activeRequestType.fields);
				if(fieldsICanSee.length > 0)
				{
					fieldsICanSee.map(function(field){
						if(field.inRequestsTable == 1){
		
		
							console.log(field)
	
							if (field['dataTypeId'] == 13 || field['dataTypeId'] == 14 || field['dataTypeId'] == 15) {
								tableColumns.push({
									"data": field['requestTypeFieldId'],
									"title": field['displayName'],
									"name": String(field['requestTypeFieldId']),
									"dataTypeId": field['dataTypeId'],
									"searchable": true,
									"orderable": false,
									"render": function (data, type, row) {
										if (data != undefined) {
											var display = "";
											$.each(data, function (i, item) {

												var buildJson = {id: -1};
												// wrap in try catch to make sure we dont die on bad json
												try {
													//make sure we have an id
													if (item && parseInt( item ) != 0){
														//make sure we have something to pull from
														if (window.top.linkData && Array.isArray( window.top.linkData ) && window.top.linkData.length > 0) {
															var link = window.top.linkData.find( x => x.linkSvcId == item);
															if (link) {
																buildJson = {
																	id: link.linkId,
																	text: link.linkName,
																} 
																if ('abr' in link) {
																	buildJson.index = link.abr;
																}
															}
														}
													}
												
												} catch (error) {
													//it failed probably because of a invalid json
												}

												if (buildJson.id <= 0 || buildJson.id == null || buildJson.id == undefined)
												{
													return "";
												}

												var onClickFnc = "";

												if (field['dataTypeId'] == dataTypeEnums.NOTEBOOK) {
													onClickFnc = `requestFieldHelper().NavToNotebook(${String(buildJson['id'])});`;
												}
												else if (field['dataTypeId'] == dataTypeEnums.PROJECT) {
													onClickFnc = `requestFieldHelper().NavToProject(${String(buildJson['id'])});`;
												}
												else if (field['dataTypeId'] == dataTypeEnums.EXPERIMENT) {
													onClickFnc = `requestFieldHelper().NavToExperement(${String(buildJson['id'])}, '${String(buildJson["index"])}');`;
												}

												display += `<a href="JavaScript:void(0);" class="navigateLink btn btn-info btn-sm" onClick="${onClickFnc}">${buildJson['text']}</a>`;
											})
											return display
										}
										else {
											return ""
										}
									}
								});
							}
							else {
								tableColumns.push({
									"data": field['requestTypeFieldId'],
									"title": field['displayName'],
									"name": String(field['requestTypeFieldId']),
									"dataTypeId": field['dataTypeId'],
									"searchable": field['dataTypeId'] != 7,
									"render": function (data, type, row) {
										if ( field['dataTypeId'] == dataTypeEnums.DATE)
										{
											if (data && data != "null")
											{
												data = moment(data).format("MM/DD/YY");  
											}
										}

										return data;
				
									}
								});
							}
						}
					});
				}
			}
		}
		
		var ViewOption = 25;
		if (utilities().getCookie('displayOptions') != "") {
			ViewOption = parseInt(utilities().getCookie('displayOptions'));
		}
		if (isNaN(ViewOption)){
			ViewOption = 25;
		}

		var rowReorderSetting = false;
		var sourceData = window.manageMyRequests? "requestedOrder": "assignedOrder";

		var isMember = isWorkflowManager;
		if (isMember || window.manageMyRequests) {
			rowReorderSetting = {
				dataSrc: sourceData,
				selector: 'td:nth-of-type(2) .manageRequestDragHandle',
				snapX: true
			}
			$('body').addClass('showUpdateRequestsAssignedOrderButton');
		}
		var linkFields = [];
		var leftCols = 1;
		var selRequestTypeIds = [];
		if (activeRequestType) {
			leftCols = activeRequestType["frozenColumnsLeft"];
			selRequestTypeIds.push(activeRequestType["id"]);
			linkFields = activeRequestType.fields.filter(x => (x.dataTypeId == dataTypeEnums.PROJECT || x.dataTypeId == dataTypeEnums.NOTEBOOK || x.dataTypeId == dataTypeEnums.EXPERIMENT) && x.inRequestsTable );
		}

		var fixedColumnsSetting = false;
		fixedColumnsSetting = {
			leftColumns: parseInt(leftCols)
		}


		var manageRequestsTable = $('table#manageRequestsTable').DataTable({
			"serverSide": true,
			ajax: function(data,callback,settings){
				var sendObj = {
					requestTypeId: selRequestTypeIds,
					appName: window.currApp,
					getRequestCounts: true,
					searchString: data['search']['value'],
					recordsPerPage: data['length'],
					pageNumber: Math.floor((data['start'] + 1) / data['length']),
					getFieldData: true,
					fetchColumnFilterOptions: true,
					orderBy: "",
					}
					var columnFilters = {};
					var filterOptions = data["columns"].map(function(x){

						if (x['search']['value'] != ""){
							var retObj = {}
							retObj[x['name']] = x['search']['value'].split("|")
							if (x['name'] == "requestor"){
								var searchArray = JSON.stringify(x['search']['value'].split("|"));
								sendObj['requestorNames'] = searchArray;
							}
							else
							{
								columnFilters[x['name']] = x['search']['value'].split("|");
							}

							return (retObj)
						}
						else{
							return ({})
						}
					
					});

					$.each(data.order, function(index, item){
						var name = data["columns"][[item.column]]["name"];
						if (sendObj.orderBy != "")
						{
							sendObj.orderBy += ", "	
						}
						sendObj.orderBy += `${name}:${item.dir}`;
					});
					
					if (data["order"].length > 0){
						if (data["order"][0]["column"] != 0 || !utilities().isEmpty(columnFilters) || sendObj['requestorNames'] != undefined){
							window.top.rowReorderLockedByReorder = true;
						}
						else{
							window.top.rowReorderLockedByReorder = false;
						}
					}
					else{
						window.top.rowReorderLockedByReorder = false;
					}
					
					
					if (Object.keys(columnFilters).length > 0){
						sendObj["requestFieldFilters"] = JSON.stringify(columnFilters);
					}
					else{
						sendObj["requestFieldFilters"] = null;
					}
					
					sendObj['defaultOrder'] = "assignedOrder:asc"
					if (window.manageMyRequests){
						sendObj['requestorIds'] = [globalUserInfo["userId"]];
						sendObj['defaultOrder'] = "requestedOrder:asc"
					}

					// If the ordering the user wants is identical to the default order, don't even send the
					// custom order. BUG 4324.
					if (sendObj["defaultOrder"] == sendObj["orderBy"]) {
						sendObj["orderBy"] = "";
					}
					
				ajaxModule().getFromAppService(appServiceEndpoints.SEARCH, sendObj).then(function(r){
					if (typeof(r) == "object"){
						if (r["result"] == "success"){
							console.log(settings)
							let resData = JSON.parse(r.data);

							// If we have any link fields then we need to get and decode the links
							if (linkFields.length > 0) {
								var linksToFetch = [];

								// Filter out only the links we need to fetch
								resData.forEach( x => {
									linkFields.forEach(field => {
										linksToFetch = linksToFetch.concat( x[field['requestTypeFieldId']] );
									});
								});

								// Make sure we are only dealing with a set of numbers and no duplicates.
								linksToFetch = [...new Set(linksToFetch.filter(x => x))];

								// Filter out links that we already have and anything that is not valid.
								if (window.top.linkData && Array.isArray(window.top.linkData)) {
									linksToFetch = linksToFetch.filter(x => !window.top.linkData.includes(parseInt(x)));
								}
								linksToFetch = linksToFetch.filter(x => parseInt(x) != 0 && x != undefined);
								
								// Make the ajax call if we have things to get.
								if (linksToFetch.length > 0) {
									ajaxModule().getLinksByIds(linksToFetch).then(function(response){
										//After the links are deoded they get stored in a global var so now we can continue 
										ajaxModule().decodeLinks(response).then(function(){
											applySearchData(resData, data, r, callback);
										}).catch(reason => {console.warn(`Decode links faild with: ${reason}`);});
									}).catch(reason => {console.warn(`Get links faild with: ${reason}`);});
								}
								else {
									//If we have nothing to get then apply the data
									applySearchData(resData, data, r, callback);
								}
							}
							else {
								//Apply the search data 
								applySearchData(resData, data, r, callback);
							}							
						}
						else {
							swal("Error In Service", r['error'] , "error");
						}
					}
					else{
						swal("Error In Service", "Request Timed Out" , "error");
					}						
				})
			
			},
			processing: true,
			'language':{ 
				"loadingRecords": "<div class='blueLoadingSpinner'></div><br>Loading...",
				"processing": "<div class='blueLoadingSpinner'></div><br>Loading..."
			},
			columns: tableColumns,
			order: [],
			paging: true,
			autoWidth: false,
			columnDefs: [
				{ "searchable": false, "targets": [0, 7]}
			],
			"drawCallback": function (settings) {
				requestDrawCallBack.call(this, settings);
			},
			"headerCallback": function (thead, data, start, end, display) {
				$(thead).find('th').each(function (tableHeaderIndex, tableHeader) {
					var colHeaderText = $(tableHeader).clone().children().remove().end().text();
					if (typeof tableColumns[tableHeaderIndex] !== "undefined" && (tableColumns[tableHeaderIndex]['dataTypeId'] == 5 || tableColumns[tableHeaderIndex]['data'] == "requestorName")) {
						var filterButton = $('<div class="columnFilterButton"></div>')
						$(tableHeader).html(colHeaderText + $('<div>').append($(filterButton)).html())
					}
				});
			},
			pageLength: ViewOption,
			scrollX: true,
			scrollY: 700,
			rowReorder: rowReorderSetting,
			fixedColumns: fixedColumnsSetting
		});

		//This is for priority reordering 
		manageRequestsTable.on( 'row-reordered', function ( event, diff, edit ) {
			rowReorderHandler(event, diff, edit);
		});

		$(".form-control.input-sm").bind("change", function (e) { // put view option in cookie for consumption later
			document.cookie = "displayOptions = " + $(e.target).val();
		})
		
		// TRY column_data_type: rendered_html instead of html????
		// dataTypes 1, 3, 4, 7 need filter_type: "auto_complete"
		// dataType 5 needs filter_type: "multi_select"
		// dataType 2 needs filter_type: "text"

		tableColumnsForYadcf = []
		$.each(tableColumns, function (tableColumnIndex, tableColumn) {
			if (tableColumn['data'] == "requestorName" || tableColumn['dataTypeId'] == 5) {
				var tableColumnConfig = {
					column_number: tableColumnIndex,
					filter_default_label: "-- Filter --",
					column_data_type: "text",
					filter_type: "multi_select",
					select_type: "select2",
					filter_match_mode: "contains",
					
					select_type_options: {
						width: '150px',
						placeholder: 'Select tag',
						allowClear: true ,   // show 'x' (remove) next to selection inside the select itself
						sortResults: function(data) {
							/* Sort data using lowercase comparison */
							return data.sort(function (a, b) {
								a = a.text.toLowerCase();
								b = b.text.toLowerCase();
								if (a > b) {
									return 1;
								} else if (a < b) {
									return -1;
								}
								return 0;
							});
						}
					},
					html_data_type: "text",
					filter_reset_button_text: false
				}
				tableColumnsForYadcf.push(tableColumnConfig)
			}

		});
		yadcfTableConfigOptions = {
			//cumulative_filtering: true Would be a nice improvement but as soon as you choose one option from the dropdown, it's impossible to add more options...
		}
		if (tableColumnsForYadcf.length > 0) {
			yadcf.init(manageRequestsTable, tableColumnsForYadcf);
		}

		$('#basicLoadingModal').modal('hide');

		$(window).resize();
		return false;				
		
		
	}

	/**
	 * Apply the data to the datatable.
	 * @param {JSON[]} resData The row data from the svcs.
	 * @param {JSON} data Original call to do proper loading. 
	 * @param {JSON} response Full responce for other info needed from svc
	 * @param {Function} callback Callback fnc from datatable to apply data.
	 */
	var applySearchData = function(resData, data, response, callback){
		var retOBJ = {
			data: resData,
			draw: data.draw,
			recordsTotal: response["recordsTotal"],
			recordsFiltered: response["recordsPassingFilter"]
		};
		retOBJ["yadcf_data_4"] = response["columnFilterData"]["requestors"];
		$.each(response.columnFilterData, function(key, val){
			var fieldId = key;
			if (fieldId != ""){
				var col = data.columns.findIndex(x => parseInt(x.name) == fieldId)
				if (col != -1){
					retOBJ[`yadcf_data_${col}`] = val;
				}
			}
		});
		callback(retOBJ);
	}

	var requestDrawCallBack = function(settings){

		$('.columnFilterButton').on('click', function (event) {
			console.log("CLICKED COLUMN FILTER BUTTON INSIDE DRAW CALLBACK");

			if ($(this).hasClass('activeColumnFilterButton')) {
				$(this).removeClass('activeColumnFilterButton');
				if ($(this).closest('tr').find(".activeColumnFilterButton").length == 0)
				{
					$('#manageRequestsTable_wrapper > div > div > div > div.dataTables_scroll > div.dataTables_scrollHead').css('height', '');
					$('#manageRequestsTable_wrapper > div > div > div > div.DTFC_LeftWrapper > div.DTFC_LeftHeadWrapper').css('height', '');	
				}
			}
			else {
				$(".activeColumnFilterButton").removeClass("activeColumnFilterButton");
				$(this).addClass('activeColumnFilterButton');
				//IMPORTANT: if you attempt to show the filter with the overflow: visable css it will graphicly make everything look bad and disalighn head to body
				//this is not the best way but it works
				$('#manageRequestsTable_wrapper > div > div > div > div.dataTables_scroll > div.dataTables_scrollHead').css('height', '');
				$('#manageRequestsTable_wrapper > div > div > div > div.DTFC_LeftWrapper > div.DTFC_LeftHeadWrapper').css('height', '');
				$('.dataTables_scrollHead').height($($(this).parent().children()[1]).height() + $('.dataTables_scrollHead').height() + 4);
				$('.DTFC_LeftHeadWrapper').height($($(this).parent().children()[1]).height() + $('.DTFC_LeftHeadWrapper').height() + 4);
				//this would fix the bottum buttons overlaping onto table but there is no good way to reset it after filter is closed.
				//$('.DTFC_ScrollWrapper').height($('.DTFC_ScrollWrapper').height() + $($(this).parent().children()[1]).height());
			}
			event.stopPropagation();
		});

	}

	/**
	 * Handler function for the datatable reordering function.
	 * @param {JSON} event The actual jquery event.
	 * @param {JSON} diff The table diffs.
	 * @param {JSON} edit The rows being edited.
	 */
	var rowReorderHandler = async function(event, diff, edit) {

		console.log(event);
		console.log(diff);
		console.log(edit);

		var manageRequestsTable = $("#manageRequestsTable").DataTable();

		// We can't allow users to reorder queuable rows below the unqueueable ones.
		if (diff.some(x => [x.oldData, x.newData].includes(0) || [x.oldData, x.newData].includes(undefined) || [x.oldData, x.newData].includes(null))) {
			
			// Let the user know that they can't do this.
			var notificationTitle = "Invalid Reorder Operation";
			var notificationMsg = "Cannot prioritize requests that have no priority.";
			if (typeof window.invalidReorderNotification !== "undefined") {
				window.invalidReorderNotification.update({ 'title': notificationTitle, 'message': notificationMsg, 'type': "yellowNotification" });
			}
			else {
				window.invalidReorderNotification = $.notify({
					title: notificationTitle,
					message: notificationMsg
				}, {
					delay: 0,
					type: "yellowNotification",
					template: utilities().notifyJSTemplates.default,
					onClose: function () {
						window.invalidReorderNotification = undefined;
					}
				});
			}

			// Then redraw the table to restore the table's ordering from before they tried to do this.
			// Passing in false tells datatables to reload its data, but maintain the current page.
			manageRequestsTable.draw(false);
			return;
		}
		
		var transientRecordsPromises = [];
		for ( var i=0, ien=diff.length ; i<ien ; i++ ) {
			$(diff[i].node).addClass("reordered");
			var sendObj = {
				requestId = manageRequestsTable.row( diff[i].node ).data()['id']
			};		
			
			var colName = "";
			if (window.manageMyRequests) {
				colName = "requested";
				sendObj["requestedOrder"] = diff[i]['newData'];
			}
			else 
			{
				colName = "assigned";
				sendObj["assignedOrder"] = diff[i]['newData'];
			}

			transientRecordsPromises.push(ajaxModule().updateTransientRecords(sendObj, colName));
		}

		Promise.all(transientRecordsPromises).then(function(transientRecordsResults) {
			if (transientRecordsResults.every(x => x.result == "success")) {
				displayUnsavedTableChanges();
			} else {
				var errorRes = transientRecordsResults.find(x => x.result != "success");
				swal("Warning!", errorRes["error"], "warning");
			}
			manageRequestsTable.draw(false);
		}).catch(function() {
			swal("Error In App Service", "Request Timed Out" , "error");
		})
		
	}

	var resetRequests = function(){
		var colName = "assigned"
		if (window.manageMyRequests) {
			colName = "requested"
		}

		ajaxModule().cancelReorder(colName).then(function(r){

			if (typeof(r) == "object"){
				if (r.result == "success"){
					closeUnsavedTableChanges(true);
				}
				else{
					swal("Error In App Service", r['error'] , "error");
				}
			}
			else 
			{
				swal("Error In App Service", r , "error");
			}
		});

	}

	/**
	 * Checks to see if the main table can be edited.
	 * @param {number} requestTypeId The request type ID we're looking for.
	 */
	var checkTransColumnLock = function(requestTypeId){
		return new Promise(async function(resolve,reject){
			var inputObj = {requestTypeId : requestTypeId}
			var r = await ajaxModule().checkAssignedOrderLock(inputObj);

			if (typeof(r) == "object"){
				if (r.result == "success"){
					if ('lockedByCurrentUser' in r){
						displayUnsavedTableChanges();
					}
					else if ('locked' in r && !window.manageMyRequests){
						window.top.rowReorderLocked = true;
						closeUnsavedTableChanges();
						swal("Warning!", r.locked, "info");
						//$("#lockMsg").text(r.locked);
					}
					else 
					{
						window.top.rowReorderLocked = false;
						closeUnsavedTableChanges();
						$("#lockMsg").text("");
					}
				}
				else 
				{
					swal("Warning!", r['error'] , "warning");
				}
				console.log(r);
			}
			else{
				swal("Error In App Service", "Request Timed Out" , "error");
				reject();
			}
			resolve(true);
		});
	}

	/**
	 * Checks if there is a table draft for the current request type ID.
	 * @param {number} requestTypeId The ID of the request type we're managing.
	 */
	var checkTableDraft = async function(requestTypeId) {
		if (window.manageMyRequests) {
			// This is the My Requests page, so there can only be two outcomes,
			// the user has a draft, or not.
			var response = await ajaxModule().checkDraftRequestedOrder(requestTypeId);
			if (response["result"] == "success") {
				if (response["data"]) {
					displayUnsavedTableChanges();
				}
			}
		} else {
			// The Manage Requests page. Pass this through to the trans column lock function.
			await checkTransColumnLock(requestTypeId);
		}
	}

	/**
	 * Displays the unsaved changes notification and the table update buttons when the current
	 * user has a draft.
	 */
	var displayUnsavedTableChanges = function() {
		$("#manageRequestsTable").attr("hasChanges", true);
		utilities().displayUnsavedChangesNotification();
		$("#UpdateRequestsButtons").fadeIn("slow");
		window.top.rowReorderLocked = false;
		$("#lockMsg").text("");
	}

	/**
	 * Hides the unsaved changes notification and the table update buttons when the notification needs
	 * to be hidden.
	 * @param {bool} redraw Do we want to redraw the manage requests table?
	 */
	var closeUnsavedTableChanges = function(redraw=false) {
		$("#manageRequestsTable").attr("hasChanges", false);
		utilities().hideUnsavedChangesNotification();
		$("#UpdateRequestsButtons").fadeOut("fast");
		
		if (redraw) {
			$("#manageRequestsTable").DataTable().draw();
		}
	}

	/**
	 * Function to get a list of visible request types - defined as request types that can be edited and/or viewed by this user.
	 */
	var getVisibleRequestTypes = function() {
		return new Promise(function(resolve, reject) {
			let promiseArray = [];
			promiseArray.push(ajaxModule().getRequestTypesICanEdit());
			promiseArray.push(ajaxModule().getRequestTypesICanView());
	
			Promise.all(promiseArray).then(function(responses) {
				let editableRequestTypesList = utilities().decodeServiceResponce(responses[0]);
				let viewableRequestTypesList = utilities().decodeServiceResponce(responses[1]);

				let returnArr = editableRequestTypesList;
				$.each(viewableRequestTypesList, function(i, requestType) {
					if (!returnArr.find(x => x.id == requestType.id && x.displayName == requestType.displayName)) {
						returnArr.push(requestType);
					}
				});

				resolve(returnArr);
			});
		});
	}

	/**
	 * Helper function to populate the request types dropdown with visible request types.
	 */
    var populateRequestTypesList = function() {
        return new Promise(function (resolve, reject) {
			var defaultOptions = null;
            getVisibleRequestTypes().then(function(processedRequestTypesArray) {

                var dropdown = $('<select></select>'); // only used as a container
                $.each(processedRequestTypesArray, function (index, requestType) {

                    if (requestType["disabled"] != 1) {
                        var requestTypeOption = $('<option></option>').attr('value', index).attr('requesttypeid', requestType['id']).text(requestType['displayName'])
                        if (requestType['isDefault'] == 1) {
                            defaultOptions = index;
                            requestTypeOption.attr('selected','selected');
                            dropdown.prepend(requestTypeOption);
                        }
                        else {
                            dropdown.append(requestTypeOption);
                        }

                        if (window.top != window.self) {
                            var reqTypeId = window.parent.$("#requestTypeId").val();
                            if (reqTypeId == requestType['id']) {
                                preSelect = index;
                            }
                        }
                        else {
                            if (requestType['isDefault'] == 1) {
                                defaultOptions = index;
                            }
                        }
                    }

                    if (requestType['canAdd'] || !requestType['restrictAccess']) {
                        showMakeNewRequest = true;
                    }
                });

                utilities().sortDropdownlist(dropdown);
                $('select#manageRequestsTable_requestTypeDropdown').html(dropdown.html());
                
                if ($('select#requestTypeDropdown').children().length == 0) {
                    if (defaultOptions != null) {
                        $(dropdown).val(defaultOptions);
                    }
                    else {
                        $(dropdown).val(0);
                    }


                    window.savedFieldsOptionsHTML = dropdown.html();
                    $('select#requestTypeDropdown').html(window.savedFieldsOptionsHTML);

                    if (window.top != window.self) {
                        $('select#requestTypeDropdown').val(preSelect);
                    }
                }

                resolve(true);
            }).catch(function (response) {
				console.error("error");
				console.error(response);
                reject(false);
            });
        });
    }


	var documentReadyFunction = function () {
		$('#basicLoadingModal').modal('show');

		$('body').on('change', 'select#manageRequestsTable_requestTypeDropdown', function (event) {
			var thisRequestTypeId = parseInt($(this).find('option:selected').attr('requesttypeid'));
			checkTableDraft(thisRequestTypeId);
			initManageRequestsTable(thisRequestTypeId);
		});

		$('table#manageRequestsTable > tbody').on('click', 'td.details-control', function (event) {
			var tr = $(this).closest('tr');
			var row = $('table#manageRequestsTable').DataTable().row(tr);

			if (row.child.isShown()) {
				// This row is already open - close it
				row.child.hide();
				tr.removeClass('shown');
			}
			else {
				// Open the request in the #requestEditorModal
				utilities().hideUnsavedChangesNotification();
				ajaxModule().fetchSpecificRequest(row.data(), row.index());
			}
		});

		$('body').on('click', '.updateRequestsAssignedOrderButton', function (event) {
			//manage requests
			
			ajaxModule().commitOrder("assigned").then(function(r){

				if (typeof(r) == "object"){
					if (r.result == "success"){
						closeUnsavedTableChanges(true);
					}
					else{
						swal("Error In App Service", r['error'] , "error");
					}
				}
				else 
				{
					swal("Error In App Service", r , "error");
				}
			});
		});

		$('body').on('click', '.updateRequestsRequestedOrderButton', function (event) {
			//my requests 
			ajaxModule().commitOrder("requested").then(function(r){

				if (typeof(r) == "object"){
					if (r.result == "success"){
						closeUnsavedTableChanges(true);
					}
					else{
						swal("Error In App Service", r['error'] , "error");
					}
				}
				else 
				{
					swal("Error In App Service", r , "error");
				}
			});

			
		});

		$('body').on('click', '#resetRequests', function (event) {
			//my requests 
			resetRequests();
		});

		$('body').on('click', '#requestEditorModal .requestEditorContainer .bottomButtons .requestEditorCancel', function (event) {
			// Trigger a click on this request's parent table row's expand/collapse button
			// No equivalent for submit button b/c submitRequestEditor calls .click() on cancel button to close
			window.allowRequestEditorHide = true;
			$('#requestEditorModal').modal('hide');
		});

		$(window).on('resize', function () {
			// Need to resize any request items tables inside the manageRequests table
			if (typeof resizeTimeout !== "undefined") {
				clearTimeout(resizeTimeout)
			}

			resizeTimeout = setTimeout(function () {
				utilities().resizeManageRequestsTable();
				dataTableModule().resizeRequestItemsTableInRequest();
			}, 200);
		});

		$('#manageRequestsTable_wrapper .dataTables_scrollBody').scroll(function () {
			if ($("#manageRequestsTable_wrapper .dataTables_scrollHead").is(":visible")) {
				$("#manageRequestsTable_wrapper .dataTables_scrollHead").scrollLeft($('#manageRequestsTable_wrapper .dataTables_scrollBody').scrollLeft());
			}
		});

		$('#requestEditorModal').on('hidden.bs.modal', function () {
			$('#requestEditorModal .dropdownEditorContainer').removeClass('makeVisible');
			window.allowRequestEditorHide = false;
			if ($("#manageRequestsTable").attr("hasChanges") == "true") {
				displayUnsavedTableChanges();
			} else {
				utilities().closeUnsavedChangesNotification();
			}
		});

		$('#requestEditorModal').on('hide.bs.modal', function (e) {
			if (window.unsavedChangesNotificationOpen && !window.allowRequestEditorHide) {
				e.preventDefault();
				e.stopImmediatePropagation();
				console.log("Prevented modal from closing...");
			}
			$(window).trigger('resize');
			window.CurrentPageMode = "manageRequests"
			
		});

		var promiseChain = [];
		promiseChain.push(populateRequestTypesList());
		promiseChain.push(ajaxModule().processRequestTypesArray());
		promiseChain.push(ajaxModule().populateRequestItemTypesList());
		promiseChain.push(ajaxModule().populateSavedFieldsList());

		Promise.all(promiseChain)
			.then(function () {
				$('select#manageRequestsTable_requestTypeDropdown').change();
			});
		$('#basicLoadingModal').modal('show');
	}

	return {
		documentReadyFunction: documentReadyFunction,
		checkTransColumnLock: checkTransColumnLock,
	}
});

var manageRequests = manageRequestsModule();

$(document).ready(function () {
	manageRequests.documentReadyFunction();
});
