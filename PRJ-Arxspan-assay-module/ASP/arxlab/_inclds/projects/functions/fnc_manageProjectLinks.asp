<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%

Response.CodePage = 65001
Response.CharSet = "UTF-8"

Function addTabToProject(projectId, tabName, tabDescription, includedFrom)
	Call getconnectedadm
	If ownsProject(projectId) or (session("role")="Admin") And tabName <> "" then
		Dim newProjects(2)
		newProjects(0) = Null
		newProjects(1) = Null
		
		includedFromProjectId = SQLClean(includedFrom,"N","S")
		If IsNull(includedFrom) Then
			includedFromProjectId = "NULL"
		End If

		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM projects WHERE parentProjectId="&SQLClean(projectId,"N","S")
		rec.open strQuery,connAdm,3,3
		If rec.eof Then
			rec.close
			hasLinks = false
			
			strQuery = "SELECT id FROM linksProjectExperiments WHERE projectId="&SQLClean(projectId,"N","S")
			rec.open strQuery,connAdm,3,3
			If Not rec.eof Then
				hasLinks = True
			End If
			rec.close
			
			strQuery = "SELECT id FROM linksProjectNotebooks WHERE projectId="&SQLClean(projectId,"N","S")
			rec.open strQuery,connAdm,3,3
			If Not rec.eof Then
				hasLinks = True
			End If
			rec.close
			
			strQuery = "SELECT id FROM linksProjectReg WHERE projectId="&SQLClean(projectId,"N","S")
			rec.open strQuery,connAdm,3,3
			If Not rec.eof Then
				hasLinks = True
			End If
			rec.close
			
			If hasLinks Then
				strQuery = "INSERT into projects(name,userId,companyId,parentProjectId,includedFromProjectId,visible) output inserted.id as newId values(" &_
				SQLClean("default","T","S") & "," &_
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(session("companyId"),"N","S") & "," &_
				SQLClean(projectId,"N","S") & "," &_
				includedFromProjectId & "," &_
				SQLClean("1","N","S") & ")"
				Set rs = connAdm.execute(strQuery)
				newProjects(0) = rs("newId")
				newProjectId = CStr(rs("newId"))
				
				strQuery = "SELECT experimentType, experimentId FROM linksProjectExperiments WHERE projectId="&SQLClean(projectId,"N","S")
				rec.open strQuery,connAdm,3,3
				Do While Not rec.eof
					Call removeExperimentFromProject(connAdm, rec("experimentType"), rec("experimentId"), projectId)
					Call addExperimentToProject(connAdm, rec("experimentType"), rec("experimentId"), newProjectId, null, null)
					rec.movenext
				Loop
				rec.close
				
				strQuery = "SELECT notebookId FROM linksProjectNotebooks WHERE projectId="&SQLClean(projectId,"N","S")
				rec.open strQuery,connAdm,3,3
				Do While Not rec.eof
					Call removeNotebookFromProject(connAdm, rec("notebookId"), projectId)
					Call addNotebookToProject(connAdm, rec("notebookId"), newProjectId, null)
					rec.movenext
				Loop
				rec.close
				
				strQuery = "SELECT cd_id FROM linksProjectReg WHERE projectId="&SQLClean(projectId,"N","S")
				rec.open strQuery,connAdm,3,3
				Do While Not rec.eof
					Call removeRegIdFromProject(connAdm, rec("cd_id"), projectId)
					Call addRegIdToProject(connAdm, rec("cd_id"), newProjectId, null)
					rec.movenext
				Loop
				rec.close
				Set rec = Nothing
			End if
		End If
		
		strQuery = "INSERT into projects(name,userId,visible,companyId,includedFromProjectId,parentProjectId) output inserted.id as newId values(" &_
		SQLClean(tabName,"T","S") & "," &_
		SQLClean(session("userId"),"N","S") & "," &_
		SQLClean("1","N","S") & "," &_
		SQLClean(session("companyId"),"N","S") & "," &_
		includedFromProjectId & "," &_
		SQLClean(projectId,"N","S") & ");" 
		Set rs = connAdm.execute(strQuery)
		newProjects(1) = rs("newId")
		addTabToProject = rs("newId")
		
		Set pRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT toProjectId FROM projectAutoLinks WHERE disabled=0 AND fromProjectId="&projectId
		pRec.open strQuery,connAdm,3,3
		Do While Not pRec.eof
			For each project in newProjects
				If Not IsNull(project) Then
					Call addAllLinksFromProject(connAdm, pRec("toProjectId"), projectId)
				End If
			next
		pRec.movenext
		Loop
	End if
	Call disconnectadm
End Function

Function getParentProjectId(projectId)
	Call getConnected
	strQuery = "SELECT parentProjectId FROM projects WHERE id=" & SQLClean(projectId,"N","S") & " AND parentProjectId IS NOT NULL"
	Set rs = server.CreateObject("ADODB.RecordSet")
	rs.open strQuery,conn,3,3
	If rs.eof Then
		getParentProjectId = projectId
	Else
		getParentProjectId = getParentProjectId(rs("parentProjectId"))
	End If
	Call disconnect
End Function

Function getLinkedProjectIds(projectId)
	Dim retVal : retVal = Array()
	parentProjectId = getParentProjectId(projectId)
	If Trim(parentProjectId) = Trim(projectId) Then
		ReDim Preserve retVal(UBound(retVal) + 1)
		retVal(UBound(retVal)) = projectId
	Else
		Call getConnected
		strQuery = "SELECT toProjectId FROM projectAutoLinks WHERE disabled=0 AND fromProjectId="&parentProjectId
		Set pRec = server.CreateObject("ADODB.RecordSet")
		pRec.open strQuery,conn,3,3

		strQuery = "SELECT name FROM projects WHERE id=" & SQLClean(projectId,"N","S")
		Set nRec = server.CreateObject("ADODB.RecordSet")
		nRec.open strQuery,conn,3,3
		If Not nRec.eof Then
			Do While Not pRec.eof
				strQuery = "SELECT id FROM projects WHERE name=" & SQLClean(nRec("name"),"T","S") & " AND parentProjectId=" & SQLClean(pRec("toProjectId"),"N","S")
				Set iRec = server.CreateObject("ADODB.RecordSet")
				iRec.open strQuery,conn,3,3
				If Not iRec.eof Then
					ReDim Preserve retVal(UBound(retVal) + 1)
					retVal(UBound(retVal)) = iRec("id")
				End If
				iRec.close
				pRec.movenext
			Loop
		End If
		nRec.close
		pRec.close
		Call disconnect
	End If
	getLinkedProjectIds = retVal
End Function

Function addExperimentToProject(connAdm, experimentType, experimentId, projectId, includedFromProjectId, linkComment)
	If ((Not IsNull(includedFromProjectId)) Or canWriteProject(projectId, session("userId"))) And canViewExperiment(experimentType,experimentId,session("userId")) then
		insertIncludedFromProjectId = SQLClean(includedFromProjectId,"N","S")
		
		stringToDealWithSQLStupidity = "includedFromProjectId="&insertIncludedFromProjectId
		If IsNull(includedFromProjectId) Then
			insertIncludedFromProjectId = "NULL"
			stringToDealWithSQLStupidity = "includedFromProjectId is NULL"
		End If

		Set tRec = server.CreateObject("ADODB.RecordSet")
		
		strQuery = "SELECT id FROM linksProjectExperiments WHERE experimentType="&SQLClean(experimentType,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")& " AND projectId="&SQLClean(projectId,"N","S")& " AND " & stringToDealWithSQLStupidity
		tRec.open strQuery,connAdm,3,3
		
		If tRec.eof then
			if not IsNull(linkComment) then
				linkComment = Server.HTMLEncode(linkComment)
			end if 
			
			strQuery = "INSERT into linksProjectExperiments(experimentType,experimentId,projectId,includedFromProjectId,comments) values(" &_
			SQLClean(experimentType,"N","S") & "," &_
			SQLClean(experimentId,"N","S") & "," &_
			SQLClean(projectId,"N","S") & "," &_
			insertIncludedFromProjectId & "," &_
			SQLClean(linkComment,"T","S") & ")"
			connAdm.execute(strQuery)
			
			toProjectIds = getLinkedProjectIds(projectId)
			For each toProjectId in toProjectIds
				'ELN-672 when the project doesn't have a tab both projectId and parentProjectId both will be same so we should avoid adding second time.. 
				If Trim(projectId) <> Trim(toProjectId) then 
					Call addExperimentToProject(connAdm, experimentType, experimentId, toProjectId, projectId, null)
				end if
			next
		Else
			addExperimentToProject = "Experiment already exists in project."
		End If
		
		tRec.close
		Set tRec = nothing
	End If
End Function

Function addNotebookToProject(connAdm, notebookId, projectId, includedFromProjectId)
	If ((Not IsNull(includedFromProjectId)) Or canWriteProject(projectId, session("userId"))) And canReadNotebook(notebookId,session("userId")) Then
		insertIncludedFromProjectId = SQLClean(includedFromProjectId,"N","S")
		If IsNull(includedFromProjectId) Then
			insertIncludedFromProjectId = "NULL"
		End If

		Set tRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM linksProjectNotebooks WHERE notebookId="&SQLClean(notebookId,"N","S")& " AND projectId="&SQLClean(projectId,"N","S")& " AND includedFromProjectId="&insertIncludedFromProjectId
		tRec.open strQuery,connAdm,3,3
		If tRec.eof then
			strQuery = "INSERT into linksProjectNotebooks(notebookId,projectId,includedFromProjectId) values(" &_
			SQLClean(notebookId,"N","S") & "," &_
			SQLClean(projectId,"N","S") & "," &_
			insertIncludedFromProjectId & ")"
			connAdm.execute(strQuery)

			toProjectIds = getLinkedProjectIds(projectId)
			For each toProjectId in toProjectIds
				'ELN-672 when the project doesn't have a tab both projectId and parentProjectId both will be same so we should avoid adding the notebook second time.. 
				if projectId <> toProjectId then 
					Call addNotebookToProject(connAdm, notebookId, toProjectId, projectId)
				end if
			next
		Else
			addNotebookToProject = "Notebook already exists in project."
		End If
	End If
End Function

Function addRegIdToProject(connAdm, cdId, projectId, includedFromProjectId)
	If canWriteProject(projectId, session("userId")) And session("regUser") then
		insertIncludedFromProjectId = SQLClean(includedFromProjectId,"N","S")
		If IsNull(includedFromProjectId) Then
			insertIncludedFromProjectId = "NULL"
		End If

		Set tRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM linksProjectReg WHERE cd_id="&SQLClean(cdId,"N","S")& " AND projectId="&SQLClean(projectId,"N","S")& " AND includedFromProjectId="&insertIncludedFromProjectId
		tRec.open strQuery,connAdm,3,3
		If tRec.eof then
			strQuery = "INSERT into linksProjectReg(cd_id,projectId,includedFromProjectId) values(" &_
			SQLClean(cdId,"N","S") & "," &_
			SQLClean(projectId,"N","S") & "," &_
			insertIncludedFromProjectId & ")"
			connAdm.execute(strQuery)

			toProjectIds = getLinkedProjectIds(projectId)
			For each toProjectId in toProjectIds
				'ELN-672 when the project doesn't have a tab both projectId and parentProjectId both will be same so we should avoid adding the regid second time.. 
				if projectId <> toProjectId then 
					Call addRegIdToProject(connAdm, cdId, toProjectId, projectId)
				End If
			next
		Else
			addRegIdToProject = "Registration item already exists in project."
		End If
		tRec.close
		Set tRec = nothing
	End if
End Function

Function removeExperimentFromProject(connAdm, experimentType, experimentId, projectId)
	if ownsProject(projectId) Or canWriteProject(projectId,session("userId")) then
		strQuery = "DELETE FROM linksProjectExperiments WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND projectId=" & SQLClean(projectId,"N","S")
		connAdm.execute(strQuery)
		
		toProjectIds = getLinkedProjectIds(projectId)
		For each toProjectId in toProjectIds
			'ELN-695 when the project doesn't have a tab both projectId and parentProjectId both will be same 
			If Trim(projectId) <> Trim(toProjectId) Then 
				Call removeExperimentFromProject(connAdm, experimentType, experimentId, toProjectId)
			End If
		next
	end if
End Function

Function removeNotebookFromProject(connAdm, notebookId, projectId)
	if ownsProject(projectId) Or canWriteProject(projectId,session("userId")) then
		strQuery = "DELETE FROM linksProjectNotebooks WHERE notebookId="&SQLClean(notebookId,"N","S") & " AND projectId=" & SQLClean(projectId,"N","S")
		connAdm.execute(strQuery)
		
		toProjectIds = getLinkedProjectIds(projectId)
		For each toProjectId in toProjectIds
			'ELN-695 when the project doesn't have a tab both projectId and parentProjectId both will be same 
			If projectId <> toProjectId Then 
				Call removeNotebookFromProject(connAdm, notebookId, toProjectId)
			End If
		next
	end if
End Function

Function removeRegIdFromProject(connAdm, cdId, projectId)
	if ownsProject(projectId) Or canWriteProject(projectId,session("userId")) then
		strQuery = "DELETE FROM linksProjectReg WHERE cd_id="&SQLClean(cdId,"N","S") & " AND projectId=" & SQLClean(projectId,"N","S")
		connAdm.execute(strQuery)
		
		regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
		
		Call getconnectedJchemReg
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT projectId FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(cdId,"N","S")
		rec.open strQuery,jchemRegConn,3,3
		If Not rec.eof Then
			If Not IsNull(rec("projectId")) Then
				If CStr(rec("projectId")) = CStr(projectId) Then
					strQuery = "UPDATE "&regMoleculesTable&" SET projectId=null WHERE cd_id="&SQLClean(cdId,"N","S")
					jchemRegConn.execute(strQuery)
				End If
			End If
		End If
		Call disconnectJchemReg
		
		toProjectIds = getLinkedProjectIds(projectId)
		For each toProjectId in toProjectIds
			'ELN-695 when the project doesn't have a tab both projectId and parentProjectId both will be same 
			If projectId <> toProjectId Then 
				Call removeRegIdFromProject(connAdm, cdId, toProjectId)
			End If
		next
	end if
End Function

Function initializeIncludedProject(projectIncluding, projectIncluded)
	Call getconnectedadm
	If ownsProject(projectIncluding) and canReadProject(projectIncluded, session("userId")) Then
		Call addAllLinksFromProject(connAdm, projectIncluding, projectIncluded)
	End If
Call disconnectadm
End Function

Function addAllLinksFromProject(connAdm, projectIncluding, projectIncluded)
	If ownsProject(projectIncluding) and canReadProject(projectIncluded, session("userId")) Then		
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		fn="C:/Temp/" & projectIncluding & "-" & projectIncluded & ".txt"
		set tfile=fs.CreateTextFile(fn)
		
		'Add all experiments from this project
		strQuery = "SELECT id, name, description FROM projects WHERE (parentProjectId="&SQLClean(projectIncluded,"N","S")&" or id="&SQLClean(projectIncluded,"N","S")&")"
		tfile.WriteLine(strQuery)
		Set subRec = server.CreateObject("ADODB.RecordSet")
		subRec.open strQuery,connAdm,3,3
		Do While Not subRec.eof
			strQuery = "SELECT id FROM projects WHERE parentProjectId="&SQLClean(projectIncluding,"N","S")&" AND name=("&SQLClean(subRec("name"),"T","S") & "COLLATE Latin1_General_CS_AS) order by id asc"
			tfile.WriteLine(strQuery)
			Set parRec = server.CreateObject("ADODB.RecordSet")
			parRec.open strQuery,connAdm,3,3
			parId = Null
			
			If Not parRec.eof Then
				updateSql = "UPDATE projects SET includedFromProjectId=" & SQLClean(subRec("id"),"N","S") & " WHERE id=" & SQLClean(parRec("id"),"N","S")
				tfile.WriteLine(updateSql)
				connAdm.execute(updateSql)
				parId = parRec("id")
			Else
				tfile.WriteLine("calling addTabToProject(" & projectIncluding & "," & subRec("name") & "," & subRec("description") & "," & subRec("id") & ")")
				parId = addTabToProject(projectIncluding, subRec("name"), subRec("description"), subRec("id"))
			End If
			parRec.close
			Set parRec = Nothing
			
			If (Not IsNull(parId)) And subRec("id") <> projectIncluded Then
				tfile.WriteLine("calling addAllLinksFromProject(" & connAdm & "," & parId & "," & subRec("id") & ")")
				Call addAllLinksFromProject(connAdm, parId, subRec("id"))
			End If
			subRec.movenext
		Loop
		subRec.close
		Set subRec = Nothing
		tfile.WriteLine("done!")
		set tfile=nothing
		set fs=nothing
	End if
End Function
%>