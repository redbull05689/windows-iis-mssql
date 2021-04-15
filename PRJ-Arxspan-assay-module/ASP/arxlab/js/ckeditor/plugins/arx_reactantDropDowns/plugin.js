CKEDITOR.plugins.add('arx_reactantDropDowns', {
	init: function(editor) {
		var config = editor.config,lang = editor.lang.format;
		var tags = [] //new Array();
		tags[0]=["0", "Reactant Names", "Reactant Names",'<a class="autoFill" formname="tab_text" heading="Reactant Names" href="javascript:void(0);" prefix="r" type="mol">Reactant Names</a>'];
		tags[1]=["1", "Reactant Chemical Names", "Reactant Chemical Names",'<a class="autoFill" formname="name" heading="Reactant Chemical Names" href="javascript:void(0);" prefix="r" type="mol">Reactant Chemical Names</a>'];
		tags[2]=["2", "Reactant Molecular Weights", "Reactant Molecular Weights",'<a class="autoFill" formname="molecularWeight" heading="Reactant Molecular Weights" href="javascript:void(0);" prefix="r" type="mol">Reactant Molecular Weights</a>'];
		tags[3]=["3", "Reactant Molecular Formulas", "Reactant Molecular Formulas",'<a class="autoFill" formname="molecularFormula" heading="Reactant Molecular Formulas" href="javascript:void(0);" prefix="r" type="mol">Reactant Molecular Formulas</a>'];
		tags[4]=["4", "Reactant Equivalents", "Reactant Equivalents",'<a class="autoFill" formname="equivalents" heading="Reactant Equivalents" href="javascript:void(0);" prefix="r" type="mol">Reactant Equivalents</a>'];
		tags[5]=["5", "Reactant W/W", "Reactant W/W",'<a class="autoFill" formname="weightRatio" heading="Reactant W/W" href="javascript:void(0);" prefix="r" type="mol">Reactant W/W</a>'];
		tags[6]=["6", "Reactant Samples Masses", "Reactant Samples Masses",'<a class="autoFill" formname="sampleMass" heading="Reactant Sample Masses" href="javascript:void(0);" prefix="r" type="mol">Reactant Sample Masses</a>'];
		tags[7]=["7", "Reactant Sample Volumes", "Reactant Sample Volumes",'<a class="autoFill" formname="volume" heading="Reactant Sample Volumes" href="javascript:void(0);" prefix="r" type="mol">Reactant Sample Volumes</a>'];
		tags[8]=["8", "Reactant Moles", "Reactant Moles",'<a class="autoFill" formname="moles" heading="Reactant Moles" href="javascript:void(0);" prefix="r" type="mol">Reactant Moles</a>'];
		tags[9]=["9", "Reactant Solvents", "Reactant Solvents",'<a class="autoFill" formname="solvent" heading="Reactant Solvents" href="javascript:void(0);" prefix="r" type="mol">Reactant Solvents</a>'];
		tags[10]=["10", "Reactant Percent Weights", "Reactant Percent Weights",'<a class="autoFill" formname="percentWT" heading="Reactant Percent Weights" href="javascript:void(0);" prefix="r" type="mol">Reactant Percent Weights</a>'];
		tags[11]=["11", "Reactant Molarites", "Reactant Molarities",'<a class="autoFill" formname="molarity" heading="Reactant Molarities" href="javascript:void(0);" prefix="r" type="mol">Reactant Molarities</a>'];
		tags[12]=["12", "Reactant Densities", "Reactant Densities",'<a class="autoFill" formname="density" heading="Reactant Densities" href="javascript:void(0);" prefix="r" type="mol">Reactant Densities</a>'];

		editor.ui.addRichCombo( 'arx_reactantDropDowns',{
			label : "Reactant Drop Downs",
			title :"Reactant Drop Downs",
			voiceLabel : "Reactant Drop Downs",
			className : 'cke_format',
			multiSelect : false,

			panel :{
				css : [ config.contentsCss, CKEDITOR.skin.getPath('editor') ],
				voiceLabel : lang.panelVoiceLabel
			},

			init : function(){
				this.startGroup( "Reactant Drop Downs" );
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