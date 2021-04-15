<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
sectionId = "workflow" 
pageTitle = "Make New Request - Arxspan Workflow"
%>

<!-- #include file="header2.asp"-->

<script type="text/javascript">
	window.CurrentPageMode = "makeNewRequest"
	window.currApp = "Workflow";
</script>

<div class="row">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header" data-background-color="materialblue">
                <h4 class="title">
                	Submit New Request
                </h4>
            </div>
			<div class="dropdownEditorContainer requestEditorContainer newRequestEditor" requestid="">
				<div class="requestItemHolder">
					<div class="requestItem" itemnum="1">
						<div class="editorField" fieldid="requestType">
							<label class="editorFieldLabel">Request Type</label>
							<select class="editorFieldDropdown requestTypeDropdown 1" id="requestTypeDropdown" itemnum="1"></select>
						</div>

						<div class="editorField" fieldid="assignedUserGroup">
							<label class="editorFieldLabel">Assigned User Group</label>
							<select class="editorFieldDropdown assignedUserGroupDropdown 1" id="assignedUserGroupDropdown"></select>
						</div>
						
						<div class="groupAccessToRequestTypeSection" id="groupAccessToRequestTypeEditorSection">
							<label class="editorSectionLabel">Assigned group has conflicts with request type</label>
							<div class="editorSection" sectionid="groupAccessToRequestType">
								<table class="groupAccessToRequestTypeTable table table-bordered table-hover" id="groupAccessToRequestTypeTable">
									<thead>
										<tr>
											<th>Field name</th>
											<th>Error message</th>
										</tr>
									</thead>
									<tbody></tbody>
								</table>
							</div>
						</div>

						<div class="requestFieldsSection<%If inframe Then%> inIframe<%End If%>" id="requestFieldsEditorSection">
							<label class="editorSectionLabel">Fields</label>
							<div class="editorSection card" sectionid="requestFields" id="requestFields1"></div>
						</div>

						<div class="requestItemsEditorSection 1"></div>
					</div>
				</div>
				<div class="bottomButtons">
					<button class="prioritizeNewRequestButton submitButton btn btn-success"></button>
					<button class="cancelNewRequestButton btn btn-danger"></button>
				</div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
	window.makingNewRequest = true;
	$(document).ready(function(){
		$('.sidebarItem_makeNewRequest').addClass('active');
		$('body').addClass('pageWithIndividualRequestEditor');

		requestEditorHelper.insertRequestFieldsToggle();
	})
</script>
<script type="text/javascript" src="js/makeNewRequest.min.js?<%=jsRev%>"></script>
<!-- #include file="_inclds/footer.asp"-->