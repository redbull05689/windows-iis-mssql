import Plugin from '@ckeditor/ckeditor5-core/src/plugin';
import ButtonView from '@ckeditor/ckeditor5-ui/src/button/buttonview';
import clock from './clock.svg';

export default class TimeStamp extends Plugin {

    static get pluginName() {
        return "TimeStamp";
    }

    init() {
        const editor = this.editor;

        editor.ui.componentFactory.add('TimeStamp', locale => {
            const view = new ButtonView(locale);

            view.set({
                label: 'Insert Time Stamp',
                icon: clock,
                tooltip: true
            });

            // Callback executed once the image is clicked.
            view.on('execute', () => {
                // Insert text at a given position - the document selection will not be modified.
                editor.model.change(writer => {
                    editor.model.insertContent(writer.createText((new Date()).toLocaleString()));
                });
            });

            editor.on('change', e => {
                if (e.name === 'change:isReadOnly') {
                    view.isEnabled = !editor.isReadOnly;
                }
            });

            return view;
        });
    }
}