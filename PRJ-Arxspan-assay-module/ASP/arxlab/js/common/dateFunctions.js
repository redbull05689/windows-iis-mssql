/**
 * Helper function to format a datetime string.
 * @param {string} elementId - The id of the input field
 * @param {string} date - A datetime string
 * @param {boolean} displayUTC - Display UTC time if this flag set
 */
function setElementContentToDateString(elementId, date, displayUTC) {
	displayDate = "";
	try {
		if(displayUTC) {
			dateSuffix = '';
			displaySuffix = ' UTC';
		}
		else {
			dateSuffix = ' UTC';
			displaySuffix = '';
		}
		
		date = new Date(date + dateSuffix);
		displayDate = date.format('m/dd/yyyy hh:MM:ss TT') + displaySuffix;
	}
	catch(err) {
		//console.log("ERROR formatting date: ", err);
	}

	var el = document.getElementById(elementId);
	if(el) {
		el.innerHTML = displayDate;
	}
}
