<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<%
Function copyChemistryData(fromUserId, toUserId, fromExperimentId, toExperimentId, revisionNumber, oldRevisionNumber, forceChemistryProcessing)
	' We need to copy the chemData images from the old revision into the new revision's folder
	copyFromPath = uploadRoot&"\"&CStr(fromUserId)&"\"&CStr(fromExperimentId)&"\"&oldRevisionNumber&"\chem\chemData"
	recursiveDirectoryCreate uploadRoot,CStr(toUserId)&"\"&CStr(toExperimentId)&"\"&revisionNumber&"\chem\chemData\"

	copiedFiles = False
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	If fs.FolderExists(copyFromPath) = True Then
		Set folder = fs.getFolder(copyFromPath)
		If folder.files.Count > 0 Then
			fs.CopyFile uploadRoot&"\"&CStr(fromUserId)&"\"&CStr(fromExperimentId)&"\"&oldRevisionNumber&"\chem\chemData\*",uploadRoot&"\"&CStr(toUserId)&"\"&CStr(toExperimentId)&"\"&CStr(revisionNumber)&"\chem\chemData\"
			copiedFiles = True
		End If
	End If
	
	'ELN-1331 checking for forceChemistryProcessing
	If  (forceChemistryProcessing = "1")  Or session("hasCompoundTracking") Or (Not copiedFiles) Then
		cdxml = ""
		mrvData = ""
		Call getconnected
		
		Set jRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cdx, mrvData FROM experiments_history WHERE experimentId="&SQLClean(fromExperimentId,"N","S")&" AND revisionNumber="&SQLClean(oldRevisionNumber,"N","S")
		jRec.open strQuery,conn,3,3
		If Not jRec.eof Then
			cdxml = jRec("cdx")
			mrvData = jRec("mrvData")
		End if
		jRec.Close
		Set jRec = Nothing
		
		If cdxml <> "" And mrvData = "" Then
			'insert into experiment loading so we can determine when Python is done processing
			Call getconnectedadm
			strQuery = "INSERT into experimentLoading(experimentId,dateSubmitted,cleared) values("&SQLClean(toExperimentId,"N","S")&",GETDATE(),0)"
			connAdm.execute(strQuery)
	
			'add to dispatch.py queue to process chemistry again and hopefully get images this time.
			newFlag = ""
			If fromExperimentId = toExperimentId Then
				newFlag = "notnew"
			Else
				newFlag = "newCopy"
			End If
			set tfile=fs.CreateTextFile("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(session("toUserId"))&"_"&CStr(toUserId)&"_"&CStr(toExperimentId)&"_"&CStr(revisionNumber)&"_"&Abs(session("hasCompoundTracking"))&"_"&newFlag&"_rxn.rxn",false,true)
			tfile.WriteLine(Replace(Replace(Replace(cdxml,"\""",""""),"HeightPages=""1""","HeightPages=""5"""),"WidthPages=""1""","WidthPages=""5"""))
			tfile.close
			set tfile=nothing

			'wait up to 100 seconds for the processing to complete
			counter = 0
			Do While True And counter < 100
				counter = counter + 1
				sleep = 1
				strQuery = "WAITFOR DELAY '00:00:" & right(clng(sleep),2) & "'" 
				connAdm.Execute strQuery,,129 
				Set bRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT id FROM experimentLoading WHERE experimentId="&SQLClean(toExperimentId,"N","S")
				bRec.open strQuery,connAdm,3,3
				If bRec.eof Then
					'break
					counter = 10000
				End If
				bRec.close
				Set bRec = nothing
			Loop
			Call disconnectadm
		End If
	End If
	set fs=nothing
	
End function
%>