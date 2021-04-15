/**
 * Helper function to base16 encode the given str.
 * @param {string} str The string to encode.
 */
function encodeIt(str){
	var z
	
	if(!str){
		return "";
	}

 	var aStr = str.split(''),
	z = aStr.length,
	aRet = [];
   	
	   while (--z >= 0) {
    	var iC = aStr[z].charCodeAt();
    	
		if (iC > 255) {
      		aRet.push('&#'+iC+';');
    	} else {
			aRet.push(aStr[z]);
    	}
	}
	return aRet.reverse().join('');
}

/**
 * Helper function to decode unicode encoded double-byte strings.
 * @param {string} str The string to decode.
 */
function decodeDoubleByteString(str) {
	if (!str) {
		return str;
	}

	// We have to make sure ampersands aren't escaped too...
	str = str.replace(/&amp;/g, "&");

	// The format is &#{code};, so set a capturing group around all of it and replace with the results of the lambda.
	return str.replace(/(\&\#\d*;)/g, function(x) {

		// The code we want is all digits, so grab the digits, then return the string found at its charcode.
		var code = x.match(/(\d+)/g);
		return String.fromCharCode(code[0]);

	});

}
