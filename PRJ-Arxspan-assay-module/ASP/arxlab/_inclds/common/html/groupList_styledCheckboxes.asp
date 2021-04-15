<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Call getconnected
Set gRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, name FROM groups WHERE companyId="&session("companyId")& " ORDER BY name"
gRec.open strQuery,conn,3,3
%>
<div id="groupListContainer" style="height:220px;width:280px;overflow:auto;">
<ul id="groupsList" class="groupsList" style="margin-top:0px;margin-bottom:0px;">
	<%
	Do While Not gRec.eof
	%>
		<%
		Set gRec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT userId, fullName from groupMembersView WHERE groupId=" & SQLClean(gRec("id"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")& " AND userId in("&getUsersICanSee()&") AND enabled=1"
		If isInteger(notebookUserId) Then
			strQuery = strQuery & " AND userId<>"&SQLClean(notebookUserId,"N","S")
		End If
		strQuery = strQuery & " ORDER BY fullName"
		gRec2.open strQuery,conn,3,3
		noMembers = False
		If gRec2.eof Then
			noMembers = true
		End if

		If Not noMembers Then
		%>
			<li class="groupListGroup" id="groupListGroup-<%=gRec("id")%>"><input type="checkbox" class="css-checkbox groupCheck" id="listGroupCheckGroup-<%=gRec("id")%>" name="listGroupCheckGroup-<%=gRec("id")%>" group="<%=gRec("id")%>" checkName="<%=gRec("name")%>" onclick="groupCheck(<%=gRec("id")%>)"><a href="javascript:void(0);" onClick="toggleGroup(<%=gRec("id")%>);return false;" class="expandGroupLink" id="expandGroupLink-<%=gRec("id")%>">+</a><label for="listGroupCheckGroup-<%=gRec("id")%>" class="css-label checkboxLabel objectSettingsCheckbox"><%=gRec("name")%></label>
			<ul id="groupListUsers-<%=gRec("id")%>" class="groupListUsers" style="display:none;margin-top:0px;margin-bottom:0px;">
		<%
		End if

		Do While Not gRec2.eof
			'If gRec2("userId") <> session("userId") then
			randomNumberForUniqueCheckbox = Int((1000-1+1)*Rnd+1)
		%>
			<li class="groupListUser-<%=gRec2("userId")%>"><input type="checkbox" class="css-checkbox groupCheckUser" id="listGroupCheckUser-<%=gRec2("userId")&"-"&randomNumberForUniqueCheckbox%>" group="<%=gRec("id")%>" userId="<%=gRec2("userId")%>" checkName="<%=gRec2("fullName")%>" onclick="userCheck(<%=gRec("id")%>,<%=gRec2("userId")%>)"><label for="listGroupCheckUser-<%=gRec2("userId")&"-"&randomNumberForUniqueCheckbox%>" class="css-label checkboxLabel objectSettingsCheckbox"><%=gRec2("fullName")%></label></li>
		<%
			'End if
			gRec2.movenext
		Loop
		gRec2.close
		Set gRec2 = Nothing
		
		If Not noMembers Then
		%>
			</ul>
		<%
		End if
		%>
		<%If Not noMembers Then%>
		</li>
		<%End if%>
	<%
		gRec.movenext
	loop

	Set gRec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id, fullName FROM usersView WHERE companyId="&SQLClean(session("companyId"),"N","S")& " AND id not in (SELECT userId FROM groupMembers WHERE companyId="&SQLClean(session("companyId"),"N","S")&") AND id in ("&getUsersICanSee()&") AND enabled=1"
	If isInteger(notebookUserId) Then
		strQuery = strQuery & " AND id<>"&SQLClean(notebookUserId,"N","S")
	End If
	strQuery = strQuery & " ORDER BY fullName"
	gRec2.open strQuery,conn,3,3
	noMembers = False
	If gRec2.eof Then
		noMembers = True
	End if
	If Not noMembers then
	%>
		<li class="groupListGroup"><input type="checkbox" class="css-checkbox groupCheck" style="visibility:hidden;" group="0" id="ungroupedUsersCheckbox" name="ungroupedUsersCheckbox"><a href="javascript:void(0);" onClick="toggleGroup(0);return false;" class="expandGroupLink" id="expandGroupLink-0">+</a><label for="ungroupedUsersCheckbox" class="css-label checkboxLabel objectSettingsCheckbox">Ungrouped</label>
		<ul id="groupListUsers-0" class="groupListUsers" style="display:none;margin-top:0px;margin-bottom:0px;">
	<%
	End if
	Do While Not gRec2.eof
		If gRec2("id") <> session("userId") then
			randomNumberForUniqueCheckbox = Int((1000-1+1)*Rnd+1)
	%>
		<li class="groupListUser-<%=gRec2("id")%>"><input type="checkbox" checkName="<%=gRec2("fullName")%>" class="css-checkbox groupCheckUser" id="listGroupCheckUser-<%=gRec2("id")&"-"&randomNumberForUniqueCheckbox%>" group="0" userId="<%=gRec2("id")%>"><label for="listGroupCheckUser-<%=gRec2("id")&"-"&randomNumberForUniqueCheckbox%>" class="css-label checkboxLabel objectSettingsCheckbox"><%=gRec2("fullName")%></label></li>
	<%
		End if
		gRec2.movenext
	loop
	If Not noMembers then
	%>
		</ul>
	<%
	End if
	%>
	</li>

</ul>
</div>