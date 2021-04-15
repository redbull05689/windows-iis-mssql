
var dataTableSortModule = function() {

    /**
     * Compares x and y in descending order. Passes through to datatables' default string desc sort.
     * @param {*} x The first item to compare.
     * @param {*} y The second item to compare.
     */
    var stringSortDesc = function(x, y) {
        return $.fn.dataTableExt.oSort["string-desc"](x, y);
    }

    /**
     * Compares x and y in ascending order. Passes through to datatables' default string asc sort.
     * @param {*} x The first item to compare.
     * @param {*} y The second item to compare.
     */
    var stringSortAsc = function(x, y) {
        return $.fn.dataTableExt.oSort["string-asc"](x, y);
    }
    
    /**
     * Gets the value of the given input string.
     * @param {string} textHtml The HTML of the input div.
     */
    var getInputText = function(textHtml) {
        return $(textHtml).find("input").val();
    }

    /**
     * Gets the text of the given textarea string.
     * @param {string} longTextHtml The HTML of the textarea div.
     */
    var getLongText = function(longTextHtml) {
        return $(longTextHtml).find("textarea").text();
    }

    /**
     * Gets the text of the given number input string.
     * @param {string} numberHtml The HTML of the number div.
     */
    var getNumber = function(numberHtml) {
        return $(numberHtml).find("input").val();
    }

    /**
     * Gets the text of the currently selected dropdown of the given dropdownHtml.
     * @param {string} dropDownHtml The HTML of the dropdown div.
     */
    var getSelectedDropdownText = function(dropDownHtml) {
        return $(dropDownHtml).find("option:selected").text();
    }

    /**
     * Gets the date as ms from the given HTML input string.
     * @param {string} dateHtml The HTML of the date input div.
     */
    var getDateVal = function(dateHtml) {
        var val = $(dateHtml).find("input").attr('initval');
        
        if (!val) {
            val = 0;
        } else if ($.isNumeric(val)) {
            val = parseInt(val) * 1000;
        } else {
            val = Date.parse(val);
        }

        return val;
    }

    /**
     * Gets the text of the given A link.
     * @param {string} aHtml The HTML of the a link div.
     */
    var getAText = function(aHtml) {
        return $(aHtml).find("a").text();
    }

    /**
     * Gets the file name from the given file upload HTML form.
     * @param {string} fileHtml The HTML of the file upload form.
     */
    var getFileText = function(fileHtml) {
        return $(fileHtml).find("form").attr("filename");
    }

    /**
     * Adds all of the necessary custom row ordering operations to the dataTableExt plugin.
     */
    var documentReadyFunction = function() {
        $.fn.dataTableExt.oSort["dropDown-desc"] = function(x, y) {
            return stringSortDesc(getSelectedDropdownText(x), getSelectedDropdownText(y));
        }

        $.fn.dataTableExt.oSort["dropDown-asc"] = function(x, y) {
            return stringSortAsc(getSelectedDropdownText(x), getSelectedDropdownText(y));
        }

        $.fn.dataTableExt.oSort["text-desc"] = function(x, y) {
            return stringSortDesc(getInputText(x), getInputText(y));
        }

        $.fn.dataTableExt.oSort["text-asc"] = function(x, y) {
            return stringSortAsc(getInputText(x), getInputText(y));
        }

        $.fn.dataTableExt.oSort["longText-desc"] = function(x, y) {
            return stringSortDesc(getLongText(x), getLongText(y));
        }

        $.fn.dataTableExt.oSort["longText-asc"] = function(x, y) {
            return stringSortAsc(getLongText(x), getLongText(y));
        }

        $.fn.dataTableExt.oSort["number-desc"] = function(x, y) {
            return stringSortDesc(parseFloat(getNumber(x)), parseFloat(getNumber(y)));
        }

        $.fn.dataTableExt.oSort["number-asc"] = function(x, y) {
            return stringSortAsc(parseFloat(getNumber(x)), parseFloat(getNumber(y)));
        }

        $.fn.dataTableExt.oSort["file-desc"] = function(x, y) {
            return stringSortDesc(getFileText(x), getFileText(y));
        }

        $.fn.dataTableExt.oSort["file-asc"] = function(x, y) {
            return stringSortAsc(getFileText(x), getFileText(y));
        }

        $.fn.dataTableExt.oSort["workflow-date-desc"] = function(x, y) {
            return stringSortDesc(getDateVal(x), getDateVal(y));
        }

        $.fn.dataTableExt.oSort["workflow-date-asc"] = function(x, y) {
            return stringSortAsc(getDateVal(x), getDateVal(y));
        }

        $.fn.dataTableExt.oSort["link-desc"] = function(x, y) {
            return stringSortDesc(getSelectedDropdownText(x), getSelectedDropdownText(y));
        }

        $.fn.dataTableExt.oSort["link-asc"] = function(x, y) {
            return stringSortAsc(getSelectedDropdownText(x), getSelectedDropdownText(y));
        }

        $.fn.dataTableExt.oSort["reg-desc"] = function(x, y) {
            return stringSortDesc(getAText(x), getAText(y));
        }

        $.fn.dataTableExt.oSort["reg-asc"] = function(x, y) {
            return stringSortAsc(getAText(x), getAText(y));
        }

        $.fn.dataTableExt.oSort["sortOrder-desc"] = function(x, y) {
            return stringSortDesc(x, y);
        }

        $.fn.dataTableExt.oSort["sortOrder-asc"] = function(x, y) {
            return stringSortAsc(x, y);
        }
    }

    return {
        documentReadyFunction: documentReadyFunction
    }
}

dataTableSortModule().documentReadyFunction();