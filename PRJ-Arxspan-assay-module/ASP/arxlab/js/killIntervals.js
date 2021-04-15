function killIntervals(){
	try{window.clearInterval(checkExportInterval);}catch(err){}
	try{window.clearInterval(importInterval);}catch(err){}
	try{window.clearInterval(checkNewVersionInterval);}catch(err){}
	try{window.clearInterval(bounceInterval);}catch(err){}
	try{window.clearInterval(warningInterval);}catch(err){}
	try{window.clearInterval(gssInterval);}catch(err){}
	try{window.clearInterval(usi);}catch(err){}
	try{window.clearInterval(ucInt);}catch(err){}
	try{window.clearInterval(checkNewNotificationsInterval);}catch(err){}
	try{window.clearInterval(checkNewNotificationsInterval2);}catch(err){}
	try{window.clearInterval(aInt);}catch(err){}
	//ftui
	//try{window.clearInterval(getHeaderNotificationsInterval);}catch(err){}
}