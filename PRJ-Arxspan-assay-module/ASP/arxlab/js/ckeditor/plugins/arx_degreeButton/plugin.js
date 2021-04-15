CKEDITOR.plugins.add('arx_degreeButton', {
	init: function(editor) {
		editor.ui.addButton('degreeButton',
			{
				label: 'Degree Symbol',
				command: 'drawDegree',
				icon: this.path + 'icons/degreebutton.png'
			});
	}
})