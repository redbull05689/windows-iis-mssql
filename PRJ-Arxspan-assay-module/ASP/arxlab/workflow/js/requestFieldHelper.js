var requestFieldHelper = (function() {

    const EXP_SEARCH_URL = "/arxlab/ajax_loaders/fetchExperimentSearchTypeAhead.asp";
    const WRITABLE_EXP_SEARCH_URL = "/arxlab/ajax_loaders/fetchWritableExperimentSearchTypeAhead.asp";

    var NavToNotebook = function(ID){
        window.open("../show-notebook.asp?id=" + ID,' _blank')
    }

    var NavToProject = function(ID){
        window.open("../show-project.asp?id=" + ID,' _blank')
    }
   
    var NavToExperement = function(ID, index){
        if (index == "chem"){
            window.open("../experiment.asp?id=" + ID,' _blank')
        }
        else{
            window.open("../"+ String(index) +"-experiment.asp?id=" + ID,' _blank')
        }
        
    }

    /**
     * Clears the select2 field that keys to fieldId and hides the open and clear buttons.
     * @param {String} fieldId The fieldId of the field we want to clear.
     */
    var clearSelect2Field = function(fieldId) {
        var navLinkSelector = `.navigateLink[fieldId="${fieldId}"]`;
        var clearLinkSelector = `.clearLink[fieldId="${fieldId}"]`;
        $(navLinkSelector).hide();
        $(clearLinkSelector).hide();

        $(`input[fieldId="${fieldId}"]`).select2("data", {id: -1, text: ""});

        // Do this so we can call the jquery listeners for the changeObj and unsaved changes notification.
        $(`input[fieldId="${fieldId}"]`).change();
        $(`input[fieldId="${fieldId}"]`).keydown();
    }

    var initAllSealectFields = function(versionedRequestItems, versionedFields){
        
        // if we are adding in more fields, make sure that we do not show any unsaved changes notifications
        window.preventNotification = 1;

        if ($("input#searchForNotebook").length > 0)
        { 
            var notebookfields = $("input#searchForNotebook");
            $.each(notebookfields, function(i,obj)
            {
                initNotebookSearch(obj, versionedRequestItems, versionedFields);
            });
        
        }        

        if ($("input#searchForProject").length > 0)
        { 
            var Projectfields = $("input#searchForProject");
            $.each(Projectfields, function(i,obj)
            {
                initProjectSearch(obj, versionedRequestItems, versionedFields);
            });
        
        }       

        if ($("input#searchForExperement").length > 0)
        { 
            var Experementfields = $("input#searchForExperement");
            $.each(Experementfields, function(i,obj)
            {
                initExperementSearch(obj, EXP_SEARCH_URL, versionedRequestItems, versionedFields);
            });
        
        }
        
        initExperementSearch($("#workflowFileExperimentSearch"), WRITABLE_EXP_SEARCH_URL, versionedRequestItems, versionedFields);

        // re-enable change detection notification
        window.preventNotification = 0;        
    }

    var initNotebookSearch = function(Field, versionedRequestItems, versionedFields){
    
        var disabled = false;
        if($(Field).attr('autoGen') == "1")
        {
            disabled = true;
        }
        $('#overlay_select2Compatible').addClass('makeVisible');

        if($(Field).attr("initialized") != 'true')
        {

            elnSearchBox = $(Field).select2({
                formatSearching: null,
                selectOnBlur: false,
                minimumInputLength: 3,
                disabled: disabled,
                formatResult: function(object, container, query){
                    var contentHTML = "";
                    if(object['id'] == "specialResult_searchFor"){
                        // Ignore this - it's meant as a way to make a full search link at the top of the typeahead results
                    }
                    else{
                        contentHTML += '<div class="resultContent">'
                        resultNameHTML = object['name']
                        if(object['userExperimentName'] && object['userExperimentName'] !== "" && object['userExperimentName'] !== null){
                            resultNameHTML += " - " + object['userExperimentName'];
                        }
                        contentHTML += '<div class="resultNameRow"><div class="resultExperimentName">' + resultNameHTML + '</div></div>';
                        contentHTML += '<div class="resultDetailsRow">' + object['desc'] + '</div>';
                        contentHTML += '</div>'
                    }
                    return contentHTML
                },
                ajax: {
                    url: "/arxlab/ajax_loaders/fetchNotebookSearchTypeahead.asp",
                    dataType: 'html',
                    delay: 250,
                    method: "POST",
                    type: "POST",
                    contentType: "application/x-www-form-urlencoded",
                    data: function (params) {
                        return {
                            userInputValue: params
                        };
                    },
                    results: function (data, params) {
                        // parse the results into the format expected by Select2
                        var i = 0;
                        resultsArray = JSON.parse(data)
                        while(i < resultsArray.length){
                            resultsArray[i]['id'] = resultsArray[i]['id'];
                            resultsArray[i]['text'] = resultsArray[i]['name'];
                            i++
                        }
                        return {
                            results: resultsArray
                        };
                    },
                    cache: false
                },
                dropdownCssClass : 'elnSearchTypeaheadDropdown searchForNotebook',
                formatInputTooShort: function () {
                    return "Please enter at least 3 characters";
                },
                openOnEnter: false,
                placeholder: ""
            }).data('select2');

            // This is a hacky way to make the links in the results of the typeahead clickable. Select2 stops the click event when you click a link in the dropdown by default...
            elnSearchBox.onSelect = (function(fn) {
                return function(data, options) {
                    window.linkedExperimentInfo = data;
                    instantiateNotebookLink(Field, data["id"], data["text"]);
                    $(Field).select2('close');
                    if ($("td").has(Field).length > 0)
                    {
                        dataTableModule().updateRequestItemsTableDataAndRedraw($(Field), versionedRequestItems, versionedFields)
                    }
                }
            })(elnSearchBox.onSelect);
            $(Field).select2('data', {id: -1, text: ""})
            if ($(Field).children().length > 0)
            {
                var optionId = $($(Field).children()[0]).attr("id");
                var optionName = $($(Field).children()[0]).val();
                if (optionId != null)
                {
                    instantiateNotebookLink(Field, optionId, optionName);
                }
            }
            else if($(Field).siblings('option[fieldid =' + $(Field).attr('fieldid') + ']').length > 0)
            {
                var refrance =  $(Field).siblings('option[fieldid =' + $(Field).attr('fieldid') + ']');
                var optionId = $(refrance).attr("id");
                var optionName = $(refrance).val();
                $(Field).siblings('option[fieldid =' + $(Field).attr('fieldid') + ']').remove()
                instantiateNotebookLink(Field, optionId, optionName);
            }
            $(Field).attr("initialized", true); //This is to make sure we do not clear pre selected data by re initializeing 
        }
        console.log('Notebook');

    }

    var initProjectSearch =function(Field, versionedRequestItems, versionedFields){
    
        var disabled = false;
        if($(Field).attr('autoGen') == "1")
        {
            disabled = true;
        }
        $('#overlay_select2Compatible').addClass('makeVisible');
        
        if($(Field).attr("initialized") != 'true')
        {

            elnSearchBox = $(Field).select2({
                formatSearching: null,
                selectOnBlur: false,
                minimumInputLength: 3,
                disabled: disabled,
                formatResult: function(object, container, query){
                    var contentHTML = "";
                    if(object['id'] == "specialResult_searchFor"){
                        // Ignore this - it's meant as a way to make a full search link at the top of the typeahead results
                    }
                    else{
                        contentHTML += '<div class="resultContent">'
                        resultNameHTML = object['name']
                        if(object['userExperimentName'] && object['userExperimentName'] !== "" && object['userExperimentName'] !== null){
                            resultNameHTML += " - " + object['userExperimentName'];
                        }
                        contentHTML += '<div class="resultNameRow"><div class="resultExperimentName">' + resultNameHTML + '</div></div>';
                        contentHTML += '<div class="resultDetailsRow">' + object['desc'] + '</div>';
                        contentHTML += '</div>'
                    }
                    return contentHTML
                },
                ajax: {
                    url: "/arxlab/ajax_loaders/fetchProjectSearchTypeahead.asp",
                    dataType: 'html',
                    delay: 250,
                    method: "POST",
                    type: "POST",
                    contentType: "application/x-www-form-urlencoded",
                    data: function (params) {
                        return {
                            userInputValue: params
                        };
                    },
                    results: function (data, params) {
                        // parse the results into the format expected by Select2
                        var i = 0;
                        resultsArray = JSON.parse(data)
                        while(i < resultsArray.length){
                            resultsArray[i]['id'] = resultsArray[i]['id'];
                            resultsArray[i]['text'] = resultsArray[i]['name'];
                            i++
                        }
                        return {
                            results: resultsArray
                        };
                    },
                    cache: false
                },
                dropdownCssClass : 'elnSearchTypeaheadDropdown searchForNotebook',
                formatInputTooShort: function () {
                    return "Please enter at least 3 characters";
                },
                openOnEnter: false,
                placeholder: ""
            }).data('select2');

            // This is a hacky way to make the links in the results of the typeahead clickable. Select2 stops the click event when you click a link in the dropdown by default...
            elnSearchBox.onSelect = (function(fn) {
                return function(data, options) {
                    window.linkedExperimentInfo = data;
                    instantiateProjectLink(Field, data["id"], data["text"]);
                    $(Field).select2('close');
                    if ($("td").has(Field).length > 0)
                    {
                        dataTableModule().updateRequestItemsTableDataAndRedraw($(Field), versionedRequestItems, versionedFields)
                    }
                }
            })(elnSearchBox.onSelect);

            if ($(Field).children().length > 0)
            {
                var optionId = $($(Field).children()[0]).attr("id");
                var optionName = $($(Field).children()[0]).val();
                if (optionId != "null")
                {
                    instantiateProjectLink(Field, optionId, optionName);
                }
            }
            else if($(Field).siblings('option[fieldid =' + $(Field).attr('fieldid') + ']').length > 0)
            {
                var refrance =  $(Field).siblings('option[fieldid =' + $(Field).attr('fieldid') + ']');
                var optionId = $(refrance).attr("id");
                var optionName = $(refrance).val();
                $(Field).siblings('option[fieldid =' + $(Field).attr('fieldid') + ']').remove()
                instantiateProjectLink(Field, optionId, optionName);
            }
            $(Field).attr("initialized", true); //This is to make sure we do not clear pre selected data by re initializeing 
        }
        console.log('Project');

    }

    /**
     * Initializes the experiment search input as a Select2 input.
     * @param {*} Field The HTML field.
     * @param {string} searchUrl The experiment search endpoint to use.
     * @param {JSON[]} versionedRequestItems The list of request items for this request type.
     * @param {JSON[]} versionedFields The list of fields for this request type.
     */
    var initExperementSearch = function(Field, searchUrl, versionedRequestItems, versionedFields){
    
        var disabled = false;
        if($(Field).attr('autoGen') == "1")
        {
            disabled = true;
        }
        $('#overlay_select2Compatible').addClass('makeVisible');

        if($(Field).attr("initialized") != 'true')
        {

            elnSearchBox = $(Field).select2({
                formatSearching: null,
                selectOnBlur: false,
                minimumInputLength: 3,
                disabled: disabled,
                formatResult: function(object, container, query){
                    var contentHTML = "";
                    if(object['id'] == "specialResult_searchFor"){
                        // Ignore this - it's meant as a way to make a full search link at the top of the typeahead results
                    }
                    else{
                        contentHTML += '<div class="resultContent">'
                        resultNameHTML = object['text']
                        if(object['userExperimentName'] && object['userExperimentName'] !== "" && object['userExperimentName'] !== null){
                            resultNameHTML += " - " + object['userExperimentName'];
                        }
                        contentHTML += '<div class="resultNameRow"><div class="resultExperimentName">' + resultNameHTML + '</div></div>';
                        contentHTML += '<div class="resultDetailsRow">' + object['desc'] + '</div>';
                        contentHTML += '</div>'
                    }
                    return contentHTML
                },
                ajax: {
                    url: searchUrl,
                    dataType: "html",
                    delay: 250,
                    method: "POST",
                    type: "POST",
                    contentType: "application/x-www-form-urlencoded",
                    data: function (params) {
                        return {
                            userInputValue: params
                        };
                    },
                    results: function (data, params) {
                        // parse the results into the format expected by Select2
                        var i = 0;
                        resultsArray = JSON.parse(data);
                        while(i < resultsArray.length){
                            resultsArray[i]['id'] = parseInt(resultsArray[i]['legacyId']);
                            resultsArray[i]['text'] = resultsArray[i]["name"];
                            resultsArray[i]['desc'] = resultsArray[i]["userExperimentName"];
                            if (resultsArray[i]['experimentType'] == 1){
                                resultsArray[i]['index'] = "chem";
                            }
                            else if (resultsArray[i]['experimentType'] == 2){
                                resultsArray[i]['index'] = "bio";
                            }
                            else if (resultsArray[i]['experimentType'] == 3){
                                resultsArray[i]['index'] = "free";
                            }
                            else if (resultsArray[i]['experimentType'] == 4){
                                resultsArray[i]['index'] = "anal";
                            }
                            else if (resultsArray[i]['experimentType'] == 5){
                                resultsArray[i]['index'] = "cust";
                            }
                            i++
                        }
                        return {
                            results: resultsArray
                        };
                    },
                    cache: false
                },
                dropdownCssClass : 'elnSearchTypeaheadDropdown searchForNotebook',
                formatInputTooShort: function () {
                    return "Please enter at least 3 characters";
                },
                openOnEnter: false,
                placeholder: ""
            }).data('select2');

            // This is a hacky way to make the links in the results of the typeahead clickable. Select2 stops the click event when you click a link in the dropdown by default...
            elnSearchBox.onSelect = (function(fn) {
                return function(data, options) {
                    window.linkedExperimentInfo = data;
                    instantiateExpLink(Field, data["id"], data["text"], data["index"], data["userId"], data["experimentType"]);
                    instantiateClearLink($(Field).attr("fieldId"));
                    $(Field).select2('close');
                    if ($("td").has(Field).length > 0)
                    {
                        dataTableModule().updateRequestItemsTableDataAndRedraw($(Field), versionedRequestItems, versionedFields)
                    }
                }
            })(elnSearchBox.onSelect);

            if ($(Field).children().length > 0)
            {
                var optionData = JSON.parse($($(Field).children()[0]).val());
                if (optionData != null) {
                    optionData['id'] = $($(Field).children()[0]).attr("id");
                    if(optionData['id'] != 'null')
                    {
                        instantiateExpLink(Field, optionData["id"], optionData["text"], optionData["index"], optionData["owner"], optionData["experimentType"]);
                        instantiateClearLink($(Field).attr("fieldId"));
                    }
                }
            }
            else if($(Field).siblings('option[fieldid =' + $(Field).attr('fieldid') + ']').length > 0)
            {
                var refrance =  $(Field).siblings('option[fieldid =' + $(Field).attr('fieldid') + ']');
                var optionId = $(refrance).attr("id");
                var optionName = $(refrance).val();
                var optionindex = $(refrance).attr("index");
                var optionOwner = $(refrance).attr("owner");
                var optionType = $(refrance).attr("experimentType");
                $(Field).siblings('option[fieldid =' + $(Field).attr('fieldid') + ']').remove()
                instantiateExpLink(Field, optionId, optionName, optionindex, optionOwner, optionType);
                instantiateClearLink($(Field).attr("fieldId"));
            }

            $(Field).attr("initialized", true); //This is to make sure we do not clear pre selected data by re initializeing 
        }


        console.log('experiment');

    }

    /**
     * Instantiates a select2 data link.
     * @param {*} field The JQuery-selected input field.
     * @param {*} linkData The data to store in the select2 field.
     * @param {String} navFncStr The onclick function to store as an onClick.
     */
    var instantiateLink = function(field, linkData, navFncStr) {
        $(field).select2("data", linkData).trigger("change");
        var navLinkSelector = `.navigateLink[fieldId="${$(field).attr("fieldId")}"]`;
        $(navLinkSelector).show();
        $(navLinkSelector).attr('onClick', navFncStr);
    }

    /**
     * Instantiates a notebook link.
     * @param {*} field The JQuery-selected input field.
     * @param {*} id The ID of the notebook.
     * @param {*} text The notebook name.
     */
    var instantiateNotebookLink = function(field, id, text) {
        var linkData = {
            "id": id,
            "text": text
        };
        var navFncStr = `requestFieldHelper().NavToNotebook("${String(id)}");`;

        instantiateLink(field, linkData, navFncStr);
    }

    /**
     * Instantiates a project link.
     * @param {*} field The JQuery-selected input field.
     * @param {*} id The ID of the project.
     * @param {*} text The project name.
     */
    var instantiateProjectLink = function(field, id, text) {
        var linkData = {
            "id": id,
            "text": text
        };
        var navFncStr = `requestFieldHelper().NavToProject("${String(id)}");`;

        instantiateLink(field, linkData, navFncStr);
    }

    /**
     * Instantiates a experiment link.
     * @param {*} field The JQuery-selected input field.
     * @param {*} id The ID of the experiment.
     * @param {String} text The experiment name.
     * @param {String} index The experiment index.
     * @param {number} userId The experiment owner's ID.
     * @param {number} experimentType The experiment type ID.
     */
    var instantiateExpLink = function(field, id, text, index, userId, experimentType) {
        var linkData = {
            "id": id,
            "text": text,
            "index": index,
            "owner": userId,
            "type": experimentType
        };
        var navFncStr = `requestFieldHelper().NavToExperement('${String(id)}', '${String(index)}')`;
        instantiateLink(field, linkData, navFncStr);
    }

    /**
     * Instantiates a select2 clear link.
     * @param {String} fieldId The field ID of the field to clear.
     */
    var instantiateClearLink = function(fieldId) {
        var clearLinkSelector = `.clearLink[fieldId="${fieldId}"]`;
        $(clearLinkSelector).show();
        $(clearLinkSelector).attr("onClick", `requestFieldHelper().clearSelect2Field("${fieldId}")`);
    }

    var initRegSearch = function(){

        registrationSearchBox = $('input#searchRegistration').select2({
            formatSearching: null,
            createSearchChoice: function (term, data) {
                // $('input[type="text"].elnSearchInput').val(term).attr("secretvalue",term);
            },
            text: function (item) { return item.regId },
            selectOnBlur: false,
            ajax: {
                url: "/arxlab/ajax_loaders/fetchRegistrationSearchTypeahead.asp",
                dataType: 'html',
                quietMillis: 600,
                method: "POST",
                type: "POST",
                contentType: "application/x-www-form-urlencoded",
                data: function (params) {
                    return {
                        userInputValue: params,
                        r: Math.random()
                    };
                },
                results: function (data, params) {
                    // parse the results into the format expected by Select2
                    var i = 0;
                    resultsArray = JSON.parse(data).results
                    while(i < resultsArray.length){
                        resultsArray[i]['id'] = resultsArray[i]['regId']
                        i++
                    }
                    return {
                        results: resultsArray
                    };
                },
                cache: false,
                timeout: 1500
            },
            escapeMarkup: function (markup) { return markup; },
            minimumInputLength: 1,
            formatResult: function(object, container, query){
                headingHTML = '<div class="resultHeading">'
                contentHTML = '<div class="resultContent">'
                $.each(object,function(columnName, value){
                    if(columnName !== "id" && columnName !== "cd_id"){
                        headingHTML += '<div class="colHeader">' + columnName + '</div>';
                        contentHTML += '<div class="colContent">' + value + '</div>';
                    }
                })
                headingHTML += '</div>'
                contentHTML += '</div>'
                return headingHTML + contentHTML
            },
            formatSelection: function (item) {
                window.linkedRegIdInfo = item;
                return item.regId
            },
            formatSearching: null,
            initSelection : function (element, callback) {
                var data = {id: element.val(), regId: element.val()};
                callback(data);
            },
            openOnEnter: false,
            dropdownCssClass : 'elnRegIdLookupDropdown'
        });
    }

    // Go through each dropdown in the request editor and apply any dropdown dependencies.
    var applyDependencies = function(thisRequestType, versionedFields) {
        var dropdowns = $(".editorFieldInputContainer > select");

        $.each(dropdowns, function(selIndex, select) {
            applyDependency(select, thisRequestType, versionedFields);
        });
    };

    // Apply the dependencies that apply to the given select dropdown.
    var applyDependency = function(select, thisRequestType, versionedFields) {
        
        // Grab the dependencies for this dropdown.
        var parent = $(select).closest(".editorField");
        var requestTypeFieldId = $(parent).attr("requesttypefieldid");

        if (!Object.keys(thisRequestType["fieldsDict"]).includes(requestTypeFieldId)) {
            return;
        }

        var requestTypeField = thisRequestType["fieldsDict"][requestTypeFieldId][0];
        var fieldDependencies = requestTypeField["requestTypeFieldDropDownDependencies"];

        // While we're at it, get this dropdown's display name.
        var thisSavedFieldId = requestTypeField["savedFieldId"];
        var thisSavedField = versionedFields.find(x => x.id == thisSavedFieldId);
        var thisDisplayName = thisSavedField["displayName"];

        // Make a global default option.
        var emptyDefaultOption = $("<option emptydefaultoption></option>");
        emptyDefaultOption.val("");
        emptyDefaultOption.text("-- Make a Selection --");

        var targetJSON = {
            empty: []
        };

        // Now, go through the field dependencies.
        $.each(fieldDependencies, function(depIndex, dependency) {

            // Pull out the variables from the dependency object.
            var dropdownOptionId = dependency["dropDownOptionId"];
            var targetFieldId = dependency["targetRequestTypeFieldId"];

            // Pull out the target values from the list of dependency value objects.
            var targetValues = dependency["requestTypeFieldDropDownDependencyValues"].map(x => x.targetDropDownOptionId);

            // Now figure out what our target field is, along with all of its IDs.
            var targetField = thisRequestType["fieldsDict"][targetFieldId][0];
            var targetSavedFieldId = targetField["savedFieldId"];
            var targetSavedField = versionedFields.find(x => x.id == targetSavedFieldId);

            // Filter down the options to the ones that are indicated by targetValues.
            var targetOptions = targetSavedField["options"].filter(x => targetValues.includes(x.dropdownOptionId));

            // Build an HTML option from each target option, then pre-pend the global default.
            var targetOptionsHtml = targetOptions.map(function(option) {
                var optionHtml = $("<option></option>");
                optionHtml.val(option["dropdownOptionId"]);
                optionHtml.text(option["displayName"]);
                return optionHtml;
            });
            targetOptionsHtml.unshift(emptyDefaultOption.clone());

            if (!Object.keys(targetJSON).includes(dropdownOptionId.toString())) {
                targetJSON[dropdownOptionId] = [];
            }

            var targetObj = {};
            targetObj[targetFieldId] = targetOptionsHtml;
            targetJSON[dropdownOptionId].push(targetObj);

            if (!targetJSON["empty"].includes(targetFieldId)) {
                targetJSON["empty"].push(targetFieldId);
            }

        });
        
        // Make an event listener for this dropdown. I'm going to offload this one to the function in requestItemTableHelpers for the time being
        // because the code in that function is generic enough to be reused.
        $(select).change(function() {
            requestItemTableHelpers().checkDropdownDependency($(this).val(), targetJSON, thisDisplayName, "requestType", select);
        });

        // Now make sure the listener is actually run on the first run.
        requestItemTableHelpers().checkDropdownDependency($(select).val(), targetJSON, thisDisplayName, "requestType", select);
    };
    
    return{
        initAllSealectFields: initAllSealectFields,
        NavToNotebook: NavToNotebook,
        NavToProject: NavToProject,
        NavToExperement: NavToExperement,
        clearSelect2Field: clearSelect2Field,
        applyDependencies: applyDependencies
    };


});