<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
draftHasUnsavedChanges = False
isDraft = false
If ownsExp Then
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT experimentJSON, unsavedChanges FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof then
		isDraft = True
		expJsonRec = rec("experimentJSON")
		if expJsonRec = "" then
			expJsonRec = "{}"
		end if
		Set experimentJSON = JSON.parse(expJsonRec)
		If experimentJSON.exists("molUpdate") Then
			If experimentJSON.Get("molUpdate") = "1" Then
				prefixes = Split("r,rg,p,s",",")
				For i = 0 To UBound(prefixes)
					prefix = prefixes(i)
					For j = 30 To 2 Step -1
						thisPrefix = ""
						nextPrefix = ""
						If experimentJSON.exists(prefix&j&"_trivialName") And not experimentJSON.exists(prefix&(j-1)&"_trivialName") Then
							thisPrefix = prefix&(j-1)&"_"
							nextPrefix = prefix&(j)&"_"
						End if
						If thisPrefix <> "" Then
							For Each key In experimentJSON.keys()
								If Mid(key,1,Len(nextPrefix))=nextPrefix Then
									experimentJSON.Set Replace(key,nextPrefix,thisPrefix), experimentJSON.Get(key)
									experimentJSON.purge(key)
								End if
							next
						End if
					Next
				next
				experimentJSON.Set "molUpdate","0"
				Call getconnectedadm
				strQuery = "UPDATE experimentDrafts SET experimentJSON="&SQLClean(JSON.stringify(experimentJSON),"T","S")&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
				connAdm.execute(strQuery)
			End If
		End if
		If rec("unsavedChanges") = 1 Then
			draftHasUnsavedChanges = true
		End if
	Else
		Set experimentJSON = JSON.parse("{}")
	End if
End if

Function draftSet(theKey,theVal)
	theValue = theVal
	If Not ownsExp Then
		draftSet = theValue
	Else
		If isDraft Then
			If experimentJSON.exists(theKey) then
				draftSet = experimentJSON.Get(theKey)
			Else
				experimentJSON.Set theKey, theValue
				draftSet = theValue
			End if
		Else
			experimentJSON.Set theKey, theValue
			draftSet = theValue
		End if
	End if
End Function
%>