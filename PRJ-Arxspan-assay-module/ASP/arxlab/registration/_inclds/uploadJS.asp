function preUpload(id)
{
	if (id !='')
	{
		if (document.getElementById(id).value=="")
		{
			alert("Please enter a file")
			return false;
		}
	}	
	return ShowProgress(id);
}


function ShowProgress(id)
{
  strAppVersion = navigator.appVersion;
	el = document.getElementById(id)
  if (el.value != "")
  {
	matches = el.value.match(/\.[a-zA-Z0-9]{3,9}$/)
	if (matches)
	{
		fileExtension = matches[0].replace(".","")
	}
	else
	{
		fileExtension = ""
	}
	if (fileExtension != "exe" && fileExtension != "msi" && fileExtension != "bat" && fileExtension != "pif" && fileExtension != "cmd")
	{
		if (strAppVersion.indexOf('MSIE') != -1 && strAppVersion.substr(strAppVersion.indexOf('MSIE')+5,1) > 4)
		{
		  winstyle = "dialogWidth=385px; dialogHeight:140px; center:yes";
		  window.showModelessDialog('<% = barref %>&b=IE',null,winstyle);
		}
		else
		{
		  window.open('<% = barref %>&b=NN','','width=375,height=115', true);
		}
	}
	else
	{
		alert("Invalid File Type")
		return false;
	}
  }
  else
  {
  return false
  }
}

