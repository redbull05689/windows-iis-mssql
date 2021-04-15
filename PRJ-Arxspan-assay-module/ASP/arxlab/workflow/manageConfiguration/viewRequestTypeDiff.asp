<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%

if session("email") <> "support@arxspan.com" then
    response.redirect mainAppPath & "/dashboard.asp"
end if

isManageConfigurationPage = True
requestTypePageMode = "requestTypes"
pageTitle = "View Request Type Diff - Arxspan Workflow"

requestTypeId = request.querystring("id")
asOfDate = request.querystring("r")

%>

<!-- #include file="../_inclds/globals.asp"-->
<% if showAdminPages then %>
<!-- #include file="../_inclds/header.asp"-->

<script type="text/javascript">
	window.requestTypePageMode = "<%=requestTypePageMode%>";
	$(document).ready(function(){
		$('.sidebarItem_adminConfiguration').addClass('active');
        $('body').addClass('canMakeNewRequest');
	})

	var currApp = `Workflow`;
	var requestTypeId = `<%=requestTypeId%>`;
	var asOfDate = `<%=asOfDate%>`;
</script>

<div id="arxWorkflowContainer">
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header" data-background-color="materialblue">
                    <h4 class="card-title">
                    	View Request Type Diff
    	            </h4>
                </div>
				<div id="diffViewer">
				</div>
    		</div>
    	</div>
    </div>
</div>

<script type="text/babel" src="js/viewRequestTypeDiff.js?<%=jsRev%>"></script>
<link rel="stylesheet" href="css/viewRequestTypeDiff.css">
<script src="js/diff.min.js?<%=jsRev%>"></script>
<!-- #include file="../_inclds/footer.asp"-->
<% end if %>