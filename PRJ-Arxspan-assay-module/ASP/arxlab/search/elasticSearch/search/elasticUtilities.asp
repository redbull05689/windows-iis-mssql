/**
 * Construct the final search Json for elastic search. 
 * @param {JSON} boolObj Original object from the front end.
 * @param {JSON} experimentJson Experiments that contain each structure.
 */
function handleStructureBool(boolObj, experimentJson) {

    // Figure out what keyword we are working with... must or should
    if ("should" in boolObj) {
        boolObj["should"] = generateNewStructureBool(boolObj["should"], experimentJson);
    }
    if ("must" in boolObj) {
        boolObj["must"] = generateNewStructureBool(boolObj["must"], experimentJson);
    }
    if ("must_not" in boolObj) {
        boolObj["must_not"] = {
                                "bool": {
                                    "must": generateNewStructureBool(boolObj["must_not"], experimentJson)
                                }
                                
                            };
    }               

    return ({bool: boolObj});
}

/**
 * Construct the final search Json for elastic search. 
 * This will also use the handleStructureBool when needed to generate deep structure objects.
 * @param {JSON[]} arrayObj Array object to apply the structures too.
 * @param {JSON} experimentJson Experiments that contain each structure.
 */
function generateNewStructureBool(arrayObj, experimentJson) {
    // Setup our output bucket
    var retArray = [];
    
    // loop through each item in the array and figrue out what to do with it.
    // NOTE: we need to loop like this because server side JS uses ES3 and array.each is ES5
    for (var i=0; i<arrayObj.length; i++){
        var item = arrayObj[i];
        // look to see if we have terms to work with
        if ('terms' in item) {

            // look to see if we have structure.
            if ('Structure' in item.terms) {
                
                // get the structure ref.
                var StructureRef = item.terms.Structure[0];
                // This is the structure we need to get.
                retArray.push(
                    {
                        bool: {
                            should: [
                                // There used to be a more detailed search structure, but the ES search endpoint
                                // was not playing nice with it in a very inexplicable and unexplainable manner,
                                // so this has been simplified to just what's actually being searched for.
                                createTermObject("experimentId" , experimentJson[StructureRef])
                            ]
                        }
                    }
                );
            }

        }
        else if ('bool' in item) { // if we have a bool instead we need to go deeper and start again
            retArray.push(handleStructureBool(item.bool, experimentJson));
        }
        else { // catch all for things that dont need toutched and just passed along.
            retArray.push(item);
        }
    };
    return retArray;
}


/**
 * Helper function to create a JSON with the structure {"term": {key: val}}.
 * @param {String} key Key to put val under
 * @param {Any} val Value to add
 */
function createTermObject(key, val) {
    if(val instanceof Array){
        var retObj = {terms: {}};
        retObj["terms"][key] = val;
    } 
    else {
        var retObj = {term: {}};
        retObj["term"][key] = val;
    }
    
    return (retObj);
}

