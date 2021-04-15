function addRxnToVisible(table, expIdIndex) {
	return new Promise(function(resolve, reject) {
		rows = table.rows({page:'current'})[0];
		
		var myPromises = [];
		rows.forEach(function(rowNum) {
			if (containsChild(table, rowNum) && !containsImg(table, rowNum)) {
				expId = getExpIdFromChild(table, rowNum);
				if (expId != "") {
					myPromises.push(getCdx(expId, expIdIndex, rowNum, table));
				}
			}
		});
		
		Promise.all(myPromises).then(function() {
			resolve(true);
		});
	});
}

function containsImg(table, rowNum) {
    output = false;
    childRow = table.row(rowNum).child();
    rowData = childRow[childRow.length - 1]
    if (typeof(rowData) != 'undefined') {
        rowHtml = rowData.innerHTML;
        output = rowHtml.indexOf("<img src=") > -1;
    }
    return output;
}

/**
 * Helper function to check if a given row in a table has a child row.
 * @param {*} table The DataTable table.
 * @param {number} rowNum The row's number.
 */
function containsChild(table, rowNum) {
	// This shouldn't be necessary, as the only thing that should be passed in here are DataTable objects
	// and all DataTable objects have access to the same API methods, regardless of whether or not the
	// jQuery selector can be used to access a valid DataTable.
	if (!table) {
		return false;
	}
    return table.row(rowNum).child.isShown();
}

/**
 * Helper function to determine the experiment ID of an experiment table row.
 * @param {*} table The DataTable table.
 * @param {number} rowNum The row's number.
 */
function getExpIdFromChild(table, rowNum) {
	output = "";
	
	// If our data is not an array and has an actual data structure, we can just pull the experiment ID out of it.
	if (!Array.isArray(table.row(rowNum).data())) {
		var rowData = table.row(rowNum).data();
		if ("expId" in rowData) {
			output = rowData["expId"];
		}
	} else {

		// Otherwise, the exp ID is going to be in the child row.
		childRow = table.row(rowNum).child();
		rowHtml = childRow[childRow.length - 1];

		// If we have an actual HTML string here, then grab it and pull out the exp ID using a regex.
		if (typeof(rowHtml) != 'undefined') {
			expId = rowHtml.innerHTML;
			re = />(\d*)</;
			match = re.exec(expId);
			if (match != null) {
				output = match[1];
			}
		}
	}
    return output;
}

function getRxn(molData, rowNum, table, expId, expIdIndex) {
	return new Promise(function(resolve, reject) {
		var jchemProxyLoc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport";
		$.ajax({
			type: "POST",
			url: jchemProxyLoc,
			data: JSON.stringify({"structure": molData.replace(/\\"/g, '"').replace(/<\?[^>]+\?><!DOCTYPE[^>]+>/g,""), //jchem doesn't like the doctype def, so remove it,
								  "parameters": "svg:headless,nosource,transbg,absLabelVisible,maxscale28,marginSize2,cv_off,atsiz0.5,w800,h100"}),
			dataType: "json",
			contentType: "application/json",
			async: true
		}).done(function(msg) {
			var theSvg = $(msg['structure']);
			theSvg.addClass('centerSvg');
			saveChemImageToCache(expId, theSvg);
			resolve(wrapBinImg(theSvg, rowNum, table, expId, expIdIndex));
		}).fail(function() {
			resolve(noRxn(table, rowNum));
		});
	});
}

function getCdx(expId, expIdIndex, row, table) {
	return new Promise(function(resolve, reject) {
		var loadingImg = $("<img style='height:99px;margin:auto;display:block;'>").attr('src', window.location.origin + "/arxlab/images/loading_big.gif");
		var loadingDiv = $("<div width=100%>").append(loadingImg);
		var childRow = table.row(row).child();
		var childData = prepareChildRow(childRow, loadingDiv);
		table.row(row).child(childData).show();

		//Check for the image in the cache
		loadChemImageFromCache(expId).then(function(chemImage){
			if(chemImage){
				resolve(wrapBinImg($(chemImage), row, table, expId, expIdIndex));
			}else{
				var getCDXLoc = window.location.origin + "/arxlab/experiments/ajax/load/getCDXorMRV.asp";
				$.ajax({
					method: "GET",
					url: getCDXLoc,
					data: {"id": expId, "qs":"removeUIDs"},
					async: true
				}).done(function(msg) {
					if (msg != "") {
						resolve(getRxn(msg, row, table, expId, expIdIndex));
					} else {
						resolve(noRxn(table, row));
					}
				});
			 }
		}).catch(function(){
			resolve(noRxn(table, row));
		});
	});
}

/**
 * Helper function to wrap an SVG chemical image in CSS and push the image to the table.
 * @param {string} theSvg The SVG image string.
 * @param {number} rowNum The row's number.
 * @param {*} table The DataTable table.
 * @param {number} expId The experiment's ID.
 * @param {number} expIdIndex The position of the experiment ID in the row data array.
 */
function wrapBinImg(theSvg, rowNum, table, expId, expIdIndex)
{
    var rowData = table.row(rowNum).data();

    if (Array.isArray(rowData)) {
        var rowExpId = rowData[expIdIndex];
    } else {
		var rowExpId = rowData["expId"];
	}
	
	if (rowExpId == expId) {
		theSvg.css("display", "block");
		theSvg.css("margin", "auto");
	
		childRow = table.row(rowNum).child();
		rowData = prepareChildRow(childRow, theSvg);
	
		table.row(rowNum).child(rowData).show()
	}
}

function prepareChildRow(childRow, content) {
    var rowData = [];
    if (childRow.length > 1) {
		// This strips all html so we will add what we need back after
        desc = childRow[0].innerHTML.replace(/<(?:.|\n)*?>/gm, '');
        if (desc != "") {
			if (isNaN(desc)){
				rowData.push("<div class='multiLineSpacing' style='margin-left:25px;width=100%'>" + desc + "</div>");
			}
            else {
				rowData.push(desc);
			}
        }
    }
    rowData.push(content);
    return rowData;
}

function noRxn(table, rowNum) {
    var noRxnDiv = $("<div  style='height:99px;margin:auto;display:block;'>").text("No reaction found.");
    table.row(rowNum).child(noRxnDiv).show();
}

function getCdxDashboard(expId, RxnHolder, loadGif) {
	console.log("getCdxDashboard: " + Date.now());
	return new Promise(function(resolve, reject) {
		//Check for the image in the cache
		loadChemImageFromCache(expId).then(function(chemImage){
			if(chemImage){
				resolve(wrapBinImgDash($(chemImage), RxnHolder, loadGif));
			}else{
				var getCdxLoc = window.location.origin + "/arxlab/experiments/ajax/load/getCDXorMRV.asp";
				$.ajax({
					method: "GET",
					url: getCdxLoc,
					data: {"id": expId, "qs":"removeUIDs"},
					async: true
				}).done(function(msg) {
					if (msg != "") {
						console.log("DONE getCdxDashboard: " + Date.now());
						resolve(getRxnDash(msg, RxnHolder, loadGif, expId));
					} else {
						resolve(noRxnDash(RxnHolder, loadGif));
					}
				});
			}
		}).catch(function(){
			resolve(noRxnDash(RxnHolder, loadGif));
		});
	});
}

function getRxnDash(cdx, RxnHolder, loadGif, expId) {
	console.log("getRxnDash: " + Date.now());
	return new Promise(function(resolve, reject) {
		var jchemProxyLoc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport";
		$.ajax({
			type: "POST",
			url: jchemProxyLoc,
			data: JSON.stringify({"structure": cdx.replace(/\\"/g, '"').replace(/<\?[^>]+\?><!DOCTYPE[^>]+>/g,""), //jchem doesn't like the doctype def, so remove it
								  "parameters": "svg:headless,nosource,transbg,absLabelVisible,maxscale28,marginSize2,cv_off,atsiz0.5,w800,h100"}),
			dataType: "json",
			contentType: "application/json",
			async: true
		}).done(function(msg) {
			var theSvg = $(msg['structure']);
			theSvg.addClass('centerSvg');
			console.log("DONE getRxnDash: " + Date.now());
			saveChemImageToCache(expId, theSvg);
			resolve(wrapBinImgDash(theSvg, RxnHolder, loadGif));
		}).fail(function() {
			resolve(noRxnDash(RxnHolder, loadGif));
		});
	});
}

function wrapBinImgDash(theSvg, RxnHolder, loadGif) {
	$('#'+RxnHolder).empty();
	$('#'+RxnHolder).append(theSvg);
}

function noRxnDash(RxnHolder, loadGif) {
    var noRxnDiv = $("<div  style='height:99px;margin:auto;display:block;'>").text("No reaction found.");
    loadId = loadGif.id;
    rxnId = RxnHolder.id;
    $("#loadId").remove();
    $("#rxnId").append(noRxnDiv);
}

function saveChemImageToCache(expId, theSvg){
	
	var sameChemImageloc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/saveChemImageCache.asp";
	$.ajax({
		type: "POST",
		url: sameChemImageloc + "?expId="+expId,
		data: $(theSvg).get(0).outerHTML,
		dataType: "xml",
		contentType: "text/xml",
		async: true
	});
}

function loadChemImageFromCache(expId){
	return new Promise(function(resolve, reject) {
		var getChemImageloc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/getChemImageCache.asp";
		$.ajax({
			type: "GET",
			url: getChemImageloc + "?expId=" + expId + "&rand=" + (new Date()).getTime(),
			contentType: "text/xml",
			async: true
		}).done(function(msg) {
			resolve(msg);
		}).fail(function() {
			reject();
		});
	});
}