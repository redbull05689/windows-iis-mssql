function editAttachmentName(id,attachmentId)
{
	document.getElementById(id).style.display = "inline";
	document.getElementById(id+"_link").style.display = "none";
	document.getElementById(id+"_image").src = "images/btn_save.png"
	document.getElementById(id+"_image_link").onclick = function(){finishEditAttachmentName(id,attachmentId);return false;}
	
}
function finishEditAttachmentName(id,attachmentId)
{
	//name= encodeURIComponent(document.getElementById(id).value)
	//getFile("/arxlab/experiments/ajax/do/change-attachment-name.asp?attachmentId="+attachmentId+"&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&name="+name)
	document.getElementById(id).style.display = "none";
	document.getElementById(id+"_link").innerHTML = document.getElementById(id).value;
	document.getElementById(id+"_link").style.display = "inline";
	document.getElementById(id+"_image").src = "images/btn_edit.gif"
	document.getElementById(id+"_image_link").onclick = function(){editAttachmentName(id,attachmentId);return false;}
	document.getElementById(id.replace("_quick","")).value = document.getElementById(id).value
	experimentJSON[id.replace("_quick","")] = document.getElementById(id).value;
	sendAutoSave(id.replace("_quick",""),document.getElementById(id).value);
}