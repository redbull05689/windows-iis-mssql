CKEDITOR.plugins.add('arx_reagentDropDowns', {
	init: function(editor) {
		var config = editor.config,lang = editor.lang.format;
		var tags = [] //new Array();
		tags[0]=["0", "Reagent Names", "Reagent Names",'<a class="autoFill" formname="tab_text" heading="Reagent Names" href="javascript:void(0);" prefix="rg" type="mol">Reagent Names</a>'];
		tags[1]=["1", "Reagent Chemical Names", "Reagent Chemical Names",'<a class="autoFill" formname="name" heading="Reagent Chemical Names" href="javascript:void(0);" prefix="rg" type="mol">Reagent Chemical Names</a>'];
		tags[2]=["2", "Reagent Molecular Weights", "Reagent Molecular Weights",'<a class="autoFill" formname="molecularWeight" heading="Reagent Molecular Weights" href="javascript:void(0);" prefix="rg" type="mol">Reagent Molecular Weights</a>'];
		tags[3]=["3", "Reagent Molecular Formulas", "Reagent Molecular Formulas",'<a class="autoFill" formname="molecularFormula" heading="Reagent Molecular Formulas" href="javascript:void(0);" prefix="rg" type="mol">Reagent Molecular Formulas</a>'];
		tags[4]=["4", "Reagent Equivalents", "Reagent Equivalents",'<a class="autoFill" formname="equivalents" heading="Reagent Equivalents" href="javascript:void(0);" prefix="rg" type="mol">Reagent Equivalents</a>'];
		tags[5]=["5", "Reagent W/W", "Reagent W/W",'<a class="autoFill" formname="weightRatio" heading="Reagent W/W" href="javascript:void(0);" prefix="rg" type="mol">Reagent W/W</a>'];
		tags[6]=["6", "Reagent Samples Masses", "Reagent Samples Masses",'<a class="autoFill" formname="sampleMass" heading="Reagent Sample Masses" href="javascript:void(0);" prefix="rg" type="mol">Reagent Sample Masses</a>'];
		tags[7]=["7", "Reagent Sample Volumes", "Reagent Sample Volumes",'<a class="autoFill" formname="volume" heading="Reagent Sample Volumes" href="javascript:void(0);" prefix="rg" type="mol">Reagent Sample Volumes</a>'];
		tags[8]=["8", "Reagent Moles", "Reagent Moles",'<a class="autoFill" formname="moles" heading="Reagent Moles" href="javascript:void(0);" prefix="rg" type="mol">Reagent Moles</a>'];
		tags[9]=["9", "Reagent Solvents", "Reagent Solvents",'<a class="autoFill" formname="solvent" heading="Reagent Solvents" href="javascript:void(0);" prefix="rg" type="mol">Reagent Solvents</a>'];
		tags[10]=["10", "Reagent Percent Weights", "Reagent Percent Weights",'<a class="autoFill" formname="percentWT" heading="Reagent Percent Weights" href="javascript:void(0);" prefix="rg" type="mol">Reagent Percent Weights</a>'];
		tags[11]=["11", "Reagent Molarites", "Reagent Molarities",'<a class="autoFill" formname="molarity" heading="Reagent Molarities" href="javascript:void(0);" prefix="rg" type="mol">Reagent Molarities</a>'];
		tags[12]=["12", "Reagent Densities", "Reagent Densities",'<a class="autoFill" formname="density" heading="Reagent Densities" href="javascript:void(0);" prefix="rg" type="mol">Reagent Densities</a>'];

		editor.ui.addRichCombo( 'arx_reagentDropDowns',{
			label : "Reagent Drop Downs",
			title :"Reagent Drop Downs",
			voiceLabel : "Reagent Drop Downs",
			className : 'cke_format',
			multiSelect : false,

			panel :{
				css : [ config.contentsCss, CKEDITOR.skin.getPath('editor') ],
				voiceLabel : lang.panelVoiceLabel
			},

			init : function(){
				this.startGroup( "Reagent Drop Downs" );
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