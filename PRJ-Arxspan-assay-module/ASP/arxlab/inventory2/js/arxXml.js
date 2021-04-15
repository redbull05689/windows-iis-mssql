if(typeof(String.prototype.trim) === "undefined")
{
    String.prototype.trim = function() 
    {
        return String(this).replace(/^\s+|\s+$/g, '');
    };
}

function xmlToString(xmlStr)
{
	try
	{
		return(new XMLSerializer()).serializeToString(xmlStr)
	}
  catch (e) {
      // Internet Explorer.
      return xmlStr.xml;
    }

}

function loadXML(xmlString)
{
  // ObjectExists checks if the passed parameter is not null.
  // isString (as the name suggests) checks if the type is a valid string.
    var xDoc;
    // The GetBrowserType function returns a 2-letter code representing
    // ...the type of browser.
    if (window.ActiveXObject)
	{
		bType = "ie"
	}
	else
	{
		bType = ""
	}

    switch(bType)
    {
      case "ie":
        // This actually calls into a function that returns a DOMDocument 
        // on the basis of the MSXML version installed.
        // Simplified here for illustration.
        xDoc = new ActiveXObject("MSXML2.DOMDocument")
        xDoc.async = false;
        xDoc.loadXML(xmlString);
        break;
      default:
        var dp = new DOMParser();
        xDoc = dp.parseFromString(xmlString, "text/xml");
        break;
    }
    return xDoc;
}