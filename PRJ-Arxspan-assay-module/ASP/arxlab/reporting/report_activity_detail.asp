<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
sectionId = "god2"
subSectionID = "reportDetail"
header = "Detailed Operational Report"
pageTitle = header
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<!-- #include file="../_inclds/common/js/popupDivsJS.asp"-->
<script src="../js/jquery.dataTables.1.10.15.min.js"></script>
<script src="../js/buttons.html5.min.js"></script>
<script src="../js/dataTables.buttons.min.js"></script>
<script src="../js/moment.min.js"></script>
<script src="../js/datetime-moment.js"></script>
<script src="../js/pikaday.1.6.1.jquery.js"></script>
<script src="../js/pikaday.1.6.1.js"></script>
<script src="../js/jquery.clearsearch.js"></script>
<script src="../js/jszip.min.js" type="text/javascript"></script>
<link href="../css/jquery.dataTables.1.10.15.css" rel="stylesheet" type="text/css">
<link href="../css/buttons.dataTables.min.css" rel="stylesheet" type="text/css">
<link href="../css/pikaday.1.6.1.css" rel="stylesheet" type="text/css">
<link href="<%=mainAppPath%>/search/elasticSearch/nobootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=mainAppPath%>/search/elasticSearch/jQuery-QueryBuilder-2.4.3/css/query-builder.dark.min.css" rel="stylesheet" type="text/css">

<script>
// Setting this up here so it's easier to find and change later.
var tooManyRows = 1000;
</script>

<%
If Not session("userHasOperationalReport") Then
	response.redirect(mainAppPath & "/dashboard.asp")
End if
%>

<%
sectionId = "tool"
urlId = request.querystring("id")
userIds = Split(urlId, "-")
noIds = urlId = ""

If UBound(userIds) >= 1 Or noIds Then
	currUserId = ""
Else
	currUserId = userIds(0)
End If
%>

<h1 id="DetailTitle"><%=header%></h1>

<div id="builder" class="query-builder form-inline">
	<dl id="builder_group_0" class="rules-group-container">
		<table id="filterTable" class="rule-container" width=100%>
			<thead>
				<th align="left">
					Experiment Type<br>
					Ctrl+Click to select/unselect multiple experiment types
				</th>
				<th align="left">Status</th>
				<th align="left">Date (optional)</th>
				<%IF noIds THEN%>
					<th align="left">
						Users (optional)<br>
						Ctrl+Click to select/unselect multiple users
					</th>
					<th align="left">
						Groups (optional)<br>
						Ctrl+Click to select/unselect multiple groups
					</th>
				<%END IF%>
			</thead>
			<tr>
				<td>
					<div id="exp_boxes">
						<select multiple class="reportSelect" id="expSelect">
						</select>
					</div>
				</td>
				<td>
					<div id="status_boxes">
						<input id="createBox" name="statusBox" type="checkbox" value="1" style="display: inline-block;" checked />
						<label class="checkbox" for="createBox">Created</label>
						<br>
						<input id="saveBox" name="statusBox" type="checkbox" value="2" style="display: inline-block;" checked />
						<label class="checkbox" for="saveBox">Saved</label>
						<br>
						<input id="openBox" name="statusBox" type="checkbox" value="3" style="display: inline-block;" checked />
						<label class="checkbox" for="openBox">Signed - Open</label>
						<br>
						<input id="closeBox" name="statusBox" type="checkbox" value="4" style="display: inline-block;" checked />
						<label class="checkbox" for="closeBox">Signed - Closed</label>
						<br>
						<input id="witnessBox" name="statusBox" type="checkbox" value="5" style="display: inline-block;" checked />
						<label class="checkbox" for="witnessBox">Witnessed</label>
						<br>
						<input id="rejectBox" name="statusBox" type="checkbox" value="6" style="display: inline-block;" checked />
						<label class="checkbox" for="rejectBox">Rejected</label>
						<br>
						<input id="regulatoryBox" name="statusBox" type="checkbox" value="7" style="display: inline-block;" checked />
						<label class="checkbox" for="regulatoryBox">Regulatory Check</label>
					</div>
				</td>
				<td>
					<div>
						<b>Date Field:</b>
						<select id="dateField">
							<option value="1">Date Created</option>
							<option value="2">Date Last Modified</option>
							<option value="3">Sign Close Date</option>
							<option value="4">Witnessed Date</option>
						</select>
					</div>
					<div id="dateBoxes">				
						<b>After:</b> <input id="dateAfter" placeholder="MM-DD-YYYY" class='notype clearable' type="text">
						<b>Before:</b> <input id="dateBefore" placeholder="MM-DD-YYYY" class='notype clearable' type="text">
					</div>
				</td>
				<%IF NoIds THEN%>
				<td>
					<input type="checkbox" id="inactiveToggle" name="inactiveToggle" style="display: inline-block;" onclick="toggleInactiveUsers()"></input>
					<label class="checkbox" for="inactiveToggle">Show Inactive Users</label>
					<br>
					<select multiple class="reportSelect" id="userSelect" size='8'>
					</select>
				</td>
				<td>
					<select multiple class="reportSelect" id="groupSelect" size='8'>
					</select>
				</td>
				<%END IF%>
			</tr>
		</table>
		<table>
			<tr>
				<td>
					<button id="reportButton" class="query-builder btn btn-xl" onclick="filterBtn()">Filter</button>
				</td>
			</tr>
		</table>
	</dl>
</div>

<% IF noIds THEN %>
<script>
// This populates a multiple select object with a list of users the current user is allowed to view data about.
$.ajax({
	method: "GET",
	url: "/arxlab/reporting/get_user_list.asp",
}).done(function(msg) {
		userList = msg.split(",");
		userList.pop(); //There is always an empty blank, we don't need it
		for (i = 0; i < userList.length; ++i) {
			user = userList[i].split(":");
			uId = user[0];
			uName = user[1];
			enabled = user[2];

			var selectOption = $("<option>", {
				value: uId,
				text: uName,
				enabled: enabled,
			});

			if (enabled == 0) {
				selectOption.attr("hidden", true);
			}

			$("#userSelect").append(selectOption);
	}
})

$.ajax({
	method: "GET",
	url: "/arxlab/reporting/get_group_list.asp",
}).done(function(msg) {
		groupList = msg.split(",");
		groupList.pop(); //There is always an empty blank, we don't need it
		for (i = 0; i < groupList.length; ++i) {
			group = groupList[i].split(":");
			gId = group[0];
			gName = group[1];

			var selectOption = $('<option>', {
				value: gId,
				text: gName
		});

		$("#groupSelect").append(selectOption);
	}
})

</script>
<% ELSE %>
<script>
// If the user has already chosen users to get to this page via the Summary Report, then don't show the
// multiple select object and instead make a call to the user list function to get a list of names to
// change the page title.
$.ajax({
        method: "POST",
        url: "/arxlab/reporting/get_user_list.asp",
		data: {"ids": "<%=urlId%>"}
      }).done(function(msg) {
		  var docHead = "<%=header%> for "
		  if (msg == "") {
			  // This is if the user ID given doesn't show up in the user list results.
			  docHead += "Unknown User is unavailable";
			  $("#builder").attr("hidden", true);
			  $("#TableDiv").attr("hidden", true);
		  }
		  else {
			userList = msg.split(",");
			userList.pop(); //There is always an empty blank, we don't need it

			nameArr = [];
			
			for (i = 0; i < userList.length; ++i) {
				nameArr.push(userList[i].split(":")[1]);
			}

			docHead += nameArr.join(", ");
		  }
	 	  document.title = docHead;
		  $("#DetailTitle").text(docHead);
	  });
</script>
<% END IF %>

<br>
<div id="downloadDiv">
	<a href="#" onclick="downloadCSVAjax()">Download the report as a CSV file with the current filter settings.</a>
</div>
<div id="largeWarning" hidden>
	<p>The current filter settings will result in <span>x</span> rows.<br>
	A very large dataset can negatively impact the performance of your browser, so we recommend narrowing down the result range further.<br>
	Alternately, <a href="#" onclick="downloadCSVAjax()">download the data as a CSV file</a>.</p>
</div>
<div id="TableDiv" class="scrollTable" hidden>
<table id="DetailReport" class="display" cellspacing="0" width="100%">
	<thead>
		<tr>
			<th>Experiment Type</th>
			<th>Experiment Type</th>
			<th>Last Name</th>
			<th>First Name</th>
			<th>User Email</th>
			<th>Notebook Name</th>
			<th>Notebook Description</th>
			<th>Experiment Name</th>
			<th>Experiment Description</th>
			<th>Status</th>
			<th>Reopened</th>
			<th>Requested Witness</th>
			<th>User Experiment Name</th>
			<th>Experiment Note</th>
			<th>Notebook Parent Project Name</th>
			<th>Notebook Parent Project Description</th>
			<th>Notebook Project Name</th>
			<th>Notebook Project Description</th>
			<th>Project Name</th>
			<th>Project Description</th>
			<th>Parent Project Name</th>
			<th>Parent Project Description</th>
			<th>Date Created (UTC)</th>
			<th>Date Last Modified (UTC)</th>
			<th>Sign Close Date (UTC)</th>
			<th>Witnessed Date (UTC)</th>
		</tr>
	</thead>
</table>
</div>
<script>

getExpTypes();

// Hide specific columns based on what user is loaded into the page.
var hideCols = ("<%=currUserId%>" == "") ? [ 0 ] : [ 0, 2, 3 ];

// Let DataTables know that there are dates in the table that might need to be sorted.
$.fn.dataTable.moment();
var table = $('#DetailReport').DataTable( {
			"columnDefs": [
				{
					// If we have multiple users, only hide column 0, the experiment type number.
					// Otherwise, hide the first and last names of the user because that seems
					// redundant when the user's name is displayed at the top of the page.
					"targets": hideCols,
					"visible": false,
					"searchable": false
				}
			],
			"scrollX": "100%",
			"pagingType": "full_numbers",
			dom: 'Bfrtip',
			buttons: [
				{
					extend: 'excelHtml5',
					charset: 'UTF-8',
					exportOptions: {
						columns: ':visible'
					}
				}
			]
		} );

// Both of our datepickers should NOT allow users to type dates in themselves because
// date formats are definitely not standard across the board. Restrict them here and let
// users pick from a more universal object like a calendar.
$('.notype').on('keydown', function(e){
    e.preventDefault();
})

var beforePicker = new Pikaday({
								field: $('#dateBefore')[0],
								format: 'MM-DD-YYYY'}
								);
var afterPicker = new Pikaday({
								field: $('#dateAfter')[0],
								format: 'MM-DD-YYYY'}
								);
$('.clearable').clearSearch({ callback: function() { console.log("cleared"); } } );
showTable();

function getSelectedCheckboxes(filterDiv) {
	// Get a list of selected experiment types.
	outArr = [];
	$("#" + filterDiv + " :checked").each(function() {
		outVal = $(this).val();

		if ($(this).attr("reqtype") != undefined) {
			outVal += "_" + $(this).attr("reqtype") + "_" + $(this).text();
		}

    	outArr.push(outVal);
	})
	if (filterDiv == "status_boxes" & outArr == []) {
		outArr = [1,2,3,4,5,6];
	}
	return outArr;
}

function showTable() {
	// Show the table object and hide the "too much data" warning.
	table.draw();
	$("#largeWarning").attr("hidden", true);
	$("#TableDiv").attr("hidden", false);

	// The Table headers and body get misaligned when scrollX is used, but if the window is resized, then
	// DataTables calls a function to recalculate the alignment. For some reason, I need to call the resize
	// event twice to make it realize that proper alignment might be nice to have.
	$(window).trigger('resize');
	$(window).trigger('resize');
}

function buildDetailUrl(expType, dateBefore, dateAfter, userIds, statuses, groups) {
	// Build the URL for calling the detailed report ASP file.

	returnObj = {
		exp: expType,
		groups: groups,
		typeDate: $("#dateField").val(),
		status: statuses
	};

	var base = "get_detailed_report.asp?exp=" + expType;
	base += "&typeDate=" + $("#dateField").val();

	if (dateBefore != "") {
		returnObj["dateBefore"] = dateBefore;
	}

	if (dateAfter != "") {
		returnObj["dateAfter"] = dateAfter;
	}

	if (userIds != "") {
		returnObj["id"] = userIds;
	}

	return returnObj;
}

function getMultiSelectVals(id) {

	var queryStringUserId = "<%=urlId%>";

	// We're getting user IDs, but we already have one specified by the querystring.
	if (id.includes("user") && queryStringUserId != "") {
		vals = [queryStringUserId];
	} else {
		vals = $(id).val();
		if (vals == null) {
			vals = []
			if (id.includes("user")) {
				$(id + " > option").each(function(){
					vals.push(this.value);
				});
			}
		}
	}
	
	return vals;
}

function filterBtn() {
	// When the button is pressed, clear the table, get a new result set and either have
	// the table display it or show the "too much data" warning if there's too many rows.
	buttonStatus("#reportButton", true);
	$("#largeWarning").attr("hidden", true);
	$("#downloadDiv").attr("hidden", true);
	table.clear().draw();

	// If we got here via the Summary page, we already have a formatted ID string we can use.
	// Otherwise, just build it right here from the userSelect.
	ids = ("<%=urlId%>" == "") ? getMultiSelectVals("#userSelect") : ["<%=urlId%>"];
	groups = ("<%=urlId%>" == "") ? getMultiSelectVals("#groupSelect"): [];
	selectedExps = getSelectedCheckboxes("exp_boxes");
	selectedStatuses = getSelectedCheckboxes("status_boxes");
	dateBefore = $("#dateBefore").val();
	dateAfter = $("#dateAfter").val();

	rowCount = getData(ids, dateBefore, dateAfter, selectedExps, selectedStatuses, groups);
}

function getData(ids, dateBefore, dateAfter, selectedExps, selectedStatuses, groups) {
	
	typeDate = $("#dateField").val();

	// Do a COUNT(*) query first to check how many rows the current filter will return.
	$.ajax({
        method: "POST",
        url: "/arxlab/reporting/get_detailed_report_count.asp",
		data: {
			data: JSON.stringify({
				userIds: ids,
				expTypes: selectedExps,
				groups: groups,
				status: selectedStatuses,
				dateBefore: dateBefore,
				dateAfter: dateAfter,
				typeDate: typeDate
			})},
		// Make this specific call an asynchronous one so the button actually changes while this is getting done.
        async: true
      }).fail(function() {
		  buttonStatus("#reportButton", false);
	  }).done(function(msg) {
		  if (msg >= tooManyRows) {
				// Too much data, hide the table, don't populate it and show the warning.
				$("#TableDiv").attr("hidden", true);
				$("#largeWarning span").text(msg);
				$("#largeWarning").attr("hidden", false);
				buttonStatus("#reportButton", false);
			} else {
				// Otherwise, call the detailed report function for every selected experiment type if there's actual data to retrieve.
				if (msg > 0) {
					for (i = 0; i < selectedExps.length; ++i) {
						inputData = buildDetailUrl(selectedExps[i], dateBefore, dateAfter, ids, selectedStatuses, groups);
						$.ajax({
							method: "POST",
							url: "get_detailed_report.asp",
							data: {
								data: JSON.stringify(inputData)
							}
						}).done(function(msg) {
							var rows = msg.split(";;;");
							rows.pop();
							for (j = 0; j < rows.length; ++j) {
								table.row.add(rows[j].split(':::'));
							};
						}).always(function() {
							showTable();
							buttonStatus("#reportButton", false);
						});
					} 
				} else {
					showTable();
					buttonStatus("#reportButton", false);
				}
			}
	  });
}

function downloadCSVAjax() {
	// Fallback plan for result sets with too much data. Send the current filter options to an
	// ASP page that makes a CSV report and offer the generated CSV as a download for the user.
	ids = getMultiSelectVals("#userSelect");
	groups = getMultiSelectVals("#groupSelect");
	selectedExps = getSelectedCheckboxes("exp_boxes");
	selectedStatuses = getSelectedCheckboxes("status_boxes");
	dateBefore = $("#dateBefore").val();
	dateAfter = $("#dateAfter").val();
	typeDate = $("#dateField").val();

    $(document.body).css({'cursor' : 'wait'});
	$.ajax({
        method: "POST",
        url: "/arxlab/reporting/make_detailed_report_csv.asp",
		data: {
			data: JSON.stringify({
				userIds: ids.join("-"),
				groups: groups,
				expTypes: selectedExps,
				status: selectedStatuses,
				dateBefore: dateBefore,
				dateAfter: dateAfter,
				typeDate: typeDate
			})
		}
		}).done(function(msg) {
			$(document.body).css({'cursor' : 'default'});
			var csvFile;
			var dl;

			csvFile = new Blob(["\uFEFF"+msg], {type: "text/html; charset=utf-8"});
			dl = document.createElement("a");
			dl.download = document.title + ".csv";
			dl.href = window.URL.createObjectURL(csvFile);
			dl.style.display = "none";
			document.body.appendChild(dl);
			dl.click();
		});
}

function buttonStatus(btnLabel, disabled) {
  var btnText = disabled ? "Working..." : "Filter"
  $(btnLabel).text(btnText);
  $(btnLabel).prop("disabled", disabled)
}

function getExpTypes() {

    appendOption("#expSelect", 1, "Chemistry", undefined, true);
    appendOption("#expSelect", 2, "Biology", undefined, true);
    appendOption("#expSelect", 3, "Concept", undefined, true);
    appendOption("#expSelect", 4, "Analytical", undefined, true);

	getWorkflowRequestTypes(null, function() {}).then(function(resp) {
		$.each(resp, function(reqTypeIndex, reqType) {
            if (reqType["displayName"] != undefined) { // if there are no records the function will return an empty record
			    appendOption("#expSelect", 5, reqType["displayName"], reqType["id"], true);
            }
		});
		
		$("#expSelect").attr("size", $("#expSelect").children().length > 8 ? 8 : $("#expSelect").children().length);
	});

}

function appendOption(selector, value, text, reqType, selected) {
    if (text != undefined) {
        $(selector).append($("<option></option>", {
	        value: value,
	        text: text,
	        reqType: reqType,
	        selected: selected
        }));
	}
    else {
        console.log("The option was not appended because the name is blank.");
    }
}

/**
 * Toggles whether inactive users appear or not from the user selection list
 */
function toggleInactiveUsers() {
	var isChecked = $("#inactiveToggle").is(":checked");	
	$.each($("#userSelect").children("[enabled=0]"), function(optionIndex, option) {
		$(option).attr("hidden", !isChecked);
		$(option).attr("selected", false); 
	});
}
</script>
<!-- #include file="../_inclds/footer-tool.asp"-->