import Plugin from '@ckeditor/ckeditor5-core/src/plugin';

export default class MentionCustomization extends Plugin {
    init() {
        const editor = this.editor;
        // elements to the model 'mention' attribute.
        editor.conversion.for( 'upcast' ).elementToAttribute( {
            view: {
                name: 'a',
                key: 'data-mention',
                classes: 'mention',
                attributes: {
                    href: true,
                    'onClick': true
                }
            },
            model: {
                key: 'mention',
                value: viewItem => {
                    // The mention feature expects that the mention attribute value
                    // in the model is a plain object with a set of additional attributes.
                    // In order to create a proper object, use the toMentionAttribute helper method:
                    const mentionAttribute = editor.plugins.get( 'Mention' ).toMentionAttribute( viewItem, {
                        // Add any other properties that you need.
                        onClick: viewItem.getAttribute( 'onClick' )
                    } );

                    return mentionAttribute;
                }
            },
            converterPriority: 'high'
        } );

        // Downcast the model 'mention' text attribute to a view <span> element.
        editor.conversion.for( 'downcast' ).attributeToElement( {
            model: 'mention',
            view: ( modelAttributeValue, { writer } ) => {
                // Do not convert empty attributes (lack of value means no mention).
                if ( !modelAttributeValue ) {
                    return;
                }

                // we need to do this because the on click does not live through re render 
                // and for whatever reason if you do not ref modelAttributeValue like this it does not work. 
                var id =  modelAttributeValue.id;
                var elm = window.top.$(".fileName").toArray().find(x => x.innerHTML == id.substring(1));
                if (elm) {
                    var onClickStr = `window.top.showMainDiv('attachmentTable');window.top.document.getElementById('${$(elm).closest('tr').attr('id')}').scrollIntoView();`;
                }
                
                return writer.createAttributeElement( 'span', {
                    class: 'mention',
                    'data-mention': modelAttributeValue.id,
                    'onClick': onClickStr
                }, {
                    // Make mention attribute to be wrapped by other attribute elements.
                    priority: 20,
                    // Prevent merging mentions together.
                    id: modelAttributeValue.uid
                } );
            },
            converterPriority: 'high'
        } );
    }
}