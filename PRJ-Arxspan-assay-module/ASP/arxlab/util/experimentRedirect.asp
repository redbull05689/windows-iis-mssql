<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_getPrefix.asp"-->
<%
'prep db conn
Set recExp = server.CreateObject("ADODB.RecordSet")
experimentId = Request.QueryString("experimentId")
'setup query
SQLQuery = "SELECT legacyId, experimentType FROM allExperiments WHERE id=" & experimentId & " and companyId=" & session("companyId") 
'run it
recExp.open SQLQuery, connAdm, 0, 1
'check that we have results 
if Not recExp.eof then
legacyId = recExp("legacyId")
experimentType = recExp("experimentType")
'clean up 
recExp.close
'setup link
prefix = GetPrefix(experimentType)
experimentWithPrefix = GetExperimentPage(prefix)
fullLink = mainAppPath & "/" & experimentWithPrefix & "?id=" & legacyId
'and go
Response.Redirect fullLink
end if 
%>