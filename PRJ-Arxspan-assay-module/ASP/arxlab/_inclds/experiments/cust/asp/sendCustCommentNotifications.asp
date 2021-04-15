<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%

    ' Stuff from the frontend that we're gonna need.
    ids = request.form("ids")
    expName = request.form("expName")
    expId = request.form("expId")
    expType = "5"
    ownerId = request.form("ownerId")
    comment = request.form("comment")
    
	rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
    ' Stuff we can derive either from our session or frontend variables.
    commenterName = session("firstName") & " " & session("lastName")
    userIdList = split(ids, ",")

    ' Figure out what page we're using.
    prefix = getPrefix(expType)
    page = GetExperimentPage(prefix)
    expLink = page & "?id=" & expId

    ' Figure out who owns expId.
    ownerQuery = "SELECT firstName + ' ' + lastName AS name FROM users WHERE id=" & SQLClean(ownerId, "N", "S")
    Set ownerRec = server.CreateObject("ADODB.RecordSet")

    ownerRec.open ownerQuery, connAdm, 3, 3

    ' Just kill it if we can't figure out who owns it.
    if ownerRec.eof then
        response.end
    end if

    ownerName = ownerRec("name")
    ownerRec.close
    Set ownerRec = nothing
    
    ' Make a title and email body.
    title = "Comment Added"
    emailBody = generateExperimentCommentEmailBody(commenterName, expLink, expName, ownerName, "", "", comment, true)

    ' Loop through ID in userIdList
    for i=0 to uBound(userIdList)
    
        ' Assuming we have a valid userId...
        If IsInteger(userIdList(i)) and userIdList(i) <> "" then

            ' Insert this comment into the notifications table.
            strQuery = "INSERT into commentNotifications(userId,commenterId,experimentType,experimentId,comment,dateAdded,dateAddedServer) values("&_
            SQLClean(userIdList(i),"N","S") & "," &_
            SQLClean(session("userId"),"N","S") & "," &_
            SQLClean(experimentType,"N","S") & "," &_
            SQLClean(experimentId,"N","S") & "," &_
            SQLClean(maxChars(comment,100),"T","S") & ",GETUTCDATE(),GETDATE())"
            connAdm.execute(strQuery)

            ' Then send the notification and send the user an email.
            a = sendNotification(userIdList(i),title,emailBody,1)

            If not userHasCommentEmailsEnabled(userIdList(i)) Then ' If the user doesn't have email notifications on, the sendNotification call didn't actually send an email...
                b = emailUser(userIdList(i), "ARXSPAN - You have received a new notification.", Replace(Replace(emailBody,"href=""","href=""https://"&rootAppServerHostName&mainAppPath&"/"),"href='","href='https://"&rootAppServerHostName&mainAppPath&"/"))
            End If
        End if
    next
%>