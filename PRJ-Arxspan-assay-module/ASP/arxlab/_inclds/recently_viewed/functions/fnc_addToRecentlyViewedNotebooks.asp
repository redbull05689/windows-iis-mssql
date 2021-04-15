<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function addToRecentlyViewedNotebooks(cNotebookId)
	'called when a notebook is viewed. adds notebook to recently viewed notebooks table. used to order notebooks in the nav and on the shownotebooks page 
	'through the all notebookPernWithInfo view

	'delete other records of this notebook from the table
	strQuery = "DELETE FROM recentlyViewedNotebooks WHERE userId="&SQLClean(session("userId"),"N","S")&" AND notebookId="&SQLClean(cNotebookId,"N","S")
	connadm.Execute(strQuery)

	'insert notebook into recently viewed notebooks table
	strQuery = "Insert into recentlyViewedNotebooks(notebookId,userId,theDate) values("&_
	SQLClean(cNotebookId,"N","S") & "," &_
	SQLClean(session("userId"),"N","S") & ",GETUTCDATE())"
	connadm.Execute(strQuery)
end function
%>