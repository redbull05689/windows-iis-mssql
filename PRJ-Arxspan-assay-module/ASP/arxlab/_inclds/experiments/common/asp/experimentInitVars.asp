<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
'get experiment Id it is used everywhere
experimentId = request.querystring("id")
notebookId = request.querystring("notebookId")
revisionId = request.querystring("revisionId")
projectId = request.querystring("projectId")
description = request.querystring("description")
requestTypeId = request.querystring("r")
canDeleteExperimentLinks = ownsExperiment(experimentType,experimentId,session("userId")) And Not isExperimentClosedByStatus(experimentStatusId)
session("ssoexperimenttype") = experimentType
session("ssoexperimentid") = experimentId

If request.querystring("id") = "" Then
	page = mainAppPath&"/experiments/createExperiment.asp?notebookId="&notebookId&"&experimentType="&experimentType&"&description="&description
	If projectId <> "" Then
		page = page &"&projectId="&projectId
	End If
	If requestTypeId <> "" Then
		page = page & "&r=" & requestTypeId
	end if
	session("defaultNotebookId") = notebookId
	session("defaultProjectId") = projectId

	session("defaultExperimentType") = experimentType
	If experimentType = 5 Or experimentType = "5" Then
		experimentTypeInt = 5000 + CInt(requestTypeId)
		session("defaultExperimentType") = experimentTypeInt
	End If

	response.redirect(page)
End If

session("SSOexperimentType") = experimentType
%>

<script>
	var canDeleteExperimentLinks = "<%=canDeleteExperimentLinks%>" == "True";
</script>