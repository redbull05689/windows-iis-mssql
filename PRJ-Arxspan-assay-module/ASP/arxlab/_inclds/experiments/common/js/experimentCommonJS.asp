<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
	ssoFolderName = getCompanySpecificSingleAppConfigSetting("ssoFolderPathName", Session("companyId"))
%>
/* This script and many more are available free online at
The JavaScript Source!! http://javascript.internet.com
Created by: Robert Nyman | http://robertnyman.com/ */
function removeHTMLTags(strInputCode){
 		/* 
  			This line is optional, it replaces escaped brackets with real ones, 
  			i.e. < is replaced with < and > is replaced with >
 		*/	
 	 	strInputCode = strInputCode.replace(/&(lt|gt);/g, function (strMatch, p1){
 		 	return (p1 == "lt")? "<" : ">";
 		});
 		var strTagStrippedText = strInputCode.replace(/<\/?[^>]+(>|$)/g, "");
 		return strTagStrippedText;	
   // Use the alert below if you want to show the input and the output text
   //		alert("Input code:\n" + strInputCode + "\n\nOutput text:\n" + strTagStrippedText);	
}

var tableItemsToRemove = []

function removeTableItem(theUrl,theTR)
{
	swal({
		title: "Are you sure you wish to remove this file?",
		text: "You will not be able to recover this file!",
		confirmButtonText: "Yes",
		type: "warning",
		showCancelButton: true,
		reverseButtons: true
	}, function(isConfirm) {
		if (isConfirm) {
			removeItem(theUrl, theTR);
			sendAutoSave('experimentId',experimentJSON['experimentId']);
		}
		return false;
	});
}

function removeItem(theUrl, theTR) {
	// Abstracted this function out from the above removeTableItem function to be reused with removeFolder
	tableItemsToRemove.push(theTR)
	getFile(theUrl);
	$('#' + theTR).remove();
	addAttachmentsCount($(".fileName").length);
	unsavedChanges = true;
}

function removeFolder(folderId) {
	swal({
		title: "Are you sure you wish to remove this folder?",
		text: "You will not be able to recover this folder!",
		confirmButtonText: "Yes",
		type: "warning",
		showCancelButton: true,
		reverseButtons: true
	}, function(isConfirm) {
		if (isConfirm) {
			$.each(attachmentJSON, function(index, file) {
				if (file.folderId == folderId) {
					var url = "<%=mainAppPath%>/experiments/ajax/do/removeAttachment.asp?experimentType=" + experimentType + "&experimentId=" + experimentId + "&attachmentId=" + file.attachmentId + "<%=preQS%>&"
					removeItem(url, file.trId);
				}
			});
			sendAutoSave('experimentId',experimentJSON['experimentId']);
			// Calling updateAttachments here to make sure the folder objects are actually removed.
			updateAttachments();
		}
		return false;
	});
}

function addInventoryLink(id,amount,name,collectionName,fieldName,fragmentId){
	return new Promise(function(resolve, reject) {
		console.log("collectionName: ", collectionName);
		console.log("fieldName: ", fieldName);
		console.log("fragmentId: ", fragmentId);
		$.ajax({
			url: "<%=mainAppPath%>/experiments/ajax/do/addInventoryLink.asp",
			type: 'POST',
			dataType: 'html',
			data: { id: id,amount:amount,name:name,experimentId:<%=experimentId%>,experimentType:<%=experimentType%>,collectionName:collectionName,fieldName:fieldName,fragmentId:fragmentId}
		})
		.done(function(response) {
			console.log("inventory link added");
		})
		.fail(function() {
			console.log("inventory link failed");
		})
		.always(function() {
			resolve(true);
		});
	});
}

function multiFileUploadStart()
{
	reloadSubmitFrame2();
	window.setTimeout('waitForMultiUpload()',10000)
	return true;
}

function waitForNote()
{
	try
	{
		results = window.frames["submitFrame2"].document.getElementById("resultsDiv").innerHTML
		if (results == "success") 
		{
			noteTableInTabs = false
			for (i=0;i<mainTabs.length ;i++ )
			{
				if (mainTabs[i] == "noteTable")
				{
					noteTableInTabs = true
				}
			}
			if(!noteTableInTabs){mainTabs.push('noteTable')}
			document.getElementById("noteTable_tab").style.display = 'block';
			removeNoteEditors()
			htmlStr = getFile("<%=mainAppPath%>/experiments/ajax/load/getNoteTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand="+Math.random())
			document.getElementById("noteTable").innerHTML = htmlStr
			replaceNoteTableData()
			delayedRunJS(htmlStr)
			document.getElementById("noteName").value = "";
			CKEDITOR.instances["noteText"].setData('')
			hidePopup("noteDiv")
			if (mainTabSelected != "noteTable")
			{
				showMainDiv("noteTable")
			}
			unsavedChanges = true;
			positionButtons()
		}
		else
		{
			alert(results)
		}
		reloadSubmitFrame2()
	}
	catch(err)
	{
		setTimeout('waitForNote()',150)
	}
	return false;
}

function setNoteName(note_id) {
	var note_id_str = "#" + note_id;
	//console.log($(note_id_str).val());
	experimentJSON[note_id] = $(note_id_str).val();
}

function newElementalMachinesData()
{
	var emTableInTabs = false
	for (i=0;i<mainTabs.length ;i++ )
	{
		if (mainTabs[i] == "elementalMachinesTable")
		{
			emTableInTabs = true;
			break;
		}
	}
	
	if(!emTableInTabs) {
		mainTabs.push('elementalMachinesTable');
	}
		
	document.getElementById("elementalMachinesTable_tab").style.display = 'block';
	//var htmlStr = getFile("<%=mainAppPath%>/experiments/ajax/load/getElementalMachinesTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand="+Math.random())
	//document.getElementById("elementalMachinesTable").innerHTML = htmlStr
	
	if (mainTabSelected != "elementalMachinesTable") {
		showMainDiv("elementalMachinesTable");
	}
	
	checkEMCredentials(true);
}

function checkEMCredentials(addData) {
	
	// Check the session to see if the user credentials are saved in the session. If they are,
	// load the data div, otherwise load the credential div.
	$.ajax({
		url: '/arxlab/ajax_loaders/elementalMachines/checkSessionEMCredentials.asp',
		type: 'GET'
	})
	.success(function(response) {
		var respJson = JSON.parse(response);
		if (respJson["username"] == "" && respJson["password"] == "") {
			$("#elementalMachinesSignDiv").attr("addData", addData);
			showPopup('elementalMachinesSignDiv');
		} else {
			populateMachineList();
			if (addData) {
				showPopup('addElementalMachinesDataDiv');
			}
		}
	});
}

function getEMAnnotations() {

	var values = [];
	$("textarea.em_annotation").each(function() {
		values.push($(this).val());
	})
	return values;
}

function checkEMAnnotations() {

	var annotations = getEMAnnotations();

	return annotations.every(isFilledString);
}

function isFilledString(value) {
	return value != "";
}

function saveEMAnnotations() {
	var values = {};
	$("#elementalMachinesTable > table.attachmentsIndexTable > tbody > tr > td > textarea.em_annotation").each(function() {
		var id = $(this).attr("rownum");
		var annotation = $(this).val();

		if (annotation != "") {
			values[id] = annotation;
		}
	});

	$.ajax({
		url: '/arxlab/ajax_doers/elementalMachines/addEMAnnotations.asp',
		dataType: "json",
		type: 'POST',
		data: {
		  data: JSON.stringify(values),
		},
	}).success(function(response) {
		console.log(response);
	});
	return values;
}

function newNote()
{
	newId = getFile("<%=mainAppPath%>/experiments/ajax/do/new-note.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand="+Math.random())
	noteTableInTabs = false
	for (i=0;i<mainTabs.length ;i++ )
	{
		if (mainTabs[i] == "noteTable")
		{
			noteTableInTabs = true
		}
	}
	if(!noteTableInTabs){mainTabs.push('noteTable')}
	document.getElementById("noteTable_tab").style.display = 'block';
	removeNoteEditors()
	htmlStr = getFile("<%=mainAppPath%>/experiments/ajax/load/getNoteTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand="+Math.random())
	document.getElementById("noteTable").innerHTML = htmlStr
	replaceNoteTableData()
	delayedRunJS(htmlStr)
	//document.getElementById("noteName").value = "";
	CKEDITOR.instances["noteText"].setData('')
	hidePopup("noteDiv")
	if (mainTabSelected != "noteTable")
	{
		showMainDiv("noteTable")
		toggleNote('note_p_'+newId)
	}
	else
	{
		toggleNote('note_p_'+newId)
	}
	unsavedChanges = true;
	positionButtons()
}

function reloadAttachmentTable(){
	updateCK = false;
	attachmentTableInTabs = false
	for (i=0;i<mainTabs.length ;i++ )
	{
		if (mainTabs[i] == "attachmentTable")
		{
			attachmentTableInTabs = true
		}
	}
	if(!attachmentTableInTabs){mainTabs.push('attachmentTable')}
	document.getElementById("attachmentTable_tab").style.display = 'block';

	if(!updateCK){
		if (mainTabSelected != "attachmentTable"){
			showMainDiv("attachmentTable")
		}
	}else{
		CKEDITOR.instances[editorId].insertHtml("<img src='"+imageUrl+"' width='300' border='0'/>");
	}			

	el = document.getElementById("uploadFormHolder");
	if (el) {
		elRow = document.getElementById("attachmentTableFileUploadRow")
		if (elRow) {
			elRow.appendChild(el.parentNode.removeChild(el));
		}
		el.style.display = "none";
	}

	removeAttachmentEditors()
	htmlStr = getFile("/arxlab/ajax_loaders/getAttachmentTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand="+Math.random())
	document.getElementById("attachmentTable").innerHTML = htmlStr
	for (k=0;k<tableItemsToRemove.length ;k++ )
	{
		try{document.getElementById(tableItemsToRemove[k]).style.display = 'none';}catch(err){}
	}
	//alert("1")
	document.getElementById('fileName').value = "";
	//alert("2")
	CKEDITOR.instances['fileDescription'].setData('');
	//alert("3")
	document.getElementById("fileInputContainer").innerHTML = '<input type="file" name="file1" id="file1">'
	//alert("4")
	try{
	replaceAttachmentTableData()
	}catch(err){}
	//alert("5")
	delayedRunJS(htmlStr)
	//alert("6")
	//if(id == 0)
	//{
		unsavedChanges = true
	//}
	positionButtons()
	hidePopup('uploadingDiv')

	el = document.getElementById("uploadFormHolder");
	if (el) {
		elRow = document.getElementById("attachmentTableFileUploadRow")
		if (elRow) {
			elRow.appendChild(el.parentNode.removeChild(el));
		}
		el.style.display = "block";
	}
}

function waitForUpload(id)
{
	try
	{
		// Just making sure we can pull data from submitFrame2 no matter where we are.
		results = window.parent.window.frames["submitFrame2"].document.getElementById("resultsDiv").innerHTML;
		updateCK = false;
		if (results.split("|").length>1){
			updateCK = true;
			editorId = results.split("|")[1];
			imageUrl = results.split("|")[2];
		}
		results = results.split("|")[0]
		if (results == "success") 
		{
			attachmentTableInTabs = false
			for (i=0;i<mainTabs.length ;i++ )
			{
				if (mainTabs[i] == "attachmentTable")
				{
					attachmentTableInTabs = true
				}
			}
			if(!attachmentTableInTabs){mainTabs.push('attachmentTable')}
			document.getElementById("attachmentTable_tab").style.display = 'block';

			if(!updateCK){
				if (mainTabSelected != "attachmentTable"){
					showMainDiv("attachmentTable")
				}
			}else{
				// If there is the tocIframe, then we're probably in the custom experiments.
				if ($("#tocIframe").attr("src")) {
					$("#tocIframe")[0].contentWindow.CKEDITOR.instances[editorId].insertHtml("<img src='"+imageUrl+"' width='300' border='0'/>");
				} else {
					CKEDITOR.instances[editorId].insertHtml("<img src='"+imageUrl+"' width='300' border='0'/>");
				}
			}

			el = document.getElementById("uploadFormHolder");
			document.getElementById("uploadFormHolderHolder").appendChild(el.parentNode.removeChild(el));
			el.style.display = "none";

			removeAttachmentEditors()
			htmlStr = getFile("/arxlab/ajax_loaders/getAttachmentTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand="+Math.random())
			document.getElementById("attachmentTable").innerHTML = htmlStr
			for (k=0;k<tableItemsToRemove.length ;k++ )
			{
				try{document.getElementById(tableItemsToRemove[k]).style.display = 'none';}catch(err){}
			}
			document.getElementById('fileName').value = "";
			CKEDITOR.instances['fileDescription'].setData('');
			document.getElementById("fileInputContainer").innerHTML = '<input type="file" name="file1" id="file1">'
			replaceAttachmentTableData()
			delayedRunJS(htmlStr)
			//if(id == 0)
			//{
				unsavedChanges = true
			//}
			positionButtons()
			hidePopup('uploadingDiv')

			el = document.getElementById("uploadFormHolder");
			if (el) {
				elRow = document.getElementById("attachmentTableFileUploadRow")
				if (elRow) {
					elRow.appendChild(el.parentNode.removeChild(el));
				}
				el.style.display = "block";
			}
		}
		else
		{
			alert(results)
		}
		reloadSubmitFrame2()
	}
	catch(err)
	{
		console.log(err);
		setTimeout('waitForUpload(\'+id+\')',150)
	}
	return false;
}

function waitForMultiUpload()
{
	try
	{
		results = window.frames["submitFrame2"].document.body.innerHTML
		
		if (results.length > 500)
		{
			attachmentTableInTabs = false
			for (i=0;i<mainTabs.length ;i++ )
			{
				if (mainTabs[i] == "attachmentTable")
				{
					attachmentTableInTabs = true
				}
			}
			if(!attachmentTableInTabs){mainTabs.push('attachmentTable')}
			document.getElementById("attachmentTable_tab").style.display = 'block';
			removeAttachmentEditors()
			htmlStr = getFile("/arxlab/ajax_loaders/getAttachmentTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand="+Math.random())
			document.getElementById("attachmentTable").innerHTML = htmlStr
			for (k=0;k<tableItemsToRemove.length ;k++ )
			{
				try{document.getElementById(tableItemsToRemove[k]).style.display = 'none';}catch(err){}
			}
			replaceAttachmentTableData()
			delayedRunJS(htmlStr)
			if (mainTabSelected != "attachmentTable")
			{
				showMainDiv("attachmentTable")
			}
			unsavedChanges = true;
			positionButtons()
			hidePopup('multiFileDiv')
		}
		else{
			throw "yo"
		}
		reloadSubmitFrame2()
	}
	catch(err)
	{
		window.setTimeout('waitForMultiUpload()',150)
	}
	return false;
}

var attachmentTableData = []
var noteTableData = []

function removeNoteEditors()
{
	window.noteTableData = []
	els = document.getElementsByTagName("textarea");
	for(var i=0;i<els.length;i++){
		instanceName = els[i].id;
		if (instanceName.slice(0,5) == "note_")
		{
			baseName = instanceName.replace("description","");
			try{
				textData = CKEDITOR.instances[instanceName].getData();
				CKEDITOR.remove(CKEDITOR.instances[instanceName]);
			}catch(err){
				textData = document.getElementById(baseName+"description").value;
			}
			noteTableData.push([baseName, document.getElementById(baseName+"name").value , textData])
		}
	}
}

function replaceNoteTableData()
{
	for(i=0;i<noteTableData.length;i++)
	{
		noteName = noteTableData[i][1]
		if(noteName.replace(/^\s+|\s+$/g, "") == ""){noteName = "Untitled"}
		// This note could have been removed in memory
		if (document.getElementById(noteTableData[i][0]+"name"))
		{
			document.getElementById(noteTableData[i][0]+"name").value = noteName;
			document.getElementById(noteTableData[i][0]+"a").innerHTML = noteName.substring(0,40);
			document.getElementById(noteTableData[i][0]+"description").value = noteTableData[i][2];
			document.getElementById(noteTableData[i][0]+"description_preview").innerHTML = removeHTMLTags(noteTableData[i][2]).substring(0,50);
		}
	}
}

window.attachmentTableData = []

function removeAttachmentEditors()
{

	window.attachmentTableData = []
	els = document.getElementsByTagName("textarea");
	for(var i=0;i<els.length;i++){
		instanceName = els[i].id;
		if (instanceName.slice(0,5) == "file_")
		{
			baseName = instanceName.replace("description","");
			try{
				textData = CKEDITOR.instances[instanceName].getData();
				CKEDITOR.remove(CKEDITOR.instances[instanceName]);
			}catch(err){
				textData = document.getElementById(baseName+"description").value;
			}
			attachmentTableData.push([baseName, document.getElementById(baseName+"name").value , textData])
		}
	}
}

function replaceAttachmentTableData()
{
	//alert(JSON.stringify(attachmentTableData))
	for(i=0;i<attachmentTableData.length;i++)
	{
		thisName = attachmentTableData[i][1]
		if(thisName.replace(/^\s+|\s+$/g, "") == ""){thisName = "Untitled"}
		//alert("11")
		document.getElementById(attachmentTableData[i][0]+"name").value = thisName;
		//alert("12")
		try{
		document.getElementById(attachmentTableData[i][0]+"name_quick_link").innerHTML = thisName.substring(0,40);
		}catch(err){}
		//alert("13")
		document.getElementById(attachmentTableData[i][0]+"description").value = attachmentTableData[i][2];
		//alert("14")
		//document.getElementById(attachmentTableData[i][0]+"name_quick").innerHTML = removeHTMLTags(attachmentTableData[i][2]).substring(0,50);
	}
}

originalPageContentTDHeight = document.getElementById("pageContentTD").clientHeight;

function positionButtons()
{
	/*
	<%If subsectionId="experiment" then%>
	document.getElementById("tabBodyContainer").style.height = document.getElementById(mainTabSelected).clientHeight + "px";
	//ELN-541 Increasing the top height by 50px for the new "Experiment Details" container
	document.getElementById("submitRow").style.top = 220 + 50 + document.getElementById(mainTabSelected).clientHeight + "px";
	document.getElementById("pageContentTD").style.height = document.getElementById(mainTabSelected).clientHeight + 250 +"px";
	<%End if%>
	*/
}

function reloadSubmitFrame()
{
	f = document.getElementById("submitFrame")
	f.src = f.src
}

function reloadSubmitFrame2()
{
	f = document.getElementById("submitFrame2")
	f.src = f.src
}

function reloadUploadFrame()
{
	f = document.getElementById("upload_frame")
	f.src = f.src
}

function ssoSign()
{
	err = false;
	if ($("#requesteeIdBox").val() == -2 && $("#ssoSignStatusBox").val() == "2") {
		swal("Please select a Witness");
		err = true;
	}
	
	if (!document.getElementById("ssoVerify").checked)
	{
		alert("Please click reviewed to continue.");
		err = true;
	}
	
	el = document.getElementById("ssoSignStatusBox");
	keepOpen = el.options[el.selectedIndex].value;
	el = document.getElementById("requesteeIdBox")
	requesteeId = el.options[el.selectedIndex].value;
	
	if (requesteeId == "-1")
		requesteeId = "0";

	if(keepOpen=="1")
		keepOpenFlag = "1"
	else
		keepOpenFlag = "0"

	if(!err)
	{
		killIntervals();
		hidePopup("ssoSignDiv");
		keyString = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
		var signAuthUrl = "https://<%=rootAppServerHostName%><%=ssoFolderName%>sign.asp?state=SIGN&key="+keyString;
		console.log('signAuthUrl: ' + signAuthUrl);
		window.signingPopupWindow = window.open(signAuthUrl,"_blank");
		// Successful sign-in will call the experimentSubmit function to finalize the signing
		showPopup('ssoTokenDiv');

		// Looking at other tabs doesnt work for IE11
		var isIE11 = !!window.MSInputMethodContext && !!document.documentMode;
		
		window.repeatedlyCheckIfSigningPopupWindowClosed = setInterval(function(){
			
			if (checkForSSOKeyCookie(keyString)){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				ssoSignFinalize(keyString);

			}else if(window.signingPopupWindow.closed && !isIE11){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				//Double check to make sure that we didn't pick up on the closing of the window before we noticed the cookie
				if (checkForSSOKeyCookie(keyString)){
					ssoSignFinalize(keyString);
				}
			}
			else if(!$('#ssoTokenDiv').is(':visible')){
				window.signingPopupWindow.close();
			}
		},200);
	}
}
/**
* Grabs the cookie and kicks off the sign of the experiment, then deletes the cookie
* @param {string} cookieId - A random string used to find the unique cookie (does not include "ssoKey")
*/
function ssoSignFinalize(cookieId, abandon = false){
	pattern = new RegExp("(?:(?:^|.*;\\s*)ssoKey" + cookieId + "\\s*\\=\\s*([^;]*).*$)|^.*$");
	cookieValue = document.cookie.match(pattern);

	if (cookieValue[1] == "sign"){
		if (abandon) {
			abandonExperimentSubmit();
		}
		else {
			experimentSubmit(false,true,false, undefined, undefined, undefined);
		}
	}else if (cookieValue[1] == "type5"){
		// Better check to make sure the signing statuses are checked properly.
		if (!["4", "5"].includes(statusId)) {
			if (abandon) {
				abandonExperimentSubmit();
			}
			else {
				experimentSubmit(false,true,false, undefined, $("#requestId").val(), $("#requestRevisionId").val());
			}
		} 
	}

	//Delete cookie
	document.cookie = "ssoKey" + cookieId + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
}

/**
* Looks at the cookies for the ssoKey
* @param {string} cookieId - A random string used to find the unique cookie (does not include "ssoKey")
* @return {Boolean} True if cookie found. False if not found
*/
function checkForSSOKeyCookie(keyVal){
	if (document.cookie.split(';').filter(function(item) {
		return item.trim().indexOf("ssoKey" + keyString + "=") == 0
	}).length) {
		return true;
	}
	return false;
}

function ssoCoAuthorSign()
{
	err = false;
	if (!document.getElementById("ssoCoAuthorVerify").checked)
	{
		alert("Please click reviewed to continue.");
		err = true;
	}
	
	el = document.getElementById("ssoCoAuthorSignStatusBox");
	keepOpen = el.options[el.selectedIndex].value;
	requesteeId = "0";

	if(keepOpen=="1")
		keepOpenFlag = "1"
	else
		keepOpenFlag = "0"

	if(!err)
	{
		killIntervals();
		hidePopup("ssoCoAuthorSignDiv");
		keyString = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
		var signAuthUrl = "https://<%=rootAppServerHostName%><%=ssoFolderName%>sign.asp?state=SIGN&key="+keyString;
		console.log('signAuthUrl: ' + signAuthUrl);
		window.signingPopupWindow = window.open(signAuthUrl,"_blank");
		// Successful sign-in will call the addCoAuthorSignature function to finalize the signing
		showPopup('ssoTokenDiv');
		window.repeatedlyCheckIfSigningPopupWindowClosed = setInterval(function(){
			if (checkForSSOKeyCookie(keyString)){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				addCoAuthorSignature();
			}else if(window.signingPopupWindow.closed && !isIE11){
				hidePopup('ssoTokenDiv');
				clearInterval(window.repeatedlyCheckIfSigningPopupWindowClosed);
				//Double check to make sure that we didn't pick up on the closing of the window before we noticed the cookie
				if (checkForSSOKeyCookie(keyString)){
					addCoAuthorSignature();
				}
			}
			else if(!$('#ssoTokenDiv').is(':visible')){
				window.signingPopupWindow.close();
			}
		},200);
	}
}

function fixHTMLForCKEditor(s) {
	s = s.replace("&lt;","&amp;lt;");
	s = s.replace("&gt;","&amp;gt;");
	return s;
}

/**
 * Add the total number of attachments to the attachments table tab.
 * @param num The number of attachments.
 */
function addAttachmentsCount(num) {
	let attachmentText = "Attachment Table"
	let attachmentTab = $("#attachmentTable_tab");
	if (num && !isNaN(num) && num > 0) {
		attachmentTab.text(`${attachmentText} (${num})`);
	} else {
		attachmentTab.text(attachmentText);
	}
}

$(document).ready(function() {
    $.ajax({
        url: "<%=mainAppPath%>/_inclds/experiments/common/html/experimentTopRightFunctions.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&comments=<%=request.querystring("comments")%>",
        type: "GET",
        async: true,
        cache: false
    })
    .success(function (html) {
        var topRightInterval = setInterval(function() {
            var topRightElement = document.getElementById("topRightFunctionsAsp");
            if(topRightElement) {
                clearInterval(topRightInterval);
                $("#topRightFunctionsAsp").html(html);
            }
        });
    })
    .fail(function () {
        console.error("Unable to load experimentTopRightFunctions. Please contact support@arxspan.com.");
    });
});
