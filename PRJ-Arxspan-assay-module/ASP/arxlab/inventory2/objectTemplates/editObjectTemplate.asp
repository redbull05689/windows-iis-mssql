<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
titleData = "Arxspan Inventory"
isObjectTemplates = true
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header.asp"-->
<%If session("invRoleName") = "Admin" Then%>
<style type="text/css">
	.fieldDiv{
		background-color:white;
		margin-bottom:10px;
		position:relative;
	}
	.fieldDiv div{
		float:left;
		padding-left:6px;
	}
	.optionsDiv{
		overflow-y:visible;
		height:180px;
		width:454px;
	}
	.holderDiv{
		display:block;
		float:none!important;
	}
	.closeLink{
		position:absolute;
		top:0;
		right:0;
	}
    option.avatar {
      background-repeat: no-repeat !important;
      padding-left: 20px;
    }
    .avatar .ui-icon {
      background-position: left top;
    }
</style>
<link rel="stylesheet" href="/arxlab/css/inventoryObjectManagement.css?<%=jsRev%>">
<div id="arxOneContainer">
<div id="inventoryObjectManagementPage">
<h1 class="editObjectType">Edit Object Type</h1>

<label class="ax1-text-label" for="objectName">* Name</label><input type="text" name="objectName" id="objectName" class="ax1-text">
<label class="ax1-text-label" for="icon">* Icon</label>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="flask.gif"><img src="images/treeIcons/flask.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="check.gif"><img src="images/treeIcons/check.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="checkedout.gif"><img src="images/treeIcons/checkedout.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="cylinder.gif"><img src="images/treeIcons/cylinder.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="disposed.gif"><img src="images/treeIcons/disposed.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="door.gif"><img src="images/treeIcons/door.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="freezer.gif"><img src="images/treeIcons/freezer.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="hierarchy.gif"><img src="images/treeIcons/hierarchy.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="lab.gif"><img src="images/treeIcons/lab.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="lock.gif"><img src="images/treeIcons/lock.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="plate.gif"><img src="images/treeIcons/plate.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="rack.gif"><img src="images/treeIcons/rack.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="mouse.gif"><img src="images/treeIcons/mouse.gif"></div>
<div class="objectIconRadioButtonContainer"><input type="radio" name="icon" value="cage.gif"><img src="images/treeIcons/cage.gif"></div>
<br />
<div class="objectSettingsCheckboxesContainer">
	<label class="ax1-text-label">Misc. Options</label>
	<div class="objectSettingsCheckboxes">
		<input type="checkbox" class="css-checkbox" id="active" name="active" CHECKED><label for="active" class="checkboxLabel css-label objectSettingsCheckbox">Active</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="hasStructure" name="hasStructure"><label for="hasStructure" class="checkboxLabel css-label objectSettingsCheckbox">Display Structure</label>
		<br />
<!--
		<input type="checkbox" class="css-checkbox" id="canAdd" name="canAdd"><label for="canAdd" class="checkboxLabel css-label objectSettingsCheckbox">Can Add Children</label>
		<br />
-->
		<input type="checkbox" class="css-checkbox" id="canSample" name="canSample"><label for="canSample" class="checkboxLabel css-label objectSettingsCheckbox">Allow Sampling (requires an 'Amount' and 'Units' field)</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canEdit" name="canEdit"><label for="canEdit" class="checkboxLabel css-label objectSettingsCheckbox">Allow Editing</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canUse" name="canUse"><label for="canUse" class="checkboxLabel css-label objectSettingsCheckbox">Allow amount decrementing (requires an 'Amount' and 'Units' field)</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canMove" name="canMove"><label for="canMove" class="checkboxLabel css-label objectSettingsCheckbox">Allow moving</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canCheck" name="canCheck"><label for="canCheck" class="checkboxLabel css-label objectSettingsCheckbox">Allow checking in and out</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canDispose" name="canDispose"><label for="canDispose" class="checkboxLabel css-label objectSettingsCheckbox">Allow disposing</label>
		<br />
<!--	
		<input type="checkbox" class="css-checkbox" id="canImport" name="canImport"><label for="canImport" class="checkboxLabel css-label objectSettingsCheckbox">Can Import (into object from the context menu)</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="showTable" name="showTable"><label for="showTable" class="checkboxLabel css-label objectSettingsCheckbox">Show as table when selected in tree</label>
		<br />
-->
		<input type="checkbox" class="css-checkbox" id="restrictAccess" name="restrictAccess"><label for="restrictAccess" class="checkboxLabel css-label objectSettingsCheckbox">Restrict Access</label>
	</div>
</div>
<div class="objectAllowedGroupsUsersContainer">
	<label class="x1-text-label">Users &amp; User Groups</label>
	<div class="objectAllowedGroupsUsers"></div>
</div>
<input type="hidden" id="groupIds">
<input type="hidden" id="userIds">
<input type="hidden" id="allUserIds">
<input type="hidden" id="numUsers">
<input type="hidden" id="numGroups">


<div class="reorderFieldsButtonContainer"><button type="button" class="reorderFieldsButton">Reorder Fields</button></div>

<table id="objectFieldsTable" class="objectFieldsTable">
	<thead>
		<th>Name</th>
		<th>Basic</th>
		<th>Form Visibility</th>
		<th>Advanced</th>
		<th>Lookup</th>
		<th>Dropdown Options</th>
		<th></th>
	</thead>
	<tbody></tbody>
</table>
<div class="editTemplateBottomButtons">
	<div class="editTemplateBottomButtons_addField"><button type="button">Add Field</button></div>
	<div class="editTemplateBottomButtons_saveObject"><button type="button">Save Object Template</button></div>
</div>

<div class="objectFieldsTableTitle objectFieldsGroupingTableTitle">Field Groups</div>
<table id="objectFieldsGroupingTable" class="objectFieldsGroupingTable">
	<thead>
		<th>Field Group Name</th>
		<th># of Fields</th>
		<th></th>
	</thead>
	<tbody></tbody>
</table>
<div class="editTemplateFieldGroupsBottomButtons">
	<div class="editTemplateFieldGroupsBottomButtons_addGroup"><button type="button">Add Group</button></div>
</div>

<div class="objectFieldsTableTitle objectFieldsLabelPrintingSettingsTableTitle">Label Printing Settings</div>
<div class="labelPrintingSettingsLayoutDropdownContainer">
	<label id="objectFieldsLabelPrintingSettingsStatus" class="">Label Layout has not been setup</label>
	<div class="select-style select-style-medium-long" style="display: none;">
		<select name="labelPrintingSettingsLayoutDropdown" id="labelPrintingSettingsLayoutDropdown"></select>
	</div>
	<hr class="labelPrintingSettingsLayout">
</div>
<table id="objectFieldsLabelPrintingSettingsTable" class="objectFieldsLabelPrintingSettingsTable" style="display: none;">
	<thead>
		<th>Line Number</th>
		<th>Display Name</th>
		<th>Field to Use</th>
		<th>Second Field</th>
	</thead>
	<tbody></tbody>
</table>
<div class="objectFieldsLabelPrintingSettingsBottomButtons">
	<div class="objectFieldsLabelPrintingSettingsBottomButtons_saveObjectTemplate"><button type="button">Save Object Template</button></div>
</div>
</div>
</div>

<script type="text/javascript" src="js/objectTemplateManagement.js"></script>
<script type="text/javascript">
	function saveObject(){
		// check required fields
		if (!$("#objectName").val() || $("#objectName").val().length < 1) {
			alert("Name is a required field");
			return;
		}

		if (!$('input[name=icon]:checked').val()) {
			alert("Icon is a required field");
			return;
		}

		var badRows = [];

		var using = false;
		var sampling = false;
		var haveAmount = false;
		var haveAmountUnits = false;
		
		if ($('input[name=canSample]:checked').val()) {
			sampling = true;
		}

		if ($('input[name=canUse]:checked').val()) {
			using = true;
		}

		$('#objectFieldsTable .baseRow').each(function(i,el){
			var baseRowId = $(this).attr('baserowid');
			var theName = $('[baserowid="'+baseRowId+'"] [jsonField=fieldName]').val();
			
			if (theName == "") {
				badRows.push(""+(i+1));
			}

			if ($('[baserowid=field_'+i+"] [jsonField=isAmountField]").prop("checked")) {
				haveAmount = true;
			}

			if ($('[baserowid=field_'+i+"] [jsonField=isAmountUnitField]").prop("checked")) {
				haveAmountUnits = true;
			}

		});

		if (badRows.length > 0) {
			rowStr = "";
			for (var i = 0; i < badRows.length; i++) {
				rowStr += badRows[i];
				
				if (i < badRows.length - 1) {
					rowStr += ", ";
				}
			}
			
			alert("Please enter a name for fields on rows: " + rowStr);
			return;
		}
		
		if (sampling && (!haveAmount || !haveAmountUnits)) {
			alert("Allow sampling option set, please create fields for Amount and Amount Units");
			return;
		}

		if (using && (!haveAmount || !haveAmountUnits)) {
			alert("Allow amount decrementing option set, please create fields for Amount and Amount Units");
			return;
		}

		setGroups_v2();
		objectName = $("#objectName").val();
		pl = {}
		pl["object"] = makeJSON();
		<%if request.querystring("id") <> "" then%>
			pl["id"] = <%=request.querystring("id")%>
		<%end if%>
		r = restCall("/addEditObjectType/","POST",pl);
		window.location = "objectTemplates/index.asp";
	}

	$(document).ready(function() {
		// Load the common pool of dropdowns, set it as a JSON object, and make HTML for the dropdown of common dropdowns
		window.commonPoolOfDropdowns = restCall("/getPoolOfDropdowns/","POST",{"onlyActive":true});
		window.commonPoolOfDropdowns_dropdownHTML = commonPoolOfDropdowns_makeDropdownHTML(window.commonPoolOfDropdowns['dropdowns']);
		
		//window.labelPrinting_layouts = [{"id":"ovjdj0j039vj230fje","layoutName":"Simple printing layout","lineCount":5},{"id":"vmimiosdmfemvem093","layoutName":"OneLine printing layout","lineCount":5},{"id":"osjvoij03j320jc230fe","layoutName":"LotsOfLines printing layout","lineCount":12}]
		//loadLabelPrintingLayoutList(window.labelPrinting_layouts);
		
		<%If request.querystring("id") <> "" then%>
		r = restCall("/getObject/","POST",{"id":<%=request.querystring("id")%>});
		window.mostRecentSavedObjectData = r;
		if(typeof window.mostRecentSavedObjectData['fieldGroups'] == "undefined"){
			window.mostRecentSavedObjectData['fieldGroups'] = []
		}
		window.fieldGroupsObject = window.mostRecentSavedObjectData['fieldGroups'];
		//Get the label printing layout details from the backend
		//INV-313
		if(window.mostRecentSavedObjectData.hasOwnProperty('labelPrintingSettings')){
			layoutObj = window.mostRecentSavedObjectData['labelPrintingSettings'];
			if(layoutObj.hasOwnProperty('labelLayoutId') && layoutObj.hasOwnProperty('layoutName') &&  layoutObj.hasOwnProperty('lineCount')){
				window.labelPrinting_layouts = [{"id":layoutObj['labelLayoutId'],"layoutName":layoutObj['layoutName'],"lineCount":layoutObj['lineCount']}];
				loadLabelPrintingLayoutList(window.labelPrinting_layouts);
			}
		}
		showGroupPopup();
		loadJSON(r);
		<% else %>
		window.fieldGroupsObject = [];
		populateObjectFieldsGroupingTable();
		<%End If%>
	});
</script>
<%End if%>
<!-- #include file="../_inclds/footer.asp"-->