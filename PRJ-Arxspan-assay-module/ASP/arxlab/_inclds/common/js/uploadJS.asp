<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
function preUpload(id)
{
		if (document.getElementById("Folder1").value == "")
		{
			if (id != '')
			{
				if (document.getElementById("file1_"+id).value=="")
				{
					return false;
				}
			}
			
		}	
		else
		{
		 	console.log("FALSE");
			UploadFolder();
			return(false); 
		}
	return ShowProgress(id);
}

function UploadFolder()
{
	//get the element 
	elem = document.getElementById("Folder1");
	//get the form to be submitted
	var data =	document.getElementsByName("file_form");
	UrlArray = [];

	//make sure all files in the folder are leagal
	for (n = 0; n < elem.files.length; n++)
	{
		
		F = elem.files[n];
		console.log(F);
		matches = F.name.match(/\.[a-zA-Z0-9]{3,9}$/);
		
		if (matches)
		{
			fileExtension =	matches[0].replace(".","")
			if(fileExtension != "exe" && fileExtension != "msi" && fileExtension != "bat" && fileExtension != "pif" && fileExtension != "cmd")
			{
				path = F.webkitRelativePath.split("/");

				RelPath = "";

				for (i=0;i<path.length;i++)
				{
					if (i != path.length - 1)
					{
						RelPath += path[i] + "/";
					}
				}
				//set up the url that will be used for the form and add it to an array to be prossesed later 
				urlLocations = "/arxlab/experiments/upload-file.asp?experimentType="+document.getElementById("experimentType").value+"&experimentId="+document.getElementById("experimentId").value+"&jqfu=1&FolUp=1"+"&random="+Math.random()+"&filename="+encodeURIComponent(encodeIt(F.name))+"&path="+encodeURIComponent(encodeIt(RelPath)),
				UrlArray.push(urlLocations)
					
			}
			else
			{
				console.log("File Not accepted: " + F.name);
				return(false);
			}

		} 

	} 
	
	//if the url array has some sort of items it continues 
	if (UrlArray.length > 0)
	{
		showPopup('uploadingDiv')
		hidePopup('addFileDiv');
		submitFormAndWait(0,data[0], UrlArray)
	}
}

function submitFormAndWait(i, FrmDta, urls) 
{				
	//this is used so that the form does not cancel itself out. 
	//without this only the last file gets uploaded 
	Frm = FrmDta
	Frm.action = UrlArray[i];
	Frm.onsubmit = null;
	Frm.submit();

	if (i < urls.length)
	{
		setTimeout(function(){ submitFormAndWait(i + 1, FrmDta, urls ); }, 750);
	}
	else
	{
		//this is used to make the subfolders nest correctly 
		url = "<%=mainAppPath%>/ajax_doers/updateAttachmentTableWithFolderId.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>";
		console.log("url: "+url);
		var update = postDataToFile(url);
		if(update=="success")
		{
			console.log("success");
			//window.location.reload();
		}

		//reset the form to clear last input
		document.getElementsByName("file_form")[0].reset()
		hidePopup('uploadingDiv');
		//reload attatchment table
		updateAttachments();
	}


}

function ShowProgress(id)
{
  strAppVersion = navigator.appVersion;
  if (id == 0)
  {
		el = document.getElementById("file1")
  }
  else
  {
		el = document.getElementById("file1_"+id)
  }
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
  reloadSubmitFrame2();
  try{hidePopup('addFileDiv_'+id)}catch(err){}
  hidePopup('addFileDiv')
  showPopup('uploadingDiv')
  waitForUpload(id);
  return true;
}

function preUploadBase64(){
  reloadSubmitFrame2();
  hidePopup('addFileDivBase64')
  showPopup('uploadingDiv')
  waitForUpload(0);
  return true;
}