<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/experiments/common/functions/fnc_requestWitness.asp"-->
<%
'send a witness request
experimentType = request.Form("experimentType")
experimentId = request.Form("experimentId")
requesteeId = request.Form("requesteeId")
revisionNumber = request.Form("revisionNumber")

'can only send witness request if you own the experiment
If ownsExperiment(experimentType,experimentId,session("userId")) Then

	' Making sure that all signers have approved the experiment before sending the notification.
	if experimentType <> "5" or checkIfAllSigned(experimentId, experimentType, revisionNumber) then
		title = "Witness Request"
		Call getconnectedadm
		Call getconnected
		Set rec = server.CreateObject("ADODB.RecordSet")
		'create and send notification by experiment type
		prefix = GetPrefix(experimentType)
		tableName = GetFullName(prefix, "experiments", true)
		page = GetExperimentPage(prefix)
		strQuery = "SELECT name FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			experimentName = rec("name")
		End if
		note = "The user "&session("firstName") & " " & session("lastName") & " has requested that you witness <a href="""&mainAppPath&"/"& page &"?id="&experimentId&""">"&experimentName&"</a>"

		a = sendNotification(requesteeId,title,note,7)
	end if

	' call function to insert witness request into database. This happens regardless of whether or not
	' the notification is sent.
	errorStr = requestWitness(experimentType,experimentId,requesteeId)
Else
	errorStr = "Not authorized"
End if
If errorStr = "" Then
	response.write("{}")
Else
	response.write("<div id=""resultsDiv"">"&errorStr&"</div>")
End if
response.end()
%>
