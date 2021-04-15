<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentId = SQLClean(request.Form("experimentId"),"N","S")
experimentType = SQLClean(request.Form("experimentType"),"N","S")
revisionId = SQLClean(request.Form("revisionId"),"N","S")
experimentStatusId = SQLClean(request.Form("experimentStatusId"),"N","S")
experimentLinkSection = SQLClean(request.Form("experimentLinkSection"),"JSON","S")

Call Response.Clear()
Response.ContentType = "application/json"

if canViewExperiment(experimentType,experimentId,session("userId")) then
	call getconnected

	Response.LCID = 2057	
	Dim aspJSONarray: Set aspJSONarray = New JSONarray

	If experimentLinkSection = "experiment" Then

		strQuery = "SELECT linkExperimentType, " &_
			"prev, " &_
			"next, " &_
			"linkExperimentId, " &_
			"name, " &_
			"firstName, " &_
			"lastName, " &_
			"details, " &_
			"comments " &_
		"FROM {fromTable} " &_
		"WHERE visible=1 " &_		
		"AND experimentId={expId} " &_		
		"AND experimentType={expType} {revision}"
		
		fromTable = "(SELECT * FROM experimentLinksView UNION ALL SELECT * FROM experimentLinks_preSaveView) AS T"
		revision = ""
		
		if revisionId <> 0 then
			fromTable = "experimentLinks_historyView"
			revision = "AND revisionNumber=" & revisionId
		end if

		strQuery = Replace(strQuery, "{fromTable}", fromTable)
		strQuery = Replace(strQuery, "{expId}", experimentId)
		strQuery = Replace(strQuery, "{expType}", experimentType)
		strQuery = Replace(strQuery, "{revision}", revision)

		Dim rs: Set rs = conn.execute(strQuery)

		if not rs.EOF then
		  	Call aspJSONarray.LoadRecordset(rs)		  	
		  	for each item in aspJSONarray.items
		  	    if isObject(item) and typeName(item) = "JSONobject" then
		  	        canDeleteExperimentLink = False
		  	        If ownsExperiment(experimentType,experimentId,session("userId")) And Not isExperimentClosedByStatus(experimentStatusId) then
		  	        	canDeleteExperimentLink = True
		  	        End If
		  	        item.Add "canDeleteExperimentLink", canDeleteExperimentLink
		  	    end if
		  	next
		end if
		rs.close
		set rs = nothing
	ElseIf experimentLinkSection = "project" Then
		
		Set lRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT projectName, projectId, description, parentProjectId, comments FROM linksProjectExperimentsView WHERE experimentId="&SQLClean(experimentId,"N","S")& " AND typeId="&SQLClean(experimentType,"N","S")
		lRec.open strQuery,conn
		Do While Not lRec.eof
			If canReadProject(lRec("projectId"), session("userId")) Or canWriteProject(lRec("projectId"), session("userId"))Then
				projectName = lRec("projectName")
				projectId = lRec("projectId")
				projectDescription = lRec("description")
				linkComment = lRec("comments")
				If Not IsNull(lRec("parentProjectId")) Then
					Set lRec2 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT name, description FROM projects WHERE id="&SQLClean(lRec("parentProjectId"),"N","S")
					lRec2.open strQuery,conn
					If Not lRec2.eof Then
						parentProjectName = lRec2("name")
					End If
					projectName = parentProjectName & " => "&projectName
					projectDescription = lRec2("description")
				End if
				
				canDeleteExperimentLink = False
				if (ownsProject(projectId) Or canWriteProject(projectId,session("userId"))) And Not isExperimentClosedByStatus(experimentStatusId) then
					canDeleteExperimentLink = True
				End if
				
				set aspJSONobject = New JSONobject
				aspJSONobject.Add "projectName", projectName
				aspJSONobject.Add "projectId", projectId
				aspJSONobject.Add "projectDescription", projectDescription
				aspJSONobject.Add "linkComment", linkComment
				aspJSONobject.Add "canDeleteExperimentLink", canDeleteExperimentLink
				aspJSONarray.Push aspJSONobject
			End If
			lRec.moveNext
		Loop

		prefix = GetPrefix(experimentType)
		expNotebookView = GetExperimentView(prefix)
		historyTableView = GetFullName(prefix, "experimentHistoryView", true)
		
		' We need to get the notebookId (if any) associated with this experiment
		If revisionId = 0 then
			strQuery = "SELECT * FROM " & expNotebookView & " WHERE id=" & experimentId
		Else
			strQuery = "SELECT * FROM " & historyTableView & " WHERE experimentId=" & experimentId & " AND revisionNumber="&SQLClean(revisionId,"N","S")
		End if

		set	expRec = Server.CreateObject("ADODB.RecordSet")
		
		expRec.open strQuery,conn,3,3
		If Not expRec.eof Then
			notebookId = expRec("notebookId")
		Else
			notebookId = 0
		End If

		' Get the "Via Notebook" experiment project links
		Set lRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT projectId, projectName, projectDescription, parentProjectId FROM linksProjectNotebooksView WHERE notebookId="&SQLClean(notebookId,"N","S")

		lRec.open strQuery,conn
		Do While Not lRec.eof
			If canReadProject(lRec("projectId"), session("userId")) Or canWriteProject(lRec("projectId"), session("userId")) Then
				projectName = lRec("projectName")
				projectId = lRec("projectId")
				projectDescription = lRec("projectDescription")
				If Not IsNull(lRec("parentProjectId")) Then
					Set lRec2 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT name, description FROM projects WHERE id="&SQLClean(lRec("parentProjectId"),"N","S")
					lRec2.open strQuery,conn
					If Not lRec2.eof Then
						parentProjectName = lRec2("name")
					End If
					projectName = parentProjectName & " => "&projectName
					projectDescription = lRec2("description")
				End if

				set aspJSONobject = New JSONobject
				aspJSONobject.Add "projectName", projectName
				aspJSONobject.Add "projectId", projectId
				aspJSONobject.Add "projectDescription", projectDescription
				aspJSONobject.Add "viaNotebook", True
				aspJSONarray.Push aspJSONobject
			End if
			lRec.moveNext
		Loop

	ElseIf experimentLinkSection = "registration" Then
		
		If revisionId = 0 Then
			strQuery = "SELECT regNumber, displayRegNumber, comments from (SELECT * FROM experimentRegLinks UNION ALL SELECT * FROM experimentRegLinks_preSave) as T WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S")
		Else
			strQuery = "SELECT regNumber, displayRegNumber, comments from experimentRegLinks_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND revisionNumber="&SQLClean(revisionId,"N","S")
		End if
		Set lRec = server.CreateObject("ADODB.RecordSet")
		lRec.open strQuery,conn
		Do While Not lRec.eof
			If lRec("regNumber") <> lRec("displayRegNumber")  Then
				thePage = regPath&"/showReg.asp"
			Else
				thePage = regPath&"/showBatch.asp"
			End if
			
			canDeleteExperimentLink = False
			If ownsExperiment(experimentType,experimentId,session("userId")) And Not isExperimentClosedByStatus(experimentStatusId) then
				canDeleteExperimentLink = True
			End if
			
			linkComment = lRec("comments")
			If Not isNull(lRec("comments")) Then
				linkComment = CStr(linkComment)
			End If

			set aspJSONobject = New JSONobject
			aspJSONobject.Add "regLinkUrl", CStr(thePage & "?regNumber=" & lRec("displayRegNumber"))
			aspJSONobject.Add "regNumber", CStr(lRec("regNumber"))
			aspJSONobject.Add "displayRegNumber", CStr(lRec("displayRegNumber"))
			aspJSONobject.Add "canDeleteExperimentLink", canDeleteExperimentLink
			aspJSONobject.Add "linkComment", linkComment
			aspJSONarray.Push aspJSONobject

			lRec.moveNext
		loop
	ElseIf experimentLinkSection = "request" Then
		
		' If revisionId = 0 Then
		' 	strQuery = "SELECT regNumber, displayRegNumber, comments from (SELECT * FROM experimentRegLinks UNION ALL SELECT * FROM experimentRegLinks_preSave) as T WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S")
		' Else
		' 	strQuery = "SELECT regNumber, displayRegNumber, comments from experimentRegLinks_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND revisionNumber="&SQLClean(revisionId,"N","S")
		' End if

		strQuery = "SELECT " &_
			"experimentId, " &_
			"experimentType, " &_
			"requestId, " &_
			"comments " &_
		"FROM experimentRequests " &_
		"WHERE experimentId=" & experimentId & " " &_
		"AND experimentType=" & experimentType

		Set lRec = server.CreateObject("ADODB.RecordSet")
		lRec.open strQuery,conn
		Do While Not lRec.eof
			reqPage = "/arxlab/workflow/viewIndividualRequest.asp?requestId=" & cstr(lRec("requestId"))
			
			canDeleteExperimentLink = False
			If ownsExperiment(experimentType,experimentId,session("userId")) And Not isExperimentClosedByStatus(experimentStatusId) then
				canDeleteExperimentLink = True
			End if
			
			linkComment = lRec("comments")
			If Not isNull(lRec("comments")) Then
				linkComment = CStr(linkComment)
			End If

			set aspJSONobject = New JSONobject
			aspJSONobject.Add "reqLinkUrl", CStr(reqPage)
			aspJSONobject.Add "requestId", cstr(lRec("requestId"))
			aspJSONobject.Add "canDeleteExperimentLink", canDeleteExperimentLink
			aspJSONobject.Add "linkComment", linkComment
			aspJSONarray.Push aspJSONobject

			lRec.moveNext
		loop
	End If

	Call aspJSONarray.Write()
	call disconnect
end if
%>