<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->

<%
If cols = "" Then
	cols = 3
End if
notebookId = request.querystring("id")
If ownsNotebook(notebookId) Or canShareNotebook(notebookId) Or session("role")="Admin" then
	call getconnected

	userCanRead = canReadNotebook(notebookId,session("userId"))
	userCanWrite = canWriteNotebook(notebookId)

	emptyRec = True
	Set inviteRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM groupNotebookInvitesView WHERE notebookId="&SQLClean(notebookId,"N","S")
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
		strQuery = "SELECT id, companyId, name FROM groups WHERE id="&SQLClean(inviteRec("shareeId"),"N","S") 
		userRec.open strQuery,conn,3,3
		%>
		<%
		If Not userRec.eof then
		%>
		<td valign="top">
			<%If userRec("companyId") = session("companyId") then%>
				<%
				Set gRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT fullName FROM groupMembersView WHERE groupId="&SQLClean(userRec("id"),"N","S") &" AND enabled =1"
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
					<%If inviteRec("sharerId") = session("userId") Or session("role")="Admin" Or ownsNotebook(notebookId) then%>
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
						<form id="cancelForm_<%=inviteRec("id")%>" method="post" action="<%=mainAppPath%>/notebooks/cancel-group-invite.asp" target="submitFrame">
							<input type="hidden" name="inviteId" value="<%=inviteRec("id")%>">
							<input type="hidden" name="prevPage" value="<%=mainAppPath&"/show-notebook.asp?id="&notebookId%>">
						</form>
						<table cellpadding="0" cellspacing="0">
						<tr>
						<td>
							<span><strong><%=accessLabel%></strong></span>
						</td>
						<td>
						<form method="post" action="<%=mainAppPath%>/notebooks/change-group-invite.asp" target="submitFrame" id="changeForm_<%=inviteRec("id")%>" style="display:block;">
						<select name="newPermissions" id="newPermissions" <%If Not hasShareNotebookPermission(false) Then%>disabled<%End if%>>
							<%If (userCanRead) Or session("role")="Admin" then%>
							<option value="1"<%If canRead = 1 And canWrite <> 1 then%> SELECTED<%End if%>>View</option>
							<%End if%>
							<%If inviteRec("readOnly") <> 1 then%>
							<%If (userCanWrite) Or session("role")="Admin" then%>
							<option value="2"<%If canRead <> 1 And canWrite = 1 then%> SELECTED<%End if%>>Write</option>
							<%End if%>
							<%End if%>
							<%If (userCanRead And userCanWrite) Or session("role")="Admin" then%>
							<option value="3"<%If canRead = 1 And canWrite = 1 then%> SELECTED<%End if%>>View/Write</option>
							<%End if%>
						</select>
						<input type="hidden" name="inviteId" value="<%=inviteRec("id")%>">
						<input type="hidden" name="shareeId" value="<%=inviteRec("shareeId")%>">
						<input type="hidden" name="notebookId" value="<%=inviteRec("notebookId")%>">
						</form>
						</td>
						<%If inviteRec("sharerId") = session("userId") or ownsNotebook(notebookId) then%>
						<td>
							<a href="javascript:void(0);" <%If hasShareNotebookPermission(false) Then%>onclick="changeInvite(<%=inviteRec("id")%>)"<%End if%> style="margin-right:15px;<%If Not hasShareNotebookPermission(false) Then%>color:#ccc;<%End if%>"><%=changeLabel%></a>
						</td>
						<td>
							<a href="javascript:void(0);" <%If inviteRec("readOnly") <> 1 then%>onclick="cancelInvite(<%=inviteRec("id")%>)"<%else%>style="visibility:hidden;"<%End if%>><%=cancelLabel%></a>
						</td>
						<%End if%>
						</tr>
						</table>
					</div>
					<%End if%>
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
	strQuery = "SELECT * FROM notebookInvitesView WHERE notebookId="&SQLClean(notebookId,"N","S")  
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
		strQuery = "SELECT * FROM "&usersTable&" WHERE id="&SQLClean(inviteRec("shareeId"),"N","S")  &" AND enabled =1"
		userRec.open strQuery,conn,3,3
		%>
		<%
		If Not userRec.eof then
		%>
		<td valign="top">
			<%If userRec("companyId") = session("companyId") then%>
				
				<div class="userData">
					<div class="userName"><%=userRec("firstName")%>&nbsp;<%=userRec("lastName")%></div>
					<div class="userTitle"><strong><%=sharedByLabel%>:</strong><%=inviteRec("sharerName")%></div><br/>
					<div class="userTitle"><%=userRec("title")%></div><%If inviteRec("accepted") = 0 then%> <span class="userInviteStatus">pending</span><%End if%>
					<div class="userCompany"><%=userRec("company")%><%If userRec("city") <> "" then%>, <%=userRec("city")%><%End if%></div>
					<div class="userPhone"><%=userRec("phone")%></div>
					<div class="userEmail"><a href="mailto:<%=userRec("email")%>"><%=userRec("email")%></a></div>
					<%If inviteRec("sharerId") = session("userId") Or session("role")="Admin" Or ownsNotebook(notebookId) then%>
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
						<form id="cancelForm_<%=inviteRec("id")%>" method="post" action="<%=mainAppPath%>/notebooks/cancel-invite.asp" target="submitFrame">
							<input type="hidden" name="inviteId" value="<%=inviteRec("id")%>">
							<input type="hidden" name="prevPage" value="<%=mainAppPath&"/show-notebook.asp?id="&notebookId%>">
						</form>

						<table cellspacing="0" cellpadding="0">
						<tr>
						<td>
							<span><strong><%=accessLabel%></strong></span>
						</td>
						<td>
						<form method="post" action="<%=mainAppPath%>/notebooks/change-invite.asp" target="submitFrame" id="changeForm_<%=inviteRec("id")%>" style="display:block;">
						<select name="newPermissions" id="newPermissions" style="margin-top:0px;padding:0px;" <%If Not hasShareNotebookPermission(false) Then%>disabled<%End if%>>
							<%If (userCanRead) Or session("role")="Admin" then%>
							<option value="1"<%If canRead = 1 And canWrite <> 1 then%> SELECTED<%End if%>>View</option>
							<%End if%>
							<%If ((userCanWrite) Or session("role")="Admin") And (Not isAdminUser(inviteRec("shareeId"))) then%>
							<%If inviteRec("readOnly") <> 1 then%>
							<option value="2"<%If canRead <> 1 And canWrite = 1 then%> SELECTED<%End if%>>Write</option>
							<%End if%>
							<%End if%>
							<%If (userCanRead And userCanWrite) Or session("role")="Admin" then%>
							<option value="3"<%If canRead = 1 And canWrite = 1 then%> SELECTED<%End if%>>View/Write</option>
							<%End if%>
						</select>
						<input type="hidden" name="inviteId" value="<%=inviteRec("id")%>">
						<input type="hidden" name="shareeId" value="<%=inviteRec("shareeId")%>">
						<input type="hidden" name="notebookId" value="<%=inviteRec("notebookId")%>">
						</form>
						</td>
						<%If inviteRec("sharerId") = session("userId") Or ownsNotebook(notebookId) then%>
						<td>
							<a href="javascript:void(0);" <%If hasShareNotebookPermission(false) Then%>onclick="changeInvite(<%=inviteRec("id")%>)"<%End if%> style="margin-right:15px;<%If Not hasShareNotebookPermission(false) Then%>color:#ccc;<%End if%>"><%=changeLabel%></a>
						</td>
						<td>
							<a href="javascript:void(0);" <%If (inviteRec("readOnly") <> 1) And (Not isAdminUser(inviteRec("shareeId"))) Then%>onclick="cancelInvite(<%=inviteRec("id")%>)"<%else%>style="visibility:hidden;"<%End if%>><%=cancelLabel%></a>
						</td>
						<%End if%>
						</tr>
						</table>
						
						<%If canShareShareNotebook(notebookId) THen%>
						<%If inviteRec("readOnly") <> 1 then%>

						<table cellpadding="0" cellspacing="0">
						<tr>
						<td>
						<span><strong>Sharing Permissions</strong></span>
						</td>
						<td>
						<form method="post" action="<%=mainAppPath%>/notebooks/change-share-invite.asp" target="submitFrame" id="shareChangeForm_<%=inviteRec("id")%>" style="display:block;">
						<select name="newSharePermissions" id="newSharePermissions" style="margin-top:0px;padding:0px;margin-bottom:0px;">
							<option value="1"<%If inviteRec("canShare") = 0 And inviteRec("canShareShare") = 0 then%> SELECTED<%End if%>>Can't Share</option>
							<option value="2"<%If inviteRec("canShare") = 1 And inviteRec("canShareShare") = 0 then%> SELECTED<%End if%>>Can Share</option>
							<option value="3"<%If inviteRec("canShare") = 1 And inviteRec("canShareShare") = 1 then%> SELECTED<%End if%>>Can Delegate</option>
						</select>
						<input type="hidden" name="inviteId" value="<%=inviteRec("id")%>">
						<input type="hidden" name="shareeId" value="<%=inviteRec("shareeId")%>">
						<input type="hidden" name="notebookId" value="<%=inviteRec("notebookId")%>">
						</form>
						</td>
						<td>
							<a href="javascript:void(0);" onclick="changeShareInvite(<%=inviteRec("id")%>)"><%=changeLabel%></a>
						</td>
						</tr>
						</table>
						<%End if%>

						<%End if%>
					</div>
					<%End if%>
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