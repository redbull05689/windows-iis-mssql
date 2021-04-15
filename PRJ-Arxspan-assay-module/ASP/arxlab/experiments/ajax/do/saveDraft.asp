<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/security/functions/fnc_checkCoAuthors.asp"-->
<%
'save a draft of the experiment
'draft items come in a JSON object like this {thePairs:[{theKey:'',theVal:''},...]}
'where theKey and theVal are individual form values
Response.CodePage = 65001
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
canWrite = request.querystring("c") 'The c is for co-author

If experimentType = 5 Then
	canWrite = checkCoAuthors(experimentId, experimentType, "saveDraft")
End If
 
Call getconnectedadm

If ownsExperiment(experimentType,experimentId,session("userId")) or canWrite then
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT experimentJSON from experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	rec.open strQuery,connAdm,3,3
	If Not rec.eof Then
		Set thePairs = JSON.parse(join(array(request.Form("thePairs"))))
		'load experimentJSON (draft object)
		Set experimentJSON = JSON.parse(rec("experimentJSON"))
		unsavedChangesFlag = 0
		'loop through each item in array
		For Each key In thePairs.keys()
			'update the draft object with each item in array
			experimentJSON.Set thePairs.Get(key).Get("theKey"),thePairs.Get(key).Get("theVal")
			If InStr(thePairs.Get(key).Get("theKey"),"sortOrder")=0 Then
				'set unsavedChanges flag for everything except sort order
				unsavedChangesFlag = 1
			End if
		Next

		'Not sure why, but need to make sure we update the userID
		experimentJSON.Set "userId", session("userId")

		'insert draft object and unsavedChanges flag back into the db
		strQuery = "UPDATE experimentDrafts SET unsavedChanges="&SQLClean(unsavedChangesFlag,"N","S")&",experimentJSON="&SQLClean(JSON.stringify(experimentJSON),"T","S")&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
		connAdm.execute(strQuery)
	End if
	response.write("Draft saved!!")
End If

Call disconnectadm()




%>