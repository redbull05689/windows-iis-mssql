<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Set rec = server.CreateObject("ADODB.RecordSet")

strQuery = "SELECT DISTINCT notebookId, " &_
                "projectId, " &_
                "shareeId, " &_
                "name, " &_
                "sharerFullName, " &_
                "type " &_
"FROM allInvitesViewWithInfo " &_
"WHERE shareeId={uId} " &_
"AND (accepted=0 and denied=0);"
strQuery = Replace(strQuery, "{uId}", SQLClean(session("userId"),"N","S"))
session("query") = strQuery
rec.open strQuery,conn,0,-1

Do While Not rec.eof
    name = rec("name")
    notebookId = rec("notebookId")
    projectId = rec("projectId")
    invType = rec("type")
    sharer = rec("sharerFullName")

    invLink = ""
    if invType = "Project" then
        invLink = "show-project.asp?id=" & projectId
    elseif invType = "Notebook" then
        invLink = "show-notebook.asp?id=" & notebookId
    end if

    response.write("<a href=" & mainAppPath & "/" & invLink & "> " & name & "</a>" & ":::" &_
                   invType & ":::" &_
                   sharer & ";;;")
	rec.movenext
loop
rec.close
%>