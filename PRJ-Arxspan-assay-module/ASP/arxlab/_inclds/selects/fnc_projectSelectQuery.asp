<%
    'function fetches projects from the db and sends the results out as a json array of objects
    function getProjects()
		' IDQ 8623: If the current user is a sharee, view allProjectPermViewWithInfo below returns only the parent project and not the subprojects.
		' While the view is being called in other places and changing it would be a bit risky, I work around this using a temp table. 
        strQuery =  "SET NOCOUNT ON " &_
					"SELECT DISTINCT projectId,userId,name,visible,lastViewed,description,parentprojectId " &_
					"INTO #t " &_
                    "FROM allProjectPermViewWithInfo " &_
                    "WHERE userId="&SQLClean(session("userId"),"N","S")&" " &_
						"AND visible=1 "&_
						"AND ( " &_ 
						"(accepted=1 AND canWrite=1) " &_ 
						"OR (accepted is null AND canWrite=1) " &_ 
						"OR canWrite is null " &_
						"); " &_
					"INSERT INTO #t " &_
					"SELECT p.id, p.userId,p.name,p.visible,t.lastViewed,p.description,p.parentProjectId " &_
					"FROM projects p INNER JOIN #t t ON p.parentProjectId = t.projectId " &_
					"WHERE p.visible = 1 AND NOT EXISTS (SELECT 1 FROM #t WHERE projectId = p.id);" &_
					"SELECT * FROM #t;" &_
					"DROP TABLE #t;"
        Set nRec = server.CreateObject("ADODB.RecordSet")
		nRec.CursorLocation = adUseClient
        nRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
		nRec.sort = "lastViewed DESC"
		
		Set projectDict = JSON.parse("{}")
		recordsFound = False
        Do while Not nRec.eof
			recordsFound = True
			If IsNull(nRec("parentProjectId")) Then
				If Not projectDict.exists(nRec("projectId")) Then
					Set projectObj = JSON.parse("{}")
					projectObj.set "id", CStr(nrec("projectId"))
					projectObj.set "projectName", CStr(nrec("name"))
					projectObj.set "description", CStr(nrec("description"))
					projectObj.set "parentProjectId", null
					projectObj.set "subprojects", JSON.parse("{}")
					projectDict.Set CStr(nrec("projectId")), projectObj
				End If
			End If
            nRec.movenext
        Loop
		
		If recordsFound Then
			nRec.MoveFirst
			Do while Not nRec.eof
				If (Not IsNull(nRec("parentProjectId"))) Then
					parentProjectId = CStr(nRec("parentProjectId"))
					If projectDict.Exists(parentProjectId) Then
						Set parentProjectObj = projectDict.Get(nRec("parentProjectId"))
						Set projectObj = JSON.parse("{}")
						projectObj.set "id", CStr(nrec("projectId"))
						name = nRec("name")
						If IsNull(name) Then
							name = CStr("")
						Else
							name = CStr(name)
						End If
						projectObj.set "projectName", name
						description = nRec("description")
						If IsNull(description) Then
							description = CStr("")
						Else
							description = CStr(description)
						End If
						projectObj.set "description", description
						projectObj.set "parentProjectId", parentProjectId
						Set subProjectDict = parentProjectObj.Get("subprojects")
						subProjectDict.Set CStr(nrec("projectId")), projectObj
						parentProjectObj.Set "subprojects", subProjectDict
						projectDict.Set CStr(nrec("parentProjectId")), parentProjectObj
					End If
				End If
				nRec.movenext
			Loop
		End If
		
        nRec.close
        Set nRec = nothing
		
		Set projectList = JSON.parse("[]")
		For Each parentId in projectDict.keys()
			Set projectObj = projectDict.Get(parentId)
			Set subprojects = projectObj.Get("subprojects")
			projectList.push(projectObj)
			
			For Each projectId in subprojects.keys()
				Set projectObj = subprojects.Get(projectId)
				projectList.push(projectObj)
			Next
		Next
        getProjects = JSON.stringify(projectList)    

    End function  
%>
