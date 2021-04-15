<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp" -->
<%
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
revisionId = request.querystring("revisionId")
%>
<!-- #include file="../../../_inclds/experiments/common/asp/getExperimentJSON.asp"-->

<!-- #include file="../../../_inclds/elementalMachines/html/showElementalMachinesTable.asp" -->
<script type="text/javascript">
	attachEdits(document.getElementById("elementalMachinesTable"))
</script>
<!-- #include file="../../../_inclds/experiments/common/asp/saveExperimentJSON.asp"-->