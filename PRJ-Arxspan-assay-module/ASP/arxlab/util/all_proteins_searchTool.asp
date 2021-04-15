<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%server.scriptTimeout = 1800000%>

<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/_inclds/common/asp/lib_JChem.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/lib_reg.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/fnc_sendProteinToSearchTool.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%

Class StrConCatArray
	Private StringCounter
	Private StringArray()
	Private StringLength
	
	'called at creation of instance
	Private Sub Class_Initialize()
		StringCounter = 0
		InitStringLength = 128
		ReDim StringArray(InitStringLength - 1)
		StringLength = InitStringLength
	End Sub
	
	Private Sub Class_Terminate()
		Erase StringArray
	End Sub

	'add new string to array
	Public Sub Add(byref NewString)
		StringArray(StringCounter) = NewString
		StringCounter = StringCounter + 1
		
		'ReDim array if necessary
		If StringCounter MOD StringLength = 0 Then
			'redimension
			ReDim Preserve StringArray(StringCounter + StringLength - 1)
			
			'double the size of the array next time
			StringLength = StringLength * 2
		End If
	End Sub
	
	'return the concatenated string
	Public Property Get Value
		Value = Join(StringArray, "")
	End Property 
	
	'resets array
	Public Function Clear()
		StringCounter = 0
		
		Redim StringArray(InitStringLength - 1)
		StringLength = InitStringLength
	End Function		
End Class 



if session("userId") = "2" Or session("email")="support@arxspan.com" Or session("email") = "jeff.carter@arxspan.com" or session("email") = "amanda.lashua@arxspan.com" then

	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.setOption 2, 13056
	call getconnectedAdm
	call getconnectedAdm
	Call getConnectedJchemReg
	Set recST = server.CreateObject("ADODB.RecordSet")
	strQuery  = "SELECT cd_id, reg_id FROM "&regMoleculesTable&" WHERE groupId in (SELECT id from groupCustomFields WHERE visible=1) or groupId=0 or groupId is null order by cd_id DESC"
	recST.open strQuery,jchemRegConn,3,3
	outputString = ""

	Set outputString = New StrConCatArray
	Set lookupList = New StrConCatArray

	Do While Not recST.eof

		outputString.Add recST("cd_id")
		outputString.Add ", "

		lookupList.Add recST("cd_id")
		lookupList.Add ": """
		lookupList.Add recST("reg_id")
		lookupList.Add """, "
		
		recST.movenext
	Loop
	call disconnect	
	call disconnectadm
	Call disconnectJchemReg
	soutputString = outputString.value
	soutputString = LEFT(soutputString, (LEN(soutputString)-2)) 'remove the trailing ','
	slookupList = lookupList.value
	slookupList = LEFT(slookupList, (LEN(slookupList)-2)) 'remove the trailing ','
end If
%>

<div>
	<h3>Send ALL</h3>
	<p><button id="theButton" onClick="$('#theButton').hide();$('#justOneButton').hide();sendAll();">SEND ALL!</button></p>
	<br />
	<h3>Send ONE</h3>
	<p><input class="typeahead" type="text" id="oneId" placeholder="Reg ID"><button id="justOneButton" onClick="$('#theButton').hide();$('#justOneButton').hide();sendOne('oneId');">send one</button></p>
	<div id="theOutput"></div>
</div>

<script src="/arxlab/jqfu/js/jquery-1.10.2.js?<%=jsRev%>"></script>
<script src="typeahead.bundle.min.js"></script>
<script>
var theCdids = [<%=soutputString%>]

var lookupList = {<%=slookupList%>}

var states = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  local: Object.values(lookupList)
});


$(function(){
	$('#oneId').typeahead(
		{
		hint: true,
		highlight: true,
		minLength: 1
		},
		{
		name: 'my-dataset',
		source: states
		});
})

function sendAll(){

	cdid = theCdids.shift()
	data = {"cdid": cdid};

	//var div = document.getElementById("theOutput");
	//div.innerHTML += "<p>Trying CD_ID: " + cdid + "</p>";
	
	$.ajax({
		url: '/arxlab/util/one_protein_searchTool.asp',
		type: 'POST',
		dataType: 'json',
		cdid: cdid,
		data: data
	})
	.success(function(response) {
		var div = document.getElementById("theOutput");
		div.innerHTML += "<p>Sent REG_ID: " + lookupList[response.cdid] + "</p>";
	})
	.fail(function(error, textStatus, errorThrown) {
		var div = document.getElementById("theOutput");
		div.innerHTML += "<p>ERROR SENDING REG_ID: " + lookupList[this.cdid] + "</p>";
	})
	.always(function(){
		if (theCdids.length > 0){
			sendAll();
		}else{
			var div = document.getElementById("theOutput");
			div.innerHTML += "<h1>DONE</h1>";
		}
	});
}

function sendOne(inputId){

	regid = $("#"+inputId).typeahead('val');

	for(var key in lookupList){
		if (lookupList[key].toLowerCase() == regid.toLowerCase()){
			cdid = key;
			data = {"cdid": key};
		}
	}

	var div = document.getElementById("theOutput");
	div.innerHTML += "<p>Trying CD_ID: " + cdid + "</p>";
	
	$.ajax({
		url: '/arxlab/util/one_protein_searchTool.asp',
		type: 'POST',
		dataType: 'json',
		cdid: cdid,
		data: data
	})
	.success(function(response) {
		var div = document.getElementById("theOutput");
		div.innerHTML += "<p>Sent REG_ID: " + lookupList[response.cdid] + "</p>";
	})
	.fail(function(error, textStatus, errorThrown) {
		var div = document.getElementById("theOutput");
		div.innerHTML += "<p>ERROR SENDING REG_ID: " + lookupList[this.cdid] + "</p><p>" + error.responseText + "</p>";
	})
	.always(function(){
		var div = document.getElementById("theOutput");
		div.innerHTML += "<h1>DONE</h1><h3>refresh the page to do another</h3>";
	});
}

function getRegIdsFromLookupList(arr, searchKey) {
	retval = [];
	for (var key in arr){
		if (arr[key] == searchKey){
			retval.push(key);
		}
	}
	return retval;
}


</script>
