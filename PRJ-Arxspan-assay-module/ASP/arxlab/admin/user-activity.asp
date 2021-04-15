<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "user-activity"
subsectionId = "user-activity"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
teamId = request.querystring("teamId")
%>

	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->

	<script type="text/javascript">
		function toggleRow(id)
		{
			row = document.getElementById("user-frame-row-"+id);
			theImage = document.getElementById("user-img-"+id);
			srcSpan = document.getElementById("user-frame-src-"+id)
			frame = document.getElementById("user-frame-"+id)
			if (row.style.display == "none")
			{
				theImage.src = "<%=mainAppPath%>/images/minus.gif"
				try{
					row.style.display = "table-row";
				}
				catch(err){
					row.style.display = "block";
				}
			}
			else
			{
				row.style.display = "none";
				theImage.src = "<%=mainAppPath%>/images/plus.gif"
			}
			if (srcSpan.innerHTML != '')
			{
				frame.src = srcSpan.innerHTML.replace(/&amp;/g,"&");
				srcSpan.innerHTML ='';
			}
		}
	</script>

	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	

<h1 style="margin-bottom:15px;">User Activity</h1>
<%If (session("role") = "Admin" Or session("role") = "Super Admin") Then%>
<span style="font-weight:bold;">Team</span>
<form method="get" action="<%=mainAppPath%>/admin/user-activity.asp" style="margin-bottom:15px;">
<select id="teamId" name="teamId">
<%
Call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM usersView WHERE companyId="&SQLClean(session("companyId"),"N","S") & " AND (roleNumber=1 or roleNumber=2) ORDER BY fullName ASC"
rec.open strQuery,conn,3,3
Do While Not rec.eof
If CStr(rec("id")) = CStr(teamId) Then
	selText = "SELECTED"
Else
	selText = ""
End if
%>
	<option value="<%=rec("id")%>" <%=selText%>><%=rec("fullName")%></option>
<%
	rec.movenext
loop
rec.close
Set rec = nothing
%>
</select>
<input type="submit" value="Go">
</form>
<%End if%>
<%If (session("roleNumber") = "1" And teamId <> "") Or (session("roleNumber") = "2" Or session("roleNumber") = "3") then%>

<%
If session("roleNumber") = "1" Then
	strQuery = "SELECT * FROM usersView WHERE userAdded="&SQLClean(teamId,"N","S")
End if
If session("roleNumber") = "2" Then
	strQuery = "SELECT * FROM usersView WHERE userAdded="&SQLClean(session("userId"),"N","S")
End If
If session("roleNumber") = "3" Then
	strQuery = "SELECT * FROM usersView WHERE userAdded="&SQLClean(session("managerId"),"N","S")
End if
%>
<table class="experimentTable">
<%
Set rec = server.CreateObject("ADODB.RecordSet")
rec.open strQuery,conn,3,3
Do While Not rec.eof
%>
	<tr>
		<td class="caseInnerTitle">
			<img id="user-img-<%=rec("id")%>" src="<%=mainAppPath%>/images/plus.gif" style="margin-right:5px;" width="12" height="12" onClick="toggleRow('<%=rec("id")%>')"/>
			<%=rec("fullName")%>
		</td>
	</tr>
	<tr id="user-frame-row-<%=rec("id")%>" style="display:none;">
		<td class="caseInnerData" style="padding-left:20px!important;">
			<iframe width="820" id="user-frame-<%=rec("id")%>" name="user-frame-<%=rec("id")%>" src="" frameborder="0"></iframe>
			<span style="display:none;" id="user-frame-src-<%=rec("id")%>"><%=mainAppPath%>/table_pages/show-userActivityRecentlyViewedExperiments.asp?inframe=true&id=<%=rec("id")%>&frameWidth=800&frameBG=white&recLimit=5&frameExperimentTableWidth=780</span>
		</td>
	</tr>
<%
	rec.movenext
Loop
rec.close
Set rec = nothing
%>
</table>
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%Call disconnect%>