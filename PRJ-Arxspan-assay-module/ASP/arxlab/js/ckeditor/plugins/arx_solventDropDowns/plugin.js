CKEDITOR.plugins.add('arx_solventDropDowns', {
	init: function(editor) {
		var config = editor.config,lang = editor.lang.format;
		var tags = [] //new Array();
		tags[0]=["0", "Solvent Names", "Solvent Names",'<a class="autoFill" formname="tab_text" heading="Solvent Names" href="javascript:void(0);" prefix="s" type="mol">Solvent Names</a>'];
		tags[1]=["1", "Solvent Chemical Names", "Solvent Chemical Names",'<a class="autoFill" formname="name" heading="Solvent Chemical Names" href="javascript:void(0);" prefix="s" type="mol">Solvent Chemical Names</a>'];
		tags[2]=["2", "Solvent Ratios", "Solvent Ratios",'<a class="autoFill" formname="ratio" heading="Solvent Ratios" href="javascript:void(0);" prefix="s" type="mol">Solvent Ratios</a>'];
		tags[3]=["3", "Solvent Volume", "Solvent Volume",'<a class="autoFill" formname="volume" heading="Solvent Volume" href="javascript:void(0);" prefix="s" type="mol">Solvent Volume</a>'];
		tags[4]=["4", "Solvent Volumes", "Solvent Volumes",'<a class="autoFill" formname="volumes" heading="Solvent Volumes" href="javascript:void(0);" prefix="s" type="mol">Solvent Volumes</a>'];

		editor.ui.addRichCombo( 'arx_solventDropDowns',{
			label : "Solvent Drop Downs",
			title :"Solvent Drop Downs",
			voiceLabel : "Solvent Drop Downs",
			className : 'cke_format',
			multiSelect : false,

			panel :{
				css : [ config.contentsCss, CKEDITOR.skin.getPath('editor') ],
				voiceLabel : lang.panelVoiceLabel
			},

			init : function(){
				this.startGroup( "Solvent Drop Downs" );
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