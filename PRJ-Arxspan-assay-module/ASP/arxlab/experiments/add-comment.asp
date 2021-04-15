<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
'add a comment to an experiment
Call getconnected
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
notifiedUserList = request.querystring("notifiedUserList[]")
parentCommentId = request.querystring("parentCommentId")
comment = SQLClean(request.querystring("comment"),"JSON","S")
workflowRequestFieldId = request.querystring("r")

rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))

'make sure we have all the data we need
If experimentId <> "" And experimentType <> "" And comment <> "" Then
	'only add comment if user can view experiment
	If canViewExperiment(experimentType,experimentId,session("userId")) Then
		'add the comment and get the new comment id
		strQuery = "INSERT into experimentComments(experimentType,experimentId,userId,parentCommentId,comment,dateSubmitted,dateSubmittedServer{requestId}) output inserted.id as newId values(" &_
			SQLClean(experimentType,"N","S") & "," &_
			SQLClean(experimentId,"N","S") & "," &_
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(parentCommentId,"N","S") & "," &_
			SQLClean(comment,"T","S") & ",GETUTCDATE(),GETDATE()"
		if workflowRequestFieldId <> "" then
			strQuery = strQuery & ", " & workflowRequestFieldId
			strQuery = Replace(strQuery, "{requestId}", ",requestFieldId")
		else
			strQuery = Replace(strQuery, "{requestId}", "")
		end if
		strQuery = strQuery & ")"
		Set rs = connAdm.execute(strQuery)
		newId = CStr(rs("newId"))


    set commRec = server.CreateObject("ADODB.RecordSet")
        commQuery = "SELECT * FROM experimentComments WHERE id=" & newId
        commRec.open commQuery,conn,3,3
    Do While Not commRec.eof
            commentStr =""
            commentStr = commentStr & "{" & """" & "id" & """" & ": " & newId
            commentStr = commentStr & "," & """" & "parentId" & """" & ":" & commRec("parentCommentId")
            commentStr = commentStr & "," & """" & "userName" & """" & ":" & """" & session("firstName") &" "& session("lastName") & """" 
            commentStr = commentStr & "," & """" & "userId" & """" & ":" & commRec("userId")
            commentStr = commentStr & "," & """" & "dateSubmitted" & """" & ":" & """" & commRec("dateSubmitted") & """" 
            commentStr = commentStr & "," & """" & "comment" & """" & ":" & """" & comment & """" 
            commentStr = commentStr & "," & """" & "attachment" & """" & ":[]" 
            commentStr = commentStr & "}"
            commRec.movenext
        Loop


		'get current UTC date for display in new comment block
		Set dateRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT GETUTCDATE() as now"
		dateRec.open strQuery,connAdm,3,3
		If Not dateRec.eof Then
			dateNow = dateRec("now")
		End If
		dateRec.close
		Set dateRec = nothing

		'get experiment page for link in comment added notification
		Set eRec = server.CreateObject("ADODB.RecordSet")
		
		prefix = GetPrefix(CStr(experimentType))
		tableName = GetFullName(prefix, "experiments", true)
		page = GetExperimentPage(prefix)
		
		strQuery = "SELECT u.firstName, u.lastName, e.name, e.userId, e.userExperimentName, e.details from " & tableName & " e inner join users u on u.id=e.userId where e.id="&SQLClean(experimentId,"N","S")
		
		' Get the experiment owner's name
		eRec.open strQuery,connAdm,3,3
		If Not eRec.eof Then
			experimentOwnerName = eRec("firstName") & " " & eRec("lastName")
		'End if
		'eRec.close
		
		' Get the experiment name/description & owner's userId
		'viewStrQuery = "SELECT name, userId, description, details FROM allExperiments WHERE legacyId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
		'eRec.open viewStrQuery,connAdm,3,3
		'If Not eRec.eof Then
			experimentName = eRec("name")
			experimentOwnerId = eRec("userId")
			if eRec("userExperimentName") <> "" then
				experimentDescription = eRec("userExperimentName")
			else
				experimentDescription = eRec("details")
			end if
		End if
		eRec.close

		' Get the experiment's project info
		projectStrQuery = "SELECT projectName, projectId FROM linksProjectExperimentsView WHERE experimentId="&SQLClean(experimentId,"N","S")& " AND typeId="&SQLClean(experimentType,"N","S")
		eRec.open projectStrQuery,connAdm,3,3
		If Not eRec.eof Then
			projectId = eRec("projectId")
			projectName = eRec("projectName")
		End if
		eRec.close
		Set eRec = nothing
		
		' Notification email title
		title = "Comment Added"
		' Notification email body
		experimentLink = "https://"&rootAppServerHostName&mainAppPath&"/"&mainAppPath&"/"&page&"?id="&experimentId ' probably not used
		email_commenterFullName = session("firstName") &" "& session("lastName")
		email_experimentLink = page&"?id="&experimentId
		email_projectLink = "show-project.asp?id="&projectId
		
		usersWhoCanViewThisExperiment = usersWhoCanViewExperiment(experimentType,experimentId)
        listOfUsersWhoCanViewThisExperiment = Split(usersWhoCanViewThisExperiment,",")

		If ubound(listOfUsersWhoCanViewThisExperiment) >= 0 then
			' Send notification to all users who can view the experiment that a comment has been added - send a special message if they were mentioned in the comment
			' Do a batch insert here instead of inserting one at a time inside the loop.
			strQuery = "INSERT INTO commentNotifications(userId,commenterId,experimentType,experimentId,comment,dateAdded,dateAddedServer) SELECT value," &_
					SQLClean(session("userId"),"N","S") & "," &_
					SQLClean(experimentType,"N","S") & "," &_
					SQLClean(experimentId,"N","S") & "," &_
					SQLClean(maxChars(comment,100),"T","S") & ",GETUTCDATE(),GETDATE() FROM STRING_SPLIT('" & usersWhoCanViewThisExperiment & "', ',') WHERE value<>'';"
			connAdm.execute(strQuery)

			usersMentioned = Split(notifiedUserList,",")
	    
			For i = 0 To ubound(listOfUsersWhoCanViewThisExperiment) ' Loop through all users who can see the experiment
				If IsInteger(listOfUsersWhoCanViewThisExperiment(i)) and listOfUsersWhoCanViewThisExperiment(i) <> "" then	            
					If CStr(session("userId")) <> CStr(listOfUsersWhoCanViewThisExperiment(i)) Then ' As long as this isn't the commenter...
						thisUserWasMentioned = False
						For j = 0 To ubound(usersMentioned)
							if Trim(CStr(usersMentioned(j))) = CStr(listOfUsersWhoCanViewThisExperiment(i)) then
								thisUserWasMentioned = True ' Found this user in the list of mentioned users
								exit for
							end if
						next
						emailBody = generateExperimentCommentEmailBody(email_commenterFullName,email_experimentLink,experimentName,experimentOwnerName,email_projectLink,projectName,comment,thisUserWasMentioned)
						a = sendNotification(listOfUsersWhoCanViewThisExperiment(i),title,emailBody,1)
						If not userHasCommentEmailsEnabled(listOfUsersWhoCanViewThisExperiment(i)) and thisUserWasMentioned = True Then ' If the user doesn't have email notifications on, the sendNotification call didn't actually send an email...
							b = emailUser(listOfUsersWhoCanViewThisExperiment(i),"ARXSPAN - You have received a new notification.",Replace(Replace(emailBody,"href=""","href=""https://"&rootAppServerHostName&mainAppPath&"/"),"href='","href='https://"&rootAppServerHostName&mainAppPath&"/"))
						End If
					End if
				End if
			next
		End If

		'return the HTML for the new comment
	    response.contentType = "application/json charset=utf-8"
	    response.write(commentStr)

	End If
End if

%>