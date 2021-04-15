<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
isManageConfigurationPage = True 
pageTitle = "Edit Fields - Arxspan Workflow"
%>

<!-- #include file="../_inclds/globals.asp"-->
<% if showAdminPages() then %>
<!-- #include file="../_inclds/header.asp"-->

<div id="arxWorkflowContainer">
    <div class="row">
        <div class="col-md-12">
			<div id="reactFieldEditor"></div>
            <div class="dropdownEditorContainer card" fieldid="">
            	<div class="editorField" fieldid="displayName">
            		<label class="editorFieldLabel">Field Name</label>
            		<input type="text" class="editorFieldInput">
            	</div>
            	<div class="editorField" fieldid="hoverText">
            		<label class="editorFieldLabel">Hover Text</label>
            		<input type="text" class="editorFieldInput">
            	</div>
            	<div class="editorField" fieldid="dataType">
            		<label class="editorFieldLabel">Data Type</label>
            		<select class="editorFieldDropdown dataTypeDropdown" id="dataTypeDropdown"></select>
            	</div>

            	<div class="hiddenEditorSectionContainer fieldDropdownOptionsSection" id="dropdownOptionsEditorSection">
            		<label class="editorSectionLabel">Dropdown Options</label>
            		<div class="editorSection dropdownOption " sectionid="dropdownOptions">
            			<div class="aboveEditorTableButtonsContainer">
            				<button class="newDropdownOptionButton basicActionButton">+ New Option</button>
            				<select id="savedDropdownsListDropdown" class="savedDropdownsListDropdown"></select>
            				<label for="savedDropdownsListSyncCheckbox" class="savedDropdownsListSyncCheckboxLabel">Keep Synced with Dropdown</label><input type="checkbox" name="savedDropdownsListSyncCheckbox" class="savedDropdownsListSyncCheckbox" id="savedDropdownsListSyncCheckbox">
            			</div>
            			<div class="editorSectionTableContainer dropdownOptionsTableContainer">	
            				<table class="editorSectionTable dropdownOptionsTable dataTable" id="dropdownOptionsTable">
            					<thead>
            						<th>Option Name</th>
            						<th>Disabled</th>
            						<th></th>
            					</thead>
            					<tbody></tbody>
            				</table>
            			</div>
            		</div>
            	</div>

            	<div class="editorField" fieldid="isUnique">
            		<label class="editorFieldLabel" for="dropdownEditor_isUnique_cb">Is Unique</label>
            		<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_isUnique_cb">
            	</div>

            	<div class="editorField structureOptionField" fieldid="useSalts">
            		<label class="editorFieldLabel" for="dropdownEditor_useSalts_cb">Use Salts</label>
            		<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_useSalts_cb">
            	</div>

            	<div class="editorField structureOptionField" fieldid="structureBoxWidth">
            		<label class="editorFieldLabel">Structure Box Width (in pixels)</label>
            		<input type="text" class="editorFieldInput">
            	</div>

            	<div class="editorField structureOptionField" fieldid="structureBoxHeight">
            		<label class="editorFieldLabel">Structure Box Height (in pixels)</label>
            		<input type="text" class="editorFieldInput">
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
                    	Manage Fields
    	            </h4>
                    <div class="category manageRequestsTable_requestTypeDropdownContainer">
						<button class="newDropdownButton btn btn-white">New Field</button>
	                </div>
                </div>
    			
    			<div class="dropdownsTableContainer">
    				<table id="dropdownsTable" class="dropdownsTable dataTable" cellspacing="0">
    					<thead>
    						<th>Field Name</th>
    						<th>Hover Text</th>
    						<th>Data Type</th>
    						<th>Is Unique</th>
    						<th>Use Salts</th>
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
	$(document).ready(function(){
		$('.sidebarItem_adminConfiguration, .sidebarItem_manageFields').addClass('active');
        $('body').addClass('canMakeNewRequest');
	})
</script>

<script type="text/babel" src="js/React/fieldComponent.js?<%=jsRev%>"></script>
<script type="text/babel" src="js/editFields.js?<%=jsRev%>"></script>
<!-- #include file="../_inclds/footer.asp"-->
<% end if %>