<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
sectionId = "workflow" 
pageTitle = "User Settings - Arxspan Workflow"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header.asp"-->

<div class="row">
    <div class="col-lg-6 col-md-12">
		<div class="card">
            <div class="card-header" data-background-color="materialblue">
            	<h4 class="title">Notification Preferences</h4>
            </div>
            <div class="card-content">
		        <div class="table-responsive">
		            <table class="table" id="notificationPreferences_requestTypesTable">
		                <thead class="text-primary">
		                	<tr>
		                		<th>Request Type Name</th>
		                		<th></th><!-- "Settings" button column -->
		                	</tr>
		                </thead>
		                <tbody></tbody>
		            </table>
		        </div>
            </div>
        </div><div class="card">
            <div class="card-header" data-background-color="materialblue">
            	<h4 class="title">Excel Import Settings</h4>
            </div>
            <div class="card-content">
		        <div class="table-responsive">
		            <table class="table" id="excelImportSettingsTable">
		                <thead class="text-primary">
		                	<tr>
		                		<th>Select where to add file contents</th>
		                		<th></th><!-- "Settings" button column -->
		                	</tr>
		                </thead>
		                <tbody></tbody>
		            </table>
		        </div>
            </div>
        </div>
    </div>
    <div class="col-lg-6 col-md-12">
        <div class="card requestTypeNotificationUserSettings" id="requestTypeNotificationUserSettings">
        </div>        
    </div>
</div>
<script type="text/javascript">
	window.manageMyRequests = true;
	$(document).ready(function(){
		$('.sidebarItem_userSettings').addClass('active');
	})
	currApp = "Configuration";
</script>
<script type="text/javascript" src="js/userSettings.js?<%=jsRev%>"></script>
<script type="text/babel" src="js/React/userSettingsModule.js?<%=jsRev%>"></script>   
<script type="text/babel" src="js/React/notificationLoadingModule.js?<%=jsRev%>"></script>    
<script type="text/babel" src="js/React/notificationSubmitionModule.js?<%=jsRev%>"></script>        
<!-- #include file="_inclds/footer.asp"-->