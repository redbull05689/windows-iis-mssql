/**
 * Wrapper function for the paste handler function in the paste handler module.
 * @param {ClipboardEvent} event The paste event.
 * @param {string} ckId The ID of the CK editor being pasted into.
 */
function pasteHandler(event,ckId) {
	return pasteHandlerHelper.pasteHandler(event, ckId);
}

/**
 * Module for the CKEditor Paste Handler. Broken out from the old singular function to hopefully clean up the code.
 */
function pasteHandlerHelperModule() {

	// Detect if the current browser is FireFox so we don't do extra image processing with it.
	var isFirefox = typeof InstallTrigger !== "undefined";

	/**
	 * Handles paste events for the CKEditor and figures out if there's any processing that needs to be done for pasted objects.
	 * @param {ClipboardEvent} event The paste event.
	 * @param {string} ckId The ID of the CK editor being pasted into.
	 */
	var pasteHandler = function(event, ckId) {
		var items = event.clipboardData.items;
		//console.log(JSON.stringify(items)); // will give you the mime types
		if (items){

			// If there are two items in our clipboard, we need to determine if running anything in this handler is redundant.
			if (items.length == 2) {
				// Check to see if there's a base64 copy of an image being pasted into the editor and if there is, return because
				// the base64 string has already been pasted. Incredibly hacky because copying some images into the clipboard actually copies
				// two versions; a base64 copy and the actual image file, and I could not find any way to gracefully handle this and I didn't want
				// to disable the default paste functionality and reimplement it all.
				if (base64ClipboardChecker(items)) {
					return '';
				}
			}
			
			// Fallback on this if we haven't determined anything from the above.
			for(i=0;i<items.length;i++){
				if(items[i]["kind"]=="file" && items[i]["type"].indexOf("image")!=-1 && !$('textarea#comment').is(':focus') && !stopPasteHandler){
					base64ImageHandler(items[i], ckId);
				}
			}

		} else {

			types = event.clipboardData.types;
			for (var i=0;i<types.length;i++){
				if(types[i]=="public.tiff" || types[i].indexOf("CorePasteboard")!=-1){
					alert("Your browser does not allow the pasting of images into this section.");
					event.preventDefault();
					return false;
				}
			}

		}
		return '';
	}

	/**
	 * Callback function for when image files are read. Encodes the image file into base64, then inserts it into the specified CKEditor.
	 * @param {ProgressEvent} event The FileReader event.
	 * @param {string} ckId The ID of the CK editor being pasted into.
	 */
	var fileReaderCallbackFn = function(event, ckId) {
		base64 = event.target.result
		base64 = base64.substring(base64.indexOf(",")+1,base64.length)
		extension = event.target.result
		extension =  extension.substring(extension.indexOf("/")+1,extension.indexOf(";"))
		//console.log(event.target.result)
		//console.log(base64)
		document.getElementById("base64File").value = base64;
		document.getElementById("base64FileExtension").value = extension;
		if(ckId){
			document.getElementById("base64FileCKEditorId").value = ckId;
			// This is a really bad way of figuring out whether or not we're in a custom experiment CKEDITOR or not.
			// Basically, the non-iframe CKEDITORs have hard-coded ckIds that start with 'e_' so I'm relying on that
			// to figure out where the CKEDITOR variable lives.
			if (ckId.indexOf("e_") < 0) {
				$("#tocIframe")[0].contentWindow.CKEDITOR.instances[ckId].insertHtml("<img src='data:image/png;base64," + base64 + "'>");
			} else {
				CKEDITOR.instances[ckId].insertHtml("<img src='data:image/png;base64," + base64 + "'>");
			}
		} else{
			// Non-CKEDITOR instances just go through the usual file-upload process.
			document.getElementById("base64FileCKEditorId").value = "";
			showPopup("addFileDivBase64");
		}
	}
	
	/**
	 * Handler function for images in the passed DataTransferItem object.
	 * @param {DataTransferItem} item A DataTransferItem of kind "file".
	 * @param {string} ckId The ID of the CK editor being pasted into.
	 */
	var base64ImageHandler = function(item, ckId) {

		// Firefox seems to handle image pasting just fine, so we won't do our base64 encoding for it.
		if (isFirefox) {
			return;
		}

		var blob = item.getAsFile();
		var reader = new FileReader();
		reader.onload = function(event){
			fileReaderCallbackFn(event, ckId);
		};
		reader.readAsDataURL(blob);
	}
	
	/**
	 * Checks to see if the given clipboard list has an image and a text object.
	 * @param {DataTransferItemList} clipboardItemList The clipboard list. Must only be used with a two item list.
	 */
	var base64ClipboardChecker = function(clipboardItemList) {
		return (clipboardItemList[0]["type"].indexOf("image") != 1 && clipboardItemList[1]["type"].indexOf("text") != 1) || 
			(clipboardItemList[0]["type"].indexOf("text") != 1 && clipboardItemList[1]["type"].indexOf("image") != 1);
	}

	return {
		pasteHandler: pasteHandler,
	};
};

var pasteHandlerHelper = pasteHandlerHelperModule();