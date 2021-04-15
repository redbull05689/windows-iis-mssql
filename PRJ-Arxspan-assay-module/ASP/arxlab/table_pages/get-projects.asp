<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DISTINCT projectId," &_
				"userId," &_
				"name," &_
				"visible," &_
				"lastViewed," &_
				"description," &_
				"fullName " &_
"FROM allProjectPermViewWithInfo " &_
"WHERE userId={uId} " &_
"AND visible=1 " &_
"AND (accepted=1 OR accepted is null) " &_
"AND parentProjectId is NULL"
strQuery = Replace(strQuery, "{uId}", SQLClean(session("userId"),"N","S"))
rec.open strQuery,conn,0,-1

Do While Not rec.eof
    name = rec("name")
    desc = rec("description")
    creator = rec("fullName")

	' 8624: GMT or EST?
    lastViewedUTC = rec("lastViewed")
	If session("useGMT") Then
		lastViewed = lastViewedUTC
	Else
		lastViewed = ConvertUTCToLocal(lastViewedUTC)
	End If

    projectId = rec("projectId")
    
    response.write("<a href=" & mainAppPath & "/show-project.asp?id=" & projectId & "> " & name & "</a>" & ":::" &_
                   desc & ":::" &_
                   creator & ":::" &_
                   lastViewed & ";;;")
	rec.movenext
loop
rec.close
%>