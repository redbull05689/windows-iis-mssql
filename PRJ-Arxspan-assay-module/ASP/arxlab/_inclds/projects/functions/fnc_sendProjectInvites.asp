<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%

    function sendProjectInvites(projectId, projectName)
        ' Figures out who needs to get an invite to the given project and sends out notifications for the invites.
        userAdded = ""

        ' We think this block is looking for the user ID of the user who created the account that's sending these project invites.
        ' The assumption is that the userAdded account is this user's manager. If there is a value for this query found, they will be filtered
        ' out of the second query.
        Set userRec=server.CreateObject("ADODB.Recordset")
        userQuery = "SELECT * FROM users WHERE id=" & SQLClean(session("userId"),"N","S") & " AND userAdded IS NOT null AND userAdded <> 0"
        userRec.open userQuery,connAdm,3,3
        
        If Not userRec.eof then
            Call insertIntoProjectInvites(projectId, session("userId"), userRec("userAdded"))
            Call sendProjectInviteNotification(projectId, projectName, userRec("userAdded"))
            
            userAdded = userRec("userAdded")
        End if
        
        Set usersViewRec=server.CreateObject("ADODB.Recordset")
        usersViewQuery = "SELECT * FROM usersView WHERE roleNumber=1 AND companyId=" & SQLClean(session("companyId"),"N","S") & " AND id <> "&SQLClean(session("userId"),"N","S")
        If userAdded <> "" Then
            usersViewQuery = usersViewQuery & " AND id <> " & SQLClean(userAdded,"N","S")
        End if
        usersViewRec.open usersViewQuery,connAdm,3,3

        Do While Not usersViewRec.eof
            Call insertIntoProjectInvites(projectId, session("userId"), usersViewRec("id"))
            Call sendProjectInviteNotification(projectId, projectName, usersViewRec("id"))
            
            usersViewRec.movenext
        loop

    end function

    function insertIntoProjectInvites(projectId, sharerId, shareeId)
        ' Adds an invite to projectId for shareeId, from sharerId.
        insQuery = "" &_
            "INSERT INTO projectInvites" &_
            " (projectId, sharerId, shareeId, canRead, canWrite, accepted, denied, readonly)" &_
            " VALUES" &_
            " ({projectId}, {sharerId}, {shareeId}, 1, 0, 0, 0, 1)"
        
        insQuery = Replace(insQuery, "{projectId}", SQLClean(projectId, "N", "S"))
        insQuery = Replace(insQuery, "{sharerId}", SQLClean(sharerId, "N", "S"))
        insQuery = Replace(insQuery, "{shareeId}", SQLClean(shareeId, "N", "S"))
        
        connAdm.execute(insQuery)
    end function

    function sendProjectInviteNotification(projectId, projectName, shareeId)
        ' Sends a notification to shareeId that they have been invited to share projectId.
        title = "Project Share Invitation"
        note = "User {firstName} {lastName} has invited you to share <a href=""{mainAppPath}/show-project.asp?id={projectId}"">{projectName}</a>"
        note = Replace(note, "{firstName}", session("firstName"))
        note = Replace(note, "{lastName}", session("lastName"))
        note = Replace(note, "{mainAppPath}", mainAppPath)
        note = Replace(note, "{projectId}", projectId)
        note = Replace(note, "{projectName}", projectName)

        a = sendNotification(shareeId, title, note, 8) ' I guess 8 is the type of notification? That's defined somewhere but I don't remember where.
    end function

%>