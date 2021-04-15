<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="fnc_getJWT.asp"-->
<%
function loginUser(userId)
	'logs in the specified user
	call getconnected
	set liRec = server.createObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM usersView WHERE id="&SQLClean(userId,"N","S")
	liRec.open strQuery,conn,3,3
	if not liRec.eof Then
		' 12/6/17 - Now updating servicesConnectionId only on login
		' 2/26/18 - JVA: Now setting the servicesConnectionId in session to what is set in the DB at user creation time. 
		' 2/26/18 - JVA: It should never be set anywhere else!
		session("servicesConnectionId") = liRec("servicesConnectionId")
		connAdm.execute("UPDATE users SET loginAttempts=0,lastActivityTime=GETUTCDATE(),servicesConnectionId="&SQLClean(session("servicesConnectionId"),"T","S")&" WHERE id="&SQLClean(userId,"N","S"))
		session("usersICanSee") = ""
		'set session data
		session("firstName") = liRec("firstName")
		session("lastName") = liRec("lastName")
		session("email") = liRec("email")
		session("userId") = liRec("id")
		session("role") = liRec("roleName")
		session("roleId") = CInt(liRec("roleId"))
		session("roleNumber") = CInt(liRec("roleNumber"))
		session("company") = liRec("companyName")
		session("companyName") = liRec("companyName")
		session("companyId") = CInt(liRec("companyId"))

		' Get the adminSvc endpoint.
		getAdminSvcEndpoint()
		session("isWorkflowManager") = checkIfWorkflowManager(userId)
		setJWT liRec("id"), liRec("companyId")
			
		session("title") = liRec("title")
		session("phone") = liRec("phone")
		session("managerId") = liRec("userAdded")
		session("defaultWitnessId") = liRec("defaultWitnessId")
		session("defaultMolUnits") = liRec("defaultMolUnits")
		If IsNumeric(session("defaultWitnessId")) Then
			Set liRec2 = server.createobject("ADODB.RecordSet")
			strQuery2 = "SELECT fullName FROM usersView WHERE id="&SQLClean(session("defaultWitnessId"),"N","S")
			liRec2.open strQuery2,conn,3,3
			If Not liRec2.eof Then
				session("defaultWitnessName") = liRec2("fullName")
			End if
			liRec2.close
			Set liRec2 = nothing
		End if
		session("noPdf") = false

		isSupport = session("email") = "support@arxspan.com"

		'set the chemdraw session variable
		If liRec("useChemdrawPlugin") = 0 Then
			session("noChemDraw") = true
		End if

		If liRec("autoApproveReg") = 1 Then
			session("autoApproveReg") = True
		Else
			session("autoApproveReg") = False
		End if

		If liRec("companyHasMarvin") = 1 Then
			session("companyHasMarvin") = True
			
			If liRec("useMarvin") = 1 Then
				session("useMarvin") = true
			else
				session("useMarvin") = false
			End if
			
		Else
			session("companyHasMarvin") = False
			session("useMarvin") = false
		End If

		
		If liRec("manageWorkflow") = 1 Then
			session("manageWorkflow") = True
		Else
			session("manageWorkflow") = False
		End if



		If liRec("canEditReg") = 1 Then
			session("canEditReg") = True
		Else
			session("canEditReg") = False
		End if

		If liRec("hasAccordInt") = 1 Then
			session("hasAccordInt") = True
		Else
			session("hasAccordInt") = False
		End if

		If liRec("hasInventoryIntegration") = 1 Then
			session("hasInventoryIntegration") = True
		Else
			session("hasInventoryIntegration") = False
		End if

		If liRec("hasCrais") = 1 Then
			If session("companyId") = 57 then
				If (InStr(LCase(session("email")),"@daiichisankyo.co.jp") > 0) Or (InStr(LCase(session("email")),"@asubio.co.jp") > 0) Or session("email") = "support@arxspan.com" Then
					session("hasCrais") = True
				Else
					session("hasCrais") = False
				End if
			Else
				session("hasCrais") = True
			End if
		Else
			session("hasCrais") = False
		End if

		If liRec("hasBarcodeChooser") = 1 Then
			session("hasBarcodeChooser") = True
		Else
			session("hasBarcodeChooser") = False
		End if

		If liRec("hasProductsSD") = 1 Then
			session("hasProductsSD") = True
		Else
			session("hasProductsSD") = False
		End if

		If liRec("hasCompoundTracking") = 1 Then
			session("hasCompoundTracking") = True
		Else
			session("hasCompoundTracking") = False
		End if

		'set the experiment page based on whether or not the user will use chemdraw
		If session("noChemDraw") Then
			session("expPage") = "experiment_no_chemdraw.asp"
		else
			session("expPage") = "experiment.asp"
		End if
		If liRec("canLeadProjects") = 1 Then
			session("canLeadProjects") = True
		Else
			session("canLeadProjects") = False
		End If

		If liRec("autoSaveOnUnload") = 1 Then
			session("autoSaveOnUnload") = True
		Else
			session("autoSaveOnUnload") = False
		End If

		If liRec("canChangeExperimentNames") = 1 Then
			session("canChangeExperimentNames") = True
		Else
			session("canChangeExperimentNames") = False
		End If

		If liRec("showFullChemicalNameInQuickView") = 1 Then
			session("showFullChemicalNameInQuickView") = True
		Else
			session("showFullChemicalNameInQuickView") = False
		End If

		If liRec("canDelete") = 1 Then
			session("canDelete") = True
		Else
			session("canDelete") = False
		End If

		If liRec("hasInv") = 1 Then
			session("hasInv") = True
		Else
			session("hasInv") = False
		End If
		If Not IsNull(liRec("invRoleName")) then
			session("invRoleName") = liRec("invRoleName")
		Else
			session("invRoleName") = ""
		End if

		If Not IsNull(liRec("defaultAddFromELNKeyPath")) Then
			session("defaultAddFromELNKeyPath") = liRec("defaultAddFromELNKeyPath")
		Else
			session("defaultAddFromELNKeyPath") = ""
		End if

		If liRec("hasAssay") = 1 Then
			session("hasAssay") = True
		Else
			session("hasAssay") = False
		End If
		If Not IsNull(liRec("assayRoleName")) then
			session("assayRoleName") = liRec("assayRoleName")
		Else
			session("assayRoleName") = ""
		End if

		If liRec("hasRegApi") = 1 Then
			session("hasRegApi") = True
		Else
			session("hasRegApi") = False
		End If

		If liRec("useGMT") = 1 Then
			session("useGMT") = True
		Else
			session("useGMT") = False
		End If

		If liRec("hasShortPdf") = 1 Then
			session("hasShortPdf") = True
		Else
			session("hasShortPdf") = False
		End If

		'muf 
		If liRec("hasMUFExperiment") = 1 Then
			session("hasMUFExperiment") = True
		Else
			session("hasMUFExperiment") = False
		End If

		If liRec("hideNonCollabExperiments") = 1 Then
			session("hideNonCollabExperiments") = True
		Else
			session("hideNonCollabExperiments") = False
		End If

		If liRec("requireProjectLink") = 1 Then
			session("requireProjectLink") = True
		Else
			session("requireProjectLink") = False
		End If

		If liRec("requireProjectLinkForNB") = 1 Then
			session("requireProjectLinkForNB") = True
		Else
			session("requireProjectLinkForNB") = False
		End if

		If liRec("hasReg") = 1 Then
			session("hasReg") = True
		Else
			session("hasReg") = False
		End If
		If liRec("hasELN") = 1 Then
			session("hasELN") = True
		Else
			session("hasELN") = False
		End if

		'Defaults for session timeout
		session.Timeout = 60
		session("sessionTimeout") = True
		session("sessionTimeoutMinutes") = 60
		
		If Not IsNull(liRec("sessionTimeout")) Then
			If liRec("sessionTimeout") = 1 Then
				If Not IsNull(liRec("sessionTimeoutMinutes")) Then
					session.Timeout = CInt(liRec("sessionTimeoutMinutes"))
					session("sessionTimeoutMinutes") = liRec("sessionTimeoutMinutes")
				End if
			End if
		End if

		session("regRegistrar") = False
		session("regUser") = False
		session("regRestrictedUser") = False
		session("regRoleNumber") = liRec("regRoleNumber")
		If session("hasReg") Then
			If Not IsNull(liRec("regRoleNumber")) then
				Select Case CInt(liRec("regRoleNumber"))
					Case 10
						session("regRegistrar") = True
						session("regUser") = True
						session("regRegistrarRestricted") = False
					Case 15
						session("regRegistrar") = True
						session("regRegistrarRestricted") = True
					Case 20
						session("regUser") = True
					Case 30
						session("regUser") = True
						session("regRestrictedUser") = True
				End select
			End if
		End if

		'If liRec("redirectToSignedPDF") = 1 Then
		'ELN-447
		If	IsNull(liRec("redirectUserToSignedPDF")) Or liRec("redirectUserToSignedPDF") = 1 Then
			session("redirectToSignedPDF") = True
		Else
			session("redirectToSignedPDF") = False
		End if

		If liRec("canViewSiblings") = 1 then
			session("canViewSiblings") = True
		Else
			session("canViewSiblings") = False
		End if
		If liRec("canViewEveryone") = 1 then
			session("canViewEveryone") = True
		Else
			session("canViewEveryone") = False
		End if

		'exception for sloan from changing their passwords
		'they have no passwords
		If session("companyId") <> 4 then
			session("mustChangePassword") = liRec("mustChangePassword")
		Else
			session("mustChangePassword") = 0
		End if

		If liRec("useSafe") = 1 Then
			session("useSAFE") = True
		else
			session("useSAFE") = False
		End If

		If liRec("useGoogleSign") = 1 Then
			session("useGoogleSign") = True
		else
			session("useGoogleSign") = False
		End If
		
		If liRec("softToken") = 1 Then
			session("softToken") = True
		Else
			session("softToken") = False
		End If

		If liRec("companyHasFT") = 1 Then
			session("companyHasFT") = True
		Else
			session("companyHasFT") = False
		End If
		If liRec("userHasFT") = 1 Then
			session("userHasFT") = True
		Else
			session("userHasFT") = False
		End If
		If session("userHasFT") And session("companyHasFT") Then
			session("hasFT") = True
			session("FTDB") = liRec("FTDB")
		Else
			session("hasFT") = False		
		End if

		If session("companyHasFT") Then
			session("FTDB") = liRec("FTDB")
		End if


		If liRec("companyHasFTLiteAssay") = 1 Then
			session("companyHasFTLiteAssay") = True
		Else
			session("companyHasFTLiteAssay") = False
		End If
		If session("companyHasFTLiteAssay") Then
			session("FTDBLiteAssay") = liRec("FTDBLiteAssay")
		End If
		
		If liRec("companyHasFTLiteInventory") = 1 Then
			session("companyHasFTLiteInventory") = True
		Else
			session("companyHasFTLiteInventory") = False
		End If
		If session("companyHasFTLiteInventory") Then
			session("FTDBLiteInventory") = liRec("FTDBLiteInventory")
		End If

		If liRec("companyHasFTLiteReg") = 1 Then
			session("companyHasFTLiteReg") = True
		Else
			session("companyHasFTLiteReg") = False
		End If
		If session("companyHasFTLiteReg") Then
			session("FTDBLiteReg") = liRec("FTDBLiteReg")
		End If		

		If liRec("hasGroupFields") = 1 Then
			session("hasGroupFields") = True
		Else
			session("hasGroupFields") = False
		End If

		If liRec("ipBlock") = 1 Then
			session("ipBlock") = True
		Else
			session("ipBlock") = False
		End If

		''412015
		If liRec("canReopen") = 1 Then
			session("canReopen") = True
		Else
			session("canReopen") = False
		End If

		If liRec("canEditTemplates") = 1 Then
			session("canEditTemplates") = True
		Else
			session("canEditTemplates") = False
		End If

		If liRec("canEditKeywords") = 1 Then
			session("canEditKeywords") = True
		Else
			session("canEditKeywords") = False
		End If	

		If liRec("useChemdrawPlugin") = 1 Then
			session("useChemDrawForLiveEdit") = True
		End If

		If liRec("isSsoUser") = 1 Then
			session("isSsoUser") = True
		Else
			session("isSsoUser") = False
		End If

		''/412015
		
		If Not IsNull(liRec("barcodeLength")) Then
			session("barcodeLength") = liRec("barcodeLength")
		Else
			session("barcodeLength") = 6
		End if

		'chemistry blocking section
		If IsNull(liRec("hasChemistry")) Or liRec("hasChemistry")=1 Then
			companyHasChemistry = True
			session("companyHasChemistry") = true
		Else
			companyHasChemistry = False
			session("companyHasChemistry") = false
		End if
		If IsNull(liRec("userHasChemistry")) Or liRec("userHasChemistry")=1 Then
			userHasChemistry = true
		Else
			userHasChemistry = false
		End if
		If companyHasChemistry = False Then
			session("hasChemistry") = False
		Else
			If userHasChemistry Then
				session("hasChemistry") = True
			Else
				session("hasChemistry") = False
			End if
		End if

		If liRec("canChangeHasChemistry") = 1 Then
			session("canChangeHasChemistry") = true
		Else
			session("canChangeHasChemistry") = false		
		End if

		If liRec("ccAdminsOnSupport") = 1 Then
			session("ccAdminsOnSupport") = True
		Else
			session("ccAdminsOnSupport") = False
		End if
		'end chemistry blocking section

		'begin new experiment defaults
		If IsNull(liRec("defaultNotebookId")) Then
			session("defaultNotebookId") = ""
		Else
			session("defaultNotebookId") = liRec("defaultNotebookId")
		End If

		If IsNull(liRec("defaultExperimentType")) Then
			session("defaultExperimentType") = ""
		Else
			session("defaultExperimentType") = liRec("defaultExperimentType")
		End If
		
		If IsNull(liRec("defaultProjectId")) Then
			session("defaultProjectId") = ""
		Else
			session("defaultProjectId") = liRec("defaultProjectId")
		End If

		If Not IsNull(liRec("registerFromBio")) then
			If liRec("registerFromBio") = 1 Then
				session("registerFromBio") = True		
			Else
				session("registerFromBio") = False			
			End if
		Else
			session("registerFromBio") = False
		End If

		if liRec("allowAllNotebookPDFDownloads") = 1 then
			session("canDownloadAllNotebookPDFs") = true
		else
			session("canDownloadAllNotebookPDFs") = false
		end if
		
		session("passwordRegEx") = "^.*(?=.{6,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*$"
		session("passwordMessage") = "Passwords must be at least 6 characters and have: at least one, uppercase letter, lower case letter and number."
		If Not IsNull(liRec("passwordRegEx")) Then
			If Trim(liRec("passwordRegEx")) <> "" Then
				session("passwordRegEx") = liRec("passwordRegEx")
				session("passwordMessage") = liRec("passwordMessage")
			End if
		End if

		session("userOptions") = "{}"
		If Not IsNull(liRec("options")) Then
			If liRec("options") <> "" Then
				session("userOptions") = liRec("options")
			End if
		End if
		
		session("hasOrdering") = False
		If Not IsNull(liRec("hasOrdering")) Then
			If liRec("hasOrdering") <> "" Then
				session("hasOrdering") = True
			End If
		End If

		' Give all Admin's Ops Report
		session("userHasOperationalReport") = false
		If liRec("roleNumber") <= 1 Then
			session("userHasOperationalReport") = True
		End If

		'make a string list of all the groups that the user is a member of
		Set gRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT groupId FROM groupMembers WHERE userId="&SQLClean(session("userId"),"N","S")
		gRec.open strQuery,conn,3,3
		groupStr = ""
		Do While Not gRec.eof
			groupStr = groupStr & gRec("groupId")
			gRec.movenext
			If Not gRec.eof Then
				groupStr = groupStr & ","
			End if
		Loop
		gRec.close
		Set gRec = Nothing
		session("groupIds") = groupStr

		session("loadedRegRestrictedGroups") = False

		'log the login
		If Not hideLoginNotification then
			a = logAction(0,0,"",10)
		End if
	end if

	'session("hasElementalMachines") = false
	session("hasElementalMachines") = liRec("companyHasElementalMachines") and liRec("userHasElementalMachines")


	session("elementalMachinesUserName") = ""
	session("elementalMachinesPassword") = ""

	session("useResumableFileUploader") = false
	If Not IsNull(liRec("useHTML5Uploader")) Then
		If liRec("useHTML5Uploader") = 1 Then
			session("useResumableFileUploader") = True
		End If
	End If

	liRec.close()
	set liRec = Nothing

	set opRec = server.createObject("ADODB.RecordSet")
	strQuery = "SELECT userID, filterData FROM reportUsers WHERE userID = " & SQLClean(userId,"N","S") & " AND companyId = " & session("companyId")
	opRec.open strQuery,conn,3,3

	
	session("opReportFilter") = ""
	If Not opRec.eof Then
		session("userHasOperationalReport") = true
		If opRec("filterData") <> "" Then
			session("opReportFilter") = opRec("filterData")
		End If
	End If
	opRec.close()
	set opRec = Nothing

	session("requestTypeNames") = ""
	session("requestTypeIds") = ""

	' Set the logout Redirect URL as cookie so we can read it even after the session is dead
	strQuery = "SELECT logoutRedirectUrl FROM companies WHERE id="&SQLClean(session("companyId"),"N","S")
	Set lruRec = Server.CreateObject("ADODB.RecordSet")
	lruRec.Open strQuery,Conn,3,3 
	If Not lruRec.eof Then
		If lruRec("logoutRedirectUrl") <> "" And Not IsNull(lruRec("logoutRedirectUrl")) Then
			' Set the logout redirect cookie for 1 year
			Response.Cookies("logoutRedirectUrl") = lruRec("logoutRedirectUrl")
			Response.Cookies("logoutRedirectUrl").expires = DateAdd( "yyyy", 1, Date )
		else
			' Delete the cookie if it exists
			Response.Cookies("logoutRedirectUrl").expires = DateAdd( "yyyy", -1, Date ) 
		End If
	End If
	lruRec.close()
	set lruRec = Nothing

	'This is here to help with session slowness
	session.Save()
	
end function
%>