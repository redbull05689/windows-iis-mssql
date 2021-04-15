<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<select class="reg_dropdown" id="linkProjectId" name="linkProjectId" style="margin-top:0px;">
	<option value="">--SELECT--</option>
	<%
	Set nRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT DISTINCT projectId,userId,name,visible,lastViewed,description,fullName FROM allProjectPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and ((accepted=1 and canWrite=1) or (accepted is null and canWrite=1) or canWrite is null) and parentprojectId is null order by lastViewed DESC"
	nRec.open strQuery,conn,3,3
	Do While Not nRec.eof
		Set nRec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id,name FROM projects WHERE parentprojectId="&SQLClean(nRec("projectId"),"N","S")
		nRec2.open strQuery,conn,3,3
		If nRec2.eof then
	%>
		<option value="<%=nRec("projectId")%>" <%If CStr(projectId)=CStr(nRec("projectId")) then%>SELECTED<%End if%>><%=nRec("name")%></option>
	<%
		Else
	%>
		<option value="x"><%=nRec("name")%></option>
	<%
			Do While Not nRec2.eof
				%>
				<option value="<%=nRec2("id")%>" <%If CStr(projectId)=CStr(nRec2("id")) then%>SELECTED<%End if%>>--<%=nRec2("name")%></option>
				<%
				nRec2.movenext
			loop
		End If
		nRec2.close
		Set nRec2 = Nothing
		
		nRec.movenext
	Loop
	nRec.close
	Set nRec = nothing
	%>
</select>
