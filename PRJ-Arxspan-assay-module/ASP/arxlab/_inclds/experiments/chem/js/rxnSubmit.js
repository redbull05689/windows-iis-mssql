/* Currenly, this is only used for Marvin */

/* attach a submit handler to the form */
$("#uploadRXNForm").submit(function(event) {
            /* stop form from submitting normally */
            event.preventDefault();
            rxnSubmit(this);
});

function rxnSubmit(theForm){

    console.log("rxnSubmit here");
    var files = document.getElementById("rxnFile").files;
    for (var i = 0, f; f = files[i]; i++) {
        var reader = new FileReader();
        reader.onload = (function(theFile) {
            
            fileType = null;
            fileData = reader.result;

            //remove the base64 tag
            fileData = atob(reader.result.replace(/^data:[^;]*;base64,*/,''));

            //Try to figure out the type
            if (/^<cml>/.test(fileData)) {
                fileType = "mrv";
            }else if (/\$RXN/.test(fileData)) {
                fileType = "rxn";
            } else if (/\$MOL/.test(fileData)) {
                fileType = "mol";
            } else if (/ChemAxon file format v\d\d/.test(fileData)) {
                fileType = "cml";
            } else if (/\$RXN V3000/.test(fileData)) {
                fileType = "rxn:V3";
            } else if (/V[23]000(.|[\r\n])*?\$\$\$\$/.test(fileData)) {
                fileType = "sdf";
            } else if (/<CDXML/.test(fileData)) {
                fileType = "cdxml";
                fileData = fileData.replace(/^.*<CDXML/gm, "<CDXML");
            } else if (/ChemDraw \d\d/.test(fileData)) {
                fileType = "base64:cdx";
                fileData = reader.result.replace(/^data:[^;]*;base64,*/,'');
            } else {
                //we don't know, see if marvin can figure it out.
                fileType = null;
            }
            
            console.log("We think the file type is: " + fileType);
            //console.log(fileData);
            marvinSketcherInstance.off("molchange", null);
            clearTimeout(mrvTimeout);
            marvinSketcherInstance.importStructure(fileType,fileData).then(function () {
                hidePopup('uploadingDiv');
                unsavedChanges=false;
                addTojchem(fileType, fileData);
                experimentSubmit(false,false,false).then(function(){				
                    if (typeof updateOnMolChange === 'function'){
                        readyTimeout = setInterval(function(){ 
                            // experimentSubmit resolves before these timeouts are done
                            //  We need to wait until they are done before we turn the
                            //  marvin onchange event back on or the page never loads
                            if($('#blackDiv').css('display') == 'none' || $('#blackDiv').css('height') == '0px') {
                                clearInterval(readyTimeout);
                                updateOnMolChange();
                                marvinSketcherInstance.on("molchange", updateOnMolChange);
                            } 
                        }, 100);
                    }
                });
            }, function(error) {
                //Try again, let marvin try to figure out the file type
                console.log("Failed to import, trying again with data type set to: 'AutoDiscover'");
                marvinSketcherInstance.importStructure(null,fileData).then(function () {
                    hidePopup('uploadingDiv');
                    unsavedChanges=false;
                    addTojchem(null, fileData);
                    experimentSubmit(false,false,false).then(function(){				
                        if (typeof updateOnMolChange === 'function'){
                            readyTimeout = setInterval(function(){ 
                                if($('#blackDiv').css('display') == 'none' || $('#blackDiv').css('height') == '0px') {
                                    clearInterval(readyTimeout);
                                    updateOnMolChange();
                                    marvinSketcherInstance.on("molchange", updateOnMolChange);
                                } 
                            }, 100);
                        }
                    });
                }, function(error2){
                    console.log("Still Failed to import, trying again with sepearte server side processing");
                    callRXNEcho(theForm);
                });     
            });
        });
        // Read in the image file as a data URL.
        reader.readAsDataURL(f);
    }
}

function addTojchem(molDataType, molData){
    var inputData = {'format':molDataType, 'structure': molData, 'targetElement': 'mycdx'};
    $.ajax({
        url: '/arxlab/ajax_loaders/chemistry/getMoleculeId.asp',
        type: 'POST',
        dataType: 'json',
        data: inputData,
        async: true,
        molFormat: molDataType,
        targetElement: 'mycdx'
    }).done(function(response) {
        if(response.hasOwnProperty("sketchId")){
            console.log("got MoleuleId");
        }else{
            console.error("Error getting moleculeId");
        }
    })
    .fail(function(error) {
            console.log(error);
            console.error("Error getting the moleculeId");
    });
}


function callRXNEcho(theForm){
            /* get some values from elements on the page: */
            var $form = $(theForm),
                fd = new FormData($form[0]),
                url = $form.attr('action');
    
            /* Send the data using post */
            posting = $.ajax({
                url: url,
                data: fd,
                type: 'POST',
                contentType: false, // NEEDED, DON'T OMIT THIS (requires jQuery 1.6+)
                processData: false, // NEEDED, DON'T OMIT THIS
            });

            /* Put the results in a div */
            posting.done(function(data) {
                try{
                    marvinSketcherInstance.importStructure("cdxml",JSON.parse(data).experimentCDX).then(function () {
                        hidePopup('uploadingDiv');
                        unsavedChanges=false;
                        addTojchem('cdxml', fileData);
                        experimentSubmit(false,false,false,false,true);
                    }, function(error2){
                        console.log("Failed to import, we are out of ideas");
                        swal("Reaction Failed to Upload", "Please try uploading in a different format" , "error");    
                        hidePopup('uploadingDiv');
                    });

                }catch(e){
                    swal("Failed to Upload", "Please try uploading in a different format" , "error");
                    hidePopup('uploadingDiv');
                }
            });

            posting.error(function(data){
                swal("Failed to Upload Reaction", "Please try uploading in a different format. \r\n Error Message: " + data.error().statusText, "error");
                hidePopup('uploadingDiv');
            });

}