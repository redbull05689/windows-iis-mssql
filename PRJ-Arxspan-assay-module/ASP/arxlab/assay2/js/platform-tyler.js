isAdminPage = false;

function parseSelectList(theId){
	var f;
	f = new Form(getCache(theId));
	x = f.getFieldByName("options").getValArray()
	if(x.hasOwnProperty("options")){
		return x["options"];
	}
	if(x.hasOwnProperty("options.text") && !x.hasOwnProperty("options.value")){
		return x["options.text"];
	}
	if(x.hasOwnProperty("options.text") && x.hasOwnProperty("options.value")){
		return zip(x["options.value"],x["options.text"]);
	}
	return [];
}

function attachFieldByName(object){
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
            	if(property!='_links'){
                	attachFieldByName(object[property]);
                }
            }
        }
    }
	if(object.hasOwnProperty("fields")){
		if(!object["__pFieldOptions"]["multi"]){
			object.getFieldByName = (function(ob){
				return function(theName){
					var result = false;
					$.each(ob.fields,function(i,field){
						if (field["__pFieldOptions"]["name"].toLowerCase()==theName.toLowerCase()){
							result = field;
							return false;
						}
					});
					return result;
				}
			})(object);
			object.getFieldNames = (function(ob){
				return function(){
					var result = [];
					$.each(ob.fields,function(i,field){
						result.push(field["__pFieldOptions"]["name"])
					});
					return result;
				}
			})(object);
		}else{
			$.each(object.fields,function(i,fieldArrayItem){
				fieldArrayItem.getFieldByName = (function(ob){
					return function(theName){
						var result = false;
						$.each(ob,function(i,field){
							if (field["__pFieldOptions"]["name"].toLowerCase()==theName.toLowerCase()){
								result = field;
								return false;
							}
						});
						return result;
					}
				})(fieldArrayItem);
			})
			$.each(object.fields,function(i,fieldArrayItem){
				fieldArrayItem.getFieldNames = (function(ob){
					return function(){
						var result = [];
						$.each(ob,function(i,field){
							result.push(field["__pFieldOptions"]["name"])
						});
						return result;
					}
				})(fieldArrayItem);
			})
		}
	}
}

function attachGetValArray(object){
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
            	if(property!='_links'){
                	attachGetValArray(object[property]);
                }
            }
        }
    }
	if(object.hasOwnProperty("__pFieldOptions")){
		if(object["__pFieldOptions"]["type"]=="fieldSet"){
			object.getValArray = (function(ob){
					return function(){
						if (ob["__pFieldOptions"]["multi"]){
							r = {};
							$.each(ob.fields,function(i,fieldItemArray){
								$.each(fieldItemArray,function(i,field){
									if(field["__pFieldOptions"]["type"]!="fieldSet"){
										if(!r.hasOwnProperty(ob["__pFieldOptions"]["name"]+"."+field["__pFieldOptions"]["name"])){
											r[ob["__pFieldOptions"]["name"]+"."+field["__pFieldOptions"]["name"]] = [];
										}
										if(field["__pFieldOptions"]["multi"]){
											r[ob["__pFieldOptions"]["name"]+"."+field["__pFieldOptions"]["name"]].push(field["value"] || []);								
										}else{
											r[ob["__pFieldOptions"]["name"]+"."+field["__pFieldOptions"]["name"]].push(field["value"] || "");
										}
									}
								});
							});
							return r;							
						}else{
							r = {};
							$.each(ob.fields,function(i,field){
								if(field["__pFieldOptions"]["type"]!="fieldSet"){
									if(field["__pFieldOptions"]["multi"]){
										r[ob["__pFieldOptions"]["name"]+"."+field["__pFieldOptions"]["name"]] = field["value"] || [];								
									}else{
										r[ob["__pFieldOptions"]["name"]+"."+field["__pFieldOptions"]["name"]] = field.hasOwnProperty("value") ? [field["value"]] : [];
									}
								}
							});
							return r;
						}
					}
				})(object);
		}else{
			object.getValArray = (function(ob){
					return function(){
						if(ob["__pFieldOptions"]["multi"]){
							r = {};
							r[ob["__pFieldOptions"]["name"]] = ob["value"] || [];
							return r;
						}else{
							r = {}
							r[ob["__pFieldOptions"]["name"]] = ob.hasOwnProperty("value") ? ob["value"] : [];
							return r;
						}
					}
				})(object);
		}
	}
}

function attachParentField(object){
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
            	if(property!='_links'){
                	attachParentField(object[property]);
                }
            }
        }
    }
	if(object.hasOwnProperty("fields")&&!object[property].parentField){
		if(!object["__pFieldOptions"]["multi"]){
			$.each(object.fields,function(i,field){
				if(!field.hasOwnProperty("parentField")){
					Object.defineProperty(field, 'parentField',{value:object,enumerable:false})
				}
			});
		}else{
			$.each(object.fields,function(i,fieldArrayItem){
				Object.defineProperty(fieldArrayItem, 'parentField',{value:object,enumerable:false})
				$.each(fieldArrayItem,function(i,field){
					if(!field.hasOwnProperty("parentField")){
						Object.defineProperty(field, 'parentField',{value:fieldArrayItem,enumerable:false})
					}
				});
			})
		}
	}
}

function removeParentField(object){
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
                removeParentField(object[property]);
            }
        }
    }
	if(object.hasOwnProperty("parentField")){
		delete object["parentField"];
	}
}

function removeDunder(object){
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
            	if(property.substring(0,2)!="__"){
            		removeDunder(object[property]);	
            	}else{
            		delete object[property];
            	}
                
            }
        }
    }
}

function setDefaultValues(object,propertyName){
	propertyName = propertyName || "";
	for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
            	if(property!='_links'){
                	setDefaultValues(object[property],property);
                }
            }
        }
    }
	if(!object.hasOwnProperty("fields") && !object.hasOwnProperty("value")&& propertyName.substring(0,2)!="__"  && object.constructor.name == "Object"){
		var theVal = "";
		if(object["__pFieldOptions"]["type"]=="checkbox"){
			theVal = false;
		}
		if(!object["__pFieldOptions"]["multi"]){
			object["value"] = object["value"] || theVal;
		}else{
			object["value"] = object["value"] || [theVal];
		}
	}
}

function fixSort(form){
	var b = {}
	$.each(form.fields,function(i,field){
		if(field["__pFieldOptions"]["type"]!="fieldSet"){
			try{
				b[field["__pFieldOptions"]["name"].toLowerCase().replace(/\s+/ig,"_")] = field["value"]
			}catch(err){}
		}
	})
	form._sort = b;
}

function fixNumbers(object){
	for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
               	fixNumbers(object[property]);
            }
        }
    }
	if(object.hasOwnProperty("value") && object.constructor.name == "Object"){
		if(object.hasOwnProperty("__pFieldOptions")){
			if (object["__pFieldOptions"].hasOwnProperty("validation")){
				if (object["__pFieldOptions"]["validation"].indexOf("isNumber")!=-1 || object["__pFieldOptions"]["validation"].indexOf("isInteger")!=-1){
					if($.isArray(object["value"])){
						if($.isArray(object["value"][0])){
							for(var i=0;i<object["value"].length;i++){
								for(var i=0;i<object["value"][0].length;i++){
									try{
										object["value"][i][j] = parseFloat(object["value"][i][j]);
									}catch(err){}								
								}
							}
						}else{
							//does jquery each pass by ref?
							for(var i=0;i<object["value"].length;i++){
								try{
									object["value"][i] = parseFloat(object["value"][i]);
								}catch(err){}								
							}
						}
					}else{
						try{
							object["value"] = parseFloat(values);
						}catch(err){}
					}
				}
			}
		}
	}
}

function attachOptions(object,propertyName){
	propertyName = propertyName || "";
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
            	if(property!='_links'){
                	attachOptions(object[property],property);
                }
            }
        }
    }
	if(propertyName.substring(0,2)!="__" && object.constructor.name == "Object"){
		object["__pFieldOptions"] = object["__pFieldOptions"] || {};
		object["__pDefOptions"] = object["__pDefOptions"] || {};
		object["__pFunctions"] = object["__pFunctions"] || {};
		object["__pExcelOptions"] = object["__pExcelOptions"] || {};
		object["__pDisplayOptions"] = object["__pDisplayOptions"] || {};
	}
}

function getDunder(object){
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
                getDunder(object[property]);
            }
        }
    }
	if(object.hasOwnProperty("linkFunction")){
		tempF = new Function("field",object["linkFunction"]);
		tempF(object);
	}
	if(object.hasOwnProperty("_dunderSource")){
		var lO = getCache(object["_dunderSource"])
		for (var property in lO){
			if(lO.hasOwnProperty(property)){
				if(property == "__parent"){
					for (var property2 in lO["__parent"]){
						object[property2] = lO["__parent"][property2];
					}
				}else{
					if(object.hasOwnProperty(property)){
						if (property.substring(0,2)=="__"){
							for (var property2 in lO[property]){
								// dunders sometimes have the property fields in them
								// that is why there is a check for __ The check for __ may be desired anyways
								// but the dunders should not have a fields property.
								if(lO[property].hasOwnProperty(property2)){
									object[property][property2] = lO[property][property2];
								}
							}
						}	
					}else{
						if (property.substring(0,2)=="__"){
							object[property] = lO[property];
						}
					}
				}
			}
		}
	}
}




function Form(fd){
	this.viewState = "view";
	this.fd = fd;
	attachOptions(this.fd);
	//this.cleanFieldSets(this.fd);
	getDunder(this.fd);
	attachParentField(this.fd);
	attachFieldByName(this.fd);
	this.getFieldByName = this.fd.getFieldByName;
	this.getFieldNames = this.fd.getFieldNames;
	attachGetValArray(this.fd);
	setDefaultValues(this.fd);
}

Form.prototype.showHeader = function(){
	var self = this;
}

Form.prototype.show = function(theDiv,viewState){
	var self = this;

	self.viewState = viewState || "view";
	if(self.fd.hasOwnProperty("name")){
		$("#"+theDiv).append($("<h1>"+self.fd.name+"</h1>"))
	}

	console.log(self.fd.fields);
	//console.log(JSON.stringify(self.fd.fields));
	cals = [];
	$.each(self.fd.fields,function(i,field){
		$("#"+theDiv).append(self.displayField(field));
	});
	for(var i=0;i<cals.length;i++){
		cals[i]();
	}

	if(self.fd["__pFunctions"]["afterShow"]){
		tempF = new Function("field","form",self.fd["__pFunctions"]["afterShow"]);
		tempF(self,self);
	}

	formErrors = $("<div id='formErrors'/>");
	$("#"+theDiv).append(formErrors);

	if(self.viewState=="view"){
		if (self.fd.typeId == resultSetTypeId){
			resultsHolder = $("<div id='resultsHolder' style='position:relative;'>");
			resultsHolderInner = $("<div id='resultsHolderInner'>");
			resultsHolder.append(resultsHolderInner);
			D = {}
			D["value"] = restCall("/getChildIds/","POST",{"id":self.fd.id})["childIds"];
			D["position"] = 0;
			D["id"] = "resultsHolderInner";
			scroller = $(createChildLinksScroller(false,D,"resultsHolderInner",false,false,false));
			resultsHolder.append(scroller)
			$("#"+theDiv).append(resultsHolder);
			afterScroller()
		}
	}

	buttonHolder = $("<div id='buttonHolder'/>")
	if(self.viewState == "edit"){
		b = $("<input type='button' value='SAVE'/>");
		b[0].onclick = (function(form){
			return function(){
				if(!form.validate()){
					alert('Form contains errors.  Please review your data and try again');
					return false;
				}
				if(form.fd["beforeSave"]){
					tempF = new Function("field","form",form.fd["beforeSave"]);
					aa = tempF(self,self);
					if(aa=="error"){
						return false;
					}
				}
				fixSort(form.fd);
				fixNumbers(form.fd);
				if(form.fd.typeId!=1){
					form.removeDunder();
				}
				if(form.fd.id){
					delete cache[form.fd.id];
					cache[form.fd.id] = JSON.parse(JSON.stringify(form.fd))
					theId = form.fd.id;
					restCall("/saveForm/","POST",{"form":form.fd});
				}else{
					theId = saveNew(form.fd)
				}
				makeForm(theId,"arxOneContainer","view")
				nodesToReload = [form.fd.parentId]
				handleNodeReloads(nodesToReload,false,false,$("#tree").dynatree("getTree"))
				$("#saveId").text(theId);
				$("#output").val(JSON.stringify(form.fd,null,2));
			}
		})(self)
		buttonHolder.append(b);
		$("#running").val(JSON.stringify(self.fd,null,2))
	}
	if(self.viewState == "view"){
		if(canEdit){
			b = $("<input id='editButton' type='button' value='EDIT'/>");
			b[0].onclick = (function(form){
				return function(){
					makeForm(form.fd.id,"arxOneContainer","edit")
				}
			})(self)
			buttonHolder.append(b);
			$("#running").val(JSON.stringify(self.fd,null,2))
		}
		if(self.fd.hasOwnProperty("locked")){
			if (self.fd["locked"]){
				b.attr("style", "display: none !important");;
				console.log("it is locked")
			}
			if(jsRole=='admin'){
				b = $("<input id='unlockButton' type='button' value='UNLOCK'/>");
				if(!self.fd.locked){
					b.attr("style", "display: none !important");;
				}
				b[0].onclick = (function(form){
					return function(){
						if(confirm('Are you sure you want to unlock this protocol?')){
							var p = new Form(getCache(self.fd.id))
							p.fd.locked = false;
							delete cache[p.fd.id];
							cache[p.fd.id] = JSON.parse(JSON.stringify(p.fd))
							theId = p.fd.id;
							restCall("/saveForm/","POST",{"form":p.fd});
							$('#editButton').attr("style", "display: inline-block !important");;
							$('#unlockButton').attr("style", "display: none !important");;
							$('#lockButton').attr("style", "display: inline-block !important");;
							handleNodeReloads([self.fd.parentId],[],false,$("#tree").dynatree("getTree"))
						}
					}
				})(self)
				buttonHolder.append(b);

				b = $("<input id='lockButton' type='button' value='LOCK'/>");
				if(self.fd.locked){
					b.attr("style", "display: none !important");;
				}
				b[0].onclick = (function(form){
					return function(){
						if(confirm('Are you sure you want to lock this protocol?')){
							var p = new Form(getCache(self.fd.id))
							p.fd.locked = true;
							delete cache[p.fd.id];
							cache[p.fd.id] = JSON.parse(JSON.stringify(p.fd))
							theId = p.fd.id;
							restCall("/saveForm/","POST",{"form":p.fd});
							$('#editButton').attr("style", "display: none !important");;
							$('#unlockButton').attr("style", "display: inline-block !important");;
							$('#lockButton').attr("style", "display: none !important");;
							handleNodeReloads([self.fd.parentId],[],false,$("#tree").dynatree("getTree"))
						}
					}
				})(self)
				buttonHolder.append(b);

			}
		}
		if(self.fd.canDelete && canDelete||1==1){
			b = $("<input type='button' value='DELETE'/>");
			b[0].onclick = (function(form){
				return function(){
					nodesToReload = [form.fd.parentId]
					delete cache[form.fd.id];
					restCall("/deleteForm/","POST",{"id":form.fd.id})
					handleNodeReloads(nodesToReload,false,false,$("#tree").dynatree("getTree"))
					$("#arxOneContainer").empty();
				}
			})(self)
			buttonHolder.append(b);
			$("#running").val(JSON.stringify(self.fd,null,2))
		}
	}
	if(self.fd.typeId!=resultTypeId){
		$("#"+theDiv).append(buttonHolder);
	}
}
function sendToFT(theId){

	return true;
}

function save2(fd){
	if(fd.id){
		delete cache[fd.id];
		cache[fd.id] = JSON.parse(JSON.stringify(fd))
		theId = fd.id;
		restCall("/saveForm/","POST",{"form":fd});
	}else{
		theId = saveNew(fd)
	}
	return theId;
}


function saveNew(theOb){
	theObEx = $.extend(true,{},theOb)
	id = restCall("/getNextId/","POST",{})["id"];
	theObEx.id = id;
	cache[id] = JSON.parse(JSON.stringify(theObEx))
	restCall("/saveForm/","POST",{"form":theObEx});
	return id;
}

function applyDisplayOptions(field,theVal){
	showScientificNotation = field["__pDisplayOptions"]["scientificNotation"];
	noDecimals = false;
	numDecimals = field["__pDisplayOptions"]["decimalPlaces"];
	if(isNumber(numDecimals)){
		numDecimals = parseInt(numDecimals)
	}else{
		if(showScientificNotation){
			numDecimals = 1;
		}else{
			noDecimals = true;
		}
	}

	if(showScientificNotation){
		theVal = theVal.toExponential(numDecimals);	
	}else{
		if(!noDecimals){
			theVal = theVal.toFixed(numDecimals);
		}
	}
	return theVal;
}

function zeroPad(num, places) {
  var zero = places - num.toString().length + 1;
  return Array(+(zero > 0 && zero)).join("0") + num;
}

Form.prototype.displayField = function(field,opts){
	var self = this;
	var fieldHolderDiv,fieldDiv,o,a,d3,d4,label,sendOpts,fieldCopy;
	var opts = opts || {}

	fieldHolderDiv = $('<div class="fieldHolder" fieldtype="' + field["__pFieldOptions"]["type"] + '"></div>');
	field.show = (function(theDiv){
			return function(){
				$(theDiv).show();
			}
		})(fieldHolderDiv)
	field.hide = (function(theDiv){
			return function(){
				$(theDiv).hide();
			}
		})(fieldHolderDiv)
	labelText = field["__pFieldOptions"]["name"];
	if(field["__pFieldOptions"]["required"]){
		labelText += "*"
	}
	label = $("<div class='label'>"+labelText+"</div>");
	if(!field.hasOwnProperty("labelDiv")){
		Object.defineProperty(field, 'labelDiv',{value:label,enumerable:false})
	}
	if(!opts["displayTable"]&&field["__pFieldOptions"]["type"]!="heading"&&!(field["__pFieldOptions"]["type"]=="checkbox"&&self.viewState == "edit")&&field["__pFieldOptions"]["type"]!="hidden"){
		fieldHolderDiv.append(label);
	}
	fieldDiv = $("<div class='field'></div>");
	if(opts["noNest"]){
		fieldDiv.addClass("noNest")
	}
	fieldHolderDiv.addClass("fn_"+self.cleanClass(field["__pFieldOptions"]["name"]))
	if(field["__pFieldOptions"]["type"] == "fieldSet"){
		fieldHolderDiv.addClass("fieldSetHolder")
	}

	field["__pFieldOptions"]["multi"] = field["__pFieldOptions"]["multi"] || false 

	if(field["__pFunctions"]["beforeShow"]){
		tempF = new Function("field","form",field["__pFunctions"]["beforeShow"]);
		tempF(field,self);
	}

	fieldVal = field["value"];
	if(field["__pFieldOptions"]["multi"]){
		fieldVal = self.requireArray(fieldVal).slice(0);
		if(fieldVal.length>0){
			firstVal = fieldVal[0];
		}else{
			firstVal = "";
		}
	}else{
		firstVal = fieldVal;
	}

	if(field["__pFieldOptions"]["type"]=="select" && isNumber(firstVal) && self.viewState=="view"){
		var fff = new Form(getCache(firstVal));
		if(fff.getFieldByName('name')){
			firstVal = fff.getFieldByName('name').value;
		}
	}

	isAssayTable = false;
	if(field["__pExcelOptions"]["dataWidth"]){
		dataWidth = parseInt(field["__pExcelOptions"]["dataWidth"]);
		dataHeight = parseInt(field["__pExcelOptions"]["dataHeight"]);
		hasHeaders = field["__pExcelOptions"]["hasHeaders"];
		if(hasHeaders){
			dataHeight += 1;
		}
		if(!(dataWidth==1 && dataHeight==1)){
			isAssayTable = true;
			assayTable = $("<table/>");
			assayTable.addClass("plateMap")
			if (dataWidth == 1){
				fieldVal = [fieldVal];
			}
			for(var i=0;i<dataHeight;i++){
				tr = $("<tr/>");
				if(i==0 && hasHeaders){
					tr.addClass("headerRow")
				}
				if(i%2==0){
					tr.addClass("odd");
				}else{
					tr.addClass("even");
				}
				for(var j=0;j<dataWidth;j++){
					td = $("<td/>")
					theVal = fieldVal[j][i];
					if(!(hasHeaders && i==0)){
						theVal = applyDisplayOptions(field,theVal);
					}
					td.append($("<span>"+theVal+"</span>"));
					tr.append(td);
				}
				assayTable.append(tr);
			}
		}
	}

	if(field["__pFieldOptions"]["type"] == "fieldSet"){
		sendOpts = {}
		if(field["__pFieldOptions"]["display"]=="table"){
			sendOpts["displayTable"] = true;
			opts["displayTable"] = true;
			if(!opts["noNest"]){
				tableHead = $("<div class='tableHead tableHead_"+self.cleanClass(field["__pFieldOptions"]["name"])+"'></div>");
				if(field["__pFieldOptions"]["multi"]){
					iter = field["fields"][0]
				}else{
					iter = field["fields"]
				}
				$.each(iter,function(i,field){
					tableHead.append($("<div class='tableHeader th_"+self.cleanClass(field["__pFieldOptions"]["name"])+"'>"+field["__pFieldOptions"]["name"]+"</div>"));
				})
				fieldDiv.append(tableHead)
			}
		}

		if(field["__pFieldOptions"]["multi"]){
			$.each(field["fields"],function(q,fieldFromFields){
				d3 = $("<div class='field fieldSetField'></div>")
				$.each(fieldFromFields,function(i,field2){
					d3.append(self.displayField(field2,sendOpts))
				});
				if(field["__pFunctions"]["afterShow"]){
					tempF = new Function("field","form",field["__pFunctions"]["afterShow"]);
					tempF(fieldFromFields,self);
				}
				d3 = $("<div class='field'></div>").append($("<div class='fieldHolder'></div>").append(d3));
				d4 = $("<div class='fieldHolder fs_"+self.cleanClass(field["__pFieldOptions"]["name"])+"'></div>")
				if(opts["displayTable"]&&field["__pFieldOptions"]["display"]=="table"){
					d4.addClass("displayTable");
					d3.addClass("displayTable");
				}
				if((q>0||opts["noNest"])&&self.viewState=="edit"){
					d4.append(self.removeParentLink(opts["originalField"] || field,self,fieldFromFields))
				}
				if(isAdminPage&&field["__pFieldOptions"]["multi"]&&self.viewState=="edit"){
					a = $("<a href='javascript:void(0)' class='moveUpButton'></a>");
					a[0].onclick = (function(field){
						return function(){
							$.each(field.parentField.fields,function(i,field2){
								if (field==field2){
									if(i>0){
										field.parentField.fields.splice(i-1, 0, field.parentField.fields.splice(i, 1)[0]);
									}
								}
							})
						}
					})(fieldFromFields)
					d3.append(a)
					a = $("<a href='javascript:void(0)' class='moveDownButton'></a>");
					a[0].onclick = (function(field){
						return function(){
							$.each(field.parentField.fields,function(i,field2){
								if (field==field2){
									if(i<field.parentField.fields.length-1){
										field.parentField.fields.splice(i+1, 0, field.parentField.fields.splice(i, 1)[0]);
									}
								}
							})
						}
					})(fieldFromFields)
					d3.append(a)
				}
				fieldDiv.append(d4.append(d3))
				if(adminTyler){
					d4.append($("<a class='sortLink' href='javascript:void(0)'>Sort</a>"));
				}

			});
		}else{
			d3 = $("<div class='field fieldSetField'></div>")
			$.each(field["fields"],function(i,field){
				d3.append(self.displayField(field,sendOpts))
			});
			d3 = $("<div class='field'></div>").append($("<div class='fieldHolder'></div>").append(d3));
			d4 = $("<div class='fieldHolder fs_"+self.cleanClass(field["__pFieldOptions"]["name"])+"'></div>")
			if(opts["displayTable"]){
				d4.addClass("displayTable");
			}
			fieldDiv.append(d4.append(d3))
			if(field["__pFunctions"]["afterShow"]){
				tempF = new Function("field","form",field["__pFunctions"]["afterShow"]);
				tempF(field["fields"],self);
			}
		}
		if(!opts["noNest"]&&field["__pFieldOptions"]["multi"]&&self.viewState=="edit"){
			thisA = self.addLink(field,self);
			if(!field.hasOwnProperty("theAddLink")){
				Object.defineProperty(field, 'theAddLink',{value:thisA,enumerable:false})
			}
			fieldDiv.append(thisA)
		}
	}else{
		if(field["__pFunctions"]["afterShow"]&&!opts["noNest"]){
			tempF = new Function("field","form",field["__pFunctions"]["afterShow"]);
			tempF(field,self);
		}
	}

	if(field["__pFieldOptions"]["type"] == "heading"){
		fieldHolderDiv.append($("<h2>"+field["__pFieldOptions"]["name"]+"</h2>"));
	}
	
	if(isAssayTable){
		o = assayTable;
	}else{
		if(field["__pFieldOptions"]["type"] == "text"){
			if(self.viewState == "edit"){
				o = $("<input type='text'>");
				if(firstVal != ""){
					o.val(firstVal);
				}
				o[0].getValue = function(){return $(this).val()};
			}
			if(self.viewState == "view"){
				o = $("<span>"+firstVal+"</span>");
			}
		}

		if(field["__pFieldOptions"]["type"] == "date"){
			if(self.viewState == "edit"){
				fieldId = Math.random().toString().replace(".","");
				o = $("<input type='text' id='"+fieldId+"'>");
				if(firstVal != ""){
					o.val(firstVal);
				}
				o[0].getValue = function(){return $(this).val()};
				cals.push((function(fieldId){
					return function(){
						Calendar.setup(
						{
						  inputField  : fieldId,         // ID of the input field
						  ifFormat    : "%m/%d/%Y",    // the date format
						  showsTime   : false,
						  timeFormat  : "12",
						  electric    : false
						}
					  );
					}
				})(fieldId))
			}
			if(self.viewState == "view"){
				o = $("<span>"+firstVal+"</span>");
			}
		}

		if(field["__pFieldOptions"]["type"] == "select"){
			if(self.viewState == "edit"){
				o = $("<select/>");
				o.append($("<option>").text("--SELECT--").attr("selected",true));
				$.each(field["__pFieldOptions"]["options"],function(i,op){
					if($.isArray(op)){
						o.append($("<option>").val(op[0]).text(op[1]))
					}else{
						o.append($("<option>").val(op).text(op))
					}
				});
				if(firstVal){
					o.val(firstVal);
				}
				o[0].getValue = function(){
					v = $(this).val();
					if (v=="--SELECT--"){
						return "";
					}else{
						return v;
					}
				};
			}
			if(self.viewState == "view"){
				o = $("<span>"+firstVal+"</span>");
			}
		}

		if(field["__pFieldOptions"]["type"] == "file"){
			if(self.viewState == "edit"){
				o = $("<iframe/>",{src:"upload_file_frame.asp?fileId="+field["value"],frameBorder:0});

				o[0].getValue = function(){
					return $(this).contents().find('#theFileId').val()};
			}
			if(self.viewState == "view"){
				o = $("<iframe/>",{src:"upload_file_frame.asp?fileId="+field["value"]+"&readOnly=true",frameBorder:0});
			}
		}

		if(field["__pFieldOptions"]["type"] == "textArea"){
			if(self.viewState == "edit"){
				o = $("<textarea/>");
				if(firstVal != ""){
					o.val(firstVal);
				}
				o[0].getValue = function(){return $(this).val()};
			}
			if(self.viewState == "view"){
				o = $("<span>"+firstVal+"</span>")
			}
		}

		if(field["__pFieldOptions"]["type"] == "checkbox"){
			if(self.viewState == "edit"){
				o = $("<input type='checkbox'>");
				if(firstVal != ""){
					o.prop("checked",firstVal);
				}
				o[0].getValue = function(){return $(this).prop("checked")}
			}
			if(self.viewState == "view"){
				o = $("<span>"+firstVal+"</span>")
			}
		}
	}

	if(o){
		if(!field.hasOwnProperty("theO")){
			Object.defineProperty(field, 'theO',{value:o,enumerable:false})
		}
		if(opts["changeFunction"]){
			field.changeFunction = opts["changeFunction"];
		}else{
			if(field["__pFieldOptions"]["multi"]){
				field.changeFunction = (function(field,holderDiv,form){
					return function(){
						vals = [];
						holderDiv.find(".fieldValue").not('.fieldSetField .fieldSetField').each(function(i,el){
							vals.push($($(el).children()[0])[0].getValue())
						});
						field.value = vals;
						if(field["__pFieldOptions"]["type"]=="text" && field["__pFieldOptions"]["multi"]){
							splitBy = "";
							if(field["value"][0].indexOf("\n")!=-1){
								splitBy = "\n";
							}
							if(field["value"][0].indexOf("\t")!=-1){
								splitBy = "\t";
							}
							if(splitBy){
								arr = field.value[0].split(splitBy);
								field.value[0] = arr[0].replace(/^\s+|\s+$/g, '');
								field.theO.val(field.value[0]);
								$.each(arr,function(i,item){
									if(i!=0){
										sendOpts = {}
										sendOpts["noNest"] = true;
										sendOpts["changeFunction"] = field.changeFunction
										baseField = $.extend(true,{},field);
										baseField["value"] = arr[i].replace(/^\s+|\s+$/g, '');
										baseField.parentField = field.parentField
										attachFieldByName(baseField)
										attachGetValArray(baseField)
										$(form.displayField(baseField,sendOpts)).insertBefore(field.theAddLink);
									}
								});
								vals = [];
								holderDiv.find(".fieldValue").not('.fieldSetField .fieldSetField').each(function(i,el){
									vals.push($($(el).children()[0])[0].getValue())
								});
								field.value = vals;
							}
						}
					}
				})(field,fieldHolderDiv,self)
			}else{
				field.changeFunction = (function(field){
					return function(){
						field.value = this.getValue()

					}
				})(field)
			}

			if(field["__pFunctions"]["afterChange"]){
				field.changeFunction = (function(field,form,o,cf){
						return function(){
							cf.call(o[0]);
							tempF = new Function("field","form",field["__pFunctions"]["afterChange"]);
							tempF(field,form);
						}
					})(field,self,o,field.changeFunction)
			}
		}
		o[0].onchange = field.changeFunction;
		fieldDiv.append($("<div class='fieldValue'></div>").append(o));
	}

	if(field["__pFieldOptions"]["multi"]&&field["__pFieldOptions"]["type"]!="fieldSet"){
		sendOpts = {}
		sendOpts["noNest"] = true;
		sendOpts["changeFunction"] = field.changeFunction;
		$.each(fieldVal,function(i,val){
			if(i != 0){
				fieldCopy = $.extend(true,{},field);
				fieldCopy["value"] = field["value"][i];
				fieldDiv.append(self.displayField(fieldCopy,sendOpts));
			}
		});
	}

	if(field["__pFieldOptions"]["multi"] && opts["noNest"] && field["__pFieldOptions"]["type"]!="fieldSet" &&self.viewState=="edit" ){
		fieldDiv.find(".fieldValue").append(self.removeParentLink(field,self));
	}

	if (field["__pFieldOptions"]["multi"] && !opts["noNest"] && field["__pFieldOptions"]["type"]!="fieldSet" && self.viewState=="edit"){
		thisA = self.addLink(field,self);
		if(!field.hasOwnProperty("theAddLink")){
			Object.defineProperty(field, 'theAddLink',{value:thisA,enumerable:false})
		}
		fieldDiv.append(thisA)
	}

	if (opts["noNest"]){
		return fieldDiv.children();
	}
	if(field["__pFieldOptions"]["type"]!="heading"&&field["__pFieldOptions"]["type"]!="hidden"){
		fieldHolderDiv.append(fieldDiv)
	}else{
		fieldHolderDiv.removeClass("fieldHolder");
	}

	// Appending checkbox label after the checkbox itself - Tyler 6.6.16
	if(field["__pFieldOptions"]["type"]=="checkbox" && self.viewState == "edit"){
		fieldHolderDiv.append(label);
	}

	if(field["__pFieldOptions"]["type"]!="fieldSet"){
		errorDiv = $("<div class='errorDiv'/>");
		fieldHolderDiv.append(errorDiv);
		if(!field.hasOwnProperty("errorDiv")){
			Object.defineProperty(field, 'errorDiv',{value:errorDiv,enumerable:false})
		}
	}
	if(!field.hasOwnProperty('holderDiv')){
		Object.defineProperty(field, 'holderDiv',{value:fieldHolderDiv,enumerable:false})
	}
	return fieldHolderDiv;
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function isInteger(n) {
    var int_regex = /^[0-9]+$/ ;
    return int_regex.test(n);
}

function excelValidate(recordNumber,form){
	errors = []
	$.each(form.fields,function(i,field){
		fieldVal = field["value"];
		dataWidth = parseInt(field["__pExcelOptions"]["dataWidth"]);
		dataHeight = parseInt(field["__pExcelOptions"]["dataHeight"]);
		hasHeaders = field["__pExcelOptions"]["hasHeaders"];
		if (dataWidth == 1 && dataHeight == 1){
			fieldVal = [[fieldVal]]
		}else{
			if (dataWidth == 1){
				fieldVal = [fieldVal];
			}
		}
		iStart = 0;
		if(hasHeaders){
			iStart = 1;
		}
		for(var i=iStart;i<dataHeight;i++){
			for(var j=0;j<dataWidth;j++){
				theVal = fieldVal[j][i];
				//magic
				if(field["__pFieldOptions"].hasOwnProperty("validation")){
					$.each(field["__pFieldOptions"]["validation"],function(ww,vItem){
						if(vItem == "isNumber"){
							errorText = "Field must contain only numeric data";
							if(!isNumber(theVal)&&theVal!=""){
								errors.push(makeError(field,recordNumber,i,j,theVal,errorText))
							}
						}
						if(vItem == "isInteger"){
							errorText = "Field must be an integer";
							if(!isInteger(theVal)&&theVal!=""){
								errors.push(makeError(field,recordNumber,i,j,theVal,errorText))
							}
						}
						if(vItem == "isDate"){
							errorText = "Field must contain a date";
							if(!isDate(theVal)&&theVal!=""){
								errors.push(makeError(field,recordNumber,i,j,theVal,errorText))
							}
						}
					})
				}
				if(field["__pFieldOptions"]["required"]){
					errorText = "Field is required";
					if(theVal==""){
						errors.push(makeError(field,recordNumber,i,j,theVal,errorText))
					}
				}
				if(field["__pFieldOptions"]["type"]=="select"){
					errorText = "Field does not contain a valid option ("+field["__pFieldOptions"]["options"].join(",")+")";
					if(field["__pFieldOptions"]["options"].indexOf(theVal)==-1){
						errors.push(makeError(field,recordNumber,i,j,theVal,errorText))
					}
				}
			}
		}
	});
	return errors;
}

function isDate(testdate) {
    var date_regex = /^(0[1-9]|1[0-2])\/(0[1-9]|1\d|2\d|3[01])\/(19|20)*\d{2}$/ ;
    return date_regex.test(testdate);
}

function colName(n) {
	n -= 1
	var ordA = 'a'.charCodeAt(0);
	var ordZ = 'z'.charCodeAt(0);
	var len = ordZ - ordA + 1;
  
	var s = "";
	while(n >= 0) {
		s = String.fromCharCode(n % len + ordA) + s;
		n = Math.floor(n / len) - 1;
	}
	return s.toUpperCase();
}
function makeError(theField,recordNumber,i,j,theVal,errorText){
	errorStr = "";
	leftOffset = parseInt(theField["__pExcelOptions"]["leftOffset"]);
	topOffset = parseInt(theField["__pExcelOptions"]["topOffset"]);
	leftOffsetOffset = parseInt(theField["__pExcelOptions"]["repeatWidth"]);
	topOffsetOffset = parseInt(theField["__pExcelOptions"]["repeatHeight"]);
    leftOffset = leftOffset+(leftOffsetOffset*(recordNumber))
    topOffset = topOffset+(topOffsetOffset*(recordNumber))

	hasHeaders = theField["__pExcelOptions"]["hasHeaders"];
	if(hasHeaders){
		i -= 1;
	}

	fieldName = theField["__pFieldOptions"]["name"];
	errorStr += "<strong>Record:</strong> "+(recordNumber+1)+","
	errorStr += " <strong>Field:</strong> "+fieldName+","
	errorStr += " <strong>Cell:</strong> "+colName(leftOffset+j)+":"+(topOffset+i)+","
	errorStr += " <strong>Value:</strong> "+theVal+","
	errorStr += " <strong>Error:</strong> "+errorText
	return errorStr;
}

Form.prototype.validate = function(){
	var self = this;
	isError = false;
	function validateInner(object,propertyName){
		propertyName = propertyName || "";
	    for (var property in object) {
	        if (object.hasOwnProperty(property)) {
	            if (typeof object[property] == "object"){
	            	if(property!='_links'){
	                	validateInner(object[property],property);
	                }
	            }
	        }
	    }
		if(propertyName.substring(0,2)!="__" && object.constructor.name == "Object"){
			errors = [];
			if(object["__pFieldOptions"].hasOwnProperty("validation")){
				$.each(object["__pFieldOptions"]["validation"],function(i,vItem){
					if(vItem == "isNumber"){
						thisIsError = false;
						errorText = "Field must contain only numeric data";
						if(object["__pFieldOptions"]["multi"]){
							$.each(object["value"],function(j,val){
								if(!isNumber(val)&&val){
									thisIsError = true;
									isError = true;
								}
							});
						}else{
							if(!isNumber(object["value"])&&object["value"]){
								thisIsError = true;
								isError = true;
							}
						}
						if(thisIsError){
							errors.push(errorText)
						}
					}
					if(vItem == "isInteger"){
						thisIsError = false;
						errorText = "Field must be an integer";
						if(object["__pFieldOptions"]["multi"]){
							$.each(object["value"],function(j,val){
								if(!isInteger(val)&&val){
									thisIsError = true;
									isError = true;
								}
							});
						}else{
							if(!isInteger(object["value"])&&object["value"]){
								thisIsError = true;
								isError = true;
							}
						}
						if(thisIsError){
							errors.push(errorText)
						}
					}
					if(vItem == "isDate"){
						thisIsError = false;
						errorText = "Field must contain a date";
						if(object["__pFieldOptions"]["multi"]){
							$.each(object["value"],function(j,val){
								if(!isDate(val)&&val){
									thisIsError = true;
									isError = true;
								}
							});
						}else{
							if(!isDate(object["value"])&&object["value"]){
								thisIsError = true;
								isError = true;
							}
						}
						if(thisIsError){
							errors.push(errorText)
						}
					}
					if(vItem == "isGreaterThan5"){
						thisIsError = false;
						errorText = "Field must be greater than 5";
						if(object["__pFieldOptions"]["multi"]){
							$.each(object["value"],function(j,val){
								if(isNumber(val)){
									if(val<=5){
										thisIsError = true;	
										isError = true;
									}
								}
							});
						}else{
							if(isNumber(object["value"])){
								if(object["value"]<=5){
									thisIsError = true;
									isError = true;
								}
							}
						}
						if(thisIsError){
							errors.push(errorText)
						}
					}
				});
			}
			if(object["__pFieldOptions"]["required"]){
				errorText = "Field is required";
				if(object.hasOwnProperty("value")){
					v = object["value"];
					if(v=="" || v==[] || v==[""]){
						errors.push(errorText)
						isError = true;
					}
				}else{
					errors.push(errorText)
					isError = true;
				}
			}
			if(errors.length){
				object.errorDiv.html(errors.join("<br>"))
			}else{
				try{
					object.errorDiv.html("");
				}catch(err){}
			}
		}
	}
	validateInner(self.fd);
	if(isError){
		return false;
	}else{
		return true;
	}
}

Form.prototype.clearValues = function(object){
	var self = this;
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
                self.clearValues(object[property]);
            }else{
                if(property == "value" || object.hasOwnProperty("value")){
					object["value"] = "";
                }
            }
        }
    }
}

Form.prototype.cleanFieldSets = function(object){
	//the purpose of this was to separate fields when field sets were being added from the same javascript object
	//e.g.
	//fields3 = [
	//	{"type":"text",name:"3 different text field",value:["se1"]},
	//	{"type":"fieldSet",name:"set of fields as a field","fields":fields2},
	//	{"type":"fieldSet",name:"set of fields as a field","fields":fields2}
	//]
	//probably not needed in practice??
	var self = this;
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object"){
                self.cleanFieldSets(object[property]);
            }else{
                if(object.hasOwnProperty("__pFieldOptions")){
					if(object["__pFieldOptions"]["type"] == "fieldSet"){
						object["fields"] = $.extend(true,[],object["fields"])
					}
                }
            }
        }
    }
}

Form.prototype.cleanClass = function(theClass){
	var self = this;
	return theClass.replace(/[^A-Za-z0-9]/ig,"_")
}

Form.prototype.removeDunder = function(){
	var self = this;
	removeDunder(self.fd);
}

Form.prototype.removeParentLink = function(field,form,arrayElement){
	a = $('<a href="javascript:void(0)" class="removeParentLink"><div class="removeButtonContainer"><img style="vertical-align:middle;padding:2px;" src="images/removeButton.png" width="22" height="22"><div class="removeButtonText">Remove</div></div></a>');
	a[0].onclick = (function(field,form,arrayElement){
		return function(){
			if (field["__pFieldOptions"]["type"] == "fieldSet"){
				$.each(field["fields"],function(i,a){
					if (a==arrayElement){
						field["fields"].splice(i,1);
					}
				});
			}
			el = this;
			$(el).parent().remove();
			if(field.changeFunction){
				field.changeFunction()
			}
		}
	})(field,form,arrayElement)
	return a;
}

Form.prototype.addField = function(form,fieldSet,fieldToAdd,insertBeforeName){
	console.log(form);
	console.log(fieldSet);
	console.log(fieldToAdd);
	console.log(insertBeforeName);
	//this came to me in a dream
	getDunder(fieldToAdd);
	sendOpts = {}
	if(insertBeforeName){
		el = fieldSet.getFieldByName(insertBeforeName).holderDiv;
		insertBefore = true;
	}else{
		insertBefore = false;
		el = fieldSet.getFieldByName(fieldSet.getFieldNames()[fieldSet.getFieldNames().length-1]).holderDiv;
	}
	if(fieldToAdd["__pFieldOptions"]["type"]=="fieldSet"){
		baseField = $.extend(true,{},fieldToAdd);
		baseField["fields"] = [baseField["fields"][0]]
	}else{
		baseField = $.extend(true,{},fieldToAdd);
	}
	getDunder(baseField);
	removeParentField(baseField)
	form.clearValues(baseField)
	if(fieldSet.fields){
		fieldSet.fields.push(baseField)
	}else{
		fieldSet.push(baseField)
	}
	if(fieldSet.parentField){
		attachParentField(fieldSet.parentField)	
	}else{
		attachParentField(fieldSet)	
	}
	attachFieldByName(fieldSet)

	attachGetValArray(baseField)
	if(insertBefore){
		$(form.displayField(baseField,sendOpts)).insertBefore($(el));
	}else{
		$(form.displayField(baseField,sendOpts)).insertAfter($(el));
	}
}

Form.prototype.addLink = function(field,form){
	a = $('<a href="javascript:void(0)"><div class="addButtonContainer"><img src="images/addButton.png" width="22" height="22"><div class="addButtonText">Add</div></div></a>');
	a.addClass("addLink")
	a[0].onclick = (function(field,form){
		return function(){
			sendOpts = {}
			sendOpts["noNest"] = true;
			sendOpts["changeFunction"] = field.changeFunction;
			el = this;
			if(field["__pFieldOptions"]["type"]=="fieldSet"){
				sendOpts["originalField"] = field;
				baseField = $.extend(true,{},field);
				form.clearValues(baseField)
				baseField["fields"] = [baseField["fields"][0]]
				for (var i=0;i<baseField["fields"][0].length;i++){
					if(baseField["fields"][0][i].hasOwnProperty("fields")){
						baseField["fields"][0][i]["fields"] = [baseField["fields"][0][i]["fields"][0]]
					}
				}
				field["fields"].push(baseField["fields"][0])
				attachParentField(field)
			}else{
				baseField = $.extend(true,{},field);
				baseField["value"] = "";
				baseField.parentField = field.parentField
			}
			attachFieldByName(baseField)
			attachGetValArray(baseField)
			$(form.displayField(baseField,sendOpts)).insertBefore($(el));
			if(field.changeFunction){
				field.changeFunction()
			}
			if(field.changeFunction){
				field.changeFunction()
			}
			if(field["__pFunctions"]["afterShow"]){
				tempF = new Function("field","form",field["__pFunctions"]["afterShow"]);
				tempF(field,form);
			}
		}
	})(field,form)
	return a;
}

Form.prototype.requireArray = function(theVal){
	var self = this;
	if($.isArray(theVal)){
		return theVal;
	}else{
		if(typeof theVal === "string"){
			return [theVal];
		}else{
			return [];
		}
	}
}



cache = {};

function getCache(theId){
	theId = parseInt(theId);
	if(cache.hasOwnProperty(theId)){
		return JSON.parse(JSON.stringify(cache[theId]));
	}else{
		form = restCall("/loadForm/","POST",{"id":theId})["form"]
		cache[theId] = form;
		return form;
	}
}

function selectOfType(typeIds){
	if(!$.isArray(typeIds)){
		typeIds = [typeIds];
	}
	$.each(typeIds,function(i,typeId){
		typeIds[i] = parseInt(typeIds[i]);
	})
	ops = restCall("/selectOfType/","POST",{"typeIds":typeIds})["ops"]
	return ops;
}


function ifValShowSibling(field,value,fieldName){
	if(field.parentField.getFieldByName(fieldName)){
		if(field['value']==value){
			field.parentField.getFieldByName(fieldName).show()
		}else{
			field.parentField.getFieldByName(fieldName).hide()
		}
	}
}

function ifValRequireSibling(field,values,fieldName){
	if(!$.isArray(values)){
		values = [values]
	}
	for(var i=0;i<values.length;i++){
		values[i] = values[i].toLowerCase();
	}
	if(field.parentField.getFieldByName(fieldName)){
		f1 = field.parentField.getFieldByName(fieldName)
		foundOne = false;
		$.each(values,function(i,value){
			if($.isArray(field["value"])){
				$.each(field['value'],function(j,value2){
					if(value2.toLowerCase()==value){
						f1["__pFieldOptions"]["required"] = true;
						f1.labelDiv.html(f1["__pFieldOptions"]["name"]+"*")
						foundOne = true;
					}				
				})
			}else{
				if(field['value'].toLowerCase()==value){
					f1["__pFieldOptions"]["required"] = true;
					f1.labelDiv.html(f1["__pFieldOptions"]["name"]+"*")
					foundOne = true;
				}
			}
		});
		if(!foundOne){
			f1["__pFieldOptions"]["required"] = false;
			f1.labelDiv.html(f1["__pFieldOptions"]["name"])
		}
	}
}

function ifValShowAndRequireSibling(field,values,fieldName){
	if(!$.isArray(values)){
		values = [values]
	}
	for(var i=0;i<values.length;i++){
		values[i] = values[i].toLowerCase();
	}
	if(field.parentField.getFieldByName(fieldName)){
		f1 = field.parentField.getFieldByName(fieldName)
		foundOne = false;
		$.each(values,function(i,value){
			if(field['value'].toLowerCase()==value){
				f1["__pFieldOptions"]["required"] = true;
				f1.labelDiv.html(f1["__pFieldOptions"]["name"]+"*")
				foundOne = true;
				f1.show();
			}
		});
		if(!foundOne){
			f1["__pFieldOptions"]["required"] = false;
			f1.labelDiv.html(f1["__pFieldOptions"]["name"])
			f1.hide();
			if($.isArray(f1["value"])){
				f1["value"] = [""];
			}else{
				f1["value"] = "";
			}
		}
	}
}

function hideSiblingsExcept(field,exceptFields){
	if(!exceptFields){
		exceptFields = [];
	}
	for (var i=0;i<exceptFields.length;i++){
		exceptFields[i] = exceptFields[i].toLowerCase();
	}
	fieldNames = field.parentField.getFieldNames();
	$.each(fieldNames,function(i,fieldName){
		if(exceptFields.indexOf(fieldName.toLowerCase())==-1&&fieldName.toLowerCase()!=field["__pFieldOptions"]["name"].toLowerCase()){
			f1 = field.parentField.getFieldByName(fieldName)
			if(f1["__pFieldOptions"]["type"]!="heading"){
				f1["__pFieldOptions"]["required"] = false;
				f1.labelDiv.html(f1["__pFieldOptions"]["name"]);
				f1.hide();
				f1["value"] = "";
			}
		}
	})
}

function hideSiblingsAfter(field){
	foundIt = false;
	$.each(field.parentField,function(i,field2){
		if (foundIt){
			field2["__pFieldOptions"]["required"] = false;
			field2.labelDiv.html(field2["__pFieldOptions"]["name"]);
			field2.hide();
			if($.isArray(field2["value"])){
				field2["value"] = [""];
			}else{
				field2["value"] = "";
			}
			try{
				field2.theO.val("");
			}catch(err){}

		}
		if (field==field2){
			foundIt = true;
		}
	})
}

function clearSiblingsExcept(field,exceptFields){
	if(!exceptFields){
		exceptFields = [];
	}
	for (var i=0;i<exceptFields.length;i++){
		exceptFields[i] = exceptFields[i].toLowerCase();
	}
	fieldNames = field.parentField.getFieldNames();
	$.each(fieldNames,function(i,fieldName){
		if(exceptFields.indexOf(fieldName.toLowerCase())==-1&&fieldName.toLowerCase()!=field["__pFieldOptions"]["name"].toLowerCase()){
			f1 = field.parentField.getFieldByName(fieldName)
			if(f1["__pFieldOptions"]["type"]!="heading"){
				f1["value"] = "";
			}
		}
	})
}

function ifNotValShowSibling(field,value,fieldName){
	if(field.parentField.getFieldByName(fieldName)){
		if(field['value']!=value){
			field.parentField.getFieldByName(fieldName).show()
		}else{
			field.parentField.getFieldByName(fieldName).hide()
		}
	}
}

function zip(a,b){
	var c = []
	for(var i=0;i<a.length;i++){
		c.push([a[i],b[i]]);
	}
	return c;
}

function uniqueArray(list) {
  var result = [];
  $.each(list, function(i, e) {
    if ($.inArray(e, result) == -1) result.push(e);
  });
  return result;
}

function htmlEncode(value){
  return $('<div/>').text(value).html();
}

function makeTableWithinThisTable(currentScope){
	var tableHeaderArray = [];
	// First find all the th's we're going to put in the table
	$(currentScope).children('.fieldHolder:not([style="display: none;"])').find('.fieldSetField:nth-of-type(1)').each(function(){
		$(this).children('.fieldHolder').each(function(){
			var thText = $(this).children('div.label').text();
			tableHeaderArray.push(thText);
		});
	});
	tableHeaderArray = uniqueArray(tableHeaderArray);
	
	// Now build the thead with all the th's
	var tableHeaderHTML = '<table class="tableViewTable"><thead><th class="actionDotsHeader"></th>';
	$(tableHeaderArray).each(function(index,headerText){
		tableHeaderHTML += "<th>" + headerText + "</th>"
	});
	tableHeaderHTML += "</thead>";
 
	// Now go through each set/row
	var tableBodyHTML = "<tbody>";
	$(currentScope).children('.fieldHolder:not([style="display: none;"])').children('.field').children('.fieldHolder').children('.fieldSetField').each(function(){
		var thisRowHTML = '<tr><td class="actionDotsCell"><div class="actionDots"><div class="actionDotsPopup"><div class="actionDotsPopupArrow"></div><div class="actionDotsPopupContent"><div class="actionDotsPopup_sortButton">Sort</div><div class="actionDotsPopup_removeFieldButton">Remove Field</div></div></div></div></td>';
		var fieldSetField = $(this);
		fieldSetField.children('.fieldHolder').each(function(){
			var thText = $(this).children('.label').text();
		});

		// Go through each cell and if it's found in the HTML, make a td out of it - otherwise, "---"
		$(tableHeaderArray).each(function(key, headerText){
			var cellValue = false;
			fieldSetField.children('.fieldHolder').each(function(){
				var thText = $(this).children('.label').text();
				if(thText == headerText){
					var valueLine = 1;
					cellValue = "";
					$(this).children('.field').children('.fieldValue').each(function(){
						if($(this).children('input[type="text"]').length){
							cellValue += '<div class="doNotWrap">' + $(this).children('input[type="text"]').val() + '</div>';
						}
						else if($(this).children('textarea').length){
							cellValue += $(this).children('textarea').val();
							cellValue += "<br />";
						}
						else if($(this).children('select').length){
							var selectedOption = $(this).children('select').children('option:selected').val();
							if(selectedOption !== "--SELECT--"){	
								cellValue += '<div class="doNotWrap">' + selectedOption + '</div>';
							}
						}
						else{
							cellValue += htmlEncode($(this).text());
							cellValue += "<br />";
						}





						/*
						if(valueLine > 1){ 
							cellValue += "\n" ;
						}
						*/
						valueLine++;
					})
				}
			});
			if(cellValue === false){
				thisRowHTML += '<td class="fieldNotFound">' + "---" + '</td>';
			}
			else{
				thisRowHTML += '<td>' + cellValue + '</td>';
			}
		});

		thisRowHTML += "</tr>";
		tableBodyHTML += thisRowHTML;

		if($(this).children('.fieldHolder.fieldSetHolder').length){
			tableBodyHTML += '<tr><td class="innerTableContainerCell" colspan="' + (tableHeaderArray.length + 1) + '">';
			$(this).children('.fieldHolder.fieldSetHolder').each(function(){
				// Going to take the form view in the DOM, add a unique random identifier to it, and run this function again using the identifier as the function's scope. This is what gets field sets beyond the top level ones.
				var uniqueScopeId = "tableViewScopeId_" + Math.round( (Math.random() * 50000) );
				$(this).attr('tableviewscopeid',uniqueScopeId);
				tableBodyHTML += makeTableWithinThisTable('.fieldSetHolder[tableviewscopeid="' + uniqueScopeId + '"] > .field')
			});
			tableBodyHTML += "</td></tr>";
		}
	});
	tableBodyHTML += "</tbody></table>";

	tableHTML = tableHeaderHTML + tableBodyHTML;
	return tableHTML;
}

$('document').ready(function(){
	$('body').on( "click", ".fieldHolder.fieldSetHolder", function(e) {
		// Detect click on Expand/Collapse Button in Form View
		var buttonTopPixel = $(this).offset().top + 29; //add "top: 31px" minus border
		var buttonBottomPixel = buttonTopPixel + 35; //add button's height
		var buttonLeftPixel = $(this).offset().left - 16; //add "left: -16px";
		var buttonRightPixel = buttonLeftPixel + 31; //add button's width
		var whereYouClickedVertically = e.pageY;
		var whereYouClickedHorizontally = e.pageX;
		var clickWasVerticallyWithinTheButton = whereYouClickedVertically >= buttonTopPixel && whereYouClickedVertically <= buttonBottomPixel;
		var clickWasHorizontallyWithinTheButton = whereYouClickedHorizontally >= buttonLeftPixel && whereYouClickedHorizontally <= buttonRightPixel;

		if(clickWasVerticallyWithinTheButton && clickWasHorizontallyWithinTheButton){
			if($(this).hasClass('collapsed')){
				$(this).removeClass('collapsed')
			}
			else{
				$(this).addClass('collapsed');
			}
		}

		e.stopPropagation();
	});

	$('body').on( "click", ".tableViewTable tbody tr td.innerTableContainerCell", function(e) {
		// Detect Click on Expand/Collapse Button in Table View
		var buttonTopPixel = $(this).offset().top + 21; //add "top: 21px"
		var buttonBottomPixel = buttonTopPixel + 33; //add button's height
		var buttonLeftPixel = $(this).offset().left + 28; //add "left: "
		var buttonRightPixel = buttonLeftPixel + 140; //add button's width
		var whereYouClickedVertically = e.pageY;
		var whereYouClickedHorizontally = e.pageX;

		var clickWasVerticallyWithinTheButton = whereYouClickedVertically >= buttonTopPixel && whereYouClickedVertically <= buttonBottomPixel;
		var clickWasHorizontallyWithinTheButton = whereYouClickedHorizontally >= buttonLeftPixel && whereYouClickedHorizontally <= buttonRightPixel;
		
		if(clickWasVerticallyWithinTheButton && clickWasHorizontallyWithinTheButton){
			if($(this).hasClass('collapsed')){
				$(this).removeClass('collapsed')
			}
			else{
				$(this).addClass('collapsed');
			}
		}

		// Detect Click on "Remove This Field" Button in Table View
		var buttonTopPixel = $(this).offset().top + 21; //add "top: 21px"
		var buttonBottomPixel = buttonTopPixel + 33; //add button's height
		var buttonLeftPixel = $(this).offset().left + 188; //add "left: "
		var buttonRightPixel = buttonLeftPixel + 148; //add button's width
		var whereYouClickedVertically = e.pageY;
		var whereYouClickedHorizontally = e.pageX;

		var clickWasVerticallyWithinTheButton = whereYouClickedVertically >= buttonTopPixel && whereYouClickedVertically <= buttonBottomPixel;
		var clickWasHorizontallyWithinTheButton = whereYouClickedHorizontally >= buttonLeftPixel && whereYouClickedHorizontally <= buttonRightPixel;

		if(clickWasVerticallyWithinTheButton && clickWasHorizontallyWithinTheButton){
			if($(this).hasClass('collapsed')){
				$(this).removeClass('collapsed');
			}
			else{
				$(this).addClass('collapsed');
			}
		}

		e.stopPropagation();
	});

	function getTextFromFieldValue(fieldValueElement){
		var textFromFieldValueElement = "";
		if(fieldValueElement.children('input[type="text"]').length){
			textFromFieldValueElement += fieldValueElement.children('input[type="text"]').val();
		}
		else if(fieldValueElement.children('textarea').length){
			textFromFieldValueElement += fieldValueElement.children('textarea').val();
			textFromFieldValueElement += "<br />";
		}
		else if(fieldValueElement.children('select').length){
			var selectedOption = fieldValueElement.children('select').children('option:selected').val();
			if(selectedOption !== "--SELECT--"){	
				textFromFieldValueElement += selectedOption;
			}
		}
		else{
			textFromFieldValueElement += htmlEncode(fieldValueElement.text());
			textFromFieldValueElement += "<br />";
		}
		return textFromFieldValueElement;
	}

	function makeSortPopupItems(currentScope){
		var sortPopupItemsHTML = "";
		sortPopupItemsHTML += '<ol class="dd-list">';
		currentScope.children('.fieldHolder:not([style="display: none;"])').children('.field').children('.fieldHolder').children('.fieldSetField').each(function(){
			$(this).children('.fieldHolder').each(function(index, value){
				var uniqueId = Math.round( (Math.random() * 50000) );

				if(index == 0){
					$(this).parent().parent().parent().parent().attr('uniqueid',uniqueId);
					var listItemDisplayName = getTextFromFieldValue($(this).children('.field').children('.fieldValue'));
					sortPopupItemsHTML += '<li class="dd-item" data-uniqueid="' + uniqueId + '"><div class="dd-handle dd-nodrag">' + listItemDisplayName + '</div></li>';
				}
			});
		});
		sortPopupItemsHTML += '</ol>';

		return sortPopupItemsHTML;
	}

	$('body').on('click', '.fieldHolder > .sortLink', function(){
		var thisScope = $(this).parent().parent();
		var sortPopupItemsHTML = '<div id="sortPopupList">' + makeSortPopupItems(thisScope) + '</div>';
		$('.popupWindow > .popupWindowContent > .dd').html(sortPopupItemsHTML);
		var thisFieldHolderUniqueId = $(this).parent().attr('uniqueid');
		console.log(thisFieldHolderUniqueId);
		$('.popupWindow > .popupWindowContent > .dd .dd-item[data-uniqueid=' + thisFieldHolderUniqueId + '] > .dd-handle').removeClass('dd-nodrag');
		$('.popupWindow').addClass('popupWindowShow');
		$('body').css('overflow-y','hidden');
		$(".dd-nodrag").on("mousedown", function(event) {
			event.preventDefault();
			return false;
		});
		
		$('.dd').nestable({
			maxDepth: 1,
			noDragClass: "dd-nodrag"
		});
	});

	$('.popupWindowBackdrop').click(function(){
		$('.popupWindow').removeClass('popupWindowShow');
		$('body').css('overflow-y','');
	})

	$(window).scroll(function(){
		var greatestValidTopOfTable = 0;
		var chosenTable = "";
		var scrollFromTop = $(window).scrollTop();
		var numberOfParentTables = 0;

		$('.tableViewTable').each(function(){
			// Grab the lowest one that's above the bottom position of the screen and still off the top of the screen
			var topOfTable = $(this).offset().top;
			var bottomOfTable = $(this).offset().top + $(this).outerHeight();
			
			if( (scrollFromTop >= topOfTable) && (scrollFromTop < bottomOfTable) && (topOfTable >= greatestValidTopOfTable) && !$(this).parent().hasClass('collapsed') ){
				chosenTable = $(this);
			}
		});
		if(chosenTable !== ""){
			var chosenTableHasChanged = false;
			numberOfParentTables = $(chosenTable).parents('table.tableViewTable').length;

			if(typeof window.latestChosenTableForFloatingHeader !== 'undefined'){
				chosenTableHasChanged = window.latestChosenTableForFloatingHeader[0] !== chosenTable[0];
			}

			if(typeof window.latestChosenTableForFloatingHeader == 'undefined' || chosenTableHasChanged){
				window.latestChosenTableForFloatingHeader = chosenTable;
				var floatingHeaderHTML = '<div class="fixedTableHeader">';
				chosenTable.children('thead').children('tr').children('th').each(function(thCount){
					if(thCount == 0){
						floatingHeaderHTML += '<div style="width:' + $(this).outerWidth() + 'px;" class="actionDotsHeaderFloating">&nbsp;</div>';
					}
					else{
						floatingHeaderHTML += '<div style="width:' + $(this).outerWidth() + 'px;">' + $(this).text() + '</div>';
					}
				});
				floatingHeaderHTML += '</div>';
				
				$('.fixedTableHeader').remove();
				$('div#tableView > table.tableViewTable').before(floatingHeaderHTML);
			}
			else{
				$('.fixedTableHeader').css('top', scrollFromTop + 'px').css('left', (numberOfParentTables * 43));
			}
		}
	});

	$('body').on('click', '.runTableViewFunction', function(event){
		$('#tableView').html(makeTableWithinThisTable('#test3 > .fieldSetHolder > .field'));
	});

	$('body').on('click', '.actionDots', function(event) {
    	$(this).find('.actionDotsPopup').addClass('showPopup');
    	$('#tableViewActionDotsCloseBackdrop').addClass('showBackdrop')
	});

	$('body').on('click', '#tableViewActionDotsCloseBackdrop', function(event) {
    	$('.actionDotsPopup').removeClass('showPopup');
    	$('#tableViewActionDotsCloseBackdrop').removeClass('showBackdrop');
    });
});
