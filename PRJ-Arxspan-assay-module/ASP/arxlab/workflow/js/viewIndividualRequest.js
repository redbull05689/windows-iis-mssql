/**
 * Fetches a single request.
 * @param {number} requestId The request's ID.
 * @param {number} requestRevId The revision of the request we want to view.
 */
function viewIndividualRequest(requestId, requestRevId){

    var inputParams = {
        getFieldData: true,
        getItemData: true,
        //getOnlyLatestHistoryRecord: true,
        appName: "Workflow"
    }

    ajaxModule().getRequestRevision(requestId, requestRevId, inputParams).then(function(response) {
        if(typeof response !== "undefined"){
            var request = response;

            userGroupName = ""
            $.each(window.groupsList, function(){
                if(this['id'] == request['assignedGroupId']){
                    userGroupName = this['name']
                    return false;
                }
            });

            var asOfDate = utilities().asOfDateValidator(request["dateCreated"]);
            
            ajaxModule().getVersionedConfigData(request["requestTypeId"], currVersion=false, dateCreated=asOfDate).then(function(configResponses) {
                var thisRequestType = configResponses[2][0];        
                var requestItemTypes = configResponses[1];        
                var fields = configResponses[0];
        
                window.top.thisRequestType = thisRequestType;
                window.top.versionedRequestItems = requestItemTypes;
                window.top.versionedFields = fields;
        
                var requestElement = $('<div id="requestEditor" />');
                requestEditorHelper.finalizeRequestEditorInitialization();
                requestEditorHelper.generateRequestDetailsRow(request, requestElement, thisRequestType, requestItemTypes, fields);

                $("#requestEditor").remove();
                $('#individualRequestContainer').append(requestElement);
            
                requestEditorHelper.insertRequestFieldsToggle();
            
            })
        }
    })
}

$(document).ready(function(){
    if(window.top != window.self) {
        $(".sidebar").hide();
        $(".main-panel").css('width','100%');
        $(".main-panel").css('float','initial');
    }
    requestEditorHelper.populateUserGroupsList().then(function () {
        if (stripDown == true) {
            $('.sidebar').hide();
            $('#notificationsDropdownToggle').hide();
            $('.main-panel > .navbar').hide();
            $('.main-panel').width($(window).width());

            $(window).resize(function () {
                $('.main-panel').width($(window).width());
            });

        }

        viewIndividualRequest(requestId, requestRevId);  

    });
});
