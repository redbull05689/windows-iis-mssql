<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
subSectionId = "user-profile"
%>
<!-- #include file="../_inclds/globals.asp" -->


<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<%
Call getconnected
Set userRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM usersView WHERE id="&SQLClean(request.querystring("id"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
userRec.open strQuery,conn,3,3
If Not userRec.eof then
%>


<div class="dashboardObjectContainer userProfile"><div class="objHeader elnHead"><h2><%=userProfileLabel%></h2></div>
			<div class="objBody">


<table cellpadding="0" cellspacing="0" class="profileTable">
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			First Name
		</td>
		<td class="caseInnerData">
			<%=userRec("firstName")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			Last Name
		</td>
		<td class="caseInnerData">
			<%=userRec("lastName")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			email
		</td>
		<td class="caseInnerData">
			<a href="mailto:<%=userRec("email")%>"><%=userRec("email")%></a>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			Title
		</td>
		<td class="caseInnerData">
			<%=userRec("title")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			Company
		</td>
		<td class="caseInnerData">
			<%=userRec("companyName")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			Address
		</td>
		<td class="caseInnerData">
			<%=userRec("address")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			City, State Zip
		</td>
		<td class="caseInnerData">
			<%=userRec("city")&", "&userRec("state")&" "&userRec("zip")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			Country
		</td>
		<td class="caseInnerData">
			<%=userRec("country")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			Phone
		</td>
		<td class="caseInnerData">
			<%=userRec("phone")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			Permissions
		</td>
		<td class="caseInnerData">
			<%=userRec("roleName")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			Groups
		</td>
		<td class="caseInnerData">
			<%
			Set gRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM groupMembersView WHERE userId="&SQLClean(userRec("id"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
			gRec.open strQuery,conn,3,3
			Do While Not gRec.eof
				response.write("<a href='"&mainAppPath&"/table_pages/show-group.asp?id="&gRec("groupId")&"'>"&gRec("groupName")&"</a>")
				gRec.movenext
				If Not gRec.eof Then
					response.write(", ")
				End if
			Loop
			gRec.close
			Set gRec = nothing
			%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			Manager
		</td>
		<td class="caseInnerData">
			<%=userRec("managerName")%>
		</td>
	</tr>
</table>

</div>
</div>
<iframe src="<%=mainAppPath%>/table_pages/frame-show-notebooks.asp?userId=<%=userRec("id")%>" style="background-color:#DFDFDF;width:100%;height:100px;border:none;" name="groupNotebookFrame" id="groupNotebookFrame" scrolling="no" frameborder="0"></iframe>
<%end if%>

<!-- #include file="../_inclds/footer-tool.asp"-->