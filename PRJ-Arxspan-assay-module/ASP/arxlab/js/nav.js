function navViewMore(theClass){
	elms = document.getElementById("sideNavSection").getElementsByTagName("*");
	els = [];
	for(i;i<elms.length;i++){
		if (elms[i].getAttribute('class')) {
			if(elms[i].getAttribute('class') == theClass){
				els.push(elms[i]);
			}
		} else if (elms[i].className) {
			if (elms[i].className == theClass) {
				els.push(elms[i]);
			}
		}
	}
	var stateSack = new sack();
	
	if(els[0].style.display == 'none' || els[0].style.display == ''){
		for(i=0;i<els.length;i++){
			els[i].style.display = "inline";
		}
		document.getElementById(theClass+"Link").innerHTML = "<< VIEW LESS";
		stateSack.requestFile = "/arxlab/ajax_doers/changeState.asp?stateId="+theClass+"&state=1&random="+Math.random();
		stateSack.onCompletion = function(){;};
		stateSack.runAJAX();
	}else{
		for(i=0;i<els.length;i++){
			els[i].style.display = "none";
		}
		document.getElementById(theClass+"Link").innerHTML = "VIEW MORE >>";
		stateSack.requestFile = "/arxlab/ajax_doers/changeState.asp?stateId="+theClass+"&state=0&random="+Math.random();
		stateSack.onCompletion = function(){;};
		stateSack.runAJAX();
	}
	return false;
}