<!-- #include file="_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/jsRev.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
Response.CharSet = "UTF-8"
%>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title><%=pageTitle%></title>
<meta name="description" content="<%=metaDesc%>" />
<meta name="keywords" content="<%=metaKey%>" />
<link href="<%=mainCSSPath%>/latofont.css?<%=jsRev%>" rel="stylesheet" type="text/css">

<script type="text/javascript" src="js/jquery-1.11.1.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../common/bootstrap-3.3.5/js/bootstrap.js?<%=jsRev%>"></script>
<script type="text/javascript">
	var jwt = "<%=session("jwtToken")%>";
	$( document ).ready(function() 
	{
		var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");
        var edge = ua.indexOf("Edge");
    	if (edge > 0 || msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) 
    	{
 			window.top.swal(
			{
        	title: "",
        	text: "Workflow is not supported in the current browser, navigate back to dashboard.",
        	type: "error",
        	confirmButtonText: "Return to Dashboard!",
      		},
			function(isConfirm)
			{
				window.top.window.location.replace("<%=mainAppPath%>/dashboard.asp");
			} 
			);
    	}
	
	});
</script>
<!-- #include file="../_inclds/__whichServer.asp"-->
<%
	If whichServer <> "DEV" Then
%>
<script type="text/javascript" src="js/disableConsole.js?<%=jsRev%>"></script>
<%
	End if
%>
<!-- #include file="getGlobalUserInfo.asp"-->
<!-- #include file="getUsersAndUserGroups.asp"-->
<script type="text/javascript">
connectionId = '<%=session("servicesConnectionId")%>';
globalUserInfo = JSON.parse('<%=userInfo%>');
usersList = JSON.parse(`<%=userArray%>`);
groupsList = JSON.parse(`<%=groupArray%>`);
companyId = globalUserInfo["companyId"];
haseln="<%=session("hasELN")%>"
hasordering="<%=session("hasOrdering")%>"
hasreg="<%=session("hasReg")%>"
hasinv="<%=session("hasInv")%>"
hasassay="<%=session("hasAssay")%>"
workflowServiceEndpointUrl="<%=getCompanySpecificSingleAppConfigSetting("workflowServiceEndpointUrl", session("companyId"))%>"
</script>

<link href="<%=mainAppPath%>/js/select2-3.5.1/select2.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=mainAppPath%>/js/select2-3.5.1/select2.js?<%=jsRev%>"></script>

<script type="text/javascript" src="js/serviceEndpoints.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../util/resumableFunctions.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/workflowUtilities.min.js?<%=jsRev%>"></script>
<!-- #include file="_inclds/fetchDataTypes.asp"-->
<script type="text/javascript" src="js/requestItemTableHelpers.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/requestFieldHelper.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/elnAutomation.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../js/resumableModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jquery.csv.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../js/resumable.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/dataTableModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/tableFileUploadModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/fieldsModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/requestEditorModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/ajaxModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/arxWorkflow.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/sdFileModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/BiIntegration/biIntegration.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/md5-min.js"></script>

<script src="js/dynatree/jquery/jquery-ui.custom.js?<%=jsRev%>" type="text/javascript"></script>
<script src="js/dynatree/jquery/jquery.cookie.js?<%=jsRev%>" type="text/javascript"></script>

<link rel="stylesheet" href="js/React/react-table.css">
<!-- #include file="_inclds/reactIncludes.asp"-->
<script src="js/React/babel6.min.js" charset="utf-8"></script>

<script type="text/babel" src="js/React/commonReactElements.js?<%=jsRev%>"></script>
<script type="text/babel" src="js/React/notificationComponent.js?<%=jsRev%>"></script>
<link rel="stylesheet" href="js/React/notificationComponent.css">


<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../_inclds/CKE/CKE5-Standard-Editing/build/ckeditor.js?<%=jsRev%>"></script>
<script type="text/javascript">

function _base64ToArrayBuffer(base64) {
	return _base64ToArray(base64).buffer;
}

function _base64ToArray(base64) {
	var binary_string = window.atob(base64);
	var len = binary_string.length;
	var bytes = new Uint8Array( len );
	for (var i = 0; i < len; i++)        {
		bytes[i] = binary_string.charCodeAt(i);
	}
	return bytes;
}

	<%If session("useChemDrawForLiveEdit") Then%>
		useChemDrawForLiveEdit = true;
	<%End If%>
	hasMarvin = <%=LCase(CStr(session("useMarvin")))%>
	var changeObj = {}
  	var originalObj = {}
</script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript">
	inputData = {
	"connectionId": connectionId,
	"userId": <%=session("userId")%>,
	'whichClient':'<%=replace(whichClient,"'","\'")%>'
}

</script>

<% if lcase(session("email")) = "support@arxspan.com" then %>
<script> var isSupport = true; </script>
<% else %>
<script> var isSupport = false; </script>
<% end if %>

<script type="text/javascript" src="../common/popper.js-1.12.3/dist/umd/popper.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../common/bootstrap-3.3.5/js/bootstrap.js?<%=jsRev%>"></script>
<link href="../common/bootstrap-3.3.5/css/bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">

<link href="css/jquery.dataTables.1.10.15.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="css/dataTables.1.10.15.bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/jquery.dataTables.1.10.15.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/dataTables.1.10.15.bootstrap.min.js?<%=jsRev%>"></script>

<script type="text/javascript" src="js/dataTableSortModule.min.js?<%=jsRev%>"></script>

<link href="css/rowReorder.bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/dataTables.rowReorder.js?<%=jsRev%>"></script>

<link href="css/fixedHeader.bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/dataTables.fixedHeader.min.js?<%=jsRev%>"></script>

<link href="css/fixedColumns.bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/dataTables.fixedColumns.min.js?<%=jsRev%>"></script>

<link href="css/jquery.dataTables.yadcf.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/jquery.dataTables.yadcf.js?<%=jsRev%>"></script>

<link href="../js/sweetalert1/sweetalert.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="../js/sweetalert1/sweetalert.min.js?<%=jsRev%>"></script>

<script type="text/javascript" src="js/moment-with-locales.js?<%=jsRev%>"></script>
<script src="../js/moment.min.js"></script>
<script src="../js/datetime-moment.js"></script>

<% if session("companyId") = 111 and whichServer = "BETA" or session("companyId") = 99 and whichServer = "MODEL" then %>
<script> var boeh = true; </script>
<% else %>
<script> var boeh = false; </script>
<% end if %>

<link href="../css/pikaday.1.6.1.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<!-- Load pikaday.js and then its jQuery plugin -->
<script type="text/javascript" src="../js/pikaday.1.6.1.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../js/pikaday.1.6.1.jquery.js?<%=jsRev%>"></script>

<link href="<%=mainCSSPath%>/styles-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">

<link href="css/material-dashboard.css" rel="stylesheet"/>
<link href="css/font-awesome.min.css" rel="stylesheet">
<link href="css/material-dashboard.roboto-with-icons.css" rel="stylesheet" type="text/css">
<script src="js/material.min.js" type="text/javascript"></script>
<script src="js/bootstrap-notify.js?<%=jsRev%>"></script>
<script src="js/material-dashboard.js?<%=jsRev%>"></script>
<!-- #include file="../_inclds/common/asp/checkLoginAndResetInactivityTimer.asp"-->

<div class="wrapper">
    <div class="sidebar" data-color="materialblue">

		<!--
	        Tip 1: You can change the color of the sidebar using: data-color="purple | blue | green | orange | red"

	        Tip 2: you can also add an image using data-image tag
	    -->
	    <!--
		<div class="logo">
			<a href="http://www.creative-tim.com" class="simple-text">
				Arxspan
			</a>
		</div>
		-->
				
    	<div class="sidebar-wrapper">
            <ul class="nav">
			    <li class="sidebarItem_eln_dashboard">
                    <a href="/arxlab/dashboard.asp">
                        <i class="material-icons">A</i>
                        <p>Main Menu</p>
                    </a>
							
						<ul class="nav sub-nav">
							<li class="sidebarItem_eln_dashboard_link elnSidebar">
								<a href="/arxlab/dashboard.asp">
									<i class="material-icons">dashboard</i>
									<p>Dashboard</p>
								</a>
							</li>
							<li class="sidebarItem_ELNWatchlist elnSidebar">
								<a href="/arxlab/table_pages/show-watchlist.asp">
									<i class="material-icons">content_paste</i>
									<p>Watchlist</p>
								</a>
							</li>
							<li class="sidebarItem_ELNNotebooks elnSidebar">
								<a href="/arxlab/table_pages/show-notebooks.asp?all=true">
									<i class="material-icons">library_books</i>
									<p>Notebooks</p>
								</a>
							</li>
							<li class="sidebarItem_ELNProjects elnSidebar">
								<a href="/arxlab/table_pages/show-projects.asp">
									<i class="material-icons">timeline</i>
									<p>Projects</p>
								</a>
							</li>
							<li class="sidebarItem_contactSupport elnSidebar">
								<a href="/arxlab/support-request.asp">
									<i class="material-icons">help</i>
									<p>CONTACT SUPPORT</p>
								</a>
							</li>
							<li class="sidebarItem_logout elnSidebar">
								<a href="/arxlab/logout.asp">
									<i class="material-icons">arrow_back</i>
									<p>Logout</p>
								</a>
							</li>
						</ul>

                </li>
                <li class="sidebarItem_dashboard">
                    <a href="<%=mainAppPath%>/workflow/">
                        <i class="material-icons">dashboard</i>
                        <p>My Requests</p>
                    </a>
                </li>
                <li class="sidebarItem_makeNewRequest">
                    <a href="makeNewRequest.asp">
                        <i class="material-icons">add</i>
                        <p>Submit New Request</p>
                    </a>
                </li>
                <li class="sidebarItem_manageRequests">
                    <a href="manageRequests.asp">
                        <i class="material-icons">content_paste</i>
                        <p>Manage Requests</p>
                    </a>
                </li>
			</ul>
	
			<ul class="nav separatingLineAbove">
				<li class="sidebarItem_userSettings">
					<a href="userSettings.asp">
	                    <i class="material-icons">person</i>
	                    <p>User Settings</p>
		    		</a>
		    	</li>
		    </ul>
			<ul id="workflowAdminNavMenu" class="nav" <% if session("role") <> "Admin" and session("manageWorkflow") = false then %>style="display:none;"<%End If%>>
                <li class="sidebarItem_adminConfiguration">
                    <a href="#" class="" aria-expanded="true">
                        <i class="material-icons">settings</i>
                        <p>Admin Configuration</p>
                    </a>
                    <div class="collapse in" aria-expanded="true" style="">
                        <ul class="nav">
                            <li class="sidebarItem_manageDropdowns">
                                <a href="manageConfiguration/editDropdowns.asp">
                                    <span class="sidebar-mini">D</span>
                                    <span class="sidebar-normal">Dropdowns</span>
                                </a>
                            </li>
                            <li class="sidebarItem_manageFields workflowAdminFields">
                                <a href="manageConfiguration/editFields.asp">
                                    <span class="sidebar-mini">F</span>
                                    <span class="sidebar-normal">Fields</span>
                                </a>
                            </li>
                            <li class="sidebarItem_manageRequestTypes workflowAdminFields">
                                <a href="manageConfiguration/editRequestTypes.asp">
                                    <span class="sidebar-mini">RT</span>
                                    <span class="sidebar-normal">Request Types</span>
                                </a>
                            </li>
                            <li class="sidebarItem_manageRequestItemTypes workflowAdminFields">
                                <a href="manageConfiguration/editRequestItemTypes.asp">
                                    <span class="sidebar-mini">RIT</span>
                                    <span class="sidebar-normal">Request Item Types</span>
                                </a>
                            </li>
                        </ul>
                    </div>
                </li>
            </ul>
    	</div>
	</div>
	<div id="BioDiv"></div>
    <div class="main-panel">
		<% if not inFrame then %>
			<nav class="navbar navbar-transparent navbar-absolute">
				<div class="container-fluid">
					<div class="navbar-header">
						<button type="button" class="navbar-toggle" data-toggle="collapse">
							<span class="sr-only">Toggle navigation</span>
							<span class="icon-bar"></span>
							<span class="icon-bar"></span>
							<span class="icon-bar"></span>
						</button>
						<a class="navbar-brand" href="#">Workflow</a>
					</div>
					
					<ul class="nav navbar-nav navbar-right notificationsSectionUL">
						<li class="dropdown">
							<a href="#" class="dropdown-toggle notifications-dropdown-toggle" data-toggle="dropdown" id="notificationsDropdownToggle">
								<i class="material-icons">notifications</i>
								<span class="notification"></span>
								<span id="reactNotificationCount">0</span>
							</a>
						</li>
						<div id="reactNotificationHolder"></div>
					</ul>
				</div>
			</nav>
		<% end if %>

        <% if not inFrame then %>
        <div class="content">
            <div class="container-fluid">
        <% else %>
        <div class="content nopadding">
            <div class="container-fluid nopadding">
        <% end if %>


<link href="css/workflowStyles.css" rel="stylesheet" type="text/css" MEDIA="screen">

<%
	if whichServer = "DEV" then
%>
	<style>
		*[dirty=true] {
			color: red;
			background-color: magenta;
		}
	</style>
<%
	end if
	workflowexcelimportparentrowindcolname = getCompanySpecificSingleAppConfigSetting("workflowExcelImportParentRowIndColName", session("companyId"))
%>
<script>
  isWorkflowManager = "<%=session("isWorkflowManager")%>" == "true";
  excelImportParentRow = "<%=workflowexcelimportparentrowindcolname%>";
</script>
</head>