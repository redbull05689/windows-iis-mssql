<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%witnessArea = true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<%

Response.CodePage = 65001
Response.CharSet = "UTF-8"

'form handler for the popup form labeled reject. purpose is to reject the witness of an experiment.
'when this happens the experiment is reopened with a message for the reason why the witnessing was rejected
'this page can also be accessed by the reopen button if the user has permission to reopen experiments

Function DecodeUTF8(s)
  Set stmANSI = Server.CreateObject("ADODB.Stream")
  s = s & ""
  On Error Resume Next

  With stmANSI
    .Open
    .Position = 0
    .CharSet = "Windows-1252"
    .WriteText s
    .Position = 0
    .CharSet = "UTF-8"
  End With

  DecodeUTF8 = stmANSI.ReadText
  stmANSI.Close

  If Err.number <> 0 Then
    lib.logger.error "str.DecodeUTF8( " & s & " ): " & Err.Description
    DecodeUTF8 = s
  End If
  On error Goto 0
End Function

'get form data
experimentType = request.Form("experimentType")
experimentId = request.Form("experimentId")
requestId = request.Form("requestId")
reason = Server.HTMLEncode(request.Form("reason"))
abandonExperiment = request.Form("abandonExperiment")

Call getconnectedadm
'make sure the rejecting user has a valid witness request
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT requesteeFirstName, requesteeLastName from witnessRequestsView WHERE id="&SQLClean(requestId,"N","S") & " AND requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S") & " AND experimentTypeId="&SQLClean(experimentType,"N","S") & " AND accepted=0 and denied=0"
rec.open strQuery,connAdm,3,3
If Not rec.eof Or request.querystring("reopen") = "true" Then
	If Not rec.eof then
		requesteeFirstName = rec("requesteeFirstName")
		requesteeLastName = rec("requesteeLastName")
	end if

	'delete witness request
	strQuery = "DELETE FROM witnessRequests WHERE id="&SQLClean(requestId,"N","S")
	connAdm.execute(strQuery)
	
	'generate experiment query, log reopen/reject and select the experiment view page
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "experiments", true)
	strQuery = "SELECT name, userId FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S")
	page = GetExperimentPage(prefix)
	Select Case experimentType
		Case "1"
			logActionId = 2
		Case "2"
			logActionId = 3
		Case "3"
			logActionId = 4
		Case "4"
			logActionId = 3
		Case "5"
			logActionId = 3
	End Select
	
	a = logAction(logActionId,experimentId,"",9)

	'get data for reject/reopen notification to the experiment owner
	Set eRec = server.CreateObject("ADODB.RecordSet")
	eRec.open strQuery,connAdm,3,3
	If Not eRec.eof Then
		name = eRec("name")
		userId = eRec("userId")
	End If
	'build experiment link for notification
	hrefStr = mainAppPath & "/" & page & "?id=" &experimentId
	
	revNum = getExperimentRevisionNumber(experimentType,experimentId)

	authors = getCoAuthors(experimentId, experimentType, revNum)
	authorList = split(authors, ",")

	' replace any user entered < and > symbols so that browsers won't try to render any links
	reason = Replace(reason,"<","&lt; ")
	reason = Replace(reason,">"," &gt;")

	If request.querystring("reopen") <> "true" Then
		'reqular rejection by a user with a witness request
		'build notification
		If abandonExperiment = "true" Then
			title = "Not Pursued Request Rejection"
			' Create our reason message, including a link to the experiment
			reasonFixedForCKEditor = "The user " & requesteeFirstName & " " & requesteeLastName & " has denied your request to no longer pursue <a href="""&hrefStr&""">"&name&"</a>" & vbcrlf & "REASON:"&vbcrlf & reason	
			else 
			title = "Witness Request Rejection"
			' Create our reason message, including a link to the experiment
			reasonFixedForCKEditor = "The user " & requesteeFirstName & " " & requesteeLastName & " has denied your request to witness <a href="""&hrefStr&""">"&name&"</a>" & vbcrlf & "REASON:"&vbcrlf & reason
		end if
		
	
		reason = textToHTML(reasonFixedForCKEditor)
		'send notification to co-authors
		for each author in authorList
			if abandonExperiment = "true" then
				a = sendNotification(author, title, reason, 18)
				else
				a = sendNotification(author, title, reason, 6)
			end if
		next
		'if there are no co-authors, send one to the owner
		if UBound(authorList) = -1 then
			if abandonExperiment = "true" then
				a = sendNotification(author, title, reason, 18)
				else 
				a = sendNotification(userId, title, reason, 6)
			end if
		end if
		'make a new revision with reopened status
		a = duplicateAndChangeStatus(experimentType,experimentId,"7",true)
		'add a note to the experiment containing the reason for rejection
		a = addNoteToExperiment(experimentType,experimentId,title,reason,true)
	Else
		'experiment has been reopened by someone with permission to reopen experiments
		'if the user has explicit reopen privelege or the user is and Admin of Group Admin
		If session("roleNumber") <2 Or session("canReopen") Then
			'generate notification for user
			title = "Experiment Reopened"
			reason = "Your experiment <a href="""&hrefStr&""">"&name&"</a> has been reopened" & vbcrlf & "REASON:"&vbcrlf & reason
			reason = textToHTML(reason)
		
			'send notification to co-authors
			for each author in authorList
				a = sendNotification(author, title, reason, 5)
			next
			'make new revision of experiment with reopened status
			a = duplicateAndChangeStatus(experimentType,experimentId,"8",true)
			'add note to the experiment with reason for reopening
			a = addNoteToExperiment(experimentType,experimentId,title,reason,true)
		End if
	End If
	'delete any witness requests because an open experiment should not have witness requests
	connadm.execute("DELETE FROM witnessRequests WHERE experimentTypeId="&SQLClean(experimentType,"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S"))
	%><div id="resultsDiv">success</div><%
End If
'return error for witness request not found
%>
<div id="resultsDiv">Witness Request Not Found</div>