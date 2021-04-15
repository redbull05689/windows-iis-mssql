<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% sectionId = "workflow" %>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header.asp"-->
<script>
	window.CurrentPageMode = "custExp"
	window.currApp = "ELN";
</script>

<div class="row">
    <div class="col-md-12">
        <div class="card">
			<div class="dropdownEditorContainer requestEditorContainer newRequestEditor nopadding" requestid="">			
				<div class="requestItemHolder">
					<div class="requestItem" itemnum="1">
						<div class="editorField" fieldid="requestType" style="display:none;">
							<label class="editorFieldLabel">Request Type</label>
							<select class="editorFieldDropdown requestTypeDropdown" id="requestTypeDropdown"></select>
						</div>

						<div class="editorField" fieldid="assignedUserGroup" style="display:none;">
							<label class="editorFieldLabel">Assigned User Group</label>
							<select class="editorFieldDropdown assignedUserGroupDropdown" id="assignedUserGroupDropdown"></select>
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
							<div class="editorSection card nopadding" sectionid="requestFields"></div>
						</div>

						<div class="requestFieldsSection" id="requestFieldsEditorSectionBottom">
							<div class="editorSection card nopadding" sectionid="requestFieldsBottom" id="requestFields1Bottom"></div>
						</div>
						<div class="requestItemsEditorSection"></div>

					</div>
				</div>

				<div class="bottomButtons">
					<button class="prioritizeNewRequestButton submitButton btn btn-success">Prioritize &amp; Submit</button>
				</div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript" src="<%=mainAppPath%>/js/mousetrap.min.js?<%=jsRev%>"></script>
<script type="text/javascript">

function bindSaveShortcut() {

	if (window.top != window.self) {
		if (window.parent.revisionId == "") {
			Mousetrap.bind(['command+s', 'ctrl+s'], function(e) {
				window.parent.clickSave();
				return false;
			});
			Mousetrap.stopCallback = function () {
				return false;
			}
		}	
	}
}

bindSaveShortcut();

</script>
<script type="text/javascript">
	window.makingNewRequest = true;
	$(document).ready(function(){
		$(".sidebar").hide();
		$(".main-panel").css('width','100%');
		$(".main-panel").css('float','initial');
		$('.sidebarItem_makeNewRequest').addClass('active');
		$('body').addClass('pageWithIndividualRequestEditor');
	})
</script>
<script type="text/javascript" src="js/makeNewRequest.js?<%=jsRev%>"></script>
<!-- #include file="_inclds/footer.asp"-->