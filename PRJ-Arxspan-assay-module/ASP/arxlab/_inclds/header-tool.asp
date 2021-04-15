<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
If request.querystring("source")<>"compounds" then
	Set browserdetect = Server.CreateObject("MSWC.BrowserType")
	browser=browserdetect.Browser
	version=browserdetect.Version
	bCheck = browser&" "&version
	bCheck = Trim(bCheck)
End if
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
'QQQ h3/standalone reg
'RRR needs updating
'nxq don't understand

nonGXPLabel = checkBoolSettingForCompany("useNonGxpLabel", session("companyId"))
%>

<!-- #include virtual="/arxlab/_inclds/jsRev.asp" -->

<html>
<head>
	<title><%=pageTitle%></title>
	<meta name="keywords" content="<%=metaKey%>" />
	<meta name="description" content="<%=metaD%>" />

<!-- new ft stuff-->
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/arxspan_global_styles.css?<%=jsRev%>">
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/transitionStyles.css?<%=jsRev%>">
<link href="<%=mainCSSPath%>/latofont.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<link rel="shortcut icon" href="<%=mainAppPath%>/favicon.ico">
<script type="text/javascript" src="<%=mainAppPath%>/js/arxlayout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/isotope.pkgd.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/babel-for-es6-support.js?<%=jsRev%>"></script>
<% 'No version of IE supports "startsWith", this is a pollyfill to fix that %>
<script type="text/javascript">
	if (!String.prototype.startsWith) {
		String.prototype.startsWith = function(searchString, position){
		  position = position || 0;
		  return this.substr(position, searchString.length) === searchString;
	  };
	}
	if (!String.prototype.endsWith) {
		String.prototype.endsWith = function(searchString, position) {
			var subjectString = this.toString();
			if (typeof position !== 'number' || !isFinite(position) || Math.floor(position) !== position || position > subjectString.length) {
				position = subjectString.length;
			}
			position -= searchString.length;
			var lastIndex = subjectString.lastIndexOf(searchString, position);
			return lastIndex !== -1 && lastIndex === position;
		};
	}
</script>
<!--[if lte IE 8]>
 <link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/normalize.css" />
 <script type="text/javascript" src="js/html5shiv-printshiv.min.js"></script>
 <script type="text/javascript" src="js/jspatch.js"></script>
 <link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/ie8_and_below.css" />
	<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/lato_ie_300.css" /> 
 <link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/lato_ie_400.css" /> 
	<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/lato_ie_700.css" />

	<script type="text/javascript">
 	if (!Array.isArray) {
 		Array.isArray = function(arg) {
 			return Object.prototype.toString.call(arg) === '[object Array]';
 		};
 	}
 
 	if (typeof Array.prototype.forEach !== 'function') {
 		Array.prototype.forEach = function(callback, context) {
 			for (var i = 0; i < this.length; i++) {
 			callback.apply(context, [ this[i], i, this ]);
 			}
 		};
 	}


 	(function(constructor) {
    if (constructor &&
        constructor.prototype &&
        constructor.prototype.firstElementChild == null) {
        Object.defineProperty(constructor.prototype, 'firstElementChild', {
            get: function() {
                var node, nodes = this.childNodes, i = 0;
                while (node = nodes[i++]) {
                    if (node.nodeType === 1) {
                        return node;
                    }
                }
                return null;
            }
        });
    }
})(window.Node || window.Element);


if (!document.getElementsByClassName) {
  document.getElementsByClassName = function(search) {
    var d = document, elements, pattern, i, results = [];
    if (d.querySelectorAll) { // IE8
      return d.querySelectorAll("." + search);
    }
    if (d.evaluate) { // IE6, IE7
      pattern = ".//*[contains(concat(' ', @class, ' '), ' " + search + " ')]";
      elements = d.evaluate(pattern, d, null, 0, null);
      while ((i = elements.iterateNext())) {
        results.push(i);
      }
    } else {
      elements = d.getElementsByTagName("*");
      pattern = new RegExp("(^|\\s)" + search + "(\\s|$)");
      for (i = 0; i < elements.length; i++) {
        if ( pattern.test(elements[i].className) ) {
          results.push(elements[i]);
        }
      }
    }
    return results;
  }
}

if (!Array.prototype.indexOf)
{
  Array.prototype.indexOf = function(elt /*, from*/)
  {
    var len = this.length >>> 0;

    var from = Number(arguments[1]) || 0;
    from = (from < 0)
         ? Math.ceil(from)
         : Math.floor(from);
    if (from < 0)
      from += len;

    for (; from < len; from++)
    {
      if (from in this &&
          this[from] === elt)
        return from;
    }
    return -1;
  };
}




  



 </script>
<![endif]-->
<!-- end new ft stuff-->

<% if pageTitle = "Notifications" then %>
	<base href="<%=mainAppPath%>/">
<% end if %>
<link href="<%=mainCSSPath%>/style-print.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="print">
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<link href="<%=mainAppPath%>/js/sweetalert1/sweetalert.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<link href="<%=mainCSSPath%>/styles-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="<%=mainCSSPath%>/menu-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<link href="<%=mainCSSPath%>/cms.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="<%=mainCSSPath%>/reg-styles.css?<%=jsRev%>" rel="stylesheet" type="text/css" media="screen">
<link href="<%=mainCSSPath%>/arxspan_advanced_search_red.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<link href="<%=mainCSSPath%>/popup_styles.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<link href="<%=mainAppPath%>/js/select2-3.5.1/select2.css?<%=jsRev%>" rel="stylesheet" type="text/css">

<link href="<%=mainCSSPath%>/aaron-restyle.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<%If interfaceLanguage = "Japanese" Or interfaceLanguage = "Chinese" then%>
<style type="text/css">
*{
	font-family: 'Hiragino Kaku Gothic Pro',Meiryo,'MS PGothic',sans-serif!important;
}
#topNav a {
	width:140px!important;
}
#addTab_tab{
	width:120px!important;
}
.arxspanSideText {
    padding: 11px 19px;
}
div.rightSide .topNavButton {
    font-size: 11px;
    line-height: 15px;
}
div.topSectionLower .topSectionLowerButton a {
    font-size: 13px;
}
</style>
<%End if%>
<%If InStr(LCase(request.servervariables("HTTP_USER_AGENT")),"safari") = 0 or InStr(LCase(request.servervariables("HTTP_USER_AGENT")),"chrome") <> 0 then%>
<style type="text/css">
.experimentsTable TR:hover {
	background-color:#F5F5F5;
	}

/*
upload form
*/

.AjaxUploaderProgressInfoText{
	width:100px;
	overflow:hidden;
}

.AjaxUploaderProgressTable{
	width:100px!important;
}
</style>
<%End if%>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1"/>
<meta name="keywords" content="<%=metaKey%>" />
<meta name="description" content="<%=metaD%>" />

<script type="text/javascript" src="<%=mainAppPath%>/js/getFile2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/killIntervals.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/createSelect.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/common/dateFunctions.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/addLoadEvent.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/ajaxNoReturn.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/ajaxPostToFile.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/popups.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/nav.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/encoder.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/md5-min.js"></script>
<%'QQQ START NOT USED FOR H3 Reg%>
<script type="text/javascript" src="<%=mainAppPath%>/js/ajax.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/dateFormat.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/nodeToString.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/delayedRunJS.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/attachmentNaming.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/showBigProd.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/json2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/encodingFunctions.js?<%=jsRev%>"></script>
<%'QQQ END NOT USED FOR H3 Reg%>

<%If (subsectionId = "experiment" Or subsectionId = "bio-experiment" Or subsectionId = "free-experiment" Or subsectionId = "anal-experiment" Or subsectionId = "cust-experiment" Or subSectionId="show-project") And revisionId = "" then%>
<script type="text/javascript" src="<%=mainAppPath%>/js/mousetrap.min.js?<%=jsRev%>"></script>
<script type="text/javascript">

function bindSaveShortcut() {
	Mousetrap.bind(['command+s', 'ctrl+s'], function(e) {
		clickSave();
		return false;
	});
	Mousetrap.stopCallback = function () {
		return false;
	}
}

<%If (subsectionId = "experiment" Or subsectionId = "bio-experiment" Or subsectionId = "free-experiment" Or subsectionId = "anal-experiment" Or subSectionId="show-project") And revisionId = "" then%>
	bindSaveShortcut();
<%Else%>
	Mousetrap.bind(['command+s', 'ctrl+s'], function(e) {
		return false;
	})
<%End if%>

</script>
<script type="text/javascript" src="<%=mainAppPath%>/js/pasteHandler.js?<%=jsRev%>"></script>
<script type="text/javascript">
document.onpaste = function(){pasteHandler(event);}
</script>
<script type="text/javascript">
	isForSign = false;
</script>
<%End if%>

<%'mfu%>
<script src="/arxlab/jqfu/js/jquery-1.10.2.js?<%=jsRev%>"></script>
<script src="/arxlab/jqfu/jquery-ui-1.10.3/ui/minified/jquery-ui.min.js?<%=jsRev%>"></script>
<link rel="stylesheet" href="<%=mainAppPath%>/css/jquery.typeahead-2.10.1.min.css">
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.typeahead-2.10.1.min.js?<%=jsRev%>"></script>

<script type="text/javascript" src="<%=mainAppPath%>/js/sweetalert1/sweetalert.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/cytoscape.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.placeholder.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.leanModal.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/promisePolyfill.min.js?<%=jsRev%>"></script>

	<!-- Force latest IE rendering engine or ChromeFrame if installed -->
	<!--[if IE]>
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<![endif]-->
    
<%'FANCYTREE RELATED%>
<link rel="stylesheet" type="text/css" href="<%=mainAppPath%>/js/fancytree/ui.fancytree.css?<%=jsRev%>">
<script type="text/javascript" src="<%=mainAppPath%>/js/fancytree/jquery.fancytree-all.js?<%=jsRev%>"></script>    
    
<%If bCheck="IE 8.0" Then%>

<%End if%>

<%If subSectionId="experiment" Or subSectionId="bio-experiment" Or subSectionId="free-experiment" Or subSectionId="anal-experiment" Or subSectionId="cust-experiment" Or subsectionId="prep-templates" Or subsectionId="prep-templates-bio-protocol" Or subsectionId="prep-templates-bio-summary" Or subsectionId="prep-templates-free-description" then%>
<script type="text/javascript" src="<%=mainAppPath%>/js/ckeditor/ckeditor.js?<%=jsRev%>"></script>
<script type="text/javascript">
CKEDITOR.timestamp=Math.random();
</script>
<%''QQQ asp uploader not used for H3 Reg%>
<%End if%>
<%If bCheck="IE 8.0" Then%>
<%'!-- #include virtual="/arxlab/aspuploader/include_aspuploader.asp" --%>
<script type="text/javascript" src="<%=mainAppPath%>/js/jspatch.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/html5shiv-printshiv.min.js?<%=jsRev%>"></script>
<link href="<%=mainCSSPath%>/old_ie.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<%End if%>
<script type="text/javascript" src="<%=mainAppPath%>/js/userOptions.js?<%=jsRev%>"></script>
<script type="text/javascript">

var defaultWitnessId = "<%=session("defaultWitnessId")%>";
var defaultWitnessName = "<%=session("defaultWitnessName")%>";

function includeJS(sId, fileUrl, source) 
{ 
if ( ( source != null ) && ( !document.getElementById( sId ) ) ){ 
var oHead = document.getElementsByTagName('HEAD').item(0);
var oScript = document.createElement( "script" );
oScript.language = "javascript";
oScript.type = "text/javascript";
oScript.id = sId;
oScript.defer = true;
oScript.text = source;
oHead.appendChild( oScript );
} 
} 

<%'QQQ start Copying is not needed in H3 Reg but has not yet been removed%>
function copyLink(formId)
{
	document.getElementById(formId).submit();
	waitForCopyLink();
}


function waitForCopyLink()
{
	try
	{
		result = window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML
		if (result == "success")
		{
			window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML = "";
		}
		else
		{
			setTimeout('waitForCopyLink()',150)
		}
	}
	catch(err)
	{
		setTimeout('waitForCopyLink()',150)
	}
}
<%'QQQ end Copying is not needed in H3 Reg but has not yet been removed%>

function _base64ToArrayBuffer(base64) {
	return _base64ToArray(base64).buffer;
}

function _base64ToArray(base64) {
	var binary_string =  window.atob(base64);
	var len = binary_string.length;
	var bytes = new Uint8Array( len );
	for (var i = 0; i < len; i++)        {
		bytes[i] = binary_string.charCodeAt(i);
	}
	return bytes;
}
</script>

<%If subSectionId = "experiment" Or subSectionId="bio-experiment" Or subSectionId="free-experiment" Or subSectionId="anal-experiment" then%>
<script type="text/javascript">
var checkNewVersionSack = new sack();
	function checkNewVersion()
	{
		// Element "thisRevisionNumber" may not exist
		var revNum = "";
		var revNode = document.getElementById("thisRevisionNumber");
		if (revNode) {
			revNum = revNode.value;
        }
		checkNewVersionSack.requestFile = "<%=mainAppPath%>/ajax_checkers/experimentNewerVersion.asp?id=" + document.getElementById("experimentId").value + "&experimentType=" + document.getElementById("experimentType").value + "&revisionNumber=" + revNum + "&random=" + Math.random();
		checkNewVersionSack.onCompletion = checkNewVersionDone;
		checkNewVersionSack.runAJAX();

	}

	function checkNewVersionDone()
	{
		if (checkNewVersionSack.response == "true"){
				unsavedChanges = false;
				document.getElementById("blackDiv").style.position = "fixed";
				document.getElementById("blackFrame").style.position = "fixed";
				document.getElementById("blackDiv").style.height = document.body.clientHeight+"px";
				document.getElementById("blackFrame").style.height = document.body.clientHeight+"px";
				document.getElementById("blackDiv").style.display = "block";
				document.getElementById("blackFrame").style.display = "block";
				killIntervals();
				alert("This experiment has a newer version. It may have been saved in another session. Click OK to load the current version.");
				window.location = window.location;
		}
	}

	checkNewVersionInterval = setInterval('checkNewVersion()',60000)
</script>
<%End if%>

<!-- #include file="common/asp/checkLoginAndResetInactivityTimer.asp"-->

<!--[if (gte IE 6)&(lt IE 7)]>
<style type="text/css">
.pageNav li  {
	margin-left:8px;
	list-style:none;
	line-height:12px;
	height:12px;
	}
</style>
<![endif]-->
<!--[if (gte IE 7)&(lt IE 8)]>
<style type="text/css">
.pageNav li  {
	margin-left:8px;
	list-style:none;
	line-height:12px;
	}
</style>
<![endif]-->

<!--[if (lte IE 6)]>
<style type="text/css">
#blackFrame { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
#blackDiv { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
#addFileDiv { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
#signDiv { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
#uploadRXNDiv { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
#noteDiv { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
#copyDiv { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
#groupsDiv { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
#reasonDiv { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
#witnessSignDiv { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
<%if experimentType <> "" then%>
<%
prefix = GetPrefix(experimentType)
attachmentsTable = GetFullName(prefix, "attachments", true)
uploadScript = GetUploadPage(prefix)
strQuery9 = "SELECT id FROM " & attachmentsTable & " WHERE experimentId="&SQLClean(experimentId,"N","S")
if strQuery9 <> "" then
Set attachmentRec = server.CreateObject("ADODB.RecordSet")
attachmentRec.open strQuery9,conn,3,3
Do While Not attachmentRec.eof
%>
#addFileDiv_<%=attachmentRec("id")%> { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
<%
	attachmentRec.movenext
loop
end if
%>

<%
prefix = GetPrefix(experimentType)
attachmentsPreSaveTable = GetFullName(prefix, "attachments_preSave", true)
uploadScript = GetUploadPage(prefix)
strQuery9 = "SELECT id FROM " & attachmentsPreSaveTable & " WHERE experimentId="&SQLClean(experimentId,"N","S")
if strQuery9 <> "" then
Set attachmentRec = server.CreateObject("ADODB.RecordSet")
attachmentRec.open strQuery9,conn,3,3
Do While Not attachmentRec.eof
%>
#addFileDiv_p<%=attachmentRec("id")%> { 
 position: absolute!important; 
 top: expression(0+((e=document.documentElement.scrollTop)?e:document.body.scrollTop)+'px')!important; 
 left: expression(0+((e=document.documentElement.scrollLeft)?e:document.body.scrollLeft)+'px')!important;} 
}
<%
	attachmentRec.movenext
loop
end if
%>
<%end if%>
</style>
<![endif]-->

<%'QQQ START This script is not used in H3 Reg.  The script is part%>
<%'of the system that remembers whether or not nav items are open or collapsed.%>
<%'in the H3 Reg there is only on menu Item and it is reg and it is always opened%>
<script type="text/javascript">
var stateSack = new sack();

function navToggle(id)
{
	// console.log("id is:", id)
	el = document.getElementById(id)
	if (el.style.display == "none")
	{
		// console.log("in first if clause.... el.style.display is:", el.style.display)
		el.style.display = "block"
		stateSack.requestFile = "<%=mainAppPath%>/ajax_doers/changeState.asp?stateId="+id+"&state=1&random="+Math.random();
		stateSack.onCompletion = doNothing;
		stateSack.runAJAX();
		if(document.getElementById(id+"_arrow")){
			document.getElementById(id+"_arrow").src = "<%=mainAppPath%>/images/nav-down.gif";
		}
	}
	else
	{
		// console.log("in first else clause.... el.style.display is:", el.style.display)
		el.style.display = "none"
		stateSack.requestFile = "<%=mainAppPath%>/ajax_doers/changeState.asp?stateId="+id+"&state=0&random="+Math.random();
		stateSack.onCompletion = doNothing;
		stateSack.runAJAX();
		if(document.getElementById(id+"_arrow")){
			document.getElementById(id+"_arrow").src = "<%=mainAppPath%>/images/nav-right.gif";
		}
	}
}

function doNothing(){a=2;}
</script>

<script type="text/javascript">
	userOptions = JSON.parse("<%=replace(session("userOptions"),"""","\""")%>")
</script>

<%'QQQ END This script is not used in H3 Reg.  The script is part%>

<%'RRR While not this script specifically. help is extremely outdated%>
<script  type="text/javascript">
var popUpWin=0;
function helpPopup(URLStr, winName, width, height)
{
  if(popUpWin)
  {
    if(!popUpWin.closed) popUpWin.close();
  }
  popUpWin = open('<%=mainAppPath%>/'+URLStr, winName, 'scrollbars=0,toolbar=0,status=0,directories=no,menubar=0,resizable=yes,width='+width+',height='+height+'');
}

/**
 * Function to load the list of notebooks that the user can write to into the new experiment popup.
 */
function loadNotebooksICanWriteTo() {
	$.ajax({
		url: "<%=mainAppPath%>/ajax_loaders/notebooksThisUserCanWriteTo.asp",
		type: "GET",
		async: true,
		cache: false
	})
	.done(function(selectData) {
		$("#newExperimentNotebookId").html(selectData);
	})
	.fail(function() {
		alert("Unable to load notebook list. Please contact support@arxspan.com.");
	});
}

/**
 * Function to load the list of projects that the user can link experiments to into the new experiment popup.
 */
function loadProjectListForNewExperimentDialog() {
	$.ajax({
		url: "<%=mainAppPath%>/ajax_loaders/projectListForExperimentDialog.asp",
		type: "GET",
		async: true,
		cache: false
	})
	.done(function(selectData) {
		$("#newExperimentProjectList").html(selectData);
	})
	.fail(function() {
		alert("Unable to load project list. Please contact support@arxspan.com.");
	});
}

/**
 * Makes an AJAX call to experimentTypesICanCreate to fetch all of the experiment types that can be created.
 */
function loadExperimentTypesICanCreate() {
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: "<%=mainAppPath%>/ajax_loaders/experimentTypesICanCreate.asp",
		}).done(function(response) {
			resolve(response);
		});
	});
}

/**
 * Helper function that takes the response from loadExperimentTypesICanCreate and parses the results into
 * experiment type dropdown lists.
 * @param {string} expTypeResp The response from the loadExperimentTypesICanCreate function.
 */
function processExperimentTypesICanCreate(expTypeResp) {
	var responseObj = JSON.parse(expTypeResp);
	var defaultTypeList = responseObj["defaultTypeList"];
	var custTypeList = responseObj["custTypeList"];
	custTypeList.sort(function(a, b) {
		return a.name.toLowerCase() > b.name.toLowerCase() ? 1 : -1;
	});
	var defaultType = responseObj["default"];
	var defaultTypeId = responseObj["defaultType"];

	// 7948: Override the default type by the current experiment type in the Next Step experiment type
	if (typeof experimentType !== "undefined" && experimentType != "") {
        defaultTypeId = experimentType;
		if (experimentType == "5") {
			// If this is a custom exp, the value of the option should be in the format of 5:requestTypeID
			if ($("#requestTypeId")) {
				var requestTypeIdVal = $("#requestTypeId").val();
                defaultTypeId = "5:" + requestTypeIdVal;
			}
        }
    }

	iterateExpTypesList(defaultTypeList);
	iterateExpTypesList(custTypeList);
	$("#newExperimentType").val(defaultType);

	iterateNextStepTypesList(defaultTypeList, false);
	iterateNextStepTypesList(custTypeList, true);
	$("#nextStepExperimentType").val(defaultTypeId);
}

/**
 * Helper function to create a new option for the experiment types list with the given name and href value.
 * @param {string} name The name of this option.
 * @param {string} href The link of the experiment type.
 */
function createTypeOption(name, href) {
	return createOptionObj(name, href);
}

/**
 * Helper function to create a new option for the next step experiment types list with the given name and id value.
 * @param {string} name The name of this option.
 * @param {string} id The id of the experiment type.
 * @param {bool} isRequest Is this a request type?
 */
function createNextStepOption(name, id, isRequest) {
	var typeId = isRequest ? "5:" + id : id;
	return createOptionObj(name, typeId);
}

/**
 * Helper function to create a new option with the given name and value.
 * @param {string} name The name of this option.
 * @param {string} value The value of this option.
 */
function createOptionObj(name, value) {
	var option = $("<option>");
	option.text(decodeDoubleByteString(name));
	option.val(value);
	return option;
}

/**
 * Iterate through the given experiment type list, create an HTML option, then append it to the
 * newExperimentType select.
 * @param {JSON[]} expTypeList The list of experiment types.
 */
function iterateExpTypesList(expTypeList) {
	expTypeList.forEach(function(expType) {
		var typeOption = createTypeOption(expType["name"], expType["href"]);
		$("#newExperimentType").append(typeOption);
	});
}

/**
 * Iterate through the given experiment type list, create an HTML option, then append it to the
 * nextStepExperimentType select.
 * @param {JSON[]} expTypeList The list of experiment types.
 * @param {bool} isCustList Is this a list of request types?
 */
function iterateNextStepTypesList(expTypeList, isCustList) {
	expTypeList.forEach(function(expType) {
		var nextStepOption = createNextStepOption(expType["name"], expType["id"], isCustList);
		$("#nextStepExperimentType").append(nextStepOption);
	});
}

/**
 * On click function for the new experiment button that creates a new experiment.
 * @param {string} The ID of the experiment type list.
 * @param {string} The ID of the new exp notebook box.
 * @param {string} The ID of the new exp description box.
 * @param {button} The clicked button.
 */
function newExperimentOnClick(experimentTypeListId, experimentNotebookListId, experimentDescriptionBoxId, button)
{
	var t = document.getElementById(experimentTypeListId);
	var n = document.getElementById(experimentNotebookListId);
	var d = document.getElementById(experimentDescriptionBoxId);
	var projectLinkId = document.getElementById("linkProjectId").value;
	
	if (projectLinkId != "x")
	{
		if(n.options[n.selectedIndex].value != '-1')
		{
			if(t.options[t.selectedIndex] != undefined && t.options[t.selectedIndex].value != '')
			{
				expLoc = t.options[t.selectedIndex].value;
				expLoc = expLoc.split("?")
				redirPage = expLoc[0]+'?notebookId='+n.options[n.selectedIndex].value+"&projectId="+projectLinkId+"&description="+escape(encodeURIComponent(encodeIt(d.value)));
				if (expLoc.length > 1)
					redirPage += "&" + expLoc[1];

				window.location.href=redirPage;
				return;
			}
			else
			{
				swal("", "Please select an experiment type.", "warning");
			}
		}
		else
		{
			swal("", "Please select a notebook.", "warning");
		}
	}
	else
	{
		swal("", "The selected project has sub-projects. Please select the sub-project that you would like to link to.", "warning");
	}
	
	button.disabled = false;
	button.style.color = 'black';
}

$( document ).ready(function() {
	loadNotebooksICanWriteTo();
	loadProjectListForNewExperimentDialog();
	loadExperimentTypesICanCreate().then(function(response) {
		processExperimentTypesICanCreate(response);
	});
});
</script>



<script type="text/javascript"><!--//--><![CDATA[//><!--
sfHover = function() 
	{
		if (document.getElementById("nav"))
		{
			var sfEls = document.getElementById("nav").getElementsByTagName("LI");

			for (var i=0; i<sfEls.length; i++) 
				{
				sfEls[i].onmouseover=function() 
					{
					this.className+=" sfhover";
					}

				sfEls[i].onmouseout=function() 
					{
					this.className=this.className.replace(new RegExp(" sfhover\\b"), "");
					}
				}
		}
	}
if (window.attachEvent) window.attachEvent("onload", sfHover);
//--><!]]></script>

<!--[if IE 6]>
<script src="js/DD_belatedPNG.js?<%=jsRev%>"></script>
<script>
  /* EXAMPLE */
  DD_belatedPNG.fix('#homeContent');
  DD_belatedPNG.fix('#innerContent');
  DD_belatedPNG.fix('.homeBannerText H1');
  DD_belatedPNG.fix('.png');
  
  /* string argument can be any CSS selector */
  /* change it to what suits you! */
</script>
<![endif]--> 


</head>
<body class="yui3-skin-sam">
<div id="newExperimentDiv" class="popupDiv popupBox">
<div class="popupFormHeader">New Experiment</div>
<form name="copy_form" method="post" action="<%=mainAppPath%>/static/error.asp" onSubmit="return false;" class="popupForm">
	<section>
		<label for="newExperimentNotebookId" class="select-style-label"><%=selectNotebookLabel%></label>
		<div class="select-style">
			<select name="newExperimentNotebookId" id="newExperimentNotebookId" class="selectStyles">
			</select>
		</div>
	</section>
	<section class="popupTextareaSection">
		<label for="newExperimentDescription"><%=descriptionLabel%></label>
		<textarea id="newExperimentDescription" name="newExperimentDescription" style="box-sizing: content-box;"></textarea>
	</section>
	<section>
		<label for="newExperimentType" class="select-style-label"><%=experimentTypeLabel%></label>
		<div class="select-style">
			<select id="newExperimentType" name="newExperimentType" class="selectStyles">
					<option value="">--- SELECT ---</option>
			</select>
		</div>
	</section>
	<section>
		<label for="linkProjectId" class="select-style-label"><%=projectLabel%></label>
		<div id="newExperimentProjectList" class="select-style">
		</div>
	</section>
	<%
	Do While Right(projectJSON,1) = ","
		projectJSON = Mid(projectJSON,1,Len(projectJSON)-1)
	loop
	%>
	<%projectJSON = projectJSON &"]"%>
	<%session("projectJSON") = projectJSON%>
	<section class="bottomButtons buttonAlignedRight">
		<button onClick="this.disabled=true;this.style.color='grey';newExperimentOnClick('newExperimentType', 'newExperimentNotebookId', 'newExperimentDescription', this)" type="submit"><%=createLabel%></button>
	</section>
</form>
</div>

<%'inactivity div%>
<div id="inactivityDiv" class="popupDiv popupBox">
	<div class="popupFormHeader">Session Expiration</div>
	<p style="padding-bottom:20px;">Due to inactivity your session will expire in <span id="expireSeconds" style="font-size:18px;font-weight:bold;"></span> seconds.</p>
	<form onsubmit="return false;" class="popupForm">
		<section class="bottomButtons buttonAlignedRight">
			<button type="submit" onclick="allowReset=true;$.get('<%=mainAppPath%>/ajax_doers/resetInactivityTimer.asp?rand=<%=Rnd%>');hidePopup('inactivityDiv')">Stay Signed In</button>		
			<button type="submit" onclick="window.location='<%=mainAppPath%>/logout.asp'">Logout</button>
		</section>
	</form>
</div>

<div style="display:none;background-color:black;z-index:100;width:100%;height:100%;top:0;left:0;position:absolute;background:rgba(0,0,0,.7);filter: alpha(opacity = 80);" id="blackDiv"></div>
<div class="containerDiv background">
<div style="display:none;background-color:black;z-index:99;width:100%;height:100%;top:0;left:0;position:fixed;background:rgba(1,0,0,.7);filter: alpha(opacity = 70);border:none;" id="blackFrame" onclick="closeComments()"></div>
<div class="outerDiv">

<div class="topDiv redesigned2015" style="position:relative;">
	<!-- #include file="header2.0.asp"-->

<!-- ftui <div style="position:absolute;top:20px;left:300px;" id="headerNotificationsDiv"><div style="position:relative;"><span class="textOnImage overlayText" style="margin-left:5px;"><%=numNotifications%></span><a href="<%=mainAppPath%>/dashboard.asp"><img src="<%=mainAppPath%>/images/phone.gif" border="0"></a><%If numNotifications > 0 then%><span style="color:black;font-weight:bold;font-size:10px;margin-left:2px;"><%=newNotificationsLabel%><%End if%></div></div>-->
<!-- ftui
<div id="languageSelect">
	<a href="javascript:void(0);" onclick="setUserOption('languageSelect','English',function(){window.location=window.location});"><img src="<%=mainAppPath%>/images/small_flags/us.gif"></a>
	<a href="javascript:void(0);" onclick="setUserOption('languageSelect','Japanese',function(){window.location=window.location});"><img src="<%=mainAppPath%>/images/small_flags/jp.gif"></a>
	<a href="javascript:void(0);" onclick="setUserOption('languageSelect','Chinese',function(){window.location=window.location});"><img src="<%=mainAppPath%>/images/small_flags/cn.gif"></a>
</div>
-->
<!--
<div class="persNav">
	<%=welcomeLabel%>
	<span class="headUserName">
		<a <%If session("roleNumber") <> "1" then%>href="<%=mainAppPath%>/users/my-profile.asp"<%else%>href="<%=mainAppPath%>/my-profile.asp"<%End if%>><%=session("firstName") & " " & session("lastName")%></a>
	</span> &nbsp; | &nbsp;
	<a href="<%=mainAppPath%>/support-request.asp"><%=contactSupportLabel%></a>
	
	<div id="nonGxpDiv"><%If nonGXPLabel = 1 then%>Non-GxP&nbsp;<%End if%><%=session("companyName")%></div>
</div>
-->

<!-- ftui<div class="logoDiv"><a <%If session("hasELN") then%>href="<%=mainAppPath%>/dashboard.asp"<%End if%>><img src="<%=mainAppPath%>/images/arxspan-logo-1.gif" alt="logo" border="0"></a></div>-->


<!--#include file="nav_top_tool.asp"-->

</div>

<div id="prodZoom" style="position:absolute;display:none;width:300px;height:300px;border:1px solid black;top:0;right:0;background-color:white;z-index:100000;"><a href='javascript:void(0);' title='Click to Close'><img id="prodZoomImage" style="width:300px;height:300px;" src="<%=mainAppPath%>/images/blank.gif" onclick="this.src='images/blank.gif';document.getElementById('prodZoom').style.display='none';" border="0"/></a></div>

<a id="modalDummy" style="display:none;">needed for modal</a>
<script type="text/javascript">
$("#modalDummy").leanModal({ top : 40, overlay : 0.8, closeButton: ".modal_close" });
$("#lean_overlay").click(function(){try{hidePopup(currentPopup)}catch(err){}})
window.companyId = <%=session("companyId")%>;
window.companyId = <%=session("companyId")%>;
function updateCkEditorSize(storageKey, cke_instance){
	setUserOption(storageKey, parseInt(CKEDITOR.instances[cke_instance].ui.space( 'contents' ).getStyle( 'height' )));
}
</script>
<script type="text/javascript" src="<%=mainAppPath%>/js/select2-3.5.1/select2.js?<%=jsRev%>"></script>