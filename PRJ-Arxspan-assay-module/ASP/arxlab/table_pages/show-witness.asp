<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
sectionId = "show-experiments"
subSectionID = "show-experiments"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
	header = "Witnessed By Me"
    dateCol = "Witnessed"
    requests = request.querystring("r")
    if requests <> "" then
        header = "Witness Requests"
        dateCol = "Requested"
    end if

	pageTitle = header
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<script src="../js/jquery.dataTables.1.10.15.min.js"></script>
<script src="../js/moment.min.js"></script>
<script src="../js/datetime-moment.js"></script>
<script src="../_inclds/experiments/chem/js/getRxn.js?<%=jsRev%>"></script>
<link href="../css/jquery.dataTables.1.10.15.css" rel="stylesheet" type="text/css">
<link href="../css/buttons.dataTables.min.css" rel="stylesheet" type="text/css">
<link href="../css/fixedHeader.dataTables.min.css" rel="stylesheet" type="text/css">
<script src="../_inclds/common/functions/getCookie.js?<%=jsRev%>"></script>
<h1 id="NotebookTitle"><%=header%></h1>

<br>
<div id="TableDiv">
<table id="SummaryTable" class="display" cellspacing="100" style="width:100%">
	<thead>
		<tr>
			<th>Experiment Name</th>
            <th>Type</th>
			<th>Sharer</th>
			<th>Date <%=dateCol%> (UTC)</th>
		</tr>
	</thead>
</table>
</div>

<script>

var table = $('#SummaryTable').DataTable( {
				"pageLength": 25,
				"columnDefs": [
					{
						"visible": false,
						"searchable": false,
						"data": "expId",
						"title": "Experiment ID",
					},
					{
						"targets": 0,
						"data": "name",
						"title": "Experiment Name",
					},
					{
						"targets": 1,
						"data": "type",
						"title": "Experiment Type",
						"render": function(data, type, row, meta) {
							if (data == "Chemistry") {
								console.log("Chemistry");
							}
							return data;
						}
					},
					{
						"targets": 2,
						"data": "sharer",
						"title": "Sharer",
					},
					{
						"targets": 3,
						"data": "date",
						"title": "Date <%=dateCol%> (UTC)",
					}
				],
				// Put B in front to restore the CSV button
				dom: 'fiprtip',
        		buttons: [
					{
						extend: 'csvHtml5',
						exportOptions: {
							columns: ':visible'
						}
					}
				],
				"pagingType": "full_numbers",
				order: [[3, "desc"]],
				stateSave: true,
				stateSaveCallback: function(settings, data) {
					var date = new Date();
					date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
					document.cookie="showWitnessCookie=" + JSON.stringify(data) + ";expires=" + date.toGMTString();
				},
				stateLoadCallback: function(settings) {
					return JSON.parse(getCookie("showWitnessCookie"));
				},
				"ajax": {
					url: "/arxlab/table_pages/get-witness.asp?requests=" + "<%=requests%>",
					dataSrc: ""
				}
			} );
$.fn.dataTable.moment();

/**
 * Helper function to add experiment IDs to the data table child rows for all chemistry experiments.
 */
function addChemIds() {
	var activeRows = table.rows({filter: "applied"}).toArray()[0];
	$.each(activeRows, function(i, rowNum) {
		var row = table.row(rowNum).data()
		if (row.type == "Chemistry") {
			table.row(rowNum).child(row.expId).show();
		}
	})
}

table.on( 'page.dt', function() {
	addChemIds();
    addRxnToVisible(table, 4);
})

table.on( 'order.dt', function() {
	addChemIds();
	addRxnToVisible(table, 4);
})

table.on( 'search.dt', function() {
	addChemIds();
	addRxnToVisible(table, 4);
})


$(window).load(function() {
	new $.fn.dataTable.FixedHeader( table, {} );
});

</script>
<!-- #include file="../_inclds/footer-tool.asp"-->