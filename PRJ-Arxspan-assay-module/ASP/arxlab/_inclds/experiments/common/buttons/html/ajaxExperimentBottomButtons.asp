<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
isAjax = True
if (Not IsNull(request.querystring("notebookId"))) then
	if (request.querystring("notebookId") <> "") then
		notebookId = CLng(request.querystring("notebookId"))
	else
		notebookId = ""
	end if
else
    notebookId = ""
end if

if (Not IsNull(request.querystring("experimentType")) and request.querystring("experimentType") <> "undefined" ) then
	if (request.querystring("experimentType") <> "") then
		experimentType = CLng(request.querystring("experimentType"))
	else
		experimentType = ""
	end if
else
    experimentType = ""
end if

if (Not IsNull(request.querystring("experimentId")) and request.querystring("experimentId") <> "undefined" ) then
	if (request.querystring("experimentId") <> "") then
		experimentId = CLng(request.querystring("experimentId"))
	else
		experimentId = ""
	end if
else
    experimentId = ""
end if

if (Not IsNull(request.querystring("revisionId"))) then
	if (request.querystring("revisionId") <> "") then
		revisionId = CLng(request.querystring("revisionId"))
	else
		revisionId = ""
	end if
else
	revisionId = ""
end if
%>
<!-- #include file="../../../../globals.asp"-->
<!-- #include file="../../asp/getExperimentPermissions.asp"-->
<!-- #include file="experimentBottomButtons.asp"-->
