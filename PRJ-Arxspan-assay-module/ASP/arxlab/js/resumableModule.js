/**
 * 
 * @param {JSON} resumableOptions The config options for this Resumable Object.
 * @param {Object} assignDropElem The element to turn into a drag and drop object.
 * @param {Object} assignBrowseElem The element to turn into a file browser element.
 * @param {boolean} folderBrowser Should the assignBrowseElem be a folder uploader?
 */
var resumableModule = (function(resumableOptions, assignDropElem, assignBrowseElem, folderBrowser) {

    /**
     * The resumable object that this class represents. Instantiated with the resumableOptions given.
     * Then creates drop and browse elements based on the other class variables.
     */
    var resumableObject = new Resumable(resumableOptions);

    if (assignDropElem) {
        resumableObject.assignDrop(assignDropElem)
    }

    if (assignBrowseElem) {
        resumableObject.assignBrowse(assignBrowseElem, folderBrowser);
    }

    /**
     * Adds the given callback function to the resumable object on file add.
     * @callback addFileCallbackFn The callback function for adding a file.
     */
    var addFileCallback = function(addFileCallbackFn) {
        resumableObject.on("fileAdded", function(file) {
            addFileCallbackFn(file, resumableObject);
        })
    }

    /**
     * Adds the pause callback to the given pauseBtn.
     * @param {Object} pauseBtn The button to assign the pause callback to.
     * @callback pauseButtonCallbackFn The pause callback.
     */
    var addPauseButtonCallback = function(pauseBtn, pauseButtonCallbackFn) {
        pauseBtn.on("click", function() {
            pauseButtonCallbackFn(resumableObject);
        })
    }

    /**
     * Adds the resume callback to the given resumeBtn.
     * @param {Object} resumeBtn The button to assign the resume callback to.
     * @callback resumeButtonCallbackFn The resume callback.
     */
    var addResumeButtonCallback = function(resumeBtn, resumeButtonCallbackFn) {
        resumeBtn.on("click", function() {
            resumeButtonCallbackFn(resumableObject);
        })
    }

    /**
     * Adds the given callback function to the resumable object on file success.
     * @callback fileSuccessCallbackFn The callback function for a successful upload.
     */
    var addFileSuccessCallback = function(fileSuccessCallbackFn) {
        resumableObject.on("fileSuccess", function(file, response) {
            fileSuccessCallbackFn(file, response, resumableObject);
        });
    }

    /**
     * Adds the given callback function to the resumable object on error.
     * @callback errorCallbackFn The callback function for an error.
     */
    var addErrorCallback = function(errorCallbackFn) {
        resumableObject.on("error", function(message, file) {
            errorCallbackFn(message, file, resumableObject);
        })
    }

    /**
     * Adds the given callback function to the resumable object on file error.
     * @callback fileErrorCallbackFn The callback function for a file upload error.
     */
    var addFileErrorCallback = function(fileErrorCallbackFn) {
        resumableObject.on("fileError", function(file, response) {
            fileErrorCallbackFn(file, response, resumableObject);
        })
    }

    /**
     * Adds the given callback function to the resumable object for file progress.
     * @callback addFileProgressCallbackFn The callback function for file progress.
     */
    var addFileProgressCallback = function(addFileProgressCallbackFn) {
        resumableObject.on("fileProgress", function (file, ratio) {
            addFileProgressCallbackFn(file, ratio);
        })
    }

    /**
     * Adds the given callback function to the resumable object on file complete.
     * @callback addFileCompleteCallbackFn 
     */
    var addFileCompleteCallback = function(addFileCompleteCallbackFn) {
        resumableObject.on("complete", function() {
            addFileCompleteCallbackFn();
        })
    }
    
    return {
        resumableObject: resumableObject,
        addFileCallback: addFileCallback,
        addPauseButtonCallback: addPauseButtonCallback,
        addResumeButtonCallback: addResumeButtonCallback,
        addFileSuccessCallback: addFileSuccessCallback,
        addErrorCallback: addErrorCallback,
        addFileErrorCallback: addFileErrorCallback,
        addFileProgressCallback: addFileProgressCallback,
        addFileCompleteCallback: addFileCompleteCallback
    }

});
