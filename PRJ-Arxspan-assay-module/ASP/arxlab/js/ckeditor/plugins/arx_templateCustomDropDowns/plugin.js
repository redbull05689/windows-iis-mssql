CKEDITOR.plugins.add('arx_templateCustomDropDowns', {
	init: function(editor) {
		var config = editor.config,lang = editor.lang.format;
		var tags = eval(CKEDITOR.ajax.load('/arxlab/eln_templates/ajax/load/getCustomDropDowns.asp?random='+Math.random())); //new Array();
		//testString = '	<a class=\'autoFill\' formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a><a class="autoFill" formname="tab_text" heading="Reagent Names" href="http://serwesrser" id="autoFill_link_cke_112" prefix="rg" target="_parent" type="mol">Reagent Names</a>'
		//tags[0]=["0", "Template 1", "Template 1",'blah'];
		//tags[1]=["1", "Template 2", "Template 2",'blah'];
		//tags[2]=["2", "Template 3", "Template 3",testString];

		editor.ui.addRichCombo( 'arx_templateCustomDropDowns',{
			label : "Custom",
			title :"Custom",
			voiceLabel : "Custom",
			className : 'cke_format',
			multiSelect : false,

			panel :{
				css : [ config.contentsCss, CKEDITOR.skin.getPath('editor') ],
				voiceLabel : lang.panelVoiceLabel
			},

			init : function(){
				this.startGroup( "Templates" );
				//this.add('value', 'drop_text', 'drop_label');
				for (var this_tag in tags){
					if(tags[this_tag][0] != undefined)
					{
						this.add(tags[this_tag][0], tags[this_tag][1], tags[this_tag][2]);
					}
				}
			},

			onClick : function( value ){        
				editor.focus();
				editor.fire( 'saveSnapshot' );
				editor.insertHtml(tags[value][3]);
				editor.fire( 'saveSnapshot' );
			}
		});
	}
});