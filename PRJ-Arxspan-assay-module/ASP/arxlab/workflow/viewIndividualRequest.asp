<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
sectionId = "workflow" 
pageTitle = "View Request - Arxspan Workflow"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header.asp"-->

<% if request.querystring("currentPageMode") = "custExp" then %>
	<script type="text/javascript">
		window.CurrentPageMode = "custExp"
		window.currApp = "ELN";
	</script>
<% else %>
	<script type="text/javascript">
		window.CurrentPageMode = "manageRequests"
		window.currApp = "Workflow";
	</script>
<% end if %>

<div id="arxWorkflowContainer">
	<div id="individualRequestContainer" class="individualRequestContainer"></div>
</div>

<script type="text/javascript">
var requestId = "<%=request.querystring("requestid")%>";
var requestRevId = "<%=request.querystring("revisionId")%>";
var requestTypeId = "<%=request.querystring("revisionId")%>";
	<% if request.querystring("duplicatingRequest") = "true" then %>
		window.duplicatingRequest = true;
	<% else %>
		window.duplicatingRequest = false;
	<% end if %>

var stripDown = "<%=request.querystring("base")%>" == "true";

</script>
<script type="text/javascript" src="js/viewIndividualRequest.min.js?<%=jsRev%>"></script>
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

if (window.top == window.self) {
	currApp = "Workflow"
}

$(document).ready(function(){
	$('body').addClass('pageWithIndividualRequestEditor');
})

</script>
<!-- #include file="_inclds/footer.asp"-->