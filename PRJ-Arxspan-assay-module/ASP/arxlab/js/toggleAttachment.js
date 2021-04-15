function hideAttachmentIfOpen(divId){
	if (document.getElementById(divId).style.display == 'block')
	{
		//if attachment is visible then hide it
		try
		{
			document.getElementById(divId).style.display='none';
			document.getElementById(divId+"_td").style.lineHeight='1px';
		}
		catch(err){}
	}	
}
function toggleAttachment(divId)
{
	if (document.getElementById(divId).style.display == 'block')
	{
		//if attachment is visible then hide it
		try
		{
			document.getElementById(divId).style.display='none';
			document.getElementById(divId+"_td").style.lineHeight='1px';
		}
		catch(err){}
	}
	else
	{
		//load ckeditor if not yet loaded
		if(document.getElementById(divId+"_description_loaded")){
			if(document.getElementById(divId+"_description_loaded").value == "0"){
				if(userOptions['attachment_description_height'] && CKEDITOR.instances[divId+'_description']){
					CKEDITOR.instances[divId+'_description'].config.height = userOptions['attachment_description_height'];
				}
				CKEDITOR.replace(divId+'_description',{allowedContent:true,toolbar : 'arxspanToolbarNotesAndAttachments',extraPlugins:'arx_onchange,arx_timeStampButton,colorbutton'});
				CKEDITOR.instances[divId+'_description'].on('change',ckChange);
				CKEDITOR.instances[divId+'_description'].on('resize',function(ev){positionButtons(); updateCkEditorSize('attachment_description_height',divId+'_description'); })
				CKEDITOR.instances[divId+'_description'].on('contentDom', function(ev){ev.editor.document.on( 'paste', function(e){pasteHandler(e.data.$,divId+'_description');});});
				CKEDITOR.instances[divId+'_description'].on('instanceReady', function(ev){positionButtons();});
				document.getElementById(divId+"_description_loaded").value = 1;
			}
		}
		try
		{
			document.getElementById(divId).style.display='block';
			//ie bug fix
			document.getElementById(divId+"_td").style.lineHeight='';
			try
			{
				//loads attachment if it has not been loaded yet
				el = document.getElementById(divId+"_att")
				newSrc = document.getElementById(divId+"_src").innerHTML.replace(/&amp;/g,"&")
				oldSrc = el.src.substring(el.src.lastIndexOf('/')+1)
				if (oldSrc == "loading.html" || oldSrc == "loading.gif")
				{
					if(newSrc.search("getImage.asp?") != -1)
					{
						LoadImage(newSrc,el.id)
					}
					else
					{
						el.src = newSrc
					}
				}
			}
			catch(err){}
		}
		catch(err){alert(err)}
	}
	positionButtons()
}

/* Function to show attachment for fancyTree */
function fancytreeShowAttachment(divId)
{
	//load ckeditor if not yet loaded
	if(document.getElementById(divId+"_description_loaded")){
		if(document.getElementById(divId+"_description_loaded").value == "0"){
			if(userOptions['attachment_description_height'] && CKEDITOR.instances[divId+'_description']){
				CKEDITOR.instances[divId+'_description'].config.height = userOptions['attachment_description_height'];
			}
			CKEDITOR.replace(divId+'_description',{allowedContent:true,toolbar : 'arxspanToolbarNotesAndAttachments',extraPlugins:'arx_onchange,arx_timeStampButton,colorbutton'});
			CKEDITOR.instances[divId+'_description'].on('change',ckChange);
			CKEDITOR.instances[divId+'_description'].on('resize',function(ev){positionButtons(); updateCkEditorSize('attachment_description_height',divId+'_description'); })
			CKEDITOR.instances[divId+'_description'].on('contentDom', function(ev){ev.editor.document.on( 'paste', function(e){pasteHandler(e.data.$,divId+'_description');});});
			CKEDITOR.instances[divId+'_description'].on('instanceReady', function(ev){positionButtons();});
			document.getElementById(divId+"_description_loaded").value = 1;
		}
	}
	try
	{
		//document.getElementById(divId).style.display='block';
		//ie bug fix
		//document.getElementById(divId+"_td").style.lineHeight='';
		//try
		//{
			//loads attachment if it has not been loaded yet
			el = document.getElementById(divId+"_att");
			divSrc = document.getElementById(divId+"_src");
			if (el !== null && divSrc !== null){
				newSrc = divSrc.innerHTML.replace(/&amp;/g,"&");
				oldSrc = el.src.substring(el.src.lastIndexOf('/')+1);
				if (oldSrc == "loading.html" || oldSrc == "loading.gif"){
					if(newSrc.search("getImage.asp?") != -1){
						LoadImage(newSrc,el.id,divId);
					}
					else{
						el.src = newSrc;
					}
				}
			}
		//}
		//catch(err){}
	}
	catch(err){
		console.error(err);
	}
	
	positionButtons();
}

function LoadImage(isrc,imageElement,divId){
	var oImg = new Image();
	oImg.src = isrc;
	if (oImg.complete) {
		width = 780;
		if(oImg.width<780)
		{
			document.getElementById(imageElement).setAttribute("width",oImg.width);
			width = oImg.width;
		}
		document.getElementById(imageElement).src = isrc
		nodeImg = '<img src=\"'+isrc+'"\"  width=\"'+width+'"\" id=\"'+imageElement+'\">';
		//Get the fancytree node and update the node with the image src
		fancytreeNodeUpdate(divId, nodeImg);
	}
	else {
		oImg.onload = function(){imgLoaded(isrc,imageElement,oImg,divId)}
		oImg.src = oImg.src;
	}
}

function imgLoaded(isrc,imageElement,oImg,divId)
{
	if (oImg.complete) {
		width = 780;
		if(oImg.width<780)
		{
			document.getElementById(imageElement).setAttribute("width",oImg.width);
			width = oImg.width;
		}
		document.getElementById(imageElement).src = isrc
		nodeImg = '<img src=\"'+isrc+'\"  width=\"'+width+'\" id=\"'+imageElement+'\">';
		//Get the fancytree node and update the node with the image src
		fancytreeNodeUpdate(divId, nodeImg);
	}
	else{
		setTimeout(function(){imgLoaded(isrc,imageElement,oImg,divId)},500)
	}
}
	
function fancytreeNodeUpdate(divId, trVal){
	var tree = $("#sortable").fancytree("getTree");
	refNode =  tree.getNodeByKey(divId);
	newData = {title: "New Node image", trVal: "<td colspan='7'>"+trVal+"</td>", trId:divId, key:divId};
	newSibling = refNode.appendSibling(newData);
	refNode.remove();
}

function fancytreeNodeUpdate(divId, trVal){
	var tree = $("#sortable").fancytree("getTree");
	refNode =  tree.getNodeByKey(divId);

	newData = {title: "New Node image", trVal: "<td colspan='7'>"+trVal+"</td>", trId:divId, key:divId};
	newSibling = refNode.appendSibling(newData);
	refNode.remove();
}
