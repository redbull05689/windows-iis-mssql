CKEDITOR.plugins.add('arx_productDropDowns', {
	init: function(editor) {
		var config = editor.config,lang = editor.lang.format;
		var tags = [] //new Array();
		tags[0]=["0", "Product Names", "Product Names",'<a class="autoFill" formname="tab_text" heading="Product Names" href="javascript:void(0);" prefix="p" type="mol">Product Names</a>'];
		tags[1]=["1", "Product Chemical Names", "Product Chemical Names",'<a class="autoFill" formname="name" heading="Product Chemical Names" href="javascript:void(0);" prefix="p" type="mol">Product Chemical Names</a>'];
		tags[2]=["2", "Product Molecular Weights", "Product Molecular Weights",'<a class="autoFill" formname="molecularWeight" heading="Product Molecular Weights" href="javascript:void(0);" prefix="p" type="mol">Product Molecular Weights</a>'];
		tags[3]=["3", "Product Molecular Formulas", "Product Molecular Formulas",'<a class="autoFill" formname="molecularFormula" heading="Product Molecular Formulas" href="javascript:void(0);" prefix="p" type="mol">Product Molecular Formulas</a>'];
		tags[4]=["4", "Product Equivalents", "Product Equivalents",'<a class="autoFill" formname="equivalents" heading="Product Equivalents" href="javascript:void(0);" prefix="p" type="mol">Product Equivalents</a>'];
		tags[5]=["5", "Product Theoretical Masses", "Product Theoretical Masses",'<a class="autoFill" formname="theoreticalMass" heading="Product Theoretical Masses" href="javascript:void(0);" prefix="p" type="mol">Product Theoretical Masses</a>'];
		tags[6]=["6", "Product Theoretical Moles", "Product Theoretical Moles",'<a class="autoFill" formname="theoreticalMoles" heading="Product Theoretical Moles" href="javascript:void(0);" prefix="p" type="mol">Product Theoretical Moles</a>'];
		tags[7]=["7", "Product Purities", "Product Purities",'<a class="autoFill" formname="purity" heading="Product Purities" href="javascript:void(0);" prefix="p" type="mol">Product Purities</a>'];
		tags[8]=["8", "Product Measured Masses", "Product Measured Masses",'<a class="autoFill" formname="measuredMass" heading="Product Measured Masses" href="javascript:void(0);" prefix="p" type="mol">Product Measured Masses</a>'];
		tags[9]=["9", "Product Actual Masses", "Product Actual Masses",'<a class="autoFill" formname="actualMass" heading="Product Actual Masses" href="javascript:void(0);" prefix="p" type="mol">Product Actual Masses</a>'];
		tags[10]=["10", "Product Actual Moles", "Product Actual Moles",'<a class="autoFill" formname="actualMoles" heading="Product Actual Moles" href="javascript:void(0);" prefix="p" type="mol">Product Actual Moles</a>'];
		tags[11]=["11", "Product Yields", "Product Yields",'<a class="autoFill" formname="yield" heading="Product Yields" href="javascript:void(0);" prefix="p" type="mol">Product Yields</a>'];

		editor.ui.addRichCombo( 'arx_productDropDowns',{
			label : "Product Drop Downs",
			title :"Product Drop Downs",
			voiceLabel : "Product Drop Downs",
			className : 'cke_format',
			multiSelect : false,

			panel :{
				css : [ config.contentsCss, CKEDITOR.skin.getPath('editor') ],
				voiceLabel : lang.panelVoiceLabel
			},

			init : function(){
				this.startGroup( "Product Drop Downs" );
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