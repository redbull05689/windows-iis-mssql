function getFile(url) {
	//synchronous ajax call
  if (window.XMLHttpRequest) {              
    AJAX=new XMLHttpRequest();              
  } else {                                  
    AJAX=new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (AJAX) {
     AJAX.open("GET", url, false);                             
     AJAX.send(null);
     return AJAX.responseText;                                         
  } else {
     return false;
  } 
}

function getFileA(url,cb){
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}
	client.onreadystatechange=(function(client,cb){
		return function(){
			getFileACb(client,cb);
		}
	})(client,cb);
	client.open("GET", url, true);
	client.send(null);
	return false;
}

function getFileACb(client,cb){
	if (client.readyState == 4){
		if (client.status == 200){
			cb(client.responseText);
		}else{
			return false;
		}
	}
}