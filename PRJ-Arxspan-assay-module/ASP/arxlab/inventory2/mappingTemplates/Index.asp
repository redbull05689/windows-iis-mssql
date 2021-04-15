<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
titleData = "Arxspan Inventory"
isMappingTemplates = true
%>
<% If session("invRoleName") <> "Admin" Then %>
	response.end
<% End If %>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header.asp"-->

<div class="mappingTemplatesManagementPage">
	<h1>Mapping Templates</h1>
	<div id="mappingTemplatesHolder">
		<table class="mappingTemplatesTable">
			<thead>
				<tr>
					<th>Template Name</th>
					<th>Source Type</th>
					<th>Destination Type</th>
					<th>Category</th>
					<th>Created By</th>
					<th>Date Created</th>
					<th>Public</th>
					<th>Edit</th>
					<th>Remove</th>
				</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
</div>





<script type="text/javascript">
	function setFieldsFromSavedFieldMap(fieldMapElementId, fieldMapObject){
		$.each(fieldMapObject, function(destinationFieldName, sourceFieldName){
			$('#' + fieldMapElementId + ' .destinationFieldContainer[fieldname="'+destinationFieldName+'"] .sourceFieldsDropdown option[value="'+sourceFieldName+'"]').prop('selected',true);
		})
	}

	function populateFieldMapTemplatesTable(){
		window.mappingTemplates = restCall("/fetchAllMappingTemplates/","POST",{"connectionId":connectionId})["templates"]
		mappingTemplatesTableHTML = ""
		$.each(window.mappingTemplates, function(index, mappingTemplate){
			mappingTemplatesTableRowHTML = "<tr>";
			mappingTemplatesTableRowHTML += '<td>' + mappingTemplate['mappingTemplateName'] + '</td>';
			mappingTemplatesTableRowHTML += '<td>' + mappingTemplate['sourceType'] + '</td>';
			mappingTemplatesTableRowHTML += '<td>' + mappingTemplate['destinationType'] + '</td>';
			mappingTemplatesTableRowHTML += '<td>' + mappingTemplate['category'] + '</td>';
			mappingTemplatesTableRowHTML += '<td>' + mappingTemplate['creatorName'] + '</td>';
			mappingTemplatesTableRowHTML += '<td>' + moment(mappingTemplate['dateCreated']['$date']).format("M/D/YY") + '</td>';
			var templateIsPublicChecked = ""
			if(mappingTemplate['isPublic'] == true){
				templateIsPublicChecked = " checked";
			}
			mappingTemplatesTableRowHTML += '<td><input type="checkbox" class="templateIsPublicCheckboxInTable" name="templateIsPublicCheckboxInTable_' + mappingTemplate['_id']['$oid'] + '" id="templateIsPublicCheckboxInTable_' + mappingTemplate['_id']['$oid'] + '" templateid="' + mappingTemplate['_id']['$oid'] + '"' + templateIsPublicChecked + '></td>'
			mappingTemplatesTableRowHTML += '<td>' + '<div class="editButton" templateid="' + mappingTemplate['_id']['$oid'] + '" templateindex="'+index+'"></div>' + '</td>';
			mappingTemplatesTableRowHTML += '<td>' + '<div class="removeButton" templateid="' + mappingTemplate['_id']['$oid'] + '" templateindex="'+index+'"></div>' + '</td>';
			mappingTemplatesTableRowHTML += '</tr>';
			mappingTemplatesTableHTML += mappingTemplatesTableRowHTML;
		});
		if(mappingTemplatesTableHTML == ""){
			mappingTemplatesTableHTML = '<tr><td colspan="8">You don\'t have access to modify any saved mapping templates.</td></tr>'
		}
		$('.mappingTemplatesTable tbody').html(mappingTemplatesTableHTML);
	}

	$(document).ready(function(){
		populateFieldMapTemplatesTable();

		$('body').on('click','.editButton',function(event){
			window.mostRecentActiveTemplate = window.mappingTemplates[$(this).attr('templateindex')];
			blackOn();
			popup = newPopup("editMappingTemplatePopup");
			$(popup).append('<div class="mappingDestinationDropdownContainer"><select name="mappingDestinationDropdown" id="mappingDestinationDropdown" class="mappingDestinationDropdown"></select></div><div class="mappingSourceDropdownContainer"><select name="mappingSourceDropdown" id="mappingSourceDropdown" class="mappingSourceDropdown"></select></div><div class="fieldMappingDiv" id="fieldMappingDiv"></div><div class="editMappingTemplatePopupBottomSection"><div class="sampleMapTemplateNameTextboxContainer"><input type="text" class="sampleMapTemplateNameTextbox" placeholder="Mapping template name (Required)"></div><input type="checkbox" name="mappingTemplate_isPublic" id="mappingTemplate_isPublic" class="css-checkbox"><label for="mappingTemplate_isPublic" class="css-label checkboxLabel mappingTemplate_isPublic_label">Make Public</label><button class="saveChangesButton">Save Changes</button></div>').appendTo('body')
			initMappingInterface("",window.mostRecentActiveTemplate['sourceType'],window.mostRecentActiveTemplate['destinationType'],window.mostRecentActiveTemplate['category'],false,true)
			// Fill in parts of the popup for this template ID
			$('.sampleMapTemplateNameTextbox').val(window.mostRecentActiveTemplate['mappingTemplateName'])
			$('#mappingTemplate_isPublic').prop('checked',window.mostRecentActiveTemplate['isPublic'])
			// Populate the source & destination type dropdowns, then select the initial source & destination types
			typesDropdownHTML = ""
			$.each(window.allCustomTypesResponse['allCustomTypes'], function(key, customType){
				typesDropdownHTML += '<option value="' + customType['name'].replace(/"/g, "'") + '">' + customType['name'] + '</option>';
			});
			if(window.mostRecentActiveTemplate['category'] == "bulkImport_bulkUpdate"){
				$('#mappingSourceDropdown').append('<option value="'+window.mostRecentActiveTemplate['sourceType'].replace(/"/g, "'")+'">-- Uploaded File\'s Columns --</option>')
			}
			else{
				$('#mappingSourceDropdown').append(typesDropdownHTML)
			}
			$('#mappingDestinationDropdown').append(typesDropdownHTML)
			$('#mappingSourceDropdown option[value="' + window.mostRecentActiveTemplate['sourceType'].replace(/"/g, "'") + '"]').prop('selected',true);
			$('#mappingDestinationDropdown option[value="' + window.mostRecentActiveTemplate['destinationType'].replace(/"/g, "'") + '"]').prop('selected',true);
			setFieldsFromSavedFieldMap("fieldMappingDiv",window.mostRecentActiveTemplate['fieldMap'])
		});

		$('body').on('change','.mappingSourceDropdown, .mappingDestinationDropdown',function(event){
			initMappingInterface("",$('.mappingSourceDropdown').val(),$('.mappingDestinationDropdown').val(),window.mostRecentActiveTemplate['category'],false,true)
		});

		$('body').on('change','.templateIsPublicCheckboxInTable',function(event){
			mappingTemplateId = $(this).attr('templateid');
			checkedOrUnchecked = $(this).prop('checked');
			r = restCall("/updateMappingTemplate/","POST",{"mappingTemplateId": mappingTemplateId, "isPublic": checkedOrUnchecked})
		});

		$('body').on('click','.saveChangesButton',function(event){
			$('#editMappingTemplatePopup').remove();
			blackOff();
			// User wants to save the template - do that here 
			var mappingTemplateName = $('.sampleMapTemplateNameTextbox').val();
			var sourceType = $('.mappingSourceDropdown').val()
			var destinationType = $('.mappingDestinationDropdown').val()
			var fieldMap = makeFieldNamePairsFromMap('fieldMappingDiv')
			var isPublic = $('#mappingTemplate_isPublic').prop('checked')

			r = restCall("/updateMappingTemplate/","POST",{"mappingTemplateId": window.mostRecentActiveTemplate['_id']['$oid'], "mappingTemplateName": mappingTemplateName, "sourceType": sourceType, "destinationType": destinationType, "fieldMap": fieldMap, "isPublic": isPublic})
			populateFieldMapTemplatesTable(); // Refresh the big table of templates
		});

		$('body').on('click','.removeButton',function(event){
			var templateId = $(this).attr('templateid')
			window.mostRecentActiveTemplate = window.mappingTemplates[$(this).attr('templateindex')];
			swal({
				title: "Are you sure?",
				text: 'You are about to delete the mapping template "'+window.mostRecentActiveTemplate['mappingTemplateName']+'".',
				type: "warning",
				showCancelButton: true,
				confirmButtonColor: "#DD6B55",
				confirmButtonText: "Delete",
				closeOnConfirm: false
			},
			function(){
				r = restCall("/deleteMappingTemplate/","POST",{"mappingTemplateId": window.mostRecentActiveTemplate['_id']['$oid']})
				if(r['result'] == "success"){
					swal("Successfully Deleted", "The mapping template has been deleted.", "success");
					populateFieldMapTemplatesTable(); // Refresh the big table of templates
				}
				else{
					swal("Error Deleting Template", r['errorText'], "error")
				}
			});


				
		});

		window.allCustomTypesResponse = restCall("/getAllCustomTypes/","POST",{})
	});

</script>


<!-- #include file="../_inclds/footer.asp"-->