<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
isManageConfigurationPage = True 
pageTitle = "Edit Dropdowns - Arxspan Workflow"
%>

<!-- #include file="../_inclds/globals.asp"-->
<%
if showAdminPages() or showDropDownPages() then
%>
<!-- #include file="../_inclds/header.asp"-->

<div id="arxWorkflowContainer">
	<div class="row">
	    <div class="col-md-12">
			<div id="reactDropdownEditor"></div>
			<div class="dropdownEditorContainer card" dropdownid="">
				<div class="editorField" fieldid="displayName">
					<label class="editorFieldLabel">Dropdown Name</label>
					<input type="text" class="editorFieldInput">
				</div>
				<div class="editorField" fieldid="hoverText">
					<label class="editorFieldLabel">Dropdown Hover Text</label>
					<input type="text" class="editorFieldInput">
				</div>
				<div class="editorField" fieldid="dropdownMasking">
					<label class="editorFieldLabel" for="dropdownMasking_enabled_cb">Dropdown Masking</label>
					<input type="checkbox" class="editorFieldCheckbox" name="dropdownMasking_enabled_cb">
					<button class="basicActionButton manageDropdownMaskingButton">Manage</button>
				</div>

				<div class="dropdownMaskUserGroupSettingsContainer">
					<div class="dropdownMaskUserGroupsSection" id="dropdownMaskUserGroupsEditorSection">
						<label class="editorSectionLabel">Dropdown Mask User Group Settings</label>
						<div class="editorSection dropdownOption" sectionid="dropdownMaskUserGroups">
							<div class="editorSectionTableContainer">
								<table class="editorSectionTable restrictAccessTable dropdownMaskUserGroupsTable dropdownOptionMaskSettingsTable dataTable" id="dropdownMaskUserGroupsTable">
									<thead>
										<th></th>
										<th>Masking Enabled</th>
										<th>Mask Values</th>
									</thead>
									<tbody></tbody>
								</table>
							</div>
						</div>
					</div>
					<div class="viewMaskValuesForGroupHolder" id="viewMaskValuesForGroupHolder">
						<button class="basicActionButton hideViewMaskValuesForGroupButton">Hide</button>
						<label class="viewMaskValuesForGroupTableLabel" id="viewMaskValuesForGroupTableLabel"></label>
						<table class="viewMaskValuesForGroupTable table table-striped table-hover" id="viewMaskValuesForGroupTable">
							<thead>
								<tr>
									<th>Real Value</th>
									<th>Mask Value</th>
								</tr>
							</thead>
							<tbody></tbody>
						</table>
					</div>
					<br />
					<button class="basicActionButton submitUpdateButton">Update Mask Settings</button><button class="basicActionButton cancelChangesButton">Cancel Changes</button>
				</div>

				<label class="editorSectionLabel">Dropdown Options</label>
				<div class="editorSection" sectionid="dropdownOptions">
					<div class="aboveEditorTableButtonsContainer">
						<button class="newDropdownOptionButton basicActionButton">+ New Option</button>
					</div>
					<div class="editorSectionTableContainer dropdownOptionsTableContainer">	
						<table class="editorSectionTable dropdownOptionsTable dataTable" id="dropdownOptionsTable">
							<thead>
								<th>Option Name</th>
								<th>Disabled</th>
								<th>Masking</th>
								<th><!-- Delete button column - button only shows when option hasn't been saved to DB yet --></th>
							</thead>
							<tbody></tbody>
						</table>
					</div>
				</div>

				<div class="dropdownOptionMaskSettingsContainer">
					<div class="dropdownOptionMasksSection" id="dropdownOptionMasksEditorSection">
						<label class="editorSectionLabel">Option Masks</label>
						<div class="editorSection dropdownOption" sectionid="dropdownOptionMasks">
							<div class="editorSectionTableContainer">
								<table class="editorSectionTable restrictAccessTable dropdownOptionMasksTable dropdownOptionMaskSettingsTable dataTable" id="dropdownOptionMasksTable">
									<thead>
										<th></th>
										<th>Mask Value</th>
									</thead>
									<tbody></tbody>
								</table>
							</div>
						</div>
					</div>
					<button class="basicActionButton submitUpdateButton">Update Mask Settings</button><button class="basicActionButton cancelChangesButton">Cancel Changes</button>
				</div>

				<div class="editorField" fieldid="disabled">
					<label class="editorFieldLabel" for="dropdownEditor_disabled_cb">Disabled</label>
					<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_disabled_cb">
				</div>
				<div class="bottomButtons">
					<button class="dropdownEditorSubmit submitButton btn btn-success">Submit</button>
					<button class="dropdownEditorCancel cancelButton btn btn-danger">Cancel</button>
				</div>
			</div>
	        <div class="card">
	            <div class="card-header" data-background-color="materialblue">
	                <h4 class="card-title">
	                	Manage Dropdowns
	                </h4>
	                <div class="category manageRequestsTable_requestTypeDropdownContainer">
						<button class="newDropdownButton btn btn-white">New Dropdown</button>
					</div>
	            </div>
				
				<div class="dropdownsTableContainer">
					<table id="dropdownsTable" class="dropdownsTable dataTable" cellspacing="0">
						<thead>
							<th>Dropdown Name</th>
							<th>Hover Text</th>
							<th>Dropdown Options</th>
							<th>Status</th>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
	window.requestTypePageMode = "<%=requestTypePageMode%>";
	$(document).ready(function(){
		$('.sidebarItem_adminConfiguration, .sidebarItem_manageDropdowns').addClass('active');
		$('body').addClass('canMakeNewRequest');
	})
</script>

<script type="text/babel" src="js/React/fieldComponent.js?<%=jsRev%>"></script>
<script type="text/babel" src="js/React/dropdownComponent.js?<%=jsRev%>"></script>
<script type="text/babel" src="js/editDropdowns.js?<%=jsRev%>"></script>
<!-- #include file="../_inclds/footer.asp"-->
<% end if %>