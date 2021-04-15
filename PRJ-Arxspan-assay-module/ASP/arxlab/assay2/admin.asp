<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual='/arxlab/_inclds/globals.asp'-->
<!-- #include file="../_inclds/security/functions/fnc_getUsersICanSee.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
'only allow support@arxspan to use this page
If session("email")<>"support@arxspan.com" And session("email")<>"jeff.carter@arxspan.com" Then
	response.End
End if
%>
<script src='js/dynatree/jquery/jquery.js?<%=jsRev%>' type="text/javascript"></script>
<script type="text/javascript" src="js/platform.js?<%=jsRev%>"></script>

<script type="text/javascript">
resultTypeId = 0;

//makes a rest call
//duplicated and commented in arxOne.js
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

//makes an async rest call
//duplicated and commented in arxOne.js
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

//manages ready state and calls callback for async rest call
//duplicated and commented in arxOne.js
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

<script type="text/javascript">
//get user info
connectionId = '<%=session("servicesConnectionId")%>';
globalUserInfo = restCall("/elnConnection/","POST",{'connectionId':'<%=session("servicesConnectionId")%>','userId':<%=session("userId")%>,'whichClient':'<%=replace(whichClient,"'","\'")%>','usersICanSee':'<%=getUsersICanSee()%>'})
</script>


<script type="text/javascript">


function buildSelectChange(){
	//determines which fields to show when the type drop down box is changed on a field
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

//manually created JSON objects that are the templates for fields and forms
//for all objects in the system
opts = selectOfType(1);
opts.push([1,"All Objects"])
realField = [
	{"__pFieldOptions":{"type":"text",name:"name","required":true},value:""},
	{"__pFieldOptions":{"type":"select",name:"type","options":["text","select static","select by types","select user list","checkbox","fieldSet","heading","hidden","file","permGroupList","textArea"],"required":true},"__pFunctions":{"afterChange":buildSelectChange.toString()+";buildSelectChange();"},value:""},
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
	{"__pFieldOptions":{"type":"select",name:"icon",options:["hierarchy.gif","plate.gif","folder.gif","text_doc.gif","lock.gif"]},value:"",name:"icon"},
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
	//recursively steps through form and gets each field which is a template field.  For each template field it makes a new real field
	//this data will be stored in the forms JSON field.  The system can then load this form, the take the JSON field value and use it to create a new
	//form from this tempalate of the type that this form intendends. for each template field a dunder object is created holding all of the properties the resulting field
	//should have.  These properties are stored in a dunder object and a link with an it to the dunder properties are all that is saved in the JSON field
	function inner(form){
		var a = {};
		//add functions to dunder object
		a["__pFunctions"] = {}
		a["__pFunctions"]['afterShow']=form.getFieldByName('afterShow').value;
		a["__pFunctions"]["beforeShow"] = form.getFieldByName('beforeShow').value;
		a["__pFunctions"]["onAdd"] = form.getFieldByName('onAdd').value;
		a['beforeSave']=form.getFieldByName('beforeSave').value;

		var c = {};
		//add parent fields to dunder object
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
		//if we do have a dunder object for this field then it already exists. use the existing id for the dunder object
		if(form.hasOwnProperty("_theDunderId")){
			if (form["_theDunderId"]){
				c["id"] = form._theDunderId;
			}
		}
		var newId = save2(c);
		form._theDunderId = newId;

		//set the id of the dunder object in the form so the next time (edit) we know whether or not to save a new dunder object
		a["_dunderSource"] = newId;

		//loop through all of the fields in the case of a field set and follow all the same steps as above
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
	//set JSON field to result of form template->form process
	form.getFieldByName('JSON').value = JSON.stringify(a);
}

realFields = {"name":"Object Type","typeId":1,"fields":realFields2,"beforeSave":buildObj.toString()+";buildObj();"}

$(document).ready(function(){
	//make make form drop down
	ggg = {"name":"make form","fields":[{"__pFieldOptions":{"type":"select","name":"form"},"__pFunctions":{"afterChange":"makeForm(field['value'])"},"linkFunction":"field['__pFieldOptions']['options'] = selectOfType(1)"}]}
	gggg = new Form(ggg)
	gggg.show("test2","edit")
	//make edit type frop down
	ggg = {"name":"edit type","fields":[{"__pFieldOptions":{"type":"select","name":"form"},"__pFunctions":{"afterChange":"editForm(field['value'])"},"linkFunction":"field['__pFieldOptions']['options'] = selectOfType(1)"}]}
	gggg = new Form(ggg)
	gggg.show("test2","edit")
	//create default empty object
	rf = new Form(realFields)
	rf.show("test","edit");
})

function makeForm(theId){
	//edit a form from template put stringifyed JSON in the output text area
	var f = new Form(getCache(theId))
	thisO = JSON.parse(f.getFieldByName('JSON').value)
	thisO.typeId = parseInt(theId);
	$("#ouput").val(JSON.stringify(thisO,null,2))
	$("#test3").empty();
	t = new Form(thisO);
	t.show("test3","edit");
}

function editForm(theId){
	//edit a template put stringifyed JSON in the output text area
	f = new Form(getCache(theId))
	f.fd.beforeSave = buildObj.toString()+";buildObj();"
	$("#ouput").val(JSON.stringify(f.fd,null,2))
	$("#test3").empty();
	f.show("test3","edit");
}
</script>
<style type="text/css">

.label{
	background-color:#0f0;
	display:inline-block;
	height:auto;
	width:200px;
}
.fieldHolder{
	/*background-color:yellow;*/
	position:relative;
}

.displayTable .field{
	text-align:center;
	padding:0px;
}

.displayTable .field .displayTable .field .displayTable .field{
	text-align:center;
	padding:0px;
}

.displayTable .field .field .field{
	text-align:center;
	padding:10px;
}

.displayTable .field .displayTable .field{
	text-align:center;
	padding:0px;
}

.displayTable .field .field .field .field .field .field{
	text-align:center;
	padding:10px;
}

.displayTable .field .field .field .field .field .field .field{
	text-align:center;
	padding:0px;
}

.displayTable .field .field .field .field .field .field .field .field .field{
	text-align:center;
	padding:10px;
}



.displayTable .fieldHolder .fieldHolder{
	display:inline-block;
	margin:-1px 0 0 -1px;
	min-width:200px;
	border:1px solid black;
	padding:2px;
}

.displayTable .fieldHolder .fieldHolder .fieldHolder{
	display:block;
	border:none;
	margin:0;
	padding:0;
}

.displayTable .fieldHolder .fieldHolder .displayTable .fieldHolder .fieldHolder{
	display:inline-block;
	margin:-1px 0 0 -1px;
	min-width:200px;
	border:1px solid black;
	padding:2px;
}

.displayTable .fieldHolder .fieldHolder .fieldHolder .fieldHolder .fieldHolder .fieldHolder{
	display:block;
	border:none;
	margin:0;
	padding:0;
}

.displayTable .fieldHolder .fieldHolder .displayTable .fieldHolder .fieldHolder .displayTable .fieldHolder .fieldHolder{
	display:inline-block;
	margin:-1px 0 0 -1px;
	min-width:200px;
	border:1px solid black;
	padding:2px;
}

.displayTable .fieldHolder .fieldHolder .fieldHolder .fieldHolder .fieldHolder .fieldHolder .fieldHolder .fieldHolder .fieldHolder{
	display:block;
	border:none;
	margin:0;
	padding:0;
}

.tableHead{
	text-align:left;
}

.tableHeader{
	display:inline-block;
	margin:-1px 0 0 -1px;
	min-width:200px;
	text-align:center;
	border:1px solid black;
	padding:2px;
}


.field{
	/*background-color:#aaa;*/
	/*border:1px solid #aaa;*/
	display:inline-block;
	vertical-align:top;
}
.fieldValue{
	position:relative;
}
.value{
	/*background-color:white;*/
}
.removeParentLink{
	position:absolute;
	background-color:white;
	width:16px;
	height:16px;
	top:0px;
	right:-4px;
	z-index:100000;
}
</style>
<div id="test2" style="width:4000px;">

</div>
<div id="test3" style="width:4000px;">

</div>
<div id="test" style="width:4000px;">

</div>

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
</script>
<input type="button" value='make pretty' onclick='mp()'/>

<textarea id="running" style="width:400px;height:300px;"></textarea>
<input type="button" value='running'/>

<div style="position:fixed;right:40px;top:10px;background-color:white;width:200px;padding:20px;">
	<div class="label">label</div>
	<div class="fieldHolder">fieldHolder</div>
	<div class="field">field</div>
	<div class="value">value</div>
</div>