<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
titleData = "Arxspan Inventory"
isObjectTemplates = true
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header.asp"-->
<%If session("invRoleName") = "Admin" Then%>
<style type="text/css">
#tableHolder{
	border-collapse:collapse;
}
#tableHolder td{
	background-color:white;
	width:100px;
}
#tableHolder tr{
	background-color:white;
}
</style>
<link rel="stylesheet" href="/arxlab/css/inventoryObjectManagement.css?<%=jsRev%>">
<div id="arxOneContainer">
<div>
<h1>Object Types</h1>
<br/>
<a href="objectTemplates/editObjectTemplate.asp">Add New</a>
<br/><br/>
<div id="tableHolder"></div>
<table id="objectFieldsTable" class="objectFieldsTable objectFieldsTable_commonPoolOfDropdowns">
	<thead>
		<th>Name</th>
		<!--<th>Basic</th>
		<th>Form Visibility</th>
		<th>Advanced</th>
		<th>Lookup</th>-->
		<th>Dropdown Options</th>
		<th>Disabled</th>
		<th></th>
	</thead>
	<tbody></tbody>
</table>
<div class="editTemplateBottomButtons">
	<div class="editTemplateBottomButtons_addField"><button type="button">New Dropdown</button></div>
</div>
</div>
<script type="text/javascript">
	$(document).ready(function(){
		r = restCall("/getObjectTypes/","POST",{})
		table = document.createElement("table");
		tbody = document.createElement("tbody")
		tr = document.createElement("tr");
		th = document.createElement("th");
		th.appendChild(document.createTextNode("Name"));
		tr.appendChild(th);
		th = document.createElement("th");
		th.innerHTML = "&nbsp;";
		tr.appendChild(th);
//		th = document.createElement("th");
//		th.innerHTML = "&nbsp;";
//		tr.appendChild(th);
		tbody.appendChild(tr);
		if(r.length==0){
			tr = document.createElement("tr");
			td = document.createElement("td");
			td.setAttribute("colspan","3");
			td.appendChild(document.createTextNode("No Objects"));
			tr.appendChild(td);
			tbody.appendChild(tr);
		}
		else {
			r.sort(function(a, b) {
				return a.name.localeCompare(b.name);
			});
		}
		
		for (var i=0;i<r.length;i++){
			tr = document.createElement("tr");
			td = document.createElement("td");
			td.appendChild(document.createTextNode(r[i]["name"]));
			tr.appendChild(td);
			td = document.createElement("td");
			a = document.createElement("a");
			a.href = "objectTemplates/editObjectTemplate.asp?id="+r[i]["id"];
			a.appendChild(document.createTextNode("Edit"));
			td.appendChild(a);
			tr.appendChild(td);
//			td = document.createElement("td");
//			a = document.createElement("a");
//			a.href = "javascript:void(0);";
//			a.setAttribute("id","delete_"+r[i]["id"])
//			a.onclick = (function(id){
//				return function(){
//					removeNode(id);
//				}
//			})(r[i]["id"])
//			a.appendChild(document.createTextNode("Remove"));
//			td.appendChild(a);
//			tr.appendChild(td);

			tbody.appendChild(tr);
		}
		table.appendChild(tbody);
		document.getElementById("tableHolder").appendChild(table)
		
		window.commonPoolOfDropdowns = restCall("/getPoolOfDropdowns/","POST",{});
		//window.commonPoolOfDropdowns['dropdowns'] = [{"poolOfFields_dropdown_id":"jvoisdjvoje9v03jf0j20njs","fieldName":"FIRST POOL DROPDOWN","options":["TriggersONE","TriggersTWO"],"optionIds":{"TriggersTWO":"TriggersTWO","TriggersONE":"TriggersONE"}},{"poolOfFields_dropdown_id":"ssovdj0dsfomomvpwoi3feof","fieldName":"SECOND POOL DROPDOWN","options":["FirstOptionOnSecondDropdown","2nd of 2nd"],"optionIds":{"2nd of 2nd":"2nd of 2nd","FirstOptionOnSecondDropdown":"FirstOptionOnSecondDropdown"}},{"poolOfFields_dropdown_id":"vj0mcw0j3ujfjsmfome1380m","fieldName":"THIRD POOL DROPDOWN","options":["1st of Third","Second of 3rd"],"optionIds":{"Second of 3rd":"Second of 3rd","1st of Third":"1st of Third"}}];
		console.log(window.commonPoolOfDropdowns);
		window.commonPoolReadyToLoad = {"fields": window.commonPoolOfDropdowns['dropdowns']}
		window.fieldGroupsObject = [];
		loadJSON(commonPoolReadyToLoad);
	});

	function removeNode(id){
		r = restCall("/removeObject/","POST",{"id":id});
		$('#delete_'+id).parent().parent().remove();
	}
</script>
<script type="text/javascript" src="js/objectTemplateManagement.js"></script>
</div>
<%End if%>
<!-- #include file="../_inclds/footer.asp"-->