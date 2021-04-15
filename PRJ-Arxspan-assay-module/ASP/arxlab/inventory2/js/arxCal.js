function ArxCal(parentDiv,data,fd){
	this.parentDiv = parentDiv;
	this.data = data;
	this.userInfo = fd.userInfo;
	if(this.userInfo["calendarRole"]=="scheduler"){
		//this.pageMode = "schedulingManagerTable"; CAL-46
		this.pageMode = "requestorInstrumentCalendar";
	}else{
		this.pageMode = "requestorInstrumentCalendar";
	}
	this.instrumentName = fd.getFieldByFormName("Instrument Name").value;
	this.canScheduleInPast = fd.getFieldByFormName("Schedule in Past").value;
	this.autoApprove = fd.getFieldByFormName("Auto Approve").value;
	this.maxDaysScheduledInAdvance = fd.getFieldByFormName("Max Advance Schedule (Days)").value;
	this.formId = fd.fid;
	this.statusesToShow = [];
}

function swalSimpleAlert(messageContent, messageTitle){
	window.latestSwalMessageContent = messageContent;
	window.latestSwalMessageTitle = messageTitle;
	if(typeof messageTitle == "undefined"){
		messageTitle = "";
	}
	swal({
		title: messageTitle,
		text: messageContent,
		type: "error",
		confirmButtonText: "Ok",
		showCancelButton: false,
		html: true,
		allowOutsideClick: true,
		customClass: "arxCalSWAL"
	});
}

function generateReservationDuration(reservationMomentDuration){
	var self = this;
	var reservedForString = "";
	if(reservationMomentDuration.days() > 0){
		reservedForString += reservationMomentDuration.days() + "d";
		if(reservationMomentDuration.days() > 1){
		//	reservedForString += "s";
		}
	}
	if(reservationMomentDuration.days() > 0 && (reservationMomentDuration.hours() > 0 || reservationMomentDuration.minutes() > 0)) {
		reservedForString += ", ";
	}
	if(reservationMomentDuration.hours() > 0){
		reservedForString += reservationMomentDuration.hours() + "h";
		if(reservationMomentDuration.hours() > 1){
		//	reservedForString += "s";
		}
	}
	if(reservationMomentDuration.hours() > 0 && reservationMomentDuration.minutes() > 0){
		reservedForString += ", ";
	}
	if(reservationMomentDuration.minutes() > 0){
		reservedForString += reservationMomentDuration.minutes() + "m";
	}
	return reservedForString;
};

function generateReservationDuration_short(reservationMomentDuration){
	var reservedForString = "";
	if(reservationMomentDuration.hours() > 0){
		reservedForString += reservationMomentDuration.hours();
	}
	if(reservationMomentDuration.minutes() == 30){
		reservedForString += ".5";
	}
	reservedForString += "h"
	return reservedForString;
};


ArxCal.prototype.checkPageMode = function(){
	var self = this;
	$('#'+self.parentDiv+" .arxCalInnerContainer").attr('class','arxCalInnerContainer')
	self.fetchSchedulability();
	self.fetchSchedulabilityRegular();
	if(self.pageMode == "schedulingManager"){
		$('#'+self.parentDiv+" .arxCalInnerContainer").addClass("schedulingManagerPage")
		self.contentPage = "schedulingManagerPageContent";
		self.loadPage_calendar();
		self.isCalendar = true;
		self.isTable = false;
	}
	else if(self.pageMode == "schedulingManagerTable"){
		$('#'+self.parentDiv+" .arxCalInnerContainer").addClass("schedulingManagerTablePage")
		self.loadPage_schedulingManagerTable();
		self.isCalendar = false;
		self.isTable = true;
	}
	else if(self.pageMode == "requestorInstrumentCalendar"){
		$('#'+self.parentDiv+" .arxCalInnerContainer").addClass("requestorInstrumentCalendarPage")
		self.contentPage = "requestorInstrumentCalendarPageContent";
		self.loadPage_calendar();
		self.isCalendar = true;
		self.isTable = false;
	}
};

ArxCal.prototype.denySchedulingRequest_confirmed = function(messageText){
	var self = this;

	pl = {"function":"denyRunRequestById","eventId":self.currentEventId,"formId":self.formId,"messageText":messageText}
	restCallA("/userFunctions/","POST",pl, function (response) {
		swal.close();
		self.updateSubtleNotificationOptions("You have DECLINED the request and the requestor has been notified.");
		self.subtleNotification.show();
		if(self.isCalendar){
			self.lastCalEvent["status"] = "declined";
			self.lastCalEvent["className"] = "calendarEvent_declined";
			$('#'+self.parentDiv+' .fullCalendar').fullCalendar('rerenderEvents');
		}
		if(self.isTable){
			self.runRequestsTable.api().ajax.reload(null,false);
		}
	});		
};

ArxCal.prototype.acceptSchedulingRequest_confirmed = function(){
	var self = this;

	pl = {"function":"approveRunRequestById","eventId":self.currentEventId,"formId":self.formId}
	restCallA("/userFunctions/","POST",pl,function (response) {
		if(response['failureCount'] > 0){
			// Alert the user to the fact there was a conflict - should be a sweet alert(!)
			alert("One or more instruments in this event have already been scheduled for use in the requested time period.");
		}
		else{
			swal.close();
			self.updateSubtleNotificationOptions("You have APPROVED the request and the requestor has been notified.");
			self.subtleNotification.show();
			if(self.isCalendar){
				self.lastCalEvent["status"] = "approved";
				self.lastCalEvent["className"] = "calendarEvent_approved";
				$('#'+self.parentDiv+' .fullCalendar').fullCalendar('rerenderEvents');
			}
			if(self.isTable){
				if(self.pageMode == 'schedulingManagerTable'){
					self.runRequestsTable.api().ajax.reload(null,false);
				}
			}
		}

	});
}

ArxCal.prototype.checkIfRequestIsForThePast = function(startJSdate_unix){
	var self = this;
	var currentTimeEpoch = moment().valueOf();

	if(currentTimeEpoch > startJSdate_unix){
		// Is user allowed to schedule anything anytime?
		if(self.userInfo["calendarRole"] == "scheduler"){
			// User is allowed to schedule anyting anytime
			return false;
		}
		else{
			if(self.canScheduleInPast == true){
				return false;
			}
			else{
				alert("Sorry, but you have chosen a start date & time in the past. You may only schedule the given instrument(s) in the future.");
				return true;
			}
		}
	}
};

ArxCal.prototype.submitRequest = function(){
	var self = this;
	if($('.runRequestDropdown_instrumentCalendarPage option:first-of-type').prop('selected')){
		alert('Please choose a Run Type first.');
		return false;
	}

	var runRequestDropdownValue = $('.runRequestDropdown_instrumentCalendarPage option:selected').text();
	
	var startDateTime = self.latestSelectedCalDay.format('MM/D/YYYY') + " " + $('.startEndInputSection_requestor_instrumentCalendarPage .start.time').val();
	var startJSdate = new Date(startDateTime.replace(/([ap]m)$/, " $1"));
	var startJSdate_unix = startJSdate.getTime();
	
	var endDateTime = self.latestSelectedCalDay.format('MM/D/YYYY') + " " + $('.startEndInputSection_requestor_instrumentCalendarPage .end.time').val();
	var endJSdate = new Date(endDateTime.replace(/([ap]m)$/, " $1"));
	var endJSdate_unix = endJSdate.getTime();
	
	var userId = "";
	if(self.pageMode == "schedulingManager"){
		userId = $('.requestorNameDropdown option:selected').attr('userId');
	}

	var requestIsForThePast = self.checkIfRequestIsForThePast(startJSdate_unix);
	if(requestIsForThePast == true){
		return false;
	}

	var schedulingManagerId = "";
	if(self.pageMode == 'schedulingManager'){
		schedulingManagerId = $('#'+self.parentDiv+' .activeUserSelect option:selected').attr('userid');
	}

	miscAttributesObject= {};
	$('.requestorForm .miscAttributes > .miscAttr').each(function(){
		var miscAttrName = $(this).attr('miscattrname');
		
		// This finds any attribute values selected in a dropdown - add more to support textareas, input[type="text"], checkboxes, etc. - just add the value in the same fashion
		if($(this).find('select.miscAttrValue').length){
			miscAttributesObject[miscAttrName] = $(this).find('select.miscAttrValue option:selected').attr('value');
		}
	});

	var pl = {
		"function":"submitSchedulingRequest",
		"formId":self.formId,
		runType: runRequestDropdownValue,
		startDateTime: startJSdate,
		endDateTime: endJSdate,
		requestorId: userId,
		timezone: moment.tz.guess(),
		miscAttributes: miscAttributesObject
	} 
	restCallA("/userFunctions/","POST",pl,function (response) {
		if(typeof response['timeParadox'] !== "undefined"){
			swalSimpleAlert("Sorry, but you have chosen a start date & time in the past. You may only schedule the given instrument(s) in the future. If you think this is an error, please contact Arxspan Support.");
			return false;
		}
		if(typeof response['exceededMaxDuration'] !== "undefined"){
			//swal({ title: '<div style="font-size:28px;">Error</div>', text: '<div style="padding: 10px 8px 20px;">The duration of your request exceeds the maximum request duration for this instrument.</div>', html: true,  type: 'error', allowOutsideClick: true });
			alert("The duration of your request exceeds the maximum request duration for this instrument.");
			return false;
		}
		if(typeof response['consecutiveRequests'] !== "undefined"){
			//swal({ title: '<div style="font-size:28px;">Error</div>', text: '<div style="padding: 10px 8px 20px;">You\'ve already reached the maximum number of consecutive (back-to-back) requests. Please pick another date/time.</div>', html: true,  type: 'error', allowOutsideClick: true });
			alert("You've already reached the maximum number of consecutive (back-to-back) requests. Please pick another date/time.");
			return false;
		}
		if(typeof response['schedulability'] !== "undefined"){
			//swal({ title: '<div style="font-size:28px;">Error</div>', text: '<div style="padding: 10px 8px 20px;">You\'ve already reached the maximum number of consecutive (back-to-back) requests. Please pick another date/time.</div>', html: true,  type: 'error', allowOutsideClick: true });
			alert("This instrument is unavailable for scheduling during the time you requested. Please pick another date/time.");
			return false;
		}
		$('.schedulingConflictsList_instrumentCalendarPage').empty();
		if(response.length > 0){
			$.each(response, function(index, conflict){
				if(conflict['className'] == "calendarEvent_approved_unavailable"){
					$('.schedulingConflictsList_instrumentCalendarPage').append("<li>- " + self.instrumentName + ' is unavailable from <span class="keepOnOneLine">' + moment(conflict.start).format('h:mma') + '</span> to <span class="keepOnOneLine">' + moment(conflict.end).format('h:mma') + ' on this day.</span></li>')
				}
				else{
					$('.schedulingConflictsList_instrumentCalendarPage').append("<li>- " + self.instrumentName + ' is already scheduled from <span class="keepOnOneLine">' + moment(conflict.start).format('h:mma') + '</span> to <span class="keepOnOneLine">' + moment(conflict.end).format('h:mma') + '</span></li>')
				}
			});
		}
		else{
			swal.close();
			if(self.autoApprove == true){
				self.updateSubtleNotificationOptions("Your scheduling request for " + self.instrumentName + " has been automatically approved.");
			}
			else{
				self.updateSubtleNotificationOptions("Your scheduling request for " + self.instrumentName + " has been submitted and will be reviewed soon.");
			}
			self.subtleNotification.show();
		}
		$('#'+self.parentDiv+' .fullCalendar').fullCalendar('refetchEvents')
	});
};

ArxCal.prototype.updateSubtleNotificationOptions = function(content){
	var self = this;
	self.subtleNotification = new NotificationFx({
		wrapper : document.body,
		message : content,
		layout : 'attached',
		effect : 'bouncyflip',
		type : 'error',
		ttl : 6000,
		onClose : function() { return false; },
		onOpen : function() { return false; }
	});
};

ArxCal.prototype.denySchedulingRequest = function(requestEventPopupEventId){
	var self = this;
	var popupHTML = '<h2 class="noMarginBottom">Are you sure you want to decline this request?</h2><label class="declineExplanationLabel">Explain why you\'re declining (optional):</label><div class="declineExplanation"><textarea class="declineExplanationTextarea"></textarea></div><div class="denyRequest_cancel" parentDiv="' + self.parentDiv + '" data-eventId="' + requestEventPopupEventId + '">Cancel</div><div class="denyRequest_confirm" parentDiv="' + self.parentDiv + '">OK</div>';

	swal({    
		title: "",
		text: popupHTML,
		type: "info",
		html: true,
		allowOutsideClick: true,
		className: "self.formId",
		customClass: "arxCalSWAL"
	});
};

ArxCal.prototype.fetchRunTypes_instrumentCalendarPage = function(){
	var self = this;
	var inputData = {}
	pl = {
		"function":"fetchRunTypes",
		"formId":self.formId
	}
	response = restCallA("/userFunctions/","POST",pl,function(response){
		$('.runRequestDropdown_instrumentCalendarPage').empty();
		$('.runRequestDropdown_instrumentCalendarPage').append('<option disabled="disabled">-- Choose a Run Type --</option>');
		$.each(response,function(runRequestIndex,runRequestValue){
			var optionHTML = '<option index="' + runRequestValue['name'] + '">' + runRequestValue['name'] + '</option>';
			$('.runRequestDropdown_instrumentCalendarPage').append(optionHTML);
		});
		$('.runRequestDropdown_instrumentCalendarPage')[0].selectedIndex = 0;
	});
};

ArxCal.prototype.fetchSchedulabilityRegular = function(){
	var self = this;
	var inputData = {}
	pl = {
		"function":"fetchSchedulabilityRegular",
		"formId":self.formId
	}
	response = restCallA("/userFunctions/","POST",pl,function(response){
		self.schedulabilityRegular = response;
	});
}

ArxCal.prototype.handleDayClick = function(calDay, jsEvent, view){
	var self = this;
	self.latestSelectedCalDay = calDay;

	var popupHTML = '<form class="requestorForm '+self.pageMode+'" id="'+self.parentDiv+'_popupForm">';
	if(self.pageMode == "requestorInstrumentCalendar"){
		popupHTML += '<div class="pageTitle">Schedule Request for ' + self.instrumentName + '</div>';
	}
	else{
		popupHTML += '<div class="pageTitle pageTitleCentered">Make a Scheduling Request</div>';
	}

	popupHTML += '<label for="runRequestDropdown_instrumentCalendarPage">Run Type</label><div class="select-style select-style-medium"><select name="runRequestDropdown_instrumentCalendarPage" class="runRequestDropdown_instrumentCalendarPage"></select></div><label for="requestInstrumentsDropdown_instrumentCalendarPage">Instruments</label><div class="requestInstrumentsDropdownContainer"><select multiple="multiple" name="requestInstrumentsDropdown_instrumentCalendarPage" class="typeAheadMultiSelect requestInstrumentsDropdown_instrumentCalendarPage" style="width: 420px;"></select></div><label for="requestorNameDropdown">Requestor Name</label><div class="requestorNameDropdownContainer"><div class="select-style select-style-medium"><select name="requestorNameDropdown" class="requestorNameDropdown"></select></div></div><div class="startEndInputSection startEndInputSection_requestor_instrumentCalendarPage">	  Needed from <input type="text" class="start date" />    <input type="text" class="start time" /> to    <input type="text" class="end time" /> on ' + self.latestSelectedCalDay.format('MM/D/YYYY') + '</div><div class="reservedFor_requestor_container">	<div class="reservedFor_requestor_label">Duration: </div>	<select class="reservedFor_requestor_durationDropdown_instrumentCalendarPage"></select><div class="reservedFor_requestor_value_instrumentCalendarPage"></div></div><div class="miscAttributes"><div class="miscAttr" miscAttrName="Chip Size"><label class="miscAttrLabel">Chip Size</label><select class="miscAttrValue"><option value="70 micron">70 micron</option><option value="100 micron">100 micron</option><option value="130 micron">130 micron</option></select></div></div><div class="submitRequest" type="button">Submit Request</div>          <div class="schedulingConflicts"><ul class="schedulingConflictsList_instrumentCalendarPage"></ul></div></form>';

	swal({   
		title: "",
		text: popupHTML,
		type: "info",
		confirmButtonText: "",
		showCancelButton: true,
		cancelButtonText: "",
		html: true,
		allowOutsideClick: true,
		customClass: "arxCalSWAL"
	});

	// Fill the user list
	var userDropdownOptions = "";
	//later this should come from the platform
	$.each(self.allUsers, function(key, val){
		selected = "";
		if(val['id']==self.userInfo['id']){
			selected = "SELECTED"
		}
		userDropdownOptions += '<option userId="' + val['id'] + '"'+selected+'>' + val['name'] + '</option>'
	});

	$('.requestorNameDropdown').html(userDropdownOptions);

	// initialize input widgets first
	$('.startEndInputSection_requestor_instrumentCalendarPage .time.start').timepicker({
		'showDuration': true,
		'timeFormat': 'g:ia',
		'scrollDefault': '09:00',
		'maxTime': '11:30pm'
	});

	// initialize input widgets first
	$('.startEndInputSection_requestor_instrumentCalendarPage .time.end').timepicker({
		'showDuration': true,
		'timeFormat': 'g:ia',
		'scrollDefault': '12:00',
		'maxTime': '11:30pm'
	});

	$('.startEndInputSection_requestor_instrumentCalendarPage .date').datepicker({
		'format': 'm/d/yyyy',
		'autoclose': true
	});

	// initialize datepair
	var basicExampleEl = $('.startEndInputSection_requestor_instrumentCalendarPage')[0];
	var datepair = new Datepair(basicExampleEl);

	// Update the calculation of duration of scheduling request
	$('.startEndInputSection_requestor_instrumentCalendarPage').on('rangeSelected', function(){
		var reservedForInMS = datepair.getTimeDiff();
		var reservationMomentDuration = moment.duration(reservedForInMS);
		var reservedForString = generateReservationDuration(reservationMomentDuration);

		
		// Get the start time - example output: 1448634600000 (or something)
		var startDateTime = self.latestSelectedCalDay.format('MM/D/YYYY') + " " + $('.startEndInputSection_requestor_instrumentCalendarPage .start.time').val();
		var startJSdate = new Date(startDateTime.replace(/([ap]m)$/, " $1"));
		var startJSdate_unix = startJSdate.getTime();

		// Take 24 hours and subtract the start time
		var fullDayLength = self.latestSelectedCalDay.format('MM/D/YYYY');
		var fullDayJSdate = new Date(fullDayLength.replace(/([ap]m)$/, " $1"));
		var fullDayJSdate_unix = fullDayJSdate.getTime();
		fullDayJSdate_unix = fullDayJSdate_unix + (60 * 60 * 24 * 1000);
		var fullDayMinusStartTime = (fullDayJSdate_unix - startJSdate_unix) / 1000;

		// Loop through each of the remaining hours and for every .5 hour, wipe out the existing generated dropdown, and add an <option></option> to the dropdown for the half hour
		var numberOfHours = 0;
		var durationDropdownHTML = "";
		$('.reservedFor_requestor_durationDropdown_instrumentCalendarPage').html('');
		for(var i = 1800; i < fullDayMinusStartTime; i += (60 * 30)) {
				numberOfHours += .5;
				
				durationDropdownHTML += '<option value="' + parseFloat(i) + '" numberOfHours="' + numberOfHours + '">';
				if(parseFloat(numberOfHours) == 1){
					durationDropdownHTML += parseFloat(numberOfHours) + ' Hour';
				}
				else{
					durationDropdownHTML += parseFloat(numberOfHours) + ' Hours';
				}
				durationDropdownHTML += '</option>';
		}
		$('.reservedFor_requestor_durationDropdown_instrumentCalendarPage').html(durationDropdownHTML);

		// Set the duration dropdown's selected option
		var endDateTime = self.latestSelectedCalDay.format('MM/D/YYYY') + " " + $('.startEndInputSection_requestor_instrumentCalendarPage .end.time').val();
		var endJSdate = new Date(endDateTime.replace(/([ap]m)$/, " $1"));
		var endJSdate_unix = endJSdate.getTime();
		var startEndDifference_unix = endJSdate_unix - startJSdate_unix;

		$('.reservedFor_requestor_durationDropdown_instrumentCalendarPage option').each(function(){
			if((parseFloat($(this).attr('value')) * 1000) == startEndDifference_unix){
				$(this).prop('selected',true);
			}
		});
	});

	self.fetchRunTypes_instrumentCalendarPage();
	$('#'+self.parentDiv+" div.arxCalInnerContainer").addClass('pageIsLoaded');

	$('body').off('click','form.requestorForm .submitRequest');
	$('body').on('click','form.requestorForm .submitRequest', function(event){
		self.submitRequest();
	});
};

ArxCal.prototype.managerCalendarDayClick = function(calEvent, jsEvent, view) {
	self = this;
	self.lastCalEvent = calEvent;
	if (self.userInfo["calendarRole"]!="scheduler"){
		return false;
	}

	pl = {"function":"fetchRunRequestById","formId":self.formId,"eventId":calEvent['id']}
	restCallA("/userFunctions/","POST",pl,(function(calEvent){
		return function (response) {
			conflicts = response['conflicts'];
			var requestorName = response.requestor.name;
			self.currentEventId = response.id;

			var requestTimes = moment(calEvent['start']['_i']).format('h:mma') + ' to ' + moment(calEvent['end']['_i']).format("h:mma");
			var requestDuration = generateReservationDuration_short(moment.duration(moment(calEvent['end']['_i']).valueOf() - moment(calEvent['start']['_i']).valueOf()));

			var popupHTML = '<div class="requestEventPopup">'
			popupHTML += '<div class="runTypeNameTitle"><label class="runTypeNameLabel">Run Type: </label><div class="runTypeNameValue">' + calEvent['runType'] + '</div></div>';
			popupHTML += '<div class="runRequestPopupTop status_' + calEvent['status'] + '"><div class="leftSide"><div class="startEndDateTimeDurationBox"><div class="startEndDateTimeSection"><div class="startDateBoxContainer">';
			popupHTML += '<div class="startDateBox"><div class="startDateBoxInner">' + moment(calEvent['start']['_i']).format('M') + '</div></div><div class="startDateBox"><div class="startDateBoxInner">' + moment(calEvent['start']['_i']).format('D') + '</div></div><div class="startDateBox"><div class="startDateBoxInner">' + moment(calEvent['start']['_i']).format('YY') + '</div></div>';
           	popupHTML += '</div><div class="startEndTimeContainer">' + requestTimes + '</div></div><div class="durationSection">' + requestDuration + '</div></div></div><div class="rightSide"><label class="requestedByLabel">Requested by</label><div class="requestByValue">' + requestorName + '</div><label class="requestMadeLabel">Request made</label><div class="requestMadeValue"><div class="requestMadeDate">' + moment(calEvent['requestMadeDateTime']).format('M/d/YY') + '</div><div class="requestMadeTime">' + moment(calEvent['requestMadeDateTime']).format('h:mma') + '</div></div></div>'
			popupHTML += '</div>';

			popupHTML += '<div class="miscAttributes">';
           	$(response['miscAttributes']).each(function(){
 	          	popupHTML += '<div class="miscAttr"><label class="miscAttrLabel">Chip Size</label><div class="miscAttrValue">70 microns</div></div>';
 	        });
           	popupHTML += '</div>';

			var conflictsHTMLoutput = self.conflictsHTML(conflicts);
			if(conflictsHTMLoutput == ""){
				popupHTML += '<label class="instrumentsLabel noSchedulingConflicts">No Scheduling Conflicts</label>';
			}
			else{
				popupHTML += '<label class="instrumentsLabel">Conflicting Instrument Requests</label>';
				popupHTML += '<div class="instrumentsSection"><ul class="instrumentList">';
				popupHTML += '<li class="individualInstrument">';
				popupHTML += conflictsHTMLoutput;
				popupHTML += '</li>';
				popupHTML += '</ul></div>';
			}
			popupHTML += '</div>';
			
			popupHTML += '<div class="bottomButtonHolder"><div class="bottomButtonHolderInner">';
			if(calEvent['status'] !== "declined"){
				popupHTML += '<div class="denyRequest" parentDiv="' + self.parentDiv + '">Decline</div>';
			}
			if(calEvent['status'] !== "approved"){
				popupHTML += '<div class="acceptRequest" parentDiv="' + self.parentDiv + '">Approve</div>';
			}



			popupHTML += '</div>';

			swal({   
				title: "",
				text: popupHTML,
				type: "info",
				confirmButtonText: "Approve",
				showCancelButton: true,
				cancelButtonText: "Decline",
				html: true,
				allowOutsideClick: true,
				customClass: "arxCalSWAL"
			});

			// All the vertical elements that notify you of the conflicts' "Already Approved" statuses need their width to be set to their conflict container's height
			$('#'+self.parentDiv+' .individualInstrumentConflict').each(function(){
				var conflictContainerHeight = $(this).height();
				$(this).find('.alreadyApprovedContainer').width(conflictContainerHeight + 2 + 'px');
			})
		}
	})(calEvent));
}

ArxCal.prototype.renderCalHeaderAvailability = function(){
	var self = this;
	console.log('test');
	var dayNumber = 0;
	$('#objectTemplate_' + self.formId + ' .fc-day-header').each(function(){
		if(self.schedulabilityRegular[dayNumber] !== null){
			var availabilityTimesHTML = '';
			for(var schedInvCount = 0;schedInvCount < self.schedulabilityRegular[dayNumber].length; schedInvCount++){
	    		availabilityTimesHTML += '<div class="availabilityBlock">' + moment(self.schedulabilityRegular[dayNumber][schedInvCount]['start']).format('h:mma') + '-' + moment(self.schedulabilityRegular[dayNumber][schedInvCount]['end']).format('h:mma') + '</div>';
	    	}
	    	if(availabilityTimesHTML == ''){
	    		availabilityTimesHTML = '<div class="availabilityLabel">Unavailable</div>'
	    	}
	    	var availabilityHTML = '<div class="availabilityBlocks">' + availabilityTimesHTML + "</div>";
    		$(this).prepend(availabilityHTML);
	    }
    	dayNumber++;
    });
}

ArxCal.prototype.loadPage_calendar = function(){
	var self = this;
	//console.log(self);
	//console.log(JSON.stringify(self));
	//the fullCalendar div has to be in the right content div
	$('#'+self.parentDiv+' .fullCalendar').remove();
	$('#'+self.parentDiv+' .'+self.contentPage).append("<div class='fullCalendar'></div>")

	$('#'+self.parentDiv+' .fullCalendar').fullCalendar({
		events: function(start, end, timezone, callback) {
			pl = {
				"function":"fetchRunRequests",
				"formId":self.formId,
				"statusesToShow": self.statusesToShow
			}
			callback(restCall("/userFunctions/","POST",pl))
		},
		// put your options and callbacks here
		timezone: 'local',
		displayEventEnd: true,
		fixedWeekCount: false,
		eventRender: function(calEvent, element) {
			// Add the event's Mongo ID as an attribute
			element.attr('data-eventId',calEvent['id']);
			element.attr('data-requestor',JSON.stringify(calEvent['requestor']));
		},
		eventClick: function(calDay, jsEvent, view) {
			self.managerCalendarDayClick(calDay, jsEvent, view);
		},
		dayClick: function(calDay, jsEvent, view) {
			var dateOfMaxDaysAllowedToScheduleInAdvance = new Date();
			dateOfMaxDaysAllowedToScheduleInAdvance.setDate(dateOfMaxDaysAllowedToScheduleInAdvance.getDate() + self.maxDaysScheduledInAdvance);
			if (calDay < dateOfMaxDaysAllowedToScheduleInAdvance || self.maxDaysScheduledInAdvance == ""){
				self.handleDayClick(calDay, jsEvent, view);
			}
			else{
				// Do nothing
			}
		},
		dayRender: function(date, cell){
			var dateOfMaxDaysAllowedToScheduleInAdvance = new Date();
			dateOfMaxDaysAllowedToScheduleInAdvance.setDate(dateOfMaxDaysAllowedToScheduleInAdvance.getDate() + self.maxDaysScheduledInAdvance);

			if (date >= dateOfMaxDaysAllowedToScheduleInAdvance && self.maxDaysScheduledInAdvance !== "") {
				// Clicked date larger than today + daysToadd
				$(cell).addClass('beyondMaxDaysScheduleInAdvance');
				var dataDateOfCell = $(cell).attr('data-date');
				$(cell).parent().parent().parent().parent().parent().find('.fc-day-number[data-date=' + dataDateOfCell + ']').addClass('beyondMaxDaysScheduleInAdvance');
			}

			// Greying out the days when the instruments are completely unavailable (typically weekends)
			if(typeof self.schedulability !== 'undefined' && self.schedulability.length > 0){
				if($.inArray(date.day(), self.schedulabilityDaysUnavailable) !== -1) {
					$(cell).addClass('unavailableForSchedulingAllDay')				
		    	}
		    }
		    /*
		    if(typeof self.schedulabilityRegular !== 'undefined' && self.schedulabilityRegular.length > 0){
		    	for(var schedInvCount = 0;schedInvCount < self.schedulabilityRegular[date.day()].length; schedInvCount++){
		    		$(cell).prepend('<div>' + moment(self.schedulabilityRegular[date.day()][schedInvCount]['start']).format('h:mma') + ' - ' + moment(self.schedulabilityRegular[date.day()][schedInvCount]['end']).format('h:mma') + '</div>');
		    	}
		    }
		    */
	    },
	    viewRender: function(){
	    	clearTimeout(self.headerRenderDelay);
	    	self.headerRenderDelay = setTimeout(function(){
	    		console.log($('#objectTemplate_' + self.formId + ' .availableTimesDisplayToggleButton').attr('status'));
	    		if(typeof self.schedulabilityRegular !== 'undefined' && self.schedulabilityRegular.length > 0 && $('#objectTemplate_' + self.formId + ' .availableTimesDisplayToggleButton').attr('status') == "show"){
	    			self.renderCalHeaderAvailability();
		    	}
		    },50);
	    }
	});
	$('#'+self.parentDiv+" div.arxCalInnerContainer").addClass('pageIsLoaded');
};

ArxCal.prototype.performBulkActionOnTable = function(){
	var self = this;
	var checkedBoxes = [];
	$.each($('#'+self.parentDiv+' .DT_table tbody tr td:first-of-type div.tableBulkActionsCheckboxContainer input[type=checkbox]:checked'),function(){
		checkedBoxes.push(parseInt($(this).attr('value')));
	});

	var functionToUse = "";
	if($('#'+self.parentDiv+' .bulkActionsContainer select option:selected').text() == "Approve"){
		functionToUse = 'approveRunRequestById'; 
		self.bulkActions_action = "approve";
	}
	else{
		functionToUse = 'denyRunRequestById';
		self.bulkActions_action = "decline";
	}

	var inputData = {
		checkedBoxes: checkedBoxes
	}

	pl = {"function":functionToUse,"eventId":checkedBoxes,"formId":self.formId,"isBulk":true}
	restCallA("/userFunctions/","POST",pl,function (response) {
		var actionPastTense = "";
		$('#'+self.parentDiv+' .DT_table input[type="checkbox"]').each(function(){
			$(this).prop('checked', false);
		})
		if(self.bulkActions_action == "approve"){
			actionPastTense = "APPROVED";

			if(response['failureCount'] == 0){
				self.updateSubtleNotificationOptions("You have " + actionPastTense + " " + response['successCount'] + " requests and the requestors have been notified.");
				self.subtleNotification.show();
			}
			else{
				var messageString = "<div class=\"bulkApproveFailuresMessage_text\">You successfully " + actionPastTense + " " + response['successCount'] + " requests, but there were " + response['failureCount'] + " request(s) that couldn't be " + actionPastTense.toLowerCase() + " due to conflicting requests:</div>";
				messageString += '<table class="bulkApproveFailuresMessage_table"><thead><tr>';
				messageString += '<td>Status</td><td>Requestor</td><td>Run Type</td><td>Request Made</td><td>Date</td><td>From</td><td>To</td>';
				messageString += '</tr></thead>';
				messageString += '<tbody>';
				$.each(response['failures'], function(){
					messageString += '<tr>';
					tr = $('#'+self.parentDiv+' .DT_table input[type="checkbox"][value="' + this['id'] + '"]').closest('tr');
					tr.find('td:first').remove();
					messageString += tr.html();
					messageString += '</tr>';
				})
				messageString += '</tbody>';
				messageString += '</table>';
				messageString += '<div class="swalOkButton">Ok</div>';
				messageTitle = response['failureCount'] + " Conflicting Requests Found";

				swalSimpleAlert(messageString, messageTitle);
				
				$('div.sweet-alert').css('width','540px').css('margin-left','-270px');

				self.afterTableAjaxCallback = (function(failures){
					return function(){
						// Need to re-check the checkboxes of the requests that weren't able to be accepted
						$.each(failures, function(){
							var requestId = this['id'];
							$('#'+self.parentDiv+' .DT_table input[type="checkbox"]').each(function(){
								if($(this).attr('value') == requestId){
									$(this).prop('checked', true);
								}
							})
						});
					}
				})(response['failures'])
			}
		}
		else{
			actionPastTense = "DECLINED";
		}
		self.runRequestsTable.api().ajax.reload(null,false);
	})
};

ArxCal.prototype.setTimePeriodControl = function(){
	var self = this;

	self.allMonthWeekDayOption = $('#'+self.parentDiv+' .monthWeekDayControl div.active').text().toLowerCase();
	if (self.allMonthWeekDayOption == ""){
		self.allMonthWeekDayOption = "all"
	}
	if(self.allMonthWeekDayOption == "all"){
		self.timePeriod_start = 1000000000000;
		self.timePeriod_end = 2000000000000;
	}
	self.timePeriod_start = moment(self.timePeriod_start).startOf(self.allMonthWeekDayOption).valueOf();
	self.timePeriod_end = moment(self.timePeriod_end).endOf(self.allMonthWeekDayOption).valueOf();

	$('#'+self.parentDiv+' .timePeriodStart').text(moment(self.timePeriod_start).format('MMM Do YYYY'));
	$('#'+self.parentDiv+' .timePeriodTitleContainer .timePeriodEnd').text(moment(self.timePeriod_end).format('MMM Do YYYY'));

	if(self.allMonthWeekDayOption == "all"){
		$('#'+self.parentDiv+' .timePeriodTitleContainer div').hide();	
		$('#'+self.parentDiv+' .nextPrevTimePeriodControlContainer').css('visibility','hidden');
	}
	else{
		$('#'+self.parentDiv+' .timePeriodTitleContainer div').show();
		$('#'+self.parentDiv+' .nextPrevTimePeriodControlContainer').css('visibility','visible');
	}
	if(self.allMonthWeekDayOption == "day" || self.allMonthWeekDayOption == "all"){
		$('.timePeriodTitleContainer div.timePeriodHyphen, .timePeriodTitleContainer div.timePeriodEnd').hide();
	}
	else{
		$('.timePeriodTitleContainer div.timePeriodHyphen, .timePeriodTitleContainer div.timePeriodEnd').show();
	}
}

ArxCal.prototype.loadPage_schedulingManagerTable = function(){
	var self = this;
	var columnsForDT = [
			{ "mData": "Select", "bSortable": false },
			{ "mData": "Status" },
			{ "mData": "Requestor" },
			{ "mData": "Run Type" },
			{ "mData": "Request Made" },
			{ "mData": "Date" },
			{ "mData": "From", "bSortable": false },
			{ "mData": "To", "bSortable": false }
		];
	self.setTimePeriodControl();
	self.afterTableAjaxCallback = function(){};

	// Interrupted...
	self.runRequestsTable = $('#'+self.parentDiv+' .DT_table').dataTable({
		"bProcessing": true,
		"bServerSide": true,
		"ajax": function (data, callback, settings) {
			a = {
				"statusesToShow": self.statusesToShow,
				"timePeriod_start":self.timePeriod_start,
				"timePeriod_end":self.timePeriod_end,
				"aaSorting":settings["aaSorting"]
			}
			pl = {"function":"fetchRunRequestsForTable","formId":self.formId};
			$.extend(pl,a);
			callback(restCall("/userFunctions/","POST",pl));
			self.afterTableAjaxCallback();
			self.afterTableAjaxCallback = function(){};
		},
		"aoColumns": columnsForDT,
		"dom": "",
		"aaSorting": [[ 3, "desc" ]],
		"columnDefs": [
			{ "orderable": false, "targets": 0 }
		],
		"columns": [
			{ "data": "Select", "orderable": false },
			{ "data": "Status" },
			{ "data": "Requestor" },
			{ "data": "Run Type" },
			{ "data": "Request Made" },
			{ "data": "Date" },
			{ "data": "From", "orderable": false },
			{ "data": "To", "orderable": false }
		],
		"sServerMethod": "POST",
		"columnDefs": [{
			"targets": "_all",
			"data": null,
			"render": function ( data, type, full, meta ) {

				if(data == null){
					data = "BLANK";
				}

				if(meta['col'] == 1){
					data = '<div class="statusInCell requestStatus_' + data + '">' + data + "</div>";
				}

				if(meta['col'] == 2){
					if(data !== "REQUESTOR ID VALUE WASN'T SET"){
						data = '<div userId="' + data + '">' + data + '</div>';
					}
				}
				if(meta['col'] == 3){
					// No adjustment needed
				}
				if(meta['col'] == 4){
					data = moment(data).format('MM/DD/YY h:mma');
				}
				if(meta['col'] == 5){
					data = moment(data).format('MM/DD/YY');
				}
				if(meta['col'] == 6){
					data = '<div epoch="' + moment(data).valueOf() + '">' + moment(data).format('h:mma') + '</div>';
				}
				if(meta['col'] == 7){
					data = '<div epoch="' + moment(data).valueOf() + '">' + moment(data).format('h:mma') + '</div>';
				}

				if(meta['col'] == 0){
					data = '<div class="tableBulkActionsCheckboxContainer"><input type="checkbox" value="' + data + '" name="' + data + '" id="' + data + '" class="css-checkbox"><label class="css-label checkboxLabel" for="' + data + '"></label></div>'
				}

				return data;
			}
		}],
		"lengthMenu": [ [100, 500, 1000, -1], [100, 500, 1000, "All"] ],
		"aaSorting": [[4,'desc']]

	});
	$('#'+self.parentDiv+" div.arxCalInnerContainer").addClass('pageIsLoaded');
};

ArxCal.prototype.fetchSchedulability = function(){
	var self = this;

	// Put HTML into the DOM
	pl = {
		"function": "fetchSchedulability",
		"formId": self.formId
	}
	response = restCallA("/userFunctions/","POST",pl,function(response){
		self.schedulability = response;
		// Build list of days that are completely unavailable (in other words, days that were not selected in the schedulability settings for the instrument)
		self.schedulabilityDaysUnavailable = [0, 1, 2, 3, 4, 5, 6];
		$.each(self.schedulability, function(schedulabilitySettingKey, schedulabilitySetting){
			$.each(schedulabilitySetting['dow'], function(key, dayNumber){
				self.schedulabilityDaysUnavailable = self.schedulabilityDaysUnavailable.filter(function(elem){
				   return elem != dayNumber; 
				});	
			});
		});
	});
}

ArxCal.prototype.loadSchedulabilitySettingsMenu = function(){
	var self = this;
	self.fetchSchedulability();
	var schedulabilitySettingsMenuHTML = "";
	schedulabilitySettingsMenuHTML += '<div class="schedulabilityPopupContent"><div class="schedulabilityAddNewSettingButtonContainer"><div class="schedulabilityAddNewSettingButton" type="button">+ New</div></div><div class="schedulabilitySettingsHolder"></div><div class="saveSchedulabilityButtonContainer"><div class="saveSchedulabilityButton">Save Changes</div></div></div>';
	
	swal({   
		title: "Manage Instrument Schedulability",
		text: schedulabilitySettingsMenuHTML,
		type: "info",
		confirmButtonText: "Approve",
		showCancelButton: false,
		cancelButtonText: "Decline",
		showConfirmButton: false,
		closeOnConfirm: false,
		html: true,
		allowOutsideClick: true,
		customClass: "arxCalSWAL"
	});

	$.each(self.schedulability, function(schedulabilitySettingKey, schedulabilitySetting){
		console.log(schedulabilitySetting);
		self.addNewSchedulabilitySetting();
		el = $('.schedulabilitySettingsHolder .schedulabilitySettingContainer:last-of-type');

		// Set time inputs
		var startTime = moment(schedulabilitySetting['start']).format('h:mma');
		console.log(schedulabilitySetting['start'])
		console.log(moment(schedulabilitySetting['start']))
		console.log(startTime);
		var endTime = moment(schedulabilitySetting['end']).format('h:mma');
		el.find('.schedulabilityTimeRange.start').val(startTime);
		el.find('.schedulabilityTimeRange.end').val(endTime);

		// Set days of week
		$.each(schedulabilitySetting['dow'], function(key, val){
			el.find('.daySelectContainer .daySelectItem[value=' + val + ']').addClass('activeDay');
		});
	})
}

ArxCal.prototype.addNewSchedulabilitySetting = function(){
	var self = this;

	// Put HTML into the DOM
	var settingHTML = '<div class="schedulabilitySettingContainer"><div class="settingRemoveButton">X Remove</div><div class="schedulabilityTimeRangeContainer">From <input type="text" class="start datePickerDateHidden"><input type="text" class="schedulabilityTimeRange start" /> to <input type="text" class="schedulabilityTimeRange end" /> on these days:</div><div class="daySelectContainer"><div class="daySelectItem" value="0">Sun</div><div class="daySelectItem" value="1">Mon</div><div class="daySelectItem" value="2">Tues</div><div class="daySelectItem" value="3">Wed</div><div class="daySelectItem" value="4">Thur</div><div class="daySelectItem" value="5">Fri</div><div class="daySelectItem" value="6">Sat</div></div></div>'
	
	$('.schedulabilitySettingsHolder').append(settingHTML);

	// initialize input widgets first
	$('.schedulabilityTimeRangeContainer .schedulabilityTimeRange.start').timepicker({
		'showDuration': true,
		'timeFormat': 'g:ia',
		'scrollDefault': '09:00',
		'maxTime': '11:30pm'
	});

	// initialize input widgets first
	$('.schedulabilityTimeRangeContainer .schedulabilityTimeRange.end').timepicker({
		'showDuration': true,
		'timeFormat': 'g:ia',
		'scrollDefault': '12:00',
		'maxTime': '11:30pm'
	});

	$('.schedulabilityTimeRangeContainer .datePickerDateHidden').datepicker({
		'format': 'm/d/yyyy',
		'autoclose': true
	});

	// initialize datepair
	var basicExampleEl = $('.schedulabilityTimeRangeContainer');
	//var datepair = new Datepair(basicExampleEl);
}

ArxCal.prototype.saveSchedulability = function(){
	var self = this;

	var newSchedulabilitySettings = [];
	$('.schedulabilitySettingsHolder .schedulabilitySettingContainer').each(function(){
		var startDateTime = '01/1/1970 ' + $(this).find('.schedulabilityTimeRange.start').val();
		var startJSdate = new Date(startDateTime.replace(/([ap]m)$/, " $1"));
		var startJSdate_unix = startJSdate.getTime();

		var endDateTime = '01/1/1970 ' + $(this).find('.schedulabilityTimeRange.end').val();
		var endJSdate = new Date(endDateTime.replace(/([ap]m)$/, " $1"));
		var endJSdate_unix = endJSdate.getTime();
		
		var daysEffected = [];
		$(this).find('.daySelectContainer .daySelectItem.activeDay').each(function(){
			daysEffected.push($(this).attr('value'));
		});

		var thisSetting = {
			start: startJSdate_unix,
			end: endJSdate_unix,
			dow: daysEffected
		}
		newSchedulabilitySettings.push(thisSetting);
	});
	console.log(newSchedulabilitySettings);

	pl = {
		"function": "updateSchedulabilitySettings",
		"formId": self.formId,
		"newSchedulabilitySettings": JSON.stringify(newSchedulabilitySettings),
	}
	restCallA("/userFunctions/","POST",pl,function(r){
		self.fetchSchedulability();
	});
}

ArxCal.prototype.postDraw = function(){
	var self = this;
	// initialize input widgets first
    $('#'+self.parentDiv+' .startEndInputSection_requestor .time.start').timepicker({
        'showDuration': true,
        'timeFormat': 'g:ia',
        'scrollDefault': '09:00',
        'maxTime': '11:30pm'
    });

    // initialize input widgets first
    $('#'+self.parentDiv+' .startEndInputSection_requestor .time.end').timepicker({
        'showDuration': true,
        'timeFormat': 'g:ia',
        'scrollDefault': '12:00',
        'maxTime': '11:30pm'
    });

    $('#'+self.parentDiv+' .startEndInputSection_requestor .date').datepicker({
        'format': 'm/d/yyyy',
        'autoclose': true
    });

	pl = {
		"function":"fetchAllUsers"
	}
	restCallA("/userFunctions/","POST",pl,function(r){
		self.allUsers = r;
	});

	$('#'+self.parentDiv+' .pickDateToScheduleInstrument').text('Pick a Date to Schedule ' + this.instrumentName);
	self.checkPageMode();

	self.fetchSchedulability();
};


ArxCal.prototype.attachEventListeners = function(){
	var self = this;

	// This is for the event listeners that are global and aren't about the content of the popups
	if(typeof window.alreadyAttachedArxCalEventListeners == 'undefined'){
		$('body').on('click', '.schedulabilitySettingContainer .daySelectItem', function(event){

			if($(this).hasClass('activeDay')){
				$(this).removeClass('activeDay');
			}
			else{
				$(this).addClass('activeDay');
			}
		});

		$('body').on('click', '.schedulabilitySettingContainer .settingRemoveButton', function(event){
			$(this).parent().remove();
		});

		$('body').on('click', '.schedulabilityAddNewSettingButton', function(event){
			self.addNewSchedulabilitySetting();
			$(this).blur();
		});

		// Need to basically replicate the hover targeting behavior of the CSS in the click handler - hovering still works just fine but when you click on the li it needs to dip into the span and get its values
	}

	$('body').on('click', '.saveSchedulabilityButton', function(){
		self.saveSchedulability();
		swal.close();
	});

    $('body').on('click', '.swalOkButton', function(event){
		swal.close();
    });

    $('body').on('click', '.sweet-alert div.denyRequest[parentdiv=' + self.parentDiv + ']', function(event){
   		self.denySchedulingRequest();
    });

    $('body').on('click', '.sweet-alert div.denyRequest_cancel[parentdiv=' + self.parentDiv + ']', function(event){
		swal.close();
		if(self.isCalendar){
			$('#'+self.parentDiv+' .fullCalendar .fc-event[data-eventid="' + self.lastCalEvent.id + '"]').click();
		}
    });

    $('body').on('click', '.sweet-alert div.denyRequest_confirm[parentdiv=' + self.parentDiv + ']', function(event){
    	var messageText = $('.declineExplanationTextarea').val();
    	self.denySchedulingRequest_confirmed(messageText);
    });

	$('body').on('click', '.sweet-alert div.acceptRequest[parentdiv=' + self.parentDiv + ']', function(event){
		self.acceptSchedulingRequest_confirmed();
    });

	$(document.body).on('change','select.reservedFor_requestor_durationDropdown_instrumentCalendarPage',function(){
		var chosenOptionValue = $(this).children('option:selected').attr('value');
		var startDateTime = self.latestSelectedCalDay.format('MM/D/YYYY') + " " + $('form#' + self.parentDiv + '_popupForm .startEndInputSection_requestor_instrumentCalendarPage .start.time').val();
		var startJSdate = new Date(startDateTime.replace(/([ap]m)$/, " $1"));
		var startJSdate_unix = startJSdate.getTime();
		var endDateTime_unix = startJSdate_unix + (parseFloat(chosenOptionValue) * 1000);
		$('form#' + self.parentDiv + '_popupForm .startEndInputSection_requestor_instrumentCalendarPage .end.time').val(moment(endDateTime_unix).format('h:mma'));
	})

	$('body').on('click', '#objectTemplate_'+self.formId+' .availableTimesDisplayToggleButton', function(event){
		if($(this).attr('status') == 'show'){
			$('#objectTemplate_' + self.formId + ' .fc-day-header').each(function(){
				$(this).find('div').remove();
			});
			$(this).attr('status','hide');
			$(this).text('Show Instrument Availability');
		}
		else{
			self.renderCalHeaderAvailability();
			$(this).attr('status','show');
			$(this).text('Hide Instrument Availability');
		}
	});

    $('#'+self.parentDiv+' .calendarLegendContainerOuter').on('click','.colorBlock',function(){
    	if($(this).hasClass('checked')){
    		$(this).removeClass('checked');
    	}else{
    		$(this).addClass('checked');
    	}

		self.statusesToShow = [];
		$.each($('#'+self.parentDiv+' .calendarLegendColors div.colorBlock'), function(){
			var thisStatus = $(this).attr('status');
			if($(this).hasClass('checked')){
				self.statusesToShow.push(thisStatus);
			}
		});
		
    	if(self.isTable){
			self.runRequestsTable.api().ajax.reload(null,true);
    	}
    	if(self.isCalendar){
    		$('#'+self.parentDiv+' .fullCalendar').fullCalendar('refetchEvents');
    	}
    }); 

    $('#'+self.parentDiv+' .monthWeekDayControl div').click(function(){
    	$('#'+self.parentDiv+' .monthWeekDayControl div').removeClass('active');
    	$(this).addClass('active');
		self.timePeriod_start = moment();
		self.timePeriod_end = moment();
   		self.setTimePeriodControl();
		self.runRequestsTable.api().ajax.reload(null,false);
    });

    $('#'+self.parentDiv+' .nextPrevTimePeriodControlContainer .nextPrevTimePeriodControl div').click(function(){
    	self.allMonthWeekDayOption = $('#'+self.parentDiv+' .monthWeekDayControlContainer .monthWeekDayControl div.active').text().toLowerCase();
    	if($(this).hasClass('previous')) {
    		self.timePeriod_start = moment(self.timePeriod_start).subtract(1, self.allMonthWeekDayOption).valueOf();
    		self.timePeriod_end = moment(self.timePeriod_end).subtract(1, self.allMonthWeekDayOption).valueOf();
    	}
    	else{
    		self.timePeriod_start = moment(self.timePeriod_start).add(1, self.allMonthWeekDayOption).valueOf();
    		self.timePeriod_end = moment(self.timePeriod_end).add(1, self.allMonthWeekDayOption).valueOf();
    	}
   		self.setTimePeriodControl();

		self.runRequestsTable.api().ajax.reload(null,false);
    });

    $('#'+self.parentDiv).on('click', '.bulkActionsContainer .bulkActionsApply', function(){
    	self.performBulkActionOnTable();
    });

    $('#'+self.parentDiv).on('click', '.DT_table tbody tr td:not(:first-of-type)', function(){
    	var requestId = $(this).parent().find('td:nth-of-type(1)').find('input[type=checkbox]').attr('value');
    	var startTime = parseFloat($(this).parent().find('td:nth-of-type(7) div').attr('epoch'));
    	var endTime = parseFloat($(this).parent().find('td:nth-of-type(8) div').attr('epoch'));
    	var requestStatus = $(this).parent().find('td:nth-of-type(2) div.statusInCell').text().toLowerCase();

    	pl = {
			"function": "fetchRunRequestById",
			"formId": self.formId,
			"eventId": requestId
		}
		response = restCallA("/userFunctions/","POST",pl,function(response){
			self.clickedTableRowRequestInfo = response;
		});

    	pl = {
			"function": "fetchRunRequestById",
			"formId": self.formId,
			"eventId": requestId
		}
		response = restCallA("/userFunctions/","POST",pl,function(response){
			conflicts = response['conflicts'];
			self.currentEventId = response.id;

			var requestorName = response.requestor.name;
			
			var requestTimes = moment(response['start']).format('h:mma') + ' to ' + moment(response['end']).format("h:mma");
			var requestDuration = generateReservationDuration_short(moment.duration(moment(response['end']).valueOf() - moment(response['start']).valueOf()));

			var popupHTML = '<div class="requestEventPopup">'
			popupHTML += '<div class="runTypeNameTitle"><label class="runTypeNameLabel">Run Type: </label><div class="runTypeNameValue">' + response['runType'] + '</div></div>';
			popupHTML += '<div class="runRequestPopupTop status_' + response['status'] + '"><div class="leftSide"><div class="startEndDateTimeDurationBox"><div class="startEndDateTimeSection"><div class="startDateBoxContainer">';
			popupHTML += '<div class="startDateBox"><div class="startDateBoxInner">' + moment(response['start']).format('M') + '</div></div><div class="startDateBox"><div class="startDateBoxInner">' + moment(response['start']).format('D') + '</div></div><div class="startDateBox"><div class="startDateBoxInner">' + moment(response['start']).format('YY') + '</div></div>';
           	popupHTML += '</div><div class="startEndTimeContainer">' + requestTimes + '</div></div><div class="durationSection">' + requestDuration + '</div></div></div><div class="rightSide"><label class="requestedByLabel">Requested by</label><div class="requestByValue">' + requestorName + '</div><label class="requestMadeLabel">Request made</label><div class="requestMadeValue"><div class="requestMadeDate">' + moment(response['requestMadeDateTime']).format('M/d/YY') + '</div><div class="requestMadeTime">' + moment(response['requestMadeDateTime']).format('h:mma') + '</div></div></div></div>';

           	popupHTML += '<div class="miscAttributes">';
           	$(response['miscAttributes']).each(function(){
 	          	popupHTML += '<div class="miscAttr"><label class="miscAttrLabel">Chip Size</label><div class="miscAttrValue">70 microns</div></div>';
 	        });
           	popupHTML += '</div>';

        	var conflictsHTMLoutput = self.conflictsHTML(conflicts);
			if(conflictsHTMLoutput == ""){
				popupHTML += '<label class="instrumentsLabel noSchedulingConflicts">No Scheduling Conflicts</label>';
			}
			else{
				popupHTML += '<label class="instrumentsLabel">Conflicting Instrument Requests</label>';
			
				popupHTML += '<div class="instrumentsSection"><ul class="instrumentList">';
				// Now generate the HTML for this instrument
				popupHTML += '<li class="individualInstrument">';
				popupHTML += conflictsHTMLoutput;
				popupHTML += '</li>';
				popupHTML += '</ul></div>';
			}

			popupHTML += '</div>';

			popupHTML += '<div class="bottomButtonHolder"><div class="bottomButtonHolderInner">';
			if(requestStatus !== "declined"){
    			popupHTML += '<div class="denyRequest" parentDiv="' + self.parentDiv + '">Decline</div>';    				
			}
			if(requestStatus !== "approved"){
				popupHTML += '<div class="acceptRequest" parentDiv="' + self.parentDiv + '">Approve</div>';
			}
			popupHTML += '</div></div>';

        	swal({   
        		title: "",
        		text: popupHTML,
        		type: "info",
        		confirmButtonText: "Approve",
        		showCancelButton: true,
        		cancelButtonText: "Decline",
        		html: true,
        		allowOutsideClick: true,
        		customClass: "arxCalSWAL"
        	});

        	// All the vertical elements that notify you of the conflicts' "Already Approved" statuses need their width to be set to their conflict container's height
        	$('.individualInstrumentConflict').each(function(){
        		var conflictContainerHeight = $(this).height();
        		$(this).find('.alreadyApprovedContainer').width(conflictContainerHeight + 2 + 'px');
        	})

		});

    });

	$('#'+self.parentDiv).on('click','.selectDeselectAll :checked',function(){
		$('#'+self.parentDiv+" div.tableBulkActionsCheckboxContainer input[type=checkbox]").prop('checked', true);
	});
	$('#'+self.parentDiv).on('click','.selectDeselectAll',function(){
		if($(this).prop('checked')){
			$('#'+self.parentDiv+" div.tableBulkActionsCheckboxContainer input[type=checkbox]").prop('checked', true);
		}
		else{
			$('#'+self.parentDiv+" div.tableBulkActionsCheckboxContainer input[type=checkbox]").prop('checked', false);
		}
		
	});

	$('#'+self.parentDiv).on('mouseenter','.fc-day-grid-event',function(){
		var requestor = JSON.parse($(this).attr('data-requestor'));
		var requestorName = requestor["name"];
		var requestorEmail = requestor["email"];

		var tableEventHoverPopupHTML = '<div class="requestorNameEmailContainer"><div class="requestorTitle">Requestor:</div>';
		tableEventHoverPopupHTML += '<div class="requestorName">' + requestorName + '</div>';
		tableEventHoverPopupHTML += '<div class="requestorEmail">' + requestorEmail + '</div></div>';
		$(this).find('.fc-content').append(tableEventHoverPopupHTML);
		self.delayOfRequestorNameEmailContainer = setTimeout(function(){
			$('#'+self.parentDiv+' .requestorNameEmailContainer').addClass('makeVisible');
		},100);
	});

	$('#'+self.parentDiv).on('mouseleave','.fc-day-grid-event',function(){
		$(this).find('.requestorNameEmailContainer').remove();
	});

	$('#'+self.parentDiv).on('change','.pageModeSelectContainer',function(){
		var newPageMode = $(this).find('option:selected').val();
		self.pageMode = newPageMode;
		self.checkPageMode();
	});

	$('#'+self.parentDiv).on('click','button.schedulability_settingsButton',function(){
		self.loadSchedulabilitySettingsMenu();
		$(this).blur();
	});

	window.alreadyAttachedArxCalEventListeners = true;
};

ArxCal.prototype.conflictsHTML = function(){
	var conflictsHTML = "";
	$.each(conflicts, function(index, conflict){
		var date = new Date(conflict['start']);
		conflict['startEpoch'] = date.getTime(); 
		var date = new Date(conflict['end']);
		conflict['endEpoch'] = date.getTime();
		var date = new Date(conflict['requestMadeDateTime']);
		conflict['requestMadeDateTimeEpoch'] = date.getTime();
		var conflictTitle = 'Conflicting Request #' + (index + 1);
		var conflictDuration = generateReservationDuration_short(moment.duration(moment(conflict['endEpoch']).valueOf() - moment(conflict['startEpoch']).valueOf()));

		conflictsHTML += '<div class="individualInstrumentConflict">';

		conflictsHTML += '<div class="conflictLeftSide">';
		conflictsHTML += '<div class="conflictTitle">' + conflictTitle + '</div>';
		conflictsHTML += '<div class="conflictDateAndTimeContainer status_' + conflict['status'] + '">';
			conflictsHTML += '<div class="conflictDateTime"><div class="conflictTime conflictTimeStart">' + moment(conflict['start']).format('hh:mma') + '</div><div class="conflictTimeTo">to</div><div class="conflictTime conflictTimeEnd">' + moment(conflict['end']).format('hh:mma') + '</div></div>';
			conflictsHTML += '<div class="conflictDuration">' + conflictDuration + '</div>';
		conflictsHTML += '</div></div>'

		conflictsHTML += '<div class="conflictRightSide">';
		conflictsHTML += '<div class="conflictRunTypeLine">' + conflict['runType'] + '</div>'
		conflictsHTML += '<label class="conflictRequestedByLabel">Requested by</label>';
		conflictsHTML += '<div class="conflictRequestedByValue">'+conflict.requestor.name+'</div>';
		conflictsHTML += '<label class="conflictRequestMadeLabel">Request made</label>';
		conflictsHTML += '<div class="conflictRequestMade">' + moment(conflict['requestMadeDateTime']).format('MM/DD/YY h:mma') + '</div>';
		conflictsHTML += '</div>';


		conflictsHTML += '</div>'
	});
	return conflictsHTML;
}

// Grabs the beginning HTML, creates a DOM nodes based on the HTML string, and returns the node
ArxCal.prototype.makeHTML = function(){
	var self = this;
	if(self.userInfo["calendarRole"]=="scheduler"){
		modeSelectHTML = '<select><option value="schedulingManager">Calendar</option><option value="schedulingManagerTable">Table</option></select>';
		schedulabilityButtonHTML = '<div class="schedulability_settingsButtonContainer"><button class="schedulability_settingsButton">Change Instrument Schedulability</button></div>';
		calendarRoleAttr = "calendarRole_scheduler";
	}else{
		modeSelectHTML = '<select><option value="requestorInstrumentCalendar">Calendar</option></select>';
		schedulabilityButtonHTML = '';
		calendarRoleAttr = "calendarRole_regular";
	}
	return $('<div class="arxCalInnerContainer" calendar_role="' + calendarRoleAttr + '">' + schedulabilityButtonHTML + '<div class="arxCalMode">        <div class="calendarLegendContainerOuter"><div class="select-style select-style-medium-short pageModeSelectContainer">'+modeSelectHTML+'</div><div class="availableTimesDisplayToggleButtonContainer"><div class="availableTimesDisplayToggleButton" status="hide">Show Instrument Availability</div></div><div class="refreshCalendarButtonContainer"><button class="refreshCalendarButton">Refresh Calendar</button></div><div class="calendarLegendContainer"><label class="legendLabelText_show">Show: </label><div class="calendarLegendColors"><div class="colorBlock colorBlockUnavailable" status="unavailable"><div class="legendTooltip">Instrument Unavailable</div></div><div class="colorBlock colorBlockPending" status="pending"><div class="legendTooltip">Pending Request</div></div><div class="colorBlock colorBlockApproved" status="approved"><div class="legendTooltip">Approved Request</div></div><div class="colorBlock colorBlockDeclined" status="declined"><div class="legendTooltip">Declined Request</div></div></div></div></div>      </div>      <div class="managerPageContent"></div>      <div class="schedulingManagerPageContent">        <div class="pageTypeTitle">Approve &amp; Decline - All Instrument Requests</div>        <div class="fullCalendar"></div>             </div>      <div class="schedulingManagerTablePageContent">        <!--<div class="instrumentsSelect2Container"><label class="instrumentsSelect2Label">Instruments:</label><select class="instrumentsSelect2" id="instrumentsSelect2_' + self.parentDiv + '" multiple="multiple"></select></div>-->        <div class="bulkActionsContainer"><label>Bulk Actions:</label><div class="select-style select-style-short"><select><option>Approve</option><option>Quick Decline</option></select></div><div class="bulkActionsApply">Apply</div></div><div class="nextPrevTimePeriodControlContainerOuter"><div class="nextPrevTimePeriodControlContainer prevControlContainer"><div class="nextPrevTimePeriodControl"><div class="previous">&lt;</div></div></div><div class="timePeriodTitleContainer"><div class="timePeriodStart"></div><div class="timePeriodHyphen"> - </div><div class="timePeriodEnd"></div></div><div class="nextPrevTimePeriodControlContainer nextControlContainer"><div class="nextPrevTimePeriodControl"><div class="next">&gt;</div></div></div></div><div class="monthWeekDayControlContainer"><div class="monthWeekDayControl"><div class="active">All</div><div>Month</div><div>Week</div><div>Day</div></div></div>                <table class="DT_table">          <thead>            <tr>              <td><div class="tableBulkActionsCheckboxContainer_checkAll"><input type="checkbox" value="selectDeselectAll" name="selectDeselectAll" id="selectDeselectAll' + self.parentDiv + '" class="selectDeselectAll css-checkbox"><label class="css-label checkboxLabel" for="selectDeselectAll' + self.parentDiv + '"></label></div></td>              <td>Status</td>                           <td>Requestor</td>       <td>Run Type</td>    <td>Request Made</td>   <td>Date</td>              <td>From</td>              <td>To</td>            </tr>          </thead>        </table>      </div>      <div class="requestorInstrumentCalendarPageContent">        <div class="instrumentName" class="pickDateToScheduleInstrument">Pick a Date to Schedule</div>        <div class="fullCalendar"></div>      </div>   </div>')[0];
};

ArxCal.prototype.drawHTML = function(){
	var self = this;
	$('#' + self.parentDiv).append(self.makeHTML());
	self.postDraw();
	self.attachEventListeners();
};