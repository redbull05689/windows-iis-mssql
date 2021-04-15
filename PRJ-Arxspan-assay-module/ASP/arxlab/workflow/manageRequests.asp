<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
sectionId = "workflow" 
pageTitle = "Manage Requests - Arxspan Workflow"
%>


<!-- #include file="header2.asp"-->

<body>

<script type="text/javascript">
  	//var ReactTable = window.ReactTable.default;
	window.CurrentPageMode = "manageRequests";
	window.top.currApp = "Workflow";
	window.top.rowReorderLocked = false;
	window.top.rowReorderLockedByReorder = false;
</script>

<div class="row">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header" data-background-color="materialblue">
                <h4 class="title">
                	Manage Requests
	                <div class="category manageRequestsTable_requestTypeDropdownContainer">
	                	<label class="editorFieldLabel">Visible request type</label>
	                	<select id="manageRequestsTable_requestTypeDropdown"></select>
	                </div>
                </h4>
            </div>
			<div class="p-3 mb-2 bg-info text-white ">
				<p id="lockMsg" class="center-Align"></p>
			</div>
            <div class="card-content table-responsive card-content-dataTable">
				<div class="dropdownsTableContainer requestsTableContainer">
					<table class="editorSectionTable manageRequestsTable dataTable nowrap" id="manageRequestsTable" cellspacing="0" style="width:100%">
						<thead></thead>
						<tbody></tbody>
					</table>

					<div id="UpdateRequestsButtons" style="display: none;" class="bottomButtons">
						<button class="updateRequestsAssignedOrderButton submitButton btn btn-success">Update Request Priorities</button>
						<button class="btn btn-danger" id="resetRequests">Cancel Request Priorities</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
	$(document).ready(function(){
		$('.sidebarItem_manageRequests').addClass('active');
		$('body').addClass('pageWithRequestTable');
	})
</script>

<script type="text/javascript" src="js/manageRequests.min.js?<%=jsRev%>"></script>
<!-- #include file="_inclds/footer.asp"-->