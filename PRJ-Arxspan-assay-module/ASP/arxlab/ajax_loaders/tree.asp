<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
theType = request("type")
key = request("key")

Call getconnected
Set r = JSON.parse("[]")
Select Case theType
	Case "root"
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT DISTINCT projectId,userId,name,visible,lastViewed,description,fullName FROM allProjectPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and (accepted=1 or accepted is null) and parentProjectId is NULL "
		rec.open strQuery,conn,0,-1
		Do While Not rec.eof
			url = mainAppPath&"/show-project.asp?id="&rec("projectId")
			Set this = JSON.parse("{}")
			this.Set "key",CStr(rec("projectId"))
			this.Set "title",CStr(rec("name"))
			this.Set "icon","folder.gif"
			this.Set "isLazy",True
			this.Set "type","project"
			this.Set "url",url
			r.push(this)
			rec.moveNext
		Loop
		rec.close
		Set rec = nothing

	Case "project"
		If canReadProject(key,session("userId")) Then
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT id, name FROM projects WHERE parentProjectId="&SQLClean(key,"N","S")
			rec.open strQuery,conn,0,-1
			Do While Not rec.eof
				url = mainAppPath&"/show-project.asp?id="&rec("id")
				Set this = JSON.parse("{}")
				this.Set "key",CStr(rec("id"))
				this.Set "title",CStr(rec("name"))
				this.Set "icon","folder.gif"
				this.Set "isLazy",True
				this.Set "type","subProject"
				this.Set "url",url
				r.push(this)
				rec.moveNext
			Loop
			rec.close
			Set rec = nothing
		End If
	Case "subProject"
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT DISTINCT notebookId,userId,name,visible,lastViewed,description,fullName FROM allNotebookPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and (accepted=1 or accepted is null) and notebookId in (SELECT notebookId from linksProjectNotebooks WHERE projectId="&SQLClean(key,"N","S")&")"
		rec.open strQuery,conn,0,-1
		Do While Not rec.eof
			url = mainAppPath&"/show-notebook.asp?id="&rec("notebookId")
			Set this = JSON.parse("{}")
			this.Set "key",CStr(rec("notebookId"))
			this.Set "title",CStr(rec("name"))
			this.Set "icon","folder.gif"
			this.Set "isLazy",True
			this.Set "type","notebook"
			this.Set "url",url
			r.push(this)
			rec.moveNext
		Loop
		rec.close
		Set rec = nothing
	Case "notebook"
		If canReadNotebook(key,session("userId")) then
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT typeId, experimentId, name FROM notebookIndexView WHERE notebookId="&SQLClean(key,"N","S") & " AND visible=1"
			rec.open strQuery,conn,0,-1
			Do While Not rec.eof
				prefix = GetPrefix(rec("typeId"))
				page = GetExperimentPage(prefix)
				url = mainAppPath&"/" & page & "?id="&rec("experimentId")
				Set this = JSON.parse("{}")
				this.Set "key",CStr(rec("experimentId"))
				this.Set "title",CStr(rec("name"))
				this.Set "icon","plate.gif"
				this.Set "isLazy",False
				this.Set "type","experiment"
				this.Set "url",url
				r.push(this)
				rec.moveNext
			Loop
			rec.close
			Set rec = nothing
		End if
End select

response.write(JSON.stringify(r))
Call disconnect
%>