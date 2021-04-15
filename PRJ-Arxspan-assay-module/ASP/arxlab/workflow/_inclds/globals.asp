<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<!-- #include file="../../_inclds/__whichServer.asp"-->
<!-- #include file="../../_inclds/misc/functions/fnc_getRandomString.asp"-->
<!-- #include file="../../_inclds/escape_and_filter/functions/fnc_SQLClean.asp"-->

<!-- #include file="../../_inclds/data_types/functions/fnc_removeDuplicates.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_loginUser.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_isAdminUser.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_companyUsesSso.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_usersWhoCanViewExperiment.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_getUsersICanSee.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canReadNotebookByProject.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canReadNotebook.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canViewProject.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canWriteProject.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canWriteNotebook.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_ownsNotebook.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_ownsProject.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_hasNotebookInvite.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_hasNotebookInviteRead.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_hasNotebookInviteWrite.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canViewExperimentByProject.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canViewExperiment.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canWitness.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canCreateExperiment.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canCreateNotebook.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_hasShareNotebookPermission.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canShareNotebook.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_canShareShareNotebook.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_ownsExperiment.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_getReadNotebooks.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_isExperimentClosed.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_isExperimentClosedByStatus.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_toolTip.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_experimentStatusImg.asp"-->

<!-- #include file="../../_inclds/experiments/common/functions/fnc_fetchWorkflowData.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
If Not isApiPage Then
    If session("userId")="" Or session("role")="" Then
        If request.servervariables("REMOTE_ADDR") <> "8.20.189.170" And request.servervariables("REMOTE_ADDR") <> "8.20.189.168" And request.servervariables("REMOTE_ADDR") <> "8.20.189.169" And request.servervariables("REMOTE_ADDR") <> "8.20.189.188" And request.servervariables("REMOTE_ADDR") <> "8.20.189.21" And request.servervariables("REMOTE_ADDR") <> "8.20.189.141" And request.servervariables("REMOTE_ADDR") <> "8.20.189.142" then
            response.redirect("/login.asp")
        End if
    End if
End If
%>
<%
uploadPath = uploadRootRoot

Function showAdminPages()
	showAdminPages = False
	if session("role") = "Admin" or session("manageWorkflow") = true then
		showAdminPages = True
	end if

	if not showAdminPages then
		Set gRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM groupMembersView WHERE userId="&SQLClean(session("userId"),"N","S")
		gRec.open strQuery,conn,3,3

		Do While Not gRec.eof
			If (Not showAdminPages) And gRec("groupName") = "Configuration Managers" Then
				showAdminPages = True
				Exit Do
			End If
			gRec.moveNext
		Loop
		gRec.Close
		Set gRec=Nothing
	end if
End Function

Function showDropDownPages()
	showDropDownPages = False
	if session("role") = "Admin" then
		showDropDownPages = True
	end if

	if not showDropDownPages then
		Set gRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM groupMembersView WHERE userId="&SQLClean(session("userId"),"N","S")
		gRec.open strQuery,conn,3,3

		Do While Not gRec.eof
			If (Not showDropDownPages) And gRec("groupName") = "Business Administrators" Then
				showDropDownPages = True
				Exit Do
			End If
			gRec.moveNext
		Loop
		gRec.Close
		Set gRec=Nothing
	end if
End Function

%>
