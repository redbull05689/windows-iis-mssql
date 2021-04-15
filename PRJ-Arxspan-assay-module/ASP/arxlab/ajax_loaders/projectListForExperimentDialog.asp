<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../_inclds/globals.asp"-->
<select id="linkProjectId" name="linkProjectId" class="selectStyles">
	<option value="""">--SELECT--</option>
	<%
	strQuery = "SELECT DISTINCT projectId,userId,name,visible,lastViewed,description,fullName FROM allProjectPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and ((accepted=1 and canWrite=1) or (accepted is null and canWrite=1) or canWrite is null) and parentprojectId is null"
	Set nRec = server.CreateObject("ADODB.RecordSet")
	nRec.CursorLocation = adUseClient
	nRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
    nRec.Sort = "lastViewed DESC"

    inProjectIds = ""
    Set projectJson = JSON.Parse("[]")
    Do While Not nRec.eof
        description = ""
        If Not IsNull(nRec("description")) Then
            description = nRec("description")
        End If
        
        projectId = ""
        If Not IsNull(nRec("projectId")) Then
            projectId = nRec("projectId")
        End If
        
        name = ""
        If Not IsNull(nRec("name")) Then
            name = nRec("name")
        End If
        
        Set pj = JSON.Parse("{}")
        pj.Set "description", description
        pj.Set "projectId", projectId
        pj.Set "name", name
        
        If Len(inProjectIds) > 0 Then
            inProjectIds = inProjectIds & "," & projectId
        Else
            inProjectIds = projectId
        End If

        projectJson.push pj
        Set pj = Nothing
        nRec.movenext
    Loop
    nRec.close
    Set nRec = Nothing
    
    If inProjectIds <> "" Then
	    strQuery = "SELECT id,parentProjectId,name,description FROM projects WHERE parentprojectId in (" & inProjectIds & ")"
	    Set nRec = server.CreateObject("ADODB.RecordSet")
	    nRec.CursorLocation = adUseClient
	    nRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
        nRec.Sort = "id, name"
    
        Set subProjectJson = JSON.Parse("{}")
        Do While Not nRec.eof
            description = ""
            If Not IsNull(nRec("description")) Then
                description = nRec("description")
            End If
        
            projectId = ""
            If Not IsNull(nRec("id")) Then
                projectId = nRec("id")
            End If
        
            name = ""
            If Not IsNull(nRec("name")) Then
                name = nRec("name")
            End If
        
            parentProjectId = ""
            If Not IsNull(nRec("parentprojectId")) Then
                parentProjectId  = nRec("parentprojectId")
            End If
        
            Set pj = JSON.Parse("{}")
            pj.Set "description", description
            pj.Set "projectId", projectId
            pj.Set "name", name
        
            Set subProjectList = JSON.Parse("[]")
            If subProjectJson.Exists(CStr(parentProjectId)) Then
                Set subProjectList = subProjectJson.Get(CStr(parentProjectId))
            End If
        
            subProjectList.push pj
            subProjectJson.Set parentProjectId, subProjectList
        
            nRec.movenext
        Loop
        nRec.close
        Set nRec = Nothing
    End If

    i = 0
    Do While i < projectJson.Length
        selectedStr = ""
        Set project = projectJson.Get(i)
        
        If subProjectJson.Exists(CStr(project.Get("projectId"))) Then
            response.write("<option value=""x"">"&project.Get("name")&"</option>")
          
            j = 0
            Set subProjects = subProjectJson.Get(CStr(project.Get("projectId")))
            Do While j < subProjects.Length
                selectedStr = ""
                Set sp = subProjects.Get(j)
                If CStr(sp.Get("projectId")) = CStr(session("defaultProjectId")) Then
                    selectedStr = "selected"
                End if
                response.write("<option projectDescription="""&Replace(project.Get("description"),"""","&quot;")&""" projectName="""&Replace(project.Get("name")&" => "&sp.Get("name"),"""","&quot;")&""" value="""&sp.Get("projectId")&""" "&selectedStr&">--"&sp.Get("name")&"</option>")
                j = j + 1
            Loop
        Else
            If CStr(project.Get("projectId")) = CStr(session("defaultProjectId")) Then
                selectedStr = "selected"
            End if
            response.write("<option projectDescription="""&Replace(project.Get("description"),"""","&quot;")&""" projectName="""&Replace(project.Get("name"),"""","&quot;")&""" value="""&project.Get("projectId")&""" "&selectedStr&">"&project.Get("name")&"</option>")
        End If
        
        i = i + 1
    Loop
%>
</select>