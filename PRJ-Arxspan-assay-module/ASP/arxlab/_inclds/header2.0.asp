<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="common/functions/checkCompanyLogo.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	nonGXPLabel = checkBoolSettingForCompany("useNonGxpLabel", session("companyId"))
	redirectAssayToPlatform = checkBoolSettingForCompany("usePlatformAssay", session("companyId"))
%>

	<div class="topSectionOuter topSectionTop" class="redesigned2015">
		<div class="topSection">
			<% hasLogo = checkCompanyLogo() %>
			<div <% If hasLogo <> "" Then %> class="arxspanSideNobg" <% Else %> class="arxspanSide" <%End If%> >
				
				<% If hasLogo <> "" Then %><img class="companyHasLogo">
				<script type="text/javascript">
					el = document.getElementsByClassName("companyHasLogo")[0];
					el.src = "<%=mainAppPath%>/experiments/ajax/load/getCompanyLogo.asp"
				</script>
				<%End If%>
				<a href="<%=mainAppPath%>/dashboard.asp" <% If hasLogo <> "" Then %> class="arxspanSideTextWithLogo" <% Else %> class="arxspanSideText" <%End If%>>&nbsp;</a>
				<div class="nameAndCompany">
					<div class="nameSection"><%=welcomeLabel%>
						<span class="headUserName">
							<a href="/arxlab/users/my-profile.asp"><%=session("firstName") & " " & session("lastName")%></a>
						 </span>
					</div>
		            <div id="nonGxpDiv" class="companySection"><%If nonGXPLabel then%>Non-GxP&nbsp;<%End if%><%=session("companyName")%></div>
		        	<div id="languageSelect" style="font-size: 20px;">
							<a href="javascript:void(0);" onclick="setUserOption('languageSelect','English',function(){window.location=window.location});" style="font-size: 20px;"><img src="/arxlab/images/small_flags/us.gif"></a>
							<a href="javascript:void(0);" onclick="setUserOption('languageSelect','Japanese',function(){window.location=window.location});" style="font-size: 20px;"><img src="/arxlab/images/small_flags/jp.gif"></a>
							<a href="javascript:void(0);" onclick="setUserOption('languageSelect','Chinese',function(){window.location=window.location});" style="font-size: 20px;"><img src="/arxlab/images/small_flags/cn.gif"></a>
					</div>
				</div>
			</div>
			<div class="rightSide">
				<%
				If sectionId <> "inventory" And sectionId <> "reg" And sectionId <> "assay" And sectionId <> "workflow" Then
					thisSectionId = "eln"
				Else
					thisSectionId = sectionId
				End if
				%>
				<%If session("hasELN") then	
					%><a href="<%=mainAppPath%>/dashboard.asp"><div class="topNavButton notebookNavButton<%If thisSectionId = "eln" then%> activeNavButton<%End if%>">ELN<%If thisSectionId = "eln" then%><div class="border-bottom-active-topnav topNavBorder"></div><%End if%></div></a><%
				End if
				If session("hasReg") And session("regRoleNumber") <> 1000 then
					%><a href="<%=mainAppPath%>/registration/search.asp"><div class="topNavButton registrationNavButton<%If thisSectionId = "reg" then%> activeNavButton<%End if%>">Bio/Chem&nbsp;Reg<%If thisSectionId = "reg" then%><div class="border-bottom-active-topnav topNavBorder"></div><%End if%></div></a><%
				End if
				If session("hasAssay") And (session("assayRoleName")="Admin" Or session("assayRoleName")="Power User" Or session("assayRoleName")="User") then
					%><a href="<%=mainAppPath%>/assay<%If redirectAssayToPlatform then%>2<%End if%>/index.asp"><div class="topNavButton assayNavButton<%If thisSectionId = "assay" then%> activeNavButton<%End if%>">Assay Reg<%If thisSectionId = "assay" then%><div class="border-bottom-active-topnav topNavBorder"></div><%End if%></div></a><%
				End if
				If session("hasInv") And (session("invRoleName")="Admin" Or session("invRoleName")="Power User" Or session("invRoleName")="User" Or session("invRoleName")="Reader") then
					%><a href="<%=mainAppPath%>/inventory2/index.asp"><div class="topNavButton inventoryNavButton<%If thisSectionId = "inventory" then%> activeNavButton<%End if%>">Inventory<%If thisSectionId = "inventory" then%><div class="border-bottom-active-topnav topNavBorder"></div><%End if%></div></a><%
				End if
				If session("hasFT") then
					%><a href="<%=mainAppPath%>/gotoFT.asp?lite="><div class="topNavButton ftNavButton">Search</div></a><%
				End if
				%>
			</div>
		</div>
	</div>