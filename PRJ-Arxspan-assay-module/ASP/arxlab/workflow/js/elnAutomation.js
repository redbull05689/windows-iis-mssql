var elnAutomation = function () {

    /**
     * POSTs a request to the ASP to create a new notebook and link it to the given request.
     * @param {string} notebookName The notebook's name.
     * @param {*} editor The select2 input field.
     */
    var genNotebook = function (notebookName = "", editor) {
        return new Promise(function(resolve, reject) {
            var notebookDescription = "This notebook was generated from a Workflow Request.";
            if (notebookName != "") {
                notebookDescription += ` ${notebookName}`;
            }
    
            var data = {
                r: Math.random(),
                notebookName: notebookName,
                notebookDescription: notebookDescription
            }
            genElnObject("../notebooks/create-notebook-ajax.asp", data).then(function(response) {
                $(editor).select2("data", {id: response["notebookId"]});
                resolve({editor: editor, inTable: $(editor).closest(".requestItemsEditor").length > 0, isProject: false, id: response["notebookId"]});
            })
        });
    }

    /**
     * POSTs a request to the ASP to create a new project and link it to the given request.
     * @param {string} projectName The project's name.
     * @param {*} editor The select2 input field.
     */
    var genProject = function (projectName = "NONAME", editor) {
        return new Promise(function(resolve, reject) {
            if (projectName == "")
            {
                projectName = "NONAME";
            }
            
            var inputData = {
                r: Math.random(),
                projectName: projectName,
                projectDescription: "This project was generated from a Workflow Request.",
                disable: 1,
                ajax: 1
            };
            genElnObject("../projects/create-project.asp", inputData).then(function(response) {
                $(editor).select2("data", {"id": response["projectId"]});
                resolve({editor: editor, inTable: $(editor).closest(".requestItemsEditor").length > 0, isProject: true, id: response["projectId"]});
            });
        })
    }

    /**
     * Helper function to POST a request to the ASP to create a notebook or project.
     * @param {string} url The endpoint to hit.
     * @param {JSON} inputData The JSON to submit to the creation endpoint.
     */
    var genElnObject = function(url, inputData) {
        return new Promise(function(resolve, reject) {
            var reply = {};
            $.ajax({
                url: url,
                type: 'POST',
                dataType: 'json',
                data: inputData,
            }).done(function (response) {
                $.each(Object.keys(response), function(i, key) {
                    reply[key] = response[key];
                });
                resolve(reply);
            }).fail(function () {
                console.error("Notebook Failed");
                reply["msg"] = "Failed to create Notebook";
                resolve(reply);
            }).always(function () {
                console.log("complete");
            });
    
        })
    }

    return {
        genNotebook: genNotebook,
        genProject: genProject,
    };




}