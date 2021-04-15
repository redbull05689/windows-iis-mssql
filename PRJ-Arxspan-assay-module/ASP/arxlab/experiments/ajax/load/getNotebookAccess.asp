<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentAccessString = ""
cNotebookId = request.querystring("notebookId")

'return true if user can view the notebook
userId = CStr(session("userId"))
If (session("role") = "Admin" Or session("role") = "Super Admin") And CStr(session("userId")) = userId Then
	If CStr(session("companyId")) = getNotebookCompanyId(cNotebookId) Or session("companyId")="1" then
		'if you are an admin you can read any notebook in your company. or if you are a member of arxspan you can see any experiment
		experimentAccessString = experimentAccessString & "You are an admin.<br/>"
	End If
End if

Call getconnected

Set crnRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM notebooks WHERE userId="&SQLClean(userId,"N","S") & " AND id="&SQLClean(cNotebookId,"N","S")
crnRec.open strQuery,conn,3,3
If Not crnRec.eof Then
	'if you own the notebook the user read it
	experimentAccessString = experimentAccessString & "You are the owner of this notebook.<br/>"
End if

crnRec.close
strQuery = "SELECT canRead, canWrite, sharerId, sharerName FROM notebookInvitesView WHERE notebookId="&SQLClean(cNotebookId,"N","S") & " AND shareeId=" & SQLClean(userId,"N","S") & " AND accepted=1"
crnRec.open strQuery,conn,3,3
If Not crnRec.eof Then
	'if you have accepted a read invitation to this notebook than you 
	'the user read the notebook
	If crnRec("canRead") = 1 And crnRec("canWrite") = 0 then
		experimentAccessString = experimentAccessString & "Shared with read access by: <a href='"&mainAppPath&"/users/user-profile.asp?id="&crnRec("sharerId")&"'>"&crnRec("sharerName")&"</a><br/>"
	End If
	If crnRec("canRead") = 0 And crnRec("canWrite") = 1 then
		experimentAccessString = experimentAccessString & "Shared with write access by: <a href='"&mainAppPath&"/users/user-profile.asp?id="&crnRec("sharerId")&"'>"&crnRec("sharerName")&"</a><br/>"
	End If
	If crnRec("canRead") = 1 And crnRec("canWrite") = 1 then
		experimentAccessString = experimentAccessString & "Shared with read/write access by: <a href='"&mainAppPath&"/users/user-profile.asp?id="&crnRec("sharerId")&"'>"&crnRec("sharerName")&"</a><br/>"
	End if
End if

Set cgRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT canRead, canWrite, groupId, groupName, sharerId, sharerName FROM groupPermView WHERE notebookId="&SQLClean(cNotebookId,"N","S") & " and userId=" & SQLClean(userId,"N","S")
cgRec.open strQuery,conn,3,3
If Not cgRec.eof Then
	'if the notebook is readshared with a group that you are a member of
	'the user can read the notebook
	If cgRec("canRead") = 1 And cgRec("canWrite") = 0 then
		experimentAccessString = experimentAccessString & "Shared with read access with <a href='"&mainAppPath&"/table_pages/show-group.asp?id="&cgRec("groupId")&"'>"&cgRec("groupName")&"</a> by <a href='"&mainAppPath&"/users/user-profile.asp?id="&cgRec("sharerId")&"'>"&cgRec("sharerName")&"</a>.<br/>"
	End If
	If cgRec("canRead") = 0 And cgRec("canWrite") = 1 then
		experimentAccessString = experimentAccessString & "Shared with write access with <a href='"&mainAppPath&"/table_pages/show-group.asp?id="&cgRec("groupId")&"'>"&cgRec("groupName")&"</a> by <a href='"&mainAppPath&"/users/user-profile.asp?id="&cgRec("sharerId")&"'>"&cgRec("sharerName")&"</a>.<br/>"
	End If
	If cgRec("canRead") = 1 And cgRec("canWrite") = 1 then
		experimentAccessString = experimentAccessString & "Shared with read/write access with <a href='"&mainAppPath&"/table_pages/show-group.asp?id="&cgRec("groupId")&"'>"&cgRec("groupName")&"</a> by <a href='"&mainAppPath&"/users/user-profile.asp?id="&cgRec("sharerId")&"'>"&cgRec("sharerName")&"</a>.<br/>"
	End if
End if
cgRec.close
Set cgRec = nothing


'if the notebook cannot be read by other means see if the notebook is linked to 
'a project that the user has access to


'	'determins whether or not the notebook is linked to a project that the user has read access to
'	'view permission to a notebook are inherited through project permissions
'	Set cgRec = server.CreateObject("ADODB.RecordSet")
'	strQuery = "SELECT * FROM projectNotebookPermView WHERE notebookId="&SQLClean(cNotebookId,"N","S")& " AND shareeId=" & SQLClean(userId,"N","S") & " AND (canRead=1 or groupCanRead=1)"
'	cgRec.open strQuery,conn,3,3
'	If Not cgRec.eof Then
'		'if notebook is in a project that is shared with user via a user share then the user
'		'can view the notebook
'		experimentAccessString = experimentAccessString & "Shared via project "&crnRec("projectName")&" by "&crnRec("sharerName")&".<br/>"
'	End if
		
'get the projects that the notebook is linked to
Set ttRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT projectId FROM linksProjectNotebooks WHERE notebookId="&SQLClean(cNotebookId,"N","S")
ttRec.open strQuery,conn,3,3
'loop through all the projects that this notebook belongs to
Do While Not ttRec.eof 
	'get the top level project id because that is where the permission are on 
	'the tabs are also project with a parentprojectid of the actual project
	Set tttRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT parentProjectId FROM projects WHERE id="&SQLClean(ttRec("projectId"),"N","S")
	tttRec.open strQuery,conn,3,3
	If Not tttRec.eof Then
		If Not IsNull(tttRec("parentProjectId")) then
			ppId = tttRec("parentProjectId")
		Else
			ppId = 0
		End if
	Else
		ppId = 0
	End If
	tttRec.close
	Set tttRec = nothing
	
	Set cgRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT canRead, canWrite, projectId, projectName, sharerId, sharerName FROM projectInvitesView WHERE (projectId="&SQLClean(ttRec("projectId"),"N","S") & " or projectId="&SQLClean(ppId,"N","S")&") and shareeId=" & SQLClean(userId,"N","S")
	cgRec.open strQuery,conn,3,3
	If Not cgRec.eof Then
		'if the user has a usershare invute to the top level project then they can see the notebook
		If cgRec("canRead") = 1 And cgRec("canWrite") = 0 then
			experimentAccessString = experimentAccessString & "Shared with read access via project <a href='show-project.asp?id="&cgRec("projectId")&"'>"&cgRec("projectName")&"</a> by <a href='"&mainAppPath&"/users/user-profile.asp?"&cgRec("sharerId")&"'>"&cgRec("sharerName")&"</a>.<br/>"
		End If
		If cgRec("canRead") = 0 And cgRec("canWrite") = 1 then
			experimentAccessString = experimentAccessString & "Shared with write access via project <a href='show-project.asp?id="&cgRec("projectId")&"'>"&cgRec("projectName")&"</a> by <a href='"&mainAppPath&"/users/user-profile.asp?"&cgRec("sharerId")&"'>"&cgRec("sharerName")&"</a>.<br/>"
		End If
		If cgRec("canRead") = 1 And cgRec("canWrite") = 1 then
			experimentAccessString = experimentAccessString & "Shared with read/write access via project <a href='show-project.asp?id="&cgRec("projectId")&"'>"&cgRec("projectName")&"</a> by <a href='"&mainAppPath&"/users/user-profile.asp?"&cgRec("sharerId")&"'>"&cgRec("sharerName")&"</a>.<br/>"
		End if
	End if
	cgRec.close
	Set cgRec = Nothing
	
	Set cgRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT canRead, canWrite, groupId, groupName, projectId, projectName FROM groupProjectPermView WHERE (projectId="&SQLClean(ttRec("projectId"),"N","S") & " or projectId="&SQLClean(ppId,"N","S")&") and userId=" & SQLClean(userId,"N","S")
	cgRec.open strQuery,conn,3,3
	If Not cgRec.eof Then
		'if the user is a member of a group that has a read invite to the project hen the user can see the notebook
		If cgRec("canRead") = 1 And cgRec("canWrite") = 0 then
			experimentAccessString = experimentAccessString & "Shared with read access with group <a href='"&mainAppPath&"/table_pages/show-group.asp?id="&cgRec("groupId")&"'>"&cgRec("groupName")&"</a> via project <a href='show-project.asp?id="&cgRec("projectId")&"'>"&cgRec("projectName")&"</a>.<br/>"
		End If
		If cgRec("canRead") = 0 And cgRec("canWrite") = 1 then
			experimentAccessString = experimentAccessString & "Shared with write access with group <a href='"&mainAppPath&"/table_pages/show-group.asp?id="&cgRec("groupId")&"'>"&cgRec("groupName")&"</a> via project <a href='show-project.asp?id="&cgRec("projectId")&"'>"&cgRec("projectName")&"</a>.<br/>"
		End If
		If cgRec("canRead") = 1 And cgRec("canWrite") = 1 then
			experimentAccessString = experimentAccessString & "Shared with read/write access with group <a href='"&mainAppPath&"/table_pages/show-group.asp?id="&cgRec("groupId")&"'>"&cgRec("groupName")&"</a> via project <a href='show-project.asp?id="&cgRec("projectId")&"'>"&cgRec("projectName")&"</a>.<br/>"
		End if
	End if
	cgRec.close
	Set cgRec = nothing
	ttRec.movenext
loop


response.write(experimentAccessString)

%>