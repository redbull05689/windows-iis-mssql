<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
' Ticket 5076 - Replace ASP function with a SQL table function
' Ex. To get a list of users who can view experimentId = 10 and experimentType = 5, execute this -
'		SELECT STUFF((SELECT  ',' + CAST(userId AS VARCHAR) FROM dbo.udfUsersWhoCanViewExperiment(10, 5) FOR XML PATH('')), 1, 1, '') AS userIdList;
function usersWhoCanViewExperiment(experimentType,experimentId)
	'return list of all users who can view the specified experiment
	'used to determine who to push notifications to
	usersWhoCanViewExperiment = ""
	Set uwRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT STUFF((SELECT ',' + CAST(userId AS VARCHAR) FROM dbo.udfUsersWhoCanViewExperiment(" & SQLClean(experimentId,"N","S") & "," & SQLClean(experimentType,"N","S") & ") FOR XML PATH('')), 1, 1, '') AS userIdList"
	uwRec.open strQuery,conn,3,3
	If Not uwRec.eof Then
		' uwRec("userIdList") can be value of NULL
		usersWhoCanViewExperiment = uwRec("userIdList") & ""
	End If
	uwRec.close
	set uwRec = Nothing
end function
%>