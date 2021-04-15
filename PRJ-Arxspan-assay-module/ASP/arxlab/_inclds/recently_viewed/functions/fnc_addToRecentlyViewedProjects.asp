<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function addToRecentlyViewedProjects(projectId)
	'called when a project is viewed. adds project to recently viewed projects table. used to order projects in the nav and on the showprojects page 
	'through the all projectPernWithInfo view

	'delete other records of this project from the table
	strQuery = "DELETE FROM recentlyViewedProjects WHERE userId="&SQLClean(session("userId"),"N","S")&" AND projectId="&SQLClean(projectId,"N","S")
	connadm.Execute(strQuery)
	
	'insert notebook into recently viewed projects table
	strQuery = "Insert into recentlyViewedProjects(projectId,userId,theDate) values("&_
	SQLClean(projectId,"N","S") & "," &_
	SQLClean(session("userId"),"N","S") & ",GETUTCDATE())"
	connadm.Execute(strQuery)
end function
%>