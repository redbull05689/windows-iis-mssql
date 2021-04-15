<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%'signs an experiment%>
<%Response.Buffer=False%>
<%Server.scriptTimeout = 6000%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_requestWitness.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<%
'get form data JSON object
experimentJSON = Request.Form("hiddenExperimentJSON")
Set experimentJSON = JSON.parse(experimentJSON)

experimentId = experimentJSON.get("experimentId")
experimentType = experimentJSON.Get("typeId")
notebookId = experimentJSON.get("notebookId")

' Check if the current user is a coauthor on the experiment if this is a cust exp.
isCoAuthor = checkCoAuthors(experimentId, experimentType, "")

If session("requireProjectLink") Then
	'return error if no project is linked and project link is required
	%><!-- #include file="../_inclds/experiments/common/asp/requireProjectLink.asp"--><%
End if

Call getconnectedadm

'if the hungsaveSerial is already in the ACK table don't continue
'because the experiment is already in the process of saving
hungSaveSerial = experimentJSON.Get("hungSaveSerial")
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM serialsAck WHERE serial="&SQLClean(hungSaveSerial,"T","S")
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	response.write("<div id='frameExperimentId'>"&experimentId&"</div>")
	response.write("<div id='resultsDiv'>success</div>")
	response.end
End if

'redirect to error if the user does not own the experiment
If Not (ownsExperiment(experimentType,experimentId,session("userId")) or isCoAuthor) Then
	response.redirect(mainAppPath&"/static/notAuthorized.asp")
End If

'prevent signingg of previous revisions
If experimentJSON.get("thisRevisionNumber") <> "" then
	maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
	If CInt(maxRevisionNumber) <> CInt(experimentJSON.get("thisRevisionNumber"))Then
		response.write("<div id='resultsDiv'>There is a newer version of this experiment. Changes will not be saved.</div>")
		response.end
	End if
End If
%>
<%
If experimentJSON.get("sign") = "true" Then
	'get the correct experiment table
	prefix = GetPrefix(experimentType)
	experimentTable = GetFullName(prefix, "experiments", true)
	
	doNotEndResponse = True
	%>
	<!-- #include file="../_inclds/experiments/common/asp/signValidate.asp"-->
	<%
	If not signError Then
		' make a new revision of the experiment with the signed and closed status
		' 9990: If we are here, we should have a newStausID = "3" (Sign & Open) or "5" (Sign & Close) from signValidate.asp, use that instead of always hardcoding "5".
		statusIdToWrite = newStatusId & ""
		if statusIdToWrite = "" then
			statusIdToWrite = "5"
		end if
		oldRevisionNumber = duplicateAndChangeStatus(experimentType,experimentId,statusIdToWrite,true)

		if experimentType = "5" then
			authors = getCoAuthors(experimentId, experimentType, oldRevisionNumber+1)
			authorList = split(authors, ",")
			for each author in authorList
				' need to make sure author > 0, because the current app service will return userId 0 as a collaborator if there it is set to null.....sad.
				if not isNull(author) AND author <> "" AND author > 0 then  
					signers = addSigners(experimentId, "5", oldRevisionNumber+1, author)
				end if
			next
			userSigned = addSignature(experimentId, "5", oldRevisionNumber+1, session("userId"))
		else		
			a = savePDF(experimentType,experimentId,oldRevisionNumber+1,true,false,false)
		end if


		'convert experiment type to the correct type that is used by the log interface
		Select Case experimentType
			Case "1"
				extraType = "2"
			Case "2"
				extraType = "3"
			Case "3"
				extraType = "4"
			Case "4"
				extraType = "6"
			Case "5"
				extraType = "6"
		End Select
		'log signing action
		a = logAction(extraType,experimentId,"",7)
		session("justSaved") = False
		response.write("<div id='resultsDiv'>success</div>")
		response.end
	End If
End If
%>