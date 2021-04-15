<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->

<%
'Save a witness request, if the experiment is signed OK, it will create the witness request
experimentType = request.Form("experimentType")
experimentId = request.Form("experimentId")
requesteeId = request.Form("requesteeId")
state = request.Form("state")
'can only send witness request if you own the experiment Or you are a coauthor
If ownsExperiment(experimentType,experimentId,session("userId")) OR checkCoAuthors(experimentId, experimentType, "requestWitness") Then
    response.write("You Own This")
    session("SAFERequestWitness_" & state) = requesteeId
    session.Save()
    response.status = 200
else
    response.write("Not yours")
    response.status = 200
End if
response.end()
%>
