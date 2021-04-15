<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%
companyId = session("companyId")
notebookName = request.querystring("notebookName")

if session("role")="Super Admin" or (session("role")="Admin" and CStr(companyId)=CStr(session("companyId"))) Then
	trash=1
else
	response.redirect(loginScriptName)
End if

Call getconnected
Set gRec = server.CreateObject("ADODB.RecordSet")
If notebookName = "" then
	strQuery = "SELECT id, name FROM notebookView WHERE companyId="&SQLClean(companyId,"N","S") & " AND visible=1 ORDER BY name ASC"
Else
	strQuery = "SELECT id, name FROM notebookView WHERE companyId="&SQLClean(companyId,"N","S") & " AND name like "&SQLClean(notebookName,"L","S")&" AND visible=1 ORDER BY name ASC"
End if
gRec.open strQuery,conn,3,3
If Not gRec.eof then
%>
<h1 style="padding:10px 0px 5px 0px;">Notebooks</h1>
<div id="groupListContainer">
<ul id="groupsList" class="groupsList" style="margin-top:0px;margin-bottom:0px;margin-left:0px;">
	<li class="groupListGroup" id="groupListGroup-<%=gRec("id")%>"><input type="checkbox" class="groupCheck" name="listGroupCheckGroup-0" id="listGroupCheckGroup-0" group="0" onclick="checkAll(this)">&nbsp;&nbsp;Select All</li>
	<%
	Do While Not gRec.eof
	%>

		<%
		Set gRec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT typeId, experimentId, name from notebookIndexView WHERE notebookId=" & SQLClean(gRec("id"),"N","S") & " AND companyId="&SQLClean(companyId,"N","S")& " AND visible=1 and beenExported=0 ORDER by name ASC"
		Set rs = conn.execute("SELECT count(*) as count from notebookIndexView WHERE notebookId=" & SQLClean(gRec("id"),"N","S") & " AND companyId="&SQLClean(companyId,"N","S")& " AND visible=1 and beenExported=0")
		count = rs("count")
		rs.close
		Set rs = nothing
		gRec2.open strQuery,conn,3,3
		noMembers = gRec2.eof
		If Not noMembers Then
		%>
		<li class="groupListGroup" id="groupListGroup-<%=gRec("id")%>"><input type="checkbox" class="groupCheck" name="listGroupCheckGroup-<%=gRec("id")%>" id="listGroupCheckGroup-<%=gRec("id")%>" group="<%=gRec("id")%>" onclick="groupCheck(<%=gRec("id")%>)"><a href="javascript:void(0);" onClick="toggleGroup(<%=gRec("id")%>);return false;" class="expandGroupLink" id="expandGroupLink-<%=gRec("id")%>">+</a><a href="show-notebook.asp?id=<%=gRec("id")%>" target="new"><%=gRec("name")%></a> (<%=count%>)<input type="hidden" id="vfy1" value="vfy1">
			<ul id="groupListUsers-<%=gRec("id")%>" class="groupListUsers" style="display:none;margin-top:0px;margin-bottom:0px;margin-left:0px;">
		<%
		End if

		Do While Not gRec2.eof
		prefix = GetPrefix(gRec2("typeId"))
		href = GetExperimentPage(prefix) & "?id=" & gRec2("experimentId")
		%>
			<li class="groupListUser-<%=gRec2("typeId")%>-<%=gRec2("experimentId")%>"><input type="checkbox" class="groupCheckUser" name="listGroupCheckUser-<%=gRec2("typeId")%>-<%=gRec2("experimentId")%>"  id="listGroupCheckUser-<%=gRec2("typeId")%>-<%=gRec2("experimentId")%>" group="<%=gRec("id")%>" experimentId="<%=gRec("id")%>-<%=gRec2("experimentId")%>" onclick="userCheck(<%=gRec("id")%>,'<%=gRec2("typeId")%>-<%=gRec2("experimentId")%>')"><a href="<%=href%>" target="new"><%=gRec2("name")%></a></li>
		<%
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
		</li>
	<%
		gRec.movenext
	loop
	%>
</ul>
<%else%>
<h1 style="padding:10px 0px 5px 0px;">Notebooks</h1>
<p>No notebooks match your query.</p>
<%End if%>