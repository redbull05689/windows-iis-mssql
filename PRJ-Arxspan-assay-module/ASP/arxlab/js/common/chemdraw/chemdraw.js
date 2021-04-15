/**
 *
 * This is a Javascript library to write multi-browser pages comprising CS ChemDraw Plugin/ActiveX.
 *
 * You will use the following three functions in your web pages:
 *  cd_insertObjectStr()
 *  cd_insertObject()
 *  cd_includeWrapperFile()
 *
 * To support other browsers outside IE and Netscape, you should change the following function:
 *  cd_figureOutUsing()
 *
 * Usually there is no need for you to change any other variables or functions.
 *
 * All Rights Reserved.
 *
 * ***PLEASE DON'T FORGET CHANGE THE VERSION NUMBER BELOW WHEN CHANGING THIS FILE***
 * (version 1.047) 7/13/2005
 */

/**
 * This function checks for user browser information such as type and verison.
 */
function _checkBrowser(){
	var matched, browser;
	function uaMatch( ua ) {
		ua = ua.toLowerCase();
		var match = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
			 /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
			 /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
			 /(msie) ([\w.]+)/.exec( ua ) ||
			 ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) ||
			 [];
		return {
			browser: match[ 1 ] || "",
			version: match[ 2 ] || "0"
		};
	}
	matched = uaMatch( navigator.userAgent );
	browser = {};
	 if ( matched.browser ) {
		 browser[ matched.browser ] = true;
		 browser.version = matched.version;
	 }
	 if ( browser.chrome ) {
		 browser.webkit = true;
	 } else if ( browser.webkit ) {
		 browser.safari = true;
	 }
	 if(!(window.ActiveXObject) && "ActiveXObject" in window){
		browser = {"msie":true}
		try{
			browser["version"] = matched.version
		}catch(err){}
	 }
	 return browser;
}


// ------------------------------------- GLOBAL DATA -------------------------------------------
// Global data. VERY IMPORTANT: never never change these.
var CD_CONTROL200CLSID  = "clsid:63CF1336-E07A-4CD3-9DC9-755E7CE2120D";
var CD_CONTROL190CLSID  = "clsid:84328ED3-9299-409F-8FCC-6BB1BE585D08";
var CD_CONTROL180CLSID	= "clsid:BFC17D2E-4BAB-4DA2-AFFE-0554CD12FFAF";
var CD_CONTROL170CLSID	= "clsid:DE727D51-7109-4A3A-8F67-94AECB3D9782";
var CD_CONTROL160CLSID	= "clsid:B8350810-35B3-46F8-AA9B-FC649FFF06DF";
var CD_CONTROL150CLSID	= "clsid:F974516A-2072-4af1-B063-489FAA6D4177";
var CD_CONTROL140CLSID	= "clsid:8B0D4252-4E82-463a-84ED-E8A796C4808A";
var CD_CONTROL130CLSID	= "clsid:8B0D4252-4E82-463a-84ED-E8A796C4808A";
var CD_CONTROL120CLSID	= "clsid:4A6F3C59-D184-49FA-9189-AF42BEDFE5E4";
var CD_CONTROL110CLSID	= "clsid:45C31980-E065-49A1-A3D7-E69CD40DAF66";
var CD_CONTROL100CLSID	= "clsid:7EF697A4-D9F3-4303-9161-BBBEA1C30097";
var CD_CONTROL90CLSID	= "clsid:60257C74-D60B-41D6-9296-A08BD51F15B5";
var CD_CONTROL80CLSID	= "clsid:51A649C4-3E3D-4557-9BD8-B14C0AD44B0C";
var CD_CONTROL70CLSID	= "clsid:AF2D2DC1-75E4-4123-BC0B-A57BD5C5C5D2";
var CD_CONTROL60CLSID	= "clsid:FA549D21-6F54-11D2-B61B-00C04F736BDF";

var CD_CONTROL_CLSID	= CD_CONTROL120CLSID;

// These three files should be placed in the same folder as the three .js files.

var CD_PLUGIN_JAR	= "camsoft.jar";
var CD_PLUGIN_CAB	= "camsoft.cab";
var CD_PLUGIN_CAB2	= "camsoft2.cab";

// These functions allow override of the above hard-coded settings.

function setPluginJarLocation(location)  { CD_PLUGIN_JAR = location;  }
function setPluginCabLocation(location)  { CD_PLUGIN_CAB = location;  }
function setPluginCab2Location(location) { CD_PLUGIN_CAB2 = location; }

// MOST IMPORTANT!!! To indicate which Plugin/ActiveX to use
// 1 - Control/ActiveX;  2 - old Plugin;  3 - new Plugin.

var cd_currentUsing = 0;
var js_canUseTry = false;

// Default threshold can be overridden by declaring it previously in page
if (!cd_plugin_threshold) var cd_plugin_threshold = 5.0;

// !DGB! 12/01
// Declare global array to hold the names of cd_objects in the page
var cd_objectArray = new Array();


// ------------------------------------- TODO AREA -------------------------------------------
// You may change this section when configuring for your website.


// These two variables define the URL for downloading the Plugin/ActiveX control. You may change
// it to your own download address if you choose.

if (!CD_AUTODOWNLOAD_PLUGIN) {
	var CD_AUTODOWNLOAD_PLUGIN  = "http://accounts.cambridgesoft.com/login.cfm?serviceid=11&fp=true";
}
var CD_AUTODOWNLOAD_ACTIVEX = CD_AUTODOWNLOAD_PLUGIN;

/**
 * This function is very important; I is run before anything else, to figure out which Plugin/ActiveX control should be used.
 * If you would like to configure this to recognize other types of browsers (by default, only
 * MS Internet Explorer and Netscape are recognized) you may add to this function.
 */
function cd_figureOutUsing() {

	// ChemDraw Plugin isn't availabe on IE, MAC
	if (cd_IsMacWithIE()) {
		cd_currentUsing = 0;
		return;
	}


	// Only 1, 2, 3 are used. Other codes make no sense.
	// 1 - Control/ActiveX;  2 - old Plugin;  3 - new Plugin.
	
	var version = cd_getBrowserVersion();
	
	// CURRENT SETTING:
	//    ActiveX Control (1) - IE 5.5 or higher versions
	//    old Plugin      (2) - IE 5.0 or lower versions, Netscape 4.x or lower versions
	//    new Plugin      (3) - Netscape 6.0 or higher versions
	if (cd_testBrowserType("Microsoft Internet Explorer")) {
		if (version < cd_plugin_threshold)
			cd_currentUsing = 2;
		else
			cd_currentUsing = 1;
		if (version >= 5.5)
			js_canUseTry = true;
	}
	else if (cd_testBrowserType("firefox")) {
			cd_currentUsing = 3
			js_canUseTry = true;
	}


	// TODO: add code to support other browsers beside IE and Netscape
	// else if (...)
	//		cd_currentUsing = 1 or 2 or 3;


	// Unknown browser type.
	else{
		cd_currentUsing = 0;
		js_canUseTry = true;
	}

}




// -------------------------------- FUNCTIONS USED IN WEB PAGES --------------------------------------
// The following three functions will be used in web pages

/**
 * This function is used to insert a browser-specific Plugin/ActiveX Control object using a string to specify parameters.
 * @param {any} tagStr - should be like following sample:
 *	cd_insertObjectStr("<EMBED src='HTML/blank.cdx' align='baseline' border= '0' width='267' height='128' type= 'chemical/x-cdx' name= 'myCDX'>");
 */
function cd_insertObjectStr(tagStr) {

	var paraArray = {"type" : "", "width" : "", "height" : "", "name" : "", "src" : "", "viewonly" : "", "shrinktofit" : "", "dataurl" : "", "dontcache" : "", "dockingreferenceid" : "", "editoutofplace" : ""};
	
	cd_parsePara(tagStr, paraArray);

	cd_insertObject(paraArray["type"], paraArray["width"], paraArray["height"], paraArray["name"],
				 paraArray["src"], paraArray["viewonly"], paraArray["shrinktofit"], paraArray["dataurl"], paraArray["dontcache"], paraArray["dockingreferenceid"], paraArray["editoutofplace"]);
}


/**
 * This function is used to insert a browser-specific Plugin/ActiveX Control object using specific parameters.
 * The first 3 parameters [mimeType, objWidth, objHeight] are required, and the rest are optional
 *
 * @param {any} mimeType
 * @param {any} objWidth
 * @param {any} objHeight
 * @param {any} objName
 * @param {any} srcFile
 * @param {any} viewOnly
 * @param {any} shrinkToFit
 * @param {any} dataURL
 * @param {any} dontcache
 * @param {any} dockingreferenceid
 * @param {any} editoutofplace
 * @param {any} showTools
 */
function cd_insertObject(mimeType, objWidth, objHeight, objName, srcFile, viewOnly, shrinkToFit, dataURL, dontcache, dockingreferenceid, editoutofplace,showTools) {
	if (cd_currentUsing >= 1 && cd_currentUsing <= 3)
		//!DGB! 12/01 Add a call to cd_AddToObjectArray
		cd_AddToObjectArray(objName);
		document.write( cd_getSpecificObjectTag(mimeType, objWidth, objHeight, objName, srcFile, viewOnly, shrinkToFit, dataURL, dontcache, dockingreferenceid, editoutofplace,showTools) );
}


/////////////////////////////////////////////////////////////////////////////////////////////
// Use this function to insert a Plugin/ActiveX Control wrapper file.

var chemDrawIsInstalled = false;
var alreadyCheckedForChemDraw = false;

/**
 * This function set the flags for no chemdraw mode.
 */
function setNoChemDrawMode() {
	alreadyCheckedForChemDraw = true;
	chemDrawIsInstalled = false;
}

/**
 * This function determines if user has chemdraw installed.
*/
function hasChemdraw() {
	return new Promise(function(resolve, reject) {
		if(alreadyCheckedForChemDraw) {
			resolve(chemDrawIsInstalled);
		}
		else {
			cd_includeWrapperFile().then(function(chemDrawStatus) {
				resolve(chemDrawStatus);
				alreadyCheckedForChemDraw = true;
				chemDrawIsInstalled = chemDrawStatus;
				return;
			});
		}
	});
}

/**
 * This function determines the right wrapper file to include for chemdraw sttuff.
 */
function cd_includeWrapperFile() {
	return new Promise(function(resolve, reject) {
		var basePath = "/arxlab/js/common/chemdraw/";

		if (basePath.length > 0) {
			var lastChar = basePath.charAt(basePath.length - 1);
			if (!(lastChar == "\\" || lastChar == "/"))
				basePath += "\\";
			
			// all these files should be place in the same folder as the three js files.
			CD_PLUGIN_JAR	= basePath + "camsoft.jar";
			CD_PLUGIN_CAB	= basePath + "camsoft.cab";
			CD_PLUGIN_CAB2	= basePath + "camsoft2.cab";
		}

		if (cd_currentUsing >= 1 && cd_currentUsing <= 3) {
			var wrapperfile = "";
			if (cd_currentUsing == 2 || cd_currentUsing == 3) {
				// Plugin uses cdlib_ns.js wrapper file
				wrapperfile += basePath + "cdlib_ns.js";
			}
			else if (cd_currentUsing == 1) {
				// ActiveX Control uses cdlib_ie.js wrapper file
				wrapperfile += basePath + "cdlib_ie.js";
			}

			var sTag = document.createElement('script');
			sTag.setAttribute('src', wrapperfile);
			document.head.appendChild(sTag);
		}

		// auto-download Plugin/ActiveX
		// If you don't like the auto-download feature, remove the following 4 lines
		if (cd_currentUsing == 2 || cd_currentUsing == 3) {
			if (cd_isCDPluginInstalled() == false) {
				resolve(false);
			}
		}
		else if (cd_currentUsing == 1) {
			if (cd_isCDActiveXInstalled() == false) {
				resolve(false);
			}
		}
		
		resolve(true);
	});
}


// ------------------------------------- INTERNAL FUNCTIONS DEFINATION -------------------------------------------
// You may never change following codes.


/////////////////////////////////////////////////////////////////////////////////////////////
// At first, run figureOutUsing() to initilize *currentUsing*.

cd_figureOutUsing();

/**
 * !DGB! 12/01 This function appends an element to the cd_objectsArray.
 * The array contains the names of all cd objects in the page
 * @param {any} objName
 */
function cd_AddToObjectArray(objName) {
	cd_objectArray[cd_objectArray.length] = objName;
}

var cd_pluginID = 1000;

/**
 *  According to browser type and version, choose its corresponding ChemDraw Plugin/ActiveX tag.
 * The first 3 parameters [mimeType, objWidth, objHeight] is required, and the last 5 is optional.
 * @param {any} mimeType
 * @param {any} objWidth
 * @param {any} objHeight
 * @param {any} objName
 * @param {any} srcFile
 * @param {any} viewOnly
 * @param {any} shrinkToFit
 * @param {any} dataURL
 * @param {any} dontcache
 * @param {any} dockingreferenceid
 * @param {any} editoutofplace
 * @param {any} showTools
 */
function cd_getSpecificObjectTag(mimeType, objWidth, objHeight, objName, srcFile, viewOnly, shrinkToFit, dataURL, dontcache, dockingreferenceid, editoutofplace,showTools) {
	mimeType = "chemical/x-cdx";
	var buf = "";
	
	if (dataURL != null) {
		//!DGB! 12/01 add a conditional call to unescape(dataURL)
		if (dataURL.indexOf("%3Bbase64%2C") > 0)
			dataURL = unescape(dataURL);
	}

	if (cd_currentUsing == 1) {	// ActiveX Control

		buf =	"<OBJECT classid=\"" + CD_CONTROL_CLSID + "\" " +
				"style=\"HEIGHT: " + objHeight + "px; WIDTH: " + objWidth + "px\"";
				
		if (objName != null && objName != "")
			buf += " name=\"" + objName + "\"";
			
		buf += ">\n";

		if (srcFile != null && srcFile != "")			
			buf += "<param NAME=\"SourceURL\" VALUE=\"" + srcFile + "\">\n";

		if (dockingreferenceid != null && dockingreferenceid != "")			
			buf += "<param NAME=\"DockingReferenceID\" VALUE=\"" + dockingreferenceid + "\">\n";

		if (dataURL != null && dataURL != "")
			buf += "<param NAME=\"DataURL\" VALUE=\"" + dataURL + "\">\n";
		
		if (viewOnly != null && viewOnly != "")
			buf += "<param NAME=\"ViewOnly\" VALUE=\"" + viewOnly + "\">\n";

		if (shrinkToFit != null && shrinkToFit != "")
			buf += "<param NAME=\"ShrinkToFit\" VALUE=\"" + shrinkToFit + "\">\n";
		
		if (dontcache != null && dontcache != "")
			buf += "<param NAME=\"DontCache\" VALUE=\"" + dontcache + "\">\n";

		if (editoutofplace != null && editoutofplace != "")
			buf += "<param NAME=\"EditOutOfPlace\" VALUE=\"" + editoutofplace + "\">\n";
	
		if (showTools)
		{
			buf += "<param NAME=\"ShowToolsWhenVisible\" VALUE=\"1\">\n";
		}
		else
		{
			buf += "<param NAME=\"ShowToolsWhenVisible\" VALUE=\"0\">\n";
		}

		buf += "</OBJECT>\n";
	}
	else if (cd_currentUsing == 2 || cd_currentUsing == 3) { // Plugin

		var pluginID = ++cd_pluginID;

		if (objName == null)
			objName == "";

		if (srcFile == null)
			srcFile == "";
					
		buf +=	"<EMBED " +
				"src=\"" + srcFile + "\"" + 
				" width=\"" + objWidth + "\"" +
				" height=\"" + objHeight + "\"" +
				" type=\"" + mimeType + "\"";

		if (cd_currentUsing == 3) {
			// In netscape 6, we get data directly from the plugin, not the applet
			if (objName != null && objName != "")
				buf += " name=\"" + objName + "\"";
		}

		if (cd_currentUsing == 2) 
			buf += " id=\"" + pluginID + "\"";
			
		if (dataURL != null && dataURL != "")
			buf += " dataurl=\"" + dataURL + "\"";
		
		if (dockingreferenceid != null && dockingreferenceid != "")
			buf += " dockingreferenceid=\"" + DockingReferenceID + "\"";
		
		if (viewOnly != null && viewOnly != "")
			buf += " viewonly=\"" + viewOnly + "\"";

		if (shrinkToFit != null && shrinkToFit != "")
			buf += " shrinktofit=\"" + shrinkToFit + "\"";
			
		if (dontcache != null && dontcache != "")
			buf += " dontcache=\"" + dontcache + "\"";

		if (editoutofplace != null && editoutofplace != "")
			buf += " editoufofplace=\"" + EditOutOfPlace + "\"";

		if (showTools)
		{
			buf += " showtoolswhenvisible=\"1\"";
		}
		else
		{
			buf += " showtoolswhenvisible=\"0\"";
		}

		buf += ">\n";

		if (cd_currentUsing == 2) {
			// old Plugin needs CDPHelper
			
			buf +=	"<APPLET ID=\"" + objName +  "\" NAME=\"" + objName + "\" CODE=\"camsoft.cdp.CDPHelperAppSimple\" WIDTH=0 HEIGHT=0 ARCHIVE=\"" + CD_PLUGIN_JAR + "\">" +
				"<PARAM NAME=ID VALUE=\"" + pluginID + "\">" +
				"<PARAM NAME=cabbase value=\"" + CD_PLUGIN_CAB + "\"></APPLET>\n";
		}
	}
	else
	{
		buf = "<P><font color=red>\"ALERT: Your browser has not been tested with or qualified to host the ChemDraw plugin.\"</font></P>";
	}
	
	return buf;	
}

/**
 * This function to return the reference of ChemDraw Plugin/ActiveX by its name.
 *
 * @param {any} nm
 */
function cd_getSpecificObject(nm) {
	var r = null;

	if (cd_currentUsing == 1) // ActiveX Control
		r = document.querySelector('object[name="' + nm + '"]');
	else if (cd_currentUsing == 2) // old Plugin + CDPHelper
		r = document.applets[nm];
	else if (cd_currentUsing == 3) // new Plugin (XPCOM, scriptable old Plugin)
		r = document.embeds[nm];

	//if (r == null)
	//	alert("ERROR: You have the wrong name [" + nm + "] to refer to the Plugin/ActiveX !!!");

	return r;
}

/**
 * To get Browser's version.
 */
function cd_getBrowserVersion() {
	//if (cd_testBrowserType("Microsoft Internet Explorer")) {
	//	var str = navigator.appVersion;
	//	var i = str.indexOf("MSIE");
	//	if (i >= 0) {
	//		str = str.substr(i + 4);
	//		return parseFloat(str);
	//	}
	//	else
	//		return 0;
	//}
	//else
	//	return parseFloat(navigator.appVersion);
	return parseFloat(_checkBrowser()["version"])
}

/**
 * To test Browser's type.
 *
 * @param {any} brwType
 */
function cd_testBrowserType(brwType) {
	if (brwType=="Microsoft Internet Explorer"){
		if(_checkBrowser().msie){
			return 1
		}
	}else{
		if(!_checkBrowser().msie){
			return 1
		}
	}
	//return (navigator.appName.indexOf(brwType) != -1);
}

/**
 * To test if IE runs on MAC.
 */
function cd_IsMacWithIE() {
	return cd_testBrowserType("Microsoft Internet Explorer") && (navigator.platform.indexOf("Mac") != -1 || navigator.platform.indexOf("MAC") != -1);
}

/**
 * To test whether Plugin is installed on locall machine.
 */
function cd_isCDPluginInstalled() {
	if (cd_testBrowserType("Microsoft Internet Explorer")) {
		var str =
		"<div style='left:0;top:0;zIndex:1;position:absolute'><applet code='camsoft.cdp.CDPHelperAppSimple2' width=0 height=0 name='test_plugin'><param name=ID value=99999><param NAME=cabbase value='" + CD_PLUGIN_CAB2 + "'></applet></div>" +
		"<SCRIPT LANGUAGE=javascript>" +
		"	var testpluginonlyonce = false;" +
		"	function document_onmouseover() {" +
		"		if (!testpluginonlyonce) {" +
		"			testpluginonlyonce = true;" +
		"			var pluginstalled = false;" +
		"			pluginstalled = document.applets[\"test_plugin\"].isLoaded();" +
		"			if (!pluginstalled) {" +
		"				CD_PLUGIN_JAR = \"\";" +
		"				CD_PLUGIN_CAB = \"\";" +
		"				cd_installNetPlugin();" +
		"			}" +
		"		}" +
		"	}" +
		"</" + "SCRIPT>" +
		"<SCRIPT LANGUAGE=javascript FOR=document EVENT=onmouseover>document_onmouseover()</" + "SCRIPT>";
		
		document.write(str);
		
		return true;
	}
	
	for (var i = 0; i < navigator.plugins.length; ++i) {
		if (navigator.plugins[i].name.indexOf("ChemDraw") != -1)
			return true;
	}
	
	return false;
}

/**
 *  To install NET plugin on local machine.
 */
function cd_installNetPlugin() {
	if (confirm("You currently use " + navigator.appName + " " + cd_getBrowserVersion() + ".\n" +
		"This page will use CS ChemDraw Plugin, but it isn't installed on your computer.\n" +
		"Do you want to install it now?")) {
		window.open(CD_AUTODOWNLOAD_PLUGIN);
	}
	else {
		CD_PLUGIN_JAR = "";
		CD_PLUGIN_CAB = "";
	}
}

/**
 *  To test whether ActiveX is installed on local machine.
 */
function cd_isCDActiveXInstalled() {
	// Note: try ... catch ... statement isn't available in JavaScript 1.4 (IE 4 uses js 1.4).
	// That means that try/catch code can't even exist if we're using an earlier version of JavaScript
	//  so we have to wrap it as a string.  If we're using a sufficiently-recent browser (that has
	//  a version of JavaScript 1.4 or later), we'll eval the string, which will end up doing a try/catch
	//  For older browsers, we'll just do things the old way, and suffer through any performance penalties.
	
	var retval = true;

	if (js_canUseTry) {
		var str = "";
		str = str + "try\n";
		str = str + "{\n";
		str = str + "	// Try 20.0\n";
		str = str + "	var obj20 = new ActiveXObject(\"ChemDrawControl20.ChemDrawCtl\");\n";
		str = str + "	CD_CONTROL_CLSID = CD_CONTROL200CLSID; obj20='';\n";
		str = str + "} catch(e15)\n";
		str = str + "{\n";		
		str = str + "try\n";
		str = str + "{\n";
		str = str + "	// Try 19.0\n";
		str = str + "	var obj19 = new ActiveXObject(\"ChemDrawControl19.ChemDrawCtl\");\n";
		str = str + "	CD_CONTROL_CLSID = CD_CONTROL190CLSID; obj19='';\n";
		str = str + "} catch(e15)\n";
		str = str + "{\n";
		str = str + "try\n";
		str = str + "{\n";
		str = str + "	// Try 18.0\n";
		str = str + "	var obj18 = new ActiveXObject(\"ChemDrawControl18.ChemDrawCtl\");\n";
		str = str + "	CD_CONTROL_CLSID = CD_CONTROL180CLSID; obj18='';\n";
		str = str + "} catch(e15)\n";
		str = str + "{\n";
		str = str + "try\n";
		str = str + "{\n";
		str = str + "	// Try 17.0\n";
		str = str + "	var obj17 = new ActiveXObject(\"ChemDrawControl17.ChemDrawCtl\");\n";
		str = str + "	CD_CONTROL_CLSID = CD_CONTROL170CLSID; obj17='';\n";
		str = str + "} catch(e15)\n";
		str = str + "{\n";
		str = str + "try\n";
		str = str + "{\n";
		str = str + "	// Try 16.0\n";
		str = str + "	var obj16 = new ActiveXObject(\"ChemDrawControl16.ChemDrawCtl\");\n";
		str = str + "	CD_CONTROL_CLSID = CD_CONTROL160CLSID; obj16='';\n";
		str = str + "} catch(e15)\n";
		str = str + "{\n";
		str = str + "try\n";
		str = str + "{\n";
		str = str + "	// Try 15.0\n";
		str = str + "	var obj15 = new ActiveXObject(\"ChemDrawControl15.ChemDrawCtl\");\n";
		str = str + "	CD_CONTROL_CLSID = CD_CONTROL150CLSID; obj15='';\n";
		str = str + "} catch(e15)\n";
		str = str + "{\n";
		str = str + "	try\n";
		str = str + "	{\n";
		str = str + "		// Try 14.0\n";
		str = str + "		var obj14 = new ActiveXObject(\"ChemDrawControl14.ChemDrawCtl\");\n";
		str = str + "		CD_CONTROL_CLSID = CD_CONTROL140CLSID; obj14='';\n";
		str = str + "	} catch(e14)\n";
		str = str + "	{\n";
		str = str + "		try\n";
		str = str + "		{\n";
		str = str + "			// Try 13.0\n";
		str = str + "			var obj13 = new ActiveXObject(\"ChemDrawControl13.ChemDrawCtl\");\n";
		str = str + "			CD_CONTROL_CLSID = CD_CONTROL130CLSID; obj13='';\n";
		str = str + "		} catch(e13)\n";
		str = str + "		{\n";
		str = str + "			try\n";
		str = str + "			{\n";
		str = str + "				// Try 12.0\n";
		str = str + "				var obj12 = new ActiveXObject(\"ChemDrawControl12.ChemDrawCtl\");\n";
		str = str + "				CD_CONTROL_CLSID = CD_CONTROL120CLSID; obj12='';\n";
		str = str + "			} catch(e12)\n";
		str = str + "			{\n";
		str = str + "			try\n";
		str = str + "				{\n";
		str = str + "					// Try 11.0\n";
		str = str + "					var obj11 = new ActiveXObject(\"ChemDrawControl11.ChemDrawCtl\");\n";
		str = str + "					CD_CONTROL_CLSID = CD_CONTROL110CLSID; obj11='';\n";
		str = str + "				} catch(e11)\n";
		str = str + "				{\n";
		str = str + "					try\n";
		str = str + "					{\n";
		str = str + "						// Try 10.0\n";
		str = str + "						var obj10 = new ActiveXObject(\"ChemDrawControl10.ChemDrawCtl\");\n";
		str = str + "						CD_CONTROL_CLSID = CD_CONTROL100CLSID; obj10='';\n";
		str = str + "					} catch(e10)\n";
		str = str + "					{\n";
		str = str + "						try\n";
		str = str + "						{\n";
		str = str + "							// Try 9.0\n";
		str = str + "							var obj9 = new ActiveXObject(\"ChemDrawControl9.ChemDrawCtl\");\n";
		str = str + "							CD_CONTROL_CLSID = CD_CONTROL90CLSID; obj9='';\n";
		str = str + "						} catch(e9)\n";
		str = str + "						{\n";
		str = str + "							try\n";
		str = str + "							{\n";
		str = str + "								// Try 8.0\n";
		str = str + "								var obj8 = new ActiveXObject(\"ChemDrawControl8.ChemDrawCtl\");\n";
		str = str + "								CD_CONTROL_CLSID = CD_CONTROL80CLSID; obj8='';\n";
		str = str + "							} catch(e8)\n";
		str = str + "							{\n";
		str = str + "								try\n";
		str = str + "								{\n";
		str = str + "									// try 7.0\n";
		str = str + "									// Something is wrong in 7.0 installers, which causes \"ChemDrawControl7.ChemDrawCtl\" cannot be used.\n";
		str = str + "									var obj7 = new ActiveXObject(\"ChemDrawControl7.ChemDrawCtl.7.0\");\n";
		str = str + "									CD_CONTROL_CLSID = CD_CONTROL70CLSID; obj7='';\n";
		str = str + "								} catch(e7)\n";
		str = str + "								{\n";
		str = str + "									try\n";
		str = str + "									{\n";
		str = str + "										// try 6.0\n";
		str = str + "										var obj6 = new ActiveXObject(\"ChemDrawLib.ChemDrawCtl6.0\");\n";
		str = str + "										CD_CONTROL_CLSID = CD_CONTROL60CLSID; obj6='';\n";
		str = str + "									} catch(e6)\n";
		str = str + "									{\n";
		str = str + "										// No version installed\n";
		str = str + "										retval = false;\n";
		str = str + "									}\n";
		str = str + "								}\n";
		str = str + "							}";
		str = str + "						}";
		str = str + "					}";
		str = str + "				}";
		str = str + "			}";
		str = str + "		}";
		str = str + "	}";
		str = str + "}";
		str = str + "}";
		str = str + "}";
		str = str + "}";
		str = str + "}";
		str = str + "}";

		eval(str);
	}
	else {
		document.write("<OBJECT NAME=\"test_120\" WIDTH=0 HEIGHT=0 CLASSID=\"" + CD_CONTROL120CLSID +  "\"><param NAME=ViewOnly VALUE=true></OBJECT>");
		if (document.all("test_120").Selection != null)
			CD_CONTROL_CLSID = CD_CONTROL120CLSID;
		else {
			document.write("<OBJECT NAME=\"test_110\" WIDTH=0 HEIGHT=0 CLASSID=\"" + CD_CONTROL110CLSID  + "\"><param NAME=ViewOnly VALUE=true></OBJECT>");
			if (document.all("test_110").Selection != null)
				CD_CONTROL_CLSID = CD_CONTROL110CLSID;
			else {
				document.write("<OBJECT NAME=\"test_100\" WIDTH=0 HEIGHT=0 CLASSID=\"" +  CD_CONTROL100CLSID + "\"><param NAME=ViewOnly VALUE=true></OBJECT>");
				if (document.all("test_100").Selection != null)
					CD_CONTROL_CLSID = CD_CONTROL100CLSID;
				else {
					document.write("<OBJECT NAME=\"test_90\" WIDTH=0 HEIGHT=0 CLASSID=\"" +  CD_CONTROL90CLSID + "\"><param NAME=ViewOnly VALUE=true></OBJECT>");
					if (document.all("test_90").Selection != null)
						CD_CONTROL_CLSID = CD_CONTROL90CLSID;
					else {
						document.write("<OBJECT NAME=\"test_80\" WIDTH=0 HEIGHT=0  CLASSID=\"" + CD_CONTROL80CLSID + "\"><param NAME=ViewOnly VALUE=true></OBJECT>");
						if (document.all("test_80").Selection != null)
							CD_CONTROL_CLSID = CD_CONTROL80CLSID;
						else {
							document.write("<OBJECT NAME=\"test_70\" WIDTH=0 HEIGHT=0  CLASSID=\"" + CD_CONTROL70CLSID + "\"><param NAME=ViewOnly VALUE=true></OBJECT>");
							if (document.all("test_70").Selection != null)
								CD_CONTROL_CLSID = CD_CONTROL70CLSID;
							else {
								document.write("<OBJECT NAME=\"test_60\" WIDTH=0  HEIGHT=0 CLASSID=\"" + CD_CONTROL60CLSID + "\"><param NAME=ViewOnly VALUE=true></OBJECT>");
								if (document.all("test_60").Selection != null)
									CD_CONTROL_CLSID = CD_CONTROL60CLSID;
								else
									retval = false;
							}
						}
					}
				}
			}
		}
	}
	return retval;
}

/**
 * To install NET plugin on locall machine.
 */
function cd_installNetActiveX() {
	if (confirm("You currently use " + navigator.appName + " " + cd_getBrowserVersion() + ".\n" +
		"This page will use CS ChemDraw ActiveX control, but it isn't installed on your computer.\n" +
		"Do you want to install it now?")) {
		window.open(CD_AUTODOWNLOAD_ACTIVEX);
	}
}

/**
 * This function to parse all useful parameter from <EMBED> string. Return values is stored an array.
 * <embed width="200" HEIGHT="200" type="chemical/x-cdx" src="mols/blank.cdx" dataurl="mols/toluene.mol" viewonly="TRUE">
 *
 * @param {any} str
 * @param {any} paraArray
 */
function cd_parsePara(str, paraArray) {

	for (var p in paraArray)
		paraArray[p] = cd_getTagValue(p, str);
}

/**
 * This function return the tag value from <EMBED> string.
 *
 * @param {any} tag
 * @param {any} str
 */
function cd_getTagValue(tag, str) {
	var r = "";
	var pos = str.toLowerCase().indexOf(tag, 0);
	var taglen = tag.length;
	
	// make sure tag is a whole word
	while (pos >= 0 && !(pos == 0 && (str.charAt(taglen) == " " || str.charAt(taglen) == "=") ||
		pos > 0 && str.charAt(pos - 1) == " " && (str.charAt(pos + taglen) == " " || str.charAt(pos + taglen) == "=")) ) {
		pos += taglen;
		pos = str.toLowerCase().indexOf(tag, pos);
	}

	if (pos >= 0) {		
		// skip the space chars following tag
		pos += taglen;
		while (str.charAt(pos) == " ")
			pos++;
		
		// following char must be '='
		if (str.charAt(pos) == "=") {
			pos++;
			
			// skip the space chars following '='
			while (str.charAt(pos) == " ")
				pos++;
			
			var p2 = pos;
			if (str.charAt(pos) == "\"") {
				pos++;
				p2 = str.indexOf("\"", pos);
			}
			else if (str.charAt(pos) == "\'") {
				pos++;
				p2 = str.indexOf("\'", pos);
			}
			else {
				p2 = str.indexOf(" ", pos);
			}
			
			if (p2 == -1)
				p2 = str.length
			else if (pos > p2)
				p2 = str.length - 1;

			r = str.substring(pos, p2);
		}
	}
	
	return r;
}
