			</div>
		</div>
	</div>
</div>

<div class="modal fade in" id="requestEditorModal" role="dialog">
    <div class="modal-dialog">
      	<!-- Modal content-->
      	<div class="modal-content">
	        <!--
	        <div class="modal-header">
	        	<button type="button" class="close" data-dismiss="modal">×</button>
	        	<h4 class="modal-title">Modal Header</h4>
	        </div>
	       	-->
	        <div class="modal-body">
	        	<p>Loading...</p>
	        </div>
	        <div class="modal-footer">
	        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			</div>
		</div>
	</div>
</div>

<div class="modal fade in" id="prioritizeThisRequestTableModal" role="dialog" data-backdrop="static">
    <div class="modal-dialog">
      	<!-- Modal content-->
      	<div class="modal-content card">
	        <div class="card-header" data-background-color="materialblue">
				<h4 class="title">Prioritize Your Request</h4>
			</div>
			<div class="prioritizeRequestsWithStructurePreviewList">
				<div class="prioritizeThisRequestOuterContainer">
					<div class="prioritizeThisRequestColumnHeaders">
						<div class="columnHeader_Priority">Priority</div>
						<div class="columnHeader_requestName">Request Name</div>
						<div class="columnHeader_requestDate">Date Submitted</div>
						<div class="columnHeader_numberOfItems"># of Items</div>
						<div class="columnHeader_previewStructures">Preview Structures</div>
					</div>
					<div class="prioritizeThisRequestContainer">
						<table id="prioritizeThisRequestTable" class="dataTable" cellspacing="0">
							<tbody class="ui-sortable">
								<tr class="thisNewRequestRow">
									<td colspan="4">
										<div class="thisNewRequestRowText">THIS NEW REQUEST</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<div class="requestItemStructurePreviewListContainer">
					<ul class="requestItemStructurePreviewList">
						<li class="loadingSpinnerHolder">
							<div class="blueLoadingSpinner"></div>
							<div class="loadingSpinnerText">Loading...</div>
						</li>
					</ul>
				</div>
			</div>
			<div class="bottomButtons">
				<button class="requestEditorSubmitNewRequest btn btn-success">Submit Request</button>
				<button id="cancelPrioritizeNewRequestBtn" type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
			</div>
		</div>
	</div>
</div>

<div class="modal fade in" id="basicLoadingModal" role="dialog" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog">
      	<!-- Modal content-->
      	<div class="modal-content card">
	        <div class="modal-body">
				<div class="blueLoadingSpinner"></div>
		        <div class="loadingText">Loading...</div>
	        </div>
	        <div class="modal-footer"></div>
		</div>
	</div>
</div>


    <div id="modalDialog" class="modal-dialog" style="display: none; z-index: 999999999999999999999;">
      	<!-- Modal content-->
      	<div class="modal-content card">
	        <div class="modal-body">
				
	        </div>
	        <div class="modal-footer"></div>
		</div>
	</div>


<div class="modal fade in" id="commentsModal" role="dialog" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog">
      	<!-- Modal content-->
		<div class="modal-content card">
		  	<h3 class="modal-header">Department</h3>
	        <div class="modal-body" id="comment-body">
				<div class="comment">
					<h4 class="modal-title">Loading...</h4>
					<div>Testing a comment</div>
				</div>
				<div class="comment">
					<h4 class="modal-title">Loading...</h4>
					<div>Testing a comment</div>
				</div>
				<div class="comment">
					<h4 class="modal-title">Loading...</h4>
					<div>Testing a comment</div>
				</div>
				<div class="comment">
					<h4 class="modal-title">Loading...</h4>
					<div>Testing a comment</div>
				</div>
				<div class="comment">
					<h4 class="modal-title">Loading...</h4>
					<div>Testing a comment</div>
				</div>
	        </div>
	        <div class="modal-footer">			
				<div class="commentersList" id="commentersList">
					<li>Test</li>
					<li>Test2</li>
				</div>
				<div class="form-group">
					<textarea class="form-control comment-input" rows="3" id="comment-field" placeholder="Enter comment here (use '@collaborators' to message all collaborators)..." style="background-image: linear-gradient(60deg, #2196F3, #4285f4);"></textarea>
					<button class="btn comment-submit btn-success btn-sm">                            
						<span>Send</span>
					</button>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="modal fade in" id="fileImportModal" role="dialog" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<h3>Select where to add file contents</h3>
			<div class="fileImportRadioSelector">
				<div class="fileImportRadioButton">
					<input type="radio" name="fileImportSelect" id="beforeSelect" class="defaultSettingButton" value="Before" checked>
					<label for="beforeSelect" class="defaultSettingLabel">Before Existing Rows</label>
				</div>
				<div class="fileImportRadioButton">
					<input type="radio" name="fileImportSelect" id="afterSelect" class="defaultSettingButton" value="After">
					<label for="afterSelect" class="defaultSettingLabel">After Existing Rows</label>
				</div>
				<div class="fileImportRadioButton">
					<input type="radio" name="fileImportSelect" id="deleteSelect" class="defaultSettingButton" value="Delete">
					<label for="deleteSelect" class="defaultSettingLabel">Delete Existing Rows</label>
				</div>
				<div class="fileImportRadioButton">
					<input type="checkbox" id="rememberImportSetting" class="defaultSettingButton" value="Delete">
					<label for="rememberImportSetting" class="defaultSettingLabel">Remember My Selection</label>
				</div>
			</div>
			<div class="modal-footer">
				<div class="form-group">
					<button class="btn file-upload-setting-submit btn-success btn-sm">                            
						<span>Submit</span>
					</button>
					<button class="btn file-upload-setting-cancel btn-danger btn-sm">                            
						<span>Cancel</span>
					</button>
				</div>
			</div>
		</div>
	</div>
</div>


<div class="modal fade in" id="requestTypeFieldEditorModal" role="dialog">
    <div class="modal-dialog">
      	<!-- Modal content-->
      	<div class="modal-content">

      		<div class="dropdownEditorContainer">
				<div class="requestTypeFieldAttributeTable" id="requestTypeFieldAttributeTable">
					<label class="editorSectionLabel">Custom Attributes</label>
					<div class="editorSection dropdownOption " sectionid="dropdownOptions">
					
						<div class="aboveEditorItemContainer">
							<div class="aboveEditorTableButtonsContainer">
								<button class="addFieldCustomAttribute basicActionButton">+ Add Attribute</button>
							</div>
						</div>
						<div class="editorSectionTableContainer dropdownOptionsTableContainer">	
							<table class="editorSectionTable requestTypeFieldCustomAttributesTable dataTable dropdownOptionsTable" id="requestTypeFieldCustomAttributesTable">
								<thead>
									<tr>
										<th>Attribute</th>
										<th>Description</th>
										<th>Data Type</th>
										<th>Value</th>
										<th>Delete</th>
									</tr>
								</thead>
								<tbody class="" style=""></tbody>
							</table>
						</div>
					</div>
				</div>

	        	<div class="modalTitleFixed"></div>
	        	<div class="editorField" fieldid="requestTypeFieldIsRequired">
	        		<label class="editorFieldLabel">Required</label>
	        		<input type="checkbox" class="editorFieldCheckbox requestTypeFieldIsRequired">
	        	</div>
	        	<div class="editorField" fieldid="requestTypeFieldAllowMultiple">
	        		<label class="editorFieldLabel">Allow Multiple Values</label>
	        		<input type="checkbox" class="editorFieldCheckbox requestTypeFieldAllowMultiple">
	        	</div>
	        	<div class="editorField" fieldid="requestTypeFieldIsDisabled">
	        		<label class="editorFieldLabel">Disabled</label>
	        		<input type="checkbox" class="editorFieldCheckbox requestTypeFieldIsDisabled">
	        	</div>
	        	<div class="editorField" fieldid="requestTypeFieldRestrictAccess">
	        		<label class="editorFieldLabel">Restrict Access</label>
	        		<input type="checkbox" class="editorFieldCheckbox requestTypeFieldRestrictAccess">
	        	</div>
	        	<div class="editorField" fieldid="requestTypeFieldClearWhenDuplicate">
	        		<label class="editorFieldLabel">Clear When Duplicating Request</label>
	        		<input type="checkbox" class="editorFieldCheckbox requestTypeFieldClearWhenDuplicate">
	        	</div>
	        	<div class="editorField" fieldid="requestTypeFieldAutoGenNotebook" style="display: none;">
	        		<label class="editorFieldLabel">Automatically Generate Notebook</label>
	        		<input type="checkbox" class="autoGenCheck editorFieldCheckbox requestTypeFieldAutoGenNotebook">
	        	</div>
	        	<div class="editorField" fieldid="requestTypeFieldAutoGenProject" style="display: none;">
	        		<label class="editorFieldLabel">Automatically Generate Project</label>
	        		<input type="checkbox" class="autoGenCheck editorFieldCheckbox requestTypeFieldAutoGenProject">
	        	</div>
				<div class="editorField" fieldid="requestTypeFieldAutoGenExperiment" style="display: none;">
	        		<label class="editorFieldLabel">Automatically Generate experiment</label>
	        		<input type="checkbox" class="autoGenCheck editorFieldCheckbox requestTypeFieldAutoGenExperiment">
	        	</div>
				<div class="editorField" fieldid="requestTypeFieldBiDirectinalLink" style="display: none;">
	        		<label class="editorFieldLabel">Link Request from ELN</label>
	        		<input type="checkbox" class="biLinkCheck editorFieldCheckbox requestTypeFieldBiDirectinalLink">
	        	</div>
				<div class="editorField" fieldid="requestTypeFieldSendToELN" style="display: none;">
	        		<label class="editorFieldLabel">Allow Files to be Sent to the ELN</label>
	        		<input type="checkbox" class="sendToELNCheck editorFieldCheckbox requestTypeFieldSendToELN">
	        	</div>

	        	<div class="editorSection requestTypeFieldRestrictAccessSection card" sectionid="requestTypeFieldRestrictAccessEditorSection">
	        		<div class="requestTypeFieldRestrictionsContainer">
	        			<div class="requestTypeFieldAllowedUsersSection" id="requestTypeFieldAllowedUsersEditorSection">
	        				<label class="editorSectionLabel">Allowed Users</label>
	        				<div class="editorSection dropdownOption" sectionid="requestTypeFieldAllowedUsers">
	        					<div class="editorSectionTableContainer">	
	        						<table class="editorSectionTable restrictAccessTable requestTypeFieldAllowedUsersTable dataTable" id="requestTypeFieldAllowedUsersTable">
	        							<thead>
	        								<th></th>
	        								<th>Can Add</th>
	        								<th>Can View</th>
	        								<th>Can Edit</th>
	        								<th>Can Delete</th>
	        							</thead>
	        							<tbody></tbody>
	        						</table>
	        					</div>
	        				</div>
	        			</div>
	        			<div class="requestTypeFieldAllowedGroupsSection" id="requestTypeFieldAllowedGroupsEditorSection">
	        				<label class="editorSectionLabel">Allowed Groups</label>
	        				<div class="editorSection dropdownOption" sectionid="requestTypeFieldAllowedGroups">
	        					<div class="editorSectionTableContainer">
	        						<table class="editorSectionTable restrictAccessTable requestTypeFieldAllowedGroupsTable dataTable" id="requestTypeFieldAllowedGroupsTable">
	        							<thead>
	        								<th></th>
	        								<th>Can Add</th>
	        								<th>Can View</th>
	        								<th>Can Edit</th>
	        								<th>Can Delete</th>
	        							</thead>
	        							<tbody></tbody>
	        						</table>
	        					</div>
	        				</div>
	        			</div>
	        		</div>
	        	</div>
				
	        	<div class="editorField" fieldid="requestTypeFieldDefaultValue">
	        		<label class="editorFieldLabel">Company Default Value</label>
					<input class="defaultValueInput company" type="text"><select class="defaultValueDropdown defaultEditorDropdown company"></select>
					<div class="editorSection requestTypeFieldDefaultEditor card" sectionid="requestTypeEditorSection">
						<div class="requestTypeUserDefaultsSection" id="requestTypeAllowedUsersEditorSection">
							<label class="editorSectionLabel">User Defaults</label>
							<div class="editRequestTabs">
								<div class="userDefaults">
								</div>
								<div class="userDefaultsTabs">
								</div>
							</div>
						</div>
						<div class="requestTypeGroupDefaultsSection" id="requestTypeAllowedGroupsEditorSection">
							<label class="editorSectionLabel">Group Defaults</label>
							<div class="editRequestTabs">
								<div class="groupDefaults">
								</div>
								<div class="groupDefaultsTabs">
								</div>
							</div>
						</div>
					</div>
	        	</div>

				<br>
				<div class="editorSectionTableContainer" id="filterSection">
	        		<label class="editorFieldLabel">Filter Value Managment</label>
					<div class="filterValueManagementSection">
	        			<div class="editorSection dropdownOption" sectionid="filterValueManagementSection">
							<div class="aboveEditorTableButtonContainer">
	        					
	        				</div>
	        				<div class="editorSectionTableContainer">
	        					<table class="editorSectionTable dataTable" id="filterValueManagmentTable">
									<thead></thead>
									<tbody></tbody>
								</table>
	        				</div>
	        			</div>
	        		</div>
				</div>



	     
				<div class="editorSectionTableContainer dependencyEditor">
	        		<label class="editorFieldLabel">Relational Dependencies</label>
					<div class="requestTypeDropdownDependenciesSection" id="requestTypeDropdownDependenciesSection">
	        			<div class="editorSection dropdownOption" sectionid="requestTypeDropdownDependencies">
							<div class="aboveEditorTableDependencyButtonContainer aboveEditorTableDependencyButtonContainer">
	        					<button class="addDependencyButton basicActionButton">+ Add Dependency</button>
	        				</div>
	        				<div class="editorSectionTableContainer">
	        					<table class="editorSectionTable dropdownDependencyTable dataTable" id="dropdownDependencyTable">
									<thead>
										<th>Source Value</th>
										<th>Target</th>
										<th>Target Values</th>
										<th>Delete</th>
									</thead>
									<tbody class="dropdownDependencyBody"></tbody>
								</table>
	        				</div>
	        			</div>
	        		</div>
				</div>
	        	<div class="bottomButtons">
	        		<button class="requestTypeFieldEditorSubmit submitButton btn btn-success">Update Field</button>
	        		<button class="requestTypeFieldEditorCancel cancelButton btn btn-danger">Cancel Changes</button>
	        	</div>
	        </div>
		</div>
	</div>
</div>

<div id="reactTest"></div>

<div class="modal fade in" id="reprioritizationRequestItemTypeNotificationSettingsModal" role="dialog">
    <div class="modal-dialog">
      	<!-- Modal content-->
      	<div class="modal-content card">
	        <!--
	        <div class="modal-header">
	        	<button type="button" class="close" data-dismiss="modal">×</button>
	        	<h4 class="modal-title">Modal Header</h4>
	        </div>
	       	-->
	        <div class="modal-body">
	        	<div class="notificationsContainerTitle">Reprioritization Notifications for <span class="reprioritizationRequestItemTypeNameContainer"></span></div>
                <div class="requestItemReprioritizationNotificationsSection" id="requestItemReprioritizationNotificationsEditorSection">
                    <div class="editorSection dropdownOption" sectionid="requestItemReprioritizationNotifications">
                        <div class="editorSectionTableContainer">
                            <table class="editorSectionTable requestItemReprioritizationNotificationsTable dataTable" id="requestItemReprioritizationNotificationsTable">
                                <thead>
                                    <th>User Group</th>
                                    <th>Email</th>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="bottomButtons">
                	<button class="submitUpdateButton btn btn-success">Update Notification Settings</button>
                	<button class="cancelChangesButton btn btn-danger">Cancel Changes</button>
                </div>
	        </div>
		</div>
	</div>
</div>

<div class="modal fade in" id="moveFilesModal" role="dialog" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<h3>Select files to send to an experiment</h3>
			<input
				type="text"
				class="searchForExperement select2-offscreen sendToExperimentSelect2"
				id="workflowFileExperimentSearch"
				name="workflowFileExperimentSearch"
				title="Search for Experiment"
			/>
			<div id="moveFilesSelectorSection" class="fileImportRadioSelector">
			</div>
			<div class="modal-footer">
				<div class="form-group">
					<button class="btn send-file-submit-btn btn-success btn-sm">                            
						<span>Send Selected Files</span>
					</button>
					<button class="btn cancel-send-btn btn-sm">                            
						<span>Cancel</span>
					</button>
				</div>
			</div>
		</div>
	</div>
</div>

</body>
<script>
	<% If inFrame then %>
		// hack to remove white space from this page when there's no header.
		$(".content").css("margin-top", "0px")
		// hack to remove bottom buttons
		$(".bottomButtons").css("display", "none")
	<% end if %>

		// Check to see if the user has made any requests and show the My Requests link if they have.
		ajaxModule().checkIfUserHasMadeRequests();
</script>
</html>