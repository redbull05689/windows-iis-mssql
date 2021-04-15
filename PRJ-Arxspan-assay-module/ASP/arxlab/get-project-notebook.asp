<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"--><%
Set rec = server.CreateObject("ADODB.RecordSet")
projId = request.form("id")
projectOwner = request.form("projectOwner")
strQuery = "SELECT * " &_
"FROM linksProjectNotebooksView " &_
"WHERE projectId={projectId} " &_
"AND (visible=1 or visible is null);"
strQuery = Replace(strQuery, "{projectId}", projId)
rec.open strQuery,conn

isProjectOwner = ownsProject(projId)
isAdministrator = isAdminUser(session("userId"))

Do While Not rec.eof
	If isProjectOwner Or isAdministrator Or canWriteNotebook(rec("notebookId")) Or canReadNotebook(rec("notebookId"), session("userId")) Then
		notebookId = rec("notebookId")
		notebookName = rec("name")
		desc = rec("description")
		owner = rec("notebookOwnerName")

		delButton = ""

		If projectOwner or (session("canDelete") and session("role")="Admin") Then
			delButton = "<a href='javascript:void(0);' onclick='deleteProjectNotebook(" & notebookId & ", " & projId & ")'> <img src='" & mainAppPath & "/images/cross_2_1x.png' class='png' height='12' width='12' border='0'></a>"
		End If

		response.write("<a href=" & mainAppPath & "/show-notebook.asp?id=" & notebookId & "> " & notebookName & "</a>" & ":::" &_
						desc & ":::" &_
						owner & ":::" &_
						delButton & ";;;")
	End If
	rec.movenext
loop
rec.close
%>