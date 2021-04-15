<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If ownsExp And revisionId="" Then
	Call getconnectedadm
	If Not isDraft Then
		strQuery = "INSERT INTO experimentDrafts(experimentId,experimentType,experimentJSON) values("&_
					SQLClean(experimentId,"N","S") & "," &_
					SQLClean(experimentType,"N","S") & "," &_
					SQLClean(JSON.stringify(experimentJSON),"T","S") & ")"
		connAdm.execute(strQuery)
	Else
		strQuery = "UPDATE experimentDrafts SET experimentJSON="&SQLClean(JSON.stringify(experimentJSON),"T","S")&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
		connAdm.execute(strQuery)
	End if
	Call disconnectadm
End if
%>