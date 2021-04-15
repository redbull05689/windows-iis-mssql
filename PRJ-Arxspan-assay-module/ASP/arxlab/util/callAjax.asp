<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "error"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
	sectionID = "tool"
	subSectionID="error"
	terSectionID=""

	pageTitle = "Arxspan Error"
	metaD=""
	metaKey=""

%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<%If session("email")="support@arxspan.com" then%>
<script type="text/javascript">
counter = 0
var checkNewVersionSack = new sack();
	function checkNewVersion()
	{
		a = getFile("<%=mainAppPath%>/ajax_checkers/experimentNewerVersion.asp?id="+document.getElementById("experimentId").value+"&experimentType="+document.getElementById("experimentType").value+"&revisionNumber="+document.getElementById("thisRevisionNumber").value+"&random="+Math.random())
		counter += 1;
		document.getElementById("test").value += counter + " " + a + "\n";
	}

	checkNewVersionInterval = setInterval('checkNewVersion()',1)
</script>
<textarea id="test"></textarea>
<input type="hidden" id="experimentId" value="31112">
<input type="hidden" id="experimentType" value="1">
<input type="hidden" id="thisRevisionNumber" value="1">
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->