var useChemDrawForLiveEdit = true;

function truncateCdxmlProlog(fileStr)
{
	var retStr = fileStr;
	var cdxmlTagPos = fileStr.indexOf('<CDXML');
	if(cdxmlTagPos > 0) {
		retStr = fileStr.substring(cdxmlTagPos);
	}
	return retStr;
}

function isCdxml(fileStr)
{
	var cdxmlOpenRegEx = /<cdxml/i;
	var cdxmlCloseRegEx = /<\/cdxml>/i;
	if(cdxmlOpenRegEx.test(fileStr) && cdxmlCloseRegEx.test(fileStr))
		return true;
	
	return false;
}

loaindGifTimeout = {}
storedLargeImgs = {}
storedImgs = {}

/**
 * Gets updated LiveEditor Structure images.
 * 
 * @param {string} targetElement - Target Element ID
 * @param {bool} skipUpdateImage - Skip image update if this flag is set
 * @param {bool} preserveImgHTML - Also skip image process if this flag is set
 */
function getUpdatedLiveEditStructureImage(targetElement, skipUpdateImage, preserveImgHTML)
{
	if (skipUpdateImage || (preserveImgHTML != undefined && preserveImgHTML != false)) {
		return new Promise(function (resolve, reject) {
			resolve(true);
		});
	}

	return new Promise(function (resolve, reject) {
		var linkElement = $('[liveEditId="' + targetElement + '"]');
		var molDataType = $('[liveEditId="' + targetElement + '"]').attr('molFormat');
		var jchemProxyLoc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport";

		//Put a loading image in the box
		// remove the image that's in the structure box now
		var divHolder = $(linkElement).find(".structureImage");
		$(divHolder).empty();

		// put the loading image in the structure box
		setLoadingGif = function (targetElement) {
			loadingGif = window.location.origin + "/arxlab/images/loading_big.gif";
			var imageHeight = $('[liveEditId="' + targetElement + '"]').attr('height');
			var imageWidth = $('[liveEditId="' + targetElement + '"]').attr('width');
			var loadingGifSize = Math.min(imageHeight, imageWidth);
			$(divHolder).append("<img src='" + loadingGif + "'id='loadingGif-" + targetElement + "' style='height:" + loadingGifSize + "px; width:" + loadingGifSize + "px; ' />");
		};

		//Make the loading gif on a short timeout, this keeps it from showing if it loads quickly
		loaindGifTimeout[targetElement] = setTimeout(setLoadingGif, 300, targetElement);

		var molData = $(linkElement).attr('molData');
		var molDataStr = unescape(molData);

		molDataType = getFileFormat(molData);
		if (molDataType == "") {
			//try again with the escaped one
			molDataType = getFileFormat(molDataStr);
		}

		hasChemdraw().then(function (isInstalled) {
			if (isInstalled) {
				cd_putData(targetElement, "text/xml", molDataStr);
				$(linkElement).removeAttr('liveEditFileId');
				resolve(true);
				return;
			}
			else {
				if (molDataType == 'cdxml' && isCdxml(molDataStr)) {
					molDataStr = truncateCdxmlProlog(molDataStr);
				}

				//This removes the atom ids
				if (molDataType == 'mrv') {
					molDataStr = molDataStr.replace(/<scalar[^>]+_mjs::uid[^>]+>[^<]+<\/scalar>/gm, "");
				}
				theWidth = 300;
				try {
					theWidth = $(linkElement).parent()[0].offsetWidth - 2;
					if (theWidth == -2) {
						theWidth = 300;
					}
				} catch (e) {
					//Do nothing	
				}

				// 5766 - Adding the -a flag to the input parameters to both data payloads to run
				// ChemAxon's "General Dearomatization". (https://docs.chemaxon.com/display/Dearomatization.html)
				// The call in lib_JChem.asp has this flag, so I am merely adding it to here too to unify them.
				var theData = JSON.stringify({
					"structure": molDataStr,
					"parameters": "svg:headless,nosource,transbg,absLabelVisible,maxscale28,marginSize2,cv_off,atsiz0.5,-a,w" + theWidth + ",h" + ($(linkElement).attr('height') - 2),
					"inputFormat": molDataType
				});
				//theData = encodeURIComponent(theData); //Turnning this on slows down JchemProxy 10x

				//same call with larger requested img
				var TheLargerImg = JSON.stringify({
					"structure": molDataStr,
					"parameters": "svg:headless,nosource,transbg,absLabelVisible,maxscale28,marginSize2,cv_off,atsiz0.5,-a,w" + (theWidth * 2) + ",h" + (($(linkElement).attr('height') - 2) * 2),
					"inputFormat": molDataType
				});

				$.ajax({
					method: "POST",
					url: jchemProxyLoc,
					data: theData,
					dataType: "json",
					contentType: "application/json",
					async: true,
					targetElement: targetElement
				}).done(function (msg) {
					if (msg.hasOwnProperty("structure")) {
						//We have a real image, lets not show the loading Gif
						clearTimeout(loaindGifTimeout[targetElement]);

						// remove the image that's in the structure box now
						var linkElement = $('[liveEditId="' + targetElement + '"]');
						var divHolder = $(linkElement).find(".structureImage");
						$(divHolder).empty();

						// put the new image in the structure box
						var imageElementHtml = msg['structure'];
						storedImgs[targetElement] = msg['structure'];
						$(divHolder).append(imageElementHtml);
					}
				}).fail(function (msg) {
					var divHolder = $(linkElement).find(".structureImage");
					$(divHolder).empty();
					swal("", "No structure found; please try again.", "warning");
				}).always(function () {
					var linkElement = $('[liveEditId="' + targetElement + '"]');
					$(linkElement).removeAttr('liveEditFileId');

					if ($(linkElement).hasClass('isCheckedOut')) {
						$(linkElement).attr('onclick', 'editStructure("' + targetElement + '")');
						$(linkElement).removeClass('isCheckedOut');
					}

					//Remove the discard checkout button
					$('[discardliveeditid="' + targetElement + '"]').removeClass('isCheckedOut');
					$('[discardliveeditid="' + targetElement + '"]').hide();

					$("#loadingGif-" + targetElement).hide();
					resolve(true);
				});

				//ask for the larger img 
				$.ajax({
					method: "POST",
					url: jchemProxyLoc,
					data: TheLargerImg,
					dataType: "json",
					contentType: "application/json",
					async: true,
					targetElement: targetElement
				}).done(function (msg) {
					if (msg.hasOwnProperty("structure")) {
						storedLargeImgs[targetElement] = msg['structure'];
					}
				});
			}
		});
	});
}

function updateLiveEditStructureData(targetElement, fileStr, format, skipUpdateImage)
{
	skipUpdateImage = skipUpdateImage || false;

	return new Promise(function(resolve, reject) {
		if ($('[name="' + targetElement + '"]').length > 0 && hasMarvin){
			setupMarvin(targetElement, btoa(fileStr), true);
			resolve(true);
			return;
		}else if($('[liveEditId="' + targetElement + '"]').length == 0) {
			resolve(true);
			return;
		}
		format = getFileFormat(fileStr);
		
		var inputData = {'format':format, 'structure': fileStr, 'targetElement': targetElement};
		
		$.ajax({
			url: '/arxlab/ajax_loaders/chemistry/getMoleculeId.asp',
			type: 'POST',
			dataType: 'json',
			data: inputData,
			async: true,
		})
		.done(function(response) {
			if(response.hasOwnProperty("sketchId"))
			{
				var cdId = response["sketchId"].toString();
				
				// Check to make sure we don't have any unallowed chars in the file extension
				if (/\:/.test(format) || format.length == 0){
					console.log("WARRNING: Unallowed characters in file extension: " + format + " Assuming \"cdxml\"");
					format = "cdxml";
				}
				//Post message to delete the mol file at the user end
				var fileId = $('[liveEditId="' + targetElement + '"]').attr("liveEditFileId");
				if(typeof(fileId) != 'undefined'){
					window.postMessage({ message_type: 'delete', file: '1-' + fileId + '.' + format}, window.location.href);
				}
				
				$.ajax({
					url: '/arxlab/ajax_loaders/chemistry/getMoleculeFormatById.asp?id='+cdId+'&tagId='+targetElement,
					type: 'POST',
					dataType: 'json'			})
				.done(function(response) {
					if (response["data"] == "")
					{
						response["data"] = getEmptyMolFile();
					}

					$('[liveEditId="' + targetElement + '"]').attr('molData', escape(response["data"]));
					getUpdatedLiveEditStructureImage(targetElement, skipUpdateImage)
					.then(function() {
		
						resolve(true);
					});
				})
				.fail(function() {
					resolve(true);
					console.log("Failed to getMoleculeFormatById in updateLiveEditStructureData");
				});
			}
		});
	});
}

function checkInStructure(targetElement, skipUpdateImage)
{
	try {
		skipUpdateImage = skipUpdateImage || false;
		$('[liveEditId="' + targetElement + '"]').attr('onClick', "");
		var molFormat = $('[liveEditId="' + targetElement + '"]').attr('molFormat');
	
		var formating = molFormat.split(":");
		if (formating.length > 1)
		{
			molFormat = formating[1];
		}
	
		var theArgs = {'targetElement': targetElement, 'ext': molFormat, skipUpdateImage: skipUpdateImage};
		
		liveEditor.setCheckInUploadCallback(function(msg, uploadFileDatab64, theArgs) {
			// update the structure image
			try{
				uploadFileData = atob(uploadFileDatab64);
			}catch(e){
				console.log("Unable to atob uploadFileData");
			}
	
			//Check to see if there is a change
			var molData = unescape($('[liveEditId="' + theArgs.targetElement + '"]').attr('molData'));

			//It starts with the XMLs, then rips out line breaks, rips out double spaces, converts to Base64, converts to byte array, gets MD5 hash, and finally makes the hash upperCase.
			var uploadMD5 = md5(_base64ToArray(btoa(uploadFileData.replace(/(\r\n|\n|\r)/gm, "").replace(/\s{2,}/gm, "")))).toUpperCase();
			var molDataMD5 = md5(_base64ToArray(btoa(molData.replace(/(\r\n|\n|\r)/gm, "").replace(/\s{2,}/gm, "")))).toUpperCase();

			if (molDataMD5 == uploadMD5){
				swal({
					title: "Reaction Unchanged",
					text: "Looks like you are trying to check in an unchanged reaction. Are you sure?",
					type: "warning",
					showCancelButton: true,
					confirmButtonColor: "#DD6B55",
					confirmButtonText: "Check In",
					cancelButtonText: "Cancel",
				}, function (isConfirm) {
					if (isConfirm) {
					updateLiveEditStructureData(theArgs.targetElement, uploadFileData, theArgs.ext, theArgs.skipUpdateImage).then(function(){
						try {$('[liveEditId="' + theArgs.targetElement + '"]').trigger('chemistryChanged');}
						catch(e) {console.log("error calling chemistryChanged... ", e);}
						});
					} else {
						$('[liveEditId="' + targetElement + '"]').attr('onClick', "checkInStructure(\""+theArgs.targetElement+"\", " +theArgs.skipUpdateImage +");"); //Turn the checkin button back on
						setTimeout(function(){swal({
								title: "Canceled",
								text: "Check In Cancled",
								type: "info",
								timer: 2000
						});},200); //If I don't have the timeout, both sweet alerts get killed at the same time
					}
				});
			}else{
				updateLiveEditStructureData(theArgs.targetElement, uploadFileData, theArgs.ext, theArgs.skipUpdateImage).then(function(){
					try {$('[liveEditId="' + theArgs.targetElement + '"]').trigger('chemistryChanged');}
					catch(e) {console.log("error calling chemistryChanged... ", e);}
				});
			}
		}, theArgs);
	
		var fileId = $('[liveEditId="' + targetElement + '"]').attr('liveEditFileId');
		window.postMessage({
				message_type : 'checkin',
				attachmentId : fileId,
				url : '/arxlab/ajax_loaders/chemistry/getMoleculeId.asp',
				filename : '',
				filelabel : '',
				chunk: 1, //This is needed because of a bug in the mac host
				description : {"targetElement": targetElement},
				experimentType : '1',
				sort : '0',
				ext : '.'+molFormat
				}, '*');
	}
	catch (exception) {
		swal({
			title: "Error",
			text: "There was an error with this reaction. Please contact support.",
			type: "error"
		});
	}
}

function discardCheckIn(targetElement){

	swal({title: 'Are you sure?', 
		  text: 'This will permanently remove any unsaved changes to this file. This cannot be undone.',
		  type: 'warning', 
		  showCancelButton: true, 
		  confirmButtonColor: '#DD6B55', 
		  confirmButtonText: 'Yes, Discard Check-Out', 
		  closeOnConfirm: true},function(){ 
		
		var molFormat = $('[liveEditId="' + targetElement + '"]').attr('molFormat');

		try {
			// Check to make sure we don't have any unallowed chars in the file extension
			if (/\:/.test(molFormat) || molFormat.length == 0){
				console.log("WARRNING: Unallowed characters in file extension: " + molFormat + " Assuming \"cdx\"");
				molFormat = "cdx";
			}
	
			var fileId = $('[liveEditId="' + targetElement + '"]').attr('liveEditFileId');
			window.postMessage({ message_type: 'delete', file: '1-' + fileId + "." + molFormat}, window.location.href);
		
			var linkElement = $('[liveEditId="' + targetElement + '"]');
			$(linkElement).removeAttr('liveEditFileId');
				
			if($(linkElement).hasClass('isCheckedOut'))
			{
				$(linkElement).attr('onclick', 'editStructure("'+targetElement+'")');
				$(linkElement).removeClass('isCheckedOut');
			}
			
			//Remove the discard checkout button
			$('[discardliveeditid="' + targetElement + '"]').removeClass('isCheckedOut');
			$('[discardliveeditid="' + targetElement + '"]').hide();
	
	
			try {
				$('[liveEditId="' + targetElement + '"]').trigger('discardCheckout');
			}
			catch(e) {
				console.error("error calling discardCheckout... ", e);
			}
		}
		catch (exception) {
			swal({
				title: "Error",
				text: "There was an error with this reaction. Please contact support.",
				type: "error"
			});
		}
	
	});
}

/**
 * Does nothing, Needs to be here to make the drop area work
 * @param {event} e 
 */
function dragEnterLiveEdit(e) {
	e.stopPropagation();
	e.preventDefault();
  }

/**
 * Does nothing, Needs to be here to make the drop area work
 * @param {event} e 
 */
function dragOverLiveEdit(e) {
	e.stopPropagation();
	e.preventDefault();
}

/**
 * Takes the drop event, grabs the file(s) and passes it onto the function that actually does the upload work
 * @param {event} e drop event
 * @param {string} targetElement live edit id
 */
function dropLiveEdit(e, targetElement) {
	e.stopPropagation();
	e.preventDefault();

	const dt = e.dataTransfer;
	const files = dt.files;

	uploadLiveEdit(files, targetElement);
}

/**
 * Grabs the file(s) from pressing the upload button and passes it onto the function that actually does the upload work
 * @param {string} targetElement live edit ID
 */
function uploadButtonLiveEdit(targetElement){
	const files = document.getElementById("fileElem_" + targetElement).files;
	uploadLiveEdit(files, targetElement)
}

/**
 * Give this a file, and it will add it to the live editer
 * @param {Array} files The files to upload (we really only expect one)
 * @param {String} targetElement live editor ID to update
 */
function uploadLiveEdit(files, targetElement) {

	for (let i = 0; i < files.length; i++) {
		const file = files[i];

		const reader = new FileReader();
		reader.onload = (function (te) {
			return function (e) {
				//Remove the header
				fileStr = e.target.result.replace(/^.*?base64,/, "");
				//Leave base64:cdx alone, everything else needs to be base64 decoded
				if (!/^Vmp/.test(fileStr)) {
					fileStr = atob(fileStr);
				}
				//Send it to the editor
				updateLiveEditStructureData(te, fileStr, "", false);
			};
		})(targetElement);
		reader.readAsDataURL(file);
	}
}

function getEmptyMolFile()
{
	return "Untitled Document-1\n  Arxspan\n\n  0  0  0     0  0              0 V3000\nM  V30 BEGIN CTAB\nM  V30 COUNTS 0 0 0 0 0\nM  V30 BEGIN ATOM\nM  V30 END ATOM\nM  V30 END CTAB\nM  END\n";
}

function getEmptyEncodedMolFile()
{
	return "VmpDRDAxMDAEAwIBAAAAAAAAAAAAAAAAAAAAAAQCEACOqSEJ+AmjCPaO6flg72r5BAgEAAAAHgAAAw4AAgD///////8AAAAAAAAAARMAAQABAAEA4gQJAFNhbnNTZXJpZgGAAgAAAAaAAwAAAAQCEABCnHYBrPzoAEKclAGs/CQBAAIIAEKchQGs/AYBAAcYAAEAAAABAAAA8AADAE5vIFN0cnVjdHVyZQAAAAAAAA%3D%3D"
}

/**
 * Checks if a structure is empty or null.
 * @param {String} molData The data to check. 
 */
function molHasData(molData)
{
	if (molData)
	{
		return ![getEmptyMolFile(), getEmptyEncodedMolFile(), unescape(getEmptyEncodedMolFile())].includes(molData);
	}
	return false;
}

function copyStructure(elementId)
{
	var molData = unescape($('[liveEditId="' + elementId + '"]').attr('molData'));
	if((!molData) || (molData.length == 0))
	{
		swal("", "The structure data is empty so there is nothing to copy.", "warning");
		return;
	}

		
    var input = document.createElement('textarea');
    document.body.appendChild(input);
    input.value = molData;
    input.focus();
    input.select();
    document.execCommand('Copy');
    input.remove();
}

function checkoutSketch(targetElement, sketchId, molFormat)
{
	var cdId = sketchId.toString();
	var fileId = randomString(32, '#aA') + '-' + cdId;

	liveEditor.setIsCheckedOutCallback(function(msg, args) {
		var theTargetElement = args.targetElement;
		var fileId = args.fileId;
		
		console.log("--------------------- isCheckedOutCallback is running --------------------");
		var skipUpdateImageOnCheckin = $('[liveEditId="' + theTargetElement + '"]').attr('skipUpdateImageOnCheckin');

		$('[liveEditId="' + theTargetElement + '"]').attr('onclick', 'checkInStructure("'+theTargetElement+'", ' + skipUpdateImageOnCheckin + ')');
		$('[liveEditId="' + theTargetElement + '"]').attr('liveEditFileId', fileId);
		$('[liveEditId="' + theTargetElement + '"]').addClass('isCheckedOut');

		$('[discardliveeditid="' + theTargetElement + '"]').attr('onclick', 'discardCheckIn("'+theTargetElement+ '")');
		$('[discardliveeditid="' + theTargetElement + '"]').addClass('isCheckedOut');
		$('[discardliveeditid="' + theTargetElement + '"]').show();

		//Call the passed in callback
		$('[liveEditId="' + theTargetElement + '"]').trigger('finishCheckout',[msg, args]);

	}, {'targetElement':targetElement,
	   	'fileId': fileId});
		
	var postPayload = {
			message_type : 'checkout',
			attachmentId : fileId,
			cookies: document.cookie,
			url : window.location.protocol + '//' + window.location.hostname + '/arxlab/ajax_loaders/chemistry/getMoleculeById.asp?id='+cdId+'&tagId='+targetElement+'&source=cdxml&override=true',
			experimentType : '1',
			ext : '.'+molFormat
		};
	window.postMessage(postPayload, '*');
}

function editStructure(elementId)
{
	if(typeof requireProjectLink != "undefined")
	{
		if (requireProjectLink)
		{
			if (linksJSON_projects.length == 0)
			{
				swal("Error Editing Molecule", "This experiment requires a project link. Please link a project.", "error");
				return false
			}
		}
	}
	

	$('[liveEditId="' + elementId + '"]').attr('onclick', "");
	var molData = $('[liveEditId="' + elementId + '"]').attr('molData');
	var fileId = $('[liveEditId="' + elementId + '"]').attr('liveEditFileId');
	var molDataType = getFileFormat(molData);	
	if(molDataType == ""){
		molDataType = "cdxml";
	}
	$('[liveEditId="' + elementId + '"]').attr('molFormat', molDataType);
	
	if((!molData) || (molData.length == 0))
	{
		console.log("empty mol data, initializing...");
		// This is an empty v3000 mol file
		molData = getEmptyMolFile();
		checkoutSketch(elementId, "-1", molDataType);
		return;
	}
	else {
		molData = unescape(molData);
		
	
		var inputData = {'format':molDataType, 'structure': molData, 'targetElement': elementId};
		$.ajax({
			url: '/arxlab/ajax_loaders/chemistry/getMoleculeId.asp',
			type: 'POST',
			dataType: 'json',
			data: inputData,
			async: true,
			molFormat: molDataType,
			targetElement: elementId
		})
		.done(function(response) {
			if(response.hasOwnProperty("sketchId"))
			{

				var formating = this.molFormat.split(":");
				if (formating.length > 1)
				{
					molDataType = formating[1];
				}
				else 
				{
					molDataType = this.molFormat;
				}

				checkoutSketch(this.targetElement, response['sketchId'], molDataType);
			}
			else
			{
				swal("Error Editing Molecule", "There was a problem opening this molecule for editing. Please contact support@arxspan.com.", "error");
			}
		})
		.fail(function(error) {
				console.log(error);
				swal("Error Editing Molecule", "Unable to stage molecule for editing. Please contact support@arxspan.com.", "error");
		})
		.always(function() {
		});
	}
}

function decodeEntities(encodedString) {
	var textArea = document.createElement('textarea');
	textArea.innerHTML = encodedString;
	return textArea.value;
}

/**
 * Get Chemostry Editor Markup
 * 
 * @param {string} inputName - Id of the live editor
 * @param {string} className - Class name of the editor
 * @param {string} startingMolData - Starting Mol Data
 * @param {string} widthPixels	- Width of the editor in pixel
 * @param {string} heightPixels - Height of the editor in pixwl
 * @param {bool} readOnly	- The structure is read only if set
 * @param {string} chemistryChangedCallback - Changed callback function
 * @param {string} chemistryCheckedOutCallback - Checkout callback function
 * @param {string} discardCheckoutCallback - Discard callback function
 * @param {string} checkedoutId - Live Edit file ID
 * @param {bool} skipUpdateImageOnCheckin - The value of skipUpdateImageOnCheckin attribute
 * @param {string} marvinToolbars - Value for the Marvin toolbars attribute "data-toolbars"
 * @param {bool} MJSinModal - Has Marvin JS?
 */
function getChemistryEditorMarkup(inputName, className, startingMolData, widthPixels, heightPixels, readOnly, chemistryChangedCallback, chemistryCheckedOutCallback, discardCheckoutCallback, checkedoutId, skipUpdateImageOnCheckin, marvinToolbars, MJSinModal)
{
	return new Promise(function (resolve, reject) {
		//IE11 doesn't support default parameters, so we do this instead
		chemistryChangedCallback = chemistryChangedCallback || function () { };
		chemistryCheckedOutCallback = chemistryCheckedOutCallback || function (msg, args) { };
		discardCheckoutCallback = discardCheckoutCallback || function () { };
		checkedoutId = checkedoutId || null;
		skipUpdateImageOnCheckin = skipUpdateImageOnCheckin || false;
		marvinToolbars = marvinToolbars || "basicSearch";
		MJSinModal = MJSinModal || false;

		console.log("---------------------------- getChemistryEditorMarkup ----------------------------");
		var retval = "";

		re = /^\d+(%|px|cm|em|ex|in|mm|pc|pt|px|vh|vw|vmin)$/;
		if (!re.test(widthPixels)) {
			re2 = /^\d+$/;
			if (re2.test(widthPixels)) {
				cssWidth = widthPixels + "px";
			} else {
				cssWidth = "100%";
			}
		} else {
			cssWidth = widthPixels;
		}

		hasChemdraw().then(function (isInstalled) {
			if (isInstalled) {
				console.log("HAS CHEMDRAW IS TRUE");
				cd_AddToObjectArray(inputName);
				if (widthPixels == "100%") {
					widthPixels = "800"; //Chemdraw doesn't like 100% as a size
				}
				retval = cd_getSpecificObjectTag("chemical/mdl-molfile", widthPixels, heightPixels, inputName, "", readOnly, false);
				retval = $(retval).attr('molData', '').attr('liveEditId', inputName)[0].outerHTML;
				if (className && className.length)
					retval = $(retval).addClass(className)[0].outerHTML;

				resolve(retval);

				if (startingMolData && startingMolData.length > 0) {
					var myInterval = window.setInterval(function () {
						var caughtError = false;
						var mimeType = 'chemical/x-mdl-molfile';

						if (isCdxml(startingMolData))
							mimeType = "text/xml";

						// 5301: Async issue with IE here. The object might not be created yet when it is here so only clear out the interval when cd_putData is completed.
						var bPutData = false;
						try {
							bPutData = cd_putData(inputName, mimeType, decodeEntities(startingMolData));
						}
						catch (e) {
							caughtError = true;
							console.log("error putting data in ChemDraw control");
						}

						if (!caughtError && bPutData) {
							clearInterval(myInterval);
							console.log("cleared interval");
						}
					}, 250);
				}

				return;
			}
			else {
				if (hasMarvin && !readOnly && MJSinModal == false) {
					console.log("HAS MARVIN IS TRUE");
					retval = "<iframe id='" + inputName + "' name='" + inputName + "'liveEditId='" + inputName + "' src='" + window.location.protocol + "//" + window.location.hostname + "/arxlab/_inclds/chemAxon/marvinjs-19.11.0/editor.html' class='sketcher-frame' width='" + cssWidth + "' height='" + heightPixels + "px' data-toolbars='" + marvinToolbars + "' onload=\"setupMarvin('" + inputName + "','" + btoa(startingMolData) + "',false);\"></iframe>";
					resolve(retval);
					return;
				}
				else {
					var builderFunction = function (args) {
						if ((!args.hasOwnProperty('divId')) || (!args.hasOwnProperty('readOnly')))
							return true;

						var randomDivId = args['divId'];
						var readOnly = args['readOnly'];
						var cssWidth = args['cssWidth'];
						var preserveIMG = args['preserveIMG'];

						if ($('[liveEditId="' + randomDivId + '"]').length == 0) {
							return false;
						}
						var preserveImgHTML = false;
						if (preserveIMG != false && preserveIMG != undefined) {
							if ($('[liveEditId="' + randomDivId + '"] > div > a > .structureImage > svg').length > 0) {
								var preserveImgHTML = $('[liveEditId="' + randomDivId + '"] > div > a > .structureImage > svg')[0].outerHTML;
							}
						}

						var cbHtml = $('<link href="/arxlab/css/chemistryEditorHelper.css" rel="stylesheet" type="text/css" MEDIA="screen"/>')[0].outerHTML;

						var styleStr = 'width:' + cssWidth + '; height:' + heightPixels + 'px; clear:both;';
						if (preserveIMG == false || preserveIMG == undefined) {
							var emptyDivHtml = $('<div class="structureImage" />').attr('style', styleStr)[0].outerHTML;
						}
						else {
							var emptyDivHtml = $('<div class="structureImage" />').attr('style', styleStr).append(preserveImgHTML)[0].outerHTML;
						}

						var structureLink = $('<a href="javascript:void(0)" />').attr('liveEditId', inputName).attr('style', styleStr).attr('width', widthPixels).attr('height', heightPixels);

						if (className && className.length) {
							$(structureLink).addClass(className);
						}

						if (startingMolData && startingMolData.length) {
							$(structureLink).attr('molData', escape(startingMolData));
						}

						var discardButton = $('<a href="javascript:void(0)" />').addClass("discardCheckoutLink").attr('width', widthPixels).attr('discardLiveEditId', inputName).text('Discard Checkout').hide()[0].outerHTML;


						$(structureLink).html(emptyDivHtml + discardButton);

						if ((!readOnly) && (!liveEditor.hostAppInstalled)) {
							$(structureLink).addClass('installLiveEdit');
							if (MJSinModal == true){
								//These are smaller windows, using shorter text so it doesn't overflow
								$(structureLink).addClass('installLiveEditShort');
							}
							//Make a file input and a upload button
							var fileInput = $('<input />')
								.attr("type","file")
								.attr("id", "fileElem_" + inputName)
								.attr("multiple",false)
								.attr("accept","*.*")
								.attr('onchange', 'uploadButtonLiveEdit("' + inputName + '")')
								.hide()[0].outerHTML;
							var uploadButton = $('<a href="javascript:void(0)" />')
								.addClass("uploadLink")
								.attr('width', widthPixels)
								.attr('uploadLiveEditId', inputName)
								.attr('onclick', '	fileElem = document.getElementById("fileElem_' + inputName + '");if (fileElem) {fileElem.click();}')
								.text('Upload Structure')[0].outerHTML;

							//Make the live editor a drop area
							$(structureLink).html(emptyDivHtml + uploadButton + fileInput);
							structureImageContainer = $('<div class="structureImageContainer" style="width:' + cssWidth + '" />').html($(structureLink)[0].outerHTML)[0];
							structureImageContainer.setAttribute("ondragover","dragEnterLiveEdit(event)");
							structureImageContainer.setAttribute("ondragleave","dragOverLiveEdit(event)");
							structureImageContainer.setAttribute("ondrop","dropLiveEdit(event,\"" + inputName + "\")");
							cbHtml += $(structureImageContainer)[0].outerHTML;
						}
						else {
							if (readOnly) {
								$(structureLink).addClass('isReadOnly');
								$(structureLink).attr('onclick', 'copyStructure("' + inputName + '");');
							}
							else {
								if (MJSinModal == true && hasMarvin == true) {
									$(structureLink).addClass('editStructureLink');
									$(structureLink).addClass('mjs');
									$(structureLink).attr('onclick', 'editMJSPopup("' + inputName + '");');
								}
								else {
									$(structureLink).addClass('editStructureLink');
									$(structureLink).attr('onclick', 'editStructure("' + inputName + '");');
								}
							}
							cbHtml += $('<div class="structureImageContainer" style="width:' + cssWidth + '" />').html($(structureLink)[0].outerHTML)[0].outerHTML;
						}

						$('[liveEditId="' + randomDivId + '"]').html(cbHtml);

						var myPromise = new Promise(function (resolve, reject) {
							if (startingMolData && startingMolData.length) {
								//var molDataType = 'mol';
								var molDataType = getFileFormat(startingMolData);
								if (useChemDrawForLiveEdit) {
									if (molDataType == "cdx" || molDataType == "base64:cdx") {
										molDataType = "cdxml"; // Live edit currently needs cdxml on checkin, this should force it.
									}
								}

								$('[liveEditId="' + inputName + '"]').attr('molFormat', molDataType);
								getUpdatedLiveEditStructureImage(inputName, (!readOnly && skipUpdateImageOnCheckin), preserveImgHTML)
									.then(function () {
										resolve(true);
									});
							}
							else {
								$('[liveEditId="' + inputName + '"]').attr('molFormat', "cdxml");
								resolve(true);
							}
						})
							.then(function () {
								$('[liveEditId="' + inputName + '"]').on('chemistryChanged', chemistryChangedCallback);
								$('[liveEditId="' + inputName + '"]').on('discardCheckout', discardCheckoutCallback);
								$('[liveEditId="' + inputName + '"]').on('finishCheckout', chemistryCheckedOutCallback);

								$('[liveEditId="' + inputName + '"]').attr('skipUpdateImageOnCheckin', skipUpdateImageOnCheckin);

								if (checkedoutId != null && !readOnly) {
									//Used to start with the object already checked out.
									$('[liveEditId="' + inputName + '"]').attr('onclick', 'checkInStructure("' + inputName + '", ' + skipUpdateImageOnCheckin + ')');
									$('[liveEditId="' + inputName + '"]').attr('liveEditFileId', checkedoutId);
									$('[liveEditId="' + inputName + '"]').addClass('isCheckedOut');

									$('[discardliveeditid="' + inputName + '"]').attr('onclick', 'discardCheckIn("' + inputName + '")');
									$('[discardliveeditid="' + inputName + '"]').addClass('isCheckedOut');
									$('[discardliveeditid="' + inputName + '"]').show();
								}
							});

						return true;
					};

					var randomDivId = randomString(32, '#aA');
					retval = $('<div liveEditId="' + randomDivId + '" class="liveEditStructureHolder"/>')[0].outerHTML;
					resolve(retval);

					console.log("adding viewer");
					// Build a read-only view of the molecule to start with
					var myInterval2 = window.setInterval(function () {

						if (MJSinModal == true && hasMarvin == true && readOnly == false) {
							if (builderFunction({ 'divId': randomDivId, 'readOnly': readOnly, 'cssWidth': cssWidth })) {
								clearInterval(myInterval2);
							}
						}
						else {
							if (builderFunction({ 'divId': randomDivId, 'readOnly': readOnly, 'cssWidth': cssWidth })) {
								clearInterval(myInterval2);
							}
						}

					}, 100);

					if (liveEditor.browserAllowed && isTopWindow()) {
						console.log("adding installed callback");
						// Build a live editor instance since it is supported by this browser
						// AND we are not in an iframe
						liveEditor.addInstalledCallback(builderFunction, { 'divId': randomDivId, 'readOnly': readOnly, 'cssWidth': cssWidth, "preserveIMG": true });
					}
				}

				return;
			}
		});
	});
}

function stopScroll(event){
	//console.log("scroll stop div " + event.type);
	
	if (event.ctrlKey){
		//So chrome doesn't zoom the whole page
		if(/Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor)){
			event.preventDefault();
		}
	}else{
		//stop MJS from doing its thing.
		event.stopImmediatePropagation();
		event.stopPropagation();
		//Show the message, then fade it out
		$(this).find('#scrollStopMessage').show();
		$(this).find('#scrollStopMessage').fadeOut(2000);
	}
}

function setupMarvin(id, base64StartingMolData, skipAddStructs){
	MarvinJSUtil.getEditor("#"+id).then(function (sketcherInstance) {
		marvinSketcherInstance = sketcherInstance;
		//Set the rest services
		marvinSketcherInstance.setServices(getDefaultServices());
		if(!skipAddStructs){
			addMarvinStructs(marvinSketcherInstance);
		}
		
		
		turnOnOnchange = function(){
			if (typeof updateOnMolChange === 'function'){
			marvinSketcherInstance.on("molchange", updateOnMolChange);
			}
		};
		
		if(base64StartingMolData != ''){
			//unbase64 it and remove XML stuff from cdxml
			startingMolData = atob(base64StartingMolData).replace(/^.*<CDXML/gm, "<CDXML");
			marvinSketcherInstance.importStructure(getFileFormat(startingMolData), startingMolData).catch(function(){
				console.log("Error importing marvin structure");
				console.log("File Format: " + getFileFormat(startingMolData));
				console.log("MolData: " + startingMolData);
			}).then(function () {
				marvinReady = true;
				turnOnOnchange();
			});
		}else{
			marvinReady = true;
			turnOnOnchange();
		}

		//add scroll blocker
		if (id != undefined)
		{
				$($("iframe#"+id).last()).contents().find("canvas#canvas.mjs-canvas").wrap("<div id='scrollStop'></div>");
				$($("iframe#"+id).last()).contents().find("div#scrollStop").prepend("<h2 id='scrollStopMessage' style='position: absolute; text-align: center; left:0; right:0; display: none;' align='center'>Please use ctrl + scroll to zoom the reaction</h2>");
				$($("iframe#"+id).last()).contents().find("div#scrollStop").get(0).addEventListener("wheel", stopScroll, true);
				$($("iframe#"+id).last()).contents().find("div#scrollStop").get(0).addEventListener("DOMMouseScroll", stopScroll, true);
		}
	}).catch(function(e){
		console.error("Error loading Marvin", e);
		swal("","Error Loading Marvin","error");
	});
}

function addMarvinStructs(marvinSketcherInstance){
	console.log("add structs");
	var struct = {
		"structure": "<cml><MDocument><MChemicalStruct><molecule molID=\"m1\"><atomArray><atom id=\"a1\" elementType=\"C\" x2=\"-0.14556281800143966\" y2=\"-10.46205491026832\"/><atom id=\"a2\" elementType=\"C\" x2=\"0.33032335333597973\" y2=\"-11.926681945362857\"/><atom id=\"a3\" elementType=\"C\" x2=\"1.8707206996658452\" y2=\"-11.926525321541405\"/><atom id=\"a4\" elementType=\"C\" x2=\"2.345953065666064\" y2=\"-10.46213823885108\"/><atom id=\"a5\" elementType=\"C\" x2=\"1.1007368744419004\" y2=\"-9.556758778758443\"/></atomArray><bondArray><bond atomRefs2=\"a1 a2\" order=\"2\" id=\"b1\"/><bond atomRefs2=\"a2 a3\" order=\"1\" id=\"b2\"/><bond atomRefs2=\"a3 a4\" order=\"2\" id=\"b3\"/><bond atomRefs2=\"a4 a5\" order=\"1\" id=\"b4\"/><bond atomRefs2=\"a5 a1\" order=\"1\" id=\"b5\"/></bondArray></molecule></MChemicalStruct></MDocument></cml>",
		"name": "Cyclopentadiene"
	};
	marvinSketcherInstance.addTemplate(struct);

	var struct2 = {
		"structure": "<cml><MDocument><MChemicalStruct><molecule molID=\"m1\"><atomArray><atom id=\"a1\" elementType=\"C\" x2=\"9.9715\" y2=\"-10.721993333333334\"/><atom id=\"a2\" elementType=\"C\" x2=\"10.7415\" y2=\"-12.05666\"/><atom id=\"a3\" elementType=\"C\" x2=\"12.231193333333334\" y2=\"-11.666526666666668\"/><atom id=\"a4\" elementType=\"C\" x2=\"13.71216\" y2=\"-12.05666\"/><atom id=\"a5\" elementType=\"C\" x2=\"12.942160000000001\" y2=\"-10.721993333333334\"/><atom id=\"a6\" elementType=\"C\" x2=\"11.452466666666666\" y2=\"-11.112639999999999\"/></atomArray><bondArray><bond atomRefs2=\"a1 a2\" order=\"1\" id=\"b1\"/><bond atomRefs2=\"a2 a3\" order=\"1\" id=\"b2\"/><bond atomRefs2=\"a3 a4\" order=\"1\" id=\"b3\"/><bond atomRefs2=\"a4 a5\" order=\"1\" id=\"b4\"/><bond atomRefs2=\"a5 a6\" order=\"1\" id=\"b5\"/><bond atomRefs2=\"a6 a1\" order=\"1\" id=\"b6\"/></bondArray></molecule></MChemicalStruct></MDocument></cml>",
		"name": "Chair Cyclohexane"
	};
	marvinSketcherInstance.addTemplate(struct2);

	var struct3 = {
		"structure": "<cml><MDocument><MChemicalStruct><molecule molID=\"m1\"><atomArray><atom id=\"a1\" elementType=\"C\" x2=\"20.305753978261407\" y2=\"-10.36609149920834\"/><atom id=\"a2\" elementType=\"C\" x2=\"19.985569974402058\" y2=\"-11.8724388043384\"/><atom id=\"a3\" elementType=\"C\" x2=\"20.963845476606814\" y2=\"-13.062281297989191\"/><atom id=\"a4\" elementType=\"C\" x2=\"22.503935131969257\" y2=\"-13.038545252708055\"/><atom id=\"a5\" elementType=\"C\" x2=\"23.44506469033494\" y2=\"-11.82057484822663\"/><atom id=\"a6\" elementType=\"C\" x2=\"23.080693250921232\" y2=\"-10.325111640400436\"/><atom id=\"a7\" elementType=\"C\" x2=\"21.68340566128006\" y2=\"-9.677016787593567\"/></atomArray><bondArray><bond atomRefs2=\"a1 a2\" order=\"1\" id=\"b1\"/><bond atomRefs2=\"a2 a3\" order=\"1\" id=\"b2\"/><bond atomRefs2=\"a3 a4\" order=\"1\" id=\"b3\"/><bond atomRefs2=\"a4 a5\" order=\"1\" id=\"b4\"/><bond atomRefs2=\"a5 a6\" order=\"1\" id=\"b5\"/><bond atomRefs2=\"a6 a7\" order=\"1\" id=\"b6\"/><bond atomRefs2=\"a7 a1\" order=\"1\" id=\"b7\"/></bondArray></molecule></MChemicalStruct></MDocument></cml>",
		"name": "Cycloheptane Ring"
	};
	marvinSketcherInstance.addTemplate(struct3);

	var struct4 = {
		"structure": "<cml><MDocument><MChemicalStruct><molecule molID=\"m1\"><atomArray><atom id=\"a1\" elementType=\"C\" x2=\"29.684526666666667\" y2=\"-10.539246666666667\"/><atom id=\"a2\" elementType=\"C\" x2=\"29.684526666666667\" y2=\"-12.079246666666668\"/><atom id=\"a3\" elementType=\"C\" x2=\"31.01816666666667\" y2=\"-11.309246666666667\"/></atomArray><bondArray><bond atomRefs2=\"a1 a2\" order=\"1\" id=\"b1\"/><bond atomRefs2=\"a2 a3\" order=\"1\" id=\"b2\"/><bond atomRefs2=\"a3 a1\" order=\"1\" id=\"b3\"/></bondArray></molecule></MChemicalStruct></MDocument></cml>",
		"name": "Cyclopropane Ring"
	};
	marvinSketcherInstance.addTemplate(struct4);

	var struct5 = {
		"structure": "<cml><MDocument><MChemicalStruct><molecule molID=\"m1\"><atomArray><atom id=\"a1\" elementType=\"C\" x2=\"38.90399333333333\" y2=\"-9.97766\"/><atom id=\"a2\" elementType=\"C\" x2=\"38.90399333333333\" y2=\"-11.517660000000001\"/><atom id=\"a3\" elementType=\"C\" x2=\"40.44399333333333\" y2=\"-11.517660000000001\"/><atom id=\"a4\" elementType=\"C\" x2=\"40.44399333333333\" y2=\"-9.97766\"/></atomArray><bondArray><bond atomRefs2=\"a1 a2\" order=\"1\" id=\"b1\"/><bond atomRefs2=\"a2 a3\" order=\"1\" id=\"b2\"/><bond atomRefs2=\"a3 a4\" order=\"1\" id=\"b3\"/><bond atomRefs2=\"a4 a1\" order=\"1\" id=\"b4\"/></bondArray></molecule></MChemicalStruct></MDocument></cml>",
		"name": "Cyclobutane Ring"
	};
	marvinSketcherInstance.addTemplate(struct5);

	var struct6 = {
		"structure": "<cml><MDocument><MChemicalStruct><molecule molID=\"m1\"><atomArray><atom id=\"a1\" elementType=\"C\" x2=\"45.1143\" y2=\"-10.379086666666668\"/><atom id=\"a2\" elementType=\"C\" x2=\"45.1143\" y2=\"-11.919086666666667\"/><atom id=\"a3\" elementType=\"C\" x2=\"46.20308\" y2=\"-13.007866666666667\"/><atom id=\"a4\" elementType=\"C\" x2=\"47.74308\" y2=\"-13.007866666666667\"/><atom id=\"a5\" elementType=\"C\" x2=\"48.83186\" y2=\"-11.919086666666667\"/><atom id=\"a6\" elementType=\"C\" x2=\"48.83186\" y2=\"-10.379086666666668\"/><atom id=\"a7\" elementType=\"C\" x2=\"47.74308\" y2=\"-9.290306666666666\"/><atom id=\"a8\" elementType=\"C\" x2=\"46.20308\" y2=\"-9.290306666666666\"/></atomArray><bondArray><bond atomRefs2=\"a1 a2\" order=\"1\" id=\"b1\"/><bond atomRefs2=\"a2 a3\" order=\"1\" id=\"b2\"/><bond atomRefs2=\"a3 a4\" order=\"1\" id=\"b3\"/><bond atomRefs2=\"a4 a5\" order=\"1\" id=\"b4\"/><bond atomRefs2=\"a5 a6\" order=\"1\" id=\"b5\"/><bond atomRefs2=\"a6 a7\" order=\"1\" id=\"b6\"/><bond atomRefs2=\"a7 a8\" order=\"1\" id=\"b7\"/><bond atomRefs2=\"a8 a1\" order=\"1\" id=\"b8\"/></bondArray></molecule></MChemicalStruct></MDocument></cml>",
		"name": "Cyclooctane Ring"
	};
	marvinSketcherInstance.addTemplate(struct6);
}

/**
 * Returns a promise that will give you the cdx data
 * 
 * @param {string} elementId - The target elemant ID.
 * @param {bool} useParentWindow - Use the parent window if this flag is set.
 * @param {string} fileType - The file type.
 */
function getChemistryEditorChemicalStructure(elementId, useParentWindow, fileType)
{
	fileType = fileType || 'mrv'; //IE11 doesn't have default parameters, so we do this

	return new Promise(function (resolve, reject) {

		var dataWin = window;
		if (useParentWindow) {
			dataWin = window.parent;
		}

		var molChemStruct = "";
		var elementNameExists = $('[name="' + elementId + '"]', dataWin.document).length > 0;
		var elementIdExists = $('[liveEditId="' + elementId + '"]', dataWin.document).length > 0;

		hasChemdraw().then(function (isInstalled)
		{
			if (elementNameExists && (isInstalled || hasMarvin))
			{
				if (hasMarvin) {
					resolve(MarvinJSUtil.getEditor("#" + elementId)
						.then(function (marvinSketcherInstance) {
							return marvinSketcherInstance.exportStructure(fileType, { hasUID: true });
						}).then(function (cdxData) {
							return cdxData;
						}).catch(function (error) {
							console.log("Failed to get marvin data!", error);
						}));
				}
				else {
					resolve(dataWin.cd_getData(elementId, "text/xml"));
				}
			} else if (elementIdExists) {
				molChemStruct = dataWin.document.querySelectorAll('[liveEditId="' + elementId + '"]')[0].getAttribute('molData');
				if (molChemStruct !== null) {
					molChemStruct = unescape(molChemStruct);
				}
				resolve(molChemStruct);
			} else {
				reject("Element Not Found");
			}
		});
	});
}

function getFileFormat(fileData)
{
	if (/^<cml>/.test(fileData)) 
	{
		fileType = "mrv";
	}
	else if (/\$RXN/.test(fileData)) 
	{
		fileType = "rxn";
	} 
	else if (/\$MOL/.test(fileData)) 
	{
		fileType = "mol";
	} 
	else if (/ChemAxon file format v\d\d/.test(fileData)) 
	{
		fileType = "mrv";
	} 
	else if (/\$RXN V3000/.test(fileData)) 
	{
		fileType = "rxn:V3";
	} 
	else if (/V[23]000(.|[\r\n])*?\$\$\$\$/.test(fileData)) 
	{
		fileType = "sdf";
	} 
	else if (/\s*0\s+0\s+0\s+0\s+0\s+999\sV3000/.test(fileData))
	{
		fileType = "mol:V3";
	} 
	else if (/<CDXML/.test(fileData)) 
	{
		fileType = "cdxml";
	}
	else if (/ChemDraw \d\d/.test(fileData)) 
	{
		fileType = "base64:cdx";
		//fileData = reader.result.replace(/^data:[^;]*;base64,*/,'');
	} 
	else if (/^Vmp/.test(fileData)) 
	{
		fileType = "base64:cdx";
	}	
	else if (/^\s*\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+V2000/m.test(fileData)) 
	{
		fileType = "mol";
	}	
	else {
		//we don't know, see if jchem can figure it out.
		fileType = "";
	}
	return (fileType);
}

function getLargeImg(targetElement)
{
	if (targetElement == null || targetElement == undefined)
	{
		return(false);
	}
	else 
	{
		if (targetElement in storedLargeImgs)
		{
			return(storedLargeImgs[targetElement]);	
		}
		else
		{
			return(false);
		}
	}
}

var MJStempTarget = "";
function editMJSPopup(targetElement)
{
	MJStempTarget = targetElement;
	var linkElement = $('[liveEditId="' + targetElement + '"]');
	$(linkElement).attr('onclick', "submitMJS('" + targetElement + "')");

	getChemistryEditorChemicalStructure(targetElement, false).then(function (data) {

		//add popup to page and use marvin as the editor...
		//since it it a popup it can be larger than the normal view port 

		var popUpHTML = $("<div></div>");
		popUpHTML.addClass("modal");
		popUpHTML.addClass("fade");
		popUpHTML.addClass("in");
		popUpHTML.attr("id", "modalDialogMJS");
		popUpHTML.attr("role", "dialog");
		popUpHTML.attr("data-backdrop", "static");
		popUpHTML.attr("data-keyboard", "false");

		var popUpModalDialog = $("<div></div>");
		popUpModalDialog.addClass("modal-dialog");
		popUpModalDialog.css("width", "790px");

		var popupModalContent = $("<div></div>");
		popupModalContent.addClass("modal-content");
		popupModalContent.addClass("card");
		popupModalContent.css("width", "auto");

		var popupModalBody = $("<div></div>");
		popupModalBody.addClass("modal-body");
		popupModalBody.css("width", "auto");

		var submitMJSBtn = $("<button></button>");
		submitMJSBtn.text("Submit");
		submitMJSBtn.addClass("btn");
		submitMJSBtn.addClass("btn-sm");
		submitMJSBtn.addClass("btn-success");
		submitMJSBtn.on("click", function () {
			submitMJS(MJStempTarget);
		});

		var cancelMJSBtn = $("<button></button>");
		cancelMJSBtn.text("Discard");
		cancelMJSBtn.addClass("btn");
		cancelMJSBtn.addClass("btn-sm");
		cancelMJSBtn.addClass("btn-danger");
		cancelMJSBtn.on("click", function () {
			cancelMJS(MJStempTarget);
		});

		popupModalBody.append(submitMJSBtn, cancelMJSBtn);
		popupModalContent.append(popupModalBody);
		popUpModalDialog.append(popupModalContent);
		popUpHTML.append(popUpModalDialog);

		//add the modal to the window and then show it
		$('body').append(popUpHTML);
		$('#modalDialogMJS').modal('show');

		$('#modalDialogMJS').on('hide.bs.modal', function (e) {
			$("#modalDialogMJS").remove();
		})

		if (data == null) {
			data = "";
		}

		//add the mjs editor
		// var mjsEditor = getChemistryEditorMarkup('tempEditor', "", data, 750, 750, false)
		getChemistryEditorMarkup('tempEditor', "", data, 750, 750, false).then(function (mjsEditor)
		{
			$("#modalDialogMJS").children().children().children().append(mjsEditor);
		});
	});
}

function submitMJS(targetElement)
{
	//get the data from the mjs editor
	getChemistryEditorChemicalStructure('tempEditor', false).then(function(data){
		//find the item and replace the click handaler
		var linkElement = $('[liveEditId="' + MJStempTarget + '"]');
		$(linkElement).attr('onclick', "editMJSPopup('" + MJStempTarget + "')");
		$(linkElement).attr('moldata', data);

		//update data and img and close madal 
		getUpdatedLiveEditStructureImage(MJStempTarget);
		$('#modalDialogMJS').modal('hide');	
		
		try {	
			$('[liveEditId="' + targetElement + '"]').trigger('chemistryChanged');
		}
		catch(e) {
			console.log("error calling chemistryChanged... ", e);
		}

	});
}

function cancelMJS(targetElement)
{
	//discard change and close modal
	$('#modalDialogMJS').modal('hide');	
	var linkElement = $('[liveEditId="' + MJStempTarget + '"]');
	$(linkElement).attr('onclick', "editMJSPopup('" + MJStempTarget + "')");
}

/**
 * Get updated Live Editor hover image
 * 
 * @param {string} targetElement - Target element ID
 */
function getUpdatedLiveEditHoverImage(targetElement)
{
	return new Promise(function (resolve, reject) {
		var linkElement = $('[liveEditId="' + targetElement + '"]');
		var molDataType = $('[liveEditId="' + targetElement + '"]').attr('molFormat');
		var jchemProxyLoc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport";

		// Put a loading image in the box
		// remove the image that's in the structure box now
		var divHolder = $(linkElement).find(".structureImage");

		var molData = $(linkElement).attr('molData');
		var molDataStr = unescape(molData);

		molDataType = getFileFormat(molData);
		if (molDataType == "") {
			//try again with the escaped one
			molDataType = getFileFormat(molDataStr);
		}

		hasChemdraw().then(function (isInstalled) {
			if (isInstalled) {
				cd_putData(targetElement, "text/xml", molDataStr);
				$(linkElement).removeAttr('liveEditFileId');
				resolve(true);
				return;
			}
			else {
				if (molDataType == 'cdxml' && isCdxml(molDataStr)) {
					molDataStr = truncateCdxmlProlog(molDataStr);
				}

				//This removes the atom ids
				if (molDataType == 'mrv') {
					molDataStr = molDataStr.replace(/<scalar[^>]+_mjs::uid[^>]+>[^<]+<\/scalar>/gm, "");
				}
				theWidth = 300;
				try {
					theWidth = $(linkElement).parent()[0].offsetWidth - 2;
					if (theWidth == -2) {
						theWidth = 300;
					}
				} catch (e) {
					//Do nothing	
				}

				//same call with larger requested img
				var TheLargerImg = JSON.stringify({
					"structure": molDataStr,
					"parameters": "svg:headless,nosource,transbg,absLabelVisible,maxscale28,marginSize2,cv_off,atsiz0.5,w" + (theWidth * 2) + ",h" + (($(linkElement).attr('height') - 2) * 2),
					"inputFormat": molDataType
				});

				if (molDataStr == "undefined") {
					resolve(true);
				}
				else {
					//ask for the larger img 
					$.ajax({
						method: "POST",
						url: jchemProxyLoc,
						data: TheLargerImg,
						dataType: "json",
						contentType: "application/json",
						async: true,
						targetElement: targetElement
					}).done(function (msg) {
						if (msg.hasOwnProperty("structure")) {
							storedLargeImgs[this.targetElement] = msg['structure'];
						}
					});
				}
			}
		});
	});
}

/**
 * Helper function to convert a structure into CDXML.
 * @param {string} moldata The chemistry mol data to convert.
 */
function convertToCDXML(moldata) {
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: "/arxlab/ajax_doers/convertToCDXML.asp",
			data: {
				moldata: moldata,
			},
			type: "POST"
		}).done(function(cdxml) {
			resolve(cdxml);
		}).fail(function () {
			resolve("");
		});
	});
}

/**
 * Helper function to convert a structure into MRV.
 * @param {string} moldata The chemistry mol data to convert.
 */
function convertToMRV(moldata) {
	let molDataType = getFileFormat(moldata);
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport",
			data: JSON.stringify({
				"structure": moldata,
				"parameters": "MRV",
				"inputFormat": molDataType
			}),	
			dataType: "json",
			contentType: "application/json",
			type: "POST",
		}).done(function(response) {
			if ("structure" in response) {
				resolve(response["structure"]);
			} else {
				resolve(null);
			}
		});
	});
}

/**
 * Helper function to call the marvin dispatch to process the current chemistry data.
 * @param {string} mrvData The MRV data string.
 * @param {number} experimentId The experiment's ID.
 * @param {JSON} experimentJSON The experiment data.
 * @param {function} successFn The callbackFn to invoke on successful POST. Renamed to force a git update.
 */
function callMarvinDispatch(mrvData, experimentId, experimentJSON, successFn) {
	//IE11 doesn't support default parameters, so we do this instead
	successFn = successFn || function (data) { };
	return new Promise(function (resolve, reject) {
		$.ajax({
			url: "/arxlab/_inclds/experiments/chem/asp/chemDataMarvin.asp",
			data: {
				mrvData: mrvData,
				molData: "",
				experimentId: experimentId,
				experimentJSON: JSON.stringify(experimentJSON)
			},
			type: "POST",
		}).done(function (data) {
			successFn(mrvData);
			resolve();
		}).fail(function () {
			resolve();
			swal("Error Loading Reaction Data", "Please try your request again. If this problem persists, please contact support.", "error");
		});
	});
}