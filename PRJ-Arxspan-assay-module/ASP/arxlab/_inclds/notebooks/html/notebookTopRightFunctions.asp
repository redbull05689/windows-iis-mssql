<form name="linkForm" id="linkForm" method="POST" action="<%=mainAppPath%>/misc/ajax/do/copy.asp" target="submitFrame">
<input type="hidden" name="linkType" value="4">
<input type="hidden" name="linkId" value="<%=notebookId%>">
</form>
<a href="javascript:void(0)" onClick="copyLink('linkForm')" title="Copy Notebook Link"><img border="0" src="images/edit-copy.png" class="png" style="position:absolute;right:5px;"></a>

<div style="position:absolute;right:45px;"><a href="javascript:void(0)" onClick="openInfo()" title="Show Info" id="infoLink" style="text-decoration:none;"><img border="0" src="images/info.gif"></a></div>