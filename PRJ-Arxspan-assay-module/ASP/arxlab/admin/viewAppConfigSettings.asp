<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "tool"
subSectionId = "appConfigSettings"
pageTitle = "Arxspan App Config Settings"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="getAllConfigSettings.asp"-->

<%
If session("email") <> "support@arxspan.com" Then
	response.redirect(loginScriptName)
End if
%>

<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->

<script src="js/appConfigSettings.min.js" charset="utf-8"></script>
<link rel="stylesheet" type="text/css" href="viewAppConfigSettings.css?<%=jsRev%>">

<div id="settingsTableDiv">
    <h1>All Settings</h1>
    <span id="settingsToggle" class="toggleView">(Toggle View)</span>
</div>
<div id="cacheTableDiv">
    <h1>Cached Items</h1>
    <span id="cacheToggle" class="toggleView">(Toggle View)</span>
    
    <p>Column guide:</p>
    <p>Setting Name - The name of the setting.</p>
    <p>Key - The key used to retrieve this setting from the cache. Will take the form of an Admin Service URL.</p>
    <p>Value - The value of this setting in the cache.</p>
    <p>Date Set - The time this setting was added to the cache.</p>
</div>

<script>
    const appConfigSettings = <%=cfgSettings%>;
    const cacheList = [<%=cacheList%>];

    // Building this table in jQuery until we're ready to go with the React stuff.
    let settingsTable = appConfigSettingsModule().buildTable(appConfigSettings, ["Name", "Value", "Description"], ["Setting Name", "Value", "Description"]);
    $("#settingsTableDiv").append(settingsTable);
    let cacheTable = appConfigSettingsModule().buildTable(cacheList, ["Name", "Key", "Value", "DateSet"], ["Setting Name", "Key", "Value", "Date Set"])
    $("#cacheTableDiv").append(cacheTable);
    $("#cacheTableDiv").attr("hidden", true);

    /**
     * Helper function to switch which of the tables is displayed.
     * @param {string} elemToHide DOM id of the element to hide.
     * @param {string} elemToShow DOM id of the element to display.
     */
    function toggleView(elemToHide, elemToShow) {
        $("#" + elemToHide).attr("hidden", true);
        $("#" + elemToShow).attr("hidden", false);
    }

    $("#settingsToggle").on("click", function() {toggleView("settingsTableDiv", "cacheTableDiv")})
    $("#cacheToggle").on("click", function() {toggleView("cacheTableDiv", "settingsTableDiv")})

</script>
<!--#include file="../_inclds/footer-tool.asp"-->