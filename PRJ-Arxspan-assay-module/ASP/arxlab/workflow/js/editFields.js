var editFields = (function () {

    var populateFieldsTable = function () {
        var datatable = $('#dropdownsTable').DataTable({
            'language':{ 
                "loadingRecords": "",
                "zeroRecords": "",
                "emptyTable": "",
                "processing": "<div class='blueLoadingSpinner'></div><br>Loading...",
             },

            processing: true,
            ajax: function(data,callback,settings){
                var fieldParams = {
                    isConfigPage: true,
                    appName: "Configuration"
                }
        
                ajaxModule().getFields(fieldParams).then(function (response) {
                    response = utilities().decodeServiceResponce(response);
                    if (typeof response !== "undefined") {
                        var rows = [];
                        window.fieldsArray = response;
                        $.each(response, function (index, field) {
                            var rowdata = [];
                            
                            rowdata.push(field['displayName']);
                            rowdata.push(field['hoverText']);
        
                            var thisDataType = window.dataTypesArray.find(x => x.id == field["dataTypeId"]);
                            var dataTypeName = thisDataType ? thisDataType["displayName"] : "";
                            rowdata.push(dataTypeName);
        
                            var fieldIsUnique = field["isUnique"] ? "True" : "False";
                            rowdata.push(fieldIsUnique);
        
                            var fieldUsesSalts = field['useSalts'] ? "True" : "False";
                            rowdata.push(fieldUsesSalts);
        
                            var fieldDisabled = field["disabled"] ? "Disabled" : "Enabled"
                            rowdata.push(fieldDisabled);
                            rowdata.push(field['id']);
                            
                            rows.push(rowdata);
                            /*var addedRow = datatable.row.add(rowdata).node();
                            $(addedRow).attr("fieldid", field['id']); */
                        });
                      
                        callback(rows);

                    }
                })
                settings.sAjaxDataProp = '';
            },

        });
        
       
    }

    var populateDataTypes = function () {
        $('select#dataTypeDropdown').empty();
        $.each(window.dataTypesArray, function (index, dataType) {
            var dataTypeOption = $('<option></option>').attr('value', dataType['id']).text(dataType['displayName'])
            $('select#dataTypeDropdown').append(dataTypeOption)
        });
        populateFieldsTable();
    }

    var populateSavedDropdownsListDropdown = function () {
        $('select#savedDropdownsListDropdown').empty();
        
        var dropdownParams = {
            isConfigPage: true,
            appName: "Configuration"
        };

        ajaxModule().getDropdowns(dropdownParams).then(function (response) {
            response = utilities().decodeServiceResponce(response);
            console.log("success");
            console.log(response)
            if (typeof response !== "undefined") {
                window.dropdownsArray = response;

                var savedDropdown = $('<option></option>').attr('value', "").text("-- Custom Dropdown --")
                $('select#savedDropdownsListDropdown').append(savedDropdown);

                $.each(response, function (index, dropdown) {
                    if (dropdown.disabled != 1) {
                        var savedDropdown = $('<option></option>').attr('value', index).attr('dropdownid', dropdown['id']).text(dropdown['displayName'])
                        $('select#savedDropdownsListDropdown').append(savedDropdown)
                    }
                });

                utilities().sortDropdownlist($('select#savedDropdownsListDropdown'));
            }
        });

    }

    var documentReadyFunction = function () {
        $('body').on('click', '.newDropdownButton', function (event) {
            ReactDOM.unmountComponentAtNode(document.getElementById("reactFieldEditor"));
            ReactDOM.render(<FieldEditorContainer dataTypeId={null} fieldId={null}></FieldEditorContainer>, document.getElementById("reactFieldEditor"));
        });

        $('body').on('click', 'table#dropdownsTable tr td', function (event) {
            ReactDOM.unmountComponentAtNode(document.getElementById("reactFieldEditor"));
            var fieldId = $("#dropdownsTable").DataTable().row(this).data()[6]
            var dataTypeId = fieldsArray.find(x => x.id == fieldId).dataTypeId;

            ReactDOM.render(<FieldEditorContainer dataTypeId={dataTypeId} fieldId={fieldId}></FieldEditorContainer>, document.getElementById("reactFieldEditor"));
            $(".main-panel").animate({ scrollTop: 0  }, "medium");
            //showFieldEditor(fieldId);
        });
        Promise.all(dtPromise).then(function(){
        populateDataTypes()
        populateSavedDropdownsListDropdown()
        });
    }

    return {
        documentReadyFunction: documentReadyFunction
    };
});

$(document).ready(function () {
    editFields().documentReadyFunction();
});