<iframe id="infoFrame" src="javascript:false;" width="304" height="208" style="position:absolute;top:0px;right:0px;top:<%=top%>;z-index:10000;display:none;" border="0" frameborder="0"></iframe>
<div id="infoDiv" style="border:2px solid #999;width:300px;background-color:white;position:absolute;top:<%=top%>;right:0px;z-index:10001;background-color:#eee;display:none;">
<div style="overflow-y:scroll;height:200px;border-bottom:2px solid #999;position:relative;padding:2px;">
<div style="float:right;"><a href="javascript:void(0);" onclick="closeInfo()" style="font-weight:bold;">Close</a></div>
<div style="height:1px;clear:both;"></div>
<%If subsectionId = "experiment" Or subsectionId = "bio-experiment" Or subsectionId = "free-experiment" then%>
	<span style="margin-right:5px;font-weight:bold;line-height:14px;">Owner: </span><span><a href="<%=mainAppPath%>/users/user-profile.asp?id=<%=expUserId%>"><%=experimentOwner%></a></span><br/>
	<span style="margin-right:5px;font-weight:bold;line-height:14px;">Notebook: </span><span><a href="show-notebook.asp?id=<%=notebookId%>"><%=notebookName%></a></span><br/>
<%End if%>
<span style="margin-right:5px;font-weight:bold;line-height:14px;">Access: </span><span>&nbsp;</span><br/>
<div id="experimentAccessDiv"></div>
</div>
</div>
