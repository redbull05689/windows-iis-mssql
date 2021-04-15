<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
sectionId = "workflow" 
pageTitle = "Repeat Request - Arxspan Workflow"
inframe = request.querystring("inFrame")
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header.asp"-->
<div class="row">
    <div class="col-md-12">
        <div class="card">		
			<% if not inframe then %>
				<div class="card-header" data-background-color="materialblue">
					<h4 class="title">
						Submit New Request
					</h4>
				</div>
			<% end if %>
            <div id="individualRequestContainer" class="individualRequestContainer">
		
				<div class="duplicatingRequestNotice alert alert-warning" 
					<% if inframe then %>
						style="display:none;"
					<% end if %>
				>
					<span>You are making a new request based on <a class="duplicateRequestName" target="_blank"></a></span>
				</div>
				
				<div class="dropdownEditorContainer requestEditorContainer newRequestEditor duplicateRequestEditor<%If inframe Then%> nopadding<%End If%>" requestid="">
					<div class="editorField" fieldid="requestType" <%If inframe Then%>style="display:none;"<%End If%>>
						<label class="editorFieldLabel">Request Type</label>
						<select class="editorFieldDropdown requestTypeDropdown" id="requestTypeDropdown"></select>
					</div>

					<div class="editorField" fieldid="assignedUserGroup" <%If inframe Then%>style="display:none;"<%End If%>>
						<label class="editorFieldLabel">Assigned User Group</label>
						<select class="editorFieldDropdown assignedUserGroupDropdown" id="assignedUserGroupDropdown"></select>
					</div>
					
					<div class="groupAccessToRequestTypeSection" id="groupAccessToRequestTypeEditorSection" <%If inframe Then%>style="display:none;"<%End If%>>
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
						<label class="editorSectionLabel" <%If inframe Then%>style="display:none;"<%End If%>>Fields</label>
						<div class="editorSection card" sectionid="requestFields"></div>
					</div>

					<div class="requestItemsEditorSection"></div>

					<div class="bottomButtons">
						<button class="prioritizeNewRequestButton submitButton btn btn-success">Prioritize &amp; Submit</button>
						<button class="cancelNewRequestButton btn btn-danger">Cancel</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
	window.makingNewRequest = true;
	window.duplicatingRequest = true;
	
	<% if not inframe then %>
		window.CurrentPageMode = "repeatRequest";
	<% else %>
		window.CurrentPageMode = "custExp";
	<% end if %>
	window.currApp = "Workflow";

	$(document).ready(function(){

		if (window.top != window.self) {	
			$(".sidebar").hide();
			$(".main-panel").css('width','100%');
			$(".main-panel").css('float','initial');
		}

		$('.sidebarItem_makeNewRequest').addClass('active');
		$('body').addClass('pageWithIndividualRequestEditor');
	})
	window.duplicateRequestId = <%=request.querystring("requestid")%>;
</script>
<script type="text/javascript" src="js/makeNewRequest.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/repeatRequest.min.js?<%=jsRev%>"></script>
<!-- #include file="_inclds/footer.asp"-->