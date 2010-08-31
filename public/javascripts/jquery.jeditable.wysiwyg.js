/*
 * Wysiwyg input for Jeditable
 *
 * Copyright (c) 2008 Mika Tuupola
 *
 * Licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 * 
 * Depends on jWYSIWYG plugin by Juan M Martinez:
 *   http://projects.bundleweb.com.ar/jWYSIWYG/
 *
 * Project home:
 *   http://www.appelsiini.net/projects/jeditable
 *
 * Revision: $Id$
 *
 */
 
$.editable.addInputType('wysiwyg', {
    /* Use default textarea instead of writing code here again. */
    //element : $.editable.types.textarea.element,
    element : function(settings, original) {
        /* Hide textarea to avoid flicker. */
        var textarea = $('<textarea>').css("opacity", "0");
        if (settings.rows) {
            textarea.attr('rows', settings.rows);
        } else {
            textarea.height(settings.height);
        }
        if (settings.cols) {
            textarea.attr('cols', settings.cols);
        } else {
            textarea.width(settings.width);
        }
        $(this).append(textarea);
        return(textarea);
    },
    content : function(string, settings, original) { 
        /* jWYSIWYG plugin uses .text() instead of .val()        */
        /* For some reason it did not work work with generated   */
        /* textareas so I am forcing the value here with .text() */
        $('textarea', this).text(string);
    },
    plugin : function(settings, original) {
        var self = this;
        /* Force autosave off to avoid "element.contentWindow has no properties" */
        settings.wysiwyg = $.extend({autoSave: false}, settings.wysiwyg);
        if (settings.wysiwyg) {
            setTimeout(function() { $('textarea', self).wysiwyg(settings.wysiwyg); }, 0);
        } else {
            setTimeout(function() { $('textarea', self).wysiwyg(); }, 0);
        }
    },
    submit : function(settings, original) {
        var iframe         = $("iframe", this).get(0); 
        var inner_document = typeof(iframe.contentDocument) == 'undefined' ?  iframe.contentWindow.document.body : iframe.contentDocument.body;
        var new_content    = $(inner_document).html();
        $('textarea', this).val(new_content);
    }
});
