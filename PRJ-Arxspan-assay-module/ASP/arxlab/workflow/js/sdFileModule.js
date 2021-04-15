/**
 * Module that takes in an SD File and parses it into a list of JSONs.
 * @param {File} fileBlob The input file.
 */
var SDFileModule = (async function(fileBlob) {
    var fileName = fileBlob.name;
    var nameArr = fileName.split(".");
    var fileExt = nameArr[nameArr.length - 1];

    // Short circuit this and return an error if a different file type was submitted.
    if (fileExt.toLowerCase() !== "sdf") {
        return {
            error: "Input file was not of type .sdf",
        };
    }

    /**
     * Reads the input file as text and returns the result.
     * @param {File} fileBlob The input file.
     */
    var readFileBlob = function(fileBlob) {
        return new Promise(function(resolve, reject) {
            var fr = new FileReader();
            fr.onload = function(x) {
                file = fr.result;
                resolve(file);
            };
            fr.readAsText(fileBlob);
        });
    };

    /**
     * Parses a list of mols into a list of mol data dicts.
     * @param {string[]} molList The list of mol strings that were deliminated by "$$$$".
     */
    var parseMolData = function(molList) {

        // Initialize the output list.
        var molDictList = [];

        // Iterate through each molstring and split on each carriage return.
        molList.forEach(function(mol) {
            // We'll normalize double \n's with carriage returns.
            var molLines = mol.replace("\n\n", "\r\n").split("\r\n");

            // Set up some variables to keep track of our iteration.
            var thisMolData = "";
            var molDataEndPast = false;
            var afterMol = "";
    
            molLines.forEach(function(line) {
                // Decode each line and append a carriage return to the end. This is so that we can build up the chemistry
                // data and preserve the line breaks.
                var decodedLine = line.replace("\x00", "") + "\r\n";
                
                // If we haven't found the end of the mol data yet, add to thisMolData. Otherwise, its part of the afterMol.
                if (!molDataEndPast) {
                    thisMolData += decodedLine;
                } else {
                    afterMol += decodedLine;
                }

                // This line signifies the end of a mol string, so once we get past this, everything until the end of molLines is
                // part of the afterMol metadata.
                if (decodedLine.trim() == "M  END") {
                    molDataEndPast = true;
                }
            });

            // Turn the current afterMol data into a data dictionary, add the molData string to it and add it to the return list.
            var currentMolDict = convertSDDataToDict(afterMol);
            currentMolDict.molData = thisMolData;
            molDictList.push(currentMolDict);
        });

        return molDictList;
    }

    /**
     * Uses a regex built from the given key to parse out the value from the given key.
     * @param {string} key The key of the data we want to parse out of sd.
     * @param {string} sd The afterMol data.
     */
    var getSdVal = function(key, sd) {
        var re = RegExp("> +<\\s*" + key.replace("(","\\(").replace("?","\\?").replace(")","\\)").replace("*","\\*") + "\\s*>.*?\\r\\n(.*?)\\r\\n");
        var matches = sd.match(re);
        if (matches != null && matches.length > 0) {
            return matches[1];
        }
        return false;
    }

    /**
     * Determines if the passed in line is an SD file header, using a regex.
     * @param {string} line The line to check.
     */
    var isKeyLine = function(line) {
        var re = RegExp("^> +<(.*?)>.*$");
        var matches = line.match(re);
        if (matches != null && matches.length > 0) {
            return matches[1];
        }
        return false;
    }

    /**
     * Helper function to convert sd file strings, sans the mol data, into a dictionary.
     * @param {string} sdData The afterMol data to convert into a dict.
     */
    var convertSDDataToDict = function(sdData) {
        var returnDict = {};
        var lines = sdData.split("\n");
        lines.forEach(function(line) {
            var fieldName = isKeyLine(line.trim());
            if (fieldName) {
                var val = getSdVal(fieldName.trim(), sdData);
                val = val.trim();
                returnDict[fieldName.trim()] = val;
            }
        });

        return returnDict;
    }
    
    // Read the file.
    var fileStr = await readFileBlob(fileBlob);

    // Now split it on each mol, trim each mol to make sure there's no excess carriage returns, then pop the last element because its empty.
    var molList = fileStr.split("$$$$").map(function(x) { return x.trim() });
    molList.pop();

    // Now parse the data out of the list.
    var molDictList = parseMolData(molList);

    return {
        molDictList: molDictList,
    };
});
