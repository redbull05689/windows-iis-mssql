function BIModule() {

    //#region Endpoints

    const baseUrl = "https://api-dev.boehringer-ingelheim.com:8443/ElabRest/v1";
    const availabilityUrl = `${baseUrl}/calculation/availability`;
    const hsCodeUrl = `${baseUrl}/calculation/hsCode`;
    const regulatedSubstanceUrl = `${baseUrl}/calculation/regulatedSubstance`;
    const safetyAlertsUrl = `${baseUrl}/calculation/safetyIataAlerts`;

    //#endregion

    //#region AJAX Comms

    /**
     * Makes a POST call through the BiProxy to the given URL, with the given payload.
     * @param {string} url The URL to POST to.
     * @param {JSON[]} payload The structures to send.
     */
    const makePost = async function (url, payload) {
        let response = await $.ajax({
            url: "/arxlab/workflow/js/BiIntegration/BiProxy.asp",
            type: "POST",
            data: {
                data: JSON.stringify({
                    url: url,
                    data: payload
                }),
            },
        });

        try {
            return JSON.parse(response);
        } catch (e) {
            console.error(e);
            return {};
        }
    }

    /**
     * Wraps the given name and molData into a JSON and submits to the availability data endpoint.
     * @param {string} name The name of this structure.
     * @param {string} molData The chemical structure to get data for.
     */
    const getAvailabilityDataForSingleItem = async function (name, molData) {
        const payload = [{
            name: name,
            molfile: molData,
        }];

        return await getAvailabilityDataForList(payload);
    }

    /**
     * Submits the structureList to the availability data endpoint.
     * @param {JSON[]} structureList The list of structures to get data for.
     */
    const getAvailabilityDataForList = async function (structureList) {
        return await makePost(availabilityUrl, structureList);
    }

    /**
     * Wraps the given name and molData into a JSON and submits to the HSCode endpoint.
     * @param {string} name The name of this structure.
     * @param {string} molData The chemical structure to get data for.
     */
    const calculateHsCodeForSingleItem = async function (name, molData) {
        const payload = [{
            name: name,
            molfile: molData,
        }];

        return await calculateHsCodeForList(payload);
    }

    /**
     * Submits the structureList to the HSCode endpoint.
     * @param {JSON[]} structureList The list of structures to get data for.
     */
    const calculateHsCodeForList = async function (structureList) {
        return await makePost(hsCodeUrl, structureList);
    }

    /**
     * Wraps the given name and molData into a JSON and submits to the regulatedSubstanceInfo endpoint.
     * @param {string} name The name of this structure.
     * @param {string} molData The chemical structure to get data for.
     */
    const calculateRegulatedSubstanceInfoForSingleItem = async function (name, molData) {
        const payload = [{
            name: name,
            molfile: molData,
        }];

        return await calculateRegulatedSubstanceInfoForList(payload);
    }

    /**
     * Submits the structureList to the regulatedSubstanceInfo endpoint.
     * @param {JSON[]} structureList The list of structures to get data for.
     */
    const calculateRegulatedSubstanceInfoForList = async function (structureList) {
        return await makePost(regulatedSubstanceUrl, structureList);
    }

    /**
     * Wraps the given name and molData into a JSON and submits to the safetyAlerts endpoint.
     * @param {string} name The name of this structure.
     * @param {string} molData The chemical structure to get data for.
     */
    const calculateSafetyAlertsForSingleItem = async function (name, molData) {
        const payload = [{
            name: name,
            molfile: molData,
        }];

        return await calculateSafetyAlertsForList(payload);
    }

    /**
     * Submits the structureList to the safetyAlerts endpoint.
     * @param {JSON[]} structureList The list of structures to get data for.
     */
    const calculateSafetyAlertsForList = async function (structureList) {
        return await makePost(safetyAlertsUrl, structureList);
    }

    /**
     * Wrapper function that submits the given structure to all of the endpoints we care about and returns
     * its data as a JSON object.
     * @param {JSON[]} structureList The list of structures to get data for. 
     */
    const makeAllCallsForSingleItem = async function (name, molData) {
        const payload = [{
            name: name,
            molfile: molData
        }];

        return await makeAllCallsForList(payload);
    }

    /**
     * Wrapper function that submits the structure list to all of the endpoints we care about and returns
     * their data as a JSON object.
     * @param {JSON[]} structureList The list of structures to get data for. 
     */
    const makeAllCallsForList = async function (structureList) {
        let promiseList = [
            getAvailabilityDataForList(structureList),
            calculateHsCodeForList(structureList),
            calculateRegulatedSubstanceInfoForList(structureList),
        ];

        let dataList = await Promise.all(promiseList).catch(function () {
            window.biRequestNotification.update({ 'title': "Error in service call", 'message': "", 'type': "danger" });
            window.setTimeout(function () {
                //wait 3 seconds and close the notification
                closeBiNotification();
            }, 3000);
        });

        return {
            availability: dataList[0],
            hsCode: dataList[1],
            regulatedSubstance: dataList[2],
        }
    }
    //#endregion

    //#region Data Mapping

    /**
     * Fetches data for the given molData and populates the dataTable with the given row number with the data from the API.
     * @param {number} itemRowNumber The row this data should populate into.
     * @param {string} name The name of this structure.
     * @param {string} molData The chemical structure to get data for.
     */
    const getAllBiDataForSingleRow = async function (itemRowNumber, name, molData) {
        if (isNaN(itemRowNumber)) {
            return false;
        }
        openBiNotification();
        const BiData = await makeAllCallsForSingleItem(name, molData);
        BiDataMapping(itemRowNumber, BiData.availability[name], BiData.regulatedSubstance[name], BiData.hsCode[name]);
    }

    /**
     * Fetches data for all of the structures provided and populates the dataTable with the API data. This assumes that
     * all of the data from a file or table was loaded into this function to bulk populate.
     * @param {JSON[]} structureList The list of structures to get data for. [{name : "", molfile : ""}]
     */
    const getAllBiDataForList = async function (structureList) {
        openBiNotification();
        const BiData = await makeAllCallsForList(structureList);
        const nameList = structureList.map(x => x.name);
        var dt = $(".dataTables_scrollBody > .requestItemEditorTable.display.dataTable.no-footer").DataTable();
        var dtData = dt.data().toArray();
        $.each(nameList, function (rowNumber, name) {
            dtData[rowNumber] = BiDataMapping(rowNumber, BiData.availability[name], BiData.regulatedSubstance[name], BiData.hsCode[name], true);
        });
        dt.clear().draw(false);
        dt.rows.add(dtData).draw(false);
    }

    /**
     * Map the data from the BI api to the item table.
     * @param {Number} itemRowNumber Row number (0 based) for the item.
     * @param {JSON[]} availability JSON array from the api.
     * @param {JSON[]} regulatedSubstance JSON array from the api.
     * @param {JSON} hsCode JSON from the api.
     * @param {Boolean} retRow Returns the row data insted of inserting for bulk row mapping.
     */
    var BiDataMapping = function (itemRowNumber, availability = null, regulatedSubstance = null, hsCode = null, retRow = false) {
        if (isNaN(itemRowNumber)) {
            return false;
        }

        //first get the data that already exists
        //NOTE: this is assuming their request type only has the one table and that the names will not change.
        var dataObj = $(".dataTables_scrollBody > .requestItemEditorTable.display.dataTable.no-footer").DataTable().row(itemRowNumber).data();
        //get the fields
        var itemFields = versionedRequestItems[0].fields;

        if (availability) {
            //setup data map
            // keyFromVar : colName
            var availabilityKeyMap = {
                amount: "Availability Amount",
                contact: "Availability Contact Info",
                currency: "Availability Currency",
                price: "Availability Price",
                sourceId: "Source ID",
                source: "Availability Source",
            }
            //run through data and add it to the obj
            $.each(availabilityKeyMap, function (key, val) {
                let field = itemFields.find(x => x.displayName == val);
                let dataArray = availability.map(x => x[key]);
                dataObj[field.requestTypeFieldId] = {
                    dirty: true,
                    data: dataArray,
                }
            });
        }

        if (regulatedSubstance) {
            //do it again
            var regulatedkeyMap = {
                checkComment: "Regulated Substance - Comment",
                juristicationName: "Regulated Substance - Jurisdiction Name",
                substanceLegislationName: "Regulated Substance - Legislated Name",
            }
            $.each(regulatedkeyMap, function (key, val) {
                let field = itemFields.find(x => x.displayName == val);
                let dataArray = regulatedSubstance.map(x => x[key]);
                dataObj[field.requestTypeFieldId] = {
                    dirty: true,
                    data: dataArray,
                }
            });
        }

        if (hsCode) {
            //one more time 
            var hsKeyMap = {
                codeBI: "BI HS Code",
                codeEU: "EU HS Code",
                codeUS: "US HS Code",
            }
            $.each(hsKeyMap, function (key, val) {
                let field = itemFields.find(x => x.displayName == val);
                let dataArray = [hsCode[key]];
                dataObj[field.requestTypeFieldId] = {
                    dirty: true,
                    data: dataArray,
                }
            });
        }

        //put the data in the table and redraw
        if (retRow) {
            closeBiNotification();
            return dataObj;
        }
        else {
            $(".dataTables_scrollBody > .requestItemEditorTable.display.dataTable.no-footer").DataTable().row(itemRowNumber).data(dataObj).draw();
        }
        closeBiNotification();
        return true;
    }

    /**
     * For each item in data array lookup the required bi data.
     * @param {JSON[]} dataArray Incoming data to call bi api with.
     */
    var bulkLookup = function (dataArray) {
        //look through each row 
        //find the structure
        //note the row 

        var structureField = versionedRequestItems[0].fields.find(x => x.dataTypeId == dataTypeEnums.STRUCTURE);
        if (structureField) {
            var structureFieldId = structureField.requestTypeFieldId;

            // This map function needs to filter out entries where the row doesn't have structure data or the structure is wrong.
            var structureArray = dataArray.map(x => x[structureFieldId] && "data" in x[structureFieldId] ? x[structureFieldId]["data"][0] : null);

            // Now that we've condensed the dataArray down to just structures and nulls, build the payload objects
            // and filter out anything that's null. We're filtering after we build the payload array to make sure the items
            // that we're sending have the correct index on them.
            const filteredStructureArray = structureArray
                .map((structureData, index) => { return (structureData ? { name: `item_${index}`, molfile: structureData } : null) })
                .filter(x => x);
            getAllBiDataForList(filteredStructureArray);

        }
        else {
            return dataArray;
        }


    }

    /**
     * Display a notification to the user that a service call is being made.
     */
    var openBiNotification = function () {

        window.biRequestNotification = $.notify({
            title: "Calling Service",
            message: "This may take a moment..."
        }, {
            delay: 0,
            type: "yellowNotification",
            template: utilities().notifyJSTemplates.default,
            onClose: function () {
                window.biRequestNotification = undefined;
            }
        });

    }

    /**
     * Close the notification about the service call.
     */
    var closeBiNotification = function () {
        if (window.biRequestNotification) {
            window.biRequestNotification.close();
            window.biRequestNotification = undefined;
        }
    }

    //#endregion

    return {
        getAvailabilityDataForSingleItem: getAvailabilityDataForSingleItem,
        getAvailabilityDataForList: getAvailabilityDataForList,
        calculateHsCodeForSingleItem: calculateHsCodeForSingleItem,
        calculateHsCodeForList: calculateHsCodeForList,
        calculateRegulatedSubstanceInfoForSingleItem: calculateRegulatedSubstanceInfoForSingleItem,
        calculateRegulatedSubstanceInfoForList: calculateRegulatedSubstanceInfoForList,
        calculateSafetyAlertsForSingleItem: calculateSafetyAlertsForSingleItem,
        calculateSafetyAlertsForList: calculateSafetyAlertsForList,
        makeAllCallsForSingleItem: makeAllCallsForSingleItem,
        makeAllCallsForList: makeAllCallsForList,
        BiDataMapping: BiDataMapping,
        getAllBiDataForSingleRow: getAllBiDataForSingleRow,
        getAllBiDataForList: getAllBiDataForList,
        bulkLookup: bulkLookup,
    }
}