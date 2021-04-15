<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../../../_inclds/globals.asp"-->

<%
If cols = "" Then
	cols = 3
End if
projectId = request.querystring("id")
If ownsProject(projectId) Or isAdminUser(session("userId")) then
	call getconnected

	userCanRead = canReadProject(projectId,session("userId"))
	userCanWrite = canWriteProject(projectId,session("userId"))

	emptyRec = True
	Set inviteRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM groupProjectInvites WHERE projectId="&SQLClean(projectId,"N","S")
	inviteRec.open strQuery,conn,3,3
	counter = 0
	If Not inviteRec.eof Then
		emptyRec = False
	End if

	If Not emptyRec Then
		%>
		<table class="userTable">
		<%
	End if

	Set userRec = server.CreateObject("ADODB.RecordSet")

	Do While Not inviteRec.eof
		counter = counter + 1
		If counter Mod cols = 1 And Not emptyRec then
			response.write("<tr>")
		End if
		strQuery = "SELECT * FROM groups WHERE id="&SQLClean(inviteRec("shareeId"),"N","S")
		userRec.open strQuery,conn,3,3
		%>
		<%
		If Not userRec.eof then
		%>
		<td valign="top">
			<%If userRec("companyId") = session("companyId") then%>
				<%
				Set gRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM groupMembersView WHERE groupId="&SQLClean(userRec("id"),"N","S")
				gRec.open strQuery,conn,3,3
				If Not gRec.eof Then
					numMembers = gRec.RecordCount
				Else
					numMembers = 0
				End If
				membersString = ""
				Do While Not gRec.eof
					membersString = membersString & gRec("fullName")
					gRec.movenext
					If Not gRec.eof Then
					membersString = membersString & ", "
					End if
				loop
				gRec.close
				Set gRec = nothing
				%>
				<div class="userData userDataDynamicHeight">
					<div class="userName"><%=userRec("name")%> Group</div>
					<div class="userTitle"><%=numMembers%> Members</div>
					<div class="userCompany userCompanyDynamicHeight"><%=membersString%></div>
					<div class="userIcons">
						<%
							canRead = inviteRec("canRead")
							canWrite = inviteRec("canWrite")
						%>
						<%If canRead = 1 And 1=2 then%>
							<a href="#">read</a>
						<%End if%>
						<%If canWrite = 1 And 1=2 then%>
							<a href="#">write</a>
						<%End if%>
						<form id="cancelForm_<%=inviteRec("id")%>" method="post" action="<%=mainAppPath%>/projects/cancel-project-group-invite.asp" target="submitFrame">
							<input type="hidden" name="inviteId" value="<%=inviteRec("id")%>">
							<input type="hidden" name="prevPage" value="<%=mainAppPath&"/show-project.asp?id="&projectId%>">
						</form>
						<%If ownsProject(projectId) Or isAdminUser(session("userId")) then%>
						<a href="javascript:void(0);" <%If inviteRec("readOnly") <> 1 Or isAdminUser(session("userId")) then%>onclick="cancelInvite(<%=inviteRec("id")%>)"<%else%>style="visibility:hidden;"<%End if%>><%=cancelLabel%></a>
						<a href="javascript:void(0);" onclick="changeInvite(<%=inviteRec("id")%>)" style="margin-right:15px;"><%=changeLabel%></a>
						<%End if%>
						<form method="post" action="<%=mainAppPath%>/projects/change-project-group-invite.asp" target="submitFrame" id="changeForm_<%=inviteRec("id")%>" style="display:block;">
						<select name="newPermissions" id="newPermissions">
							<%If (userCanRead) Or isAdminUser(session("userId")) then%>
								<option value="1"<%If (canRead = 1 And canWrite <> 1) then%> SELECTED<%End if%>>View</option>
							<%End if%>
							<%If inviteRec("readOnly") <> 1 then%>
								<%If (userCanWrite) Or isAdminUser(session("userId")) then%>
									<option value="2"<%If (canRead <> 1 And canWrite = 1) then%> SELECTED<%End if%>>Write</option>
								<%End if%>
							<%End if%>
							<%If (userCanRead And userCanWrite) Or isAdminUser(session("userId")) then%>
								<option value="3"<%If (canRead = 1 And canWrite = 1) then%> SELECTED<%End if%>>View/Write</option>
							<%End if%>
						</select>
						<input type="hidden" name="inviteId" value="<%=inviteRec("id")%>">
						<input type="hidden" name="shareeId" value="<%=inviteRec("shareeId")%>">
						<input type="hidden" name="projectId" value="<%=inviteRec("projectId")%>">
						</form>
					</div>
				</div>	
			<%End if%>
		</td>
		<%
		End If
		%>
		<%
		userRec.close

		If counter Mod cols = 0 And Not emptyRec then
			response.write("</tr>")
		End if

		inviteRec.movenext
	Loop




	Set inviteRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM projectInvites WHERE projectId="&SQLClean(projectId,"N","S")
	inviteRec.open strQuery,conn,3,3
	If emptyRec Then
		%>
		<table class="userTable">
		<%
	End if
	If Not inviteRec.eof Or Not emptyRec Then
		emptyRec = False
	End if

	usersTable = getDefaultSingleAppConfigSetting("usersTable")
	Set userRec = server.CreateObject("ADODB.RecordSet")

	Do While Not inviteRec.eof
		counter = counter + 1
		If counter Mod cols = 1 And notEmptyRec then
			response.write("<tr>")
		End if
		strQuery = "SELECT * FROM "&usersTable&" WHERE id="&SQLClean(inviteRec("shareeId"),"N","S") &" AND enabled =1"
		userRec.open strQuery,conn,3,3
		%>
		<%
		If Not userRec.eof then
		%>
		<td valign="top">
			<%If userRec("companyId") = session("companyId") then%>
				
				<div class="userData">
					<div class="userName"><%=userRec("firstName")%>&nbsp;<%=userRec("lastName")%></div>
					<div class="userTitle"><%=userRec("title")%></div><%If inviteRec("accepted") = 0 then%> <span class="userInviteStatus">pending</span><%End if%>
					<div class="userCompany"><%=userRec("company")%><%If userRec("city") <> "" then%>, <%=userRec("city")%><%End if%></div>
					<div class="userPhone"><%=userRec("phone")%></div>
					<div class="userEmail"><a href="mailto:<%=userRec("email")%>"><%=userRec("email")%></a></div>
					<div class="userIcons">
						<%
							canRead = inviteRec("canRead")
							canWrite = inviteRec("canWrite")
						%>
						<%If canRead = 1 And 1=2 then%>
							<a href="#">read</a>
						<%End if%>
						<%If canWrite = 1 And 1=2 then%>
							<a href="#">write</a>
						<%End if%>
						<form id="cancelForm_<%=inviteRec("id")%>" method="post" action="<%=mainAppPath%>/projects/cancel-project-invite.asp" target="submitFrame">
							<input type="hidden" name="inviteId" value="<%=inviteRec("id")%>">
							<input type="hidden" name="prevPage" value="<%=mainAppPath&"/show-project.asp?id="&projectId%>">
						</form>
						<%If ownsProject(projectId) Or isAdminUser(session("userId")) then%>
							<a href="javascript:void(0);" <%If (inviteRec("readOnly") <> 1 Or isAdminUser(session("userId"))) And (Not isAdminUser(inviteRec("shareeId"))) Then%>onclick="cancelInvite(<%=inviteRec("id")%>)"<%else%>style="visibility:hidden;"<%End if%>><%=cancelLabel%></a>
							<a href="javascript:void(0);" onclick="changeInvite(<%=inviteRec("id")%>)" style="margin-right:15px;"><%=changeLabel%></a>
						<%End if%>
						<form method="post" action="<%=mainAppPath%>/projects/change-project-invite.asp" target="submitFrame" id="changeForm_<%=inviteRec("id")%>" style="display:block;">
						<select name="newPermissions" id="newPermissions">
							<%If (userCanRead) Or isAdminUser(session("userId")) then%>
								<option value="1"<%If (canRead = 1 And canWrite <> 1) then%> SELECTED<%End if%>>View</option>
							<%End if%>
							<%If inviteRec("readOnly") <> 1 then%>
								<%If ((userCanWrite) Or isAdminUser(session("userId"))) And (Not isAdminUser(inviteRec("shareeId"))) then%>
									<option value="2"<%If (canRead <> 1 And canWrite = 1) then%> SELECTED<%End if%>>Write</option>
								<%End if%>
							<%End if%>
							<%If (userCanRead And userCanWrite) Or isAdminUser(session("userId")) then%>
								<option value="3"<%If (canRead = 1 And canWrite = 1) then%> SELECTED<%End if%>>View/Write</option>
							<%End if%>
						</select>
						<input type="hidden" name="inviteId" value="<%=inviteRec("id")%>">
						<input type="hidden" name="shareeId" value="<%=inviteRec("shareeId")%>">
						<input type="hidden" name="projectId" value="<%=inviteRec("projectId")%>">
						</form>
					</div>
				</div>	
			<%End if%>
		</td>
		<%
		End If
		%>
		<%
		userRec.close

		If counter Mod cols = 0 And Not emptyRec then
			response.write("</tr>")
		End if

		inviteRec.movenext
	Loop

	If counter Mod cols <> 0 And Not emptyRec then
		response.write("</tr>")
	End if

	If Not emptyRec Then
		%>
		</table>
		<%
	End if

	inviteRec.close
	Set inviteRec = Nothing
	Set userRec = Nothing
	call disconnect
End if
%>