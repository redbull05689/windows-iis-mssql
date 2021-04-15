var dtLoaded = false;

function getViewport(){

 var viewPortWidth;
 var viewPortHeight;

 // the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight
 if (typeof window.innerWidth != 'undefined') {
   viewPortWidth = window.innerWidth,
   viewPortHeight = window.innerHeight
 }

// IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)
 else if (typeof document.documentElement != 'undefined'
 && typeof document.documentElement.clientWidth !=
 'undefined' && document.documentElement.clientWidth != 0) {
    viewPortWidth = document.documentElement.clientWidth,
    viewPortHeight = document.documentElement.clientHeight
 }

 // older versions of IE
 else {
   viewPortWidth = document.getElementsByTagName('body')[0].clientWidth,
   viewPortHeight = document.getElementsByTagName('body')[0].clientHeight
 }
 return [viewPortWidth, viewPortHeight];
}

function showOfficeFrames()
{
	//show office pdf frames
	els = document.getElementsByTagName("iframe")
	for(i=0;i<els.length;i++)
	{
		if (els[i].className == "officeFrame")
		{
			els[i].style.visibility = "visible"
		}
	}
}

function hideOfficeFrames()
{
	//hide office pdf frames, because they like to show over layers that are above them
	els = document.getElementsByTagName("iframe")
	for(i=0;i<els.length;i++)
	{
		if (els[i].className == "officeFrame")
		{
			els[i].style.visibility = "hidden"
		}
	}
}

function populateElementalMachineTimePoints()
{	

	// This is a hack to make sure datatables is loaded for the Time Point selector.
	// I don't know why but a lot of js includes freak out when datatables is included,
	// like fancytree or select2.
	if (!dtLoaded) {
		$.getScript("js/jquery.dataTables.1.10.15.min.js", function() {
			dtLoaded = true;
		})
	}	

	// Which collection method is selected
	var methods = document.getElementById("elementalMachineCollectionMethod");
	var collectionType = methods.options[methods.selectedIndex].value;

	// Clear the current values and set a default
	if (dtLoaded) {
		// If we have a DataTable loaded already, then destroy it and remove all
		// traces.
		if ($.fn.DataTable.isDataTable("#elementalMachineDataPoints")) {
			$('#elementalMachineDataPoints').DataTable().destroy();
		}
	}

	// Clear the table div and populate it with a DataTable-friendly default.
	$('#elementalMachineDataPoints').empty();
	$('#elementalMachineDataPoints').append('<thead><tr><th></th></tr></thead><tbody><tr><td>No Data Found</td></tr></tbody>');
	
	if(collectionType != "selectTimePoints") {
		return;
	}
	
	// Which machine is selected?
	var machines = document.getElementById("elementalMachineName");
	var theMachineGuid = machines.options[machines.selectedIndex].value;

	var data = {
		uuid:theMachineGuid,
		startEpoch: "",
		endEpoch: ""
	}

	$.ajax({
		url: '/arxlab/ajax_loaders/elementalMachines/getMachineSamples.asp',
		type: 'POST',
		dataType: 'json',
		data: data,
	})
	.success(function(response) {
		// Build the table if we have a response.
		if (response.length > 0) {

			// Empty the existing contents and start constructing the row. We'll keep track of which column to hide
			// (the sample_epoch column) as well for later.
			$('#elementalMachineDataPoints').empty();
			var headerRow = $("<tr></tr>");
			var hideCol;
			var count = 0;
			$.each(response, function(index, item) {

				// Get the keys of the object. If we don't have any keys, that means we didn't get a response.
				keys = getEMKeys(item);
				if ((keys.length) == 0) {
					return;
				}

				// Build the header row with the keys if we don't already have one.
				if(headerRow.html() == "")
				{
					// build the table headers
					$.each(keys, function(keyI, keyItem){
						colhead = keyItem.toUpperCase();
						
						if (colhead == "SAMPLE_EPOCH") {
							hideCol = count;
						}

						$(headerRow).append("<th>"+colhead+"</th>")
						count = count + 1;
					});
					$("#elementalMachineDataPoints").append("<thead>" + headerRow.html() + "</thead><tbody>")
				}
				
				// Now build the actual data row.
				var dataRow = $("<tr></tr>");
				$.each(keys, function(keyI, keyItem) {
					dataRow.append("<td>" + item[keyItem] + "</td>");
				});
				$("#elementalMachineDataPoints").append(dataRow);
			});

			// Close the tbody and initialize DataTable on it.
			$("#elementalMachineDataPoints").append("</tbody>");
			var table = $('#elementalMachineDataPoints').DataTable( {
				"pageLength": 8,
				"columnDefs": [
					{
						"targets": [hideCol],
						"visible": false,
						"searchable": false
					}
				],
				dom: 'rtip',
				buttons: [
					{
						extend: 'csvHtml5',
						exportOptions: {
							columns: ':visible'
						}
					}
				],
				"pagingType": "full_numbers",
				"scrollX": "100%",
				"scrollY": "288px",
			} );

			// Make each row selectable on click and show the submit button.
			$('#elementalMachineDataPoints tbody').on( 'click', 'tr', function () {
				$(this).toggleClass('selected');
			} );
			$("#emDataSaveButton").removeAttr("style");
		}
	})
	.fail(function(error, textStatus, errorThrown) {
		$('#elementalMachineDataPoints').empty();
		$('#elementalMachineDataPoints').append('<thead><tr><th></th></tr></thead><tbody><tr><td>Error Loading Data</td></tr></tbody>');
	})
}

function getEMKeys(emObj) {
	// Get the keys of emObj.
	var badObj = false;
	keys = $.map(emObj, function(v, i) {
		// If we have an Error in the keys, then add a flag to the key array.
		if (i.endsWith("Error")) {
			return "BADOBJ";
		} else {
			return i;
		}
	});

	// If there was an error, then return an empty array so the table won't try to build with a bad object.	
	if (keys.indexOf("BADOBJ") > -1) {
		keys = [];
	}

	return keys;
}

function checkElementalMachinesAndSubmit()
{
	var machines = document.getElementById("elementalMachineName");
	var theMachineGuid = machines.options[machines.selectedIndex].value;
	var theMachineName = machines.options[machines.selectedIndex].innerHTML;
	var timeType = document.getElementById("elementalMachineCollectionMethod").value;

	// If there isn't anything selected, then don't do anything else.
	if(theMachineGuid == -1)
	{
		swal("Error","You must select a machine name.", "error");
		return false;
	}
	
	// If we're looking at a time range with nothing selected, then don't do anything.
	if(timeType == "selectTimeRange" & ($("#startTimeEpoch").val().length == 0 || $("#endTimeEpoch").val().length == 0))
	{
		swal("Error","You must select a start time and end time for data collection.", "error");
		return false;
	}

	// If we're looking at time points and nothing is selected, then don't do anything.
	if (timeType == "selectTimePoints" & $("#elementalMachineDataPoints").DataTable().rows('.selected').data().length == 0) {
		swal("Error", "You must select data points for data collection.", "error");
		return false;
	}
	
	// Start building the data to be POSTed to the API with common elements to both data sets.
	data = {
		experimentId: $("#emFormExperimentId").val(),
		experimentType: $("#emFormExperimentType").val(),
		elementalMachineGuid: theMachineGuid,
		elementalMachineName: theMachineName
	};

	if (timeType == "selectTimeRange") {
		var startTimeEpoch = $("#startTimeEpoch").val();	
		var endTimeEpoch = $("#endTimeEpoch").val();

		// The elemental machines API is expecting seconds and the epoch strings from the datepicker
		// are in milliseconds, so knock off the last 3 characters of the strings.
		startTimeEpoch = startTimeEpoch.substr(0, startTimeEpoch.length - 3);
		endTimeEpoch = endTimeEpoch.substr(0, endTimeEpoch.length - 3);

		data.startTimeEpoch = startTimeEpoch;
		data.endTimeEpoch = endTimeEpoch;

		var sampleData = {uuid:theMachineGuid, startEpoch:data.startTimeEpoch, endEpoch:data.endTimeEpoch}

		// Get the sample data and add it to the data JSON, then submit it.
		$.ajax({
			url: '/arxlab/ajax_loaders/elementalMachines/getMachineSamples.asp',
			type: 'POST',
			dataType: 'json',
			data: sampleData,
		})
		.success(function(response){
			data.data = JSON.stringify(response);
			return submitElementalMachinesData(data);
		})
	}

	// Build the data set from the selected rows and submit that.
	if (timeType == "selectTimePoints") {
		var epochList = getEMSampleEpochs();
		data.startTimeEpoch = epochList[0];
		data.endTimeEpoch = epochList[1];
		data.data = getSelectedEMDataPoints();
		return submitElementalMachinesData(data);
	}
}

function submitElementalMachinesData(data) {
	
	// Disable the submit button while this is happening.
	$("#emDataSaveButton").innerHTML = "Processing...";
	$("#emDataSaveButton").prop("disabled",true);

	// Try to submit the selected data.
	$.ajax({
		url: '/arxlab/experiments/addElementalMachinesData.asp',
		type: 'POST',
		dataType: 'json',
		data: data,
	})
	.success(function(response) {
		hidePopup('addElementalMachinesDataDiv');
		experimentSubmit(false, false, false, false, false);
		location.reload();
	})
	.fail(function(error, textStatus, errorThrown) {
		swal("Error","There was an error saving the Elemental Machines data. Please try again.", "error");
	})
	.always(function() {
		$("#emDataSaveButton").prop("disabled",false);
		$("#emDataSaveButton").innerHTML = "Submit";
	});
	
	return false;
}

function getEMSampleEpochCol() {
	// Helper function to figure out which column is the sample_epoch.
	return $("#elementalMachineDataPoints").DataTable().column(':contains(SAMPLE_EPOCH)')[0][0];
}

function getEMSampleEpochs() {
	// Helper function to get the earliest sample_epoch and the latest one for time point selection.
	var selectedRows = $("#elementalMachineDataPoints").DataTable().rows('.selected').data();
	var numSelected = selectedRows.length;
	var sampleEpochCol = getEMSampleEpochCol();
	var output = [];

	output.push(selectedRows[0][sampleEpochCol]);
	output.push(selectedRows[numSelected - 1][sampleEpochCol]);
	
	return output;
}

function getSelectedEMDataPoints() {
	// Create a json array of selected datapoints. I'm reconstructing the json objects because the table
	// might have dropped some objects from the sample list if they had errors so row # =/= the original
	// index of the json array.

	var selectedRows = $("#elementalMachineDataPoints").DataTable().rows('.selected').data();
	var numSelected = selectedRows.length;
	var jsonKeys = [];
	var output = [];
	$("#elementalMachineDataPoints").DataTable().columns().every(function() {
		jsonKeys.push(this.header().innerHTML.toLowerCase());
	});

	for(i = 0; i < numSelected; ++i) {
		point = {};
		$.each(jsonKeys, function(key, name) {
			point[name] = selectedRows[i][jsonKeys.indexOf(name)];
		})
		output.push(point);
	}
	return JSON.stringify(output);
}

function checkEMCreds() {
	$("#EMSignDivSignButton").prop("disabled", true);
	// Validate the credentials submitted by checking if they can be used to get an access token.
	data = {
		userName: $("#emEmail").val(),
		password: $("#emPass").val()
	};

	$.ajax({
		url: '/arxlab/ajax_loaders/elementalMachines/validateEMCredentials.asp',
		type: 'POST',
		data: data
	})
	.success(function(response) {
		// If there's a blank response, then the credentials are bad, so wipe the session credentials
		// and throw an alert.
		if (response == "") {
			clearSessionEMCreds();
			swal("Error", "Invalid login credentials.", "error");
			$("#EMSignDivSignButton").prop("disabled", false);
		} else {
			// Otherwise, hide the sign in div and show the data div.
			populateMachineList();
			hidePopup('elementalMachinesSignDiv');

			if ($("elementalMachinesSignDiv").attr("adddata") == "true") {
				showPopup('addElementalMachinesDataDiv');
			} else {
				location.reload();
			}
		}
	});
}

function clearSessionEMCreds() {
	// Helper function that wipes the current session's elemental machines credentials.
	// Only use this when the credentials are bad.
	$.ajax({
		url: '/arxlab/ajax_loaders/elementalMachines/clearSessionEMCredentials.asp',
		type: 'GET'
	});
}

function populateMachineList() {
	$.ajax({
		url: '/arxlab/ajax_loaders/elementalMachines/getMachineList.asp',
		type: 'GET'
	})
	.success(function(response) {
		var respJson = JSON.parse(response);
		if (respJson.length <= 0) {
			$("#elementalMachineName").append($('<option>', {value:-1, text:'No Machines Found'}));
		} else {
			$("#elementalMachineName").append($('<option>', {value:-1, text:'Select a Machine'}));

			$.each(respJson, function(id) {
				machName = respJson[id]['name'];
				guid = respJson[id]['uuid']
				$("#elementalMachineName").append($('<option>', {value:guid, text:machName}));
			})
		}
	});
}

function getEMDataForRange(guid, start, end, tableId) {
	// Fetches the EM Data for the given time range and constructs a basic HTML table out of it.
    var data = {uuid: guid, startEpoch: start, endEpoch: end};
    
    $.ajax({
		url: '/arxlab/ajax_loaders/elementalMachines/getMachineSamples.asp',
		type: 'POST',
		dataType: 'json',
		data: data,
	}).success(function(response) {
		console.log(response);
		
		var loadingWheel = $("<img>").attr("src", "images/loading.gif");
		$("#" + tableId).append(loadingWheel);
		makeEMDataTable(response, tableId);
    })
}

function makeEMDataTable(dataJson, tableId) {
	// Constructs a basic HTML table out of dataJson and injects it into the table cell belonging to tableId.

	// Start by instantiating the table and giving it a class.
	var tableStr = $("<table>").addClass("EMDataTable");
	var divStr = $("<div></div>").addClass("EMDataTableHolder").append(tableStr);
	
	// If we don't have any rows, don't do any of this stuff.
	if (dataJson.length > 0) {

		// Fetch the first object and grab its keys. Those will be the column headers. Add an "annotation*" header too.
		var headers = Object.keys(dataJson[0]);

		// Set up the next few parts of the table.
		var tableHead = $("<thead>");
		var headerRow = $("<tr>");
		var tableBody = $("<tbody>");

		$.each(dataJson, function(rowIndex, row) {

			// Set up a tr for each table row.
			var tr = $("<tr>");

			$.each(headers, function(index, key) {

				// Set up a blank value.
				var value = "";

				// If we're looking at the first row, build the headerRow as well.
				if (rowIndex == 0) {
					colHead = key == "sample_epoch" ? "time" : key;
					headerRow.append("<th>" + colHead + "</th>");
				}

				if (key == "sample_epoch") {

					var date = new Date(row[key] * 1000);
					var day = date.toLocaleDateString();
					var time = date.toLocaleTimeString();
					value = day + "\r\n" + time;
					
				} else {

					// Otherwise, grab the value that corresponds to this cell.
					value = row[key];

				}

				// Add the value to the row.
				tr.append("<td>" + value + "</td>");
			});
			
			// Add the header if we're in the first row.
			if (rowIndex == 0) {
				tableHead.append(headerRow);
			}

			// Then add the row we just built.
			tableBody.append(tr);
		})

		// Put it all together.
		tableStr.append(tableHead).append(tableBody);
	} else {
		divStr.text("No Data");
	}

	// Now inject the table into its proper location.
	$("#" + tableId).append(divStr);
	$("#" + tableId).find("img").hide();
}

loadedWitnessList = false;
loadedSoftWitnessList = false;
currentPopup = "";
function showPopup(popupId)
{
	//show popup


	//fetch revision number for witness list.
	var revisionId = $("#thisRevisionNumber").val();

	//if there is a pdf frame hide it
	try{document.getElementById('pdfFrame').style.visibility='hidden'}catch(err){}
	try{document.getElementById('chemDrawWinRegSearch').style.visibility='hidden'}catch(err){}
	try
	{	
		//hide office frames and hide chemdraw plugin
		hideOfficeFrames()
		document.getElementById("cdxRow").style.visibility = "hidden";
	}
	catch(err){}
	//show transparent black div that covers page.  frame is there to help with pesky elements that ignore z-index
	if (popupId == "uploadingDiv" || popupId == "loadingDiv" || popupId == "savingDiv"){
		document.getElementById("blackDiv").style.position = "fixed"
		document.getElementById("blackFrame").style.position = "fixed"
		document.getElementById("blackDiv").style.height = document.body.clientHeight+"px";
		document.getElementById("blackFrame").style.height = document.body.clientHeight+"px";
		document.getElementById("blackDiv").style.display = "block";
		document.getElementById("blackFrame").style.display = "block";
		document.getElementById(popupId).style.position = "fixed"
		document.getElementById(popupId).style.top = "50%"
		document.getElementById(popupId).style.left = "50%"

		//align popup properly
		document.getElementById(popupId).style.marginTop = "-170px"
		document.getElementById(popupId).style.marginLeft = "-170px"
	}
	if(popupId=="inventoryPopup"){
		$("#inventoryPopup").height("80vh");
		windowHeight = getViewport()[1];
		overflow = windowHeight - (40 + $("#inventoryPopup").height());
		if(overflow<0){
			origHeight = $("#inventoryPopup").height();
			$("#inventoryPopup").height(origHeight+overflow-60);
			$("#inventorySearchFrame").height(origHeight+overflow-60);
		}
	}
	if(popupId=="regDiv"){
		$("#regDiv").height(900);
		$("#regFrame").height(900);
		windowHeight = getViewport()[1];
		overflow = windowHeight - (40 + $("#regDiv").height());
		if(overflow<0){
			origHeight = $("#regDiv").height();
			$("#regDiv").height(origHeight+overflow-60);
			$("#regDiv").height(origHeight+overflow-60);
			$("#regFrame").height(origHeight+overflow-60);
			$("#regFrame").height(origHeight+overflow-60);
		}
	}

	if(popupId=="regDiv2"){
		$("#regDiv").height(900);
		$("#regFrame").height(900);
		windowHeight = getViewport()[1];
		overflow = windowHeight - (40 + $("#regDiv2").height());
		if(overflow<0){
			origHeight = $("#regDiv2").height();
			$("#regDiv2").height(origHeight+overflow-60);
			$("#regDiv2").height(origHeight+overflow-60);
			$("#regFrame2").height(origHeight+overflow-60);
			$("#regFrame2").height(origHeight+overflow-60);
		}
	}

	
	if ((popupId == 'signDiv' || popupId == 'ssoSignDiv') && !loadedWitnessList){
		signButtonsDiv = "signDivButtons";
		requesteeDivName = 'requesteeIdBoxDiv';
		loadingMessageDiv = "witnessListLoadingMessage";
		if(popupId == 'ssoSignDiv') {
			signButtonsDiv = "ssoSignDivButtons";
			requesteeDivName = 'ssoRequesteeIdBoxDiv';
			loadingMessageDiv = "ssoWitnessListLoadingMessage";
		}
		
		$("#"+signButtonsDiv).hide();
		$("#"+loadingMessageDiv).show();
		
		try{
			if (!(experimentId === parseInt(experimentId))){
				if(experimentId==undefined){
					experimentId = document.getElementById("experimentId").value;
					experimentType = document.getElementById("experimentType").value;
				}else if(experimentId == parseInt(experimentId)){	//ELN-1296 9/14 -- experimentId TYPE is not matching and its getting assigned to experimentId.value which is undefined and its breaking the process of witness
					experimentId = parseInt(experimentId);
					experimentType = parseInt(experimentType);
				}else{
					experimentId = experimentId.value;experimentType = experimentType.value;
				}
			}
		}catch(err){
			experimentId = document.getElementById("safeExperimentId").value;
			experimentType = document.getElementById("safeExperimentType").value;			
		}

		if (revisionId == undefined)
		{
			//get revision id out of url 
			var url = window.location.href;
			var name = "revisionNumber"
			name = name.replace(/[\[\]]/g, "\\$&");
			var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
				results = regex.exec(url);
			if (!results) return null;
			if (!results[2]) return '';
			revisionId = decodeURIComponent(results[2].replace(/\+/g, " "))

		}
		
	    $.ajax({
			type: "GET",
			async: true,
			url: 'ajax_loaders/getWitnessList.asp?experimentId='+experimentId+"&experimentType="+experimentType+"&r="+revisionId+"&random="+Math.random()
	    })
	    .done(function(response) {
			document.getElementById(requesteeDivName).innerHTML = response;
			$("#"+loadingMessageDiv).hide();
			$("#"+signButtonsDiv).show();
			
			if(experimentType != 5 && experimentType != '5') {
				loadedWitnessList = true;
			}
		})
	    .fail(function(response) {
			document.getElementById(requesteeDivName).innerHTML ="<label for='requesteeIdBox'>Witness</label><select name='requesteeIdBox' id='requesteeIdBox' style='width:220px;'><option value='-2'>--Please select a Witness--</option><option value='-1'>--Not Pursued--</option><option value='"+defaultWitnessId+"' SELECTED>"+defaultWitnessName+"</option></select>"
		})
		.always(function() {
		});
	}
	var signOnPdf = localStorage.getItem("Sign");
	if (signOnPdf == "false")
		{
			// required items needed
			swal("", "Form is missing required fields. Please review your data and try again.", "error");
			swal({
				title: "",
				text: 'Form is missing required fields. Please review your data and try again.',
				type: "error",
				closeOnConfirm: false
				
			},
			function(){
				localStorage.setItem("Sign",true);
				var returnAdd = localStorage.getItem("curURL");
				window.location.replace(returnAdd);
			});

			
		}
	if (popupId == 'softSignDiv' && !loadedSoftWitnessList){
		$("#softSignDivButtons").hide();
		$("#softWitnessListLoadingMessage").show();
		
		try{
			if (!(experimentId === parseInt(experimentId))){
				if(experimentId==undefined){
					experimentId = document.getElementById("experimentId").value;
					experimentType = document.getElementById("experimentType").value;
				}else if(experimentId == parseInt(experimentId)){	//ELN-1321 7/25 -- experimentId TYPE is not matching and its getting assigned to experimentId.value which is undefined and its breaking the process of witness
					experimentId = parseInt(experimentId);
					experimentType = parseInt(experimentType);
				}
				else{
					experimentId = experimentId.value;experimentType = experimentType.value;
				}
			}
		}catch(err){
			experimentId = document.getElementById("safeExperimentId").value;
			experimentType = document.getElementById("safeExperimentType").value;			
		}
		
	    $.ajax({
			type: "GET",
			async: true,
			url: 'ajax_loaders/getWitnessList.asp?experimentId='+experimentId+"&experimentType="+experimentType+"&r="+revisionId+"&random="+Math.random()
	    })
	    .done(function(response) {
			document.getElementById("softRequesteeIdBoxDiv").innerHTML = response;
			$("#softWitnessListLoadingMessage").hide();
			$("#softSignDivButtons").show();
			
			if(experimentType != 5 && experimentType != '5') {
				loadedWitnessList = true;
			}
		})
	    .fail(function(response) {
			document.getElementById("softRequesteeIdBoxDiv").innerHTML ="<label for='requesteeIdBox' class='select-style-label'>Witness</label><div class='select-style'><select name='requesteeIdBox' id='requesteeIdBox' style='width:220px;'><option value='-2'>--Please select a Witness--</option><option value='-1'>--Not Pursued--</option><option value='"+defaultWitnessId+"' SELECTED>"+defaultWitnessName+"</option></select></div>"
		})
		.always(function() {
		});
	}
	
	//if(popupId == "newExperimentDiv")
		//populateExpTypes(false);
	
	if(popupId == "newExperimentNextStepDiv"){
		initProjectLinkDD("#linkProjectIdNextStep")
		$("#nextStepExperimentType").change(function(){
			if($("#nextStepExperimentType").val() == "")
			{
				$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > button").attr("disabled", true);
				$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > button").hide();
				$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > label").show();
			}
			else 
			{
				$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > button").attr("disabled", false);
				$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > button").show();
				$("#newExperimentNextStepDiv > form[name='copy_form'] > .bottomButtons > label").hide();
			}
		});
	}
	
	//show popup
	currentPopup = popupId;
	if (popupId == "uploadingDiv" || popupId == "loadingDiv" || popupId == "savingDiv" || popupId == "resetPassword"){
		document.getElementById(popupId).style.display = "block";
	}else{
		document.getElementById("modalDummy").setAttribute("href","#"+popupId);
		document.getElementById("modalDummy").click();
	}
	
	// Process after show
	if (popupId == "addMolDiv")
	{
		showAddStructureCheckbox();
	}
}

function showPopupPercentage(popupId,percentages)
{
	//show popup

	//if there is a pdf frame hide it
	try{document.getElementById('pdfFrame').style.visibility='hidden'}catch(err){}
	try
	{	
		//hide office frames and hide chemdraw plugin
		hideOfficeFrames()
		document.getElementById("cdxRow").style.visibility = "hidden";
	}
	catch(err){}
	//show transparent black div that covers page.  frame is there to help with pesky elements that ignore z-index
	//document.getElementById("blackDiv").style.position = "fixed";
//	document.getElementById("blackFrame").style.position = "fixed";
//	document.getElementById("blackDiv").style.height = document.body.clientHeight+"px";
//	document.getElementById("blackFrame").style.height = document.body.clientHeight+"px";
//	document.getElementById("blackDiv").style.display = "block";
//	document.getElementById("blackFrame").style.display = "block";
	
	windowWidth = window.innerWidth ? window.innerWidth : $(window).width()
	windowHeight = window.innerHeight ? window.innerHeight : $(window).height()

	elWidth = parseInt(percentages[0]*windowWidth);
	elHeight = parseInt(percentages[0]*windowHeight);

	document.getElementById(popupId).style.width = elWidth + "px";
	document.getElementById(popupId).style.height = elHeight + "px";
	document.getElementById(popupId).style.position = "fixed";
	document.getElementById(popupId).style.left = ((windowWidth - elWidth)/2)+"px";
	document.getElementById(popupId).style.top = ((windowHeight - elHeight)/2)+"px";

	document.getElementById("modalDummy").setAttribute("href","#"+popupId);
	document.getElementById("modalDummy").click();
	//document.getElementById(popupId).style.display = "block";
}

function getPopupSize(popupId,percentages)
{	
	windowWidth = window.innerWidth ? window.innerWidth : $(window).width()
	windowHeight = window.innerHeight ? window.innerHeight : $(window).height()

	elWidth = parseInt(percentages[0]*windowWidth);
	elHeight = parseInt(percentages[0]*windowHeight);
	return {width:elWidth,
			height:elHeight};
}



function hidePopup(popupId,fromX)
{
	// hack to make sure nothing's in the search registration.
	$("#searchRegistration").val("");
	window.linkedRegIdInfo = {};
	$("#regIdColCheckbox").prop("checked", false);
	try{
		//unhide pdf frame
		document.getElementById('pdfFrame').style.visibility='visible'
	}catch(err){}
	try{allowReset=true}catch(err){}
	try{$.get(mainAppPath+'/ajax_doers/resetInactivityTimer.asp?rand=' + Math.random())}catch(err){}
	try{document.getElementById('chemDrawWinRegSearch').style.visibility='visible'}catch(err){}
	try{
		//show office frames and chemdraw plugin
		showOfficeFrames()
		document.getElementById("cdxRow").style.visibility = "visible";
	}catch(err){}
	
	//hide popup and black div and frame
	if (popupId == "uploadingDiv" || popupId == "loadingDiv" || popupId == "savingDiv"){
		document.getElementById("blackDiv").style.height = "0px";
		document.getElementById("blackFrame").style.display = "none";
	}else{
		document.getElementById("lean_overlay").style.display = "none";
		$("#overlay_select2Compatible").removeClass('makeVisible');
	}
	document.getElementById(popupId).style.display = "none"
	if(popupId=="inventoryPopup" && fromX){
		try{
			molUpdatePrefix = "";
			molUpdateCdxml = "";
		}catch(err){}
	}
	if(popupId=="regDiv")
		$('regDiv').empty();
}


//Function added to check for reason before reopen or reject 8/18/2016
function enterReasonForReopenOrReject(reason, id)
{
	if (reason.length >= 4)
	{
		if(document.getElementById(id).disabled == true)
		{
			document.getElementById(id).disabled = false;
			document.getElementById(id).className = "enabled";
		}

		return;
	}

	document.getElementById(id).disabled = true;
	document.getElementById(id).className = "";
}


function initProjectLinkDD(idToLookAt){
	projSearchBox = $(idToLookAt).select2({
		multiple: true,
		maximumSelectionLength: 1,
		allowClear: true,
		placeholder: '',
		formatSearching: null,
		createSearchChoice: function (term, data) {
	    },
	    selectOnBlur: false,
	    minimumInputLength: 0,
	    formatResult: function(object, container, query){
				var contentHTML = "";
				contentHTML += '<div class="resultContent">'
				resultNameHTML = object['name']
				if(object['userExperimentName'] && object['userExperimentName'] !== "" && object['userExperimentName'] !== null){
						resultNameHTML += " - " + object['userExperimentName'];
				}
				if( object['parentName'] != "")
				{
					contentHTML += '<div class="resultNameRow"><div class="resultExperimentName">' + object['parentName']  + '</div><br>';
					contentHTML += '<div class="resultExperimentName"><small><i>Sub Project:</i> ' + resultNameHTML + '</small></div></div>';
					
				}
				else 
				{
					contentHTML += '<div class="resultNameRow"><div class="resultExperimentName">' +resultNameHTML  + '</div></div>';
				}
			
				
				
				if (object['desc'] != null)
				{
					if(object['desc'].length > 100)
					{
						object['desc'] = object['desc'].substring(0,100);
						object['desc'] += "...";
					} 

					contentHTML += '<div class="resultDetailsRow"><small><i>Description:</i> ' + object['desc'] + '</small></div>';
				}
				contentHTML += '</div>'
			
				return contentHTML
	    },
	    ajax: {
	    	url: "/arxlab/ajax_loaders/fetchProjectSearchTypeahead.asp",
	    	dataType: 'html',
	    	delay: 250,
	    	method: "POST",
	    	type: "POST",
	    	contentType: "application/x-www-form-urlencoded",
	    	data: function (params) {
	    		return {
    		        userInputValue: params
		      	};
	    	},
	    	results: function (data, params) {
	    		// parse the results into the format expected by Select2
	    
				 var i = 0;
				 resultsArray = JSON.parse(data)
				 var retArr = []; 
					resultsArray.map(function(x){
						
					x['name'] = decodeDoubleByteString(x['name']);
					if(x.parentProjectId == null){
						var item = resultsArray.filter(function(y){
							return x.id == y.parentProjectId
						})	
						
						if (item.length == 0){
							x['parentName'] = "";
							retArr.push(x)
						}
					}
					else{

						var item = resultsArray.filter(function(y){
							return y.id == x.parentProjectId
						})	
						
						if (item.length > 0){
							x['parentName'] = decodeDoubleByteString(item[0]['name']);
							x['desc'] = item[0]['desc'];
							retArr.push(x)
						}

					}

				});

				 return {
						 results: retArr
				 };
	    	},
	    	cache: false
	    },
			dropdownCssClass : 'elnSearchTypeaheadDropdown experimentSearchTypeaheadDropdown',
			containerCssClass: 'fullWidth',
	    formatInputTooShort: function () {
            return "Please enter at least 3 characters";
        },
        openOnEnter: false
	}).data('select2');

	// This is a hacky way to make the links in the results of the typeahead clickable. Select2 stops the click event when you click a link in the dropdown by default...
	projSearchBox.onSelect = (function(fn) {
		return function(data, options) {
			window.linkedExperimentInfo = data;
			$(idToLookAt).select2('data', {id: data['id'], text: data['name']}).trigger('change');
	    	$(idToLookAt).select2('close');
	    }
	})(projSearchBox.onSelect);

	$(idToLookAt).siblings("option").toArray().map(function(x){
		if($(x).attr("selected"))
		{
			$(idToLookAt).select2('data', {id: x.value, text: x.text}).trigger('change');
		}
	});
	$(projSearchBox["container"][0]).attr("title", "Select Project");
	$(document).on("click", function(event) { 
		if(!$(event.target).hasClass("select2-selection__rendered") &&
			!$(event.target).hasClass("select2-results__option")) {
				$(idToLookAt).select2('close');				
		}
	});
}

// Makes a UUID, stolen from https://stackoverflow.com/a/2117523/3009411
function uuidv4() {
	var crypto = window.crypto || window.msCrypto;
	return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, function(c) {
		return (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
	});
};

/**
 * Helper function to base16 decode the given str.
 * @param {string} str The string to decode.
 */
function decodeIt(str) {
	var strArr = str.split(";");

	if (strArr.length == 1) {
		return str;
	}

	strArr.pop();
	var charArr = strArr.map(function (x) {
		return x.split("&#")[1];
	});
	var convCharArr = charArr.map(function (x) {
		return String.fromCharCode(x);
	});
	return convCharArr.join("");
}

/**
 * Helper function to base16 encode the given str.
 * @param {string} str The string to encode.
 */
function encodeIt(str) {
	var z
	if (!str) {
		return "";
	}
	var aStr = str.split(''),
		z = aStr.length,
		aRet = [];
	while (--z >= 0) {
		var iC = aStr[z].charCodeAt();
		if (iC > 255) {
			aRet.push('&#' + iC + ';');
		} else {
			aRet.push(aStr[z]);
		}
	}
	return aRet.reverse().join('');
}



