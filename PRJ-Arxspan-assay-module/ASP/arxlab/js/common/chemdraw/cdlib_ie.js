/**
 * This is the Javascript wrapper for ActiveX-exported methods, used by IE.
 *
 * This file contains the all following functions that can be used from a web page:
 *
 *   cd_getFormula(objName, selection)
 *   cd_getAnalysis(objName, selection)
 *   cd_getMolWeight(objName, selection)
 *   cd_getExactMass(objName, selection)
 *   cd_getData(objName, dataType)
 *   cd_putData(objName, dataType, data)
 *   cd_clear(objName)
 *
 * All Rights Reserved.
 * (version 1.013) SEP 26, 2002
 */

/**
 * Internal function to test if the structure is blank
 * 
 * @param {any} objName
 * @param {any} selection
 */
function cd_isBlankStructure(objName, selection) {
	var ob = cd_getSpecificObject(objName);
	// Make sure that ob.Objects is there. If the structure was not ready, this would fail on IE 11.
	if (ob && ob.Objects) {
		return (ob.Objects.Count == 0);
	} 

	return true;
}

/**
 * Clear all drawings in the ActiveX named *objName*
 * 
 * @param {any} objName
 */
function cd_clear(objName) {
	return cd_getSpecificObject(objName).Objects.Clear();
}

/**
 * Return the *Formula* of selected/all structure in the ActiveX named *objName*
 * 
 * @param {any} objName
 * @param {any} selection
 */
function cd_getFormula(objName, selection) {
	var r = "";

	if (!cd_isBlankStructure(objName, selection)) {
		if (selection == null || !selection)
			r = cd_getSpecificObject(objName).Objects.Formula;
		else
			r = cd_getSpecificObject(objName).Selection.Objects.Formula;
	}

	return r;
}

/**
 * Return the *Analysis* of selected/all structure in the ActiveX named *objName*
 * 
 * @param {any} objName
 * @param {any} selection
 */
function cd_getAnalysis(objName, selection) {
	var r = "";

	if (!cd_isBlankStructure(objName, selection)) {
		if (selection == null || !selection)
			r = cd_getSpecificObject(objName).Objects.ElementalAnalysis;
		else
			r = cd_getSpecificObject(objName).Selection.Objects.ElementalAnalysis;
	}

	return r;
}

/**
 * Return the *Molecular Weight* of selected/all structure in the ActiveX named *objName*
 * 
 * @param {any} objName
 * @param {any} selection
 */
function cd_getMolWeight(objName, selection) {
	if (selection == null || !selection)
		return cd_getSpecificObject(objName).Objects.MolecularWeight;
	else
		return cd_getSpecificObject(objName).Selection.Objects.MolecularWeight;
}

/**
 *  Return the *Exact Mass* of selected/all structure in the ActiveX named *objName*
 *  
 * @param {any} objName
 * @param {any} selection
 */
function cd_getExactMass(objName, selection) {
	if (selection == null || !selection)
		return cd_getSpecificObject(objName).Objects.ExactMass;
	else
		return cd_getSpecificObject(objName).Selection.Objects.ExactMass;
}

/**
 * Return version of ActiveX control
 * 
 * @param {any} objName
 */
function cd_getVersion(objName) {
	return cd_getSpecificObject(objName).Version;
}

/**
 *  Return the Coding String of *dataType* type from selected/all drawings in the ActiveX named *objName*
 *  
 * @param {any} objName
 * @param {any} mimetype
 * @param {any} checkMW
 */
function cd_getData(objName, mimetype, checkMW) {
	if (checkMW == null)
		checkMW = true;

	var r = "";

	if (!checkMW || !cd_isBlankStructure(objName, 0)) {
		var ob = cd_getSpecificObject(objName);
		if (ob) {
			var oldEncode = ob.DataEncoded;
			ob.DataEncoded = true;
			mimetype.toLowerCase();
			// Make sure the object is right, this addresses an exception seen on IE 11.
			if (typeof ob.Data !== 'undefined') {
				r = ob.Data(mimetype);
			}
			ob.DataEncoded = oldEncode;
		}
	}

	return r;
}

/**
 * Set the ActiveX named *objName* to *data*
 * 
 * @param {any} objName
 * @param {any} mimetype
 * @param {any} data
 */
function cd_putData(objName, mimetype, data) {
	var ob = cd_getSpecificObject(objName);
	if (ob) {
		var oldEncode = ob.DataEncoded;
		ob.DataEncoded = true;
		mimetype.toLowerCase();
		// Make sure the object is right, this addresses an exception seen on IE 11.
		if (typeof ob.Data !== 'undefined') {
			ob.Data(mimetype) = data;
		}
		ob.DataEncoded = oldEncode;
		return true;
	} else {
		return false;
    }
}
