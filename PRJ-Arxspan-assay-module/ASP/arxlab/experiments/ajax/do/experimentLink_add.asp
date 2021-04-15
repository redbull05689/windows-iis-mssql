<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%

Response.CodePage = 65001
Response.CharSet = "UTF-8"

' This file is used to create new experiment links - started 2.17.17
thisExperimentId = request.Form("thisExperimentId")
thisExperimentType = request.Form("thisExperimentType")
thisRevisionNumber = request.Form("thisRevisionNumber")
linkedExperimentId = request.Form("linkedExperimentId")
linkedExperimentType = request.Form("linkedExperimentType")
linkedProjectId = request.Form("linkedProjectId")
linkedRegistrationId = request.Form("linkedRegistrationId")
linkToType = request.Form("linkToType")
linkAs = request.Form("linkAs")
linkComment = request.Form("linkComment")
biDirectionalLink = request.Form("biDirectionalLink")

Call getconnectedadm

If canViewExperiment(thisExperimentType,thisExperimentId,session("userId")) Then
	If linkToType = "experiment" Then
		If Not (thisExperimentType=linkedExperimentType and thisExperimentId=linkedExperimentId) Then
			' We need to get the latest revisionId for the linked experiment - wish there was a shorter way to do this...
			prefix = GetPrefix(thisExperimentType)
			historyTableView = GetFullName(prefix, "experimentHistoryView", true)
			Set thisExpHistoryRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT TOP 1 "&historyTableView&".revisionNumber, "&historyTableView&".statusId" &_
				" from "&_ 
				historyTableView&" WHERE experimentId="&SQLClean(thisExperimentId,"N","S")& " ORDER BY revisionNumber DESC"
			thisExpHistoryRec.open strQuery,conn,0,-1

			prefix = GetPrefix(CStr(linkedExperimentType))
			linkedExperimentTable = GetFullName(prefix, "experiments", true)
			historyTableView = GetFullName(prefix, "experimentHistoryView", true)
			Set linkedExpHistoryRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT TOP 1 "&historyTableView&".revisionNumber, "&historyTableView&".statusId" &_
				" from "&_ 
				historyTableView&" WHERE experimentId="&SQLClean(linkedExperimentId,"N","S")& " ORDER BY revisionNumber DESC"
			linkedExpHistoryRec.open strQuery,conn,0,-1

			' Figure out some nice way to incorporate next/prev/reference linking differences... maybe move prev/next to be the last value set, then do some if/thens? or define variables as blank by default
			newToOld_prevNextColumnName = ""
			newToOld_prevNextColumnValue = ""
			oldToNew_prevNextColumnName = ""
			oldToNew_prevNextColumnValue = ""
			if linkAs = "previousStep" then
				newToOld_prevNextColumnName = ",prev"
				newToOld_prevNextColumnValue = ",1"
				oldToNew_prevNextColumnName = ",next"
				oldToNew_prevNextColumnValue = ",1"
			elseif linkAs = "nextStep" then
				newToOld_prevNextColumnName = ",next"
				newToOld_prevNextColumnValue = ",1"
				oldToNew_prevNextColumnName = ",prev"
				oldToNew_prevNextColumnValue = ",1"
			end if

			Set nlRec2 = server.CreateObject("ADODB.recordset")
			strQuery = "SELECT * FROM (SELECT * FROM experimentLinks UNION ALL SELECT * FROM experimentLinks_preSave) as T WHERE experimentType="&SQLClean(thisExperimentType,"N","S")&" AND experimentId="&SQLClean(thisExperimentId,"N","S")&" AND linkExperimentType="&SQLClean(linkedExperimentType,"N","S")&" AND linkExperimentId="&SQLClean(linkedExperimentId,"N","S")
			nlRec2.open strQuery,connAdm

			' If the link does not already exist, add it
			If nlRec2.eof then
				Set nlRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT TOP 1 id, userId FROM " & linkedExperimentTable & " WHERE id="&SQLClean(linkedExperimentId,"N","S")
				nlRec.open strQuery,connAdm,3,3
				' Make sure the user owns the experiment that is being linked to
				If Not nlRec.eof Then
					Do While Not nlRec.eof
						'This was originally a check to make sure the user owns the experiment, but now we just want to make sure the user has permission to see the experiment
						'If nlRec("userId") = session("userId") Or (linkAs = "referenceLink" and biDirectionalLink <> "true") Then
						If canViewExperiment(linkedExperimentType,linkedExperimentId,session("userId")) Then
							responseString = "Success"

							if not IsNull(linkComment) then
								linkComment = Server.HTMLEncode(linkComment)
							end if

							' Link the searched experiment to the viewed experiment 
							'strQuery = "INSERT into experimentLinks_preSave(experimentType,experimentId,linkExperimentType,linkExperimentId,comments" & newToOld_prevNextColumnName & ") values("&_
							'SQLClean(thisExperimentType,"N","S") & "," &_
							'SQLClean(thisExperimentId,"N","S") & "," &_
							'SQLClean(linkedExperimentType,"N","S") & "," &_
							'SQLClean(linkedExperimentId,"N","S") & "," &_
							'SQLClean(linkComment,"T","S") &_
							'newToOld_prevNextColumnValue & ")"
							'connAdm.execute(strQuery)
							
							strQuery = "INSERT into experimentLinks(experimentType,experimentId,linkExperimentType,linkExperimentId,comments" & newToOld_prevNextColumnName & ") values(" &_
							SQLClean(thisExperimentType,"N","S") & "," &_
							SQLClean(thisExperimentId,"N","S") & "," &_
							SQLClean(linkedExperimentType,"N","S") & "," &_
							SQLClean(linkedExperimentId,"N","S") & "," &_
							SQLClean(linkComment,"T","S") &_
							newToOld_prevNextColumnValue & ")"
							connAdm.execute(strQuery)
							
							strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,comments,revisionNumber,dateAdded" & newToOld_prevNextColumnName & ") values(" &_
							SQLClean(thisExperimentType,"N","S") & "," &_
							SQLClean(thisExperimentId,"N","S") & "," &_
							SQLClean(linkedExperimentType,"N","S") & "," &_
							SQLClean(linkedExperimentId,"N","S") & "," &_
							SQLClean(linkComment,"T","S") & "," &_
							SQLClean(thisExpHistoryRec("revisionNumber"),"N","S") & "," &_
							"GETDATE()" &_
							newToOld_prevNextColumnValue & ")"
							connAdm.execute(strQuery)

							' if the experiment is currently witnessed (statusId == 6), then we need to add the link to the previous revisionId as well
							If thisExpHistoryRec("statusId") = 6 And thisExpHistoryRec("revisionNumber") > 1 Then
								strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,comments,revisionNumber,dateAdded" & newToOld_prevNextColumnName & ") values(" &_
								SQLClean(thisExperimentType,"N","S") & "," &_
								SQLClean(thisExperimentId,"N","S") & "," &_
								SQLClean(linkedExperimentType,"N","S") & "," &_
								SQLClean(linkedExperimentId,"N","S") & "," &_
								SQLClean(linkComment,"T","S") & "," &_
								SQLClean(thisExpHistoryRec("revisionNumber") - 1,"N","S") & "," &_
								"GETDATE()" &_
								newToOld_prevNextColumnValue & ")"
								connAdm.execute(strQuery)
							End If


							' Link the viewed experiment to the searched experiment
							if linkAs <> "referenceLink" or (linkAs = "referenceLink" and biDirectionalLink = "true") then
								'strQuery = "INSERT into experimentLinks_preSave(experimentType,experimentId,linkExperimentType,linkExperimentId,comments" & oldToNew_prevNextColumnName & ") values("&_
								'SQLClean(linkedExperimentType,"N","S") & "," &_
								'SQLClean(linkedExperimentId,"N","S") & "," &_
								'SQLClean(thisExperimentType,"N","S") & "," &_
								'SQLClean(thisExperimentId,"N","S") & "," &_
								'SQLClean(linkComment,"T","S") &_
								'oldToNew_prevNextColumnValue & ")"
								'connAdm.execute(strQuery)

								strQuery = "INSERT into experimentLinks(experimentType,experimentId,linkExperimentType,linkExperimentId,comments" & oldToNew_prevNextColumnName & ") values(" &_
								SQLClean(linkedExperimentType,"N","S") & "," &_
								SQLClean(linkedExperimentId,"N","S") & "," &_
								SQLClean(thisExperimentType,"N","S") & "," &_
								SQLClean(thisExperimentId,"N","S") & "," &_
								SQLClean(linkComment,"T","S") &_
								oldToNew_prevNextColumnValue & ")"
								connAdm.execute(strQuery)
								
								strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,comments,revisionNumber,dateAdded" & oldToNew_prevNextColumnName & ") values(" &_
								SQLClean(linkedExperimentType,"N","S") & "," &_
								SQLClean(linkedExperimentId,"N","S") & "," &_
								SQLClean(thisExperimentType,"N","S") & "," &_
								SQLClean(thisExperimentId,"N","S") & "," &_
								SQLClean(linkComment,"T","S") & "," &_
								SQLClean(linkedExpHistoryRec("revisionNumber"),"N","S") & "," &_
								"GETDATE()" &_
								oldToNew_prevNextColumnValue & ")"
								connAdm.execute(strQuery)

								' if the experiment is currently witnessed (statusId == 6), then we need to add the link to the previous revisionId as well
								If linkedExpHistoryRec("statusId") = 6 And linkedExpHistoryRec("revisionNumber") > 1 Then
									strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,comments,revisionNumber,dateAdded" & oldToNew_prevNextColumnName & ") values(" &_
									SQLClean(linkedExperimentType,"N","S") & "," &_
									SQLClean(linkedExperimentId,"N","S") & "," &_
									SQLClean(thisExperimentType,"N","S") & "," &_
									SQLClean(thisExperimentId,"N","S") & "," &_
									SQLClean(linkComment,"T","S") & "," &_
									SQLClean(linkedExpHistoryRec("revisionNumber") - 1,"N","S") & "," &_
									"GETDATE()" &_
									oldToNew_prevNextColumnValue & ")"
									connAdm.execute(strQuery)
								End If
							end if
						Else
							responseString = "You do not own the experiment that you are linking to."
						End If

						nlRec.moveNext
					Loop
				Else
					responseString = "Experiment not found."
				End If
				nlRec.close
				Set nlRec = nothing
			Else
				responseString = "Experiment is already linked."
			End If

			nlRec2.close
			Set nlRec2 = nothing
		Else
			responseString = "You can not link an experiment to itself."
		End If

		response.write responseString

	ElseIf linkToType = "project" Then
		'add a project link to an experiment
		errorText = ""

		If linkedProjectId <> "x" Then
			'get permissions flags
			ownsExp = ownsExperiment(thisExperimentType,thisExperimentId,session("userId"))
			experimentVisible = isExperimentVisible(thisExperimentType,thisExperimentId)
			canWrite = canWriteProject(linkedProjectId,session("userId"))

			If (ownsExp And experimentVisible) or session("role")="Super Admin" or session("role")="Admin" Then
				errorText = addExperimentToProject(connAdm, thisExperimentType, thisExperimentId, linkedProjectId, null, linkComment)
				If errorText = "" Then
					responseString = "Success"
				Else 
					responseString = errorText
				End If 
			Else
				'return no permission error
				responseString = "An error occurred adding link to project."
			End If
		Else
			responseString = "You can not link to a project with sub-projects."
		End If

		response.write responseString

	ElseIf linkToType = "registration" Then
		'registration item link
		If linkedRegistrationId <> "" Then
			'get reg number for display
			regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
			Call getconnectedJchemReg
			Set tRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT reg_id FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(linkedRegistrationId,"N","S")
			tRec.open strQuery,jchemRegConn,3,3
			If not tRec.eof then
				wholeRegNumber = tRec("reg_id")
				x = Split(wholeRegNumber,"-")
				lastNums = x(UBound(x))
				If Replace(lastNums,"0","") = "" Then
					displayRegNumber = left(wholeRegNumber,Len(wholeRegNumber)-Len(lastNums)-1)
				Else
					displayRegNumber = wholeRegNumber
				End if
				tRec.close
				Set tRec = nothing

				foundLink = False
				'check regular table for link already existing
				Set tRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT experimentId from experimentRegLinks WHERE experimentId="&SQLClean(thisExperimentId,"N","S")&" AND experimentType="&SQLClean(thisExperimentType,"N","S")&" AND regNumber="&SQLClean(wholeRegNumber,"T","S")
				tRec.open strQuery,conn,3,3
				If Not tRec.eof Then
					foundLink = true
				End if
				tRec.close
				Set tRec = Nothing

				if not IsNull(linkComment) then
					linkComment = Server.HTMLEncode(linkComment)
				end if

				'if the link does not already exist create it
				If Not foundLink Then
					strQuery = "INSERT into experimentRegLinks(experimentId,experimentType,regNumber,displayRegNumber,comments) values("&_
								SQLClean(thisExperimentId,"N","S") & "," &_
								SQLClean(thisExperimentType,"N","S") & "," &_
								SQLClean(wholeRegNumber,"T","S") & "," &_
								SQLClean(displayRegNumber,"T","S") & "," &_
								SQLClean(linkComment,"T","S") & ")"
					connAdm.execute(strQuery)
					responseString = "Success"
				Else
					responseString = "Registration ID """&SQLClean(linkedRegistrationId,"N","S")&""" is already linked to this Experiment."							
				End if
			Else
				responseString = "Registration ID """ & SQLClean(linkedRegistrationId, "N", "S") & """ not found."
			End If
			Call disconnectJchemReg
		Else
			responseString = "You have not chosen a Registration ID"
		End If

		response.write responseString

	End If
Else
	responseString = "An error occurred adding link to Experiment"
End If

Call disconnectadm

%>