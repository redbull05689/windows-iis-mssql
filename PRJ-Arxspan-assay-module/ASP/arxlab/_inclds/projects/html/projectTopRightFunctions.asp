<form name="linkForm" id="linkForm" method="POST" action="<%=mainAppPath%>/projects/ajax/do/paste.asp" target="<%If inframe then%>submitFrameFrame<%else%>submitFrame<%End if%>">
<input type="hidden" name="linkTargetType" value="5">
<input type="hidden" name="linkTargetId" value="<%=request.querystring("id")%>">
</form>

<%If canWrite and not invitePending then%>
<a href="javascript:void(0)" onClick="pasteLink('linkForm')" id="pastaLink" title="Paste" style='display:block;'><img border="0" src="images/edit-paste.png" class="png" style="position:absolute;right:5px;"></a>
<%end if%>

<%If Not inframe then%>
<div style="position:absolute;right:45px;"><a href="javascript:void(0)" onClick="openInfo()" title="Show Info" id="infoLink" style="text-decoration:none;"><img border="0" src="images/info.gif"></a></div>
<%End if%>