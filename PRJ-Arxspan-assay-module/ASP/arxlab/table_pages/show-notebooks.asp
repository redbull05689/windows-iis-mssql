<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
sectionId = "show-notebooks"
subSectionID = "show-notebooks"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "show-notebooks"
%>

<%
	header = "Notebooks"
	pageTitle = header
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<script src="../js/jquery.dataTables.1.10.15.min.js"></script>
<script src="../js/moment.min.js"></script>
<script src="../js/datetime-moment.js"></script>
<link href="../css/jquery.dataTables.1.10.15.css" rel="stylesheet" type="text/css">
<link href="../css/buttons.dataTables.min.css" rel="stylesheet" type="text/css">
<link href="../css/fixedHeader.dataTables.min.css" rel="stylesheet" type="text/css">
<script src="../_inclds/common/functions/getCookie.js?<%=jsRev%>"></script>
<h1 id="NotebookTitle"><%=header%></h1>

<br>
<div id="LoadingGif">
	<img src="../images/loading.gif" align="middle">
</div>
<div id="TableDiv" hidden>
<table id="SummaryTable" class="display" cellspacing="100" style="width:100%">
	<thead>
		<tr>
			<th>Notebook Name</th>
			<th>Description</th>
			<th>Creator</th>
			<th>Last Viewed (EDT)</th>
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
				order: [[3, "desc"]],
				stateSave: true,
				stateSaveCallback: function(settings, data) {
					var date = new Date();
					date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
					document.cookie="showNotebooksCookie=" + JSON.stringify(data) + ";expires=" + date.toGMTString();
				},
				stateLoadCallback: function(settings) {
					return JSON.parse(getCookie("showNotebooksCookie"));
				}
			} );
$.fn.dataTable.moment();


$.ajax({
        method: "GET",
        url: "/arxlab/table_pages/get-notebooks.asp",
		async: true
		}).done(function(msg) {
			msg = decodeDoubleByteString(msg);
			var rows = msg.split(";;;");
			rows.pop();
			for (j = 0; j < rows.length; ++j) {
				table.row.add(rows[j].split(":::"));
			};
		}).always(function() {
				table.draw();
				$("#LoadingGif").remove();
				$("#TableDiv").attr("hidden", false);
		});

$(window).load(function() {
	new $.fn.dataTable.FixedHeader( table, {} );
});
</script>
<!-- #include file="../_inclds/footer-tool.asp"-->