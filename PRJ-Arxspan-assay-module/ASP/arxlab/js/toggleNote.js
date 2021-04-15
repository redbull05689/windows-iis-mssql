function toggleNote(divId)
{
	if (document.getElementById(divId).style.display == 'block')
	{//hide note
		try
		{
			document.getElementById(divId).style.display='none';
			document.getElementById(divId+"_td").style.lineHeight='1px';
		}
		catch(err){}
	}
	else
	{//show note
		//load ckeditor if not yet loaded
		$("#requestFields").empty();
		if(document.getElementById(divId+"_description_loaded")){
			if(document.getElementById(divId+"_description_loaded").value == "0"){
				if(userOptions['note_description_height'] && CKEDITOR.instances[divId+'_description']){
					CKEDITOR.instances[divId+'_description'].config.height = userOptions['note_description_height'];
				}
				CKEDITOR.replace(divId+'_description',{allowedContent:true,toolbar : 'arxspanToolbarNotesAndAttachments',extraPlugins:'arx_onchange,arx_timeStampButton'});
				if(typeof ckChange !== "undefined"){
					CKEDITOR.instances[divId+'_description'].on('change',ckChange);
				}
				CKEDITOR.instances[divId+'_description'].on('resize',function(){ positionButtons(); updateCkEditorSize('note_description_height',divId+'_description'); })
				CKEDITOR.instances[divId+'_description'].on('contentDom', function(ev){ev.editor.document.on( 'paste', function(e){pasteHandler(e.data.$,divId+'_description');});});
				CKEDITOR.instances[divId+'_description'].on('instanceReady', function(ev) { positionButtons(); });
				document.getElementById(divId+"_description_loaded").value = 1;
			}
		}
		try
		{
			document.getElementById(divId).style.display='block';
			document.getElementById(divId+"_td").style.lineHeight='';
		}
		catch(err){alert(err)}
	}
	positionButtons()
}