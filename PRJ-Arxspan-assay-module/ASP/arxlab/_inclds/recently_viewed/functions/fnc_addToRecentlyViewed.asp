<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function addToRecentlyViewed(experimentId,experimentType)
	'called when an experiment is viewed.adds experiments to the recently viewed experiments table. This is used for the recently viewed experiments functionality on the dashboard

	'delete other records of this experiment from the table
	'we only want the most current view of the experiment so that we dont have any duplicates in the recently viewed experimets page
	strQuery = "DELETE FROM recentlyViewedExperiments WHERE userId="&SQLClean(session("userId"),"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")& " AND experimentType="&SQLClean(experimentType,"N","S") 
	connadm.Execute(strQuery)

	'insert this experiment into the recently viewed table
	strQuery = "Insert into recentlyViewedExperiments(experimentId,experimentType,userId,theDate) values("&_
	SQLClean(experimentId,"N","S") & "," &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(session("userId"),"N","S") & ",GETUTCDATE())"
	connadm.Execute(strQuery)
end function
%>