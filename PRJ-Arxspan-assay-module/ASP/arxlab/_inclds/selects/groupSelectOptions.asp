
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/selects/fnc_groupSelectQuery.asp" -->


	<option value="">--SELECT--</option>

	<%
		Set groups = JSON.parse(getGroups())
		
	For i = 0 to groups.length-1 
		Set group = groups.get(i)


	%>
		<option value="<%=group.get("groupId")%>" <%If CStr(thisGroupId)=CStr(group.get("groupId")) then%>SELECTED<%End if%>><%=group.get("groupName")%></option>
	<%		
	Next

	%>