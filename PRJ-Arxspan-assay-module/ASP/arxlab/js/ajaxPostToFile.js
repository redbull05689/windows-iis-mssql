//ELN-603 This function should return success or error not the file data
function postDataToFile(url) {
	//synchronous ajax call
	console.log("URL>>"+ url);
	if (window.XMLHttpRequest) {              
		AJAX=new XMLHttpRequest();              
	} else {                                  
		AJAX=new ActiveXObject("Microsoft.XMLHTTP");
	}
	if (AJAX) {
		AJAX.open("POST", url, false);                             
		AJAX.send(null);
		if (AJAX.readyState == 4){
			if (AJAX.status == 200){
				//return AJAX.responseText; 
				return "success"
			}else{
				return AJAX.responseText;
			}
		}
	} else {
		return false;
	} 
}