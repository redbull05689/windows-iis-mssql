<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
sectionId = "god2"
subSectionID = "reportSummary"
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
If Not session("userHasOperationalReport") Then
	response.redirect(mainAppPath & "/dashboard.asp")
End if
%>

<%
sectionId = "tool"
%>

<%
	header = "Operational Report Summary"
	pageTitle = header
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<script src="../js/jquery.dataTables.1.10.15.min.js"></script>
<script src="../js/moment.min.js"></script>
<script src="../js/datetime-moment.js"></script>
<link href="../css/jquery.dataTables.1.10.15.css" rel="stylesheet" type="text/css">
<link href="../css/buttons.dataTables.min.css" rel="stylesheet" type="text/css">
<h1 id="SummaryTitle"><%=header%></h1>
<a id="detailLink" href=<%=mainAppPath%>/reporting/report_activity_detail.asp title=Detailed Report>Detailed Report</a><br>
<input type="checkbox" id="inactiveToggle" name="inactiveToggle" style="display: inline-block;"></input>
<label class="checkbox" for="inactiveToggle">Show Inactive Users</label>
<br>
<select multiple class="reportSelect" id="groupSelect" size='8'>
</select>
<br>
<div id="LoadingGif">
	<img src="../images/loading.gif" align="middle">
</div>
<div id="TableDiv" hidden>
<table id="SummaryTable" class="display" cellspacing="100" style="width:100%">
	<thead>
		<tr>
			<th>User ID</th>
			<th>User</th>
			<th>User</th>
			<th>Last Activity Time</th>
			<th>Date of Last Witnessed Experiment</th>
			<th>Number of Experiments</th>
			<th>Number of Witnessed Experiments</th>
			<th>Number of Signed/Closed Experiments</th>
			<th>Number of Saved Experiments</th>
			<th>Number of Created Experiments</th>
			<th>Active</th>
		</tr>
	</thead>
</table>
</div>

<script>

var hideCols = [ 0, 1 ];
var table = $('#SummaryTable').DataTable( {
				"columnDefs": [
					{
						// Hide the User ID and first User Name columns. We're only using those for
						// their value when the rows are selected.
						"targets": hideCols,
						"visible": false,
						"searchable": false
					},
					{
						"targets": [5,6,7,8,9],
						"sType": "numeric" 
					}
				],
				"pagingType": "full_numbers",
				dom: 'Bfrtip',
        		buttons: [
					{
						extend: 'csvHtml5',
						exportOptions: {
							columns: ':visible'
						}
					}
				]
			} );
$('#SummaryTable tbody').on( 'click', 'tr', function () {
        $(this).toggleClass('selected');
		makeDetailedReportText(table.rows('.selected').data())
    } );
$.fn.dataTable.moment();
populateSummaryTable([]);

function populateSummaryTable(groupIds) {

	$("#SummaryTable").DataTable().clear();

	$.ajax({
		method: "POST",
		url: "/arxlab/reporting/get_summary_report.asp",
		data: {
			data: JSON.stringify(groupIds),
			inactive: $("#inactiveToggle").is(":checked")
		},
		async: true
	}).done(function(msg) {
		var rows = msg.split(";;;");
		rows.pop();
		for (j = 0; j < rows.length; ++j) {
			var row = rows[j].split(":::");
			row[5] = parseInt(row[5]);
			row[6] = parseInt(row[6]);
			row[7] = parseInt(row[7]);
			row[8] = parseInt(row[8]);
			row[9] = parseInt(row[9]);
			row[10] = row[10] == 1 ? "Yes" : "No";
			table.row.add(row);
		};
	}).always(function() {
			table.draw();
			$("#LoadingGif").remove();
			$("#TableDiv").attr("hidden", false);
	});

}

function makeDetailedReportText(selectedRows) {
	// Dynamically sets the text for the detailed report and creates an
	// appropriate link based on the selected rows.
	output = "Detailed Report";
	outlink = "<%=mainAppPath%>/reporting/report_activity_detail.asp"
	rowLength = selectedRows.length

	// If either no rows or all of the rows are selected, then we want
	// just the default values so we can get a detailed report for everyone.
	if (rowLength > 0 & rowLength < table.rows().data().length) {
		output += " for user";
		outlink += "?id=";

		// If only one row is selected, then user is singular and
		// we only need one ID. Otherwise, user is plural and we need
		// multiple IDs in the URL, delimited by "-"
		if (rowLength == 1) {
			name = selectedRows[0][1];
			id = selectedRows[0][0];
			output += ": " + name;
			outlink += id;
		} else {
			output += "s: ";
			nameArr = [];
			idArr = [];
			for (i = 0; i < rowLength; i++) {
				nameArr.push(selectedRows[i][1]);
				idArr.push(selectedRows[i][0]);
			}
			output += nameArr.join(", ");
			outlink += idArr.join("-");
		}
	}

	$("#detailLink").text(output)
	$("#detailLink").attr("href", outlink)
	
}

$(document).ready(function() {
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
	});

	$("#groupSelect, #inactiveToggle").on("change", function() {
		var groupIds = $("#groupSelect").val();

		groupIds = groupIds == null ? [] : groupIds;

		populateSummaryTable(groupIds);
	});
})
</script>
<!-- #include file="../_inclds/footer-tool.asp"-->