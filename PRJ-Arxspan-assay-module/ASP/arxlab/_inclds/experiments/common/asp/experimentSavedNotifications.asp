<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
' Ticket 5076 - Replace ASP function with a SQL table function
	SQLCleanedExperimentId = SQLClean(experimentId,"N","S") 
	SQLCleanedExperimentType = SQLClean(experimentType,"N","S")
	strQuery = "INSERT INTO experimentSavedNotifications(userId,ownerId,experimentType,experimentId,dateAdded,dateAddedServer,dismissed) SELECT userId, " &_
			SQLClean(session("userId"),"N","S") & "," & _
			SQLCleanedExperimentType & "," &_
			SQLCleanedExperimentId & ",GETUTCDATE(),GETDATE(),0 FROM dbo.udfUsersWhoCanViewExperiment(" & SQLCleanedExperimentId & ", " & SQLCleanedExperimentType & ");"
	connAdmTrans.execute(strQuery)
%>