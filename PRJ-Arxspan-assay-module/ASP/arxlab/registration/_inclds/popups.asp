<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<div style="width:300px;height:300px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="addCustomFieldDiv" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopup('addCustomFieldDiv')" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif"></a>
<form name="addCustomFieldForm" method="post" action="#" class="chunkyForm" style="margin-top:20px;margin-left:30px;">
	<label for="noteText">Field To Add</label>
	<select id="addCustomFieldSelect">
	<option value="-1">--SELECT--</option>
	<%
	Call getConnectedJchemReg
	Set tRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * from customFields ORDER BY displayName ASC"
	tRec.open strQuery,jchemRegConn,3,3
	Do While Not tRec.eof
		%>
		<option value="<%=tRec("id")%>"><%=tRec("displayName")%></option>
		<%
		tRec.moveNext
	Loop
	tRec.close
	Set tRec = nothing
	Call disconnectJchemReg
	%>
	</select>
	<input type="button" value="Select" onclick="el=document.getElementById('addCustomFieldSelect');v = el.options[el.selectedIndex].value;if(v!=-1){addNewField(v);hidePopup('addCustomFieldDiv')};" style="width:100px;margin-left:130px;margin-top:10px;">
</form>
</div>