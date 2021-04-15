<div style="width:300px;height:300px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="groupsDiv" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopup('groupsDiv')" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif"></a>
	<div class="chunkyForm" style="padding-top:0px;margin-top:5px;margin-bottom:5px;">
	<label for="trash" style="margin-top:5px;">Group Select</label>
	<input type="hidden" name="trash">
	</div>
	<!--#include file="groupList.asp"-->
	<div class="chunkyForm" style="padding-top:0px;margin-top:0px;">
	<input type="button" value="<%=selectLabel%>" onclick="setGroups();hidePopup('groupsDiv')" style="width:100px;margin-left:130px;margin-top:10px;">
	</div>
</div>