<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<script type="text/javascript" src="js/sketch.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/units.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/showTR.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/parseRXN.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/officeFrames.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/toggleAttachment.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/toggleNote.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/deleteExperiment.js?<%=jsRev%>"></script>
<%
If request.querystring("revisionId") = "" And ownsExp then
%><script type="text/javascript" src="js/editCheck2.js?<%=jsRev%>"></script><%
	If unsavedChanges(experimentType,experimentId) And ownsExp Then
		%>
		<script type="text/javascript">
			unsavedChanges = true;
		</script>
		<%
	End if
End if
%>