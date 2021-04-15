<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->	
<table class="contentTable" style="<%If request.querystring("frameWidth") <> "" Then%>width:<%=request.querystring("frameWidth")%>px!important;<%End if%>">
	<tr>
	<td style="background-color:<%If request.querystring("frameBG") <> "" then%><%=request.querystring("frameBG")%><%else%>#DFDFDF<%End if%>;" valign="top">


<div class="pageContent" style="position:relative;<%If request.querystring("frameWidth") <> "" Then%>width:<%=request.querystring("frameWidth")%>px!important;<%End if%>">

<div id="unsavedChanges" class="experimentStatusMessage" style="position:absolute;top:-24px;left:220px;background-image:url('<%=mainAppPath%>/images/unsaved-bg.gif');background-repeat:no-repeat;width:500px;height:22px;display:none;font-weight:bold;padding:0px 0px 0px 0px;"><table style="width:100%;">
<tr><td align="center">
All changes saved to draft &ndash; <a href="javascript:void(0)" onclick="unsavedChanges=false;experimentSubmit(false,false,false)" style="color:blue;">Click&nbsp;to&nbsp;publish&nbsp;now</a> &ndash; (Keyboard&nbsp;shortcut:&nbsp;Ctrl+S)</td></tr></table>
</div>

<div id="noteSaved" style="position:absolute;top:-24px;left:220px;background-image:url('<%=mainAppPath%>/images/unsaved-bg.gif');background-repeat:no-repeat;width:330px;height:22px;display:none;font-weight:bold;padding:0px 0px 0px 0px;">
<table style="width:100%;">
<tr><td align="center">
Your note has been added</td></tr></table>
</div>