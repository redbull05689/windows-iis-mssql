isAdminPage = false;

function parseSelectList(theId){
	//create an array of the form [[value,text],[value,text]...] for creating drop down lists
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

//invPerm
function drawPerms(theField){
	div = document.createElement("div");
	div.className = "permView"
	if (theField.value!=""){
		if(theField.value.hasOwnProperty("groupNames")){
			if(theField.value.groupNames.length>0){
				h3 = document.createElement("h3");
				h3.innerHTML = "Groups";
				div.appendChild(h3);
				ul = document.createElement("ul");
				for(var i=0;i<theField.value.groupNames.length;i++){
					li = document.createElement("li");
					li.innerHTML = theField.value.groupNames[i];
					ul.appendChild(li);
				}
				div.appendChild(ul);
			}
		}
		if(theField.value.hasOwnProperty("userNames")){
			if(theField.value.userNames.length>0){
				h3 = document.createElement("h3");
				h3.innerHTML = "Users";
				div.appendChild(h3);
				ul = document.createElement("ul");
				for(var i=0;i<theField.value.userNames.length;i++){
					li = document.createElement("li");
					li.innerHTML = theField.value.userNames[i];
					ul.appendChild(li);
				}
				div.appendChild(ul);
			}
		}
	}
	return div
}

function createPermissions(theForm,theField,view){
	el = document.createElement("div");
	if(!view){
		a = document.createElement("a");
		a.innerHTML = "Edit";
		a.setAttribute("href","javascript:void(0);");
		a.onclick = function(){
				blackOn();
				popup = newPopup("permPopup");
               popup.setAttribute("style","width:400px;height:500px;")
				label = document.createElement("label");
				label.innerHTML = "Users";
				popup.appendChild(label);
				div = document.createElement("div");
				popup.appendChild(div);
				$.get("../_inclds/common/html/groupListStandAlone.asp",(function (div,theField){ 
					return function (data){
					$(div).html(data);
					populatePerms(theField.value)
				}})(div,theField)
				);
				
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(theField){
					return function(){
						theField.value = getPermValue(theField);
						theField.theO.children('.permView').replaceWith(drawPerms(theField));
						el = document.getElementById("permPopup");
						el.parentNode.removeChild(el);
						blackOff();
					}
				})(theField);
				button.setAttribute("value","OK");
				popup.appendChild(button);

				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);

		};
		el.appendChild(a);
		el.appendChild(document.createElement("br"))
	}
	el.appendChild(drawPerms(theField));
	return el;
}
//end invPerm

function attachFieldByName(object){
	//attaches getFieldByName function to field objects and getFieldNames to form/fieldSet

	//recursively iterate through all nested objects
	for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
            	if(property!='_links'){
                	attachFieldByName(object[property]);
                }
            }
        }
    }

	//add function for objects that have fields
	if(object.hasOwnProperty("fields")){
		if(!object["__pFieldOptions"]["multi"]){
			//if the field is not multi i.e. not a multi fieldSet
			//attach a function that iterates through each field in the objects field array
			//and return field that matches the name provided
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
			//attacgh function that returns an array of the names of each field
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
			//is a multi fieldSet

			//in this case we need to go one level deeper.  the structure looks like this {someField...,fields[[{field1},{field2},{field3}],[{field1},{field2},{field3}]]}
			//loop through outside array of multi fieldSet and attach a function to return the matching field for each fieldSet of the multi fieldSet
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

			//loop through outside array of multi fieldSet and attach a function to return an array of the field names for each fieldSet of the multi fieldSet
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
	//reformats value data for a field or fieldset
	//for a field returns {"fieldName":"value"}
	//for a fieldSet returns {"fieldSetName.fieldName":"value"}
	//for a multi fieldSet returns {"fieldSetName.fieldName1":[val1,val2,val3....],"fieldSetName.fieldName2":[val1,val2,val3....]}

	//iterate through nested objects
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
            	if(property!='_links'){
                	attachGetValArray(object[property]);
                }
            }
        }
    }

	//only for fields (items with __pFieldOptions)
	if(object.hasOwnProperty("__pFieldOptions")){
		if(object["__pFieldOptions"]["type"]=="fieldSet"){
			object.getValArray = (function(ob){
					return function(){
						if (ob["__pFieldOptions"]["multi"]){
							r = {};
							//loop through each fieldSet in a multi fieldSet if our field name (fieldSetName.fieldName) does not yet exist, add it
							//then push values onto field names for each fieldSet
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
							//add value by appropriate name for each field in the fieldset
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
			//return {fieldName:value}
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
	//attaches parent field to field and fieldSet objects

	//recursively iterate through objects
	for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
            	if(property!='_links'){
                	attachParentField(object[property]);
                }
            }
        }
    }

	//if the object has a fields attribute (is a fieldSet) add self as the parent object of field fieldSet's children
	if(object.hasOwnProperty("fields")&&!object[property].parentField){
		if(!object["__pFieldOptions"]["multi"]){
			//if not multi loop through all of the fields and add a parentField property set equal to the parent object
			$.each(object.fields,function(i,field){
				if(!field.hasOwnProperty("parentField")){
					Object.defineProperty(field, 'parentField',{value:object,enumerable:false})
				}
			});
		}else{
			//if is multi do double loop, loop through all of the fields and add a parentField property set equal to the parent object
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
	//remove parentField Property from all fields and fieldsets

	//recursively iterate through all objects
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
                removeParentField(object[property]);
            }
        }
    }

	//delete parentField property if it exists
	if(object.hasOwnProperty("parentField")){
		delete object["parentField"];
	}
}

function removeDunder(object){
	//remove dunder objects from all fields recursively

	//recursively iterate through all objects
	for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
            	if(property.substring(0,2)!="__"){
					//if we are not on a dunder object continue to next object
            		removeDunder(object[property]);	
            	}else{
					//if we are on a dunder object, delete ourselves
            		delete object[property];
            	}
                
            }
        }
    }
}

function setDefaultValues(object,propertyName){
	//set system default values for all fields in a form object

	//recursively iterate through all objects
	propertyName = propertyName || "";
	for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
            	if(property!='_links'){
                	setDefaultValues(object[property],property);
                }
            }
        }
    }

	//make sure we are really in an actual field, not a fieldSet or a dunder object, or a date object etc...
	if(!object.hasOwnProperty("fields") && !object.hasOwnProperty("value")&& propertyName.substring(0,2)!="__"  && object.constructor.name == "Object" && propertyName != "userUpdated" && propertyName != "userAdded"){
		//default value will be an empty string for all fields
		var theVal = "";
		//except for checkboxes default value for checkboxes will be false
		if(object["__pFieldOptions"]["type"]=="checkbox"){
			theVal = false;
		}
		if(!object["__pFieldOptions"]["multi"]){
			//if we are not a multi field and our value is undefined replace with default value
			object["value"] = object["value"] || theVal;
		}else{
			//if we are a multi field and our value is undefined replace with default value as 0th item in an array
			object["value"] = object["value"] || [theVal];
		}
	}
}

function fixSort(form){
	//create an object called _sort at the root of the form
	//{form....
	// _sort:{"fieldName":"fieldVal","fieldName2","fieldVal2"}
	//the purpose of this is to make a sort of view that is easier to sort than the more complicated queries of drilling down into the actual fields would be
	//key names have spaces replaced with _ and are lower cased
	var b = {}
	$.each(form.fields,function(i,field){
		if(field["__pFieldOptions"]["type"]!="fieldSet"){
			try{
				b[field["__pFieldOptions"]["name"].toLowerCase().replace(/\s+/ig,"_").replace(/\./ig,"")] = field["value"]
			}catch(err){}
		}
	})
	form._sort = b;
}

function fixNumbers(object){
	//convert field values that should be numbers to actual numbers in the JSON instead of strings of numbers

	//recursively iterate through all objects
	for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
               	fixNumbers(object[property]);
            }
        }
    }

	//in a field
	if(object.hasOwnProperty("value") && object.constructor.name == "Object"){
		if(object.hasOwnProperty("__pFieldOptions")){
			if (object["__pFieldOptions"].hasOwnProperty("validation")){
				if (object["__pFieldOptions"]["validation"].indexOf("isNumber")!=-1 || object["__pFieldOptions"]["validation"].indexOf("isInteger")!=-1){
					//in a field that should be a number

					if($.isArray(object["value"])){
						if($.isArray(object["value"][0])){
							for(var i=0;i<object["value"].length;i++){
								for(var j=0;j<object["value"][i].length;j++){
									if(object.hasOwnProperty("__pExcelOptions")){
										if(object["__pExcelOptions"].hasOwnProperty("hasHeaders")){
											if(object["__pExcelOptions"]["hasHeaders"] && i==0){
												//skip items that have excel headers which don't need to be numbers
												continue;
											}
										}
									}
									//convert to number for each item in 2D array
									try{
										object["value"][i][j] = parseFloat(object["value"][i][j]);
									}catch(err){}								
								}
							}
						}else{
							for(var i=0;i<object["value"].length;i++){
								if(object.hasOwnProperty("__pExcelOptions")){
									if(object["__pExcelOptions"].hasOwnProperty("hasHeaders")){
										if(object["__pExcelOptions"]["hasHeaders"] && i==0){
											//skip items that have excel headers which don't need to be numbers
											continue;
										}
									}
								}
								//convert to number for each item in 2D array
								try{
									object["value"][i] = parseFloat(object["value"][i]);
								}catch(err){}								
							}
						}
					}else{
						//convert single value field to number
						try{
							object["value"] = parseFloat(values);
						}catch(err){}
					}
				}
			}
		}
	}
}

/**
 * Hack in support for Function.name for browsers that don't support it.
 * IE, I'm looking at you.
 // required for object.constructor.name == "Object"
**/
if (Function.prototype.name === undefined && Object.defineProperty !== undefined) {
    Object.defineProperty(Function.prototype, 'name', {
        get: function() {
            var funcNameRegex = /function\s([^(]{1,})\(/;
            var results = (funcNameRegex).exec((this).toString());
            return (results && results.length > 1) ? results[1].trim() : "";
        },
        set: function(value) {}
    });
}

function attachOptions(object,propertyName){
	//attach default dunder objects

	//recursively iterate through all objects
	propertyName = propertyName || "";
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
            	if(property!='_links'){
                	attachOptions(object[property],property);
                }
            }
        }
    }

	//make sure we are in a field
	if(propertyName.substring(0,2)!="__" && object.constructor.name == "Object" && propertyName != "userUpdated" && propertyName != "userAdded"){
		//add empty dunders if they do not already exist
		object["__pFieldOptions"] = object["__pFieldOptions"] || {};
		object["__pDefOptions"] = object["__pDefOptions"] || {};
		object["__pFunctions"] = object["__pFunctions"] || {};
		object["__pExcelOptions"] = object["__pExcelOptions"] || {};
		object["__pDisplayOptions"] = object["__pDisplayOptions"] || {};
	}
}

function getDunder(object){
	//gets dunder properties for fields/fieldSets

	//recursively iterate through all objects
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
                getDunder(object[property]);
            }
        }
    }

	//no longer used
	if(object.hasOwnProperty("linkFunction")){
		tempF = new Function("field",object["linkFunction"]);
		tempF(object);
	}

	//if there is a _dunderSource property {_dunderSource:2323) load the dunder object with that id and merge fields
	if(object.hasOwnProperty("_dunderSource")){
		//get the dunder object
		var lO = getCache(object["_dunderSource"])
		//iterate through each item in the dunder object
		for (var property in lO){
			if(lO.hasOwnProperty(property)){
				if(property == "__parent"){
					//for each item in the __parent object attach that item to the root of this field
					for (var property2 in lO["__parent"]){
						object[property2] = lO["__parent"][property2];
					}
				}else{
					if(object.hasOwnProperty(property)){
						//if the dunder object already exists on the field
						//overwrite each item currently in that dunder object with each item existing in the new dunder object
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
						//if the dunder object is not on the field add it
						if (property.substring(0,2)=="__"){
							object[property] = lO[property];
						}
					}
				}
			}
		}
	}
}

function getDunderIds(object,theIds){
	//return an array of all dunder ids
	//used to get all the dunder ids at once for faster loading

	var theIds = theIds || []

	//recursively loop through all objects
	for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
				getDunderIds(object[property],theIds);
            }
        }
    }

	//if there is dunder id, add it
	if(object.hasOwnProperty("_dunderSource")){
		theIds.push(object["_dunderSource"]);
	}
	return theIds;
}

function addDefaultValues(object){
	//add user defined default values

	//recursively iterate through all objects
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
                addDefaultValues(object[property]);
            }
        }
    }

	//if the field has a default value option set the fields value equal to the default value option
	if(object.hasOwnProperty("__pFieldOptions")){
		if(object["__pFieldOptions"].hasOwnProperty("defaultValue")){
			object.value = object["__pFieldOptions"]["defaultValue"]
		}
	}
}


function Form(fd){
	//main class for making, editing, viewing forms

	//default viewState is view
	this.viewState = "view";
	//set JSON object
	this.fd = fd;
	//add functions an properties to JSON, also set default values
	attachOptions(this.fd);
	getDunder(this.fd);
	attachParentField(this.fd);
	attachFieldByName(this.fd);
	//make root level of JSON equivalent to the root level of the form for field name functions
	this.getFieldByName = this.fd.getFieldByName;
	this.getFieldNames = this.fd.getFieldNames;
	attachGetValArray(this.fd);
	setDefaultValues(this.fd);
	this.hideButtons = false;
	this.showHeader = true;
	this.hasChanged = false;
	//set id to JSON id
	this.id = this.fd.id;

	//for save method
	this.save = (function(form){
		return function(notInterfaceSave){
			//abort save if form did not validate
			if(!form.validate()){
				alert('Form contains errors.  Please review your data and try again');
				return false;
			}

			//run before save function.  If function returns "error" abort save
			// there are  result sets without analysis function

//           if(form.fd.typeId == 1927){
// 				aa = saveResultSet(form,form);
// 				if(aa=="error"){
// 					return false;
// 				}
// 			}
// 			else if(form.fd.typeId == 1902){		
// 				aa = saveTemplate(form,form);
// 				if(aa=="error"){
// 					return false;
// 				}
// 			}

// else if(form.fd["beforeSave"]){
// 				tempF = new Function("field","form",form.fd["beforeSave"]);
// 				aa = tempF(form,form);
// 				if(aa=="error"){
// 					return false;
// 				}
// 			}



           if(form.fd["beforeSave"]){
				tempF = new Function("field","form",form.fd["beforeSave"]);
				aa = tempF(form,form);
				if(aa=="error"){
					return false;
				}
			}

			//create sort view
			fixSort(form.fd);
			//make sure numbers are real numbers and not strings
			fixNumbers(form.fd);

			//remove all dunder objects for all forms that are not object/form templates (id 1)
			if(form.fd.typeId!=1){
				form.removeDunder();
			}

			if(notInterfaceSave==true){
				//if we are saving programatically i.e. not through the interface
				//do not do any of the display stuff
				if(form.fd.id){
					//if the form has an id we are editing

					//remove form from cache
					delete cache[form.fd.id];

					//put new form into the cache
					cache[form.fd.id] = JSON.parse(JSON.stringify(form.fd))
					theId = form.fd.id;
					//save the form	
					restCall("/saveForm/","POST",{"form":form.fd});
				}else{
					//first save, get new id
					theId = saveNew(form.fd)
				}
			}else{
				//display saving... where the button is
				$('#buttonHolder').html("saving...");
				toVal = 1;
				if(form.fd.typeId==resultTypeId){
					toVal = 500;
				}
				//set timeout so that the drawing to change button
				//has time to get rendered by the browser
				window.setTimeout(function(){
					if(form.fd.id){
						//if the form has an id we are editing
						theId = form.fd.id;
					}else{
						theId = saveNew(form.fd)
					}

					// Invalidate this ID from the cache, then store the new one.
					delete cache[theId];				
					restCall("/saveForm/","POST",{"form":form.fd});

					//redirect to view after save
					makeForm(theId,"arxOneContainer","view")
					//reload tree
					nodesToReload = [form.fd.parentId]
					handleNodeReloads(nodesToReload,false,false,$("#tree").dynatree("getTree"))
					//for admin page
					$("#saveId").text(theId);
					$("#output").val(JSON.stringify(form.fd,null,2));
				},toVal);
			}
		}
	})(this)

	//return an array of forms for all the children of this form
	this.getChildren = (function(form){
		return function(){
			var L = []
			var childIds = restCall("/getChildIds/","POST",{"id":form.fd.id})["childIds"];
			childIds.sort()
			//add all children to cache
			getCache(childIds);
			//add all children as forms to array from cache
			$.each(childIds,function(i,childId){
				L.push(new Form(getCache(childId)))
			});
			return L;
		}
	})(this)
}

Form.prototype.showHeader = function(){
	var self = this;
}

Form.prototype.hideFields = function(L){
	//set field property to hidden for the given array of field names
	var self = this;
	$.each(L,function(i,name){
		var thisField = self.getFieldByName(name);
		if(thisField){
			if(!thisField.hasOwnProperty("hidden")){
				Object.defineProperty(thisField, 'hidden',{value:true,enumerable:false});
			}else{
				thisField.hidden = true;
			}
		}
	});
}

Form.prototype.show = function(theDiv,viewState){
	// main form display function
	var self = this;


	//get jQuery object of the target div
	if(theDiv.substring){
		theDiv = $("#"+theDiv);
	}

	//default to view if not viewState set
	self.viewState = viewState || "view";

	//run beforeShow function for the form
	if(self.fd["__pFunctions"]["beforeShow"]){
		tempF = new Function("field","form",self.fd["__pFunctions"]["beforeShow"]);
		tempF(self,self);
	}

	//if form has a name, put a header in the target div
	if(self.fd.hasOwnProperty("name")&&self.showHeader){
		theDiv.append($("<h1>"+self.fd.name+"</h1>"))
	}

	cals = [];

	//attach the result of displayField for each field that is not hidden
	$.each(self.fd.fields,function(i,field){
		if(!field.hidden){
			theDiv.append(self.displayField(field));
		}
	});
	for(var i=0;i<cals.length;i++){
		cals[i]();
	}

	//run afterShow function for form
	if(self.fd["__pFunctions"]["afterShow"]){
		tempF = new Function("field","form",self.fd["__pFunctions"]["afterShow"]);
		tempF(self,self);
	}

	//add div for form level errors.  fields have their own error divs for field specific errors
	formErrors = $("<div id='formErrors'/>");
	theDiv.append(formErrors);

	if(self.viewState=="view"){
		if (self.fd.typeId == resultSetTypeId){
			//add result holder for result sets
			//make holder divs
			resultsHolder = $("<div id='resultsHolder' style='width:100%;position:relative;'>");
			resultsHolderInner = $("<div id='resultsHolderInner'>");
			resultsHolder.append(resultsHolderInner);
			//preload children to cache and set vars for result holder creation
			D = {}
			D["value"] = restCall("/getChildIds/","POST",{"id":self.fd.id})["childIds"];
			D["value"].sort();
			D["position"] = 0;
			D["id"] = "resultsHolderInner";
			//create and append to holder div result set scroller
			scroller = $(createChildLinksScroller(false,D,"resultsHolderInner",false,false,false));
			resultsHolder.append(scroller)
			theDiv.append(resultsHolder);
			afterScroller()
		}
	}

	//create div to hold buttons
	buttonHolder = $("<div id='buttonHolder'/>")

	//create date and user added box at bottom
	try{
		d = new Date(self.fd.dateAdded)
		dateString = (d.getUTCMonth()+1)+"/"+d.getUTCDate()+"/"+d.getFullYear();
		buttonHolder.append("<div class='datebox'><div><label>User Added</label><div>"+self.fd.userAdded.userName+"</div></div><div><label>Date Added</label><div>"+dateString+"</div></div></div>")
	}catch(err){}

	//if we are editing add a save button
	if(self.viewState == "edit"){
		saveBtn = $("<input type='button' value='SAVE'/>");
		saveBtn[0].onclick = self.save;
		buttonHolder.append(saveBtn);
		$("#running").val(JSON.stringify(self.fd,null,2))
	}

	if(self.viewState == "view"){
		

		//Copy for upload templates
		if (self.fd["name"] === "Upload Template") {
			var copyBtn = $("<input type='button' value='Copy'/>");
			copyBtn[0].onclick = (function (form) {
				return function () {
					blackOn();
					popup = newPopup("uploadTemplatePopup");
					popup.setAttribute("style", "width:400px;height:550px;")

					label = document.createElement("label");
					label.innerHTML = "New Upload Template Name";
					popup.appendChild(label);

					templateNameBox = document.createElement("input");
					templateNameBox.setAttribute("type", "text");
					templateNameBox.id = "templateNameBox";
					popup.appendChild(templateNameBox);

					pasteBtn = document.createElement("input");
					pasteBtn.setAttribute("type", "button");
					pasteBtn.setAttribute("value", "Paste");
					pasteBtn.setAttribute("style", "margin-top:10px")
					popup.appendChild(pasteBtn);
					pasteBtn.onclick = (function () {

						// make sure the parent type is the correct when pasting
						if ((self.fd["name"] === "Upload Template")) {
							var newId = restCall("/getNextId/", "POST", {})["id"];
							var templateName = document.getElementById('templateNameBox').value;

							mf = restCall("/nextSequence/","POST",{"seq":form.fd.parentId})["seq"];
							form.fd._sort.index = mf
							form.getFieldByName('index').value = mf
							mf = mf.toString()
							if(templateName === "")
							{
								templateName = "copy of " +form.fd._sort.name
							}
							
							form.fd.fields[0].value = templateName;
							form.fd._sort.name = templateName;
							  
							if (form.fd.typeId != 1) {
								form.removeDunder();
							}

							form.fd.dateAdded = new Date();
							form.fd.id = newId;
							form.fd.locked = true
							if (form.fd.locked) {
								delete form.fd.locked
							}

							if (form.fd.userAdded == null) {
								form.fd.userAdded = {}
								form.fd.userAdded.userName = userName;
								form.fd.userAdded.id = connectionId.substring(0, 4);
							}
							else {
								form.fd.userAdded.userName = userName;
								form.fd.userAdded.id = connectionId.substring(0, 4);
							}

							restCall("/saveForm/", "POST", { "form": form.fd });

							window.setTimeout(function(){

								//redirect to view after save
								makeForm(newId,"arxOneContainer","view")
								//reload tree
								nodesToReload = [form.fd.parentId]
								handleNodeReloads(nodesToReload,false,false,$("#tree").dynatree("getTree"))
								//for admin page
								$("#saveId").text(newId);
								$("#output").val(JSON.stringify(form.fd,null,2));
								window.location.reload();
							},1);

						}
						else {
							alert("Error");
							
						}
					});

					document.getElementById("contentTable").appendChild(popup);
					window.scroll(0, 0);
				}
			})(self)
			buttonHolder.append(copyBtn);
		}





if(self.fd["name"] === "Protocol" || self.fd["name"] === "CBIP Protocol" ){
			var copyBtn = $("<input type='button' value='Copy'/>");	
			copyBtn[0].onclick = (function(form){
				return function(){
					blackOn();
					popup = newPopup("protocolPopup");
                    popup.setAttribute("style","width:400px;height:550px;")

                    label = document.createElement("label");
				    label.innerHTML = "New Protocol Name";
				    popup.appendChild(label);

			        protocolNameBox = document.createElement("input");
                    protocolNameBox.setAttribute("type","text");
                    protocolNameBox.id = "protocolNameBox";
                    popup.appendChild(protocolNameBox); 


                    label = document.createElement("label");
				    label.innerHTML = "Select A New Location";
				    popup.appendChild(label);

				    div = document.createElement("div")
				    div.setAttribute("id","treeAdded");
				    div.setAttribute("style","width:400px;height:400px;")
				    popup.appendChild(div);

			        pasteBtn = document.createElement("input");
			        pasteBtn.setAttribute("type","button");
			        pasteBtn.setAttribute("value","Paste");
			        pasteBtn.setAttribute("style","margin-top:10px")
			        popup.appendChild(pasteBtn);
			        pasteBtn.onclick = (function(){	

                     var parentType = restCall("/getParentType/","POST",{key:currentNodeKey})["name"]
                     // make sure the parent type is the correct when pasting
                     if((self.fd["name"] === "Protocol" && parentType === "Assay") || (self.fd["name"] === "CBIP Protocol" && parentType === "CBIP Assay"))
                     {
				       var newId = restCall("/getNextId/","POST",{})["id"];
				       var getParentTree = restCall("/getParentTree/","POST",{id:currentNodeKey})["parentTree"];				       
				       var parentTree = getParentTree.slice(0,getParentTree.length-1)
				       parentTree =  parentTree.concat(Number(currentNodeKey))                 
				       var protocolName = document.getElementById('protocolNameBox').value;
                          if(form.fd["name"] === "CBIP Protocol"){
	 			            mf = restCall("/nextSequence/","POST",{"seq":currentNodeKey})["seq"];
	 	                    form.fd._sort.index = mf
	 	                    form.getFieldByName('index').value = mf
	 	                    mf = mf.toString()
	 	                    if(protocolName === "")
	 	                    {
	 	                    	protocolName = "copy of " +form.fd._sort.name
	 	                    }
	 	                    if(mf.length == 1){mf = "0"+mf}
	 	                    form.fd.fields[0].value = mf+" " +protocolName;
						    form.fd._sort.name = mf+ " "+protocolName;
	 		              }

                           if(form.fd.typeId!=1){
				             form.removeDunder();
			                }

			            form.fd.dateAdded = new Date();	            
						form.fd.id = newId;
						form.fd.locked = true
						if(form.fd.locked){
							delete form.fd.locked
						}
						form.fd.parentTree = parentTree;
						form.fd.parentId = Number(currentNodeKey);					

						if (form.fd.userAdded == null){
							form.fd.userAdded = {}
                            form.fd.userAdded.userName = userName;
						    form.fd.userAdded.id = connectionId.substring(0,4); 
						}
						else{
							form.fd.userAdded.userName = userName;
						    form.fd.userAdded.id = connectionId.substring(0,4); 
						}
					
			            restCall("/saveForm/","POST",{"form":form.fd});
					    window.location.reload();	
                     	}
                     	else{
                     		if(self.fd["name"] === "Protocol"){alert("You must paste a Protocl under an Assay.")}
                     		else{alert("You must paste a CBIP Protocl under a CBIP Assay.")}
                     	}                     		
			});			
				  
	        document.getElementById("contentTable").appendChild(popup);							 
            window.scroll(0,0);
		$("#treeAdded").dynatree({
			initAjax: {url: "/getProtocolTree",
					   data: {key: "350", // Optional arguments to append to the url
							  mode: "all",						
							  connectionId:connectionId
							  }
					   },
			onLazyRead: function(node){
				node.appendAjax({url: "/getProtocolTree",
								   data: {"key": node.data.key.replace("_",""), // Optional url arguments
										  "mode": "all",
										  "type": node.data.type,
										  connectionId:connectionId
										  }
								  });
			},
			onClick:function(node){
						currentNodeKey = node.data.key.replace("_",""); 
						 

 					                        					 
			},			
			onActivate: function(node){
				handleLink(node.data.key,node.data.type,node.data.showTable);
				if(!node.bExpanded){
					node.expand(true);
				}
			},
			imagePath: "images/treeIcons/",
			debugLevel: 0
		     });	
             }
		})(self)	
			buttonHolder.append(copyBtn);
		    }

             // Copy Paste functionality  for assay and cbip assay only
		   if(self.fd["name"] === "Assay" || self.fd["name"] === "CBIP Assay"){
			var copyBtn = $("<input type='button' value='Copy'/>");	
			copyBtn[0].onclick = (function(form){
				return function(){
					blackOn();
					popup = newPopup("assayPopup");
					popup.setAttribute("style","width:400px;height:550px;")

                    label = document.createElement("label");
				    label.innerHTML = "New Assay Name";

				    popup.appendChild(label);

			        assayNameBox = document.createElement("input");
                    assayNameBox.setAttribute("type","text");
                    assayNameBox.id = "assayNameBox";
                    popup.appendChild(assayNameBox); 

                    label = document.createElement("label");
				    label.innerHTML = "Select A New Location ";
				    popup.appendChild(label);

				    div = document.createElement("div")
				    div.setAttribute("id","treeAdded");
				    div.setAttribute("style","width:400px;height:400px;")
				    popup.appendChild(div);

			        pasteBtn = document.createElement("input");
			        pasteBtn.setAttribute("type","button");
			        pasteBtn.setAttribute("value","Paste");
			        pasteBtn.setAttribute("style","margin-top:10px")
			        popup.appendChild(pasteBtn);
			        pasteBtn.onclick = (function(){	

                     var parentType = restCall("/getParentType/","POST",{key:currentNodeKey})["name"]
                     //  assays only under assay groups, cbip assays only under cbip projects
                     if((self.fd["name"] === "Assay" && parentType === "Assay Group") || (self.fd["name"] === "CBIP Assay" && parentType === "CBIP Project"))
                     {
				       var newId = restCall("/getNextId/","POST",{})["id"];
				       var getParentTree = restCall("/getParentTree/","POST",{id:currentNodeKey})["parentTree"];				       
				       var parentTree = getParentTree.slice(0,getParentTree.length-1)
				       parentTree =  parentTree.concat(Number(currentNodeKey))
               		   var assayName = document.getElementById('assayNameBox').value;        
                       if(form.fd["name"] === "CBIP Assay"){
	 			            mf = restCall("/nextSequence/","POST",{"seq":currentNodeKey})["seq"];
	 	                    form.fd._sort.index = mf
	 	                    form.getFieldByName('index').value = mf
	 	                    mf = mf.toString()
	 	                    if(assayName === "")
	 	                    {
	 	                    	assayName = "copy of " +form.fd._sort.name
	 	                    }
	 	                    if(mf.length == 1){mf = "0"+mf}
	 	                    form.fd.fields[0].value = mf+" " +assayName;
						    form.fd._sort.name = mf+ " "+assayName;
	 		              }

                        if(form.fd.typeId!=1){
				          form.removeDunder();
			             }

			            form.fd.dateAdded = new Date();	            
						form.fd.id = newId;
						form.fd.parentTree = parentTree;
						form.fd.parentId = Number(currentNodeKey);					
   
						if (form.fd.userAdded == null){
							form.fd.userAdded = {}
                            form.fd.userAdded.userName = userName;
						    form.fd.userAdded.id = connectionId.substring(0,4); 
						}
						else{
							form.fd.userAdded.userName = userName;
						    form.fd.userAdded.id = connectionId.substring(0,4); 
						}
			
			            restCall("/saveForm/","POST",{"form":form.fd});
					    window.location.reload();

                     	}
                     	else{
                     		if(self.fd["name"] === "Assay"){alert("You must paste an Assay under an Assay Group.")}
                     		else{alert("You must paste a CBIP Assay under a CBIP Project.")}
                     	}	                       		
			});			
				  
	        document.getElementById("contentTable").appendChild(popup);							 
            window.scroll(0,0);
		$("#treeAdded").dynatree({
			initAjax: {url: "/getAssayTree",
					   data: {key: "350", // Optional arguments to append to the url
							  mode: "all",						
							  connectionId:connectionId
							  }
					   },
			onLazyRead: function(node){
				node.appendAjax({url: "/getAssayTree",
								   data: {"key": node.data.key.replace("_",""), // Optional url arguments
										  "mode": "all",
										  "type": node.data.type,
										  connectionId:connectionId
										  }
								  });
			},
			onClick:function(node){
						currentNodeKey = node.data.key.replace("_",""); 
						 						 		 		                        					 
			},			
			onActivate: function(node){
				handleLink(node.data.key,node.data.type,node.data.showTable);

				if(!node.bExpanded){
					node.expand(true);
				}
			},
			imagePath: "images/treeIcons/",
			debugLevel: 0
		     });	
             }
		})(self)	
			buttonHolder.append(copyBtn);
		    }


		if(self.fd.canEdit){
			//if we are viewing and we have permission to edit, add an edit button
			editBtn = $("<input id='editButton' type='button' value='Edit'/>");		
			editBtn[0].onclick = (function(form){
				return function(){
					editExistingRecord = true;
					makeForm(form.fd.id,"arxOneContainer","edit")
				}
			})(self)
			buttonHolder.append(editBtn);

			

			$("#running").val(JSON.stringify(self.fd,null,2))
		}
		if(self.fd.hasOwnProperty("locked")){
			if (self.fd["locked"]){
				//if we are locked don't show edit button
				editBtn.attr("style", "display: none !important");;
				console.log("it is locked")
			}
			if(jsRole=='admin'){
				//if we are an admin show unlock button
				unlockBtn = $("<input id='unlockButton' type='button' value='Unlock'/>");
				if(!self.fd.locked){
					//hide button if we are not locked
					unlockBtn.attr("style", "display: none !important");;
				}
				unlockBtn[0].onclick = (function(form){
					return function(){
						if(confirm('Are you sure you want to unlock this protocol?')){
							//unlocking hides the unlock button, shows the edit button and shows the lock button
							//also saves form with updated lock status
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
				buttonHolder.append(unlockBtn);

				//if we are and admin show the lock button
				lockBtn = $("<input id='lockButton' type='button' value='Lock'/>");
				if(self.fd.locked){
					//hide the lock button if we are locked
					lockBtn.attr("style", "display: none !important");;
				}
				lockBtn[0].onclick = (function(form){
					return function(){
						if(confirm('Are you sure you want to lock this protocol?')){
							//the lock button hides the lock button, shows the unlock button, and hides the edit button
							//also saves form with updated lock status
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
				buttonHolder.append(lockBtn);

			}
		}
		if(self.fd.canDelete2){
			//if we have permission to delete show the delete button
			deleteBtn = $("<input type='button' value='Delete'/>");
			deleteBtn[0].onclick = (function(form){
				return function(){
					swal({
						title: decodeDoubleByteString(assayDeleteFormWarning),
						icon: "warning",
						showCancelButton: true,
					}, function() {
						deleteForm(form);
					});
				}
			})(self)
			buttonHolder.append(deleteBtn);
			$("#running").val(JSON.stringify(self.fd,null,2))
		}
	}
	//don't show buttons on results
	if(self.fd.typeId!=resultTypeId){
		if(!self.hideButtons){
			theDiv.append(buttonHolder);
		}
	}
}

/**
 * Delete the form, reload the tree and empty the target container.
 * @param {HTMLObject} form The form to delete.
 */
function deleteForm(form) {
	nodesToReload = [form.fd.parentId]
	delete cache[form.fd.id];
	restCall("/deleteForm/","POST",{"id":form.fd.id})
	handleNodeReloads(nodesToReload,false,false,$("#tree").dynatree("getTree"))
	$("#arxOneContainer").empty();
}

function save2(fd){
	if(fd.id){
		//if we have an id then we were editing
		//delete from and re-add to cache
		delete cache[fd.id];
		cache[fd.id] = JSON.parse(JSON.stringify(fd))
		//set return id to previous id
		theId = fd.id;
		//save form
		restCall("/saveForm/","POST",{"form":fd});
	}else{
		//save and get new id
		theId = saveNew(fd)
	}
	return theId;
}


function saveNew(theOb){
	//save a form for the first time
	//create copy of object i.e. not linked
	theObEx = $.extend(true,{},theOb)
	//get new id
	id = restCall("/getNextId/","POST",{})["id"];
	//set id
	theObEx.id = id;
	//add to cache
	cache[id] = JSON.parse(JSON.stringify(theObEx))
	//save form
	restCall("/saveForm/","POST",{"form":theObEx});
	//return new id
	return id;
}

function applyDisplayOptions(field,theVal){
	//apply scientific notation and num decimal places options to field
	try{
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
	}catch(err){}
	return theVal;
}

function zeroPad(num, places) {
	//left pad with zeros
  var zero = places - num.toString().length + 1;
  return Array(+(zero > 0 && zero)).join("0") + num;
}

Form.prototype.displayField = function(field,opts){
	//main field display function
	var self = this;
	var fieldHolderDiv,fieldDiv,o,a,d3,d4,label,sendOpts,fieldCopy;
	var opts = opts || {}

	//create holder div
	fieldHolderDiv = $("<div class='fieldHolder'></div>");
	//add show function to field
	field.show = (function(theDiv){
			return function(){
				$(theDiv).show();
			}
		})(fieldHolderDiv)
	//add hide function to field
	field.hide = (function(theDiv,field){
			return function(){
				$(theDiv).hide();
				field["__pFieldOptions"]["required"] = false;
				field.labelDiv.html(field["__pFieldOptions"]["name"])
			}
		})(fieldHolderDiv,field)
	//add require function to field.  Shows the field and adds a star to the label
	field.require = (function(theDiv,field){
			return function(){
				$(theDiv).show();
				field["__pFieldOptions"]["required"] = true;
				field.labelDiv.html(field["__pFieldOptions"]["name"]+"*")
			}
		})(fieldHolderDiv,field)

	//create label text
	labelText = field["__pFieldOptions"]["name"];
	if(field["__pFieldOptions"]["required"]){
		labelText += "*"
	}

	//create label div
	label = $("<div class='label'>"+labelText+"</div>");
	//add label div as property to field
	if(!field.hasOwnProperty("labelDiv")){
		Object.defineProperty(field, 'labelDiv',{value:label,enumerable:false})
	}
	//append labeldiv to field holder if the field is not displayTable, is not a heading, and is not hidden
	if(!opts["displayTable"]&&field["__pFieldOptions"]["type"]!="heading"&&field["__pFieldOptions"]["type"]!="hidden"){
		fieldHolderDiv.append(label);
	}

	//create field div
	fieldDiv = $("<div class='field'></div>");
	if(opts["noNest"]){
		fieldDiv.addClass("noNest")
	}
	fieldHolderDiv.addClass("fn_"+self.cleanClass(field["__pFieldOptions"]["name"]))

	//if we are a field set holder add class to holder div
	if(field["__pFieldOptions"]["type"] == "fieldSet"){
		fieldHolderDiv.addClass("fieldSetHolder")
	}

	//default multi to false if it is not specified on field
	field["__pFieldOptions"]["multi"] = field["__pFieldOptions"]["multi"] || false 

	//run before show field function
	if(field["__pFunctions"]["beforeShow"]){
		tempF = new Function("field","form",field["__pFunctions"]["beforeShow"]);
		tempF(field,self);
	}

	//get the first value in the array if field value is array.  For fields with multiple values this 
	//function will be called multiple times and use the first value each time.
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

	//for select lists that are ids get the name for display purposes
	if(field["__pFieldOptions"]["type"]=="select" && isNumber(firstVal) && self.viewState=="view"){
		var fff = new Form(getCache(firstVal));
		if(fff.getFieldByName('name')){
			firstVal = fff.getFieldByName('name').value;
		}
	}

	//determine if field is an aggregated table from a result
	aggregateTable = false;
	if(field["__pFieldOptions"].hasOwnProperty("aggregate")){
		if(field["__pFieldOptions"]["aggregate"]){
			if($.isArray(field.value)){
				aggregateTable = true;
			}
		}
	}

	isAssayTable = false;
	if( (field["__pExcelOptions"]["dataWidth"] && field["__pFieldOptions"]["type"]!='curve') || aggregateTable || ($.isArray(field["value"]) && field["__pExcelOptions"].hasOwnProperty("dataWidth")) ){
		//if we should make a table to display the data
		
		//if we have the reverse attribute reverse width and height
		reverse = false;
		if(field["__pExcelOptions"].hasOwnProperty("reverse")){
			reverse = field["__pExcelOptions"]["reverse"]
		}
		if (reverse){
			dataWidth = parseInt(field["__pExcelOptions"]["dataHeight"]);
			dataHeight = parseInt(field["__pExcelOptions"]["dataWidth"]);
		}else{
			dataWidth = parseInt(field["__pExcelOptions"]["dataWidth"]);
			dataHeight = parseInt(field["__pExcelOptions"]["dataHeight"]);
		}
		hasHeaders = field["__pExcelOptions"]["hasHeaders"];

		//get actual width and height
		if(!($.isArray(field.value))){
			dataWidth = 1;
			dataHeight = 1;
		}else{
			if($.isArray(field.value[0])){
				dataHeight = field.value[0].length;
				dataWidth = field.value.length
			}else{
				dataHeight = field.value.length;
				dataWidth = 1;
			}
		}

		if(!(dataWidth==1 && dataHeight==1)){
			//make table if we should
			isAssayTable = true;
			assayTable = $("<table/>");
			assayTable.addClass("plateMap")
			if (dataWidth == 1){
				fieldVal = [fieldVal];
			}
			for(var i=0;i<dataHeight;i++){
				tr = $("<tr/>");
				//make header row
				if(i==0 && hasHeaders){
					tr.addClass("headerRow")
				}
				//color odd/even rows
				if(i%2==0){
					tr.addClass("odd");
				}else{
					tr.addClass("even");
				}
				for(var j=0;j<dataWidth;j++){
					td = $("<td/>")
					theVal = fieldVal[j][i];
					if(!(hasHeaders && i==0)){
						//apply scientific notation and decimal place display options
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
			//display fieldSet like table using divs
			//only used in early demos
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
			//if we are a multi fieldSet loop through outer array
			$.each(field["fields"],function(q,fieldFromFields){
				//create a new holder div for each
				d3 = $("<div class='field fieldSetField'></div>")
				$.each(fieldFromFields,function(i,field2){
					//to the new holder div append the result of display field for each field in fieldSet
					d3.append(self.displayField(field2,sendOpts))
				});
				//run afterShow function for fieldSet
				if(field["__pFunctions"]["afterShow"]){
					tempF = new Function("field","form","fs",field["__pFunctions"]["afterShow"]);
					tempF(fieldFromFields,self,field);
				}
				//apply wrappers to holder and apply appropriate classes
				d3 = $("<div class='field'></div>").append($("<div class='fieldHolder'></div>").append(d3));
				d4 = $("<div class='fieldHolder fs_"+self.cleanClass(field["__pFieldOptions"]["name"])+"'></div>")
				if(opts["displayTable"]&&field["__pFieldOptions"]["display"]=="table"){
					d4.addClass("displayTable");
					d3.addClass("displayTable");
				}
				//if we are editing and this is not the first item in a multi fieldSet add a remove button
				if((q>0||opts["noNest"])&&self.viewState=="edit"){
					d4.append(self.removeParentLink(opts["originalField"] || field,self,fieldFromFields))
				}
				if(isAdminPage&&field["__pFieldOptions"]["multi"]&&self.viewState=="edit"){
					//for admin page add move up/move down buttons
					a = $("<a href='javascript:void(0)'>move up</a>");
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
					a = $("<a href='javascript:void(0)'>move down</a>");
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
			});
		}else{
			//single field set

			//make holder div
			d3 = $("<div class='field fieldSetField'></div>")
			$.each(field["fields"],function(i,field){
				//for each field in fieldSet append the result of displayField for each field in the fieldSet to the holder div
				d3.append(self.displayField(field,sendOpts))
			});
			//apply wrappers and classesto the holder div
			d3 = $("<div class='field'></div>").append($("<div class='fieldHolder'></div>").append(d3));
			d4 = $("<div class='fieldHolder fs_"+self.cleanClass(field["__pFieldOptions"]["name"])+"'></div>")
			if(opts["displayTable"]){
				d4.addClass("displayTable");
			}
			fieldDiv.append(d4.append(d3))

			//run aftershow function for fieldSet
			if(field["__pFunctions"]["afterShow"]){
				tempF = new Function("field","form",field["__pFunctions"]["afterShow"]);
				tempF(field["fields"],self);
			}
		}
		//for the first item in a multi field set, if we are edting, add an add button
		if(!opts["noNest"]&&field["__pFieldOptions"]["multi"]&&self.viewState=="edit"){
			thisA = self.addLink(field,self);
			if(!field.hasOwnProperty("theAddLink")){
				Object.defineProperty(field, 'theAddLink',{value:thisA,enumerable:false})
			}
			fieldDiv.append(thisA)
		}
	}else{
		//run afterShow function for field that is not a fieldSet
		if(field["__pFunctions"]["afterShow"]&&!opts["noNest"]){
			tempF = new Function("field","form",field["__pFunctions"]["afterShow"]);
			tempF(field,self);
		}
	}

	//if field type is heading append heading to holder div
	if(field["__pFieldOptions"]["type"] == "heading"){
		fieldHolderDiv.append($("<h2>"+field["__pFieldOptions"]["name"]+"</h2>"));
	}
	

	//o is the actual object that is linked to the field value e.g. type=text is an <input type="text"/>
	//all o 's should have a getValue function that returns that value that the field value should be set to on change of the o
	if(isAssayTable){
		o = assayTable;
	}else{
		if(field["__pFieldOptions"]["type"] == "text"){
			if(self.viewState == "edit"){
				o = $("<input type='text'>");
				if(field["__pFieldOptions"]["multi"]){
					//for multi text fields, allow pasting of csv or tsv data to create multiple new items
					$(o).on('paste',function(e) {
						var clipboardData, pastedData;
						if(e.hasOwnProperty("originalEvent")){
							e = e.originalEvent
						}
						e.stopPropagation();
					    e.preventDefault();
					    clipboardData = e.clipboardData || window.clipboardData;
					    pastedData = clipboardData.getData('Text');
						this.value = pastedData.replace(/\r*\n/ig,"\t");
						if(this.value.indexOf("\t")!=-1 || this.value.replace(/\s+/,"")!=""){
							this.onchange();
						}
					})
				}

				if(firstVal != ""){
					o.val(firstVal);
				}
				//simple getValue function
				o[0].getValue = function(){return $(this).val()};
			}
			if(self.viewState == "view"){
				//show a span for view
				//apply display options for sci notation and num decimal places to value
				firstVal = applyDisplayOptions(field,firstVal)
				o = $("<span>"+firstVal+"</span>");
			}
		}

		if(field["__pFieldOptions"]["type"] == "date"){
			if(self.viewState == "edit"){
				//when editing date fields add calendar popup
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
				//for view show span
				o = $("<span>"+firstVal+"</span>");
			}
		}

		if(field["__pFieldOptions"]["type"] == "select"){
			if(self.viewState == "edit"){
				//create o
				o = $("<select/>");
				//add null option
				o.append($("<option>").text("--SELECT--").attr("selected",true));
				//for each option in field options add an option to drop down
				$.each(field["__pFieldOptions"]["options"],function(i,op){
					if($.isArray(op)){
						//for arrays add first element as value and second as text
						o.append($("<option>").val(op[0]).text(op[1]))
					}else{
						//for non arrays text and value are the same
						o.append($("<option>").val(op).text(op))
					}
				});
				if(firstVal){
					o.val(firstVal);
				}
				o[0].getValue = function(){
					//on getValue if the selected item is the null option return blank
					v = $(this).val();
					if (v=="--SELECT--"){
						return "";
					}else{
						return v;
					}
				};
			}
			if(self.viewState == "view"){
				//for view show span
				o = $("<span>"+firstVal+"</span>");
			}
		}

		if(field["__pFieldOptions"]["type"] == "file"){
			if(self.viewState == "edit"){
				if(firstVal != ""){
					thisFileVal = firstVal;
				}else{
					thisFileVal = field["value"];
				}
				//show iframe to upload_file_frame if we are editng
				o = $("<iframe/>",{src:"upload_file_frame.asp?fileId="+thisFileVal,frameBorder:0});
				o.height(90);
				o.width(360);

				//getValue gets the file id from the frame
				o[0].getValue = function(){
					return $(this).contents().find('#theFileId').val()};
			}
			if(self.viewState == "view"){
				//shows iframe for upload_file_frame with read only option
				if(firstVal != ""){
					thisFileVal = firstVal;
				}else{
					thisFileVal = field["value"];
				}
				o = $("<iframe/>",{src:"upload_file_frame.asp?fileId="+thisFileVal+"&readOnly=true",frameBorder:0});
				o.height(70);
				o.width(360);
			}
		}
		
		if(field["__pFieldOptions"]["type"] == "permGroupList"){
			if(self.viewState == "edit"){
				o = $(createPermissions(self,field,self.viewState=="view"))
			}
			if(self.viewState == "view"){
				o = $(drawPerms(field))
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
				//getValue returns checked status
				o[0].getValue = function(){return $(this).prop("checked")}
			}
			if(self.viewState == "view"){
				o = $("<span>"+firstVal+"</span>")
			}
		}
		if(field["__pFieldOptions"]["type"] == "curve"){
			//curve type shows curve widget
			var widgetObject = new KnockoutPlot(field,self.viewState);
			o = widgetObject.draw();
			o[0].getValue = widgetObject.getValue();
			//define widget property
			if(!field.hasOwnProperty("widget")){
				Object.defineProperty(field, 'widget',{value:widgetObject,enumerable:false})
			}
		}
		if(field["__pFieldOptions"]["type"] == "heatMap"){
			if(self.viewState == "view"){
				//manual show heatMap button
				o = $("<button class='heatMapButton'>Show Heat Map</button>");
				o.on('click',function(){
					var arxHeatMap = new ArxHeatMap(self);
					$("#arxOneContainer").empty();
					$("#arxTwoContainer").append(arxHeatMap.makeHeatMap())
				});
				o[0].getValue = function(){return ""};
			}
		}
	}

	if(o){
		//add the o to field as property theO
		if(!field.hasOwnProperty("theO")){
			Object.defineProperty(field, 'theO',{value:o,enumerable:false})
		}

		if(opts["changeFunction"]){
			//handle passthrough change function (multi value fields repeatedly calling displayField)
			field.changeFunction = opts["changeFunction"];
		}else{
			if(field["__pFieldOptions"]["multi"]){
				field.changeFunction = (function(field,holderDiv,form){
					return function(){
						//multi text field change function
						vals = [];
						//from the holder div find all the first level children and push them to the val array
						//set the field value to this array
						holderDiv.find(".fieldValue").not('.fieldSetField .fieldSetField').each(function(i,el){
							vals.push($($(el).children()[0])[0].getValue())
						});
						field.value = vals;
						if(field["__pFieldOptions"]["type"]=="text" && field["__pFieldOptions"]["multi"]){
							//handle csv or tsv data pasted into single field
							splitBy = "";
							if(field["value"][0].indexOf("\n")!=-1){
								splitBy = "\n";
							}
							if(field["value"][0].indexOf("\t")!=-1){
								splitBy = "\t";
							}
							if(splitBy){
								//if we found a valid separator

								//split and trim the data
								arr = field.value[0].split(splitBy);
								field.value[0] = arr[0].replace(/^\s+|\s+$/g, '');
								//set the target field to the first value of th array
								field.theO.val(field.value[0]);

								//create and display new fields for each item in array
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
								//set the field value to the new value(s) with all the fields separated
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
				//default change function, just calls field.getValue
				field.changeFunction = (function(field){
					return function(){
						field.value = this.getValue()
					}
				})(field)
			}

			//if field has an afterChange function create a new function as the change function
			//that calls the built in change function then the custom afterChange function
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
		//set DOM onchange
		o[0].onchange = (function(theF,form,o){
			return function(){
				theF.call(o);
				form.hasChanged = true;
			}
		})(field.changeFunction,self,o[0]);
		//append o to fieldDiv with value wrapper
		fieldDiv.append($("<div class='fieldValue'></div>").append(o));
	}

	if(field["__pFieldOptions"]["multi"]&&field["__pFieldOptions"]["type"]!="fieldSet"){
		//fields that are multi and are not field sets must iteratively call displayField

		sendOpts = {}
		//tell the system that this is not an original field
		sendOpts["noNest"] = true;
		//add current change function so that the change function will
		//get appended to the display field
		sendOpts["changeFunction"] = field.changeFunction;
		$.each(fieldVal,function(i,val){
			if(i != 0){
				//for all field values but the first
				//make a copy of the field
				fieldCopy = $.extend(true,{},field);
				//set the value of the field to this iteration item
				fieldCopy["value"] = field["value"][i];
				//call displayField with the options set above
				fieldDiv.append(self.displayField(fieldCopy,sendOpts));
			}
		});
	}

	if(field["__pFieldOptions"]["multi"] && opts["noNest"] && field["__pFieldOptions"]["type"]!="fieldSet" &&self.viewState=="edit" ){
		//when we are editing and we are not a fieldSet add a remove link for all but the first value
		fieldDiv.find(".fieldValue").append(self.removeParentLink(field,self));
	}

	if (field["__pFieldOptions"]["multi"] && !opts["noNest"] && field["__pFieldOptions"]["type"]!="fieldSet" && self.viewState=="edit"){
		//for the first item in a multi field append the green plus button/add link to the field div
		thisA = self.addLink(field,self);
		if(!field.hasOwnProperty("theAddLink")){
			Object.defineProperty(field, 'theAddLink',{value:thisA,enumerable:false})
		}
		fieldDiv.append(thisA)
	}

	if (opts["noNest"]){
		//when we are not nesting return item without wrapper div
		return fieldDiv.children();
	}
	if(field["__pFieldOptions"]["type"]!="heading"&&field["__pFieldOptions"]["type"]!="hidden"){
		//append fieldDiv to Holder
		fieldHolderDiv.append(fieldDiv)
	}else{
		//unless we are hidden or a heading.  In that case, remove the fieldHolder class
		fieldHolderDiv.removeClass("fieldHolder");
	}
	if(field["__pFieldOptions"]["type"]!="fieldSet"){
		//add error div to field holder
		errorDiv = $("<div class='errorDiv'/>");
		fieldHolderDiv.append(errorDiv);
		//add error div object to field, this makes it very easy for the system to know
		//where to put errors
		if(!field.hasOwnProperty("errorDiv")){
			Object.defineProperty(field, 'errorDiv',{value:errorDiv,enumerable:false})
		}
	}
	//add holderDiv property to field
	if(!field.hasOwnProperty('holderDiv')){
		Object.defineProperty(field, 'holderDiv',{value:fieldHolderDiv,enumerable:false})
	}
	//return fieldHolderDiv jQuery/DOM object
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
	//excelValidation for results
	errors = []
	//iterate through each field
	$.each(form.fields,function(i,field){
		sheet = form.sheet;
		fieldVal = field["value"];
		//if field has reverse attribute switch width and height
		reverse = false;
		if(field["__pExcelOptions"].hasOwnProperty("reverse")){
			reverse = field["__pExcelOptions"]["reverse"]
		}
		if (reverse){
			dataWidth = parseInt(field["__pExcelOptions"]["dataHeight"]);
			dataHeight = parseInt(field["__pExcelOptions"]["dataWidth"]);
		}else{
			dataWidth = parseInt(field["__pExcelOptions"]["dataWidth"]);
			dataHeight = parseInt(field["__pExcelOptions"]["dataHeight"]);
		}
		//get real width and height
		if(!($.isArray(field.value))){
			dataWidth = 1;
			dataHeight = 1;
		}else{
			if($.isArray(field.value[0])){
				dataHeight = field.value[0].length;
				dataWidth = field.value.length
			}else{
				dataHeight = field.value.length;
				dataWidth = 1;
			}
		}
		hasHeaders = field["__pExcelOptions"]["hasHeaders"];

		//normalize to 2d array
		if (dataWidth == 1 && dataHeight == 1){
			fieldVal = [[fieldVal]]
		}else{
			if (dataWidth == 1){
				fieldVal = [fieldVal];
			}
		}
		//ignore headers if necessary
		iStart = 0;
		if(hasHeaders){
			iStart = 1;
		}
		//iterate all values in array
		for(var i=iStart;i<dataHeight;i++){
			for(var j=0;j<dataWidth;j++){
				theVal = fieldVal[j][i];
				//ignore fields with leftOffset 0
				if(field["__pExcelOptions"]["leftOffset"] == 0){
					continue;
				}
				if(field["__pFieldOptions"].hasOwnProperty("validation")){
					//if field has validation functions
					$.each(field["__pFieldOptions"]["validation"],function(ww,vItem){
						//run appropriate validate function
						if(vItem == "isNumber"){
							errorText = "Field must contain only numeric data";
							if(!isNumber(theVal)&&theVal!=""){
								errors.push(makeError(field,sheet,recordNumber,i,j,theVal,errorText))
							}
						}
						if(vItem == "isInteger"){
							errorText = "Field must be an integer";
							if(!isInteger(theVal)&&theVal!=""){
								errors.push(makeError(field,sheet,recordNumber,i,j,theVal,errorText))
							}
						}
						if(vItem == "isDate"){
							errorText = "Field must contain a date";
							if(!isDate(theVal)&&theVal!=""){
								errors.push(makeError(field,sheet,recordNumber,i,j,theVal,errorText))
							}
						}
					})
				}
				if(field["__pFieldOptions"]["required"]){
					//throw error if field is required and blank
					errorText = "Field is required";
					if(theVal==""){
						errors.push(makeError(field,sheet,recordNumber,i,j,theVal,errorText))
					}
				}
				if(field["__pFieldOptions"]["type"]=="select"){
					//throw error if enum and value is not in list
					errorText = "Field does not contain a valid option ("+field["__pFieldOptions"]["options"].join(",")+")";
					if(field["__pFieldOptions"]["options"].indexOf(theVal)==-1){
						errors.push(makeError(field,sheet,recordNumber,i,j,theVal,errorText))
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
	//convert column number to name e.g 28 = AB
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
function makeError(theField,sheet,recordNumber,i,j,theVal,errorText){
	//make pretty error for excel that states the sheet, recorf, field, cell, value, etc
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
	errorStr += "<strong>Sheet:</strong> "+sheet+","
	errorStr += "<strong>Record:</strong> "+(recordNumber+1)+","
	errorStr += " <strong>Field:</strong> "+fieldName+","
	errorStr += " <strong>Cell:</strong> "+colName(leftOffset+j)+":"+(topOffset+i)+","
	errorStr += " <strong>Value:</strong> "+theVal+","
	errorStr += " <strong>Error:</strong> "+errorText
	return errorStr;
}

Form.prototype.validate = function(){
	//validate field
	var self = this;
	isError = false;
	function validateInner(object,propertyName,add){
		//recursivley iterate over all objects in form
		propertyName = propertyName || "";
	    for (var property in object) {
	        if (object.hasOwnProperty(property)) {
	            if (typeof object[property] == "object" && object[property]!=null){
	            	if(property!='_links'){
	                	validateInner(object[property],property,add);
	                }
	            }
	        }
	    }
		//make sure we are in a field
		if(propertyName.substring(0,2)!="__" && object.constructor.name == "Object" && propertyName != "value" && propertyName != "userUpdated" && propertyName != "userAdded"){
			errors = [];
			if(object["__pFieldOptions"].hasOwnProperty("validation")){
				isExcelField = false;
				if(object.hasOwnProperty("__pExcelOptions")){
					if(object["__pExcelOptions"]["dataHeight"]>1 || object["__pExcelOptions"]["dataWidth"]>1){
						isExcelField = true;
					}
				}

				$.each(object["__pFieldOptions"]["validation"],function(i,vItem){
					//run appropriate validation function
					if(vItem == "isNumber"){
						thisIsError = false;
						//set error text to be set if the validation fails
						errorText = "Field must contain only numeric data";
						//for multi objects iterate all values
						if(object["__pFieldOptions"]["multi"]||isExcelField){
							$.each(object["value"],function(j,val){
								if(object.hasOwnProperty("__pExcelOptions")){
									if(object["__pExcelOptions"].hasOwnProperty("hasHeaders")){
										if(object["__pExcelOptions"]["hasHeaders"] && j==0){
											return true;
										}
									}
								}
								if(!isNumber(val)&&val){
									thisIsError = true;
									isError = true;
								}
							});
						}else{
							//not multi just apply to value
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
						//set error text to be set if the validation fails
						errorText = "Field must be an integer";
	
						if(object["__pFieldOptions"]["multi"]||isExcelField){
							//for multi objects iterate all values
							$.each(object["value"],function(j,val){
								if(object.hasOwnProperty("__pExcelOptions")){
									if(object["__pExcelOptions"].hasOwnProperty("hasHeaders")){
										if(object["__pExcelOptions"]["hasHeaders"] && j==0){
											return true;
										}
									}
								}
								if(!isInteger(val)&&val){
									thisIsError = true;
									isError = true;
								}
							});
						}else{
							//not multi just apply to value
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
						//set error text to be set if the validation fails
						errorText = "Field must contain a date";
						//for multi objects iterate all values
						if(object["__pFieldOptions"]["multi"]||isExcelField){
							$.each(object["value"],function(j,val){
								if(object.hasOwnProperty("__pExcelOptions")){
									if(object["__pExcelOptions"].hasOwnProperty("hasHeaders")){
										if(object["__pExcelOptions"]["hasHeaders"] && j==0){
											return true;
										}
									}
								}
								if(!isDate(val)&&val){
									thisIsError = true;
									isError = true;
								}
							});
						}else{
							//not multi just apply to value
							if(!isDate(object["value"])&&object["value"]){
								thisIsError = true;
								isError = true;
							}
						}
						if(thisIsError){
							errors.push(errorText)
						}
					}
					if(vItem == "isGreaterThan5" && add){
						//just for testing
						thisIsError = false;
						errorText = "Field must be unique";
						if(object["__pFieldOptions"]["multi"]||isExcelField){
							$.each(object["value"],function(j,val){
								if(object.hasOwnProperty("__pExcelOptions")){
									if(object["__pExcelOptions"].hasOwnProperty("hasHeaders")){
										if(object["__pExcelOptions"]["hasHeaders"] && j==0){
											return true;
										}
									}
								}
								if(!restCall("/isUnique/","POST",{"value":val})["result"]){
									thisIsError = true;	
									isError = true;
								}
							});
						}else{
							if(!restCall("/isUnique/","POST",{"value":object["value"]})["result"]){
								thisIsError = true;
								isError = true;
							}
						}
						if(thisIsError){
							errors.push(errorText)
						}
					}
				});
			}
			if(object["__pFieldOptions"]["required"]){
				//if field is required and value is empty throw error
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
				//add errors to field error div
				object.errorDiv.html(errors.join("<br>"))
			}else{
				try{
					object.errorDiv.html("");
				}catch(err){}
			}
		}
	}
	validateInner(self.fd,"",!self.fd.hasOwnProperty("id"));
	if(isError){
		return false;
	}else{
		return true;
	}
}

Form.prototype.clearValues = function(object){
	//recursivly set all values for all fields in form to ""
	var self = this;
    for (var property in object) {
        if (object.hasOwnProperty(property)) {
            if (typeof object[property] == "object" && object[property]!=null){
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
            if (typeof object[property] == "object" && object[property]!=null){
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
	//replace non-alpha characters in a class name with underscore
	var self = this;
	return theClass.replace(/[^A-Za-z0-9]/ig,"_")
}

Form.prototype.removeDunder = function(){
	var self = this;
	removeDunder(self.fd);
}

Form.prototype.removeParentLink = function(field,form,arrayElement){
	//remove parent link returns a red x/dash link that removes the specified field

	//create a tag
	a = $("<a href='javascript:void(0)' class='removeParentLink'><img style='vertical-align:middle;padding:2px;' src='images/delete.gif' width='20' height='20'></a>");
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
			//remove element from DOM
			$(el).parent().remove();
			if(field.changeFunction){
				//run change function
				field.changeFunction()
			}
		}
	})(field,form,arrayElement)
	return a;
}

Form.prototype.addField = function(form,fieldSet,fieldToAdd,insertBeforeName){
	//add a field to form

	//add dunder object to the fieldToAdd JSON
	getDunder(fieldToAdd);
	sendOpts = {}
	if(insertBeforeName){
		//if insertBeforeName is provided add new item to the fieldSet right before that name
		el = fieldSet.getFieldByName(insertBeforeName).holderDiv;
		insertBefore = true;
	}else{
		//otherwise add at the end
		insertBefore = false;
		el = fieldSet.getFieldByName(fieldSet.getFieldNames()[fieldSet.getFieldNames().length-1]).holderDiv;
	}
	if(fieldToAdd["__pFieldOptions"]["type"]=="fieldSet"){
		//if the fieldToAdd is a fieldSet.  Copy the Field and set the fields of the new object
		//to only the first set of fields from the fieldToAdd
		baseField = $.extend(true,{},fieldToAdd);
		baseField["fields"] = [baseField["fields"][0]]
	}else{
		//not a field set. simple field copy
		baseField = $.extend(true,{},fieldToAdd);
	}
	//apply dunder objects to copy
	getDunder(baseField);
	removeParentField(baseField)
	//clear values on copy
	form.clearValues(baseField)
	//determine how to push fields onto target fieldSet (whether it is multi or not)
	if(fieldSet.fields){
		fieldSet.fields.push(baseField)
	}else{
		fieldSet.push(baseField)
	}
	//attach parent field at the appropriate level
	if(fieldSet.parentField){
		attachParentField(fieldSet.parentField)	
	}else{
		attachParentField(fieldSet)	
	}
	attachFieldByName(fieldSet)

	attachGetValArray(baseField)
	//insert field to page
	if(insertBefore){
		$(form.displayField(baseField,sendOpts)).insertBefore($(el));
	}else{
		$(form.displayField(baseField,sendOpts)).insertAfter($(el));
	}
}

function getPlusText(field){
	//when a green plus button is added the text returned by this function is added to it
	thisName = "";
	if(field.hasOwnProperty("__pFieldOptions")){
		if(field["__pFieldOptions"].hasOwnProperty("name")){
			thisName = field["__pFieldOptions"]["name"];
		}
	}
	switch(thisName){
		case "Measurement Labels":
			return "Add Measurement Label"
		case "Assay Condition Fieldset":
			return "Add Condition"
		case "Assay Component Role":
			return "Add Component Role"
		case "Assay Component Fields":
			return "Add Assay Component"
		case "Assay Component Type Fields":
			return "Add additional type for this component"
		case "Assay Component Role Fieldset":
			return "Add additional role for this component"
		case "ext references fieldset":
			return "Add another external reference"
		case "Repeat Fixed Fields":
			return "Add Repeat Fixed"
		case "Update Offset Fields":
			return "Add Field Offset Update"
		
		default:
			return ""
	}
}

Form.prototype.addLink = function(field,form){
	//green plus button for adding form elements

	//create green + button
	a = $("<a href='javascript:void(0)' style='color:black;text-decoration:none;'><img style='vertical-align:middle;padding:2px;' src='images/add.gif' width='20' height='20'>"+getPlusText(field)+"</a>");
	a.addClass("addLink")
	a[0].onclick = (function(field,form){
		return function(){
			sendOpts = {}
			sendOpts["noNest"] = true;
			sendOpts["changeFunction"] = field.changeFunction;
			el = this;
			if(field["__pFieldOptions"]["type"]=="fieldSet"){
				//set original field so that display field can get stuff from it like change functions
				sendOpts["originalField"] = field;
				//make a copy of the field
				baseField = $.extend(true,{},field);
				//clear values
				form.clearValues(baseField)
				//unnest fields on fieldSet copy so they can be pushed onto the fields array of the parent field list
				baseField["fields"] = [baseField["fields"][0]]
				for (var i=0;i<baseField["fields"][0].length;i++){
					if(baseField["fields"][0][i].hasOwnProperty("fields")){
						baseField["fields"][0][i]["fields"] = [baseField["fields"][0][i]["fields"][0]]
					}
				}
				field["fields"].push(baseField["fields"][0])
				attachParentField(field)
			}else{
				//copy field
				baseField = $.extend(true,{},field);
				//clear value and add parent field
				baseField["value"] = "";
				baseField.parentField = field.parentField
			}
			//attach functions
			attachFieldByName(baseField)
			attachGetValArray(baseField)
			//display field at appropriate place
			$(form.displayField(baseField,sendOpts)).insertBefore($(el));
			
			//run change and afterShow functions
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
	//returns value in array if it is not already
	var self = this;
	if($.isArray(theVal)){
		return theVal;
	}else{
		if(typeof theVal === "string" || typeof theVal === "number"){
			return [theVal];
		}else{
			return [];
		}
	}
}

//better version of getCache that can preload multiple forms by taking and array
//saves 2 seconds on heatmap with 45 forms
function getCache(ids){
	//the cache object is a client side memory cache of form and dunder objects
	//the object is a javascript object.  The keys are ids and the values are the form or dunder objects
	//when you call getCache(id) if the id exists of the form or dunder object it is returned to you
	//without going to the server.  Otherwise it is gotten from the server and added to the cache

	//make array if not array
	single = false;
	if(!$.isArray(ids)){
		ids = [ids];
		single = true
	}
	rForms = [];
	newIds = []
	//find the ids that are not in the cache i.e. ids we need to get
	$.each(ids,function(i,theId){
		theId = parseInt(theId);	
		if(cache.hasOwnProperty(theId)){
			rForms.push(JSON.parse(JSON.stringify(cache[theId])));
		}else{
			newIds.push(theId)
		}
	});

	//if there are ids we need to get to put in the cache, get them
	if(newIds.length){
		r = restCall("/loadForms/","POST",{"ids":newIds})["forms"];
		L = [];
		$.each(r,function(i,thisForm){
			cache[thisForm.id] = thisForm;
			rForms.push(thisForm)
			dunderIds = getDunderIds(thisForm);
			$.each(dunderIds,function(i,dunderId){
				if(!cache.hasOwnProperty(dunderId)){
					L.push(dunderId);
				}
			})

		});
		//load dunders into cachce from all dunder ids in all the forms we just got
		if(L.length){
			dunders = restCall("/loadDunders/","POST",{"ids":L});
			$.each(dunders,function(q,dunder){
				cache[dunder.id] = dunder	
			})
		}
	}
	if(single){
		return rForms[0];
	}else{
		return rForms;
	}
}

cache = {};

function selectOfType(typeIds){
	//used for admin creates the options object necessary to show a select box of object types
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
	//if FIELD.value == value show the fieldName otherwise hide it
	if(field.parentField.getFieldByName(fieldName)){
		if(field['value']==value){
			field.parentField.getFieldByName(fieldName).show()
		}else{
			field.parentField.getFieldByName(fieldName).hide()
		}
	}
}

function ifValRequireSibling(field,values,fieldName){
	//if the field value is any of the values the fieldName is made to be required
	//otherwise field is made not required
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
	//if the field value is any of the values the fieldName is made to be required and shown
	//otherwise field is made not required and hidden
	if(!$.isArray(values)){
		values = [values]
	}
	for(var i=0;i<values.length;i++){
		values[i] = values[i].toString().toLowerCase();
	}
	if(field.parentField.getFieldByName(fieldName)){
		f1 = field.parentField.getFieldByName(fieldName)
		foundOne = false;
		$.each(values,function(i,value){
			if(field['value'].toString().toLowerCase()==value){
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


function hideRepeatFields(form){
	//used for upload template logic
	form.getFieldByName2('Repeat Width').hide();
	form.getFieldByName2('Repeat Height').hide();
	
	try{
		form.getFieldByName2('End Special').value = false;
		form.getFieldByName2('End Special').theO.prop("checked",false);
	}catch(err){}

	form.getFieldByName2('End Special').hide();
	form.getFieldByName2('End Top Offset').hide();
	form.getFieldByName2('End Left Offset').hide();
	form.getFieldByName2('End Regex').hide();
}

function showRepeatFixedFields(form){
	//used for upload template logic
	if(form.getFieldByName2('Repeat Fixed Fields').fields){
		$.each(form.getFieldByName2('Repeat Fixed Fields').fields,function(i,fieldSet){
			fieldSet.getFieldByName('Number').require();
			fieldSet.getFieldByName('Top Offset').require();
			fieldSet.getFieldByName('Left Offset').require();
			fieldSet.getFieldByName('Repeat Height').require();
			fieldSet.getFieldByName('Repeat Width').require();
			if(fieldSet.getFieldByName('Update Offset')){
				if(fieldSet.getFieldByName('Update Offset').value){
					$.each(fieldSet.getFieldByName('Update Offset Fields').fields,function(j,fieldSet2){
						fieldSet2.getFieldByName('Field Name').require();
						fieldSet2.getFieldByName('Type').require();
						fieldSet2.getFieldByName('Top Offset').require();
						fieldSet2.getFieldByName('Left Offset').require();
					})
					fieldSet.getFieldByName('Update Offset Fields').show();
					fieldSet.getFieldByName('Update Offset Fields').labelDiv.html("");
				}else{
					$.each(fieldSet.getFieldByName('Update Offset Fields').fields,function(j,fieldSet2){
						fieldSet2.getFieldByName('Field Name').hide();
						fieldSet2.getFieldByName('Type').hide();
						fieldSet2.getFieldByName('Top Offset').hide();
						fieldSet2.getFieldByName('Left Offset').hide();
					})
					fieldSet.getFieldByName('Update Offset Fields').hide()
				}
			}
		});
	}
	form.getFieldByName2('Repeat Fixed Fields').show();
}

function hideRepeatFixedFields(form){
	//used for upload template logic
	if(form.getFieldByName2('Repeat Fixed Fields').fields){
		$.each(form.getFieldByName2('Repeat Fixed Fields').fields,function(i,fieldSet){
			fieldSet.getFieldByName('Number').hide();
			fieldSet.getFieldByName('Top Offset').hide();
			fieldSet.getFieldByName('Left Offset').hide();
			fieldSet.getFieldByName('Repeat Height').hide();
			fieldSet.getFieldByName('Repeat Width').hide();
			if(fieldSet.getFieldByName('Update Offset')){
				$.each(fieldSet.getFieldByName('Update Offset Fields').fields,function(j,fieldSet2){
					fieldSet2.getFieldByName('Field Name').hide();
					fieldSet2.getFieldByName('Type').hide();
					fieldSet2.getFieldByName('Top Offset').hide();
					fieldSet2.getFieldByName('Left Offset').hide();
				})
				fieldSet.getFieldByName('Update Offset Fields').hide()
			}
		});
	}
	form.getFieldByName2('Repeat Fixed Fields').hide();
}

function uploadTemplateLogic(form){
	//logic to handle which fields show up on the upload template
	//it was too complicated to keep attached to the object so the object now just calls this function
	form.getFieldByName2 = function(fieldName){
		r = form.getFieldByName(fieldName);
		if (r===false){
			if(fieldName=="Field Type"){
				return{
					value:"excel"
				}
			}else{
				return {
					hide: function(){
						return false
					},
					show: function(){
						return false
					},
					require: function(){
						return false
					},
					value:false,
					fields:false
				}
			}
		}else{
			return r;
		}
	}
	if(form.getFieldByName2('Field Type').value == ""){
		$.each(form.getFieldNames(),function(i,fieldName){
			if(fieldName!="Field Type"){
				form.getFieldByName2(fieldName).hide();
			}
		});
	}else{
		$.each(form.getFieldNames(),function(i,fieldName){
			form.getFieldByName2(fieldName).show();
		});
		form.getFieldByName2("Name").require();
	}
	if(['excel','system','aggregate'].indexOf(form.getFieldByName2('Field Type').value.toString().toLowerCase())!=-1){
		form.getFieldByName2('Result Definition').require();
		form.getFieldByName2("Data Width").require();
		form.getFieldByName2("Data Height").require();
		if(form.getFieldByName2('Allow Other Values').value){
			form.getFieldByName2("Other Values Regex").show();
		}else{
			form.getFieldByName2("Other Values Regex").hide();
		}
	}else{
		form.getFieldByName2('Result Definition').hide();
		form.getFieldByName2("Data Width").hide();
		form.getFieldByName2("Data Height").hide();
		form.getFieldByName2("Allow Other Values").hide();
		form.getFieldByName2("Other Values Regex").hide();
	}
	if(['excel'].indexOf(form.getFieldByName2('Field Type').value.toString().toLowerCase())!=-1){
		form.getFieldByName2('Top Offset').require();
		form.getFieldByName2('Left Offset').require();
		form.getFieldByName2('Other File').show();
		form.getFieldByName2('Reverse').show();
		if(form.getFieldByName2('Other File').value){
			form.getFieldByName2("Other File Name").require();
			form.getFieldByName2("Other File Tab Name").require();
		}else{
			form.getFieldByName2("Other File Name").hide();
			form.getFieldByName2("Other File Tab Name").hide();
		}
		form.getFieldByName2('Repeat').show();
		form.getFieldByName2('Repeat Fixed').show();
		if(form.getFieldByName2('Repeat').value){
			form.getFieldByName2('Repeat Width').require();
			form.getFieldByName2('Repeat Height').require();
			form.getFieldByName2('End Special').show();
			if(form.getFieldByName2('End Special').value){
				form.getFieldByName2('End Top Offset').require();
				form.getFieldByName2('End Left Offset').require();
				form.getFieldByName2('End Regex').show();
			}else{
				form.getFieldByName2('End Top Offset').hide();
				form.getFieldByName2('End Left Offset').hide();
				form.getFieldByName2('End Regex').hide();
			}

			hideRepeatFixedFields(form);
		}else{
			hideRepeatFields(form);
		}

		if(form.getFieldByName2('Repeat Fixed').value){
			showRepeatFixedFields(form);
		}else{
			hideRepeatFixedFields(form);
		}

		form.getFieldByName2('H Skips').show()
		form.getFieldByName2('W Skips').show()

		form.getFieldByName2('Start Special').show();
		if(form.getFieldByName2('Start Special').value){
			form.getFieldByName2('Start Right Step').require();
			form.getFieldByName2('Start Down Step').require();
			form.getFieldByName2('Start Top Offset').require();
			form.getFieldByName2('Start Left Offset').require();
			form.getFieldByName2('Start Regex').show();
		}else{
			form.getFieldByName2('Start Right Step').hide();
			form.getFieldByName2('Start Down Step').hide();
			form.getFieldByName2('Start Top Offset').hide();
			form.getFieldByName2('Start Left Offset').hide();
			form.getFieldByName2('Start Regex').hide();
		}
		form.getFieldByName2('Has Headers').show();
	}else{
		form.getFieldByName2('Top Offset').hide();
		form.getFieldByName2('Left Offset').hide();
		form.getFieldByName2('Repeat').hide();
		form.getFieldByName2('Repeat Fixed').hide();
		hideRepeatFixedFields(form);
		form.getFieldByName2('Has Headers').hide();
		form.getFieldByName2('Repeat Width').hide();
		form.getFieldByName2('Repeat Height').hide();

		form.getFieldByName2('H Skips').hide()
		form.getFieldByName2('W Skips').hide()

		form.getFieldByName2('Start Special').hide();
		form.getFieldByName2('Start Right Step').hide();
		form.getFieldByName2('Start Down Step').hide();
		form.getFieldByName2('Start Top Offset').hide();
		form.getFieldByName2('Start Left Offset').hide();
		form.getFieldByName2('Start Regex').hide();

		form.getFieldByName2('End Special').hide();
		form.getFieldByName2('End Top Offset').hide();
		form.getFieldByName2('End Left Offset').hide();
		form.getFieldByName2('End Regex').hide();

		form.getFieldByName2("Other File").hide();
		form.getFieldByName2("Other File Name").hide();
		form.getFieldByName2("Other File Tab Name").hide();

		form.getFieldByName2("Reverse").hide();

	}

	if(['aggregate'].indexOf(form.getFieldByName2('Field Type').value.toString().toLowerCase())!=-1){
		form.getFieldByName2('Field Names').require();
		form.getFieldByName2('Operation').require();
		form.getFieldByName2("Data Width").hide();
		form.getFieldByName2("Data Height").hide();
		form.getFieldByName2("Decimal Places").hide();
		form.getFieldByName2("Scientific Notation").hide();
		form.getFieldByName2("Required").hide();
	}else{
		form.getFieldByName2('Field Names').hide();
		form.getFieldByName2('Operation').hide();
	}

	if(['display'].indexOf(form.getFieldByName2('Field Type').value.toString().toLowerCase())!=-1){
		form.getFieldByName2('Group Field Names').require();
	}else{
		form.getFieldByName2('Group Field Names').hide();
	}
	
	if(form.getFieldByName2('Show in FT').value){
		form.getFieldByName2('FT Mode').require();
	}else{
		form.getFieldByName2('FT Mode').hide();
	}
}

function ifValShowSibling2(field,values,fieldName){
	//if field value is any of values the fieldName is shown.  otherwise fieldName is hidden
	if(!$.isArray(values)){
		values = [values]
	}
	for(var i=0;i<values.length;i++){
		values[i] = values[i].toString().toLowerCase();
	}
	if(field.parentField.getFieldByName(fieldName)){
		f1 = field.parentField.getFieldByName(fieldName)
		foundOne = false;
		$.each(values,function(i,value){
			if(field['value'].toString().toLowerCase()==value){
				foundOne = true;
				f1.show();
			}
		});
		if(!foundOne){
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
	//hide all fields at the same level in the form except the field names in the exceptFields array
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
	//hides all sibling fields after the specified fieldname
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
	//clear the value of all sibling fields except for the field names list in the exceptFields array
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
	//if field value does not equal value fieldName is shown. otherwise it is hidden
	if(field.parentField.getFieldByName(fieldName)){
		if(field['value']!=value){
			field.parentField.getFieldByName(fieldName).show()
		}else{
			field.parentField.getFieldByName(fieldName).hide()
		}
	}
}

function zip(a,b){
	//([a1,a2,a3],[b1,b2,b3]) -> [[a1,b1],[a2,b2],[a3,b3]]
	var c = []
	for(var i=0;i<a.length;i++){
		c.push([a[i],b[i]]);
	}
	return c;
}


function saveResultSet(form,form2){
p = new Form(getCache(form.fd.parentId));
uploadTemplateId = p.getFieldByName('upload template').value;
uploadTemplate = new Form(getCache(uploadTemplateId));
analysisFunctionIds = p.getFieldByName('Analysis Functions').value;
analysisFunctions = [];
$.each(analysisFunctionIds,function(i,analysisFunctionId){
  if(analysisFunctionId){
    x = new Form(getCache(analysisFunctionId));
    analysisFunctions.push(x.getFieldByName('function').value)
  }
});

var f = new Form(getCache(parseInt(resultTypeId)));
thisO = JSON.parse(f.getFieldByName('JSON').value);
thisO.typeId = parseInt(resultTypeId);
var rs = new Form(thisO);



$.each(form.fd.fields,function(i,resultSetField){
  if(resultSetField["__pFieldOptions"]["name"].toLowerCase()!="name" && resultSetField["__pFieldOptions"]["name"].toLowerCase()!="file" && resultSetField["__pFieldOptions"]["type"] != "file"){
    rs.fd.fields.push(resultSetField);
  }
})

fields = JSON.parse(uploadTemplate.getFieldByName('JSON').value);
$.each(fields,function(j,field){
  rs.fd.fields.push(field);
})
if (form.fd.id == null)
{
	form.fd.id = restCall("/getNextId/","POST",{})["id"];
}
    var rs = new Form(rs.fd);
    rs.fd.parentId = form.fd.id;

allErrors = [];
allForms = [];

repeatFiles = []
allFiles = {}
if(uploadTemplate.getFieldByName('File Fields')){
  $.each(uploadTemplate.getFieldByName('File Fields').fields,function(yy,arrFs){
    f = form.getFieldByName(arrFs.getFieldByName('File Name').value)
    X = {};
    fileId = f.value;
    X["fileId"] = fileId;
    X["fileName"] = f["__pFieldOptions"]["name"];
    tabName = arrFs.getFieldByName('tab name').value;
    if(arrFs.getFieldByName('regular expression')){
      isRegEx = arrFs.getFieldByName('regular expression').value;
    }else{
      isRegEx = false;
    }
    X["tabName"] = tabName;
    X["isRegEx"] = isRegEx;
    X["tabNames"] = restCall("/getTabNames/","POST",X);
    if(arrFs.getFieldByName('Parse Repeats').value){
      repeatFiles.push(X);
    }
    allFiles[X["fileName"]] = X
  })
}else{
  X = {};
  fileId = form.getFieldByName('file').value;
  X["fileId"] = fileId;
  tabName = uploadTemplate.getFieldByName('tab name').value;
  if(uploadTemplate.getFieldByName('regular expression')){
    isRegEx = uploadTemplate.getFieldByName('regular expression').value;
  }else{
    isRegEx = false;
  }
  X["tabName"] = tabName;
  X["isRegEx"] = isRegEx;
  X["tabNames"] = restCall("/getTabNames/","POST",X);
  repeatFiles.push(X)
  allFiles["default"] = X
}

$.each(repeatFiles,function(q,thisFile){
  $.each(thisFile["tabNames"],function(k,tabName){
    D = {};
    D["fileId"] = thisFile["fileId"];
    D["rs"] = rs.fd;
    D["tabName"] = tabName;
    r = restCall("/getNumResults/","POST",D);
    if(r.hasOwnProperty("errors")){
      $('#formErrors').html(r["errors"].join("<br>"));
      alert('Error processing Result Set file.  Please review the error messages and try again');
      return "error"
    }
    numResults = r["num"];

    L = [];
    for(var i=0;i<numResults;i++){
      item = $.extend(true,{},rs.fd);
      L.push(item)
    }
    D = {};
    D["forms"] = L;
    D["fileId"] = thisFile["fileId"];
    D["tabName"] = tabName;
    D["isRegEx"] = thisFile["isRegEx"];
    D["allFiles"] = allFiles;
    r = restCall("/parseResults/","POST",D);

    $.each(r["forms"],function(qq,form2){
      form2.sheet = tabName;
      allErrors = $.merge(allErrors,excelValidate(qq,form2))
      allForms.push(form2)
    })
  });
});


if(allErrors.length){
  $('#formErrors').html(allErrors.join("<br/>"));
  alert('Error processing Result Set file.  Please review the error messages and try again');
  return "error";
}else{
  forms = [];
  $.each(allForms,function(i,form2){
    forms.push(new Form(form2));
  });

  $.each(forms,function(i,form2){
    $.each(analysisFunctions,function(i,analysisFunction){
      tempF = new Function("allResults","thisResult","resultSet",analysisFunction);
      thisErr=tempF(forms,form2,form);
      if($.isArray(thisErr)){
        allErrors = $.merge(allErrors,thisErr)
      }
    })
  });

	//$.each(forms,function(i,form2){
	//	thisErr = AFunction(forms,form2,form);
	//	if($.isArray(thisErr)){
	//	allErrors = $.merge(allErrors,thisErr)
	//	}
	//});

  if(allErrors.length){
    $('#formErrors').html(allErrors.join("<br/>"));
    alert('Error processing Result Set file.  Please review the error messages and try again');
    return "error";
  }
  $.each(forms,function(i,form2){
    fixNumbers(form2.fd);
    fixSort(form2.fd);
    form2.removeDunder();
    newId = saveNew(form2.fd);


  });
}
}

function saveTemplate(field,form){
if(form.getFieldByName('File Fields')){
  L2 = [];
  $.each(form.getFieldByName('File Fields').fields,function(i,f){
    b = {}
    b["__parent"] = {};
    b["__pFieldOptions"] = {};
    b["__pDefOptions"] = {};
    b["__pExcelOptions"] = {};
    b["__pDisplayOptions"] = {};
    b["__ftOptions"] = {};

    b["__pFieldOptions"]["name"] = f.getFieldByName('File Name').value;
    b["__parent"]["name"] = f.getFieldByName('File Name').value;
    b["__pFieldOptions"]["type"] = "file";
    b["__pFieldOptions"]["multi"] = false;
    b["__pFieldOptions"]["required"] = true;
    b["__pExcelOptions"]["tabName"] = f.getFieldByName('Tab Name').value;
    b["__pExcelOptions"]["regExFlag"] = f.getFieldByName('Regular Expression').value;
    b["__pExcelOptions"]["parseRepeats"] = f.getFieldByName('Parse Repeats').value;

    newId = saveNew(b);
    L2.push({"_dunderSource":newId})
  })
  form.getFieldByName('FILEJSON').value = JSON.stringify(L2)
}

L2 = [];

var attFields = form.getFieldByName('Attachment Fields');
if (attFields) {
    var L3 = [];
	$.each(attFields.fields, function (i, f) {

		var attName = f.getFieldByName('Attachment Name').value;
		var b = {};
		b["__parent"] = {};
		b["__pFieldOptions"] = {};
		b["__pDefOptions"] = {};
		b["__pExcelOptions"] = {};
		b["__pDisplayOptions"] = {};
		b["__ftOptions"] = {};

		b["__pFieldOptions"]["name"] = attName;
		b["__parent"]["name"] = attName;
		b["__pFieldOptions"]["type"] = "file";
		b["__pFieldOptions"]["multi"] = false;
		b["__pFieldOptions"]["required"] = false;

		var newId = saveNew(b);
		L3.push({ "_dunderSource": newId });
	});
	form.getFieldByName('ATTACHMENTJSON').value = JSON.stringify(L3);

	L3 = [];
}



$.each(form.getFieldByName('fields').fields,function(i,f){
  b = {}
  b["__parent"] = {};
  b["__pFieldOptions"] = {};
  b["__pDefOptions"] = {};
  b["__pExcelOptions"] = {};
  b["__pDisplayOptions"] = {};
  b["__ftOptions"] = {};
  if(f.getFieldByName('result definition').value){
    rd = new Form(getCache(f.getFieldByName('result definition').value));
    b["__pFieldOptions"]["name"] = rd.getFieldByName('name').value;
    b["__parent"]["name"] = rd.getFieldByName('name').value;
    b["__pFieldOptions"]["multi"] = f.getFieldByName('multi').value;
    b["__pFieldOptions"]["required"] = f.getFieldByName('required').value;
  }else{
    b["__pFieldOptions"]["name"] = f.getFieldByName('name').value;
    b["__parent"]["name"] = f.getFieldByName('name').value;
    if (f.getFieldByName('data height').value>1 ||f.getFieldByName('data width').value > 1){
      b["__pFieldOptions"]["multi"] = true;
    }else{
      b["__pFieldOptions"]["multi"] = false;
    }
    b["__pFieldOptions"]["required"] = f.getFieldByName('required').value;
  }

  if(f.getFieldByName('Hide in Result')){
    if(f.getFieldByName('Hide in Result').value){
      b["__parent"]["hidden"] = true;
      b["__pFieldOptions"]["hidden"] = true;
    }
  }

  if(f.getFieldByName('Show in FT')){
    if(f.getFieldByName('Show in FT').value){
      b["__ftOptions"]["mode"] = rd.getFieldByName('FT Mode').value;
      b["__ftOptions"]["send"] = true;
    }else{
      b["__ftOptions"]["send"] = false;
    }
  }else{
      b["__ftOptions"]["mode"] = "default";
      b["__ftOptions"]["send"] = true;
  }

  if(f.getFieldByName('H Skips')){
    L = [];
    $.each(f.getFieldByName('H Skips').value,function(k,skip){
      if(skip){
        L.push(parseInt(skip));
      }
    });
    b["__pExcelOptions"]["hSkips"] = JSON.stringify(L)
  }

  if(f.getFieldByName('W Skips')){
    L = [];
    $.each(f.getFieldByName('W Skips').value,function(k,skip){
      if(skip){
        L.push(parseInt(skip));
      }
    });
    b["__pExcelOptions"]["wSkips"] = JSON.stringify(L)
  }

  if(f.getFieldByName('Field Type')){
    b["__pExcelOptions"]["uploadTemplateType"] = f.getFieldByName('Field Type').value;
    if(f.getFieldByName('Field Type').value.toLowerCase()=='excel'){
      b["__pFieldOptions"]["parseExcel"] = true;
    }else{
      b["__pFieldOptions"]["parseExcel"] = false;
    }
    if(f.getFieldByName('Field Type').value.toLowerCase()=='aggregate'){
      b["__pFieldOptions"]["parseExcel"] = true;
      b["__pFieldOptions"]["aggregate"] = true;
      b["__pFieldOptions"]["aggregateFields"] = f.getFieldByName('Field Names').value;
      b["__pFieldOptions"]["aggregateOperation"] = f.getFieldByName('Operation').value;
    }else{
      b["__pFieldOptions"]["aggregate"] = false;
    }
  }else{
    b["__pFieldOptions"]["parseExcel"] = true;
  }
  try{
    theType = rd.getFieldByName('type').value;
  }catch(err){
    theType = "text";
  }
  b["__pDefOptions"]["type"] = theType;
  if(f.getFieldByName('Group Field Names')){
    b["__pDefOptions"]["groupFieldNames"] = f.getFieldByName('Group Field Names').value;
  }
  if(theType=="text" || theType=="real number" || theType=="integer" || theType=="percentage"){
    b["__pFieldOptions"]["type"] = "text";
    if(theType=="real number" || theType=="percentage"){
      b["__pFieldOptions"]["validation"] = ["isNumber"];
    }
    if(theType=="integer"){
      b["__pFieldOptions"]["validation"] = ["isInteger"];
    }
  }
  if(theType=="bool"){
    b["__pFieldOptions"]["type"] = "checkbox";
  }
  if(theType=="curve"){
    b["__pFieldOptions"]["type"] = "curve";
  }
  if(theType=="heat map"){
    b["__pFieldOptions"]["type"] = "heatMap";
  }
  if(theType=="drop down"){
    b["__pFieldOptions"]["type"] = "select";
    b["__pFieldOptions"]["options"] = rd.getFieldByName('options').value;
  }
  if(theType=="date"){
    b["__pFieldOptions"]["type"] = "date";
    b["__pFieldOptions"]["validation"] = ["isDate"];
  }

  if(f.getFieldByName('Start Special')){
    b["__pExcelOptions"]["startSpecial"] = f.getFieldByName('Start Special').value;
    b["__pExcelOptions"]["startRightStep"] = f.getFieldByName('Start Right Step').value;
    b["__pExcelOptions"]["startDownStep"] = f.getFieldByName('Start Down Step').value;
    b["__pExcelOptions"]["startTopOffset"] = f.getFieldByName('Start Top Offset').value;
    b["__pExcelOptions"]["startLeftOffset"] = f.getFieldByName('Start Left Offset').value;
    b["__pExcelOptions"]["startRegex"] = f.getFieldByName('Start Regex').value;
  }

  if(f.getFieldByName('Other File')){
    b["__pExcelOptions"]["otherFile"] = f.getFieldByName('Other File').value;
    b["__pExcelOptions"]["otherFileName"] = f.getFieldByName('Other File Name').value;
    b["__pExcelOptions"]["otherFileTabName"] = f.getFieldByName('Other File Tab Name').value;
  }

  if(f.getFieldByName('End Special')){
    if(f.getFieldByName('End Special').value){
      b["__pExcelOptions"]["endSpecial"] = f.getFieldByName('End Special').value;
      b["__pExcelOptions"]["endTopOffset"] = f.getFieldByName('End Top Offset').value;
      b["__pExcelOptions"]["endLeftOffset"] = f.getFieldByName('End Left Offset').value;
      b["__pExcelOptions"]["endRegex"] = f.getFieldByName('End Regex').value;
    }
  }

  if(f.getFieldByName('Reverse')){
    b["__pExcelOptions"]["reverse"] = f.getFieldByName('Reverse').value;
  }

  if(f.getFieldByName('Repeat Fixed')){
    if(f.getFieldByName('Repeat Fixed').value){
      b["__pExcelOptions"]["repeatFixed"] = f.getFieldByName('Repeat Fixed').value;
      L = [];
      $.each(f.getFieldByName('Repeat Fixed Fields').fields,function(k,fs){
        D = {};
        D["number"] = fs.getFieldByName('Number').value;
        D["topOffset"] = fs.getFieldByName('Top Offset').value;
        D["leftOffset"] = fs.getFieldByName('Left Offset').value;
        D["repeatHeight"] = fs.getFieldByName('Repeat Height').value;
        D["repeatWidth"] = fs.getFieldByName('Repeat Width').value;
        D["updateOffsets"] = [];
        if(fs.getFieldByName('Update Offset')){
          if(fs.getFieldByName('Update Offset').value){
            $.each(fs.getFieldByName('Update Offset Fields').fields,function(m,fs2){
              D2 = {};
              D2["name"] = fs2.getFieldByName('Field Name').value;
              D2["type"] = fs2.getFieldByName('Type').value;
              D2["topOffset"] = fs2.getFieldByName('Top Offset').value;
              D2["leftOffset"] = fs2.getFieldByName('Left Offset').value;
              D["updateOffsets"].push(D2);
            });
          }
        }
        L.push(D);
      });
      console.log("ccc",JSON.stringify(L))
      b["__pExcelOptions"]["repeatFixedFields"] = JSON.stringify(L);
    }
  }

  if(f.getFieldByName('Allow Other Values')){
    b["__pExcelOptions"]["allowOtherValues"] = f.getFieldByName('Allow Other Values').value;
    b["__pExcelOptions"]["otherValuesRegex"] = f.getFieldByName('Other Values Regex').value;
  }

  b["__pExcelOptions"]["topOffset"] = f.getFieldByName('top offset').value;
  b["__pExcelOptions"]["leftOffset"] = f.getFieldByName('left offset').value;
  b["__pExcelOptions"]["repeat"] = f.getFieldByName('repeat').value;
  repeatHeight = f.getFieldByName('repeat height').value;
  if(!repeatHeight){
    repeatHeight = 0;
  }
  repeatWidth = f.getFieldByName('repeat width').value;
  if(!repeatWidth){
    repeatWidth = 0;
  }

  b["__pExcelOptions"]["repeatHeight"] = repeatHeight;
  b["__pExcelOptions"]["repeatWidth"] = repeatWidth;
  b["__pExcelOptions"]["dataHeight"] = f.getFieldByName('data height').value;
  b["__pExcelOptions"]["dataWidth"] = f.getFieldByName('data width').value;
  b["__pExcelOptions"]["hasHeaders"] = f.getFieldByName('has headers').value;
  b["__pDisplayOptions"]["decimalPlaces"] = f.getFieldByName('decimal places').value;
  b["__pDisplayOptions"]["scientificNotation"] = f.getFieldByName('scientific notation').value;
  //b["__pFieldOptions"]["inTable"] = f.getFieldByName('show in table').value;
  //b["__pFieldOptions"]["isTableLink"] = f.getFieldByName('table link').value;
  newId = saveNew(b);
  L2.push({"_dunderSource":newId})
})
form.getFieldByName('JSON').value = JSON.stringify(L2)
}

  function AFunction(allResults,thisResult,resultSet){
  // Cell EC50 assay
//
// The average background is subtracted from all signals, and the background-subtracted
// average of DMSO controls is set as 100% activity, while the background is set
// as 0% activity. The % activity of each sample is calculated using the
// following formula:
//
// % Activity = {{ Signal - Average Background } / { DMSO Average - Average Background }} * 100
//
// The curve fits will be performed by Arxspan Assay with 4-parameter (sigmoidal) fit using
// the following formula:
//
// Y = Bottom + (Top - Bottom) / (1 + 10 ^ ((LogIC50 - X) * HillSlope))
//
// Constraints: Bottom == 0; Top < 120
//
// Curve fits will be performed only when the % Activity at the highest concentration
// of compound is less than 65%
//

var getAssayResultFloat = function(theNumber, howManyDecimals)
{
	var numDigits = howManyDecimals + 4;
	var regExp = new RegExp('^-?\\d*\\.?0*\\d{0,'+numDigits+'}');
	var match = theNumber.toFixed(20).match(regExp)[0];
	return decimalAdjust('round', theNumber, -(match.length - 4));
}

var decimalAdjust = function(type, value, exp) {
    // If the exp is undefined or zero...
    if (typeof exp === 'undefined' || +exp === 0) {
        return Math[type](value);
    }
    value = +value;
    exp = +exp;
    // If the value is not a number or the exp is not an integer...
    if (isNaN(value) || !(typeof exp === 'number' && exp % 1 === 0)) {
        return NaN;
    }
    // Shift
    value = value.toString().split('e');
    value = Math[type](+(value[0] + 'e' + (value[1] ? (+value[1] - exp) : -exp)));
    // Shift back
    value = value.toString().split('e');
    return +(value[0] + 'e' + (value[1] ? (+value[1] + exp) : exp));
}

// Utility function for loading data to be displayed as exponents
var loadExp = function(valArray, concArray)
{
	// This is the sample concentration column
	for(var j=0; j < valArray.length; j++)
	{
		var num = Number.parseFloat(valArray[j]);
		if(!isNaN(num))
		{
			concArray.push(num);
			valArray[j] = num.toExponential(2);

			if(highConc['value'] < num)
			{
				highConc['index'] = j;
				highConc['value'] = num;
			}
		}
		else
		{
			concArray.push(valArray[j]);
		}
	}
}

// Sample data
var cpdSignal = thisResult.getFieldByName('Compound Signal').value;
if(!cpdSignal || cpdSignal.length <= 0)
	return;

// setup the serial dilutions
var topConc = parseFloat(thisResult.getFieldByName('Top Concentration (uM)').value);
var dilutionFactor = parseFloat(thisResult.getFieldByName('Dilution Factor').value);
var sampleConcentrations = [];
for(var i = 0; i < cpdSignal.length; i++)
{
	var conc = topConc;
	if(i > 0)
		conc = getAssayResultFloat(sampleConcentrations[i-1] * dilutionFactor, 4);

	sampleConcentrations.push(conc);
}

// Samples run from low to high concentration
sampleConcentrations = sampleConcentrations.reverse();

// Calculate % Activity
var background = 0;
var activities = [];
var dmsoSignal = thisResult.getFieldByName('DMSO Signal').value;
var controlSignal = thisResult.getFieldByName('Control Signal').value;
thisResult.getFieldByName('DMSO Percent Activity').value = decimalAdjust('round', (dmsoSignal / controlSignal) * 100, -2);

for(var i in cpdSignal)
{
	var pctInh = (cpdSignal[i] / controlSignal) * 100;
	pctInh = decimalAdjust('round', pctInh, -2);
	activities.push(pctInh);
}

// We will use log concentration on the x-axis so only calculate it once
var logConc = JSON.parse(JSON.stringify(sampleConcentrations));
for(var conc in logConc)
	logConc[conc] = Math.log10(logConc[conc]);

// Get initial parameters
var initialParams = [];
var initialParamList = ['Sigmoidal Lower Bound Initial Value','Hill Slope Initial Value','Inflection Point Initial Value','Sigmoidal Upper Bound Initial Value'];
for(var param in initialParamList)
{
	if(thisResult.getFieldByName(initialParamList[param]))
	{
		var val = thisResult.getFieldByName(initialParamList[param]).value;
		var num = Number.parseFloat(val);
		if(!isNaN(num))
			initialParams.push(num);
		else
			initialParams.push(undefined);
	}
	else
		initialParams.push(undefined);
}

// Get fixed parameters
var fitParams = [];
var fitParamList = [];
fitParamList.push({"fitParam":"minAsymptote",
					"params":[	{'resultSetName':'Fixed Sigmoidal Lower Bound','fitName':'fixed','type':'boolean'},
								{'resultSetName':'Sigmoidal Lower Bound Minimum Value','fitName':'minVal','type':'number'},
								{'resultSetName':'Sigmoidal Lower Bound Maximum Value','fitName':'maxVal','type':'number'},
								{'resultSetName':'Sigmoidal Lower Bound Calculated Value','fitName':'calcVal','type':'number'}]
				  });

fitParamList.push({"fitParam":"hillSlope",
					"params":[	{'resultSetName':'Fixed Hill Slope','fitName':'fixed','type':'boolean'},
								{'resultSetName':'Hill Slope Minimum Value','fitName':'minVal','type':'number'},
								{'resultSetName':'Hill Slope Maximum Value','fitName':'maxVal','type':'number'},
								{'resultSetName':'Hill Slope Calculated Value','fitName':'calcVal','type':'number'}]
				  });

fitParamList.push({"fitParam":"inflectionPoint",
					"params":[	{'resultSetName':'Fixed Inflection Point','fitName':'fixed','type':'boolean'},
								{'resultSetName':'Inflection Point Minimum Value','fitName':'minVal','type':'number'},
								{'resultSetName':'Inflection Point Maximum Value','fitName':'maxVal','type':'number'},
							{'resultSetName':'Inflection Point Calculated Value','fitName':'calcVal','type':'number'}]
				  });

fitParamList.push({"fitParam":"maxAsymptote",
					"params":[	{'resultSetName':'Fixed Sigmoidal Upper Bound','fitName':'fixed','type':'boolean'},
								{'resultSetName':'Sigmoidal Upper Bound Minimum Value','fitName':'minVal','type':'number'},
								{'resultSetName':'Sigmoidal Upper Bound Maximum Value','fitName':'maxVal','type':'number'},
								{'resultSetName':'Sigmoidal Upper Bound Calculated Value','fitName':'calcVal','type':'number'}]
				  });

for(var param in fitParamList)
{
	var paramObj = fitParamList[param];
	if(paramObj['fitParam'] && paramObj['params'] && paramObj['params'].length > 0)
	{
		var fitObj = {name:paramObj['fitParam']};
		for(var val in paramObj['params'])
		{
			var theObj = paramObj['params'][val];
			if(theObj['fitName'] && theObj['resultSetName'] && theObj['type'])
			{
				var theVal = undefined;
				if(theObj['type'] === 'boolean')
					theVal = false;
				
				if(resultSet.getFieldByName(theObj['resultSetName']))
					theVal = resultSet.getFieldByName(theObj['resultSetName']).value;
				
				if(theVal === undefined || theVal.length === 0)
					continue;
				
				if(theObj['type'] === 'number')
					theVal = Number.parseFloat(theVal);
				
				fitObj[theObj['fitName']] = theVal;
			}
		}
		
		fitParams.push(fitObj);
	}
}

var thisSample = {};
thisSample['fitType'] = new arxFitSigmoidal();
thisSample.fitType.parameterDisplayConfig.inflectionPoint.label = 'EC50 (uM)';

// Calculate IC0 and Hill Slope
var fitObj = {};
thisSample['x'] = logConc;
thisSample['y'] = activities;
thisSample['fitOptions'] = fitParams;
thisSample['initialParams'] = initialParams;

try {
	var curveFit = new arxFit(thisSample['fitType']);
	fitObj = curveFit.fitCurve(thisSample['x'], thisSample['y'], thisSample['initialParams'], thisSample['fitOptions']);
}
catch(err) {
	console.log('curve fit caught error:', err);
}

// populate hill slope and IC50
if(fitObj['params'])
{	
	// populate ic50
	var ic50raw = Math.pow(10, fitObj['params'][2]);
	var ic50clean = ic50raw.toPrecision(3);
	
	thisSample['IC50'] = ic50clean;
	thisSample['params'] = fitObj['params'];
	thisSample['hillSlope'] = decimalAdjust('round', fitObj['params'][1], -2);
	
	if(fitObj['r2'])
		thisSample['r2'] = decimalAdjust('round', fitObj['r2'], -2);
}

if(thisSample['hillSlope'])
	thisResult.getFieldByName('Hill Slope').value = thisSample['hillSlope'];
	
if(thisSample['IC50'])
	thisResult.getFieldByName('EC50 (uM)').value = thisSample['IC50'];

//thisResult.getFieldByName('Cell Line').value = thisSample['compoundId'];
thisResult.getFieldByName('Percent Activity').value = activities;
	
var curveData = {};
curveData['params'] = thisSample['params'];
curveData['fitType'] = thisSample['fitType'];
curveData['fitOptions'] = thisSample['fitOptions'];
curveData['initialParams'] = thisSample['initialParams'];

curveData['pointData'] = [];
for(var i in thisSample['x'])
	curveData['pointData'].push([thisSample['x'][i], thisSample['y'][i]]);

thisResult['value'] = JSON.stringify(curveData);
var thePlot = new KnockoutPlot(thisResult, 'getImage');
curveData['image'] = thePlot.getImage();

thisResult.getFieldByName('IC50 Curve').value = JSON.stringify(curveData);
thisResult.getFieldByName('Compound ID').value = thisResult.getFieldByName('Compound ID List').value;

// Heat map properties
var heatMapProperties = {
	plateIdField:"",
	curveDataField:"IC50 Curve",
	curveLabelFields:["Compound ID","Cell Line"],
	columnLabels:sampleConcentrations,
	rowLabelField:"Cell Line",
	fieldsToHide:["Top Concentration (uM)", "Dilution Factor", "Data", "Compound Signal", "Percent Activity", "Well Address", "Compound ID", "Compound ID List", "Cell Lines Tested", "Cell Line"],
	readOnlyWells:[		{wellRowField:'emptyRowId',wellColumnField:'emptyColumnId',displayValueField:'topEmptyWellReads'},
						{wellRowField:'emptyLeftRowId',wellColumnField:'emptyLeftColumnId',displayValueField:'emptyLeftColumnReads'},
						{wellRowField:'emptyRightRowId',wellColumnField:'emptyRightColumnId',displayValueField:'emptyRightColumnReads'},
						{wellRowField:'emptyBottomRowId',wellColumnField:'emptyBottomColumnId',displayValueField:'emptyBottomRowReads'},
						{wellRowField:'dmsoRow',wellColumnField:'dmsoColumn',displayValueField:'DMSO Percent Activity',heatMap:true}
				  ],
	displayOnlyWells:[	{displayValue:100,wellColumn:'6',wellRow:'B',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'C',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'D',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'E',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'F',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'G',heatMap:true}
					 ]
};

for(var i = 0; i < allResults.length; i++)
{
	if(allResults[i] === thisResult)
	{
		thisResult.getFieldByName('Cell Line').value = thisResult.getFieldByName('Cell Lines Tested').value[i];;
		break;
	}
}

// Add column labels to heat map
if(heatMapProperties.columnLabels.length == 0)
	heatMapProperties.columnLabels.push('');
$.each(heatMapProperties.columnLabels, function(i, label) { heatMapProperties.columnLabels[i] = heatMapProperties.columnLabels[i].toString().substring(0,5); });
heatMapProperties.columnLabels.splice(4, 0, 'No Trt');
heatMapProperties.columnLabels.splice(5, 0, 'DMSO');
heatMapProperties.columnLabels.splice(0, 0, '');
heatMapProperties.columnLabels.push('');

thisResult.getFieldByName('heatMapProperties').value = JSON.stringify(heatMapProperties);
  }

/**
 * Ported from platform-tyler.js. Dummy function that is required so JS strings evaluated from the mongo
 * db doesn't blow up.
 * @param {string} theId The ID to be used?
 */
function sendToFT(theId) {
	return true;
}