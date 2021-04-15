<!-- #include virtual="/_inclds/sessionInit.asp" -->
<script type="text/javascript">
	window.CurrentPageMode = "editRequestTypes"
	window.currApp = "Configuration";
</script>
<%
isManageConfigurationPage = True
if requestTypePageMode <> "requestItemTypes" then
	requestTypePageMode = "requestTypes"
end if
if requestTypePageMode = "requestTypes" then
	requestType_requestItemType_singular = "Request Type"
	requestType_requestItemType_plural = "Request Types"
elseif requestTypePageMode = "requestItemTypes" then
	requestType_requestItemType_singular = "Request Item Type"
	requestType_requestItemType_plural = "Request Item Types"
end if
pageTitle = "Edit " & requestType_requestItemType_plural & " - Arxspan Workflow"
%>

<!-- #include file="../_inclds/globals.asp"-->
<% if showAdminPages then %>
<!-- #include file="../_inclds/header.asp"-->

<script type="text/javascript">
	window.requestTypePageMode = "<%=requestTypePageMode%>";
	$(document).ready(function(){
		$('.sidebarItem_adminConfiguration').addClass('active');
		if(window.requestTypePageMode == "requestTypes"){
			$('.sidebarItem_manageRequestTypes').addClass('active');
		}
		else{
			$('.sidebarItem_manageRequestItemTypes').addClass('active');
		}
        $('body').addClass('canMakeNewRequest');
	})
</script>

<div id="arxWorkflowContainer">
    <div class="row">
        <div class="col-md-12">
        	<div class="dropdownEditorContainer <%=requestTypePageMode%>Page card" requesttypeid="">
        		<div class="editorField" fieldid="displayName">
        			<input type="text" class="editorFieldInput">
        			<label class="editorFieldLabel"><%=requestType_requestItemType_singular%> Name</label>
        		</div>
        		<div class="editorField" fieldid="hoverText">
        			<input type="text" class="editorFieldInput">
        			<label class="editorFieldLabel">Hover Text</label>
        		</div>

				<div class="requestTypeAllowedAppsSection" id="requestTypeAllowedAppsEditorSection">
					<label class="editorSectionLabel">Allowed Applications</label>
					<div class="editorSection dropdownOption" sectionid="requestTypeAllowedApps">
						<div class="editorSectionTableContainer">
							<select id="requestTypeAllowedAppsSelect" multiple>
								<option class="requestTypeAllowedAppOption" value="1">ELN</option>
								<option class="requestTypeAllowedAppOption" value="2">Workflow</option>
								<option class="requestTypeAllowedAppOption" value="3">Assay</option>
								<option class="requestTypeAllowedAppOption" value="4">Registration</option>
								<option class="requestTypeAllowedAppOption" value="5">Inventory</option>
							</select>
						</div>
					</div>
				</div>

				<div class="requestTypeAttributeTable" id="requestTypeAttributeTable">
					<label class="editorSectionLabel">Custom Attributes</label>
					<div class="editorSection dropdownOption " sectionid="dropdownOptions">
					
						<div class="aboveEditorItemContainer">
							<div class="aboveEditorTableButtonsContainer">
								<button class="addCustomAttribute basicActionButton">+ Add Attribute</button>
							</div>
						</div>
        				<div class="editorSectionTableContainer dropdownOptionsTableContainer">	
        					<table class="editorSectionTable requestTypeCustomAttributesTable dataTable dropdownOptionsTable" id="requestTypeCustomAttributesTable">
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

				<div class="editorField" fieldid="requestNames" id="requestNamesDiv">
        			
					<a id="configRequestNameAccord" class="btn btn-info" data-toggle="collapse" href="#requestNameOptions" role="button" aria-expanded="false" aria-controls="requestNameOptionsCollapse">
						Configure Request Names
					</a>
        			
					<div class=" collapse" id="requestNameOptions">
						<div class="card-body">
							<!-- <input type="checkbox" class="editorFieldCheckbox" id="useString"> -->
        					<label for="useString" class="editorFieldLabel">Static Name</label>
							<br>
							<select id="staticNameSortOrder">
								<option value=null></option>
								<option value=1>1</option>
								<option value=2>2</option>
								<option value=3>3</option>
								<option value=4>4</option>
							</select>
							<input type="text" class="editorFieldInput inLine" id="staticNameString" maxlength="50" style="display: inline;">
						</div>

						<div class="card-body">
        					<label for="useAssignedGroup" class="editorFieldLabel">Use assigned user group</label>
							<br>
								<div class="togglebutton switch-sidebar-image">
									<label>
												<select id="groupSortOrder" style="color: black;">
													<option value=null></option>
													<option value=1>1</option>
													<option value=2>2</option>
													<option value=3>3</option>
													<option value=4>4</option>
												</select>
											<input type="checkbox" class="editorFieldCheckbox" id="useAssignedGroup">
									</label>
								</div>
						</div>

						<div class="card-body">
							<!--<input type="checkbox" class="editorFieldCheckbox" id="useField">-->
							<label for="useField" class="editorFieldLabel">Use Field in request</label>
							<br>
							<select id="fieldInNameSortOrder">
								<option value=null></option>
								<option value=1>1</option>
								<option value=2>2</option>
								<option value=3>3</option>
								<option value=4>4</option>
							</select>
							<select class="savedFieldDropdown fieldForName" id="requestNameSelectField"></select>
						</div>
			
						<div class="card-body">
							<!--<input type="checkbox" class="editorFieldCheckbox" id="useIncrementingNumbers">-->
        					<label for="useIncrementingNumbers" class="editorFieldLabel">Use incrementing numbers</label>
							<br>
						
							<select id="incromentingNumSortOrder">
								<option value=null></option>
								<option value=1>1</option>
								<option value=2>2</option>
								<option value=3>3</option>
								<option value=4>4</option>
							</select>
							<select class="savedFieldDropdown numbersBasedOffof" id="selectIncromentingNum"></select>
						</div>
					</div>
        		</div>
        		<div class="editorField" fieldid="requiresApproval" style="display: none">
        			<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_requiresApproval_cb">
        			<label class="editorFieldLabel" for="dropdownEditor_requiresApproval_cb">Requires Approval</label>
        		</div>
        		<div class="editorField" fieldid="isDefault">
        			<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_isDefault_cb">
        			<label class="editorFieldLabel" for="dropdownEditor_isDefault_cb">Is Default</label>
        		</div>
				<div class="editorField" fieldid="colabNotification">
        			<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_colabNotification_cb">
        			<label class="editorFieldLabel" for="dropdownEditor_colabNotification_cb">Notify Collaborators</label>
        		</div>
        		<div class="editorField" fieldid="restrictAccess">
        			<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_restrictAccess_cb">
        			<label class="editorFieldLabel" for="dropdownEditor_restrictAccess_cb">Restrict Access</label>
        		</div>
        		<div class="editorField" fieldid="showPrioritizationOnSubmit">
        			<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_showPrioritizationOnSubmit_cb">
        			<label class="editorFieldLabel" for="dropdownEditor_showPrioritizationOnSubmit_cb">Prioritize After Submission</label>
        		</div>
				<div class="editorField" fieldid="searchRegForExistingCompound">
        			<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_searchRegForExistingCompound_cb">
        			<label class="editorFieldLabel" for="dropdownEditor_searchRegForExistingCompound_cb">Search Registration For Compounds</label>
        		</div>
				<div class="editorField" fieldid="registerNewCompounds">
        			<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_registerNewCompounds_cb">
        			<label class="editorFieldLabel" for="dropdownEditor_registerNewCompounds_cb">Register New Compounds</label>
        		</div>
				<div class="card-body">
					<div class="editorField" fieldid="checkIfStructIsRequestedBeforeReg">
						<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_checkIfStructIsRequestedBeforeReg_cb">
						<label class="editorFieldLabel" for="dropdownEditor_checkIfStructIsRequestedBeforeReg_cb">Check if Structure is Requested Before Registering</label>
					</div>
				</div>

				<div class="editorField" fieldid="genNotebook">
				</div>
				<div class="editorField" fieldid="genProject">
				</div>

                <div class="editorSection requestTypeRestrictAccessSection card" sectionid="requestTypeEditorSection">
            		<div class="requestTypeAllowedUsersSection" id="requestTypeAllowedUsersEditorSection">
            			<label class="editorSectionLabel">Allowed Users</label>
						<div class="editRequestTabs">
							<div class="allowedUsers">
							</div>
							<div class="allowedUsersTabs">
							</div>
						</div>
            		</div>
            		<div class="requestTypeAllowedGroupsSection" id="requestTypeAllowedGroupsEditorSection">
            			<label class="editorSectionLabel">Allowed Groups</label>
						<div class="editRequestTabs">
							<div class="allowedGroups">
							</div>
							<div class="allowedGroupsTabs">
							</div>
						</div>
            		</div>
                </div>

                <div class="requestTypeReprioritizationNotificationsContainer">
					<button id="configRequestNotifications" class="btn btn-info" role="button">
						Configure Request Notifications
					</button>
                </div>

                <div class="editorField" fieldid="frozenColumnsLeft">
                    <label class="editorFieldLabel">Number of Frozen Columns in Table</label>
					<input type="number" min="0" max="3" step="1" class="editorFieldInput" id="numFrozenColumns"/>
                </div>

        		<div class="requestTypeFieldsSection" id="requestTypeFieldsEditorSection">
        			<label class="editorSectionLabel">Fields</label>
        			<div class="editorSection dropdownOption " sectionid="dropdownOptions">
					
						<div class="aboveEditorItemContainer">
							<div class="aboveEditorTableButtonsContainer">
								<button class="addSavedFieldButton basicActionButton">+ Add Field</button>
							</div>
						</div>
        				<div class="editorSectionTableContainer dropdownOptionsTableContainer">	
        					<table class="editorSectionTable requestTypeFieldsTable dataTable dropdownOptionsTable" id="requestTypeFieldsTable">
        						<thead>
									<th></th>
        							<th>Field</th>
        							<th id="requestTypeFieldGroupTableHeader">Field Group</th>
									<th id="requestTypeIncludeOnDash">Include in Manage Requests</th>
        							<th>Manage</th>
                                    <th></th>
									<th>Sorting</th>
        						</thead>
        						<tbody></tbody>
        					</table>
        				</div>
        			</div>
        		</div>


        		<div class="requestTypeRequestItemTypesSection" id="requestTypeRequestItemTypesEditorSection">
        			<label class="editorSectionLabel">Request Item Type(s)</label>
        			<div class="editorSection dropdownOption " sectionid="dropdownOptions">
        				<div class="aboveEditorTableButtonsContainer">
        					<button class="addRequestItemTypeButton basicActionButton">+ Add Request Item Type</button>
        				</div>
        				<div class="editorSectionTableContainer dropdownOptionsTableContainer">	
        					<table class="editorSectionTable requestTypeRequestItemTypesTable dataTable" id="requestTypeRequestItemTypesTable">
        						<thead>
        							<th>Request Item Type</th>
        							<th>Custom Name</th>
                                    <th>Minimum # of Items</th>
									<th>Delete items when editing</th>
        							<th></th>
        						</thead>
        						<tbody></tbody>
        					</table>
        				</div>
        			</div>
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
                    	Manage <%=requestType_requestItemType_plural%>
    	            </h4>
					<% if lcase(session("email")) = "support@arxspan.com" then %>
						<input type="text" class="asOfDate" id="getAsOfDateIn">
						<input type="time" class="asOfDate" id="asOfTime">
					<%end if%>
                    <div class="category manageRequestsTable_requestTypeDropdownContainer">
						<button class="newDropdownButton btn btn-white">New <%=requestType_requestItemType_singular%></button>
	                </div>
                </div>
    			
    			<div class="dropdownsTableContainer">
    				<table id="dropdownsTable" class="dropdownsTable dataTable" cellspacing="0">
    					<thead>
    						<th><%=requestType_requestItemType_singular%> Name</th>
    						<th>Hover Text</th>
    						<th>Fields</th>
    						<th>Restrict Access</th>
    						<th>Approval Required</th>
    						<th>Is Default</th>
    						<th>Status</th>
    					</thead>
    					<tbody></tbody>
    				</table>
    			</div>
    		</div>
    	</div>
    </div>
</div>


<script type="text/javascript" src="js/editRequestTypes.min.js?<%=jsRev%>"></script>
<script type="text/babel" src="js/React/notificationEditor.js?<%=jsRev%>"></script>
<script type="text/babel" src="js/React/notificationLoadingModule.js?<%=jsRev%>"></script>    
<script type="text/babel" src="js/React/notificationSubmitionModule.js?<%=jsRev%>"></script>    
<!-- #include file="../_inclds/footer.asp"-->
<% end if %>