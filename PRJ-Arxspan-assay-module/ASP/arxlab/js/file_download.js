function downloadFile(mimeType,fileName,fileData)
{
	dlForm = document.createElement("form");
	dlForm.setAttribute("method","post");
	dlForm.setAttribute("action","/file-download.asp");
	
	hidden = document.createElement("input");
	hidden.type = "hidden";
	hidden.name = "mimeType";
	hidden.value = mimeType;
	dlForm.appendChild(hidden);

	hidden = document.createElement("input");
	hidden.type = "hidden";
	hidden.name = "fileName";
	hidden.value = fileName;
	dlForm.appendChild(hidden);

	hidden = document.createElement("input");
	hidden.type = "hidden";
	hidden.name = "fileData";
	hidden.value = fileData;
	dlForm.appendChild(hidden);

	document.body.appendChild(dlForm);

	dlForm.submit();

}