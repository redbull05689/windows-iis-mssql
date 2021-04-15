function encodeIt(str){
    if(!str)
    {
        return "";
    }
    aStr = str.split('');
    i = aStr.length;
    aRet = [];
    while (--i>=0) {
        var iC = aStr[i].charCodeAt();
        if (iC> 255) {
        aRet.push('&#'+iC+';');
        } else {
        aRet.push(aStr[i]);
        }
    }
    return aRet.reverse().join('');
}