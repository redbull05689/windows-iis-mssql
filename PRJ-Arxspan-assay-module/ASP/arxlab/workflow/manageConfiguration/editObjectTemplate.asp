<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isObjectTemplates = true
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header.asp"-->
<% If showAdminPages() Then %>
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
<link rel="stylesheet" href="/arxlab/css/workflowConfiugrationManagement.css?<%=jsRev%>">
<h1 class="editObjectType">Edit Object Type</h1>

<label class="ax1-text-label" for="objectName">Name *</label><input type="text" name="objectName" id="objectName" class="ax1-text">
<label class="ax1-text-label" for="icon">Icon *</label>
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
		<input type="checkbox" class="css-checkbox" id="active" name="active" checked><label for="active" class="checkboxLabel css-label objectSettingsCheckbox">Active</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="hasStructure" name="hasStructure"><label for="hasStructure" class="checkboxLabel css-label objectSettingsCheckbox">Has Structure</label>
		<br />
		<!-- <input type="checkbox" class="css-checkbox" id="canAdd" name="canAdd"><label for="canAdd" class="checkboxLabel css-label objectSettingsCheckbox">Can Add Children</label>
		<br /> -->
		<input type="checkbox" class="css-checkbox" id="canSample" name="canSample"><label for="canSample" class="checkboxLabel css-label objectSettingsCheckbox">Can Sample (must have amount and units fields)</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canEdit" name="canEdit"><label for="canEdit" class="checkboxLabel css-label objectSettingsCheckbox">Can Edit</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canUse" name="canUse"><label for="canUse" class="checkboxLabel css-label objectSettingsCheckbox">Can Use (must have amount and units fields)</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canMove" name="canMove"><label for="canMove" class="checkboxLabel css-label objectSettingsCheckbox">Can Move</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canCheck" name="canCheck"><label for="canCheck" class="checkboxLabel css-label objectSettingsCheckbox">Can Check In/Out</label>
		<br />
		<input type="checkbox" class="css-checkbox" id="canDispose" name="canDispose"><label for="canDispose" class="checkboxLabel css-label objectSettingsCheckbox">Can Dispose</label>
		<br />
		<!-- <input type="checkbox" class="css-checkbox" id="canImport" name="canImport"><label for="canImport" class="checkboxLabel css-label objectSettingsCheckbox">Can Import (into object from the context menu)</label>
		<br /> 
		<input type="checkbox" class="css-checkbox" id="showTable" name="showTable"><label for="showTable" class="checkboxLabel css-label objectSettingsCheckbox">Show as table when selected in tree</label>
		<br /> -->
		<input type="checkbox" class="css-checkbox" id="restrictAccess" name="restrictAccess"><label for="restrictAccess" class="checkboxLabel css-label objectSettingsCheckbox">Restrict Access (Select Users & User groups)</label>
	</div>
</div>
<div class="objectAllowedGroupsUsersContainer">
	<label class="ax1-text-label">Users &amp; User Groups</label>
	<div class="objectAllowedGroupsUsers"></div>
</div>
<input type="hidden" id="groupIds">
<input type="hidden" id="userIds">
<input type="hidden" id="allUserIds">
<input type="hidden" id="numUsers">
<input type="hidden" id="numGroups">


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

<div class="reorderFieldsButtonContainer"><button type="button" class="reorderFieldsButton">Reorder Fields</button></div>

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
	<label class="">Label Layout</label>
	<div class="select-style select-style-medium-long">
		<select name="labelPrintingSettingsLayoutDropdown" id="labelPrintingSettingsLayoutDropdown"></select>
	</div>
	<hr class="labelPrintingSettingsLayout">
</div>
<table id="objectFieldsLabelPrintingSettingsTable" class="objectFieldsLabelPrintingSettingsTable">
	<thead>
		<th>Line Number</th>
		<th>Field to Use</th>
	</thead>
	<tbody></tbody>
</table>
<div class="objectFieldsLabelPrintingSettingsBottomButtons">
	<div class="objectFieldsLabelPrintingSettingsBottomButtons_saveObjectTemplate"><button type="button">Save Object Template</button></div>
</div>

<script type="text/javascript" src="js/objectTemplateManagement.js?<%=jsRev%>"></script>
<script type="text/javascript">
	function saveObject(){
		setGroups_v2();
		objectName = $("#objectName").val();
		icon = $("input[name=icon]:checked").val();
		
		if (objectName != "" && icon != "" && (typeof icon != 'undefined')) {
			pl = {}
			pl["object"] = makeJSON();
			fieldsObj = pl["object"]["fields"];
			fieldObjectIsNameField = false;
			var countErr = 0;
			
			<%if request.querystring("id") <> "" then%>
				pl["id"] = <%=request.querystring("id")%>
			<%end if%>
			
			for(i=0; i<fieldsObj.length; i++){
				obj = fieldsObj[i];
				//Check if atleast one field is selected as isNameField
				if(obj["isNameField"] == true){
					fieldObjectIsNameField = obj["isNameField"];
				}
			}
			
			if (!fieldObjectIsNameField){
				swal("","Please select atleast one field as name field", "error")
			}
			
			for(i=0; i<fieldsObj.length; i++){
				obj = fieldsObj[i];
				//Check if the dropdown type field has atleast one option
				if(obj["formType"] == "select"){
					var count = 0;
					for (prop in obj["optionIds"]) {
						count++;
					}
					if(count == 0){
						countErr++;
						swal("","Please select Dropdown options for field name "+ obj["fieldName"], "error")
					}
				}
			}
			console.log("countErr :: "+ countErr)
			if (fieldObjectIsNameField == true && countErr == 0){
				r = restCall("/addEditObjectType/","POST",pl);
				window.location = "manageConfiguration/index.asp";
			}
		}
		else if (objectName == "" && (icon == "" || (typeof icon == 'undefined'))){
			swal("","Please enter a valid Object Name and select an Icon for the template", "error")
		}
		else if(objectName == "" && (icon != "" || (typeof icon != 'undefined'))){
			swal("","Please enter a valid Object Name for the template", "error")
		}
		else if(objectName != "" && (icon == "" || (typeof icon == 'undefined'))){
			swal("","Please select an Icon for the template", "error")
		}
	}

	$(document).ready(function() {
		// Load the common pool of dropdowns, set it as a JSON object, and make HTML for the dropdown of common dropdowns
		window.commonPoolOfDropdowns = restCall("/getPoolOfDropdowns/","POST",{"onlyActive":true});
		window.commonPoolOfDropdowns_dropdownHTML = commonPoolOfDropdowns_makeDropdownHTML(window.commonPoolOfDropdowns['dropdowns']);
		
		window.labelPrinting_layouts = [{"id":"ovjdj0j039vj230fje","layoutName":"Simple printing layout","lineCount":5},{"id":"vmimiosdmfemvem093","layoutName":"OneLine printing layout","lineCount":5},{"id":"osjvoij03j320jc230fe","layoutName":"LotsOfLines printing layout","lineCount":12}]
		loadLabelPrintingLayoutList(window.labelPrinting_layouts);
		<%If request.querystring("id") <> "" then%>
		r = restCall("/getObject/","POST",{"id":<%=request.querystring("id")%>});
		window.mostRecentSavedObjectData = r;
		if(typeof window.mostRecentSavedObjectData['fieldGroups'] == "undefined"){
			window.mostRecentSavedObjectData['fieldGroups'] = []
		}
		window.fieldGroupsObject = window.mostRecentSavedObjectData['fieldGroups'];
		loadJSON(r);
		<% else %>
		window.fieldGroupsObject = [];
		populateObjectFieldsGroupingTable();
		<%End If%>
		showGroupPopup();
	});
</script>
<%End if%>
<!-- #include file="../_inclds/footer.asp"-->