
//note used?

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
			delayedRunJS(htmlStr)
			document.getElementById("noteName").value = "";
			CKEDITOR.instances["noteText"].setData('')
			hidePopup("noteDiv")
			if (mainTabSelected != "noteTable")
			{
				showMainDiv("noteTable")
			}
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

function waitForUpload()
{
	try
	{
		results = window.frames["submitFrame2"].document.getElementById("resultsDiv").innerHTML
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
			delayedRunJS(htmlStr)
			if (mainTabSelected != "attachmentTable")
			{
				showMainDiv("attachmentTable")
			}
			positionButtons()
			hidePopup('uploadingDiv')
		}
		else
		{
			alert(results)
		}
		reloadSubmitFrame2()
	}
	catch(err)
	{
		setTimeout('waitForUpload()',150)
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
			delayedRunJS(htmlStr)
			if (mainTabSelected != "attachmentTable")
			{
				showMainDiv("attachmentTable")
			}
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

function removeNoteEditors()
{
	for(var instanceName in CKEDITOR.instances)
	{
		if (instanceName.slice(0,5) == "note_")
		{
			CKEDITOR.remove(CKEDITOR.instances[instanceName]);
		}
	}
}

function removeAttachmentEditors()
{
	for(var instanceName in CKEDITOR.instances)
	{
		if (instanceName.slice(0,5) == "file_")
		{
			CKEDITOR.remove(CKEDITOR.instances[instanceName]);
		}
	}
}
originalPageContentTDHeight = document.getElementById("pageContentTD").clientHeight;

function positionButtons()
{
	document.getElementById("tabBodyContainer").style.height = document.getElementById(mainTabSelected).clientHeight + "px";
	document.getElementById("submitRow").style.top = 120 + document.getElementById(mainTabSelected).clientHeight + "px";
	document.getElementById("pageContentTD").style.height = document.getElementById(mainTabSelected).clientHeight + 300 +"px";
}