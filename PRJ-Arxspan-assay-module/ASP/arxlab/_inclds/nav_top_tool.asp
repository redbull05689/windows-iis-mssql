<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))

' HELP SCRIPT #################################################
										helpId = ""
										Select Case subsectionId
											Case "show-notebook"
												helpId="1"
											Case "create-notebook"
												helpId="2"
											Case "dashboard"
												helpId="3"
											Case "experiment"
												helpId="4"
											Case "bio-experiment"
												helpId="4"
											Case "free-experiment"
												helpId="4"
											Case "my-profile"
												helpId="7"
										End select
										%>

								<script type="text/javascript">
									var helpId = "<%=helpId%>"
								</script>
<% ' HELP SCRIPT ################################################# %>

<div class="topSectionLower topSectionBottom">
	<div class="actionsSection">
		<div class="topSectionLowerButton topNavButton darker"><a href="<%=mainAppPath%>/table_pages/show-watchlist.asp"><%=watchlistLabel%></a></div>
		<div class="topSectionLowerButton topNavButton darker"><a href="<%=mainAppPath%>/table_pages/show-notebooks.asp?<%If session("roleNumber") <= 1 then%>all=true<%End if%>"><%=notebooksLabel%></a></div>
		<div class="topSectionLowerButton topNavButton darker"><a href="<%=mainAppPath%>/table_pages/show-projects.asp"><%=projectsLabel%></a></div>

		<div class="topSectionLowerButton topNavButton mainHelpButton"><a href="javascript:helpPopup('help/help-index.asp?id='+helpId,'',565,500)"><%=helpLabel%></a>
			<ul>
				<li><a href="javascript:helpPopup('help/help-index.asp?id='+helpId,'',565,500)"><%=showArxlabHelpLabel%> Notebook</a></li>
				<li><a href="javascript:helpPopup('help-reg/help-index.asp?id='+helpId,'',565,500)"><%=showArxlabHelpLabel%> Registration</a></li>
				<li><a href="javascript:helpPopup('help-inv/help-index.asp?id='+helpId,'',565,500)"><%=showArxlabHelpLabel%> Inventory</a></li>
			</ul>
		</div>
		<div class="topSectionLowerButton topNavButton"><a href="<%=mainAppPath%>/support-request.asp"><%=contactSupportLabel%></a></div>
		<%

		If session("companyId") = "4" then
			'QQQ This should be removed on standalone
			logoutStr = "logout.asp?m=t"
		else
			logoutStr = "logout.asp"
		End If
		%>
		<div class="topSectionLowerButton topNavButton"><a href="<%=mainAppPath%>/<%=logoutStr%>"><%=logoutLabel%></a></div>

	</div>
</div>

<% If thisSectionId = "inventory" Then %>
	<% If session("invRoleName") = "Admin" Then %>
		<div class="managementButtonsSection"><a href="objectTemplates/index.asp" class="adminOnlyButtons_manageObjectTypes">Manage Inventory Objects</a><a href="mappingTemplates/index.asp" class="manageMappingTemplatesButton">Manage Mapping Templates</a><%
		If whichClient = "BROAD" Then
			response.write "<a href=""sciQuestImport.asp"" class=""adminOnlyButtons_sciQuestImportButton"">SQ Import</a>"
		End If
		%></div>
	<% End If %>
<% End if %>
