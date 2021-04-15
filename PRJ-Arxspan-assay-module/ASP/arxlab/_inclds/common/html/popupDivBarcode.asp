<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<script type="text/javascript">
var barcodeDest = ""
function getBarcodes(elId){
	showPopup("barcodeDiv");
	document.getElementById("barcodes").focus();
	handleBarcodeRecordClick();
	barcodeDest = elId;
}
function closeBarcodeDiv(){
	document.getElementById("barcodes").value="";
	hidePopup('barcodeDiv');
}
function barcodeMonitor(){
	var ch = String.fromCharCode(event.keyCode);
	var ch2 = String.fromCharCode(event.keyCode-48);
	var filter = /[SVY0-9]/;
	if(!filter.test(ch) && !filter.test(ch2)){
	  event.returnValue = false;
	}
	if (event.keyCode < 48){
	  event.returnValue = false;
	}
	val = document.getElementById("barcodes").value;
	if(val.replace(/(\r\n|\n|\r)/gm,"").length>0 && val.replace(/(\r\n|\n|\r)/gm,"").length % <%=session("barcodeLength")%> == 0){
		if (document.getElementById("barcodes").value.substring(document.getElementById("barcodes").value.length-1)!="\n"){
			document.getElementById("barcodes").value += "\n";
		}
	}
}
function returnBarcodes(){
	retStr = ""
	arr = document.getElementById("barcodes").value.split("\n")
	for(i=0;i<arr.length;i++ ){
		if(arr[i]!=""){
			retStr += arr[i];
		}
		if(i!=arr.length-1){
			retStr += ",";
		}
	}
	document.getElementById(barcodeDest).value = retStr;
	closeBarcodeDiv();
}
function handleBarcodeRecordClick(){
	if(document.getElementById("recordBarcodes").checked){
		document.getElementById("barcodeRecordingDiv").style.display = "block";
		document.getElementById("barcodes").onkeydown = barcodeMonitor;
		document.getElementById("barcodes").focus();
	}else{
		document.getElementById("barcodeRecordingDiv").style.display = "none";
		document.getElementById("barcodes").onkeydown = null;
	}
}
</script>
<%'add barcodes div%>
<div style="width:420px;height:460px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="barcodeDiv" class="popupDiv">
<a href="javascript:void(0)" onClick="closeBarcodeDiv();return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif"></a>
<form name="barcode_form" method="post" action="" class="chunkyForm" style="margin-top:20px;margin-left:30px;" target="submitFrame2">
	<label for="barcodes">Barcodes</label>
	<textarea name="barcodes" id="barcodes" rows="8" cols="20" style="margin-left:10px;width:360px;height:260px;" onkeydown="barcodeMonitor()"></textarea>
	<br/>
	<label for="recordBarcodes">Record:</label>
	<input type="checkbox" checked id="recordBarcodes" name="recordBarcodes" style="display:inline;margin-left:4px;width:20px;" onclick="handleBarcodeRecordClick()">
	<input type="button" value="Done" id="barcodesDone" onclick="returnBarcodes()">
</form>
<div style="float:right;margin-top:-20px;margin-right:20px;" id="barcodeRecordingDiv">
Recording&nbsp;<img width="20" height="20" src="<%=mainAppPath%>/images/ajax-loader.gif">
</div>
</div>