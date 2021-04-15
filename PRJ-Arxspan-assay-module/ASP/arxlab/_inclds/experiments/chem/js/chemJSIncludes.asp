<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../common/js/allExperimentInclude.asp"-->
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->

<script type="text/javascript" src="js/sketch.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/gridFunctions.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/units.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/showTR.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/parseRXN.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/toggleAttachment.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/toggleNote.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/arxXml.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/deleteExperiment.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/ajax.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/editTabName.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/grid.js?<%=jsRev%>" charset="utf-8"></script>
<script type="text/javascript">
<%if session("hasInventoryIntegration") Or session("hasCompoundTracking") then%>
	deleteTabFromCdx = true;
<%else%>
	deleteTabFromCdx = false;
<%end if%>
</script>
<script type="text/javascript" src="js/gridTabs.js?<%=jsRev%>"></script>
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