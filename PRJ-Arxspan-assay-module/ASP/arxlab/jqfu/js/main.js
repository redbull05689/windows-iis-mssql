/*
 * jQuery File Upload Plugin JS Example 8.9.0
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

/* global $, window */
$(function () {
    'use strict';

    // Initialize the jQuery File Upload widget:
    $('#fileupload').fileupload({
        disableImageResize: false,
        dropZone: $('.attachmentsIndexTable')
        // Uncomment the following to send cross-domain cookies:
        //xhrFields: {withCredentials: true},
        //url: 'server/php/',
    })
    .bind('fileuploadpaste', function (e, data) { return false; }); // Disable pasting files into experiment - it's never used and it triggers whenever someone pastes a file in the comments popup
    $(document).bind('drop dragover', function (e) {
        e.preventDefault();
    });
    
    // Enable iframe cross-domain access via redirect option:
    $('#fileupload').fileupload(
        'option',
        'redirect',
        window.location.href.replace(
            /\/[^\/]*$/,
            '/cors/result.html?%s'
        )
    );

	//File type checks
	$('#fileupload').fileupload(
        'option', {
        acceptFileTypes: /^.*(\.|\/)(?!(exe|js|htaccess|bat|pif|msi)$)(?![^\.\/]*(\.|\/))/i
		
        }
    );
	
	
	if (window.location.hostname === 'blueimp.github.io') {
        // Demo settings:
        $('#fileupload').fileupload('option', {
            url: '//jquery-file-upload.appspot.com/',
            // Enable image resizing, except for Android and Opera,
            // which actually support image resizing, but fail to
            // send Blob objects via XHR requests:
            disableImageResize: /Android(?!.*Chrome)|Opera/
                .test(window.navigator.userAgent),
            maxFileSize: 5000000,
            acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
        });
        // Upload server status check for browsers with CORS support:
        if ($.support.cors) {
            $.ajax({
                url: '//jquery-file-upload.appspot.com/',
                type: 'HEAD'
            }).fail(function () {
                $('<div class="alert alert-danger"/>')
                    .text('Upload server currently unavailable - ' +
                            new Date())
                    .appendTo('#fileupload');
            });
        }
    } else {
        // Load existing files:
        //$('#fileupload').addClass('fileupload-processing');
        //$.ajax({
        //    // Uncomment the following to send cross-domain cookies:
        //    //xhrFields: {withCredentials: true},
        //    url: $('#fileupload').fileupload('option', 'url'),
        //    dataType: 'json',
        //    context: $('#fileupload')[0]
        //}).always(function () {
        //    $(this).removeClass('fileupload-processing');
        //}).done(function (result) {
        //    $(this).fileupload('option', 'done')
        //        .call(this, $.Event('done'), {result: result});
        //});
    }

});
