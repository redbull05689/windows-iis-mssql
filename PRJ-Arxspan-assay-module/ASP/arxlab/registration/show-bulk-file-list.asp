<!DOCTYPE html>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
sectionId = "reg"
subSectionID = "show-bulk-files"
notebookId = Request.querystring("id")
%>

<!-- #include file="../_inclds/globals.asp"-->

<%
	header = "Arxspan Registration"
	pageTitle = header
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script src="../js/jquery.dataTables.1.10.15.min.js"></script>
<script src="../js/moment.min.js"></script>
<script src="../js/datetime-moment.js"></script>
<script src="../_inclds/common/functions/getCookie.js?<%=jsRev%>"></script>
<link href="../css/jquery.dataTables.1.10.15.css" rel="stylesheet" type="text/css">
<link href="../css/buttons.dataTables.min.css" rel="stylesheet" type="text/css">
<link href="../css/fixedHeader.dataTables.min.css" rel="stylesheet" type="text/css">


<div id="NotebookTableDiv" style="margin-top:25px;">
	<hr>
    <table id="NotebookTable" class="compact stripe" cellspacing="100" width="100%">
        <thead>
            <tr>
				<th>User Name</th>
				<th>File Name</th>
				<th>Status</th>
				<th>Records Processed</th>
				<th>Errors</th>
				<th>Download Report</th>
				<%If session("regRegistrar") Then%>
				<th>Rollback</th>
				<%End If%>
				<th>Date Created</th>
				<th>Date Processed</th>
            </tr>
        </thead>
    </table>
</div>

<script>
var notebookTable = $("#NotebookTable").DataTable( {
				//"bServerSide": true,	// Need to turn this off for pagination and search to work
				"sServerMethod": "POST",
				// "bProcessing": true,
				"sAjaxSource": "get-bulk-file-list.asp",
				"fnServerParams": function ( aoData ) {
					var sortStr = "";
					if(notebookTable) {
						$.each(notebookTable.order(), function(i, obj) {
						});
					}
					else {
						sortStr += "dateUpdatedServer desc";
					}
					
					aoData.push({"name": "sortOrder", "value": sortStr});
				},
				"pageLength": 25,
				"lengthMenu": [ [10, 25, 50, 100], [10, 25, 50, 100] ],
				"columnDefs": [
					{"className": "dt-center", "targets": [3,4]}	// center align the error and total counts.
				],
				// No sorting on this table
				"bSort" : false,
				// Put B in front to restore the CSV button
				dom: "lfiprtip",
        		buttons: [
					{
						extend: "csvHtml5",
						exportOptions: {
							columns: ":visible"
						}
					}
				],
				"pagingType": "full_numbers",
				"autoWidth": false,
				order: [[7, "desc"]],
				stateSave: true,
				drawCallback: function(settings) {
				}
});
//$.fn.dataTable.moment();	// Enable this to support sorting on date
</script>
</html>
<%
%>
