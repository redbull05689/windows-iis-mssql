<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "show-group"
subsectionId = "show-group"
%>
<!-- #include file="../_inclds/globals.asp"-->

	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<%
Call getconnected
canView = false
If request.querystring("id") <> "" Then
	groupId = request.querystring("id")
	If (session("roleNumber") < 1 Or session("userId")="2" Or session("role") = "Admin" Or session("role") = "Super Admin") And cstr(session("userId")) = CStr(userId) Then
		If CStr(session("companyId")) = getExperimentCompanyId(experimentType,experimentId)  Or session("companyId")="1"  then
			'if user is an admin then they can see all groups in their company.
			'if they are an arxspan employee they can see all groups
			canView = True
		End If
	Else
		Set gRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM groupMembers WHERE userId="&SQLClean(session("userId"),"N","S") & " AND groupId="&SQLClean(groupId,"N","S")
		gRec.open strQuery,conn,3,3
		If Not gRec.eof Then
			'can view group if user is a member of the group
			canView = True
		End If
		gRec.close
		Set gRec = nothing
	End if
Else
	canView = False
End if

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT name FROM groupsView WHERE id="&SQLClean(groupId,"N","S")
rec.open strQuery,conn,3,3
If Not rec.eof And canView then
%>

<h1><%=rec("name")%></h1>
<p><span style="font-weight:bold;">Members:&nbsp;</span>
<%
Set memberRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT userId, fullName FROM groupMembersView WHERE groupId="&SQLClean(groupId,"N","S") & " ORDER BY fullName DESC"
memberRec.open strQuery,conn,3,3
Do While Not memberRec.eof
	response.write("<a href='"&mainAppPath&"/users/user-profile.asp?id="&memberRec("userId")&"'>"&memberRec("fullName")&"</a>")
	memberRec.movenext
	If Not memberRec.eof Then
		response.write(", ")
	End if
Loop
memberRec.close
Set memberRec = nothing
%>
</p>

<iframe src="<%=mainAppPath%>/table_pages/frame-show-notebooks.asp?groupId=<%=groupId%>" style="background-color:#DFDFDF;width:100%;height:100px;border:none;" name="groupNotebookFrame" id="groupNotebookFrame" scrolling="no" frameborder="0"></iframe>
<br/><br/>
<iframe src="<%=mainAppPath%>/table_pages/frame-show-projects.asp?groupId=<%=groupId%>" style="background-color:#DFDFDF;width:100%;height:100px;border:none;" name="groupProjectFrame" id="groupProjectFrame" scrolling="no" frameborder="0"></iframe>
<%else%>
<p>Group does not exist</p>
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%Call disconnect%>