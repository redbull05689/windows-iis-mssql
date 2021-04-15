<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<div class="dashboardObjectContainer userProfile"><div class="objHeader elnHead"><h2><%=userProfileLabel%></h2></div>
			<div class="objBody">
<table cellpadding="0" cellspacing="0" class="profileTable">
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			<%=firstNameLabel%>
		</td>
		<td class="caseInnerData">
			<%=userRec("firstName")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			<%=lastNameLabel%>
		</td>
		<td class="caseInnerData">
			<%=userRec("lastName")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			<%=emailLabel%>
		</td>
		<td class="caseInnerData">
			<a href="mailto:<%=userRec("email")%>"><%=userRec("email")%></a>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			<%=personsTitleLabel%>
		</td>
		<td class="caseInnerData">
			<%=userRec("title")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			<%=companyLabel%>
		</td>
		<td class="caseInnerData">
			<%=userRec("companyName")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			<%=addressLabel%>
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
			<%=countryLabel%>
		</td>
		<td class="caseInnerData">
			<%=userRec("country")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			<%=phoneNumberLabel%>
		</td>
		<td class="caseInnerData">
			<%=userRec("phone")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			<%=userRoleLabel%>
		</td>
		<td class="caseInnerData">
			<%=userRec("roleName")%>
		</td>
	</tr>
	<tr>
		<td class="caseInnerTitle" valign="top" style="width:70px;">
			<%=userGroupsLabel%>
		</td>
		<td class="caseInnerData">
			<%
			Set gRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT groupName FROM groupMembersView WHERE userId="&SQLClean(session("userId"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
			gRec.open strQuery,conn,3,3
			If gRec.eof Then
				%>
				You are not a member of any groups
				<%
			End if
			Do While Not gRec.eof
				response.write(gRec("groupName"))
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
			<%=userManagerLabel%>
		</td>
		<td class="caseInnerData">
			<%=userRec("managerName")%>
		</td>
	</tr>
</table>

</div>
</div>