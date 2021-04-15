<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
'The purpose of this script is to determine whether there is a newer version of the experiment that you are editing.
'This can happen if you switch computers from A to B.  If you have experiment C open on A, then go to B and save C, the version on A will cause syncing problems
'if you let the user save it.
experimentId = request.querystring("id")
experimentType = request.querystring("experimentType")
revisionNumber = request.querystring("revisionNumber")

If (Not IsNumeric(experimentId)) Or (Not IsNumeric(experimentType)) Or (Not IsNumeric(revisionNumber)) Then
	response.end()
End If

'only allow experiment owner to use this script
If Not ownsExperiment(experimentType,experimentId,session("userId")) Then
	Call disconnect
	response.end
End If

'see if we are on the current revision and return true if the experiment page needs to be refreshed
maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
If CInt(maxRevisionNumber) > CInt(revisionNumber)Then
	Call disconnect
	response.write("true")
	response.end
End If
Call disconnect
%>