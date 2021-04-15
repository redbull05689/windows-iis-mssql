<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=True%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentAccessString = ""
projectId = request.querystring("projectId")
'return true if user can view the notebook
userId = CStr(session("userId"))
If (session("role") = "Admin" Or session("role") = "Super Admin") And CStr(session("userId")) = userId Then
	If CStr(session("companyId")) = getProjectCompanyId(projectId) Or session("companyId")="1" then
		'if you are an admin you can read any notebook in your company. or if you are a member of arxspan you can see any experiment
		experimentAccessString = experimentAccessString & "You are an admin.<br/>"
	End If
End if

Call getconnected
Set crnRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM projects WHERE userId="&SQLClean(userId,"N","S") & " AND id="&SQLClean(projectId,"N","S")
crnRec.open strQuery,conn,3,3
If Not crnRec.eof Then
	'if you own the notebook the user read it
	experimentAccessString = experimentAccessString & "You are the owner of this project.<br/>"
End if

crnRec.close
strQuery = "SELECT canRead, canWrite, sharerId, sharerName FROM projectInvitesView WHERE projectId="&SQLClean(projectId,"N","S") & " AND shareeId=" & SQLClean(userId,"N","S") & " AND accepted=1"
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
strQuery = "SELECT canRead, canWrite, groupId, groupName  FROM groupProjectPermView WHERE projectId="&SQLClean(projectId,"N","S") & " and userId=" & SQLClean(userId,"N","S")
cgRec.open strQuery,conn,3,3
If Not cgRec.eof Then
	'if the user is a member of a group that has a read invite to the project hen the user can see the notebook
	If cgRec("canRead") = 1 And cgRec("canWrite") = 0 then
		experimentAccessString = experimentAccessString & "Shared with read access with group <a href='"&mainAppPath&"/table_pages/show-group.asp?id="&cgRec("groupId")&"'>"&cgRec("groupName")&"</a>.<br/>"
	End If
	If cgRec("canRead") = 0 And cgRec("canWrite") = 1 then
		experimentAccessString = experimentAccessString & "Shared with write access with group <a href='"&mainAppPath&"/table_pages/show-group.asp?id="&cgRec("groupId")&"'>"&cgRec("groupName")&"</a>.<br/>"
	End If
	If cgRec("canRead") = 1 And cgRec("canWrite") = 1 then
		experimentAccessString = experimentAccessString & "Shared with read/write access with group <a href='"&mainAppPath&"/table_pages/show-group.asp?id="&cgRec("groupId")&"'>"&cgRec("groupName")&"</a>.<br/>"
	End if
End if
cgRec.close
Set cgRec = nothing


response.write(experimentAccessString)

%>