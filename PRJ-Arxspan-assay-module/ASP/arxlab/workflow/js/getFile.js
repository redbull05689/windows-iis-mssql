function getFile(url,errorOnTimeout) {
	//synchronous ajax call
  if (window.XMLHttpRequest) {              
    AJAX=new XMLHttpRequest();              
  } else {                                  
    AJAX=new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (AJAX) {
     AJAX.open("GET", url, false);                             
     AJAX.send(null);
	 if(errorOnTimeout){
		 if(AJAX.status == '500'){
			errorOnTimeout();
		 }
	 }
     return AJAX.responseText;                                         
  } else {
     return false;
  } 
}
function getFileA(url) {
	//synchronous ajax call
  if (window.XMLHttpRequest) {              
    AJAX=new XMLHttpRequest();              
  } else {                                  
    AJAX=new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (AJAX) {
     AJAX.open("GET", url, true);                             
     AJAX.send(null);
     //return AJAX.responseText;                                         
  } else {
     return false;
  } 
}