function editTabName(id)
{
	document.getElementById(id+"_input").onkeypress = function(evt){try{if (evt.keyCode == 13){saveTabName(id);return false;}}catch(err){if (event.keyCode == 13){saveTabName(id);return false;}}}
	if (document.getElementById(id.replace("_tab","")+"_trivialName").value == '')
	{
		document.getElementById(id+"_input").value = document.getElementById(id+"_text").innerHTML
	}
	else
	{
		document.getElementById(id+"_input").value = document.getElementById(id.replace("_tab","")+"_trivialName").value
	}
	document.getElementById(id+"_input").style.display = "inline";
	document.getElementById(id+"_text").style.display = "none";
	document.getElementById(id+"_image").src = "images/btn_save.png"
	document.getElementById(id+"_link").onclick = function(){saveTabName(id)}
}
function saveTabName(id)
{
	var prefix = id.replace("_tab", "");
	nn = document.getElementById(id+"_input").value
	if (nn.length > 60)
	{
		nn = nn.substring(0,60)
	}
	document.getElementById(prefix+"_trivialName").value = nn
	document.getElementById(id+"_input").style.display = "none";
	document.getElementById(id+"_text").innerHTML = nn;
	document.getElementById(id+"_text").style.display = "inline";
	document.getElementById(id+"_image").src = "images/btn_edit.gif"
	document.getElementById(id+"_link").onclick = function(){editTabName(id)}
	experimentJSON[prefix+"_trivialName"] = nn;
	UAStates[prefix]["trivialName"] = true;
	unsavedChanges = true;
	var stringified_UAStates = JSON.stringify(UAStates[prefix]);
	sendAutoSave(prefix+"_trivialName", nn);
	sendAutoSave(prefix + "_UAStates", stringified_UAStates);
	experimentJSON[prefix + "_UAStates"] = stringified_UAStates;
	document.getElementById(prefix + "_UAStates").value = stringified_UAStates;
	sendGridAutoSave();
}