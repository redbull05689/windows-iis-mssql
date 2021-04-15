CKEDITOR.plugins.add('arx_timeStampButton', {
	init: function(editor) {
		editor.ui.addButton('timeStampButton',
			{
				label: 'Time Stamp',
				command: 'drawTimeStamp',
				icon: this.path + 'icons/clockbutton.png'
			});
	}
})