<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->
<%
errorText = ""
Select Case request.Form("linkTargetType")
	Case "5"
		If canWriteProject(request.Form("linkTargetId"),session("userId")) Then
			Call getConnectedAdm
			Select Case session("linkType")
				Case "1"
					errorText = addExperimentToProject(connAdm, "1", session("linkId"), request.Form("linkTargetId"), null, null)
				Case "2"
					errorText = addExperimentToProject(connAdm, "2", session("linkId"), request.Form("linkTargetId"), null, null)
				Case "3"
					errorText = addExperimentToProject(connAdm, "3", session("linkId"), request.Form("linkTargetId"), null, null)
				Case "4"
					errorText = addNotebookToProject(connAdm, session("linkId"), request.Form("linkTargetId"), null)
				Case "5"
					errorText = addExperimentToProject(connAdm, "4", session("linkId"), request.Form("linkTargetId"), null, null)
				Case "6"
					errorText = addRegIdToProject(connAdm, session("linkId"), request.Form("linkTargetId"), null)
			End select
			Call disconnectAdm
		End if
End select
%>
<%If errorText = "" then%>
<div id="resultsDiv">success</div>
<%else%>
<div id="resultsDiv"><%=errorText%></div>
<%End if%>
