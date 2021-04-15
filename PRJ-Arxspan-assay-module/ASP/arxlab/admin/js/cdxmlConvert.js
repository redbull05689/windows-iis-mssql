/**
 * Module to compare results produced by CDXML service with ones from JChem
 * @param {string} p_cdxmlServiceEndpointUrl
 * @param {string} p_chemAxonMolExportUrl
 */
var cdxmlConvert = (function (p_cdxmlServiceEndpointUrl, p_chemAxonMolExportUrl) {

    //need to track file and structure data for export
    let structureData = "";
    let fileName = "";
    let fileType = "";

    let cdxmlServiceEndpointUrl = p_cdxmlServiceEndpointUrl;
    let chemAxonMolExportUrl = p_chemAxonMolExportUrl;


    
    /**
    * Calls Api to convert CDX or CDXML to requested format.
    *
    * @param {string} structure CDXML or Base64 of the molecule to convert.
    * @param {string} type output format
    *
    */
    var CDXMLToImage = function (structure, type) {

        return new Promise(function (resolve, reject) {
            if (!(typeof cdxmlServiceEndpointUrl === "string" && cdxmlServiceEndpointUrl.length)) {
                reject(Error("cdxmlServiceEndpointUrl not defined"));
            }

            base64 = fileType == "cdx" ? structure : "";

            restCall(cdxmlServiceEndpointUrl + "/CdxmlConv2X", "POST", { "base64cdx": base64, "cdxml": structure, "outType": type, "appName": "ELN" })
                .then(function (response) {
                    if (response["data"]) {
                        resolve(response["data"]);
                    }
                    else {
                        reject(Error("no DATA in response"));
                    }
                }, function (error) {
                    reject(error);
                });
        });

    }


    /**
    * Calls JCHem to convert CDX or CDXML to SVG.
    *
    * @param {string} structure CDXML or Base64 of the molecule to convert.
    *
    */
    var CDXMLToJChem = function (structure) {
        return new Promise(function (resolve, reject) {
            if (!(typeof chemAxonMolExportUrl === "string" && chemAxonMolExportUrl.length)) {
                reject(Error("chemAxonMolExportUrl not defined"));
            }

            inputFormat = fileType == "cdx" ? "base64" : "cdxml";
            restCall(chemAxonMolExportUrl,
                "POST",
                {
                    "structure": structure,
                    "inputFormat": inputFormat,
                    "parameters": "svg:headless,nosource,transbg,absLabelVisible,maxscale28,marginSize2,cv_off,atsiz0.5,-a"
                }
            ).then(
                function (response) {
                    console.log("Success!", response);
                    if (response["structure"]) {
                        resolve(response["structure"]);
                    }
                    else {
                        reject("no structure in response");
                    }
                }, function (error) {
                    console.error("Failed!", error);
                }
            );
        });
    }


    /**
    * Calls Api to convert CDX or CDXML to requested format and export it as an attachment.
    *
    * @param {string} structure  CDXML or Base64 of the molecule to convert.
    * @param {string} expFileType output format
    * @param {string} inputType output format
    */
    function exportImage(expFileType, structure, inputType) {

        if (!(typeof cdxmlServiceEndpointUrl === "string" && cdxmlServiceEndpointUrl.length)) {
            console.error("cdxmlServiceEndpointUrl not defined");
            return false;
        }

        if (!(typeof structure === "string" && structure.length)
            && !(typeof structureData === "string" && structureData.length)) {
            console.error("nothing to export");
            return false;
        }

        if (!(typeof structure === "string" && structure.length)) {
            structure = structureData;
        }

        if (!(typeof inputType === "string" && inputType.length)) {
            inputType = fileType;
        }

        if (inputType.toLowerCase() != "cdx" && inputType.toLowerCase() != "cdxml") {
            console.error("unsupported input type");
            return false;
        }

        base64 = inputType.toLowerCase() == "cdx" ? structure : "";
        restCall(
            cdxmlServiceEndpointUrl + "/CdxmlConv2X",
            "POST",
            { "base64cdx": base64, cdxml: structure, "outType": expFileType, "appName": "ELN", "outImageHeight": 800,"outImageWidth":1200 }
        )
        .then(
            function (response) {
                fileName = !(typeof fileName === "string" && fileName.length) ? "export" : fileName;

                if (response["data"]) {
                    download(response["data"], (fileName.substring(0, fileName.lastIndexOf('.')) || fileName) + getExtension(expFileType), expFileType);
                }
            },
            function (error) {
                console.error("Failed!", error);
            }            
        );
    }



    /**
   * Handles file upload, cleans previous import leftovers
   *
   * @param {Array} files Array of files to handle. Only the first one is processed
   *
   */
    function handleFiles(files) {
        //clear previous results
        $("#fileExport").hide();
        $(".container").hide();
        $("#cdxml2x").empty();
        $("#jchem").empty();

        files = Array.from(files);
        uploadFile(files[0]);
    }


    /**
     * Drop event handler
     * @param {event} e
     */
    function handleDrop(e) {
        var dt = e.dataTransfer;
        var files = dt.files;

        handleFiles(files);
    }


    /**
    * Posts data to a proxy page that will send a rest call/request to the api server.
    *
    * @param {string} url endpoint url
    * @param {string} verb http request type
    * @param {object} indata data to be sent to the endpoint
    */
    function restCall(url, verb, inData) {
        return new Promise(function (resolve, reject) {
            if (window.XMLHttpRequest) {
                client = new XMLHttpRequest();
            }
            else {
                client = new ActiveXObject("Microsoft.XMLHTTP");
            }

            data = JSON.stringify(inData);

            //make request
            var retVal;
            $.ajax({

                url: "apiproxy.asp",
                type: "POST",
                dataType: "json",
                data: {
                    verb: (verb),
                    url: (url),
                    data: (data),
                }
            }).done(function (response) {
                if (response == "") {
                    //return javascript object
                    retVal = JSON.parse("{}");                    
                }
                else {
                    retVal = response;
                }
                resolve(retVal);
            }).fail(function (response) {
                //alert(response["responseText"]);
                reject(Error(response["responseText"]));
            });

        });
    }

    /**
    * Exports data as a file attachment
    *
    * @param {string} data structure data
    * @param {string} filename name of the exported files
    * @param {string} type type of the file being exported
    *
    */
    function download(data, filename, type) {
        var file = new Blob([data], { type: type });

        if (window.navigator.msSaveOrOpenBlob) { // IE10+
            window.navigator.msSaveOrOpenBlob(file, filename);
        }
        else { // Others
            var a = document.createElement("a");
            var url = URL.createObjectURL(file);
            a.href = url;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            setTimeout(function () {
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
            }, 0);
        }
    }


    /**
    * Receives uploaded file and converts it into SVG with CDXML endpoint and JChem
    *
    * @param {file} file object from file upload input
    *
    */
    function uploadFile(file) {
        var fr = new FileReader();
        fileType = getFileExtension(file["name"]);
        fileName = file["name"];

        fr.onload = function (e) {

            structureData = fileType == "cdx" ? e.target.result.split(',')[1] : e.target.result;

            CDXMLToImage(structureData, "svg")
                .then(
                    function (response) {
                        if (response) {
                            $("#cdxml2x").html(response);
                            $(".container").show();
                            $("#fileExport").show();
                        }
                    },
                    function (error) {
                        console.error("Failed!", error);
                    }
                );            

            CDXMLToJChem(structureData)  
                .then(
                    function (response) {
                        if (response) {
                            $("#jchem").html(response);
                        }
                    },
                    function (error) {
                        console.error("Failed!", error);
                    }
                );
        }

        fileType == "cdx" ? fr.readAsDataURL(new Blob([file])) : fr.readAsText(file);
    }

    /**
    * Strips out file exptension
    *
    * @param {string} filename  filename
    *
    */
    function getFileExtension(filename) {
        var ext = /^.+\.([^.]+)$/.exec(filename);
        return ext == null ? "" : ext[1].toLowerCase();
    }


    /**
    * Returns file extension for  requested filetype
    *
    * @param {string} type type of the file
    *
    */
    function getExtension(type) {
        switch (type) {
            case "mol": { return ".mol"; break; }
            case "svg": { return ".svg"; break; }
            case "rxn": { return ".rxn"; break; }
            case "sdf": { return ".sdf"; break; }
            case "cml": { return ".cml"; break; }
            case "mrv": { return ".mrv"; break; }
            case "inchi": { return ".inchi"; break; }
            case "rinchi": { return ".rinchi"; break; }
            case "inchikey": { return ".inchikey"; break; }
            case "rinchikey": { return ".inchikey"; break; }
            default: return "";
        }

    }


    /**
     * Function to prevent default drag-n-drop behavior
     * @param {event} e
     */
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    /**
     * Dragover-dragenter event listener
     * @param {event} e
     */
    function highlight(e) {
        $("#drop-area").addClass('highlight');
    }

    /**
     * Dragleft, drop event listeneer
     * @param {event}  e 
     */
    function unhighlight(e) {
        $("#drop-area").removeClass('highlight');
    }


    /**
     *Configures drag-n-drop functionaity
     */
    function preparePage() {
        $("#fileElem").change(function (e) {
            handleFiles(this.files);
        });

        let dropArea = document.getElementById("drop-area");

        $("#fileExport").hide();
        $(".container").hide();

        //build drop list with available filetype export options
        ["mol", "svg", "rxn", "sdf", "cml", "mrv", "inchi", "inchikey", "rinchi", "rinchikey"].forEach(function (item) {
            let optionObj = document.createElement("option");
            optionObj.textContent = item;
            document.getElementById("fileType").appendChild(optionObj);
        });

        // Prevent default drag behaviors
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(function (eventName) {
            dropArea.addEventListener(eventName, preventDefaults, false);
            document.body.addEventListener(eventName, preventDefaults, false);
        });

        // Highlight drop area when item is dragged over it
        ['dragenter', 'dragover'].forEach(function (eventName) {
            dropArea.addEventListener(eventName, highlight, false);
        });

        ['dragleave', 'drop'].forEach(function (eventName) {
            dropArea.addEventListener(eventName, unhighlight, false);
        });


        dropArea.addEventListener('drop', handleDrop, false);      

    };


    return {
        prepare: preparePage,
        exportFile: exportImage,
        cdxmlToJChem: CDXMLToJChem,
        cdxmlToImage: CDXMLToImage
    };

});















