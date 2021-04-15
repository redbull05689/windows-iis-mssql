let appConfigSettingsModule = (function() {

    /**
     * Function to build the settings table in jQuery based on the given datasets.
     * @param {JSON[]} dataList The data for the table.
     * @param {string[]} dataKeys The list of keys for each data item in dataList.
     * @param {string[]} columnList The list of column headers for the table.
     */
    let buildTable = function(dataList, dataKeys, columnList) {
        let table = $("<table>")
            .addClass("settingsTable");
    
        let tableHead = buildTableHead(columnList);
        let tableBody = buildTableBody(dataList, dataKeys);
    
        return table
            .append(tableHead)
            .append(tableBody);
    }
    
    /**
     * Private helper function to construct the thead element of the settings display table.
     * @param {string[]} columnList The list of column headers for the table.
     */
    let buildTableHead = function(columnList) {
        let tableHead = $("<thead>");
        let tableHeadRow = $("<tr>")
            .append($("<td>").text("Row #"));
        columnList.forEach(colName => tableHeadRow.append($("<td>").text(colName)));
        tableHead.append(tableHeadRow);
        return tableHead;
    }
    
    /**
     * Private helper function to construct the tbody element of the settings displaytable.
     * @param {JSON[]} dataList The data for the table.
     * @param {string[]} dataKeys The list of keys for each data item in dataList.
     */
    let buildTableBody = function(dataList, dataKeys) {
    
        let tableBody = $("<tbody>");
    
        $.each(dataList, function(i, setting) {
            let tableRow = $("<tr>")
                .append($("<td>").text(i + 1));
    
            dataKeys.forEach(key => tableRow.append($("<td>").text(setting[key])));
            tableBody.append(tableRow);
        });
        return tableBody;
    }

    return {
        buildTable: buildTable,
    }
})