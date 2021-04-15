function editTabName(id)
{
	document.getElementById(id+"_input").onkeypress = function(evt){try{if (evt.keyCode == 13){saveTabName(id);return false;}}catch(err){if (event.keyCode == 13){saveTabName(id);return false;}}}
	document.getElementById(id+"_input").value = document.getElementById(id+"_text").innerHTML
	document.getElementById(id+"_input").style.display = "block";
	document.getElementById(id+"_text").style.display = "none";
	document.getElementById(id).className = document.getElementById(id).className + " editingTab ";
}
function saveTabName(id)
{
	nn = document.getElementById(id+"_input").value
	if (nn.length > 60)
	{
		nn = nn.substring(0,60)
	}
	document.getElementById(id+"_input").style.display = "none";
	document.getElementById(id+"_text").innerHTML = nn;
	document.getElementById(id+"_text").style.display = "block";
	document.getElementById(id).className = document.getElementById(id).className.replace("editingTab","");
	getFile("/arxlab/projects/change-project-tab-name.asp?tabId="+id.replace("_tab","").replace("tab_","")+"&name="+nn)
}