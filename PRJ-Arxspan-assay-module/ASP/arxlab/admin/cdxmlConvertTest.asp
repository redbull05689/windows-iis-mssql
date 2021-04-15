<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->

<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<%
if session("role") <> "Admin" Then
	response.redirect(mainAppPath&"/logout.asp")
End If

if session("email") = "support@arxspan.com" then
%>

<style>
    @import url("/arxlab/css/cdxml_convert.css");   
</style>
<script src="js/cdxmlConvert.js" charset="utf-8"></script>

<script>
    window.addEventListener("load", function () {
        const cConvert = cdxmlConvert("<%=getCompanySpecificSingleAppConfigSetting("cdxmlServiceEndpointUrl", session("companyId"))%>",
                                "<%=chemAxonRootUrl%>util/calculate/molExport");
        cConvert.prepare();

        $("#exportBtn").click(function() {cConvert.exportFile($("#fileType option:selected").text())});
    });   
</script>

<div id="drop-area">
    <form class="dropForm">
        <p>Upload multiple files with the file dialog or by dragging and dropping images onto the dashed region</p>
        <input type="file" id="fileElem" accept=".cdx,.cdxml"/>
        <label class="button" for="fileElem">Select some files</label>
    </form>
    <div id="fileExport" style="display:none;">
        <select id="fileType" hidden="hidden"></select>
        <button id="exportBtn" class="button">Export</button>
    </div>
</div>

<table class="container" style="display:none;">
    <tr id="gallery" class="row">
        <td id="cdxml2x" class="col-6">
        </td>
        <td id="jchem" class="col-6">
        </td>
    </tr>
</table>

<%
End If
%>
<!-- #include file="../_inclds/footer-tool.asp"-->
