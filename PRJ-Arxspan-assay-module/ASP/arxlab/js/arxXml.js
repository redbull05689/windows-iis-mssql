if(typeof(String.prototype.trim) === "undefined"){
    String.prototype.trim = function() 
    {
        return String(this).replace(/^\s+|\s+$/g, '');
    };
}

function xmlToString(xmlStr){
  try{
      theStr = (new XMLSerializer()).serializeToString(xmlStr)
  }
  catch (e) {
      // Internet Explorer.
      theStr = xmlStr.xml;
  }
  //ie 11 gets a quote stuck in here for some reason sometimes
  theStr = theStr.replace('SYSTEM"',"SYSTEM")

  return theStr;
}

function loadXML(xmlString){
    // ObjectExists checks if the passed parameter is not null.
    // isString (as the name suggests) checks if the type is a valid string.
    var xDoc;
    // The GetBrowserType function returns a 2-letter code representing
    // ...the type of browser.
    if (window.ActiveXObject){
      bType = "ie"
    }
    else{
      bType = ""
    }

    switch(bType){
      case "ie":
        // This actually calls into a function that returns a DOMDocument 
        // on the basis of the MSXML version installed.
        // Simplified here for illustration.
        xmlString = xmlString.replace(/\n/g, "");
        xmlString = xmlString.replace(/\<(\?xml|(\!DOCTYPE[^\>\[]+(\[[^\]]+)?))+[^>]+\>/g, '');
        xDoc = new window.ActiveXObject("Microsoft.XMLDOM");
        xDoc.async = "false";
        //xDoc.setProperty("SelectionLanguage", "XPath");
        xDoc.loadXML(xmlString);
        break;
      default:
        var dp = new DOMParser();
        xDoc = dp.parseFromString(xmlString, "text/xml");
        break;
    }
    return xDoc;
}