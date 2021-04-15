<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
server.scriptTimeout = 10000
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
'makes pdf version of the specified experiment

'passthrough function for experiment draft.  ignores draft data
Function draftSet(none,inString)
	draftSet = inString
End Function

'get querystring parameters
experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")
revisionNumber = request.querystring("revisionNumber")
fromSign = request.querystring("fromSign")

'only users who can view an experiment can have a PDF generated for it
if canViewExperiment(experimentType,experimentId,session("userId"))  then
	Call getconnectedadm

	'set short version flag
	shortVersion = request.querystring("short") = "1"
	
	'have PDF generation file sent to Python
	a = savePDF(experimentType,experimentId,revisionNumber,false,false,shortVersion)
	'redirect to the appropriate PDF display page
	response.redirect(mainAppPath&"/signed.asp?id="&experimentId&"&experimentType="&experimentType&"&revisionNumber="&revisionNumber&"&safeVersion="&safeVersion&"&fromSign="&fromSign&"&short="&request.querystring("short"))
Else
	'not authorized error
	response.redirect(mainAppPath&"/static/error.asp")
end if
%>