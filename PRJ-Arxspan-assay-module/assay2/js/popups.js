inFrame = false;
globalLinkTarget = null;

function blackOn(){
	document.getElementById("contentDiv").style.visibility = "hidden";
	document.getElementById("blackDiv").style.display = "block";
	document.getElementById("blackFrame").style.display = "block";
}

function blackOff(){
	document.getElementById("contentDiv").style.visibility = "visible";
	document.getElementById("blackDiv").style.display = "none";
	document.getElementById("blackFrame").style.display = "none";
}

function linkPopOpen(c){
	blackOn();
	document.getElementById("linkFrame").src = "aev.asp?c="+c+"&list=true&inframe=true"
	document.getElementById("linkFrame").style.display = "block";
	window.scroll(0,0);
}
function linkPopClose(){
	blackOff();
	document.getElementById("linkFrame").src = "javascript:false;"
	document.getElementById("linkFrame").style.display = "none";
}
function processNewLink(link,theId){
	if(link.value==""){
		theText = "Untitled"
	}else{
		theText = link.value;
	}
	if(globalLinkTarget.value==""){
		globalLinkTarget.value = [];
	}
	globalLinkTarget.value.push({"id":theId,"linkText":theText,"collection":globalLinkTarget["options"].collection});
	outter = document.getElementById(globalLinkTarget.id);
	inner = document.getElementById(globalLinkTarget.id+"_links");
	inner.parentNode.removeChild(inner);
	outter.appendChild(buildInnerLinks(globalLinkTarget,globalLinkTarget.id,false));
	linkPopClose();
	globalLinkTarget.onchange();
}