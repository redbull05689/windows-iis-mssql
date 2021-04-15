<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
sectionId = "show-watchlist"
subSectionID = "show-watchlist"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "show-watchlist"
%>

<%
	header = "Watchlist"
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
<h1 id="ProjectTitle"><%=header%></h1>

<br>
<div id="LoadingGif">
	<img src="../images/loading.gif" align="middle">
</div>
<div id="TableDiv" hidden>
<table id="ProjectTable" class="display" cellspacing="100">
	<thead>
		<tr>
            <th>Experiment Name</th>
			<th>Status</th>
			<th>Experiment Type</th>
            <th>Creator</th>
			<th>Date Created (EDT)</th>
            <th>Saves</th>
            <th>Notes</th>
            <th>Attachments</th>
            <th>Comments</th>
            <th></th>
		</tr>
	</thead>
</table>
</div>

<script>

var table = $('#ProjectTable').DataTable( {
				"pageLength": 25,
				"columnDefs": [
					{
						"visible": false,
						"searchable": false
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
				order: [[4, "desc"]],
				stateSave: true,
				stateSaveCallback: function(settings, data) {
					var date = new Date();
					date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
					document.cookie="showWatchlistCookie=" + JSON.stringify(data) + ";expires=" + date.toGMTString();
				},
				stateLoadCallback: function(settings) {
					return JSON.parse(getCookie("showWatchlistCookie"));
				}
			} );
$.fn.dataTable.moment();

table.on( 'page.dt', function() {
    addRxnToVisible(table, 10);
})

table.on( 'order.dt', function() {
	addRxnToVisible(table, 10);
})

table.on( 'search.dt', function() {
	addRxnToVisible(table, 10);
})

function updateTable() {
$.ajax({
        method: "GET",
        url: "/arxlab/table_pages/get-watchlist.asp",
		async: true
		}).done(function(msg) {
			var rows = msg.split(";;;");
			rows.pop();
			for (j = 0; j < rows.length; ++j) {
				rowData = rows[j].split(":::");
				table.row.add(rowData);
				if (rowData[2] == "Chemistry") {
					expId = rowData[10];
					table.row(j).child(expId).show();
					//getCdx(rowData[10], j, table);
				}
			};
		}).always(function() {
				table.draw();
				$("#LoadingGif").remove();
				$("#TableDiv").attr("hidden", false);
				addRxnToVisible(table, 10);
		});
}
updateTable();

$(window).load(function() {
	new $.fn.dataTable.FixedHeader( table, {} );
});

var wlSack = new sack();
function deleteWatchlistItem(id) {
	sweetAlert(
        {
            title: "Are you sure?",
            text: "Are you sure you would like to delete this item from your watchlist?",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#5CB85C',
            confirmButtonText: 'Yes',
            cancelButtonText: 'No'
        },
        function(isConfirm) {
            if (isConfirm) {
                $.ajax({
                    method: "GET",
                    url: "<%=mainAppPath%>/misc/ajax/do/deleteWatchlistItem.asp",
                    data: {"id": id, "random": Math.random()},
                    async: true
                }).done(function() {
                    redrawWatchlist();
                });
            }
        }
    )
}

function redrawWatchlist() {
	table.clear();
    updateTable();
}

</script>
<!-- #include file="../_inclds/footer-tool.asp"-->