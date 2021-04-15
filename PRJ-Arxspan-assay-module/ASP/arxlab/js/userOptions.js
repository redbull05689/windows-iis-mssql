function setUserOption(theKey,theVal,cb){
	userOptions[theKey] = theVal;
	$.post( "/arxlab/misc/ajax/do/saveUserOptions.asp", { thePairs: JSON.stringify([{"theKey":theKey,"theVal":theVal}])})
		.done(function(){if(cb!=undefined){cb()}})
}