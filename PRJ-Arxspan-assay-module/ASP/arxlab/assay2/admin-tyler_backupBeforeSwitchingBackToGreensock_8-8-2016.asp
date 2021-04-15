<!-- #include virtual='/arxlab/_inclds/globals.asp'-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
%>
<link rel="stylesheet" type="text/css" href="css/styles-formBuilder.css?<%=jsRev%>">
<script src='js/dynatree/jquery/jquery.js?<%=jsRev%>' type="text/javascript"></script>
<script type="text/javascript" src="js/platform-tyler.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jquery.nestable.js"></script>
<script type="text/javascript">
resultTypeId = 0;
adminTyler = true;

function restCall(url,verb,data,returnType){
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}
	form = "url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data));
	client.open("POST", "invp.asp", false);
	client.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	client.send(form);
	if (client.status == 200){
		if (client.responseText == ""){
			return JSON.parse("{}");
		}else{
			if (returnType == "text/plain"){
				return client.responseText;
			}else{
				return JSON.parse(client.responseText);
			}

		}
	}else{
		return false;
	}
}

function restCallA(url,verb,data,cb,returnType){
	var form
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}
	form = "url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data));
	client.onreadystatechange=(function(client,cb,returnType){
		return function(){
			restCallACb(client,cb,returnType);
		}
	})(client,cb,returnType);
	client.open("POST", "invp.asp", true);
	client.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	client.send(form);
	return false;
}

function restCallACb(client,cb,returnType){
	if (client.readyState == 4){
		if (client.status == 200){
			if (client.responseText == ""){
				cb(JSON.parse("{}"));
			}else{
				if (returnType == "text/plain"){
					cb(client.responseText);
				}else{
					cb(JSON.parse(client.responseText));
				}
			}
		}else{
			return false;
		}
	}
}
</script>

<%
	If session("servicesConnectionId") = "" Then
		session("servicesConnectionId") = session("userId")&getRandomString(16)
	End If

	strQuery = "UPDATE users SET servicesConnectionId="&SQLClean(session("servicesConnectionId"),"T","S")&" WHERE id="&SQLClean(session("userId"),"N","S")
	connAdm.execute(strQuery)
%>

<script type="text/javascript">
connectionId = '<%=session("servicesConnectionId")%>';
globalUserInfo = restCall("/elnConnection/","POST",{'connectionId':'<%=session("servicesConnectionId")%>','userId':<%=session("userId")%>,'whichClient':'<%=replace(whichClient,"'","\'")%>'})
</script>


<script type="text/javascript">

</script>

<script type="text/javascript">


function buildSelectChange(){
	if(field['value']=='fieldSet'){
		if(!field.parentField.getFieldByName('fields')){
			form.addField(form,field.parentField,field.parentField.parentField.parentField.getFieldByName('fields'),'afterChange');
		}
	}
	ifValShowSibling(field,'fieldSet','fields');
	ifNotValShowSibling(field,'fieldSet','required');
	ifNotValShowSibling(field,'fieldSet','validation');
	ifValShowSibling(field,'select by types','option types');
	ifValShowSibling(field,'select static','static options');
}

opts = selectOfType(1);
opts.push([1,"All Objects"])
realField = [
	{"__pFieldOptions":{"type":"text",name:"name","required":true},value:""},
	{"__pFieldOptions":{"type":"select",name:"type","options":["text","select static","select by types","select user list","checkbox","fieldSet","heading","hidden","file"],"required":true},"__pFunctions":{"afterChange":buildSelectChange.toString()+";buildSelectChange();"},value:""},
	{"__pFieldOptions":{"type":"checkbox",name:"multi"},value:false},
	{"__pFieldOptions":{"type":"checkbox",name:"required"},value:false},
	{"__pFieldOptions":{"type":"checkbox",name:"inTable"},value:false},
	{"__pFieldOptions":{"type":"checkbox",name:"isTableLink"},value:false},
	{"__pFieldOptions":{"type":"select",name:"validation","options":["isNumber","isGreaterThan5","isInteger"],multi:true},value:""},
	{"__pFieldOptions":{"type":"text",name:"static options",multi:true},"__pFunctions":{"afterShow":"if(field.parentField.getFieldByName('type').value!='select static'){field.hide();}"},value:""},
	{"__pFieldOptions":{"type":"select",name:"option types",multi:true,options:opts},"__pFunctions":{"afterShow":"if(field.parentField.getFieldByName('type').value!='select by types'){field.hide();}"},value:""},
	{"__pFieldOptions":{"type":"textArea",name:"afterChange"},value:""},
	{"__pFieldOptions":{"type":"textArea",name:"afterShow"},value:""},
	{"__pFieldOptions":{"type":"hidden",name:"theDunderId"},value:""},
]

realFields2 = [
	{"__pFieldOptions":{"type":"text",name:"name"},value:"",name:"name"},
	{"__pFieldOptions":{"type":"select",name:"icon",options:["hierarchy.gif","plate.gif","folder.gif","text_doc.gif"]},value:"",name:"icon"},
	{"__pFieldOptions":{"type":"select",name:"add types",multi:true},"__pFunctions":{"beforeShow":"field['__pFieldOptions'].options = selectOfType(1);"},value:""},
	{"__pFieldOptions":{"type":"checkbox",name:"canDelete"},value:false},
	{"__pFieldOptions":{"type":"checkbox",name:"showTable"},value:false},
	{"__pFieldOptions":{"type":"fieldSet","multi":true,"name":"fields"},"fields":[realField]},
	{"__pFieldOptions":{"type":"textArea",name:"beforeShow"},value:""},
	{"__pFieldOptions":{"type":"textArea",name:"onAdd"},value:""},
	{"__pFieldOptions":{"type":"textArea",name:"afterShow"},value:""},
	{"__pFieldOptions":{"type":"textArea",name:"linkFunction"},value:""},
	{"__pFieldOptions":{"type":"textArea",name:"JSON"},value:""},
	{"__pFieldOptions":{"type":"textArea",name:"beforeSave"},value:""},
]

isAdminPage = true;

function buildObj(){
	function inner(form){
		var a = {};
		a["__pFunctions"] = {}
		a["__pFunctions"]['afterShow']=form.getFieldByName('afterShow').value;
		a["__pFunctions"]["onAdd"] = form.getFieldByName('onAdd').value;
		a['beforeSave']=form.getFieldByName('beforeSave').value;

		var c = {};
		c["__parent"] = {};
		c["__parent"]["visible"] = true;
		c["__parent"]["canDelete"] = form.getFieldByName("canDelete").value;
		c["__parent"]["showTable"] = form.getFieldByName("showTable").value;
		if(form.getFieldByName('name')){
			c["__parent"]['name']=form.getFieldByName('name').value;
		}
		if(form.getFieldByName('linkFunction')){
			c["__parent"]["linkFunction"] = a["linkFunction"];
		}
		c["__parent"]["name"] = form.getFieldByName("name").value;
		c["__parent"]["icon"] = form.getFieldByName("icon").value;
		c["__pFunctions"] = {};
		c["__pFunctions"]["afterShow"] = a["__pFunctions"]["afterShow"]
		c["__pFunctions"]["beforeShow"] = a["__pFunctions"]["beforeShow"]
		c["__pFunctions"]["onAdd"] = a["__pFunctions"]["onAdd"]
		c["__parent"]["beforeSave"] = form.getFieldByName('beforeSave').value
		delete a["__pFunctions"];
		if(form.hasOwnProperty("_theDunderId")){
			if (form["_theDunderId"]){
				c["id"] = form._theDunderId;
			}
		}
		var newId = save2(c);
		form._theDunderId = newId;

		a["_dunderSource"] = newId;

		var fields = [];
		$.each(form.getFieldByName('fields').fields,function(i,field){
				var b = {};
				if(field.getFieldByName('type').value=="fieldSet"){
					b = inner(field);
				}
				b["__parent"] = {}
				b['__pFieldOptions'] = {};
				b["__pFunctions"] = {}
				b['__pFieldOptions']['name'] = field.getFieldByName('name').value;
				b["__parent"]['name'] = field.getFieldByName('name').value;
				b['__pFieldOptions']['type'] = field.getFieldByName('type').value;
				b['__pFieldOptions']['multi'] = field.getFieldByName('multi').value;
				b['__pFieldOptions']['required'] = field.getFieldByName('required').value;
				b['__pFieldOptions']['inTable'] = field.getFieldByName('inTable').value;
				b['__pFieldOptions']['isTableLink'] = field.getFieldByName('isTableLink').value;
				b['__pFieldOptions']['validation'] = field.getFieldByName('validation').value;
				b["__pFunctions"]['afterChange'] = field.getFieldByName('afterChange').value;
				b["__pFunctions"]['afterShow'] = field.getFieldByName('afterShow').value;
				if(b['__pFieldOptions']['type'] == 'select static'){
					b['__pFieldOptions']['options'] = field.getFieldByName('static options').value;
					b['__pFieldOptions']['type'] = "select";
				}
				if(b['__pFieldOptions']['type'] == 'select by types'){
					b["__pFunctions"]['afterShow'] += "field['__pFieldOptions']['options'] = selectOfType("+JSON.stringify(field.getFieldByName('option types').value)+")"
					b['__pFieldOptions']['type'] = "select";
				}
				if(b['__pFieldOptions']['type'] == 'select user list'){
					b["__pFunctions"]['afterShow'] += "field['__pFieldOptions']['options'] = restCall('/getUserList/','POST',{})"
					b['__pFieldOptions']['type'] = "select";
				}
				if(b['__pFieldOptions']['multi']&&field.getFieldByName('type').value=="fieldSet"){
					b.fields = [b.fields]
				}

				if(field.getFieldByName("theDunderId")){
					if(b["id"] = field.getFieldByName("theDunderId").value){
						b["id"] = field.getFieldByName("theDunderId").value;
					}
				}else{
					field.push({"__pFieldOptions":{"type":"hidden",name:"theDunderId"},value:""})
				}
				newId = save2(b);
				field.getFieldByName("theDunderId").value = newId;

				delete b["__pFieldOptions"];
				delete b["__pFunctions"];
				delete b["__parent"];
				b["_dunderSource"] = newId;
				fields.push(b);
		});
		a['fields'] = fields;
		return a;
	}
	a = inner(form.fd);
	form.getFieldByName('JSON').value = JSON.stringify(a);
}

realFields = {"name":"New Object","typeId":1,"fields":realFields2,"beforeSave":buildObj.toString()+";buildObj();"}

$(document).ready(function(){
	ggg = {"name":"Make Form","fields":[{"__pFieldOptions":{"type":"select","name":"form"},"__pFunctions":{"afterChange":"makeForm(field['value'])"},"linkFunction":"field['__pFieldOptions']['options'] = selectOfType(1)"}]}
	gggg = new Form(ggg)
	gggg.show("test2","edit")
	ggg = {"name":"View Form","fields":[{"__pFieldOptions":{"type":"select","name":"form"},"__pFunctions":{"afterChange":"editForm2(field['value'])"},"linkFunction":"field['__pFieldOptions']['options'] = selectOfType(1)"}]}
	gggg = new Form(ggg)
	gggg.show("test2","edit")
	ggg = {"name":"Edit Type","fields":[{"__pFieldOptions":{"type":"select","name":"form"},"__pFunctions":{"afterChange":"editForm(field['value'])"},"linkFunction":"field['__pFieldOptions']['options'] = selectOfType(1)"}]}
	gggg = new Form(ggg)
	gggg.show("test2","edit")
	rf = new Form(realFields)
	rf.show("test","edit");
})

function makeForm(theId){
	var f = new Form(getCache(theId))
	thisO = JSON.parse(f.getFieldByName('JSON').value)
	thisO.typeId = parseInt(theId);
	$("#ouput").val(JSON.stringify(thisO,null,2))
	$("#test3").empty();
	t = new Form(thisO);
	t.show("test3","edit");
}

function editForm(theId){
	f = new Form(getCache(theId))
	$("#ouput").val(JSON.stringify(f.fd,null,2))
	$("#test3").empty();
	f.show("test3","edit");
}
function editForm2(theId){
	f = new Form(getCache(theId))
	$("#ouput").val(JSON.stringify(f.fd,null,2))
	$("#test3").empty();
	f.show("test3","view");
}
</script>
<div id="tableView"></div>
<div id="test2">

</div>
<div id="test3">

</div>
<div id="test">

</div>
<div class="popupWindow"><div class="popupWindowContent"><div class="popupWindowTitle">Reorder Fields</div><div class="dd"></div></div><div class="popupWindowBackdrop"></div></div>

<div>Save Id:&nbsp;<span id="saveId"></span></div>
code
<input type="text" id="code">
<input type="button" value="getIt" onclick="$('#mp').val(JSON.stringify(getCache($('#code').val())))">
<br/>
<textarea id="output" style="width:400px;height:300px;"></textarea>
<script type="text/javascript">
function run(){
	f2 = new Form(JSON.parse($("#output").val()))
	f2.show("test","edit")
}
</script>
<input type="button" value='run' onclick='run()'/>
<textarea id="mp" style="width:400px;height:300px;"></textarea>
<script type="text/javascript">
function mp(){
	$("#output").val(JSON.stringify(JSON.parse($("#mp").val()),null,2))
}

$('body').on("mousedown", '.dd-nodrag', function(event) {
	console.log('mousedown on .dd-nodrag')
	event.preventDefault();
	return false;
});
</script>
<input type="button" value='make pretty' onclick='mp()'/>

<textarea id="running" style="width:400px;height:300px;"></textarea>
<input type="button" value='running'/>
<!--
<div style="position:fixed;right:40px;top:10px;background-color:white;width:200px;padding:20px;">
	<div class="label">label</div>
	<div class="fieldHolder">fieldHolder</div>
	<div class="field">field</div>
	<div class="value">value</div>
</div>
-->