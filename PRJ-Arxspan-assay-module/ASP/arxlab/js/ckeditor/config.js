/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
	config.disableNativeSpellChecker = false;

	config.skin = 'kama';

	config.specialChars = [ '&deg;','&alpha;','&beta;','&gamma;','&delta;','&epsilon;','&zeta;','&eta;','&theta;','&iota;','&kappa;','&lambda;','&mu;','&nu;','&xi;','&omicron;','&pi;','&rho;','&sigma;','&tau;','&upsilon;','&phi;','&chi;','&psi;','&omega;',
		'A','B','&#915;','&#916;','&#917;','Z','H','&#920;','I','K','&#923;','M','N','&#926;','O','&#928;','P','&#931;','T','Y','&#934;','X','&#936;','&#937;',
		'&sect;','&copy;','&#8482;','&reg;','&para;','&#8224;','&#8225;',
		'&times;','&middot;','&divide;','&plusmn;','&#8730;','&sup2;','&sup3;','&frac14;','&frac12;','&#8734;',
		'&#402;','&#166;','&#172;','&#181;','&#8240;','&#8592;','&#8594;','&#8593;','&#8595;','&#8596;','&#8629;','&#8656;','&#8656;','&#8658;','&#8657;','&#8659;','&#8660;',
		'&#8242;','&#8243;','&#8704;','&#8706;','&#8733;','&#8736;','&#8764;','&#8747;','&#8773;','&#8776;','&#8800;','&#8801;','&#8804;','&#8805;','&#8853;','&#8855;',
		'&#8707;','&#8709;','&#8711;','&#8712;','&#8713;','&#8719;','&#8721;','&#8743;','&#8744;','&#8745;','&#8746;','&#8747;','&#8756;','&#8834;','&#8835;','&#8838;','&#8839;'];

	config.toolbar = 'arxpspanToolbar';

	config.toolbar_arxspanToolbar = [
		{ name: 'clipboard', items : ['Undo','Redo','-','PasteText','PasteFromWord','-','Link','Unlink','-','NumberedList','BulletedList','SpecialChar','-','Subscript','Superscript','CodeSnippet' ] },
		{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','-','RemoveFormat','-','TextColor' ] },
		{ name: 'secondRow', items : [ 'FontSize','Font','Format','lineheight' ]}
	]

	config.toolbar_arxspanToolbarPrepTemplates = [
		{ name: 'clipboard', items : ['Table','Undo','Redo','-','PasteText','PasteFromWord','-','Link','Unlink','-','NumberedList','BulletedList','degreeButton','timeStampButton','SpecialChar','-','Subscript','Superscript','CodeSnippet' ] },
		{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','-','RemoveFormat','-','TextColor' ] },
		{ name: 'secondRow', items : [ 'FontSize','Font','Format','lineheight','arx_chemistryPreparationTemplates' ]}
	]

	config.toolbar_arxspanToolbarPrepTemplatesBioProtocol = [
		{ name: 'clipboard', items : ['Table','Undo','Redo','-','PasteText','PasteFromWord','-','Link','Unlink','-','NumberedList','BulletedList','timeStampButton','SpecialChar','-','Subscript','Superscript','CodeSnippet' ] },
		{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','-','RemoveFormat','-','TextColor' ] },
		{ name: 'secondRow', items : [ 'FontSize','Font','Format','lineheight','arx_bioProtocolTemplates' ]}
	]

	config.toolbar_arxspanToolbarPrepTemplatesBioSummary = [
		{ name: 'clipboard', items : ['Table','Undo','Redo','-','PasteText','PasteFromWord','-','Link','Unlink','-','NumberedList','BulletedList','timeStampButton','SpecialChar','-','Subscript','Superscript','CodeSnippet' ] },
		{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','-','RemoveFormat','-','TextColor' ] },
		{ name: 'secondRow', items : [ 'FontSize','Font','Format','lineheight','arx_bioSummaryTemplates']}
	]

	config.toolbar_arxspanToolbarPrepTemplatesFreeDescription = [
		{ name: 'clipboard', items : ['Table','Undo','Redo','-','PasteText','PasteFromWord','-','Link','Unlink','-','NumberedList','BulletedList','timeStampButton','SpecialChar','-','Subscript','Superscript','CodeSnippet' ] },
		{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','-','RemoveFormat','-','TextColor' ] },
		{ name: 'secondRow', items : [ 'FontSize','Font','Format','lineheight','arx_freeDescriptionTemplates' ]}
	]

	config.toolbar_arxspanToolbarPrepTemplatesAdmin = [
		{ name: 'clipboard', items : ['Table','Undo','Redo','-','PasteText','PasteFromWord','-','Link','Unlink','-','NumberedList','BulletedList','SpecialChar','-','Subscript','Superscript','CodeSnippet' ] },
		{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','-','RemoveFormat','-','TextColor' ] },
		{ name: 'dropdowns', items : [ 'arx_reactantDropDowns','arx_reagentDropDowns','arx_productDropDowns','arx_solventDropDowns','arx_templateCustomDropDowns','arx_chemistryExperimentDropDowns','arx_groupedTemplateDropdown' ] },
		{ name: 'secondRow', items : [ 'FontSize','Font','Format','lineheight','arx_freeDescriptionTemplates']}
	]

	config.toolbar_arxspanToolbarNotesAndAttachments = [
		{ name: 'clipboard', items : ['Table','Undo','Redo','-','PasteText','PasteFromWord','-','Link','Unlink','-','NumberedList','BulletedList','timeStampButton','SpecialChar','-','Subscript','Superscript','CodeSnippet' ] },
		{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','-','RemoveFormat','-','TextColor' ] },
		{ name: 'secondRow', items : [ 'FontSize','Font','Format','lineheight']}
	]

	config.keystrokes = [
		[ CKEDITOR.CTRL + 83, 'arxSave' ],                       // CTRL + S
		[ CKEDITOR.CTRL + 77, 'drawTimeStamp' ],                 // CTRL + D
		[ CKEDITOR.CTRL + 56, 'drawDegree' ]                     // CTRL + 8
	];

	config.line_height="1em;2em;2.5em;3em;3.5em;4em;4.5em";

	config.removePlugins = 'maximize';
	config.extraPlugins='arx_onchange,dialog,widget,ajax';
	config.plugins += ',tabletools,tableresize,colordialog,colorbutton,font,lineheight,codesnippet';
	config.disableNativeSpellChecker = false;
	 
	CKEDITOR.on('instanceReady', function(ev) {						
		//catch double click on <a>'s to open hrefs in new tab/window
		$('iframe').contents().dblclick(function(e) {		
			if(typeof e.target.href != 'undefined' ) {			
				window.open(e.target.href, 'new' + e.screenX);
			}
		});
	});

};