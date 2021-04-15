<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
'this script takes an experiment name, converts the name to an id and redirects the user to the experiment page.
'this cannot differentiate between experiments that share names and is best suited for companies that have autonamed notebooks/experiments
Call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
'find experiment by name
strQuery = "SELECT experimentId, typeId FROM notebookIndexView WHERE name="&SQLClean(Trim(request.querystring("name")),"T","S")
rec.open strQuery,conn,0,-1
'loop through all experiments with the specified name
Do While Not rec.eof
	'get the experiment id and type
	experimentId = rec("experimentId")
	experimentType = rec("typeId")
	'user must have view access to expeirment to see it
	If canViewExperiment(experimentType,experimentId,session("userId")) then
		'build the page link of the selected experiment type
		prefix = GetPrefix(experimentType)
		page = GetExperimentPage(prefix)
		page = page &"?id="&Int(experimentId)
		'redirect the user to the experiment page
		response.redirect(mainAppPath&"/"&page)
	End if
	rec.movenext
loop
Call disconnect
%>