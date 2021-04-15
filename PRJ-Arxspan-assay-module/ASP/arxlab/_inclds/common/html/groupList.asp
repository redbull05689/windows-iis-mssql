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
			<li class="groupListGroup" id="groupListGroup-<%=gRec("id")%>"><input type="checkbox" class="groupCheck" id="listGroupCheckGroup-<%=gRec("id")%>" group="<%=gRec("id")%>" checkName="<%=gRec("name")%>" onclick="groupCheck(<%=gRec("id")%>)"><a href="javascript:void(0);" onClick="toggleGroup(<%=gRec("id")%>);return false;" class="expandGroupLink" id="expandGroupLink-<%=gRec("id")%>">+</a><%=gRec("name")%>
			<ul id="groupListUsers-<%=gRec("id")%>" class="groupListUsers" style="display:none;margin-top:0px;margin-bottom:0px;">
		<%
		End if

		Do While Not gRec2.eof
			'If gRec2("userId") <> session("userId") then
		%>
			<li class="groupListUser-<%=gRec2("userId")%>"><input type="checkbox" class="groupCheckUser" id="listGroupCheckUser-<%=gRec2("userId")%>" group="<%=gRec("id")%>" userId="<%=gRec2("userId")%>" checkName="<%=gRec2("fullName")%>" onclick="userCheck(<%=gRec("id")%>,<%=gRec2("userId")%>)"><%=gRec2("fullName")%></li>
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
		<li class="groupListGroup"><input type="checkbox" class="groupCheck" style="visibility:hidden;" group="0"><a href="javascript:void(0);" onClick="toggleGroup(0);return false;" class="expandGroupLink" id="expandGroupLink-0">+</a>Ungrouped
		<ul id="groupListUsers-0" class="groupListUsers" style="display:none;margin-top:0px;margin-bottom:0px;">
	<%
	End if
	Do While Not gRec2.eof
		If gRec2("id") <> session("userId") then
	%>
		<li class="groupListUser-<%=gRec2("id")%>"><input type="checkbox" checkName="<%=gRec2("fullName")%>" class="groupCheckUser" id="listGroupCheckUser-<%=gRec2("id")%>" group="0" userId="<%=gRec2("id")%>"><%=gRec2("fullName")%></li>
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