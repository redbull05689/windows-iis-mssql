CKEDITOR.plugins.add('arx_autoText', {
	init: function(editor) {

			editor.addCommand('testcommandx', {
				exec: function(editor){alert(editor.getMenuItem('testcommandx'))}
			});

			editor.addCommand('doNothing', {
				exec: function(editor){}
			});

			editor.addCommand('arxautotextcommand',{
				editorFocus : 0,
				exec: function(editor){
					arr = editor.document.getBody().getElementsByTag('a');
					for (var i = 0; i < arr.count(); i++) {
						var element = arr.getItem(i);
						if (!element.getAttribute("id")){
							if(!element.hasClass("autoFill")){
								continue;
							}
						}
						if (element.hasClass("autoFill")||element.getAttribute("id").indexOf("autofill_link")>=0||element.getAttribute("id").indexOf("autoFill_link")>=0){
							newId = CKEDITOR.tools.getNextId();
							element.setAttribute("id","autoFill_link_"+newId)
							if(element.getAttribute("type") == "mol"){
								prefix = element.getAttribute("prefix")
								formName = element.getAttribute("formname")
								for (j=0;j<30 ;j++ ){
									if (prefix !="rc")
									{
										prefixPlusJ = prefix + j
									}
									else
									{
										prefixPlusJ = prefix
										j = 10000
									}
									if (document.getElementById(prefixPlusJ+"_tab")){
										if (prefix == 'rc')
										{
											prefixPlusJ = 'e'
										}
										//if(formName == 'tab_text'){
										//	fStr = "editor.document.getById('autoFill_link_"+newId+"').setHtml(document.getElementById('"+prefixPlusJ+'_'+formName+"').innerHTML)"
										//}else{
										//	fStr = "editor.document.getById('autoFill_link_"+newId+"').setHtml(document.getElementById('"+prefixPlusJ+'_'+formName+"').value)"
										//}
										//eval("editor.addCommand('"+prefixPlusJ+"_"+newId+"_command',{exec: function(editor){"+fStr+"}});")

										theFunction = (function(newId,prefixPlusJ,formName){
											return function(){
												editor.on('change',function(){});
												editorLink = editor.document.getById('autoFill_link_'+newId);
												groupId = editorLink.getAttribute("templategroupid");
												if (groupId){
													theAs = editor.document.$.getElementsByTagName("a");
													for(k=0;k<theAs.length;k++){
														if (theAs[k].className="autoFill" && theAs[k].getAttribute("templategroupid")==groupId){
															thisId = theAs[k].getAttribute("id");
															thisFormName = theAs[k].getAttribute("formname");
															if(thisFormName == 'tab_text'){
																editor.document.getById(thisId).setHtml(document.getElementById(prefixPlusJ+'_'+thisFormName).innerHTML.replace(/&apos;/ig,"'"));
															}else{
																editor.document.getById(thisId).setHtml(document.getElementById(prefixPlusJ+'_'+thisFormName).value.replace(/&apos;/ig,"'"));
															}
															editor.document.getById(thisId).setAttribute("selectedMol",prefixPlusJ);
														}
													}
												}else{
													if(formName == 'tab_text'){
														editor.document.getById('autoFill_link_'+newId).setHtml(document.getElementById(prefixPlusJ+'_'+formName).innerHTML.replace(/&apos;/ig,"'"));
													}else{
														editor.document.getById('autoFill_link_'+newId).setHtml(document.getElementById(prefixPlusJ+'_'+formName).value.replace(/&apos;/ig,"'"));
													}
													editor.document.getById('autoFill_link_'+newId).setAttribute("selectedMol",prefixPlusJ);
												}
												//setTimeout(function() {editor.on('change',ckChange);}, 10000);
											};
										})(newId,prefixPlusJ,formName,editor);
										editor.addCommand(prefixPlusJ+"_"+newId+"_command",{exec: theFunction})

										element.on('click', function(evt) {
											thisElement = editor.document.getById(this.getAttribute("id"))
											elementId = thisElement.getAttribute("id").replace("autoFill_link_","")
											prefix = thisElement.getAttribute("prefix")
											formName = thisElement.getAttribute("formname")
											heading = thisElement.getAttribute("heading")
											editor.addMenuGroup('testgroup');
											editor.addMenuGroup('nothingGroup');
													
											editor.addMenuItem(prefix+j+'_menu_heading', {
												label: heading,
												command: "doNothing",
												group: 'nothingGroup'
											});

											d = {}
											d[prefix+j+'_menu_heading'] = CKEDITOR.TRISTATE_OFF;
											removeItemsString = "";
											removeItemsString += "editor.removeMenuItem('"+prefix+j+'_menu_heading'+"');"
											for (j=0;j<30 ;j++ ){
												if (prefix !="rc")
												{
													prefixPlusJ = prefix + j
												}
												else
												{
													prefixPlusJ = prefix
													j = 10000
												}
												if (document.getElementById(prefixPlusJ+"_tab")){
													if (prefix == 'rc')
													{
														prefixPlusJ = 'e'
													}
													d[prefixPlusJ+'_menu_item'] = CKEDITOR.TRISTATE_OFF;
													removeItemsString += "editor.removeMenuItem('"+prefixPlusJ+'_menu_item'+"');"
													if(formName == 'tab_text'){
														thisLabel = document.getElementById(prefixPlusJ+"_"+formName).innerHTML.replace(/&apos;/ig,"'")
													}else{
														thisLabel = document.getElementById(prefixPlusJ+"_"+formName).value.replace(/&apos;/ig,"'")
													}
													editor.addMenuItem(prefixPlusJ+'_menu_item', {
														label: thisLabel,
														command: prefixPlusJ+"_"+elementId+"_command",
														group: 'testgroup'
													});
												}
											}

											editor.contextMenu.addListener(function(element, selection) {
												return d;
											});
											
											var domEvent = evt.data;
											offsetX = domEvent.$.clientX,
											offsetY = domEvent.$.clientY-10;

											editor.contextMenu.open( editor.document.getBody(),null,offsetX,offsetY );
											eval(removeItemsString)
										
											editor.contextMenu.addListener(function(element, selection) {
												eval(removeItemsString)
												return null;
											});


											iframes = document.getElementsByTagName('iframe')
											for(x=0;x<iframes.length;x++){
												if(iframes[x].getAttribute("class") == "cke_panel_frame"){
													outerDivs = document.getElementById(iframes[x].id).contentDocument.getElementsByTagName('div');
													for(var y=0;y<outerDivs.length;y++){
														if(outerDivs[y].getAttribute("title") == "Context Menu Options"){
															iframes[x].setAttribute("name","thisIsTheFrame")
															theAs = document.getElementById(iframes[x].id).contentDocument.getElementsByTagName('a');
															for(j=0;j<theAs.length;j++){
																if (theAs[j].title == "Paste" || theAs[j].title == "Copy" || theAs[j].title == "Cut" || theAs[j].title == "Edit Link" || theAs[j].title == "Unlink" || theAs[j].title == "anchor" || theAs[j].title == "removeAnchor"){
																	theAs[j].style.display = 'none';
																}
																if(theAs[j].title == heading){
																	theSpans = theAs[j].getElementsByTagName('span')
																	for (q=0;q<theSpans.length ;q++ ){
																		if (theSpans[q].getAttribute("class") == "cke_menubutton_label"){
																			theSpans[q].style.fontWeight = "bold";
																			theSpans[q].style.borderBottom = "2px solid #b6b6b6";
																		}
																	}
																}
															}
															theSpans = document.getElementById(iframes[x].id).contentDocument.getElementsByTagName('span');
															for (j=0;j<theSpans.length ;j++ ){
																if (theSpans[j].getAttribute("class") == "cke_icon_wrapper" || theSpans[j].getAttribute("class") == "cke_icon"){
																	theSpans[j].style.display = "none";
																}
																if (theSpans[j].getAttribute("class") == "cke_menuitem" || theSpans[j].getAttribute("class") == "cke_label"){
																	theSpans[j].style.marginLeft = '0px';
																}
															}
															theDivs = document.getElementById(iframes[x].id).contentDocument.getElementsByTagName('div');
															for (j=0;j<theDivs.length ;j++ ){
																if (theDivs[j].getAttribute("class") == "cke_menuseparator"){
																	theDivs[j].style.display = "none";
																}
															}
														}
													}	
												}
											}
										});//end element.on(
									}
								}
							
							}//end if mol




							if(element.getAttribute("type") == "static"){
								element.on('click', function(evt) {
									thisElement = editor.document.getById(this.getAttribute("id"))
									elementId = thisElement.getAttribute("id").replace("autoFill_link_","")
									heading = thisElement.getAttribute("heading")
									numOptions = thisElement.getAttribute("numoptions")

									//children = thisElement.getChildren()
									for (j=1;j<=numOptions ; j++ ){
										fStr = "editor.document.getById('autoFill_link_"+elementId+"').setHtml('"+thisElement.getAttribute("option_"+j)+"')"
										eval("editor.addCommand('"+j+"_"+elementId+"_command',{exec: function(editor){"+fStr+"}});")	
									}

									editor.addMenuGroup('testgroup');
									editor.addMenuGroup('nothingGroup');
											
									editor.addMenuItem(elementId+'_menu_heading', {
										label: heading,
										command: "doNothing",
										group: 'nothingGroup'
									});

									d = {}
									d[elementId+'_menu_heading'] = CKEDITOR.TRISTATE_OFF;
									removeItemsString = "";
									removeItemsString += "editor.removeMenuItem('"+elementId+'_menu_heading'+"');"
									
									for (j=1;j<=numOptions ; j++ ){
										d[elementId+'_'+j+'_menu_item'] = CKEDITOR.TRISTATE_OFF;
										removeItemsString += "editor.removeMenuItem('"+elementId+'_'+j+'_menu_item'+"');"
										editor.addMenuItem(elementId+'_'+j+'_menu_item', {
											label: thisElement.getAttribute("option_"+j),
											command: j+"_"+elementId+"_command",
											group: 'testgroup'
										});
									}
									editor.contextMenu.addListener(function(element, selection) {
										return d;
									});
									
									var domEvent = evt.data;
									offsetX = domEvent.$.clientX,
									offsetY = domEvent.$.clientY-10;

									editor.contextMenu.open( editor.document.getBody(),null,offsetX,offsetY );
									eval(removeItemsString)
								
									editor.contextMenu.addListener(function(element, selection) {
										eval(removeItemsString)
										return null;
									});


									iframes = document.getElementsByTagName('iframe')
									for(x=0;x<iframes.length;x++){
										if(iframes[x].getAttribute("class") == "cke_panel_frame"){
											outerDivs = document.getElementById(iframes[x].id).contentDocument.getElementsByTagName('div');
											for(var y=0;y<outerDivs.length;y++){
												if(outerDivs[y].getAttribute("title") == "Context Menu Options"){
													iframes[x].setAttribute("name","thisIsTheFrame")
													theAs = document.getElementById(iframes[x].id).contentDocument.getElementsByTagName('a');
													for(j=0;j<theAs.length;j++){
														if (theAs[j].title == "Paste" || theAs[j].title == "Copy" || theAs[j].title == "Cut" || theAs[j].title == "Edit Link" || theAs[j].title == "Unlink" || theAs[j].title == "anchor" || theAs[j].title == "removeAnchor"){
															theAs[j].style.display = 'none';
														}
														if(theAs[j].title == heading){
															theSpans = theAs[j].getElementsByTagName('span')
															for (q=0;q<theSpans.length ;q++ ){
																if (theSpans[q].getAttribute("class") == "cke_menubutton_label"){
																	theSpans[q].style.fontWeight = "bold";
																	theSpans[q].style.borderBottom = "2px solid #b6b6b6";
																}
															}
														}
													}
													theSpans = document.getElementById(iframes[x].id).contentDocument.getElementsByTagName('span');
													for (j=0;j<theSpans.length ;j++ ){
														if (theSpans[j].getAttribute("class") == "cke_icon_wrapper" || theSpans[j].getAttribute("class") == "cke_icon"){
															theSpans[j].style.display = "none";
														}
														if (theSpans[j].getAttribute("class") == "cke_menuitem" || theSpans[j].getAttribute("class") == "cke_label"){
															theSpans[j].style.marginLeft = '0px';
														}
													}
													theDivs = document.getElementById(iframes[x].id).contentDocument.getElementsByTagName('div');
													for (j=0;j<theDivs.length ;j++ ){
														if (theDivs[j].getAttribute("class") == "cke_menuseparator"){
															theDivs[j].style.display = "none";
														}
													}
												}
											}
										}
									}
								});//end element.on(
							
							}//end if mol



						editor.alreadyLoaded = true





						}
					}
					
					//setTimeout(function() {editor.on('change',ckChange);}, 10000);
				}
			});

//			editor.addCommand('testcommand', {
//				exec: function(editor) {
//					arr = editor.document.getBody().getElementsByTag('a');
//					for (var i = 0; i < arr.count(); i++) {
//						var element = arr.getItem(i);
//						if (element.hasClass("autoFill")){
//							elementId = element.getAttribute("id")
//							prefix = element.getAttribute("prefix")
//							formName = element.getAttribute("formname")
//						}
//					}
//				}
//			});



if (editor.addMenuItem) {
  // A group menu is required
  // order, as second parameter, is not required
  editor.addMenuGroup('testgroup');
  // Create a manu item
//   editor.addMenuItem('testitem', {
//   label: 'Do something',
//   command: 'testcommand',
//   group: 'testgroup'
//   });
//   editor.addMenuItem('testitem2', {
//   label: 'Do something else',
//   command: 'arxautotextcommand',
//   group: 'testgroup'
//   });
}


//arr = editor.document.getElementsByTag( 'a' );
//for (var i = 0; i < arr.length; i++) {
 //  var element = arr[i];
 //  element.on('click', function() {
 //    alert('link clicked');
 //  });
//}

//alert(editor.document.getBody());

editor.contextMenu.addListener(function(element, selection) {
  // Get elements parent, strong parent first
  var parents = element.getParents("strong");
  // Check if it's strong
  if (parents[0].getName() != "strong")
	{
    return null; // No item
	}
	else{
		//alert(document.getElementById('cke_118_frame'))
		//document.getElementById('cke_118_frame').document.getElementById('cke_780').style.display = 'none';
		//document.getElementById('cke_118_frame').document.getElementById('cke_781').style.display = 'none';
		//document.getElementById('cke_118_frame').document.getElementById('cke_782').style.display = 'none';
		
		
		//alert(document.getElementsByTagName('iframe'))
		//iframes = document.getElementsByTagName('iframe')
		//for(x=0;x<iframes.length;x++)
		//{
		//	alert(iframes[x].getAttribute("title")+'++'+iframes[x].id+'++'+iframes[x].name)
		//	if(iframes[x].getAttribute("title") == "Context Menu Options")
		//	{
		//		//iframes[x].name="thisIsTheFrame"
		//		theAs = document.getElementById(iframes[x].id).document.getElementsByTagName('a');
		//		for(j=0;j<theAs;j++)
		//		{
		//			alert(theAs[j].id)
		//		}
		//	}
		//}
	  return {testitem: CKEDITOR.TRISTATE_OFF,testitem2: CKEDITOR.TRISTATE_OFF}
	};
});



editor.on('instanceReady', function(editor){
	if (this.alreadyLoaded == undefined)
	{
		this.execCommand('arxautotextcommand')
		this.alreadyLoaded = true;
	}
});



  }
});