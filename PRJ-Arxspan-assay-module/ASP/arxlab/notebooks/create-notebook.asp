<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "create-notebook"
%>
<!-- #include file="../_inclds/globals.asp"-->

<!-- #INCLUDE file="../_inclds/users/functions/fnc_hasAutoNumberNotebooks.asp" -->
<!-- #INCLUDE file="../_inclds/notebooks/functions/fnc_createNewNotebook.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	groupNameInNotebook = getCompanySpecificSingleAppConfigSetting("addGroupNameToNotebookName", session("companyId"))
	pageTitle = "Arxspan Create Notebook"
%>
<%
Call getconnected
autoNumberNotebooks = hasAutoNumberNotebooks()
If request.Form <> "" Then
	notebookName = request.Form("notebookName")
	notebookDescription = request.Form("notebookDescription")
	Call getconnected
	Call getconnectedadm
	Set r = createNewNotebook(request.Form("notebookName"),request.Form("notebookDescription"),request.Form("linkProjectId"), request.Form("notebookGroup"))
	If r("success") then		
		response.redirect(mainAppPath&"/show-notebook.asp?id="&r("newId"))
	Else
		errorStr = r("errorStr")
		efields = r("efields")
	End If
	Call disconnectadm
End if
%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<%If canCreateNotebook(false) then%>
	<div class="dashboardObjectContainer createNotebook"><div class="objHeader elnHead"><h2><%=createNotebookLabel%></h2></div>

			<div class="objBody">

			<form name="searchForm" method="post" action="<%=mainAppPath%>/notebooks/create-notebook.asp">
				<%If errorStr <> "" then%>
				<p class="errorStr" style="color:red;"><%=errorStr%></p>
				<%End if%>
				<label for="notebookName"><span <%If InStr(efields,"notebookName") Then%>style="color:red;"<%End if%>>Name</span></label>
				<%If Not autoNumberNotebooks then%>
					<input type="text" name="notebookName" id="notebookName" value="<%=notebookName%>" style="width:300px;margin-left:12px;">
				<%else%>
					<input type="text" name="notebookNameOp" id="notebookNameOp" value="AUTO" readonly style="color:#aaa;border:none;margin-left:12px;">
				<%End if%>

				<label for="notebookDescription"><span <%If InStr(efields,"notebookDescription") Then%>style="color:red;"<%End if%>><%=notebookDescriptionLabel%></span></label>
				<textarea name="notebookDescription" style="width:300px;height:60px;margin:0;margin-left:12px;"><%=notebookDescription%></textarea>

				<%
				if (session("requireProjectLinkForNB") = session("requireProjectLink")) or (session("requireProjectLinkForNB") and not session("requireProjectLink")) then
					projectNameInNotebook = checkBoolSettingForCompany("useProjectNameInNotebookName", session("companyId"))
				%>
				<label for="linkProjectId"><span <%If InStr(efields,"linkProjectId") Then%>style="color:red;"<%End if%>>Project<%If session("requireProjectLinkForNB") Or projectNameInNotebook then%>*<%End if%></span></label>
				<br/>
				<!-- #include file="../_inclds/selects/writeProjects.asp"-->
				<br/>
				<%
				end if
				%>
				<%
				requireGroupFieldForNotebook = checkBoolSettingForCompany("requireGroupNameInNotebookName", session("companyId"))
				useGroupFieldForNotebook = checkBoolSettingForCompany("useGroupNameInNotebookName", session("companyId"))
				If useGroupFieldForNotebook then
				%>
				<label for=""><span <%If InStr(efields,"notebookGroup") Then%>style="color:red;"<%End if%>>Group<%If requireGroupFieldForNotebook Or (autoNumberNotebooks And groupNameInNotebook) then%>*<%End if%></span></label>
				<br/>
				<select name="notebookGroup" id="notebookGroup" style="width:300px;margin-left:12px;">
					<%thisGroupId= request.Form("notebookGroup")%>
					<!-- #include file="../_inclds/selects/groupSelectOptions.asp"-->
				</select>
				<br/>
				<%End if%>

				<input type="submit" value="<%=createNotebookLabel%>" name="createNotebook" class="btn">

				</form>
			</div>
			</div>
			<script type="text/javascript">
				if (window.attachEvent)
				{
					window.attachEvent("onload", function(){document.getElementById('notebookName').focus()})
				}else{addLoadEvent(function(){document.getElementById('notebookName').focus()})}
			</script>
<%else%>
<p>You are not authorized to create a notebook</p>
<%End if%>


<!-- #include file="../_inclds/footer-tool.asp"-->