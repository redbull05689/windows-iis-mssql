<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<%
sectionId = "create-project"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
	sectionID = "tool"
	subSectionID="create-project"
	terSectionID=""

	pageTitle = "Arxspan Create Project"
	metaD=""
	metaKey=""

%>
<%
requireGroupFieldForProject = checkBoolSettingForCompany("requireGroupNameInProjectName", session("companyId"))
useGroupFieldForProject = checkBoolSettingForCompany("useGroupNameInProjectName", session("companyId"))
'make canCreateProject function structure
If request.Form <> "" And session("canLeadProjects") Then
	efields = ""
	projectName = request.Form("projectName")
	projectDescription = request.Form("projectDescription")
	disableByDefault = request.form("disable")

	If Trim(projectName) = "" Then
		efields = efields & "projectName"
	End If
	If Len(projectName) > 150 Then
		errorStr = errorStr & "The maximum length for a project name is 150 characters."
		efields = efields & "projectName"
		projectName = Mid(projectName,1,150)
	End if
	If Len(projectDescription) > 500 Then
		errorStr = errorStr & "The maximum length for a project description is 500 characters."
		efields = efields & "projectDescription"
		projectDescription = Mid(projectDescription,1,500)
	End if

	singleGroupSelected = False
	singleGroupId = Trim(request.Form("projectGroup"))

	If useGroupFieldForProject Then
		If requireGroupFieldForProject And singleGroupId = "" Then
			efields = efields & "projectGroup"
			errorStr = errorStr & "You must select a group to create a project."
		End If
		If singleGroupId <> "" Then
			Set nRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM groupMembersView WHERE userId="&SQLClean(session("userId"),"N","S") & " AND groupId="&SQLClean(singleGroupId,"N","S")
			nRec.open strQuery,conn,3,3
			If nRec.eof Then
				efields = efields & "projectGroup"
				errorStr = errorStr & "You cannot select this group."
			End If
			nRec.close
			Set nRec = nothing
		End if
		If efields = "" Then
			If singleGroupId <> "" Then
				singleGroupSelected = True
			End if
		End if
	End if

	If efields = "" then
		Call getconnectedadm
		strQuery = "INSERT into projects(name,description,userId{visibleCol}) output inserted.id as newId values("&SQLClean(projectName,"T","S")&","&SQLClean(projectDescription,"T","S")&","&SQLClean(session("userId"),"N","S")&"{visibleVal})"

		visibleCol = ""
		visibleVal = ""
		if disableByDefault then
			visibleCol = ", visible"
			visibleVal = ", 0"
		end if
		strQuery = Replace(strQuery, "{visibleCol}", visibleCol)
		strQuery = Replace(strQuery, "{visibleVal}", visibleVal)

		Set rs = connAdm.execute(strQuery)
		newId = CStr(rs("newId"))
		projectId = newId
		originalProjectName = projectName
		projectName=""
		projectDescription = ""
		a = logAction(1,newId,"",15)

		if disableByDefault = "" then
			Call sendProjectInvites(projectId, originalProjectName)
		end if

		'START AUTO SHARE TO ADMINS/Group Managers also check do group auto share

		groupField = ""
		groupsToShareWith = ""
		Set gaRec = server.CreateObject("ADODB.RecordSet")
		If Not singleGroupSelected then
			groupField = "groupId"
			strQuery = "SELECT " & groupField & " FROM groupMembers WHERE userId="&SQLClean(session("userId"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
		Else
			groupField = "shareToGroupId"
			strQuery = "SELECT " & groupField & " FROM groupAutoShare WHERE groupId="&SQLClean(singleGroupId,"N","S")
		End If
		gaRec.open strQuery,connAdm,3,3
		groupCount = 0
		Do While Not gaRec.eof
			If singleGroupSelected Then
				groupCount = groupCount + 1
				groupsToShareWith = groupsToShareWith & gaRec(groupField) &","
			End If
			Set gaRec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT shareToGroupId FROM groupAutoShare WHERE groupId="&SQLClean(gaRec(groupField),"N","S")
			gaRec2.open strQuery,connAdm,3,3
			Do While Not gaRec2.eof
				groupCount = groupCount + 1
				groupsToShareWith = groupsToShareWith & gaRec2("shareToGroupId") &","
				gaRec2.movenext
			Loop
			gaRec2.close
			Set gaRec2 = nothing

			gaRec.movenext
		loop

		If groupCount >= 1 Then
			groupsToShareWith = Mid(groupsToShareWith,1,Len(groupsToShareWith)-1)
		End If

		groupsToShareWith = removeDuplicates(groupsToShareWith)			
		groups = Split(groupsToShareWith,",")
		
		For i = 0 To UBound(groups)
			strQuery = "INSERT into groupProjectInvites(projectId,sharerId,shareeId,canRead,canWrite,accepted,denied,readOnly) values(" &_
			SQLClean(newId,"N","S") & "," &_ 
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(groups(i),"N","S") & "," &_
			SQLClean("1","N","S") & "," &_
			SQLClean("0","N","S") & ",1,0,1)"
			'DEBUG
			connAdm.execute(strQuery)
		next

		'END AUTO SHARES

		If request.Form("ajax") = 1 Then
			set outJson = JSON.parse("{}")
			outJson.set "projectId", newId
			
			response.write JSON.stringify(outJson)
			response.end
		Else
			response.redirect(mainAppPath&"/show-project.asp?id="&newId)
		End If

	End if
End if
%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<%'create cancreateProject function%>
<%If session("canLeadProjects") then%>


	<div class="dashboardObjectContainer createNotebook"><div class="objHeader elnHead"><h2><%=createProjectLabel%></h2></div>

			<div class="objBody">

			<form name="searchForm" method="post" action="<%=mainAppPath%>/projects/create-project.asp">
				<%If errorStr <> "" then%>
				<p class="errorStr" style="color:red;"><%=errorStr%></p>
				<%End if%>
				<label for="projectName"><span <%If InStr(efields,"projectName") Then%>style="color:red;"<%End if%>>Name</span></label>
				<input type="text" name="projectName" id="projectName" value="<%=projectName%>" style="width:300px;">

				<label for="projectDescription"><span <%If InStr(efields,"projectDescription") Then%>style="color:red;"<%End if%>><%=projectDescriptionLabel%></span></label>
				<textarea name="projectDescription" style="width:300px;height:60px;margin-left:0px;margin-top:0px;"><%=projectDescription%></textarea>

				<%If useGroupFieldForProject then%>
				<label for=""><span <%If InStr(efields,"projectGroup") Then%>style="color:red;"<%End if%>>Group<%If requireGroupFieldForProject then%>*<%End if%></span></label>
				<br/>
				<select name="projectGroup" id="projectGroup" style="width:300px;">
					<%thisGroupId= request.Form("projectGroup")%>
					<!-- #include file="../_inclds/selects/groupSelectOptions.asp"-->
				</select>
				<br/>
				<%End if%>

				<input type="submit" value="<%=createProjectLabel%>" name="createProject" class="btn">

				</form>
			</div>
			</div>
			<script type="text/javascript">
				if (window.attachEvent)
				{
					window.attachEvent("onload", function(){document.getElementById('projectName').focus()})
				}else{addLoadEvent(function(){document.getElementById('projectName').focus()})}
			</script>
<%else%>
<p>You are not authorized to create a project</p>
<%End if%>


<!-- #include file="../_inclds/footer-tool.asp"-->