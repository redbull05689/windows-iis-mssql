<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
'add a link to an experiment
'linkTypes
'1 - chemistry experiment
'2 - bio experiment
'3 - concept experiment
'5 - analysis experiment
'6 - registration item
Call getconnectedadm
success = False
'only allow explicitly allowed types
If session("linkType") = "1" Or session("linkType") = "2" Or session("linkType") = "3" Or session("linkType") = "5" Or session("linkType")="6" Then
	linkType = session("linkType")
	'convert link type to be the same as experiment type for all experiments
	If linkType="5" Then
		linkType="4"
	End if
	If not (session("linkId") = "") Then
		'do not allow link to self
		If Not (CStr(request.Form("lExperimentId")) = CStr(session("linkId")) And CStr(request.Form("lExperimentType")) = CStr(session("linkType"))) then
			Select Case request.Form("lExperimentType")
				'chemistry link
				Case "1"
					Set nlRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT id FROM experiments WHERE userId="&SQLClean(session("userId"),"N","S") & " AND id=" & SQLClean(request.Form("lExperimentId"),"N","S")
					nlRec.open strQuery,connAdm,3,3
					'make sure user owns the experiment that is being linked to
					If Not nlRec.eof Then
						Set nlRec2 = server.CreateObject("ADODB.recordset")
						strQuery = "SELECT * FROM (SELECT * FROM experimentLinks UNION ALL SELECT * FROM experimentLinks_preSave) as T WHERE experimentType=1 AND experimentId="&SQLClean(request.Form("lExperimentId"),"N","S")& " AND linkExperimentType="&SQLClean(linkType,"N","S") & " AND linkExperimentId=" & SQLClean(session("linkId"),"N","S")
						nlRec2.open strQuery,connAdm
						'if the link does not already exist, add it
						If nlRec2.eof then
							strQuery = "INSERT into experimentLinks_preSave(experimentType,experimentId,linkExperimentType,linkExperimentId) values("&_
									SQLClean("1","N","S") & "," &_
									SQLClean(request.Form("lExperimentId"),"N","S") & "," &_
									SQLClean(linkType,"N","S") & "," &_
									SQLClean(session("linkId"),"N","S") & ")"
							connAdm.execute(strQuery)
							success = true
						Else
							errorStr = "Experiment is already linked."
						End If
						nlRec2.close
						Set nlRec2 = nothing
					Else
						errorStr = "You are not authorized to add links to this experiment."
					End If
					nlRec.close
					Set nlRec = nothing
				Case "2"
					If session("linkType") = "6" Then
						'registration link

						'get reg number for display
						Call getconnectedJchemReg
						Set tRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT reg_id FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(session("linkId"),"N","S")
						tRec.open strQuery,jchemRegConn,3,3
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

						'check if item is already linked in presave
						experimentType = request.Form("lExperimentType")
						experimentId = request.Form("lExperimentId")
						foundLink = false
						Set tRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT experimentId from experimentRegLinks_preSave WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")&" AND regNumber="&SQLClean(wholeRegNumber,"T","S")
						tRec.open strQuery,conn,3,3
						If Not tRec.eof Then
							foundLink = true
						End if
						tRec.close
						Set tRec = Nothing

						'check if item is already linked
						Set tRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT experimentId from experimentRegLinks WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")&" AND regNumber="&SQLClean(wholeRegNumber,"T","S")
						tRec.open strQuery,conn,3,3
						If Not tRec.eof Then
							foundLink = true
						End if
						tRec.close
						Set tRec = Nothing

						'if not already linked insert link into experiment
						If Not foundLink Then
							strQuery = "INSERT into experimentRegLinks_preSave(experimentId,experimentType,regNumber,displayRegNumber) values("&_
										SQLClean(experimentId,"N","S") & "," &_
										SQLClean(experimentType,"N","S") & "," &_
										SQLClean(wholeRegNumber,"T","S") & "," &_
										SQLClean(displayRegNumber,"T","S") & ")"
							connAdm.execute(strQuery)
							success = true
						Else
							errorStr = "Registration item already exists."							
						End if

						Call disconnectJchemReg
					else
						Set nlRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT id FROM bioExperiments WHERE userId="&SQLClean(session("userId"),"N","S") & " AND id=" & SQLClean(request.Form("lExperimentId"),"N","S")
						nlRec.open strQuery,connAdm,3,3
						'make sure user owns experiment to be linked to
						If Not nlRec.eof Then
							Set nlRec2 = server.CreateObject("ADODB.recordset")
							strQuery = "SELECT * FROM (SELECT * FROM experimentLinks UNION ALL SELECT * FROM experimentLinks_preSave) as T WHERE experimentType=2 AND experimentId="&SQLClean(request.Form("lExperimentId"),"N","S")& " AND linkExperimentType="&SQLClean(linkType,"N","S") & " AND linkExperimentId=" & SQLClean(session("linkId"),"N","S")
							nlRec2.open strQuery,connAdm
							'if the link does not already exist, add it
							If nlRec2.eof then
								strQuery = "INSERT into experimentLinks_preSave(experimentType,experimentId,linkExperimentType,linkExperimentId) values("&_
										SQLClean("2","N","S") & "," &_
										SQLClean(request.Form("lExperimentId"),"N","S") & "," &_
										SQLClean(linkType,"N","S") & "," &_
										SQLClean(session("linkId"),"N","S") & ")"
								connAdm.execute(strQuery)
								success = true
							Else
								errorStr = "Experiment is already linked."
							End If
							nlRec2.close
							Set nlRec2 = nothing
						Else
							errorStr = "You are not authorized to add links to this experiment."
						End If
						nlRec.close
						Set nlRec = Nothing
					End if
				Case "3"
					Set nlRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT id FROM freeExperiments WHERE userId="&SQLClean(session("userId"),"N","S") & " AND id=" & SQLClean(request.Form("lExperimentId"),"N","S")
					nlRec.open strQuery,connAdm,3,3
					'make sure user owns experiment to be linked to
					If Not nlRec.eof Then
						Set nlRec2 = server.CreateObject("ADODB.recordset")
						strQuery = "SELECT * FROM (SELECT * FROM experimentLinks UNION ALL SELECT * FROM experimentLinks_preSave) as T WHERE experimentType=3 AND experimentId="&SQLClean(request.Form("lExperimentId"),"N","S")& " AND linkExperimentType="&SQLClean(linkType,"N","S") & " AND linkExperimentId=" & SQLClean(session("linkId"),"N","S")
						nlRec2.open strQuery,connAdm
						'if the link does not already exist, add it
						If nlRec2.eof then
							strQuery = "INSERT into experimentLinks_preSave(experimentType,experimentId,linkExperimentType,linkExperimentId) values("&_
									SQLClean("3","N","S") & "," &_
									SQLClean(request.Form("lExperimentId"),"N","S") & "," &_
									SQLClean(linkType,"N","S") & "," &_
									SQLClean(session("linkId"),"N","S") & ")"
							connAdm.execute(strQuery)
							success = true
						Else
							errorStr = "Experiment is already linked."
						End If
						nlRec2.close
						Set nlRec2 = nothing
					Else
						errorStr = "You are not authorized to add links to this experiment."
					End If
					nlRec.close
					Set nlRec = nothing
				Case "4"
					'412015
					If session("linkType") = "6" Then
						'registration item link

						'get reg number for display
						Call getconnectedJchemReg
						Set tRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT reg_id FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(session("linkId"),"N","S")
						tRec.open strQuery,jchemRegConn,3,3
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

						experimentType = request.Form("lExperimentType")
						experimentId = request.Form("lExperimentId")
						foundLink = False
						'check presave table for link already existing
						Set tRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT experimentId from experimentRegLinks_preSave WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")&" AND regNumber="&SQLClean(wholeRegNumber,"T","S")
						tRec.open strQuery,conn,3,3
						If Not tRec.eof Then
							foundLink = true
						End if
						tRec.close
						Set tRec = Nothing
						
						'check regular table for link already existing
						Set tRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT experimentId from experimentRegLinks WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")&" AND regNumber="&SQLClean(wholeRegNumber,"T","S")
						tRec.open strQuery,conn,3,3
						If Not tRec.eof Then
							foundLink = true
						End if
						tRec.close
						Set tRec = Nothing

						'if the link does not already exist create it
						If Not foundLink Then
							strQuery = "INSERT into experimentRegLinks_preSave(experimentId,experimentType,regNumber,displayRegNumber) values("&_
										SQLClean(experimentId,"N","S") & "," &_
										SQLClean(experimentType,"N","S") & "," &_
										SQLClean(wholeRegNumber,"T","S") & "," &_
										SQLClean(displayRegNumber,"T","S") & ")"
							connAdm.execute(strQuery)
							success = true
						Else
							errorStr = "Registration item already exists."							
						End if

						Call disconnectJchemReg
					else
						Set nlRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT id FROM analExperiments WHERE userId="&SQLClean(session("userId"),"N","S") & " AND id=" & SQLClean(request.Form("lExperimentId"),"N","S")
						nlRec.open strQuery,connAdm,3,3
						'make sure user owns the experiment
						If Not nlRec.eof Then
							Set nlRec2 = server.CreateObject("ADODB.recordset")
							strQuery = "SELECT * FROM (SELECT * FROM experimentLinks UNION ALL SELECT * FROM experimentLinks_preSave) as T WHERE experimentType=4 AND experimentId="&SQLClean(request.Form("lExperimentId"),"N","S")& " AND linkExperimentType="&SQLClean(linkType,"N","S") & " AND linkExperimentId=" & SQLClean(session("linkId"),"N","S")
							nlRec2.open strQuery,connAdm
							'if the link does not already exist, add it
							If nlRec2.eof then
								strQuery = "INSERT into experimentLinks_preSave(experimentType,experimentId,linkExperimentType,linkExperimentId) values("&_
										SQLClean("4","N","S") & "," &_
										SQLClean(request.Form("lExperimentId"),"N","S") & "," &_
										SQLClean(linkType,"N","S") & "," &_
										SQLClean(session("linkId"),"N","S") & ")"
								connAdm.execute(strQuery)
								success = true
							Else
								errorStr = "Experiment is already linked."
							End If
							nlRec2.close
							Set nlRec2 = nothing
						Else
							errorStr = "You are not authorized to add links to this experiment."
						End If
						nlRec.close
						Set nlRec = Nothing
					End If
					'//412015
			End select
		Else
			errorStr = "You may not link an experiment to itself."
		End if
	Else
		errorStr = "No experiments in clipboard."
	End if
Else
	errorStr = "That type cannot be linked here."
End if
'response.write(errorStr)
%>
<%If success = true then%>
<div id="resultsDiv">success</div>
<%else%>
<div id="resultsDiv"><%=errorStr%></div>
<%End if%>