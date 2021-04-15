<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
'edit a draft experiment
'for now this is just going to remove a row
'the input will be the row that needs to be removed
Response.CodePage = 65001
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
canWrite = request.querystring("c") 'The c is for co-author


Call getconnectedadm

If ownsExperiment(experimentType,experimentId,session("userId")) or canWrite then
	Set rec = server.CreateObject("ADODB.RecordSet")
	'query the database to get the draft
	strQuery = "SELECT experimentJSON from experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	rec.open strQuery,connAdm,3,3
	If Not rec.eof Then

		Set theRow = request.Form("theRow") 'this line gets the row to be removed 
		Set theTable = request.Form("theTable") 'get the table id 
		'load experimentJSON (draft object)
		Set experimentJSON = JSON.parse(rec("experimentJSON"))
		unsavedChangesFlag = 0
		'loop through each item in array
			
		For Each key In experimentJSON.keys()
			KeyValues = Split(key, "_")	
			If IsArray(KeyValues) Then
				Count = UBound(KeyValues)
				If Count = 2 Then
					If KeyValues(0) = theTable then
						If KeyValues(1) = cstr(theRow) Then
							If experimentJSON.Exists(key) = true then
							experimentJSON.purge(cstr(key))
							End If
						End If
					End If
				End If
			Else
			End If
		Next

		''insert draft object and unsavedChanges flag back into the db
		strQuery = "UPDATE experimentDrafts SET unsavedChanges="&SQLClean(unsavedChangesFlag,"N","S")&",experimentJSON="&SQLClean(JSON.stringify(experimentJSON),"T","S")&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
		connAdm.execute(strQuery)
	End if
	response.write("Draft Edited!")
End If

Call disconnectadm()


%>