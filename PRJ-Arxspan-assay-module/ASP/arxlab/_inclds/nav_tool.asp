<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
hasExperimentsTreeInNav = getCompanySpecificSingleAppConfigSetting("canUseExperimentsTreeInNavTool", session("companyId"))
hasCommentDeleteButtons = getCompanySpecificSingleAppConfigSetting("hasCommentDeleteButtons", session("companyId"))
hasCommentReplyButton = getCompanySpecificSingleAppConfigSetting("hasCommentReplyButton", session("companyId"))
showNewReactHistoryPageLinks = getCompanySpecificSingleAppConfigSetting("showNewReactHistoryPageLinks", session("companyId"))
%>
<script language="JScript" src="/arxlab/js/json2.asp" runat="server"></script>
<table class="contentTable" style="min-height:650px;height:650px;">
	<tr>
	<td class="pageNav pageNavTD" valign="top">
		<%If thisSectionId = "eln" then%>
		<div class="searchBoxFormContainer">
			<form action="<%=mainAppPath%>/search/elasticSearch.asp" id="searchForm" method="GET">
				<div class="typeahead__container">
					<div class="typeahead__field">
						<span class="typeahead__query">
							<input class="js-typeahead"
								name="q"
								type="search"
								placeholder="Type here to search"
								autocomplete="off">
						</span>
					</div>
				</div>
			</form>
		</div>

		<script type="text/javascript">
			$.typeahead({
				debug: true,
				display: ["_id", "_index", "experimentType", "e_name", "notebookName", "e_details", "e_userAddedName"],
				input: ".js-typeahead",
				maxItem: 10,
				order: "asc",
				delay: 100,
				minLength: 3,
				filter: false,
				templateValue: "{{query}}",
				dynamic: true,
				cancelButton: false,
				template: function(query, item) {
					html = "<span class='row'>{{e_name}}</span>";
					/*
					Commented out because notebook label seems superfluous
					if (item.notebookName != null && item.notebookName != "") {
						html += "<span class='row'>{{notebookName}}</span>";
					}*/
					if (item.e_userAddedName != null && item.e_userAddedName != "") {
						html += "<span class='row'> - {{e_userAddedName}}</span>";
					}
					// There's a hack in this to just truncate super long description strings.
					if (item.e_details != null && item.e_details != "") {
						str = item.e_details
						if (str.length > 24) {
							str = str.substring(0, 24) + "..."
						}
						html += '<br/><span class="row multiLineSpacing">"<i>' + str +'</i>"</span>';
					} else {
						html += '<br/><span class="row"></span>'
					}
					return html;
				},
				emptyTemplate: "No results found for {{query}}",
				href: function(item) {
					expPage = window.location.origin + "<%=mainAppPath%>/";
					// note: We are changing the index names so we need to set these manualy insted of relying on index name to set them for us.
					// The chem link changes but the rest dont.
					if (item.experimentType == "1") {
						expPage += "<%=session("expPage")%>";
					}
					else if (item.experimentType == "2") {
						expPage += "bio-experiment.asp";
					}
					else if (item.experimentType == "3") {
						expPage += "free-experiment.asp";
					}
					else if (item.experimentType == "4") {
						expPage += "anal-experiment.asp";
					}
					else if (item.experimentType == "5") {
						expPage += "cust-experiment.asp";
					}
					 else {
						expPage += item._index + "-experiment.asp"
					}
					expPage += "?id=" + item._id;
					return expPage;
				},
				source: {
					experiment: {
						// Ajax Request
						ajax: function(param) {
							var result = {};
							result.bool = {};
							result.bool.must = {};
							result.bool.filter = {};
							result.bool.filter.terms = {};
							result.bool.must.multi_match = {};
							result.bool.must.multi_match.type = "phrase_prefix";
							result.bool.must.multi_match.query = param.toLowerCase();
							result.bool.must.multi_match.fields = ["e_userAddedName","notebookName","notebookDesc","e_name","e_details","fullName","statusName","attachmentNames","attachmentFileNames","noteNames"];
							return {
								url: "/arxlab/search/elasticSearch/search/elasticSearchSubmit.asp",
								dataType: 'json',
								method: "POST",
								type: "POST",
								contentType: "application/x-www-form-urlencoded",
								data: {
									searchJSON: JSON.stringify(result),
									pageNum: "0",
									pageSize: "40",
									sortCol: "dateCreated",
									sortOrder: "desc"
								},
								callback: {
									done: function(data, textStatus, jqXHR) {
										var li = [];
										for (i = 0; i < data.searchResults.hits.hits.length; i++) {
											var obj = data.searchResults.hits.hits[i]._source;
											obj["_id"] = data.searchResults.hits.hits[i]["_id"];
											obj["_index"] = data.searchResults.hits.hits[i]["_index"];
											li.push(obj);
										}
										return li;
									}
								}
							}
						}
					}						
				},
				callback: {
					onClickAfter: function(node, a, item, event) {
						event.preventDefault();
						expPage = window.location.origin + "<%=mainAppPath%>/";
						if (item.experimentType == "1") {
							expPage += "<%=session("expPage")%>";
						}
						else if (item.experimentType == "2") {
							expPage += "bio-experiment.asp";
						}
						else if (item.experimentType == "3") {
							expPage += "free-experiment.asp";
						}
						else if (item.experimentType == "4") {
							expPage += "anal-experiment.asp";
						}
						else if (item.experimentType == "5") {
							expPage += "cust-experiment.asp";
						}
						else {
							expPage += item._index + "-experiment.asp"
						}
						expPage += "?id=" + item._id;
						console.log(expPage);
						window.open(expPage);
					}
				}
			}
			);
		</script>
		<%end if%>


<div id="sideNavSection" class="hoverObj">
<%
regDefaultGroupId = getCompanySpecificSingleAppConfigSetting("defaultRegGroupId", session("companyId"))
redirectAssayToPlatform = checkBoolSettingForCompany("usePlatformAssay", session("companyId"))
'QQQ START the state of the nav does not change for H3 Reg
Sub getNavStates()
	gotStates = False
	myNotebooksFlag = False
	sharedNotebooksFlag = False
	groupInvitesFlag = False
	notebookInvitesFlag = False
	witnessRequestsFlag = False
	historyFlag = False

	recentExperiments = False
	recentHistory = False
	myProjectsFlag = False
	sharedProjectsFlag = False
	projectInvitesFlag = False
	toolsFlag = False
	templatesFlag = False
	registrationFlag = False
	ordersFlag = False
	myExperimentsMoreFlag = False
	sharedExperimentMoreFlag = False
	recentHistoryFlag = False
	treeFlag = false
	Set stateRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM navStates WHERE userId="&SQLClean(session("userId"),"N","S")
	stateRec.open strQuery,conn,0,-1
	If Not stateRec.eof Then
		gotStates = True
		If stateRec("myNotebooks") = 1 Then
			myNotebooksFlag = True
		end If
		If stateRec("sharedNotebooks") = 1 Then
			sharedNotebooksFlag = True
		end If
		If stateRec("groupInvites") = 1 Then
			groupInvitesFlag = True
		end If
		If stateRec("notebookInvites") = 1 Then
			notebookInvitesFlag = True
		end if
		If stateRec("witnessRequests") = 1 Then
			witnessRequestsFlag = True
		end if			
		If stateRec("history") = 1 Then
			historyFlag = True
		end If
		If stateRec("myProjects") = 1 Then
			myProjectsFlag = True
		end If
		If stateRec("sharedProjects") = 1 Then
			sharedProjectsFlag = True
		end If
		If stateRec("projectInvites") = 1 Then
			projectInvitesFlag = True
		end If
		If stateRec("tools") = 1 Or IsNull(stateRec("tools")) Then
			toolsFlag = True
		end If
		If stateRec("templates") = 1 Or IsNull(stateRec("templates")) Then
			templatesFlag = True
		end If
		If stateRec("recentExperiments") = 1 Or IsNull(stateRec("recentExperiments")) Then
			recentExperimentsFlag = True
		end If
		If stateRec("recentHistory") = 1 Or IsNull(stateRec("recentHistory")) Then
			recentHistoryFlag = True
		end If
		If stateRec("registration") = 1 Or IsNull(stateRec("registration")) Then
			registrationFlag = True
		end If
		If stateRec("orders") = 1 Or IsNull(stateRec("orders")) Then
			ordersFlag = True
		end If
		If stateRec("myExperimentsMore") = 1 Then
			myExperimentsMoreFlag = True
		end If
		If stateRec("sharedExperimentsMore") = 1 Then
			sharedExperimentsMoreFlag = True
		end If
		If stateRec("tree") = 1 Or IsNull(stateRec("tree")) Then
			treeFlag = True
		end If
	End If
	stateRec.close
	Set stateRec = Nothing
End sub
'QQQ END the state of the nav does not change for H3 Reg
%>


				<%
				'QQQ START the state of the nav does not change for H3 Reg
				Call getconnected
				Dim gotStates,myNotebooksFlag,sharedNotebooksFlag,groupInvitesFlag,notebookInvitesFlag,witnessRequestsFlag,historyFlag,myProjectsFlag,sharedProjectsFlag,projectInvitesFlag,recentExperimentsFlag,recentHistoryFlag,toolsFlag,templatesFlag,registrationFlag,myExperimentsMoreFlag,sharedExperimentsMoreFlag,treeFlag,ordersFlag
				Call getNavStates
				If Not gotStates Then
					Call getconnectedadm
					strQuery = "INSERT into navStates(userId,myNotebooks,sharedNotebooks,groupInvites,notebookInvites,witnessRequests,history,myProjects,sharedProjects,projectInvites,recentExperiments,tools,templates,registration,myExperimentsMore,sharedExperimentsMore,tree,recentHistory) values("&SQLClean(session("userId"),"N","S")&",1,1,0,0,0,0,0,0,0,1,1,1,1,0,0,1,1)"
					connAdm.execute(strQuery)
					Call getNavStates
					Call disconnectadm
				End If
				'QQQ END the state of the nav does not change for H3 Reg
				%>
				<%If hasExperimentsTreeInNav then%>
				<div class="navSectionBox backgroundFrame" style="margin-bottom:0px;">
					<div class="navSectionTitle">
							<a onclick="navToggle('tree')" href="javascript:void(0);">Tree</a><a onclick="navToggle('tree')"><span style="color: <black;"><img id="tree_arrow" border="0"<%If Not treeFlag then%> src="<%=mainAppPath%>/images/nav-right.gif"<%else%> src="<%=mainAppPath%>/images/nav-down.gif"<%End if%>/></span> </a>
					</div>
				</div>
				<div id="tree" <%If Not treeFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>>

				</div>
				<!-- dynatree -->
				<link rel='stylesheet' type='text/css' href='/arxlab/js/dynatree/skin/ui.dynatree.css?<%=jsRev%>'>
				<script src='/arxlab/js/dynatree/jquery.dynatree.js?<%=jsRev%>' type="text/javascript"></script>
				<script type="text/javascript">
				$("#tree").dynatree({
					initAjax: {url: "<%=mainAppPath%>/ajax_loaders/tree.asp",
							   data: {key: "root", // Optional arguments to append to the url
									  mode: "all",
									  type: "root",
									  }
							   },
					onLazyRead: function(node){
						node.appendAjax({url: "<%=mainAppPath%>/ajax_loaders/tree.asp",
										   data: {"key": node.data.key, // Optional url arguments
												  "mode": "all",
												  "type": node.data.type,
												  }
										  });
					},
					onActivate: function(node){
						keyPath = node.getKeyPath();
						setUserOption('mainTreeKeyPath',keyPath);
						window.location = node.data.url.trim();
					},
					imagePath: "<%=mainAppPath%>/inventory2/images/treeIcons/"
					<%if userOptions.get("mainTreeKeyPath")<>"" then%>
					,
					onPostInit: function(isReloading,isError){
						kp = "<%=userOptions.get("mainTreeKeyPath")%>";
						if (kp!=""){
							this.loadKeyPath(kp, function(node, status){
								if(status == "loaded") {
									node.expand();
								}else if(status == "ok") {
									node.expand();
								}else if(status == "notfound") {
									var seg = arguments[2],
										isEndNode = arguments[3];
								}
							});
						}
					}
					<%end if%>
				});
				</script>
				<%End if%>
				<%If session("hasELN") then%>
				<div class="navSectionBox backgroundFrame">
					<div class="navSectionTitle">
							<a onclick="navToggle('navTools')" href="javascript:void(0);"><%=arxlabToolsLabel%></a><a onclick="navToggle('navTools')"><span style="color: <black;"><img id="navTools_arrow" border="0"<%If Not toolsFlag then%> src="<%=mainAppPath%>/images/nav-right.gif"<%else%> src="<%=mainAppPath%>/images/nav-down.gif"<%End if%>/></span> </a>
					</div>
						<ul id="navTools"<%If Not toolsFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>>
								<%
								backupWaiting = False
								set bRec = server.createobject("ADODb.RecordSet")
								strQuery = "SELECT id FROM exports WHERE userId="&SQLClean(session("userId"),"N","S") & " AND status=1 or status=2"
								bRec.open strQuery,conn,0,-1
								if not bRec.eof then
									backupWaiting = true
									%>
									<script type="text/javascript">
										alreadyAlertedBackup = true;
									</script>
									<%
								Else
									%>
									<script type="text/javascript">
										alreadyAlertedBackup = false;
									</script>
									<%
								end If
								bRec.close
								Set bRec = Nothing
								%>
								<li><a href="<%=mainAppPath%>/dashboard.asp" <%If subSectionID = "dashboard" Then %> class="navSelected"<%End if%>><%=dashboardLabel%></a></li>
								<%If session("roleNumber") = 2 Or session("roleNumber") = 3 then%>
									<li><a href="<%=mainAppPath%>/admin/users.asp" <%If subSectionID = "users" Then %> class="navSelected"<%End if%>><%=manageUsersLabel%></a></li>
								<%End if%>
								<%If session("roleNumber") = 1 then%>
									<li><a href="<%=mainAppPath%>/admin/users.asp" <%If subSectionID = "users" Then %> class="navSelected"<%End if%>><%=manageUsersLabel%></a></li>
									<li><a href="<%=mainAppPath%>/admin/groups.asp" <%If subSectionID = "groups" Then %> class="navSelected"<%End if%>><%=manageGroupsLabel%></a></li>
									<%If session("email") = "support@arxspan.com" Or session("email") = "skicomputing@mskcc.org" Then%>
									<li style="position:relative;"><a href="<%=mainAppPath%>/exports/bulk-export.asp" id="backupLink" <%If subSectionID = "export" Then %> class="navSelected"<%End if%>>Backup</a><a href="<%=mainAppPath%>/exportWait.asp?from=nav" id="downloadBackupLink" <%If backupWaiting then%>style="display:block;position:absolute;top:-2px;left:50px;"<%else%>style="display:none;position:absolute;top:-2px;left:50px;"<%End if%><span style="color:red;"> - Download</span></a></li>
									<%End If%>
									<%If session("hasProductsSD") then%>
										<li><a href="<%=mainAppPath%>/admin/productsSD.asp" <%If subSectionID = "productsSD" Then %> class="navSelected"<%End if%>>Download Products SD</a></li>
									<%End if%>
								<%else%>
									<%If session("roleNumber") = 0 then%>
										<li><a href="<%=mainAppPath%>/admin/admin-users.asp" <%If subSectionID = "users" Or subSectionID = "admin-users" Then %> class="navSelected"<%End if%>><%=manageUsersLabel%></a></li>
										<li style="position:relative;"><a href="<%=mainAppPath%>/exports/bulk-export.asp" <%If subSectionID = "export" Then %> class="navSelected"<%End if%>>Backup</a><a href="<%=mainAppPath%>/exports/exportWait.asp?from=nav" id="downloadBackupLink" <%If backupWaiting then%>style="display:block;position:absolute;top:-2px;left:50px;"<%else%>style="display:none;position:absolute;top:-2px;left:50px;"<%End if%><span style="color:red;"> - Download</span></a>
										</li>
									<%else%>
										<li><a href="<%=mainAppPath%>/users/my-profile.asp" <%If subSectionID = "my-profile" Then %> class="navSelected"<%End if%>><%=myProfileLabel%></a></li>
									<%End if%>
								<%End if%>
								<% If session("email") = "support@arxspan.com" Then %>
									<li><a href="<%=mainAppPath%>/admin/viewAppConfigSettings.asp" <%If subSectionID = "appConfigSettings" Then %> class="navSelected"<%End if%>>App Config Settings</a></li>
								<% End If %>
								<%If 1=2 And session("roleNumber") <= 3 then%>
									<li><a href="<%=mainAppPath%>/admin/user-activity.asp" <%If subSectionID = "user-activity" Then %> class="navSelected"<%End if%>><%=userActivityLabel%></a></li>
								<%End if%>
								<%If session("companyId")=1 then%>
									<li><a href="<%=mainAppPath%>/table_pages/show-logHungSave.asp" <%If subSectionID = "show-logHungSave" Then %> class="navSelected"<%End if%>>View Hung Save Logs</a></li>
								<%End if%>
								<%If session("companyId")="1" then%>
									<li><a href="<%=mainAppPath%>/table_pages/show-logAspErrors.asp" <%If subSectionID = "show-logAspErrors" Then %> class="navSelected"<%End if%>>ASP Errors</a></li>
								<%End if%>
								<%If canSeeShowUserReport then%>
									<li><a href="<%=mainAppPath%>/table_pages/show-userReport.asp" <%If subSectionID = "show-userReport" Then %> class="navSelected"<%End if%>>Billing (beta)</a></li>
								<%End if%>
								<%If canUseGod then%>
									<li><a href="<%=mainAppPath%>/admin/god.asp" <%If subSectionID = "god" Then %> class="navSelected"<%End if%>>God</a></li>
								<%End if%>
								<%If session("userId") = "2" Or session("userId") = "7" Or session("userId") = "1472" Or session("email") = "amanda.lashua@arxspan.com" then%>
									<li><a href="<%=mainAppPath%>/admin/getAdms.asp" <%If subSectionID = "getAdms" Then %> class="navSelected"<%End if%>>Admins List</a></li>
								<%End if%>
								<%If session("roleNumber") = 0 then%>
									<li><a href="<%=mainAppPath%>/admin/create-companies.asp" <%If subSectionID = "create-companies" Then %> class="navSelected"<%End if%> style="font-weight:bold;">Create Companies</a></li>
									<li><a href="<%=mainAppPath%>/admin/delete-userData.asp" <%If subSectionID = "delete-user-data" Then %> class="navSelected"<%End if%> style="font-weight:bold;">Clear User Data</a></li>
								<%End if%>
								<%If session("roleNumber") = 1 then%>
									<li><a href="<%=mainAppPath%>/admin/reagentDatabaseImport.asp" <%If subSectionID = "reagentDatabase" Then %> class="navSelected"<%End if%>><%=uploadReagentDatabaseLabel%></a></li>
								<%End if%>
								<%If session("email") = "support@arxspan.com" then%>
									<li><a href="<%=mainAppPath%>/admin/cdxmlConvertTest.asp"><%=cdxmlConvertTestLabel%></a></li>
								<%End if%>
							<li><a href="<%=mainAppPath%>/search/elasticSearch.asp" <%If subSectionID = "advancedSearch" Then %> class="navSelected"<%End if%>><%=advancedSearchLabel%></a></li>
							<%If session("companyId") <> "" then%>
								<li class="chromeInstall"><a href="<%=mainAppPath%>/liveEditDownloads/chromeExtHostInstallation.asp" <%If subSectionID = "chromeExtHostInstallation" Then %> class="navSelected"<%End if%>>Live Edit Installation</a></li>
							<%End if%>
							<%If session("userHasOperationalReport") then%>
								<li><a href="<%=mainAppPath%>/reporting/report_activity_summary.asp" <%If subSectionID = "reportSummary" Then %> class="navSelected"<%End if%>><%=summaryReportLabel%></a></li>
								<li><a href="<%=mainAppPath%>/reporting/report_activity_detail.asp" <%If subSectionID = "reportDetail" Then %> class="navSelected"<%End if%>><%=detailedReportLabel%></a></li>								
							<%End if%>
							<!-- This will need to be taken out after UAT is done -->
							<%If showNewReactHistoryPageLinks = 1 then%>
									<li><a href="<%=mainAppPath%>/react/viewComponent.asp?url=savedSearchQueryTable&sid=tool&ssid=savedSearchQueries" <%If subSectionID = "savedSearchQueries" Then %> class="navSelected"<%End if%>><%=advancedSearchHistoryLabel%></a></li>
									<li><a href="<%=mainAppPath%>/react/viewComponent.asp?url=ExperimentViews&sid=tool&ssid=experimentViews" <%If subSectionID = "experimentViews" Then %> class="navSelected"<%End if%>><%=experimentViewHistoryLabel%></a></li>
									<li><a href="<%=mainAppPath%>/react/viewComponent.asp?url=UserLoginReport" <%If subSectionID = "show-user-login" Then %> class="navSelected"<%End if%>><%=userLoginHistoryLabel%></a></li>	
								<%Else if session("roleNumber") = 1 then%>
									<li><a href="<%=mainAppPath%>/table_pages/show-logLastLogin.asp" <%If subSectionID = "show-logLastLogin" Then %> class="navSelected"<%End if%>><%=viewLastLoginsLabel%></a></li>
								<% End If%>
							<%End if%>
						</ul>
					</div>
					<%End if%>
		
					<%If session("hasELN") then%>
					<%If session("roleNumber")<=1 Or session("canEditTemplates") Or session("canEditKeywords") then%>
							<div class="navSectionBox backgroundFrame">
								<div class="navSectionTitle">
										<a onclick="navToggle('navTemplates')" href="javascript:void(0);"><%=templatesLabel%></a><a onclick="navToggle('navTemplates')"><span  style="color: black;"><img id="navTemplates_arrow" border="0"<%If Not templatesFlag then%> src="<%=mainAppPath%>/images/nav-right.gif"<%else%> src="<%=mainAppPath%>/images/nav-down.gif"<%End if%>/></span></a>
								</div>
									<ul id="navTemplates"<%If Not templatesFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>>
										<%If session("roleNumber")<=1 Or session("canEditTemplates") then%>
											<li><a href="<%=mainAppPath%>/eln_templates/customDropDowns.asp" <%If sectionID = "custom-dropDowns" Then %> class="navSelected"<%End if%>><%=customDropDownsLabel%></a></li>
											<li><a href="<%=mainAppPath%>/eln_templates/prepTemplates-bio-protocol.asp" <%If subSectionID = "prep-templates-bio-protocol" Then %> class="navSelected"<%End if%>><%=biologyProtocolTemplatesLabel%></a></li>
											<li><a href="<%=mainAppPath%>/eln_templates/prepTemplates-bio-summary.asp" <%If subSectionID = "prep-templates-bio-summary" Then %> class="navSelected"<%End if%>><%=biologySummaryTemplatesLabel%></a></li>
											<li><a href="<%=mainAppPath%>/eln_templates/prepTemplates.asp" <%If subSectionID = "prep-templates" Then %> class="navSelected"<%End if%>><%=chemistryPreparationTemplatesLabel%></a></li>
											<li><a href="<%=mainAppPath%>/eln_templates/prepTemplates-free-description.asp" <%If subSectionID = "prep-templates-free-description" Then %> class="navSelected"<%End if%>><%=conceptDescriptionTemplatesLabel%></a></li>
										<%End If%>
										<%If session("roleNumber")<=1 Or session("canEditKeywords") then%>
											<li><a href="<%=mainAppPath%>/eln_keywords/manage-keywords.asp" <%If subSectionID = "manage-eln-keywords" Then %> class="navSelected"<%End if%>><%=keywordEditorTemplatesLabel%></a></li>
										<%End If%>
									</ul>
							</div>
					<%End if%>
					<%End if%>

							<%If session("hasInv") then%>
								<%If session("invRoleName")="Admin" Or session("invRoleName")="Power User" Or session("invRoleName")="User" Or session("invRoleName")="Reader" then%>
								<div id="sideNavSection">	
									<div class="navSectionBox backgroundFrame">
										<div class="navSectionTitle">
											<a href="<%=mainAppPath%>/inventory2/index.asp"><%=inventoryLabel%></a><span style="color: black;"></span>
										</div>
									</div>
								</div>
								<%End if%>
							<%End if%>
							<%If session("hasFT") then%>
								<div id="sideNavSection">	
									<div class="navSectionBox backgroundFrame">
										<div class="navSectionTitle">
											<a href="<%=mainAppPath%>/goToFT.asp?lite=">Search</a><span style="color: black;"></span>
										</div>
									</div>
								</div>
							<%End if%>
							
							<%If session("hasAssay") then%>
								<%If session("assayRoleName")="Admin" Or session("assayRoleName")="Power User" Or session("assayRoleName")="User" then%>
								<div id="sideNavSection">	
									<div class="navSectionBox backgroundFrame">
										<div class="navSectionTitle">
												<a href="<%=mainAppPath%>/assay<%If redirectAssayToPlatform then%>2<%End if%>/index.asp"><%=assayLabel%></a><span style="color: black;"></span>
										</div>
									</div>
								</div>
								<%End if%>
							<%End if%>

							<%If session("hasReg") then%>
							<%If session("regRoleNumber") <> 1000 then%>
							<%'QQQ START Main H3 Reg Section%>
								<div id="sideNavSection">	
									<div class="navSectionBox backgroundFrame">
										<div class="navSectionTitle">
												<a onclick="navToggle('navRegistration')" href="javascript:void(0);"><%=registrationLabel%></a><a onclick="navToggle('navRegistration')" href="javascript:void(0);"><span style="color: black;"><img id="navRegistration_arrow" border="0"<%If Not registrationFlag then%> src="<%=mainAppPath%>/images/nav-right.gif"<%else%> src="<%=mainAppPath%>/images/nav-down.gif"<%End if%>/></span></a>
										</div>
											<ul id="navRegistration" <%If Not registrationFlag Then%>style="display:none;"<%End if%>>
												<%If session("hasAccordInt") And session("regRoleNumber") <= 15 then%>
													<li><a href="<%=mainAppPath%>/accint/index.asp" <%If subSectionID = "reg-request-compounds" Then %> class="navSelected"<%End if%>><%=requestCompoundsLabel%></a></li>
												<%End if%>
												<%If session("roleNumber") = 1 And Not session("hasELN") then%>
													<li><a href="<%=regPath%>/users.asp" <%If subSectionID = "reg-users" Then %> class="navSelected"<%End if%>><%=manageUsersLabel%></a></li>
												<%End if%>
												<%If session("roleNumber") = 1 And Not session("hasELN") then%>
													<li><a href="<%=mainAppPath%>/admin/groups.asp" <%If subSectionID = "groups" Then %> class="navSelected"<%End if%>><%=manageGroupsLabel%></a></li>
												<%End if%>
												<%If session("regRegistrar") then%>
													<%If Not session("regRegistrarRestricted") then%>
														<li><a href="<%=regPath%>/adminApprove.asp" <%If subSectionID = "admin-approve" Then %> class="navSelected"<%End if%>><%=adminApproveLabel%></a></li>
														<%If session("hasChemistry") then%>
															<li><a href="<%=regPath%>/adminAddSalt.asp" <%If subSectionID = "add-salt" Then %> class="navSelected"<%End if%>><%=addSaltLabel%></a></li>
														<%End if%>
													<%End if%>
												<%End if%>
												<%If not session("regRegistrar") Or (session("regRegistrar") And session("regRegistrarRestricted")) Then %>
													<%If session("hasChemistry") then%>
														<li><a href="<%=regPath%>/viewSalts.asp" <%If subSectionID = "view-salts" Then %> class="navSelected"<%End if%>>View Salts</a></li>
													<%End if%>
												<%End if%>
												<%If session("regUser") Or session("regRegistrar") then%>
													<li><a href="<%=regPath%>/addStructure.asp<%If regDefaultGroupId<>"" then%>?groupId=<%=regDefaultGroupId%><%End if%>" <%If subSectionID = "add-structure" Then %> class="navSelected"<%End if%>><%=registerLabel%></a></li>
													<%If Not session("regRestrictedUser") then%>
													<%If session("companyHasFTLiteReg") Then
														searchScriptName = mainAppPath&"/gotoFT.asp?lite=reg"
													Else
														searchScriptName = regPath&"/search.asp"
													End if%>
													<li><a href="<%=searchScriptName%>" <%If subSectionID = "search" Then %> class="navSelected"<%End if%>><%=searchLabel%></a></li>
													<%End if%>
												<%End if%>
												<%If session("regRegistrar") then%>
													<%If Not session("regRegistrarRestricted") then%>
														<li><a href="<%=regPath%>/customFields.asp" <%If subSectionID = "custom-fields" Then %> class="navSelected"<%End if%>><%=customFieldsLabel%></a></li>
														<%If session("hasGroupFields") then%>
														<li><a href="<%=regPath%>/groupCustomFields.asp" <%If subSectionID = "group-custom-fields" Then %> class="navSelected"<%End if%>><%=groupCustomFieldsLabel%></a></li>
														<%End if%>
														<li><a href="<%=regPath%>/customDropDowns.asp" <%If subSectionID = "custom-dropDowns" And sectionId="reg" Then %> class="navSelected"<%End if%>><%=customDropDownsLabel%></a></li>
													<%End if%>



													<%'QQQ if H3%>
													<li><a href="<%=regPath%>/mappingTemplates.asp" <%If subSectionID = "mappingTemplates" And sectionId="reg" Then %> class="navSelected"<%End if%>><%=mappingTemplatesLabel%></a></li>
													<li><a href="<%=regPath%>/importC.asp<%If CStr(regDefaultGroupId)<>"" then%>?groupId=<%=regDefaultGroupId%><%End if%>" <%If subSectionID = "import0" Then %> class="navSelected"<%End if%>><%=bulkRegistrationLabel%></a></li>
													<%If 1=2 then%>
													<li><a href="<%=regPath%>/importA.asp" <%If subSectionID = "import1" Then %> class="navSelected"<%End if%>>Register Batches</a></li>
													<%End if%>
													<%If Not session("regRegistrarRestricted") then%>
													<li><a href="<%=regPath%>/importB.asp" <%If subSectionID = "import2" Then %> class="navSelected"<%End if%>><%=bulkUpdateLabel%></a></li>
													<%End If%>
													<li><a href="<%=regPath%>/show-bulk-file-list.asp" <%If subSectionID = "sd-rollback" Then %> class="navSelected"<%End if%>><%=SDRollbackLabel%></a></li>
													<%If 1=2 Then 'if not h3%>
													<li><a href="<%=regPath%>/import.asp" <%If subSectionID = "import" Then %> class="navSelected"<%End if%>>Import SDFile</a></li>
													<%End if%>

													<%
													Call getconnectedJchemReg
													Set tRec = server.CreateObject("ADODB.RecordSet")
													strQuery = "SELECT fid, sdFilename FROM sdImportsView WHERE userId="&SQLClean(session("userId"),"N","S")&" ORDER BY id DESC"
													tRec.open strQuery,jchemRegConn,3,3
													If Not tRec.eof Then
														Set xRec = server.CreateObject("ADODB.RecordSet")
														strQueryX = "SELECT id FROM sdImportsView WHERE userId="&SQLClean(session("userId"),"N","S")&" and sdFilename="&SQLClean(tRec("sdFilename"),"T","S")
														xRec.open strQueryX,jchemRegConn,3,3
														If xRec.eof Then
															showAddBatchButton = True
														Else
															showAddBatchButton = True
														End If
														xRec.close
														Set xRec = Nothing
														theFid = tRec("fid")
													Else
														theFid = "234242lj3k4j2lk3j4l2k3j42l3k42l34kj234lkj"
													End If
													tRec.close()
													Set tRec = Nothing
													%>
												<%End if%>
												<%If Not session("hasELN") then%>
												<li><a href="<%=mainAppPath%>/users/my-profile.asp" <%If subSectionID = "my-profile" Then %> class="navSelected"<%End if%>><%=myProfileLabel%></a></li>
												<%End if%>
											</ul>
									</div>

							<%'QQQ END MAIN H3 Reg Section%>
							<%'QQQ START REMOVE FOR h3%>
							<%End if%>
							<%End if%>
							
							<%If session("hasOrdering") then%>
							<%'QQQ START Orders section%>
								<div id="sideNavSection">	
									<div class="navSectionBox backgroundFrame">
										<%
										Set gRec = server.CreateObject("ADODB.RecordSet")
										strQuery = "SELECT * FROM groupMembersView WHERE userId="&SQLClean(session("userId"),"N","S")
										gRec.open strQuery,conn,3,3
										showAdminLinks = False
										showDropDownLinks = False
										showDashboardLink = False
										showMakeNewRequestLink = True
										
										If session("roleNumber") = 1 or session("manageWorkflow") = true Then
											showAdminLinks = True
										End If
										
										Do While Not gRec.eof
											If (Not showAdminLinks) And gRec("groupName") = "Configuration Managers" Then
												showAdminLinks = True
											End If
											
											If (Not showAdminLinks) And gRec("groupName") = "Business Administrators" Then
												showDropDownLinks = True
											End If
											
											if gRec("groupName") = "Workflow Managers" or gRec("groupName") = "Workflow Requesters" or gRec("groupName") = "Workflow Requestors" then
												showDashboardLink = True
											end if

											if gRec("groupName") = "Wuxi" then
												showMakeNewRequestLink = False
											end if

											gRec.movenext
										Loop
										gRec.close
										Set gRec = Nothing
										showWorkflowMenus = True
										If whichClient = "TAKEDA_VBU" Or whichClient = "TAKEDA_STANFORD_AIM" Then
											showWorkflowMenus = False
										End If
										%>
										<%If showWorkflowMenus Or showAdminLinks Or showDropDownLinks Then%>
										<div class="navSectionTitle">
												<a onclick="navToggle('navOrders')" href="javascript:void(0);"><%=ordersNavHeading%></a><a onclick="navToggle('navOrders')" href="javascript:void(0);"><span style="color: black;"><img id="navOrders_arrow" border="0"<%If Not ordersFlag then%> src="<%=mainAppPath%>/images/nav-right.gif"<%else%> src="<%=mainAppPath%>/images/nav-down.gif"<%End if%>/></span></a>
										</div>
											<ul id="navOrders" <%If Not ordersFlag Then%>style="display:none;"<%End if%>>
												<% if showDashboardLink and showWorkflowMenus then %>
													<li><a href="<%=mainAppPath%>/workflow/index.asp"><%=ordersDashboardLabel%></a></li>
												<% end if

												workflowTypes = configGet("/requesttypes/requestTypeCountByPermissionType?appName=Workflow&permissionType=canAdd&includeDisabled=false")
												if showMakeNewRequestLink and showWorkflowMenus and workflowTypes > 0 then %>
													<li><a href="<%=mainAppPath%>/workflow/makeNewRequest.asp"><%=ordersSubmitNewRequestLabel%></a></li>
												<% end if %>
												<%If showWorkflowMenus Then%>
												<li><a href="<%=mainAppPath%>/workflow/manageRequests.asp"><%=ordersManageRequestsLabel%></a></li>
												<li><a href="<%=mainAppPath%>/workflow/userSettings.asp"><%=ordersUserSettingsLabel%></a></li>
												<%End If%>
												<li <%If (Not showAdminLinks) And (Not showDropDownLinks) then%>style="display:none;"<%End If%>><a href="<%=mainAppPath%>/workflow/manageConfiguration/editDropdowns.asp"><%=ordersManageDropDowns%></a></li>
												<li <%If Not showAdminLinks then%>style="display:none;"<%End If%>><a href="<%=mainAppPath%>/workflow/manageConfiguration/editFields.asp"><%=ordersManageFields%></a></li>
												<li <%If Not showAdminLinks then%>style="display:none;"<%End If%>><a href="<%=mainAppPath%>/workflow/manageConfiguration/editRequestTypes.asp"><%=ordersManageRequestsTypes%></a></li>
												<li <%If Not showAdminLinks then%>style="display:none;"<%End If%>><a href="<%=mainAppPath%>/workflow/manageConfiguration/editRequestItemTypes.asp"><%=ordersManageRequestItemTypes%></a></li>
											</ul>
										<%End If%>
									</div>
								</div>

							<%'QQQ END Orders section%>
							<%End If%>
							
							<!-- Start Projects -->
							<%If session("hasELN") Or session("hasReg") then%>

							<div class="navSectionBox backgroundFrame">
								<div class="navSectionTitle">
									<a onclick="navToggle('navProjects')" href="javascript:void(0);" id="projectsNavLink"><%=projectsLabel%></a><a onclick="navToggle('navProjects')" id="projectsNavArrowLink"> <span><img id="navProjects_arrow" border="0"<%If Not myProjectsFlag then%> src="<%=mainAppPath%>/images/nav-right.gif"<%else%> src="<%=mainAppPath%>/images/nav-down.gif"<%End if%>/></span></a>
								</div>
								<div class="navSectionTabAction">								
									<a href="javascript:void(0);" onclick="if(document.getElementById('navProjects').style.display == 'none'){navToggle('navProjects')}" class="active"><%=UCase(recentLabel)%></a>					
									<a href="javascript:void(0);" onclick="if(document.getElementById('navProjects').style.display == 'none'){navToggle('navProjects')}">&nbsp;</a>
									<%'roleNumber 40 is witness only%>
									<%If session("canLeadProjects") And session("roleNumber")<40 then%>
										<a id="createNewProjectLeftNavButton" class="newObject newButton" onclick="if (window.InterCom){window.InterCom.props.openNewProject()} else{window.location='<%=mainAppPath%>/projects/create-project.asp'}" href="javascript:void(0)" >    <%=UCase(newLabel)%>+</a>
									<%End if%>	
								</div>
								<div id="navProjects"<%If Not myProjectsFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>>
								<img id="navProjectsLoading" src="<%=mainAppPath%>/images/loading.gif" <%If Not myProjectsFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>/>
									<%If myProjectsFlag then%>
										<script type="text/javascript">
                                            $.ajax({
                                                type:"GET",
                                                async: true,
                                                cache: false,
                                                url:"<%=mainAppPath%>/ajax_loaders/nav/projects.asp?subSectionId=<%=subSectionId%>",
                                                success: function(response)
                                                {
                                                    document.getElementById("navProjects").innerHTML = response;
                                                },
                                                error:function()
                                                {
                                                    console.error("Unable to clear notifications!");
                                                }
                                            });
										</script>
									<%else%>
										<script type="text/javascript">
								

											document.getElementById("projectsNavLink").onclick = function(){
												document.getElementById("navProjectsLoading").style.display = "block";
												//  console.log("In projectsNavLink listener");
                                                $.ajax({
                                                    type:"GET",
                                                    async: true,
                                                    cache: false,
                                                    url:"<%=mainAppPath%>/ajax_loaders/nav/projects.asp?subSectionId=<%=subSectionId%>",
                                                    success: function(response)
                                                    {
                                                        document.getElementById("navProjects").innerHTML = response;
                                                        navToggle('navProjects');
                                                        document.getElementById("projectsNavLink").onclick = function(){
                                                            //  console.log("In projectsNavLink second listener");
                                                            navToggle('navProjects');
                                                        }
                                                        document.getElementById("projectsNavArrowLink").onclick = function(){
                                                            //  console.log("In projectsNavLink third listener");
                                                            navToggle('navProjects');
                                                        }
                                                    },
                                                    error:function()
                                                    {
                                                        console.error("Error loading projects!");
                                                    }
                                                });
											}

											document.getElementById("projectsNavArrowLink").onclick = function(){
												document.getElementById("navProjectsLoading").style.display = "block";
												//  console.log("In projectsNavArrowLink listener");
                                                $.ajax({
                                                    type:"GET",
                                                    async: true,
                                                    cache: false,
                                                    url:"<%=mainAppPath%>/ajax_loaders/nav/projects.asp?subSectionId=<%=subSectionId%>",
                                                    success: function(response)
                                                    {
                                                        document.getElementById("navProjects").innerHTML = response;
                                                        navToggle('navProjects');
                                                        document.getElementById("projectsNavArrowLink").onclick = function(){
                                                            //  console.log("In projectsNavLink third listener");
                                                            navToggle('navProjects');
                                                        }
                                                    },
                                                    error:function()
                                                    {
                                                        console.error("Error loading projects!");
                                                    }
                                                });
											}
										</script>
									<%End if%>
								</div>
							</div>
							<%End if%>
							<!-- end projects -->

							<!-- start notebooks -->
							<%If session("hasELN") then%>
							<div class="navSectionBox backgroundFrame">
								<div class="navSectionTitle">
										<a onclick="navToggle('navNotebooks')" href="javascript:void(0);" id="notebooksNavLink"><%=notebooksLabel%></a><a onclick="navToggle('navNotebooks')" id="notebooksNavArrowLink"><span><img id="navNotebooks_arrow" border="0"<%If Not myNotebooksFlag then%> src="<%=mainAppPath%>/images/nav-right.gif"<%else%> src="<%=mainAppPath%>/images/nav-down.gif"<%End if%>/></span></a>
								</div>
								<div class="navSectionTabAction">								
										<a href="javascript:void(0);" onclick="if(document.getElementById('navNotebooks').style.display == 'none'){navToggle('navNotebooks')}" class="active"><%=UCase(recentLabel)%></a>					
										<a href="javascript:void(0);" onclick="if(document.getElementById('navNotebooks').style.display == 'none'){navToggle('navNotebooks')}">&nbsp;</a>
										<%If canCreateNotebook(false) then%>
										<a id="createNewNotebookLeftNavButton" class="newObject newButton"onclick="if (window.InterCom){window.InterCom.props.openNewNotebook()} else {window.location = '<%=mainAppPath%>/notebooks/create-notebook.asp'}" href="javascript:void(0)"><%=UCase(newLabel)%>+</a>
										<%End if%>
										
								</div>
								<div class="navSubSectionTabAction">								
										<a id="navMyNotebooksLink" href="javascript:void(0);" onclick="if(document.getElementById('navMyNotebooks').style.display == 'none'){navToggle('navMyNotebooks');this.className='active';s=document.getElementById('navSharedNotebooks');s.style.display='none';sa=document.getElementById('navSharedNotebooksLink');sa.className='';setUserOption('navSharedNotebooks',false);}" <%If Not userOptions.Get("navSharedNotebooks") then%>class="active"<%End if%>><%=UCase(myNotebooksLabel)%></a>
										<a id="navSharedNotebooksLink" href="javascript:void(0);" onclick="if(document.getElementById('navSharedNotebooks').style.display == 'none'){navToggle('navSharedNotebooks');this.className='active';m=document.getElementById('navMyNotebooks');m.style.display='none';ma=document.getElementById('navMyNotebooksLink');ma.className='';setUserOption('navSharedNotebooks',true);}" <%If userOptions.Get("navSharedNotebooks") then%>class="active"<%End if%>><%=UCase(sharedLabel)%></a>
										
								</div>

									<div id="navNotebooks"<%If Not myNotebooksFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>>
									<img id="navNotebooksLoading" src="<%=mainAppPath%>/images/loading.gif" <%If Not myNotebooksFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>/>
									<%If myNotebooksFlag then%>
										<script type="text/javascript">
                                            $.ajax({
                                                type:"GET",
                                                async: true,
                                                cache: false,
                                                url:"<%=mainAppPath%>/ajax_loaders/nav/notebooks.asp?subSectionId=<%=subSectionId%>",
                                                success: function(response)
                                                {
                                                    document.getElementById("navNotebooks").innerHTML = response;
                                                },
                                                error:function()
                                                {
                                                    console.error("Error loading projects!");
                                                }
                                            });
										</script>
									<%else%>
										<script type="text/javascript">
											document.getElementById("notebooksNavLink").onclick = function(){
												document.getElementById("navNotebooksLoading").style.display = "block";
                                                $.ajax({
                                                    type:"GET",
                                                    async: true,
                                                    cache: false,
                                                    url:"<%=mainAppPath%>/ajax_loaders/nav/notebooks.asp?subSectionId=<%=subSectionId%>",
                                                    success: function(response)
                                                    {
                                                        document.getElementById("navNotebooks").innerHTML = response;
                                                        navToggle('navNotebooks');
                                                        document.getElementById("notebooksNavLink").onclick = function(){
                                                            navToggle('navNotebooks');
                                                        }
                                                        document.getElementById("notebooksNavArrowLink").onclick = function(){
                                                            navToggle('navNotebooks');
                                                        }
                                                    },
                                                    error:function()
                                                    {
                                                        console.error("Error loading notebooks!");
                                                    }
                                                });
											}

											document.getElementById("notebooksNavArrowLink").onclick = function(){
												document.getElementById("navNotebooksLoading").style.display = "block";
                                                $.ajax({
                                                    type:"GET",
                                                    async: true,
                                                    cache: false,
                                                    url:"<%=mainAppPath%>/ajax_loaders/nav/notebooks.asp?subSectionId=<%=subSectionId%>",
                                                    success: function(response)
                                                    {
                                                        document.getElementById("navNotebooks").innerHTML = response;
                                                        navToggle('navNotebooks');
                                                        document.getElementById("notebooksNavLink").onclick = function(){
                                                            navToggle('navNotebooks');
                                                        }
                                                        document.getElementById("notebooksNavArrowLink").onclick = function(){
                                                            navToggle('navNotebooks');
                                                        }
                                                    },
                                                    error:function()
                                                    {
                                                        console.error("Error loading notebooks!");
                                                    }
                                                });
											}
										</script>
									<%End if%>
									</div>
								</div>

								<%End if%>
								<!-- end notebooks -->

								<!-- start experiments -->
							<%If session("hasELN") then%>
							<div class="navSectionBox backgroundFrame">
								<div class="navSectionTitle">
										<a onclick="navToggle('navRecentExperiments')" href="javascript:void(0);" id="recentExperimentsNavLink">
										<%=experimentsLabel%></a><a onclick="navToggle('navRecentExperiments')" href="javascript:void(0);" id="recentExperimentsNavArrowLink"><span><img id="navRecentExperiments_arrow" border="0"<%If Not recentExperimentsFlag then%> src="<%=mainAppPath%>/images/nav-right.gif"<%else%> src="<%=mainAppPath%>/images/nav-down.gif"<%End if%>/></span></a>
								</div>
								<div class="navSectionTabAction">
										<a href="javascript:void(0);" class="active" id="ra" onclick="r=document.getElementById('navRecentExperiments');if(r && r.style.display == 'none'){navToggle('navRecentExperiments')};f=document.getElementById('favoriteExperimentsList');if(r) {r.style.display='block';};if(f){f.style.display='none';};this.className='active';document.getElementById('fa').className='';"><%=UCase(recentLabel)%></a>					
										<a href="javascript:void(0);" id="fa" onclick="r=document.getElementById('navRecentExperiments');if(r && r.style.display == 'none'){navToggle('navRecentExperiments');};f=document.getElementById('favoriteExperimentsList');if(r){r.style.display='none';};if(f){f.style.display='block';};this.className='active';document.getElementById('ra').className='';"><%=UCase(watchlistLabel)%></a>
										<%
										'roleNumber 40 is witness only
										If session("roleNumber")<40 then
										%>
											<a id="createNewExperimentLeftNavButton" class="newObject newButton" onclick="if (window.InterCom){window.InterCom.props.openNewExperiment()} else {showPopup('newExperimentDiv');return false;}" href="javascript:void(0)"><%=UCase(newLabel)%>+</a>
										<%End if%>
										
								</div>
								<div id="navRecentExperimentsHolder">
									<img id="recentExperimentsLoading" src="<%=mainAppPath%>/images/loading.gif" <%If Not recentExperimentsFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>/>
									<%If recentExperimentsFlag then%>
										<script type="text/javascript">
                                            $.ajax({
                                                type:"GET",
                                                async: true,
                                                cache: false,
                                                url:"<%=mainAppPath%>/ajax_loaders/nav/experiments.asp?recentExperimentsFlag=<%=recentExperimentsFlag%>&myExperimentsMoreFlag=<%=myExperimentsMoreFlag%>&sharedExperimentsMoreFlag=<%=sharedExperimentsMoreFlag%>&subSectionId=<%=subSectionId%>",
                                                success: function(response)
                                                {
                                                    document.getElementById("navRecentExperimentsHolder").innerHTML = response;
                                                },
                                                error:function()
                                                {
                                                    console.error("Error loading experiments!");
                                                }
                                            });
										</script>
									<%else%>
										<script type="text/javascript">
											document.getElementById("recentExperimentsNavLink").onclick = function(){
												if (document.getElementById("recentExperimentsLoading")) {
													document.getElementById("recentExperimentsLoading").style.display = "block";
												}
                                                $.ajax({
                                                    type:"GET",
                                                    async: true,
                                                    cache: false,
                                                    url:"<%=mainAppPath%>/ajax_loaders/nav/experiments.asp?recentExperimentsFlag=<%=recentExperimentsFlag%>&myExperimentsMoreFlag=<%=myExperimentsMoreFlag%>&sharedExperimentsMoreFlag=<%=sharedExperimentsMoreFlag%>&subSectionId=<%=subSectionId%>",
                                                    success: function(response)
                                                    {
                                                        document.getElementById("navRecentExperimentsHolder").innerHTML = response;
                                                        navToggle("navRecentExperiments");
                                                        document.getElementById("recentExperimentsNavLink").onclick = function(){
                                                            navToggle("navRecentExperiments");
                                                        }
                                                        document.getElementById("recentExperimentsNavArrowLink").onclick = function(){
                                                            navToggle("navRecentExperiments");
                                                        }
                                                    },
                                                    error:function()
                                                    {
                                                        console.error("Error loading experiments!");
                                                    }
                                                });
											}

											document.getElementById("recentExperimentsNavArrowLink").onclick = function(){
												if (document.getElementById("recentExperimentsLoading")) {
													document.getElementById("recentExperimentsLoading").style.display = "block";
												}
                                                $.ajax({
                                                    type:"GET",
                                                    async: true,
                                                    cache: false,
                                                    url:"<%=mainAppPath%>/ajax_loaders/nav/experiments.asp?recentExperimentsFlag=<%=recentExperimentsFlag%>&myExperimentsMoreFlag=<%=myExperimentsMoreFlag%>&sharedExperimentsMoreFlag=<%=sharedExperimentsMoreFlag%>&subSectionId=<%=subSectionId%>",
                                                    success: function(response)
                                                    {
                                                        document.getElementById("navRecentExperimentsHolder").innerHTML = response;
                                                        navToggle("navRecentExperiments");
                                                        document.getElementById("recentExperimentsNavArrowLink").onclick = function(){
                                                            navToggle("navRecentExperiments");
                                                        }
                                                        document.getElementById("recentExperimentsNavLink").onclick = function(){
                                                            navToggle("navRecentExperiments");
                                                        }
                                                    },
                                                    error:function()
                                                    {
                                                        console.error("Error loading experiments!");
                                                    }
                                                });
											}
										</script>
									<%End if%>
								</div>
							</div>
							<%End if%>
							<!-- end experiments -->

							<!-- start experiment history -->

							<%If canRead Or expUserId = session("userId") Or canViewExperiment(experimentType,experimentId,session("userId")) then%>
								<%If (subSectionId = "experiment" Or subSectionId="bio-experiment" Or subSectionId="free-experiment" Or subSectionId="anal-experiment" Or subSectionId="cust-experiment") And request.querystring("id") <> "" then%>
								<%
								If CStr(request.querystring("revisionNumber")) <> "" Then 
									rId = request.querystring("revisionNumber")
								Else
									rId = request.querystring("revisionId")
								End If
								%>
									<div class="navSectionBox backgroundFrame">
										<div class="navSectionTitle">
											<a onclick="navToggle('navRecentHistory')" href="javascript:void(0);" id="historyNavLink"><%=historyLabel%></a><a onclick="navToggle('navRecentHistory')" href="javascript:void(0);" id="historyNavArrowLink"><span style="color: black;"><img id="navRecentHistory_arrow" border="0"<%If Not recentHistoryFlag then%> src="<%=mainAppPath%>/images/nav-right.gif"<%else%> src="<%=mainAppPath%>/images/nav-down.gif"<%End if%>/></span></a>
										</div>
										<div id="navRecentHistoryHolder">
										<img id="navHistoryLoading" src="<%=mainAppPath%>/images/loading.gif" <%If Not recentHistoryFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>/>
										<%If recentHistoryFlag then%>
											<script type="text/javascript">
                                                $(document).ready(function () {
                                                    $.ajax({
                                                        url: '<%=mainAppPath%>/ajax_loaders/nav/experimentHistory.asp?id=<%=request.querystring("id")%>&revisionId=<%=rId%>&subSectionId=<%=subSectionId%>&draftHasUnsavedChanges=<%=draftHasUnsavedChanges%>',
                                                        type: 'GET',
                                                        async: true,
                                                        cache: false,
                                                        dataType: 'html'
                                                    })
                                                        .success(function (r) {
                                                            $("#navRecentHistoryHolder").html(r);
                                                        })
                                                        .fail(function () {
                                                            alert("Unable to load experiment history list. Please contact support@arxspan.com.");
                                                        });
                                                });
                                            </script>
										<%else%>


<!--[if IE]>

<script type="text/javascript">
// Production steps of ECMA-262, Edition 5, 15.4.4.18
// Reference: http://es5.github.io/#x15.4.4.18
if (!Array.prototype.forEach) {

  Array.prototype.forEach = function(callback/*, thisArg*/) {

    var T, k;

    if (this == null) {
      throw new TypeError('this is null or not defined');
    }

    // 1. Let O be the result of calling toObject() passing the
    // |this| value as the argument.
    var O = Object(this);

    // 2. Let lenValue be the result of calling the Get() internal
    // method of O with the argument "length".
    // 3. Let len be toUint32(lenValue).
    var len = O.length >>> 0;

    // 4. If isCallable(callback) is false, throw a TypeError exception. 
    // See: http://es5.github.com/#x9.11
    if (typeof callback !== 'function') {
      throw new TypeError(callback + ' is not a function');
    }

    // 5. If thisArg was supplied, let T be thisArg; else let
    // T be undefined.
    if (arguments.length > 1) {
      T = arguments[1];
    }

    // 6. Let k be 0
    k = 0;

    // 7. Repeat, while k < len
    while (k < len) {

      var kValue;

      // a. Let Pk be ToString(k).
      //    This is implicit for LHS operands of the in operator
      // b. Let kPresent be the result of calling the HasProperty
      //    internal method of O with argument Pk.
      //    This step can be combined with c
      // c. If kPresent is true, then
      if (k in O) {

        // i. Let kValue be the result of calling the Get internal
        // method of O with argument Pk.
        kValue = O[k];

        // ii. Call the Call internal method of callback with T as
        // the this value and argument list containing kValue, k, and O.
        callback.call(T, kValue, k, O);
      }
      // d. Increase k by 1.
      k++;
    }
    // 8. return undefined
  };
}

if (!Array.prototype.indexOf)
{
  Array.prototype.indexOf = function(elt /*, from*/)
  {
    var len = this.length >>> 0;

    var from = Number(arguments[1]) || 0;
    from = (from < 0)
         ? Math.ceil(from)
         : Math.floor(from);
    if (from < 0)
      from += len;

    for (; from < len; from++)
    {
      if (from in this &&
          this[from] === elt)
        return from;
    }
    return -1;
  };
}


(function () {
  if (!document.getElementsByClassName) {
    window.Element.prototype.getElementsByClassName = document.constructor.prototype.getElementsByClassName = function (classNames) {
      classNames || (classNames = '*');
      classNames = classNames.split(' ').join('.');
      
      if (classNames !== '*') {
        classNames = '.' + classNames;
      }
      
      return this.querySelectorAll(classNames);
    };  
  }
  
})();

</script>

<![endif]-->


											<script type="text/javascript">
												
												document.getElementById("historyNavLink").onclick = function(){
													if (document.getElementById("navHistoryLoading")) {
														document.getElementById("navHistoryLoading").style.display = "block";
													}
													getFileA('<%=mainAppPath%>/ajax_loaders/nav/experimentHistory.asp?id=<%=request.querystring("id")%>&revisionId=<%=rId%>&subSectionId=<%=subSectionId%>&draftHasUnsavedChanges=<%=draftHasUnsavedChanges%>&random='+Math.random(),function(r){document.getElementById('navRecentHistoryHolder').innerHTML = r;delayedRunJS(r);navToggle('navRecentHistory');});
													document.getElementById("historyNavLink").onclick = function(){
														navToggle('navRecentHistory');
													}
													document.getElementById("historyNavArrowLink").onclick = function(){
														navToggle('navRecentHistory');
													}
												}

												document.getElementById("historyNavArrowLink").onclick = function(){
													if (document.getElementById("navHistoryLoading")) {
														document.getElementById("navHistoryLoading").style.display = "block";
													}
													getFileA('<%=mainAppPath%>/ajax_loaders/nav/experimentHistory.asp?id=<%=request.querystring("id")%>&revisionId=<%=rId%>&subSectionId=<%=subSectionId%>&draftHasUnsavedChanges=<%=draftHasUnsavedChanges%>&random='+Math.random(),function(r){document.getElementById('navRecentHistoryHolder').innerHTML = r;delayedRunJS(r);navToggle('navRecentHistory');});
													document.getElementById("historyNavArrowLink").onclick = function(){
														navToggle('navRecentHistory');
													}
													document.getElementById("historyNavLink").onclick = function(){
														navToggle('navRecentHistory');
													}
												}
											</script>
										<%End if%>
										</div>
									</div>
								<%End if%>
							<%End if%>
							<!-- end experiment history -->

							<%If session("hasReg") Or session("hasELN") then%>
							<%
							Set navNotebookInvitesRec = server.CreateObject("ADODB.RecordSet")
							strQuery = "SELECT id FROM allInvitesView WHERE (shareeId="&SQLClean(session("userId"),"N","S") & ") AND (accepted=0 and denied=0)"
							navNotebookInvitesRec.open strQuery,conn,1,1
							%>
						<div class="navSectionBox backgroundFrame">
								<div class="navSectionTitle">
									<a href="<%=mainAppPath%>/table_pages/show-invites.asp"><%=invitationsLabel%></a><span style="color:black;">&nbsp;(<%=navNotebookInvitesRec.RecordCount%>)</span>
								</div>
						</div>
							<%End if%>
							<%If session("hasELN") then%>
						<div class="navSectionBox backgroundFrame">
								<div class="navSectionTitle">
									<a href="<%=mainAppPath%>/table_pages/show-witnessedByMe.asp"><%=witnessedByMeLabel%></a>
								</div>
						</div>
						<%End if%>
						<%'QQQ END REMOVE FOR h3%>
						<%'QQQ START cloud logout section%>
							<%
							If session("companyId") = "4" then
								logoutStr = "logout.asp?m=t"
							else
								logoutStr = "logout.asp"
							End If
							%>
						<%If session("hasReg") then%>
						<div class="navSectionBox backgroundFrame">
								<div class="navSectionTitle">
									<a href="<%=mainAppPath%>/<%=logoutStr%>" <%If subSectionID = "partners" Then %> class="navSelected"<%End if%>><%=logoutLabel%></a>
								</div>
						</div>
						<%'QQQ END cloud logout section%>
						<%'QQQ H3 reg logout section%>
						<%If 1=2 then%>
						<div class="navSectionBox backgroundFrame">
							<div class="navSectionTitle">
								<a href="logout.asp">Logout</a>
							</div>
						</div>
						<%End if%>

						<%End if%>

</div>

<!-- END sideNavSection-->
	</td>
	<td class="pageContentTD<%If subsectionId="show-project" then%> pageContentTDNewBG<%End if%> backgroundFrame" id="pageContentTD" valign="top">


<div class="pageContent" id="pageContent" style="position:relative;">

<%'QQQ START remove experiment top button strip and marquee messages%>

<iframe id="fileupload_iframe" name="fileupload_iframe" src="javascript:false;" style="display: none">
</iframe>
<div id="unsavedChanges" class="experimentStatusMessage draftSavedMessage top"><table style="width:100%;">
<tr><td align="center">
All changes saved to draft &ndash; <a href="javascript:void(0)" onclick="clickSave();" style="color:blue;">Click&nbsp;to&nbsp;publish&nbsp;now</a> &ndash; (Keyboard&nbsp;shortcut:&nbsp;Ctrl+S)</td></tr></table>
</div>

<div id="savingDraft" class="savingDraft experimentStatusMessage"><table style="width:100%;">
<tr><td align="center">Saving Draft...</td></tr></table>
</div>

<script type="text/javascript">

function showOverMessage(theId,centerBy){
	us = document.getElementById(theId);
	us.style.display = "block";
	if(theId=="unsavedChanges"){
		try{document.getElementById("copyExperimentButton").style.display = 'none';}catch(err){}
		try{document.getElementById("moveExperimentButton").style.display = 'none';}catch(err){}
		try{document.getElementById("signExperimentButton").style.display = 'none';}catch(err){}
		changeHistoryToDraft();
		showOverMessage("unsavedChanges2","page")
	}
}

function changeHistoryToDraft(){
	try{
		document.getElementById("currentHistoryItem").style.display = "none";
		document.getElementById("draftHistoryItem").style.display = "block";
	}
	catch(err){
		window.setTimeout(changeHistoryToDraft,1000)
	}
}

function hideOverMessage(theId){
	us = document.getElementById(theId);
	us.style.display = "none";
}
</script>
<div id="networkProblem" class="networkProblem experimentStatusMessage"><table style="width:100%;">
<tr><td align="center">Looks like you are having network problems.  Arxspan is trying your command again...</td></tr></table>
</div>

<div id="networkProblem2" class="experimentStatusMessage networkProblem2"><table style="width:100%;">
<tr><td align="center">Trying again...</td></tr></table>
</div>

<div id="unsavedChanges2" class="experimentStatusMessage draftSavedMessage bottom"><table style="width:100%;">
<tr><td align="center">
All changes saved to draft &ndash; <a href="javascript:void(0)" onclick="clickSave();" style="color:blue;">Click&nbsp;to&nbsp;publish&nbsp;now</a> &ndash; (Keyboard&nbsp;shortcut:&nbsp;Ctrl+S)</td></tr></table>
</div>

<div id="reactDialogs"> 

</div>

<%'fun%>
<%If 1=2 then%>
<%For i = 3 To 1000%>
<iframe src="javascript:false;" id="unsavedChanges<%=i%>Frame" class="experimentStatusMessage" style="border:0;z-index:80000000;position:fixed;top:0px;left:220px;background-image:url('<%=mainAppPath%>/images/unsaved-bg.gif');background-repeat:no-repeat;width:500px;height:22px;display:none;font-weight:bold;padding:0px 0px 0px 0px;"><table style="width:100%;" style="z-index:80000001">
<tr><td align="center">
All changes saved to draft &ndash; <a href="javascript:void(0)" onclick="clickSave();" style="color:blue;">Click&nbsp;to&nbsp;publish&nbsp;now</a> &ndash; (Keyboard&nbsp;shortcut:&nbsp;Ctrl+S)</td></tr></table>
</iframe>
<div id="unsavedChanges<%=i%>" class="experimentStatusMessage" style="z-index:80000001;position:fixed;top:0px;left:220px;background-image:url('<%=mainAppPath%>/images/unsaved-bg.gif');background-repeat:no-repeat;width:500px;height:22px;display:none;font-weight:bold;padding:0px 0px 0px 0px;"><table style="width:100%;">
<tr><td align="center">
All changes saved to draft &ndash; <a href="javascript:void(0)" onclick="clickSave();" style="color:blue;">Click&nbsp;to&nbsp;publish&nbsp;now</a> &ndash; (Keyboard&nbsp;shortcut:&nbsp;Ctrl+S)</td></tr></table>
</div>
<%next%>
<%End if%>

<div style="position:relative;width:100%;">
<div id="unsavedChangesPdfProcessing" style="z-index:80;background-color:#b7d29c;background-repeat:no-repeat;width:80%;height:22px;font-weight:bold;padding:0px 0px 0px 0px;margin:0 auto;<%If subSectionId="dashboard" And request.querystring("id") <> "" then%>display:block;<%else%>display:none;<%End if%>"><table style="width:100%;">
<tr><td align="center" style="background-color:#b7d29c;">
<%
	If request.querystring("witness") = "1" then
		If request.querystring("reject") = "1" then
			%>Rejection<%
		else
			%>Witnessing<%
		End if
		%> in progress.<%
	else
		%>Your PDF is being processed.<%
	End if
	%>  You may continue working.  <a href="signed.asp?id=<%=request.querystring("id")%>&experimentType=<%=request.querystring("experimentType")%>&revisionNumber=<%=request.querystring("revisionNumber")%>">Click here</a> to return to <%
	If request.querystring("witness") = "1" then
		%>the<%
	Else
		%>your<%
	End If
	%> experiment.</td></tr></table>
</div>
</div>

<div id="noteSaved" style="position:absolute;top:-24px;left:220px;background-image:url('<%=mainAppPath%>/images/unsaved-bg.gif');background-repeat:no-repeat;width:330px;height:22px;display:none;font-weight:bold;padding:0px 0px 0px 0px;">
<table style="width:100%;">
<tr><td align="center">
Your note has been added</td></tr></table>
</div>

<div id="oldVersionWarning" style="position:fixed;top:124px;left:35%;background-image:url('<%=mainAppPath%>/images/unsaved-bg-large.gif');background-repeat:no-repeat;width:660px;height:22px;display:none;font-weight:bold;padding:0px 0px 0px 0px;"><table style="width:100%;">
<tr><td align="center">
Warning! There is a newer version of this experiment. Changes will not be saved.</td></tr></table>
</div>

<%If subSectionId="experiment" or subsectionId="bio-experiment" or subsectionId = "free-experiment" or subsectionId = "anal-experiment" or subsectionId = "cust-experiment" or subsectionId="experiment" or subsectionId="show-notebook" or subsectionId="show-project" then%>

<script src="/arxlab/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript">
	window.userInfo = {
		id: "<%=session("userId")%>",
		role: "<%=session("role")%>",
		email: "<%=session("email")%>",
		firstName: "<%=session("firstName")%>",
		lastName: "<%=session("lastName")%>",
		name: "<%=session("firstName") & " " & session("lastName")%>"
	}

	function openInfo()
	{
		document.getElementById("infoFrame").style.display = "block";
		document.getElementById("infoDiv").style.display = "block";
		document.getElementById("infoLink").title = "Hide Info";
		document.getElementById("infoLink").onclick = closeInfo;
		try{
			closeComments();
		    }catch(err){}
		if (document.getElementById("experimentAccessDiv").innerHTML == '')
		{
			getAccessInfo();
		}
	}

	window.browserInfo = getBrowserInfo();
    if($.isArray(window.browserInfo)){
    	window.browserInfo = window.browserInfo[0];
    }

	function closeInfo()
	{
		document.getElementById("infoFrame").style.display = "none";
		document.getElementById("infoDiv").style.display = "none";
		document.getElementById("infoLink").title = "Show Info";
		document.getElementById("infoLink").onclick = openInfo;
	}

	function updateCommentHeight()
	{
		document.getElementById("commentsInnerHolderDiv").style.display = "block";
		document.getElementById("commentsInnerHolderDiv").style.right = "-1000px";
		document.getElementById("commentsDiv").style.display = "block";
		commentHeight = document.getElementById("commentsInnerHolderDiv").clientHeight;
		document.getElementById("commentsDiv").style.display = "none";
		document.getElementById("commentsInnerHolderDiv").style.right = "0px";
		if (commentHeight + 250 >= document.body.clientHeight)
		{
			document.getElementById("commentsInnerHolderDiv").style.height = (document.body.clientHeight-250)+"px"
		}
		<%if subsectionId = "experiment" then%>
			if (commentHeight < 350)
			{
				document.getElementById("cdCommentsLink").style.display = "block"
			}
		<%end if%>
	}
	 userList = [];    // the users you can @
	 userListIncludingSelf = []; // is filled with the contents of userList plus the current user
	 notifiedUserList = [];   // the users who will get a notification
	 commentList = [];        // all the comment information
	 currentParentCommentId = 0;   //   to catch the comment been replied
	 cancelBtnQueue = [];     // to make sure there is only one cancel button on the board
     MAX_LVL = 8
   
	
 
   

    // activated when user click the Reply button
    function replyComment(id){
    	//change the css
    	var replyBtn = document.getElementById("replyBtn-"+id);
    	replyBtn.innerHTML = "Cancel";
    	replyBtn.setAttribute("onclick","cancelReply("+id+")")
    	var currentCommentDiv = document.getElementById("comment-"+id);
    	$(currentCommentDiv).css("background-color","#f9f9f9") 

    	// get the text of the parent comment
    	var parentCommentAuthorName = $('#comment-'+id+' .commentName').text()
    	var parentCommentText = $('#comment-'+id+' .commentComment').text()
    	var parentNotifiedUser = []
    	var commentText = ""
    	for(var i =0;i<userList.length;i++){
			if(parentCommentText.indexOf(userList[i].value) !== -1 || parentCommentAuthorName.indexOf(userList[i].name) !== -1){
    			parentNotifiedUser.push(userList[i].value)
    		}
    	}
    	
    	// inherit the @ed users from parent
    	for(var j = 0; j<parentNotifiedUser.length;j++){
    		mentionSeparator = ", ";
    		if((parentNotifiedUser.length - 1) == j){
    			mentionSeparator = " ";
    		}
    		commentText = commentText +parentNotifiedUser[j] + mentionSeparator;
    	}
          
    	$('textarea#comment').val(commentText);
      	var addBtn = document.getElementById("submitCommentBtn");
    	addBtn.setAttribute("value","Add Reply");
    	addBtn.setAttribute("onclick","addReplyComment("+id+")");
    	currentParentCommentId = id
    	cancelBtnQueue.push(id)
          

    	//to make sure there is only one comment div been selected
    	if(cancelBtnQueue.length>1){
    		var i = cancelBtnQueue.shift();
    		var prevCommentDiv = document.getElementById("comment-"+i);
    		$(prevCommentDiv).css("background-color","#eeeeee") 
    		var prevReplyBtn = document.getElementById("replyBtn-"+i);
    		prevReplyBtn.innerHTML = "Reply";
    		prevReplyBtn.setAttribute("onclick","replyComment("+i+")")  
    	}
    	  
    	$('#commentsDiv #comment').focus();
    	$('#commentsDiv #comment').val($('#commentsDiv #comment').val()); // Moves cursor to the end of the textarea's content
    }

    // get the ids of the to-be-deleted comment and its children
	function getDeleteList(id){

	  if(typeof(commentParent[id]) == "undefined"){
	    deleteList.push(id)
	  }
	  else{
	    deleteList.push(id)
	    try{
	      commentParent[id].forEach(function(comment){
               getDeleteList(comment["id"])
	       })
	    }catch(err){}
	  }

}

// called when the Delete button clicked
function deleteComment(commentId)
{
	deleteList = []
	getDeleteList(commentId);
	if (confirm("Are you sure you wish to delete this comment?"))
	{
		$.ajax({ 
			type: "POST",   
			url: "<%=mainAppPath%>/experiments/delete-comment.asp",  
			dataType:'text',
			data:{commentId:deleteList},
			success : function(result)
			{
				for(var i = 0;i<deleteList.length;i++)
					document.getElementById("comment-"+deleteList[i]).style.display = "none"
			},
			error: function()
			{
				console.log("Ajax call to get user list failed")
				userList = []
				userListIncludingSelf = []
			}
		});
	}
}

	function changeActiveCommentsTagsTab(tabToActivate){
		if(tabToActivate == "comments" && !$('.commentsTagsTab.commentsTab').hasClass('activeTab')){
			$('.commentsTagsTab.activeTab').removeClass('activeTab');
			$('.commentsTagsTab.commentsTab').addClass('activeTab');
			$('.commentsTagsTabContent').removeClass('activeTabContent');
			$('.commentsTagsTabContent.commentsTabContent').addClass('activeTabContent');
		}
		else if(tabToActivate == "tags" && !$('.commentsTagsTab.tagsTab').hasClass('activeTab')){
			$('.commentsTagsTab.activeTab').removeClass('activeTab');
			$('.commentsTagsTab.tagsTab').addClass('activeTab');
			$('.commentsTagsTabContent').removeClass('activeTabContent');
			$('.commentsTagsTabContent.tagsTabContent').addClass('activeTabContent');
		}
		setUserOption('lastViewedCommentsTags',tabToActivate);
	}

	function addTagToExperiment(tagText, tagId){
		$.ajax({
			url: '<%=mainAppPath%>/experiments/add-tag.asp',
			type: 'POST',
			dataType: 'html',
			data: {tagText: tagText, experimentId: "<%=experimentId%>", experimentType: "<%=experimentType%>", random: Math.random()},
		})
		.done(function() {
			$('.addedTagsContainer').append('<div class="individualAddedTagOuter" tagid="' + tagText + '"><div class="individualAddedTag"><div class="tagText">' + tagText + '</div><div class="removeTag">x</div></div></div>');
		});	
	}
	
	function removeTag(tagText){
		$.ajax({
			url: '<%=mainAppPath%>/experiments/remove-tag.asp',
			type: 'POST',
			dataType: 'html',
			data: {tagText: tagText, experimentId: "<%=experimentId%>", experimentType: "<%=experimentType%>"},
		})
		.done(function() {
			$('.individualAddedTagOuter[tagid="' + tagText + '"]').remove();
			var currentSelectTwoValue = $('#addTagBoxDropdown').select2("val");
			currentSelectTwoValue = jQuery.grep(currentSelectTwoValue, function(value) {
					// Remove the matched item from the array
					return value != tagText;
				});
			$('#addTagBoxDropdown').select2("val",currentSelectTwoValue);
		});
	}

	function getTagsOfExperiment(){
		$.ajax({
			url: '<%=mainAppPath%>/experiments/ajax/load/getTagsOfExperiment.asp',
			type: 'GET',
			dataType: 'html',
			data: {experimentId: "<%=experimentId%>", experimentType: "<%=experimentType%>"},
		})
		.done(function(response) {
			var sortedResponse = $(response);
			sortedResponse.sort(function(a, b) { return $(a).text() > $(b).text() ? 1 : -1; });
			sortedResponse.each(function(experimentTagIndex, experimentTag){
				var tagId = $(this).attr('value');
				var userId = $(this).attr('userid');
				window.allTagsForCompany.each(function(companyTagIndex, companyTag){
					if($(this).attr('value') == tagId){
						var thisTagHTML = '<div class="individualAddedTagOuter" tagid="' + tagId + '"><div class="individualAddedTag">';
						if(userId == '<%=session("userId")%>' || "<%=session("role")%>" == "Admin"){
							thisTagHTML += '<div class="tagText">' + $(companyTag).text() + '</div><div class="removeTag">x</div>'
						}
						else{
							thisTagHTML += '<div class="tagText" style="padding-right: 7px;">' + $(companyTag).text() + '</div>';
						}
						thisTagHTML += '</div></div>';
						$('.addedTagsContainer').append(thisTagHTML);
					}
				});
				// Make this tag selected in the Select2 box
				var currentSelectTwoValue = $('#addTagBoxDropdown').select2("val");
				currentSelectTwoValue.push(tagId);
				$('#addTagBoxDropdown').select2("val",currentSelectTwoValue);
			});
		});
	}

	function loadTagsIntoPage(){
		$.ajax({
			url: '<%=mainAppPath%>/experiments/ajax/load/getTags.asp',
			type: 'POST',
			dataType: 'html'
		})
		.done(function(response) {
			window.allTagsForCompany = $(response);
			window.allEnabledTagsForCompany = [];
			window.allTagsForCompany.each(function(i){
				if($(this).attr('tagdisabled') == "0"){
					window.allEnabledTagsForCompany.push($(this));
				}
			});

			$('#addTagBoxDropdown').append(window.allEnabledTagsForCompany);
			window.tagsAlreadyLoaded = true;

			$("#addTagBoxDropdown").select2();

			getTagsOfExperiment();

			$("#addTagBoxDropdown").on("change", function(option) {
			    var addedTagText = option.added.element[0].value;
			    // Check to see if company has disabled the given tag
			    window.allTagsForCompany.each(function(){
			    	if($(this).attr('value') == addedTagText && $(this).attr('tagdisabled') == "0"){
			    		addTagToExperiment(addedTagText, $(this).attr('tagid'));
			    	}
			    })
			    	
			    setTimeout(function() {
			   		// Focus on the select2 again (currently blocks the input element so disabled...):
			        //$('#addTagBoxDropdown').select2('open');
			    }, 110);
			});

			$('.addedTagsContainer').on('click', '.removeTag', function(event) {
				var tagText = $(this).parent().parent().attr('tagid');
				removeTag(tagText);
			});
		})
	}
</script>

<script type="text/javascript">
	var infoSack = new sack();
	
	function getAccessInfo()
	{
		<%if subsectionId = "cust-experiment" or subsectionId = "anal-experiment" or subsectionId = "bio-experiment" or subsectionId = "free-experiment" or subsectionId = "experiment" then%>
		infoSack.requestFile = "<%=mainAppPath%>/experiments/ajax/load/getExperimentAccess.asp?notebookId=<%=notebookId%>&experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&random="+Math.random();
		<%end if%>
		<%if subsectionId = "show-notebook" then%>
		infoSack.requestFile = "<%=mainAppPath%>/experiments/ajax/load/getNotebookAccess.asp?notebookId=<%=notebookId%>&random="+Math.random();
		<%end if%>
		<%if subsectionId = "show-project" then%>
		infoSack.requestFile = "<%=mainAppPath%>/experiments/ajax/load/getProjectAccess.asp?projectId=<%=projectId%>&random="+Math.random();
		<%end if%>
		infoSack.onCompletion = getAccessInfoComplete;
		infoSack.runAJAX();
	}

	function getAccessInfoComplete()
	{
		document.getElementById("experimentAccessDiv").innerHTML = infoSack.response
	}
</script>

<script type="text/javascript">
	function encodeIt(str){
	if(!str){
		return "";
	}
	 var aStr = str.split(''),
	     i = aStr.length,
	     aRet = [];
	   while (--i>=0) {
	    var iC = aStr[i].charCodeAt();
	    if (iC> 255) {
	      aRet.push('&#'+iC+';');
	    } else {
	      aRet.push(aStr[i]);
	    }
	  }
	 return aRet.reverse().join('');
	}

   // reset the css when the reply is canceled
	function cancelReply(id){
	  var replyBtn = document.getElementById("replyBtn-"+id)
	      replyBtn.innerHTML = "Reply";
	      replyBtn.setAttribute("onclick","replyComment("+id+")")
	  $(document.getElementById("comment-"+id)).css("background-color","#eeeeee") 
	  var addBtn = document.getElementById("submitCommentBtn");
	      addBtn.setAttribute("value","Add Comment");
	      addBtn.setAttribute("onclick","addComment()");
	  currentParentCommentId = 0
	}

		
	function insertAfter(parent, node, referenceNode) {
	  parent.insertBefore(node, referenceNode.nextSibling);
	} 

	function showCommentAndCommentAttachmentDeleteButtons(){
		if(typeof window.showCommentAndCommentAttachmentDeleteButtonsDelay !== "undefined"){
			clearTimeout(window.showCommentAndCommentAttachmentDeleteButtonsDelay)
		}
		window.showCommentAndCommentAttachmentDeleteButtonsDelay = setTimeout(function(){
			// Delete buttons are hidden by default - remove the visibility class on all comments, then find the comment with the greatest commentId + userId==current user
			$('#commentsDiv .commentDiv').removeClass('makeDeleteButtonsVisible');
			if($('#commentsDiv .commentDiv[commenterid="'+thisUserId+'"]').length > 0){
				commentElementToMakeVisible = $('#commentsDiv .commentDiv[commenterid="'+thisUserId+'"]').last();
				$('#commentsDiv .commentDiv[commenterid="'+thisUserId+'"]').each(function(){
					if(parseInt(commentElementToMakeVisible.attr('commentid')) < parseInt($(this).attr('commentid'))){
						commentElementToMakeVisible = $(this);
					}
				});
				commentElementToMakeVisible.addClass('makeDeleteButtonsVisible');
				$('#commentsTabContentInner').scrollTop(commentElementToMakeVisible.offset().top - commentElementToMakeVisible.offsetParent().offset().top + 83)
				if(window.experimentCommentWasAdded){
					commentElementToMakeVisible.effect("highlight", {}, 800)
				}
			}
		},600);
	}

	// generate the raw comment div 
	function createSingleCommentDiv(comment){
        var experimentId = "<%=experimentId%>";
        var experimentType = "<%=experimentType%>";
		var commentDiv = document.createElement("div");
			commentDiv.className = "commentDiv";
			if(comment["deleted"]){
				commentDiv.className = "commentDiv commentDeleted"
			}
			commentDiv.id = "comment-" + comment["id"];
			commentDiv.setAttribute("style", "padding-top:4px;padding-right:5px;padding-left:5px;min-height:80px;position:relative;border-bottom:1px solid #9a9a9a;"); 
			commentDiv.setAttribute("commenterid", comment["userId"])
			commentDiv.setAttribute("commentid", comment["id"])


	    var leftDiv = document.createElement("div")
			leftDiv.setAttribute("style","width:70%;float:left;")
	    var rightDiv = document.createElement("div")
			rightDiv.setAttribute("style","width:30%;float:right;")
			rightDiv.setAttribute("class","commentAttachmentsSection")


        var userLink = document.createElement("a");
            userLink.setAttribute("href","<%=mainAppPath%>/users/user-profile.asp?id="+comment["userId"]);
            userLink.setAttribute("style","text-decoration:none;");
	    var nameSpan = document.createElement("span");
			nameSpan.className = "commentName";
			nameSpan.innerHTML = comment["userName"];
	    userLink.appendChild(nameSpan);
		var dateSpan = document.createElement("span");
			dateSpan.className = "commentDate";
			dateSpan.id = "comment-"+comment["id"]+"-date"
			dateSpan.innerHTML = comment["dateSubmitted"];
		userLink.appendChild(dateSpan)
        leftDiv.appendChild(userLink)
			

		var commentCommentDiv = $('<div id="commentComment-'+comment["id"]+'" class="commentComment" style="word-wrap:break-word;margin-bottom:20px;"></div>');
		commentCommentDiv.html(comment["comment"]);
		$(leftDiv).append( $('<div>').append(commentCommentDiv.clone()).html().replace(/\n/g, "<br />") );
		var bottomDiv = document.createElement("div");
			bottomDiv.setAttribute("style","position:absolute;margin:5px;bottom:0");
		
		var replyBtn = document.createElement("a");
			replyBtn.setAttribute("href","javascript:void(0);");
			replyBtn.className = "littleButton replyButton"
			replyBtn.id = "replyBtn-"+ comment["id"]
			replyBtn.setAttribute("onclick","replyComment(" + comment["id"] + ")" );
			replyBtn.setAttribute("style","margin-right:20px;position:relative;");
			replyBtn.innerHTML = "Reply";
		bottomDiv.appendChild(replyBtn);

		if(thisUserId == comment["userId"]){
			commentDiv.setAttribute("ondragover","dragFileOver(event," + comment["id"] + ")")
			commentDiv.setAttribute("ondragleave","dropLeave(event," + comment["id"] + ")")
			commentDiv.setAttribute("ondrop","dropLeave(event," + comment["id"] + ")")
			var commentDeleteBtn = document.createElement("a");
			    commentDeleteBtn.className = "littleButton experimentCommentDeleteButton";
			    commentDeleteBtn.innerHTML = "Delete";
			    commentDeleteBtn.setAttribute("href","javascript:void(0);");
			    commentDeleteBtn.setAttribute("style","margin-right:20px;position:relative;");
			    commentDeleteBtn.setAttribute("onclick","deleteComment("+comment["id"]+");" );
		  	bottomDiv.appendChild(commentDeleteBtn);

            var isIE = /*@cc_on!@*/false || !!document.documentMode;
            if(isIE == false){
            var uploadDropDiv = document.createElement("div")
			    uploadDropDiv.innerHTML = "Drag your file here to upload."
			    uploadDropDiv.id = "fileupload-"+comment["id"]
			    rightDiv.appendChild(uploadDropDiv)
            }

			if(!(document.all && !document.addEventListener)){ // If NOT IE8 or below
				var uploadForm = document.createElement("form")
				    uploadForm.id = "uploadform-"+comment["id"]
				    uploadForm.setAttribute("method","post")		    
				    uploadForm.setAttribute("action","<%=mainAppPath%>/experiments/commentAttachmentUpload.asp?source="+window.browserInfo+"&commentId="+comment["id"]+"&experimentType="+experimentType+"&experimentId="+experimentId+"&userId="+comment["userId"])
				    uploadForm.setAttribute("onsubmit","event.preventDefault();")
				    uploadForm.setAttribute("ENCTYPE","multipart/form-data")
				var selectFileButton = document.createElement("input")
				    selectFileButton.setAttribute("type","file")
				    selectFileButton.setAttribute("name","file")
				    selectFileButton.setAttribute("style","text-align: center;font-size:11px;margin:5px")
				uploadForm.appendChild(selectFileButton)
				var submitFileButton = document.createElement("input")
				    submitFileButton.setAttribute("type","submit")
				    submitFileButton.setAttribute("value","Submit")
				    submitFileButton.setAttribute("onclick","fileUploadIframe("+comment["id"]+")")
				    submitFileButton.setAttribute("style","text-align: center;font-size:12px;margin:5px")
				uploadForm.appendChild(submitFileButton)
				rightDiv.appendChild(uploadForm)
			}
		}

		var attachmentList = document.createElement("ul")
		    attachmentList.id = "commentAttachmentList-"+comment["id"]

          if(comment["attachment"].length > 0){
	          comment["attachment"].forEach(function(attachment){
	             var attachmentItem = document.createElement("li")
	             attachmentItem.id = "attachment-"+attachment["attachmentId"]
        	     var downloadLink = document.createElement("a")
			     downloadLink.setAttribute("href","<%=mainAppPath%>/experiments/commentAttachmentDownload.asp?commentId="+comment["id"]+"&experimentType="+experimentType+"&experimentId="+experimentId+"&userId="+comment["userId"]+"&attachmentId="+attachment["attachmentId"])
			     downloadLink.innerHTML=attachment["filename"]
				 attachmentItem.appendChild(downloadLink)		     
			     if(thisUserId == comment["userId"]){
			         var deleteBtnContainer = document.createElement("div")
			         deleteBtnContainer.setAttribute("class","experimentCommentAttachmentDeleteButtonContainer")
			         var deleteBtn = document.createElement("button")
			         deleteBtn.innerHTML = "Delete"
			         deleteBtn.setAttribute("style","font-size:13px;padding:3px 4px;margin-left:6px;margin-top:2px;")
			         deleteBtn.setAttribute("onclick","deleteCommentAttachment("+attachment["attachmentId"]+")")
			         deleteBtn.setAttribute("class","experimentCommentAttachmentDeleteButton")
			         deleteBtnContainer.appendChild(deleteBtn)
			         attachmentItem.appendChild(deleteBtnContainer)
			     }
			     attachmentList.appendChild(attachmentItem) 
            })
         }
         rightDiv.appendChild(attachmentList)


         var uploadingDiv = document.createElement("div")
             uploadingDiv.setAttribute("style","display:none")
             uploadingDiv.id = "attachmentUploading-"+ comment["id"]
             uploadingDiv.innerHTML ="Uploading file"
         var uploadingImg = document.createElement("img")
             uploadingImg.setAttribute("src","<%=mainAppPath%>/jqfu/img/loading.gif")
             uploadingImg.setAttribute("style","margin-left:10px;width:13px;height:13px")
             uploadingDiv.appendChild(uploadingImg)
            
         rightDiv.appendChild(uploadingDiv)
	
		 var br = document.createElement("br")
	         br.setAttribute("style","clear:both")
         leftDiv.appendChild(bottomDiv);
	     commentDiv.appendChild(rightDiv)
		 commentDiv.appendChild(leftDiv)	
		 commentDiv.appendChild(br)		

		return commentDiv;
	}

function deleteCommentAttachment(attachmentId){
	if (confirm("Are you sure you wish to delete this attachment?"))
	{
		$.ajax({ 
			type: "POST",   
			url: "<%=mainAppPath%>/experiments/commentAttachmentDelete.asp",  
			data:{attachmentId:attachmentId},
			success : function(result)
			{
				document.getElementById("attachment-"+attachmentId).setAttribute("style","display:none")
			},
			error: function()
			{
				console.log("Ajax call to delete attachment list failed");
				userList = [];
				userListIncludingSelf = [];
			}
		}); 
	}
}
	
function createCommentDiv(i,level)
{               
   if(typeof(commentParent[i]) != "undefined")
   {
		for(var k =commentParent[i].length-1; k>-1;k--)
		{
			var comment = commentParent[i][k]
			console.log(comment)
			console.log(level)
			if(level >= MAX_LVL)
			{
				var parentId = comment["parentId"];
				var parentDiv = document.getElementById("comment-"+parentId);
				var commentDiv = createSingleCommentDiv(comment);
				$(commentDiv).css("margin-left",4*(level-1)+"%")  
				try
				{
					$(commentDiv).insertAfter(parentDiv);
					//document.getElementById("replyBtn-"+comment["id"]).setAttribute("style","display:none")
				}catch(err){} 
			}	 
			else if(level == 1)
			{
				var commentDiv = createSingleCommentDiv(comment);
				$("#commentsTabContentInner").prepend(commentDiv);
			}
			else if(level == 0){}
			else
			{
				var parentId = comment["parentId"];
				var parentDiv = document.getElementById("comment-"+parentId);
				var commentDiv = createSingleCommentDiv(comment);
				$(commentDiv).css("margin-left",4*(level-1)+"%");
				try
				{
					$(commentDiv).insertAfter(parentDiv);
				}catch(err){} 
			}
		}
    }
  
    try{
        commentParent[i].forEach(function(comment)
		{
            createCommentDiv(comment["id"],level+1)
        });		
    }catch(err){}
}
    
function fileUploadIframe(id,attachedPreSubmit)
{
	if(typeof attachedPreSubmit !== "undefined"){ // Uploading attachment added before comment submission
		document.getElementById("fileUploadNewCommentAttachmentsForm").target = "fileupload_iframe";
		document.getElementById("fileUploadNewCommentAttachmentsForm").submit();
	}
	else{
		document.getElementById("uploadform-"+id).target = "fileupload_iframe";
	    document.getElementById("uploadform-"+id).submit();
    }
    setTimeout(function() {
         closeComments();
         openComments();
         $('#fileUploadNewCommentAttachmentsForm input[type="file"]').val('');
    }, 500);
	
}
 
    // insert the new added comment or reply
	function addCommentComplete(response)
	{
		 var newComment = response
		 var commentDiv = createSingleCommentDiv(newComment)
		 var newParentId = newComment["parentId"] 


        commentList.push(newComment)	

        
            //if it is a comment, append it to the container
            if(newParentId == 0){
             $('#commentsTabContentInner').append(commentDiv);
             var containerDiv = document.getElementById("commentsTabContentInner");
                 containerDiv.scrollTop = containerDiv.scrollHeight;
            }

            //if it is a reply, calculate its indentation first
            else{
               parentLeftMargin = document.getElementById("comment-" + newParentId).style.marginLeft        
               if(parentLeftMargin == (MAX_LVL-2)*4+"%"){
                   $(commentDiv).css("margin-left",parseInt(parentLeftMargin.substring(0,parentLeftMargin.length-1))+4+"%") 
                   //block the reply button
                   $("#replyBtn-" + newParentId)[0].setAttribute("style","display:none")            
               }else if(parentLeftMargin == ""){
                    $(commentDiv).css("margin-left","4%") 
               }
               else{
                   $(commentDiv).css("margin-left",parseInt(parentLeftMargin.substring(0,parentLeftMargin.length-1))+4+"%") 
               }
                
               // append the reply to the proper place

               // ascending depreciated
               if(typeof commentParent[newParentId] == "undefined"){
                  var parentDiv = document.getElementById("comment-"+newParentId);
                  $(commentDiv).insertAfter(parentDiv)
               }else{
               var len = commentParent[newParentId].length-1;
                  var lastSiblingDiv = document.getElementById("comment-"+commentParent[newParentId][len]["id"])

                  $(commentDiv).insertAfter(lastSiblingDiv)
               }
               
                // descending
                 // var parentDiv = document.getElementById("comment-"+newParentId);
                 // $(commentDiv).insertAfter(parentDiv)

            }
           


        if(typeof commentParent !== "undefined" && typeof commentParent[newParentId] == "undefined"){
           commentParent[newParentId] = []
           commentParent[newParentId].push(newComment)
         }
         else{
            commentParent[newParentId].push(newComment)
         }  
		

		document.getElementById("comment").value = "";
		var addBtn = document.getElementById("submitCommentBtn");
	    addBtn.setAttribute("value","Add Comment");
	    addBtn.setAttribute("onclick","addComment()");
	    currentParentCommentId = 0
		window.experimentCommentWasAdded = true;
	    showCommentAndCommentAttachmentDeleteButtons();
	}






function blackOn(){
	document.getElementById("blackFrame").style.display = "block";
}

function blackOff(){
	document.getElementById("blackFrame").style.display = "none";
}

function getUserList(){
	return new Promise(function(resolve, reject) {
		$.ajax({ 
			type: "GET",   
			url: "<%=mainAppPath%>/ajax_loaders/getUsersWhoCanViewThisExperiment.asp",  
			dataType:"text",
			data:{experimentId:"<%=experimentId%>",experimentType:"<%=experimentType%>"},
			success : function(text)
			{
				data = eval(text);
				for(var i=0; i<data.length;i++)
				{
					var elem = {
						value: "@" + data[i]["name"]+ "(" + data[i]["email"] + ")",
						text:   data[i]["name"]+ "(" + data[i]["email"] + ")",
						id: data[i]["id"],
						name:  data[i]["name"]
					};
					
					userList.push(elem)           
				}
				updateUserList();
				resolve(true);
			},
			error: function()
			{
				console.log("Ajax call to get user list failed");
				userList = [];
				userListIncludingSelf = [];
				reject(true);
			}
		}); 
	});
}

	function getComments(){
			    $.ajax({
					type: "POST",   
					url: "<%=mainAppPath%>/ajax_loaders/getComments.asp",  
					dataType:'text',
					data:{experimentId:"<%=experimentId%>",experimentType:"<%=experimentType%>"},
					success : function(text){
						data = eval(text)
                    	for(var i=0; i<data.length;i++){
                            if(typeof data[i]["deleted"] == "undefined"){
                            	data[i]["deleted"] = False;
                            }
                            var elem = {
								id: data[i]["id"],
								userId:   data[i]["userId"],
								userName: data[i]["userName"],
								dateSubmitted:  data[i]["dateSubmitted"],
								parentId : data[i]["parentCommentId"],
								comment : data[i]["comment"],
								attachment : data[i]["attachment"],
								deleted : data[i]["deleted"]
                            }
                            commentList.push(elem)           
                       	}

						commentParent = {}
						commentList.forEach(function(comment){
							if(typeof commentParent[comment["parentId"]] == "undefined"){
								commentParent[comment["parentId"]] = []
								commentParent[comment["parentId"]].push(comment)
							}
							else{
							    commentParent[comment["parentId"]].push(comment)
							}
						})
						commentParent[-1]=[{id:0,userId:0,userName:"0",dateSubmitted:0,parentId:-1,
						                     comment:""}]

						createCommentDiv(-1,0);
						initFileUpload();
						showCommentAndCommentAttachmentDeleteButtons();
                    },
                   	error: function(){
						console.log("Ajax call to get user list failed")
						commentList = []
                    }
                }); 

	}

function dragFileOver(ev,id)
{
	ev.preventDefault();
	var currentCommentDiv = document.getElementById("comment-"+id);
	$(currentCommentDiv).css("background-color","#f9f9f9") 
}

function dropLeave(ev,id)
{
	ev.preventDefault();
	var currentCommentDiv = document.getElementById("comment-"+id);
	$(currentCommentDiv).css("background-color","#eeeeee") 
}


</script>

<%
Select Case subsectionId
	Case "experiment"
		top = "60px"
	Case "bio-experiment"
		top = "100px"
	Case "free-experiment"
		top = "100px"
	Case "anal-experiment"
		top = "100px"
End Select
If signedSection Then
	top = "40px"
End If
If subsectionId = "show-notebook" Or subsectionId = "show-project" Then
	top = "40px"
End if
%>


<div id="commentsDiv" style="border: 2px solid rgb(153, 153, 153);width: 80%;height: 85%;min-height: 280px;position: fixed;top: 10%;right: 10%;z-index: 10001;background-color: rgb(238, 238, 238);display: none;">

<div align="right" style="padding-right:4px;" id="commentsFirstDiv"><a href="javascript:void(0);" onclick="closeComments();window.experimentCommentWasAdded=false;" style="font-weight:bold;color:#555;text-decoration:none;">Close</a></div>
<div class="commentsTagsTabsContainer"><div class="commentsTagsTab commentsTab activeTab" onclick="changeActiveCommentsTagsTab('comments')">Comments</div><div class="commentsTagsTab tagsTab" onclick="changeActiveCommentsTagsTab('tags')">Tags</div></div>
<div class="commentsTagsTabContent commentsTabContent activeTabContent<% If hasCommentReplyButton = 1 Then response.write " hasCommentReplyButton" %><% If hasCommentDeleteButtons = 1 Then response.write " hasCommentDeleteButtons" %>" style="width: 100%;height: calc(100% - 58px);">
<div id="commentsTabContentInner" style="overflow-y:scroll;height: calc(100% - 102px);border-bottom:2px solid #999;">


</div>
<div id="addCommentDiv" style="width:100%;" align="center">
	<div class="commentTextareaUploadContainer">
		<div class="newCommentFormContainer">
			<form id="newCommentForm" class="newCommentForm" action="<%=mainAppPath%>/experiments/add-comment.asp" method="post" style ="padding-top: 9px;" align="center">
				<textarea id="comment" name="comment" style="height: 61px;min-height: 56px;display: inline-block;" resize="false"></textarea>
				<input type="button" class="createLink" id="submitCommentBtn" value="Add Comment" style="border: 1px solid #9e9e9e;background: #fff;padding: 3px 8px;display: block;font-size: 12px;margin: 6px auto 0 0;" onclick="addComment()">
			</form>
		</div>
		<div class="fileUploadNewCommentAttachmentsContainer">	
			<!-- Excluded the action value that was originally in the JS... -->
			<form id="fileUploadNewCommentAttachmentsForm" method="post" onsubmit="event.preventDefault();" ENCTYPE="multipart/form-data">
				<input type="file" name="file" id="fileUploadNewCommentAttachmentsFormFileInput" style="font-size:11px;margin: 1px 0 5px;width: 280px;">
				<input type="submit" value="Submit" onclick="fileUploadIframe(window.newAddedComment['id'],true)" id="fileUploadNewCommentAttachmentsFormSubmitButton" style="text-align:center;font-size:12px;margin: 5px auto 0 7px;display: none;">
				<button id="fileUploadNewCommentRemoveAttachmentButton">Remove Attachment</button>
			</form>
		</div>	
	</div>
</div>

</div><!-- comment tab (.commentsTabContent) -->

<div class="commentsTagsTabContent tagsTabContent">
	<div class="addedTagsContainer"></div>
	<div class="addTagBoxContainer">
		<div class="addTagBox"><select id="addTagBoxDropdown" class="addTagBoxDropdown" placeholder="Enter tag name" multiple="multiple"></select></div>
	</div>
</div><!-- tags tab (.tagsTabContent) -->
</div><!-- comment Holder div-->
<script src='/arxlab/js/horsey.js?<%=jsRev%>' type='text/javascript'></script>
 
<script type="text/javascript">
function openComments()
{	
	// reset data
	userList = [];
	userListIncludingSelf = [];
	deleteList = []
	commentList = [];
	thisUserId = <%=session("userId")%> ;
	currentParentCommentId = 0;
	blackOn();	

	// ajax call to fetch the data
	getUserList();	
	getComments();	            
	document.getElementById("commentsDiv").style.display = "block";
	document.getElementById("commentsLink").title = "Hide Comments";
	document.getElementById("commentsLink").onclick = closeComments;
	
	ajaxNoReturn("<%=mainAppPath%>/misc/ajax/do/clearCommentNotifications.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&random="+Math.random());
	if(!window.tagsAlreadyLoaded)
		loadTagsIntoPage();

	if(typeof window.userOptions["lastViewedCommentsTags"] !== "undefined" && window.userOptions["lastViewedCommentsTags"] == "tags")
			changeActiveCommentsTagsTab("tags");

	closeInfo();


	/*
	// This is the comment attachment functionality for adding attachments to new, not-yet-created comments. Some options are updated before the attachments are actually uploaded... This is commented out for now because we didn't have time to get drag & drop working
	if(!(document.all && !document.addEventListener)){ // If NOT IE8 or below
		$("#fileUploadNewCommentAttachments").fileupload({
			url: "",
			done: function(e,data)
			{
				var newAttachment = data.result;
				document.getElementById("attachmentUploading-"+newAttachment["commentId"]).setAttribute("style","display:none");
				var attachmentItem = document.createElement("li");
				attachmentItem.id = "attachment-"+newAttachment["attachmentId"];
				var downloadLink = document.createElement("a");
				downloadLink.setAttribute("href","<%=mainAppPath%>/experiments/commentAttachmentDownload.asp?commentId="+newAttachment["commentId"]+"&experimentType="+experimentType+"&experimentId="+experimentId+"&userId="+newAttachment["userId"]+"&attachmentId="+newAttachment["attachmentId"]);
				downloadLink.innerHTML=newAttachment["filename"];
				attachmentItem.appendChild(downloadLink);    
				var deleteBtn = document.createElement("button");
				deleteBtn.innerHTML = "Delete";
				deleteBtn.setAttribute("style","font-size:13px;padding:3px 4px;margin-left:6px;margin-top:2px;");
				deleteBtn.setAttribute("onclick","deleteCommentAttachment("+newAttachment["attachmentId"]+")");
				attachmentItem.appendChild(deleteBtn);
				document.getElementById("commentAttachmentList-"+newAttachment["commentId"]).appendChild(attachmentItem);
			},
			process: function(e,data)
			{
				var commentId = data.dropZone[0].id.substring(8)          
				//document.getElementById("attachmentUploading-"+commentId).setAttribute("style","display:inline")
			},
			dropZone: $("#addCommentDiv"),
	        pasteZone: $("#addCommentDiv"),
	        autoUpload: false
	    }).bind('fileuploadsubmit', function (e, data) {
			var newDataUrl = "<%=mainAppPath%>/experiments/commentAttachmentUpload.asp?source="+window.browserInfo+"&commentId="+newAddedComment["id"]+"&experimentType="+<%=experimentType%>+"&experimentId="+<%=experimentId%>+"&userId="+newAddedComment["userId"]
			data.url = newDataUrl;
		});
	}
	*/
}

function closeComments()
{
	blackOff();
	document.getElementById("commentsDiv").style.display = "none";
	document.getElementById("commentsLink").title = "Show Comments";
	document.getElementById("commentsTabContentInner").innerHTML ="";
}
/**
* Get the default config for JQFU that is used in the attachment screen
* @param {string} comment - the comment object that this attachment should be attached to
*/
function getFileUploadConfig(comment){
return {
		url:"<%=mainAppPath%>/experiments/commentAttachmentUpload.asp?source="+window.browserInfo+"&commentId="+comment["id"]+"&experimentType="+experimentType+"&experimentId="+experimentId+"&userId="+comment["userId"],
		done: function(e,data)
		{
			var newAttachment = data.result
			document.getElementById("attachmentUploading-"+newAttachment["commentId"]).setAttribute("style","display:none")
			var attachmentItem = document.createElement("li")
			attachmentItem.id = "attachment-"+newAttachment["attachmentId"]
			var downloadLink = document.createElement("a")
			downloadLink.setAttribute("href","<%=mainAppPath%>/experiments/commentAttachmentDownload.asp?commentId="+newAttachment["commentId"]+"&experimentType="+experimentType+"&experimentId="+experimentId+"&userId="+newAttachment["userId"]+"&attachmentId="+newAttachment["attachmentId"]);
			downloadLink.innerHTML=newAttachment["filename"]
			attachmentItem.appendChild(downloadLink)		     
			var deleteBtn = document.createElement("button")
			deleteBtn.innerHTML = "Delete"
			deleteBtn.setAttribute("style","font-size:13px;padding:3px 4px;margin-left:6px;margin-top:2px;")
			deleteBtn.setAttribute("onclick","deleteCommentAttachment("+newAttachment["attachmentId"]+")")
			attachmentItem.appendChild(deleteBtn)
			document.getElementById("commentAttachmentList-"+newAttachment["commentId"]).appendChild(attachmentItem)
		},
		process:function (e,data)
		{
			var commentId = data.dropZone[0].id.substring(8)          
			document.getElementById("attachmentUploading-"+commentId).setAttribute("style","display:inline")
		},
		add: function (e, data) {
			//for each file, replace every char in the filename with the unicode codepoint. This is to support non ascii text
			$.each(data.files, function (index, file) {
				var newname = data.files[index].name.replace(/./gim, function(i) {
					return '&#'+i.charCodeAt(0)+';';
				});

				// ASP doesn't like post data next to the file upload, so set the orginal file name in query params
				data.url = "<%=mainAppPath%>/experiments/commentAttachmentUpload.asp?source="+window.browserInfo+"&commentId="+comment["id"]+"&experimentType="+experimentType+"&experimentId="+experimentId+"&userId="+comment["userId"] + "&description=" + encodeURIComponent(newname);

				Object.defineProperty(data.files[index], 'name', {
					value: Math.random().toString(36).substring(2)
				});
			});
			//call the normal add function
			$.blueimp.fileupload.prototype.options.add.call(this, e, data);
		},
		dropZone: $("#comment-"+comment["id"]),
		pasteZone: $("#comment-"+comment["id"])
	}
}

 // called when replying someone's comment
function addReplyComment(id){
	var commentText = $("#comment").val(); //.replace(/\n/g," "); Don't want/need to replace newlines anymore - some people put lists in comments

		//make sure the comment is not blank
	if(commentText !== "")
	{
		// reset the cancel button queue
		cancelBtnQueue = [];
		notifiedUserList = [];
		var parentCommentId = id;	

		// disable the submit button to prevent multiple ajax call
		$(document.getElementById("submitCommentBtn")).attr("disabled",true)

		//reset the css of the selected comment div
		$(document.getElementById("comment-"+currentParentCommentId)).css("background-color","#eeeeee") 
		var replyBtn = document.getElementById("replyBtn-"+id);
		replyBtn.innerHTML = "Reply"
		replyBtn.setAttribute("onclick","replyComment("+id+")")
		
		if(document.getElementById("comment").value.substr(0,1) == "#")
		{
			alert("You can't start your comment with a '#'. Please use the 'Tags' tab to manage tags for this experiment.");
			$("#comment").focus();
			return false;
		}

			
		// search the comment text to find the users been @ed
		for(var i =0;i<userList.length;i++)
			if(commentText.indexOf(userList[i].value) !== -1)
				notifiedUserList.push(userList[i].id)

		// if the owner of the comment is not @ed, put him into the notifiedUserList, if he is already in it, do nothing 
		for(var i =0;i<commentList.length;i++)
		{
			if(commentList[i]["id"] == parentCommentId)
			{
				var inNotified = 0;
				var userId = commentList[i]["userId"];
				
				for(var k = 0;k<notifiedUserList.length;k++)
				{
					if(notifiedUserList[k] == userId)
						inNotified = 1;
				}
				
				if(inNotified == 0)
					notifiedUserList.push(userId)
			}
		}
		   
		//ajax call to submit the replied comment   
		$.ajax({
			type:"GET",
			url:"<%=mainAppPath%>/experiments/add-comment.asp",
			data:{comment:Encoder.htmlEncode(commentText),experimentId:"<%=experimentId%>",experimentType:"<%=experimentType%>",notifiedUserList:notifiedUserList,parentCommentId:currentParentCommentId},				
			success: function(response)
			{
				$(document.getElementById("submitCommentBtn")).attr("disabled",false);
				addCommentComplete(response)  

				if(!(document.all && !document.addEventListener)){ // If NOT IE8 or below
					window.newAddedComment = commentList[commentList.length-1];
					
					try{
						$('#fileUploadNewCommentAttachmentsForm').attr('action',"<%=mainAppPath%>/experiments/commentAttachmentUpload.asp?source="+window.browserInfo+"&commentId="+newAddedComment["id"]+"&experimentType="+experimentType+"&experimentId="+experimentId+"&userId="+newAddedComment["userId"])
						if($('#fileUploadNewCommentAttachmentsForm input[type="file"]').val() !== ""){
							$('#fileUploadNewCommentAttachmentsFormSubmitButton').click();
						}
					}
					catch(e){
						console.error(e);
					}

					$("#fileupload-"+newAddedComment["id"]).fileupload(getFileUploadConfig(newAddedComment)).bind('fileuploadadd', function (e, data) {
						if(!$(this).parent().parent().hasClass('makeDeleteButtonsVisible')){
							e.preventDefault();
							return false;
						}
				    });
				}
			},
			error:function()
			{
				notifiedUserList = [];
				console.log("Ajax call to add comment failed");
				alert("Add comment failed");
			}
		});
	}
}
 
function initFileUpload()
{
	console.log("init file upload");
	var experimentId = "<%=experimentId%>";
	var experimentType = "<%=experimentType%>";
	console.log("experimentType: ", experimentType, " experimentId: ", experimentId);
	for(var i=0;i<commentList.length;i++)
	{
		if(thisUserId == commentList[i]["userId"])
		{
			if(!(document.all && !document.addEventListener)){ // If NOT IE8 or below
				$("#fileupload-"+commentList[i]["id"]).fileupload(getFileUploadConfig(commentList[i])).bind('fileuploadadd', function (e, data) {
					if(!$(this).parent().parent().hasClass('makeDeleteButtonsVisible')){
						e.preventDefault();
						return false;
					}
			    });
			}
		}
    }
}

function addComment()
	{	
        var commentText = $("#comment").val(); //.replace(/\n/g," "); Don't want/need to replace newlines anymore - some people put lists in comments
		if(commentText.substr(0,1) == "#"){
			alert("You can't start your comment with a '#'. Please use the 'Tags' tab to manage tags for this experiment.");
			$("#comment").focus();
			return false;
		}

		
		if(commentText !== "")
		{
		cancelBtnQueue = []
	    $(document.getElementById("submitCommentBtn")).attr('disabled',true)
        notifiedUserList = []

		for(var i =0;i<userList.length;i++){
			if(commentText.indexOf(userList[i].value) !== -1){
				notifiedUserList.push(userList[i].id)
			}
		}


		$.ajax({
			url:"<%=mainAppPath%>/experiments/add-comment.asp",
			type:"GET",
			data:{comment:Encoder.htmlEncode(commentText),experimentId:"<%=experimentId%>",experimentType:"<%=experimentType%>",notifiedUserList:notifiedUserList},				
			success: function(response){
                addCommentComplete(response) 
   				$(document.getElementById("submitCommentBtn")).attr('disabled',false) 
				window.newAddedComment = commentList[commentList.length-1];
				
				try{
					$('#fileUploadNewCommentAttachmentsForm').attr('action',"<%=mainAppPath%>/experiments/commentAttachmentUpload.asp?source="+window.browserInfo+"&commentId="+newAddedComment["id"]+"&experimentType="+experimentType+"&experimentId="+experimentId+"&userId="+newAddedComment["userId"])
					if($('#fileUploadNewCommentAttachmentsForm input[type="file"]').val() !== ""){
						$('#fileUploadNewCommentAttachmentsFormSubmitButton').click();
					}
				}
				catch(e){
					console.error(e);
				}

                if(!(document.all && !document.addEventListener)){ // If NOT IE8 or below
                	$('#fileupload-'+newAddedComment["id"]).fileupload(getFileUploadConfig(newAddedComment)).bind('fileuploadadd', function (e, data) {
						if(!$(this).parent().parent().hasClass('makeDeleteButtonsVisible')){
							e.preventDefault();
							return false;
						}
				    });
				}
			},
			error:function(){
			   $(document.getElementById("submitCommentBtn")).attr('disabled',false)  
			   notifiedUserList = []
			   console.log("Ajax call to add comment failed")
			   alert("Add comment failed")
			}
		});
	}
}

function updateUserList(){
	if(!document.all){ // Do not run this code on IE 10/9/8
		if(typeof window.commentUserTypeaheadHorsey !== "undefined"){
			window.commentUserTypeaheadHorsey.destroy();
		}
		window.commentUserTypeaheadHorsey = horsey(document.querySelector("#comment"), {
		    source: [{ list:userList }],
		    getText: "text",
		    getValue: "value",
		    anchor: "@",
		    limit: 6
		});
	}
	userListIncludingSelf = userList;
	selfUser = {
		value: "@" + window.userInfo["name"]+ "(" + window.userInfo["email"] + ")",
		text:   window.userInfo["name"]+ "(" + window.userInfo["email"] + ")",
		id: window.userInfo["id"],
		name:  window.userInfo["name"]
	};
	userListIncludingSelf.push(selfUser)
}

function hideOrDisplayDiscard(element) {
	
	if (typeof isDraftAuthor === "undefined") {
		isDraftAuthor = true;
	}

	if ("<%=ownsExp%>" == "True" && !isDraftAuthor) {
		element = element.replace('class="discardDraftLink"', 'class="discardDraftLink hidden"');
	}
	return element;
}


</script>
	


<%End if%>

<script type="text/javascript">
	/**
	 * This is to check what browser the user is useing. 
	 * It will return false if IE and true if anything else. 
	 */
	function msieversion() {

		let ua = window.navigator.userAgent;
		let msie = ua.indexOf("MSIE ");

		if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))  // If Internet Explorer
		{
			return false;
		}
		else  // If another browser
		{
			return true;
		}

	}

	// check if we are useing IE and then skip if we are.
	if (msieversion()) {
		$.ajax({url:'/node/modalpopup'}).then(function(resp) {
			$("#reactDialogs").html(resp)

		});
	}
 </script>

<%'QQQ END remove experiment top button strip and marquee messages%>