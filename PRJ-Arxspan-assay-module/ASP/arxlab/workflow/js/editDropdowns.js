
var dropDownConfigModule = (function() {

    var populateDropdownsTable = function() {
        var datatable = $('#dropdownsTable').DataTable({

            'language':{ 
                "loadingRecords": "",
                "zeroRecords": "",
                "emptyTable": "",
                "processing": "<div class='blueLoadingSpinner'></div><br>Loading...",
             },

            processing: true,
            ajax: function(data,callback,settings){
                var dropdownParams = {
                    isConfigPage: true,
                    appName: "Configuration"
                };
        
                ajaxModule().getDropdowns(dropdownParams).then(function (response) {
                    response = utilities().decodeServiceResponce(response);
                    console.log("success");
                    console.log(response);
            
                    if (typeof response !== "undefined") {
                        window.dropdownsArray = response;
                        var rows = [];
                        $.each(response, function (index, dropdown) {
                            var datarow = [];
                            datarow.push(dropdown["displayName"]);
                            datarow.push(dropdown["hoverText"]);
            
                            var optionNamesArray = dropdown['options'].map(x => x.displayName);
                            datarow.push(optionNamesArray.join(", "));
            
                            var dropdownDisabled = dropdown["disabled"] ? "Disabled" : "Enabled";
                            datarow.push(dropdownDisabled);
            
                            //var addedRow = datatable.row.add(datarow).node();
                            //$(addedRow).attr("dropdownid", dropdown['id']);
                            datarow.push(dropdown["id"]);
                            rows.push(datarow);
                        });
            
                        callback(rows);
                    }
                });
                settings.sAjaxDataProp = '';
            },



        });
        
    }

    var populateDropdownOptionMaskUserGroupsTable = function(){
        if (window.groupsList) {
            var dropdownMaskUserGroupsTableRows = [];
            var optionMasksTableRows = [];
            $.each(window.groupsList, function (groupIndex, thisGroup) {
                // Mask user groups table rows
                var tableRow = $('<tr>').attr('groupid', thisGroup['id']).attr('groupindex', groupIndex);
                tableRow.append($('<td>').append($('<div>').text(thisGroup['name']).addClass('groupNameContainer')));
                tableRow.append($('<td>').append('<input type="checkbox" class="maskingEnabled">'));
                tableRow.append($('<td>').append('<button class="basicActionButton viewMaskValuesForGroupTableButton">View</button>'));
                dropdownMaskUserGroupsTableRows.push(tableRow);
    
                // Mask value input table rows
                var tableRow = $('<tr>').attr('groupid', thisGroup['id']).attr('groupindex', groupIndex);
                tableRow.append($('<td>').append($('<div>').text(thisGroup['name']).addClass('groupNameContainer')));
                tableRow.append($('<td>').append('<input type="text" class="maskValueInput">'));
                optionMasksTableRows.push(tableRow);
            });
    
            $('.dropdownEditorContainer #dropdownMaskUserGroupsTable > tbody').append(dropdownMaskUserGroupsTableRows);
            $('.dropdownEditorContainer #dropdownMaskUserGroupsTable > tbody').mCustomScrollbar({
                theme: "light-3",
                scrollButtons: {
                    enable: false
                },
                mouseWheel: {
                    preventDefault: true
                },
                scrollbarPosition: 'inside',
                autoExpandScrollbar: true,
                theme: 'dark',
                axis: "y",
                setWidth: "auto"
            });
    
            $('.dropdownEditorContainer #dropdownOptionMasksTable > tbody').append(optionMasksTableRows);
            $('.dropdownEditorContainer #dropdownOptionMasksTable > tbody').mCustomScrollbar({
                theme: "light-3",
                scrollButtons: {
                    enable: false
                },
                mouseWheel: {
                    preventDefault: true
                },
                scrollbarPosition: 'inside',
                autoExpandScrollbar: true,
                theme: 'dark',
                axis: "y",
                setWidth: "auto"
            });
        }
        else {
            setTimeout(populateDropdownOptionMaskUserGroupsTable.bind(null), 300);
        }
    }

    var editDropDownReady = function()
    {
        $('body').on('click', '.newDropdownButton', function (event) {
            //showDropdownEditor();
            ReactDOM.unmountComponentAtNode(document.getElementById("reactDropdownEditor"));
            ReactDOM.render(<DropdownEditorContainer dropDownId={null}></DropdownEditorContainer>, document.getElementById("reactDropdownEditor"));
        });
    
        $('body').on('click', '.dropdownEditorCancel', function (event) {
            ReactDOM.unmountComponentAtNode(document.getElementById("reactDropdownEditor"));
        });
    
        $('body').on('click', 'table#dropdownsTable tr td', function (event) {
            var dropdownId = $("#dropdownsTable").DataTable().row(this).data()[4]
            //showDropdownEditor(dropdownId);
            ReactDOM.unmountComponentAtNode(document.getElementById("reactDropdownEditor"));
            ReactDOM.render(<DropdownEditorContainer dropDownId={dropdownId}></DropdownEditorContainer>, document.getElementById("reactDropdownEditor"));
            $(".main-panel").animate({ scrollTop: 0  }, "medium");
        });
    
        populateDropdownsTable();
        populateDropdownOptionMaskUserGroupsTable();
    }

    return{
        editDropDownReady:editDropDownReady
    };


}) // end dropDownConfigModule 



$(document).ready(function () {
    dropDownConfigModule().editDropDownReady();
});