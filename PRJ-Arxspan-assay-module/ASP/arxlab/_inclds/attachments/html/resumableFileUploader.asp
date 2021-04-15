
<script type="text/javascript" src="<%=mainAppPath%>/js/resumable.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/resumableModule.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/util/resumableFunctions.min.js?<%=jsRev%>"></script>

<script>
    function addResumableJSUploader() {
        $("#fileupload").hide();
        var fileUploadTable = $("#uploadFormHolder");

        var resumableCurrFile = $("<div class='currFile'></div>").append($("<a href='#'></a>").addClass("currentFileLink").text("No file chosen"));
        var resumableBrowse = $("<button class='resumable-browse'>Choose File</button>");
        var fileDiv = $("<div></div>").addClass("resumableFileInfo");
        fileDiv.append(resumableBrowse).append(resumableCurrFile);

        var btnDiv = $("<div></div>").addClass("resumableBtns");
        var pauseBtn = $("<button></button>").addClass("resumablePause");
        var resumeBtn = $("<button></button>").addClass("resumableGo");
        btnDiv.append(pauseBtn).append(resumeBtn);

        var uploadBar = $("<div></div>").addClass("myBar");
        var uploadFileText = $("<div></div>").addClass("uploadFileText").text("Drag files to upload");
        var resumableTest = $("<div></div>").addClass("resumable-drop").append(uploadBar).append(uploadFileText).append(btnDiv);

        var expTypeString = "<%=getPrefix(experimentType)%>";
        if (expTypeString == "")
            expTypeString = "chem";

        var resumableOptions = {
            target:'/excel2CSV/Upload',
            simultaneousUploads: 1,
            query: {
                connectionId: "<%=session("servicesConnectionId")%>",
                companyId: companyId,
                userId: userInfo.id,
                appName: "ELN",
                experimentId: experimentId,
                revisionNumber: <%=maxRevisionNumber%> + 1,
                experimentType: expTypeString,
                experimentTypeId: <%=experimentType%>,
            },
            minFileSize: 0,
            headers: {Authorization: "<%=session("jwtToken")%>"},
            generateUniqueIdentifier: resumableGenerateUniqueIdentifier,
        }

        var pauseBtnCallback = function(rObj) {
            rObj.pause();
            removeProgressClasses(uploadBar);
            uploadBar.addClass("myBar-pause");
            changeResumableText("File(s) paused.");
        }

        var resumeBtnCallback = function(rObj) {
            rObj.upload();
            removeProgressClasses(uploadBar);
            uploadBar.addClass("myBar-upload");
            changeResumableText("Uploading file(s)...");
        }

        var fileAddedCallback = function(file, rObj) {            
            //fieldInputElement.find(".currentFileLink").text(file.fileName);          
            uploadBar.css("width", "0%");
            removeProgressClasses(uploadBar);
            uploadBar.addClass("myBar-upload");
            btnDiv.css('display', 'flex');

            rObj.upload();
            changeResumableText("Uploading file(s)...");
        }

        var fileSuccessCallback = function(file, response, rObj) {
            removeProgressClasses(uploadBar);
            uploadBar.addClass("myBar-success");
            btnDiv.hide();

            var responseObj = JSON.parse(response);

            rObj.removeFile(file);

            //fieldInputElement.attr("fileid", responseObj.fileId);

            if (responseObj.fileId != -1) {
                console.log(responseObj.fileId);
            }
        }

        var fileErrorCallback = function(file, response, rObj) {
            removeProgressClasses(uploadBar);
            uploadBar.addClass("myBar-error");
            uploadBar.css("width", "100%");
            btnDiv.hide();

            rObj.removeFile(file);
            changeResumableText("Error uploading file(s)...");
        }
        
        var fileProgressCallback = function(file, ratio) {
            var progress = file.progress() * 100;
            progress = Math.floor(progress);
            uploadBar.css("width", progress + "%");
        }

        var fileCompleteCallback = function() {
            updateAttachments();
            removeProgressClasses(uploadBar);
            changeResumableText("Upload complete.");

            unsavedChanges = true;
            //call unsavedChangesCheck now to make sure the unsaved changes flag gets added to top of screan 
            unsavedChangesCheck();
            sendAutoSave('experimentId', experimentId);
        }

        var resumableObject = resumableModule(resumableOptions, resumableTest, resumableTest.find(".resumable-browse"));
        resumableObject.addFileCallback(fileAddedCallback);
        resumableObject.addPauseButtonCallback(pauseBtn, pauseBtnCallback);
        resumableObject.addResumeButtonCallback(resumeBtn, resumeBtnCallback);
        resumableObject.addFileSuccessCallback(fileSuccessCallback);
        resumableObject.addFileErrorCallback(fileErrorCallback);
        resumableObject.addFileProgressCallback(fileProgressCallback);
        resumableObject.addFileCompleteCallback(fileCompleteCallback);

        fileUploadTable.append(resumableTest);

        addResumablePopup(resumableOptions);
    }

    function addResumablePopup(baseOptions) {
        
        // Instantiate the two uploaders.
        var resumableFile = resumableModule(baseOptions, undefined, $(".resumableFile"), undefined);
        var resumableFolder = resumableModule(baseOptions, undefined, $(".resumableFolder"), true);

        // Set up the callbacks.

        // On file success, remove the file from the resumable object.
        var fileSuccessCallback = function(file, response, rObj) {
            var responseObj = JSON.parse(response);

            rObj.removeFile(file);

            if (responseObj.fileId != -1) {
                console.log(responseObj.fileId);
            }
        }

        // Error callbacks. Currently unused, but still here for posterity.
        var errorCallback = function(message, file, rObj) {
            console.debug("error", message, file);
            rObj.removeFile(file);
        }
        
        var fileErrorCallback = function(file, message, rObj) {
            console.debug("fileError", file, message);
            rObj.removeFile(file);
        }
        
        // When the file upload(s) are complete, update the attachments table, tell the experiment that we have
        // unsaved changes, then put it in the draft.
        var completeCallback = function() {
            updateAttachments();
            hidePopup("addResumableFileDiv");

            unsavedChanges = true;
            //call unsavedChangesCheck now to make sure the unsaved changes flag gets added to top of screan 
            unsavedChangesCheck();
            sendAutoSave('experimentId', experimentId);
        }

        // When adding a file, remove the file(s) in the folder object.
        var fileAddCallback = function(file) {            
            var rFolder = resumableFolder.resumableObject;
            $("#resumableActualFileName").text(file.fileName);

            $.each(rFolder.files, function(index, folderFile) {
                rFolder.removeFile(folderFile);
            })

            $("#resumableFolderName").text("No folder chosen");
            $("#resumableFileToUse").val("file");
        }

        // When adding a folder, remove the file in the file object.
        var folderAddCallback = function(file) {
            var rFile = resumableFile.resumableObject;
            var folderName = file.relativePath.split("/")[0];
            $("#resumableFolderName").text(folderName);   
            
            rFile.removeFile(rFile.file);
            $("#resumableActualFileName").text("No file chosen");
            $("#resumableFileToUse").val("folder");
        }

        // Now add the necessary callbacks.
        resumableFile.addFileSuccessCallback(fileSuccessCallback);
        resumableFile.addFileCompleteCallback(completeCallback);
        resumableFile.addFileCallback(fileAddCallback);

        resumableFolder.addFileSuccessCallback(fileSuccessCallback);
        resumableFolder.addFileCompleteCallback(completeCallback);
        resumableFolder.addFileCallback(folderAddCallback);

        // Upload the correct file(s) when the upload button is pressed.
        $(".resumableUploadButton").on("click", function() {
            var fileToUse = $("#resumableFileToUse").val();

            var r;

            if (fileToUse == "file") {
                r = resumableFile.resumableObject;
            } else if (fileToUse == "folder") {
                r = resumableFolder.resumableObject;
            };

            if (r !== undefined) {
                var givenName = $("#resumableFileName").val();

                if (givenName != "") {
                    r["opts"]["query"]["givenName"] = givenName;
                }
                
                r["opts"]["query"]["description"] = CKEDITOR.instances.resumableFileDescription.getData();
                r.upload();

                $("#resumableFileName").val("");
                CKEDITOR.instances.resumableFileDescription.setData("");
                $("#resumableActualFileName").text("No file chosen");
                $("#resumableFolderName").text("No folder chosen");
            }
        });
    }
        
    function removeProgressClasses(uploadBar) {
        uploadBar.removeClass("myBar-upload");
        uploadBar.removeClass("myBar-pause");
        uploadBar.removeClass("myBar-success");
        uploadBar.removeClass("myBar-error");
    }

    function changeResumableText(newText) {
        $(".uploadFileText").text(newText);
    }
</script>