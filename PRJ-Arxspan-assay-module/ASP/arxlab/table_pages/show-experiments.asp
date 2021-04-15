<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
Response.ContentType = "text/html"
Response.AddHeader "Content-Type", "text/html;charset=UTF-8"
Response.CodePage = 65001
Response.CharSet = "UTF-8"
sectionId = "show-experiments"
subSectionID = "show-experiments"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
	recent = request.querystring("r")
	myOrYours = Request.QueryString("m")
	if myOrYours = "y" then
		header = "My Experiments"
	else
		header = "Experiments Shared With Me"
	end if
	pageTitle = header
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<script src="../js/jquery.dataTables.1.10.15.min.js"></script>
<script src="../js/moment.min.js"></script>
<script src="../js/datetime-moment.js"></script>
<script src="../_inclds/experiments/chem/js/getRxn.js?<%=jsRev%>"></script>
<script src="../_inclds/common/functions/getCookie.js?<%=jsRev%>"></script>
<link href="../css/jquery.dataTables.1.10.15.css" rel="stylesheet" type="text/css">
<link href="../css/buttons.dataTables.min.css" rel="stylesheet" type="text/css">
<link href="../css/fixedHeader.dataTables.min.css" rel="stylesheet" type="text/css">

<h1 id="ExperimentTitle"><%=header%></h1>

<br>
<script type="text/javascript">
var experimentTableHeaders = [
	{"displayName":"Experiment Name","dbCol":"name"},
	{"displayName":"Description","dbCol":"details"},
	{"displayName":"Notebook","dbCol":"notebookName"},
	{"displayName":"Status","dbCol":"status"},
	{"displayName":"Type","dbCol":"type"},
	{"displayName":"Creator","dbCol":"fullName"},
	{"displayName":"Date Created","dbCol":"dateSubmitted"},
	{"displayName":"Last Viewed","dbCol":"theDate"},
	{"displayName":"Experiment Type ID","dbCol":"typeId"},
	{"displayName":"Experiment ID","dbCol":"expId"},
	{"displayName":"Request Type ID","dbCol":"requestTypeId"}
];
</script>

<div id="TableDiv" style="margin-top:25px;">
    <table id="SummaryTable" class="display responsive dtr-column" cellspacing="100" width="100%">
		<thead>
			<tr>
			<script type="text/javascript">
				$.each(experimentTableHeaders, function(i, obj) {
					document.write("<th>" + obj.displayName + "</th>")
				});
			</script>
            </tr>
        </thead>
    </table>
</div>

<div id="customExperimentTypesJson" style="display:none;">
<%response.write(getCustomExperimentTypes())%>
</div>
<script>

try { experimentTypeData = JSON.parse($("#customExperimentTypesJson").text()); } catch(err) { console.log("ERROR parsing experimentTypeData"); console.log(err); }
if(typeof experimentTypeData == "undefined")
	experimentTypeData = [];
	var saveStateOrderingData;

var table = $('#SummaryTable').DataTable( {
	"bServerSide": true,
	"sServerMethod": "POST",
	"sAjaxSource": "/arxlab/table_pages/get-experiments.asp",
	"fnServerParams": function ( aoData ) {
		var sortStr = "";
		if(table) {
			$.each(table.order(), function(i, obj) {
				if(sortStr.length) {
					sortStr += ", ";
				}
				
				sortStr += experimentTableHeaders[obj[0]].dbCol + " " + obj[1];
			});
		}
		else if (saveStateOrderingData != null && saveStateOrderingData[0] != null &&
			saveStateOrderingData[0][0] != null && saveStateOrderingData[0][1] != null)
		{
			sortStr += experimentTableHeaders[saveStateOrderingData[0][0]].dbCol + " " + saveStateOrderingData[0][1];
		}
		else {
			sortStr += "theDate desc";
		}
		
		aoData.push({"name": "sortOrder", "value": sortStr});
		aoData.push({"name": "yMeansShowMyExperiments", "value": "<%=myOrYours%>"});
	},
	"pageLength": 25,
	"columnDefs": [
		{
			"targets": [1,8,9,10],
			"visible": false,
			"searchable": true
		}
	],
	"pageLength": 25,
	"lengthMenu": [ [10, 25, 50, 100], [10, 25, 50, 100] ],
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
	order: [[6, "desc"]],
	stateSave: true,
	oLanguage: { sEmptyTable: "There are no experiments to display." },
	stateSaveCallback: function(settings, data) {
		var date = new Date();
		date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
		document.cookie="showExperimentsCookie=" + JSON.stringify(data) + ";expires=" + date.toGMTString();
	},
	stateLoadCallback: function(settings) {
		cookieData = JSON.parse(getCookie("showExperimentsCookie"));
		
		if (cookieData != null && cookieData["order"] != null){		
			saveStateOrderingData = cookieData["order"];
		}
		return cookieData;
	},
	drawCallback: function(settings) {
		table.rows().every( function ( rowIdx, tableLoop, rowLoop ) {
			var descRow = [];
			// If there is a description, put it in a child row
			if(table.cell(rowIdx, 1).data() != "") {
				descRow.push("<div class='multiLineSpacing' style='margin-left:25px;width=100%'>" + table.cell(rowIdx, 1).data() + "</div>");
			}
			
			// If there is a chemistry reaction, put it in a child row
			if(table.cell(rowIdx, 8).data() == "1") {
				descRow.push(table.cell(rowIdx, 9).data());
			}

			// Make the child row, if one is needed
			if(descRow.length) {
				this.child(descRow).show();
			}
			
			// Put in the correct names for the custom experiment types
			if(table.cell(rowIdx, 8).data() == "5") {
				var myRequestTypeId = table.cell(rowIdx, 10).data();
				$.each(experimentTypeData, function(i, obj) {
					if(obj.hasOwnProperty("displayName") && obj.hasOwnProperty("id") && obj["id"] == myRequestTypeId) {
						table.cell(rowIdx, 4).data(obj["displayName"]);
						return false;
					}
				});
			}
		} );

		addRxnToVisible(table, 9);
	}
});	

$.fn.dataTable.moment();
</script>
<!-- #include file="../workflow/_inclds/Workflow_Includes.asp"-->
<!-- #include file="../_inclds/footer-tool.asp"-->
<script type="text/javascript" src="<%=mainAppPath%>/js/select2-3.5.1/select2.js?<%=jsRev%>"></script>