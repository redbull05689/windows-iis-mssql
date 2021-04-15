
/**
 * Creates the unique file identifier for resumable file uploading
 * @param {File} file The file being uploaded.
 * @param {Event} event The event.
 */
var resumableGenerateUniqueIdentifier = function (file, event) {

    if (file.relativePath) { // if we are uploading a folder, file.relativePath will be populated...
        return (file.size + '-' + file.relativePath.replace(/[^0-9a-zA-Z_-]/img, ''));
    } else {
        // ...otherwise we are uploading a single file
        var relativePath = file.webkitRelativePath || file.fileName || file.name; // Some confusion in different versions of Firefox
        var size = file.size;
        return (size + '-' + relativePath.replace(/[^0-9a-zA-Z_-]/img, ''));
    }
}