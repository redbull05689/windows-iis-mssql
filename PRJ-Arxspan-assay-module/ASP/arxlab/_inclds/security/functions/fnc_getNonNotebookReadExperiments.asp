<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="./fnc_getGroupIdListByUser.asp"-->
<%
Function getNonNotebookReadExperiments(userId, notebookList)
	' This function gets all of the experiments that a user can see that do not meet the following criteria:
	' - User is not the owner of the experiments
	' - User does not have read access through the notebook (specify list in notebookList, preferably using the getReadNotebooks() function)
	'
	' The primary use case for this is experiments that have been attached to Projects to which the user has read access
	' while the following conditions are not met:
	' - The user does not already have access to the Notebook the experiment is in
	' - The Notebook the experiment is in is not already attached to the Project

	'get all projects that the specified user can has view access to
	experimentCount = 0
	experimentString = ""
	
	Set grnRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT DISTINCT uniqueExperimentId FROM projectExperimentPermView WHERE (canRead=1 AND shareeId="&SQLClean(userId,"N","S")&" AND (accepted=1 OR accepted IS null)) OR (groupCanRead=1 AND groupShareeId IN " & getGroupIdListByUser(session("userId")) & " AND (groupAccepted=1 OR groupAccepted IS null))"
	grnRec.open strQuery,conn,3,3
	
	'loop through all the notebooks in the allnotebookpermview
	Do While Not grnRec.eof
		experimentCount = experimentCount + 1
		experimentString = experimentString & grnRec("uniqueExperimentId") & ","
		grnRec.movenext
	Loop
	grnRec.close
	Set grnRec = Nothing
	
	'remove the trailing comma if the string is not empty
	If experimentCount >= 1 Then
		experimentString = Mid(experimentString,1,Len(experimentString)-1)
	End If
	
	If experimentString = "" Then
		getNonNotebookReadExperiments = "'0'"
	Else
		'return the list of read notebooks 'nxq is this list complete?
		getNonNotebookReadExperiments = removeDuplicates(experimentString)
	End if
End Function
%>