<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DISTINCT notebookId," &_
				"userId," &_
				"name," &_
				"visible," &_
				"lastViewed," &_
				"description," &_
				"fullName " &_
"FROM allNotebookPermViewWithInfo " &_
"WHERE companyId={cId} " &_
"AND userId={uId} " &_
"AND visible=1 " &_
"AND (accepted=1 OR accepted is null)"
strQuery = Replace(strQuery, "{cId}", SQLClean(session("companyId"),"N","S"))
strQuery = Replace(strQuery, "{uId}", SQLClean(session("userId"),"N","S"))
rec.open strQuery,conn,0,-1

Do While Not rec.eof
    name = rec("name")
    desc = rec("description")
    creator = rec("fullName")
    lastViewed = rec("lastViewed")
    notebookId = rec("notebookId")
    
    response.write("<a href=" & mainAppPath & "/show-notebook.asp?id=" & notebookId & "> " & name & "</a>" & ":::" &_
                   desc & ":::" &_
                   creator & ":::" &_
                   lastViewed & ";;;")
	rec.movenext
loop
rec.close
%>