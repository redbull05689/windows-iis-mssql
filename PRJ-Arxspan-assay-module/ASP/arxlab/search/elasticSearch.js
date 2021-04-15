//set lang code
var lang_code = 'en';

//get default search term
var defSearch = checkQueryString();

var rules_basic = (!checkType(defSearch, "undefined")) ? {
  condition: 'AND',
  rules: [{
    id: '_all',
    operator: 'contains',
    value: defSearch
  }]
} : null;

if (interfaceLanguage == 'Japanese'){
  //lang_code = 'jp'; //TODO
}else if (interfaceLanguage == 'Chinese'){
  lang_code = 'zh_CN';
}

var esFilters = [{
  id: 'fullName',
  label: 'Name',
  type: 'string',
  optgroup: "Owner",
  operators: ['contains', 'not_contains']
},{
  id: 'emailAddress',
  label: 'Email Address',
  type: 'string',
  optgroup: "Owner",
  operators: ['contains', 'not_contains']
}, {
  id: 'statusId',
  label: 'Status',
  type: 'integer',
  input: 'select',
  optgroup: "Experiment",
  values: {
    1: 'Created',
    2: 'Saved',
    3: 'Signed - Open',
    5: 'Signed - Closed',
    6: 'Witnessed',
    7: 'Rejected',
    8: 'Reopened',
    9: 'Regulatory Check'
  },
  operators: ['equal', 'not_equal']
},{
  id: 'experimentType',
  label: 'Type',
  type: 'string',
  input: function(rule, inputName){

    // Build a select object for this input. We're building the select instead of just
    // passing in a JSON for now because for the time being, we need all custom experiment
    // types to point to es index 5.
    var sel = $("<select>");
    sel.attr("name", inputName);

    if (loadDefaultExperiments) {
      // Stealing this logic from popupDivs.asp
      if (hasChem && !hideNonCollab) {        
        sel.append($("<option>").attr("value", 1).text("Chemistry"));
      }
    
      if (!hideNonCollab) {
        sel.append($("<option>").attr("value", 2).text("Biology"));
      }
      
      if (hasFree) {
        var freeName = "Concept";
        if (hasMUF) {
          freeName = "<%=mufName%>";
        }
        sel.append($("<option>").attr("value", 3).text(freeName));
      }
    
      if (hasAnal && !hideNonCollab) {
        sel.append($("<option>").attr("value", 4).text("Analytical"));
      }
    } 
    // Build the select object by hand with requestTypeNames.
    $.each(requestTypeNames, function(index, name) {
      sel.append($("<option>").attr("value", 5).text(name));
    });
    return sel;
  },
  optgroup: "Experiment",
  operators: ['equal', 'not_equal']
},// {
  // id: 'visible',
  // label: 'Deleted',
  // type: 'integer',
  // input: 'radio',
  // optgroup: "Experiment",
  // values: {
  //   1: 'No',
  //   0: 'Yes'
  // },
  // operators: ['equal']
//},
{
  id: 'e_name',
  label: 'Notebook Page',
  type: 'string',
  optgroup: "Experiment",
  operators: ['contains', 'not_contains']
},{
  id: 'e_userAddedName',
  label: 'Experiment Name',
  type: 'string',
  optgroup: "Experiment",
  operators: ['contains', 'not_contains']
},{
  id: 'e_details',
  label: 'Details',
  type: 'string',
  optgroup: "Experiment",
  operators: ['contains', 'not_contains']
},{
  id: 'e_preparation',
  label: 'Preparation',
  type: 'string',
  optgroup: "Experiment",
  operators: ['contains', 'not_contains']
},{
  id: 'e_protocol',
  label: 'Protocol',
  type: 'string',
  optgroup: "Experiment",
  operators: ['contains', 'not_contains']
},{
  id: 'e_summary',
  label: 'Summary',
  type: 'string',
  optgroup: "Experiment",
  operators: ['contains', 'not_contains']
},{
  id: 'dateCreated',
  label: "Last Saved (MM/DD/YYYY)",
  type: 'string',
  optgroup: "Experiment",
  operators: ['greater_or_equal', 'less_or_equal']
},{
  id: 'dateUpdated',
  label: "Date Created (MM/DD/YYYY)",
  type: 'string',
  optgroup: "Experiment",
  operators: ['greater_or_equal', 'less_or_equal']
},{
  id: 'notebookName',
  label: 'Notebook Name',
  type: 'string',
  optgroup: "Notebook",
  operators: ['contains', 'not_contains']
},{
  id: 'notebookDesc',
  label: 'Notebook Description',
  type: 'string',
  optgroup: "Notebook",
  operators: ['contains', 'not_contains']
},{
  id: 'projectNames',
  label: 'Project Name',
  type: 'string',
  optgroup: "Project",
  operators: ['contains', 'not_contains']
},{
  id: 'projectDesc',
  label: 'Project Description',
  type: 'string',
  optgroup: "Project",
  operators: ['contains', 'not_contains']
},{
  id: 'attachmentNames',
  label: 'Attachment Names',
  type: 'string',
  optgroup: "Attachment",
  operators: ['contains', 'not_contains']
},{
  id: 'attachmentText',
  label: 'Attachment Text',
  type: 'string',
  optgroup: "Attachment",
  operators: ['contains', 'not_contains']
},{
  id: 'noteNames',
  label: 'Note Names',
  type: 'string',
  optgroup: "Note",
  operators: ['contains', 'not_contains']
}, {
  id: 'noteText',
  label: 'Note Text',
  type: 'string',
  optgroup: "Note",
  operators: ['contains', 'not_contains']
},{
  id: 'Structure',
  label: 'Structure Search',
  type: 'string',
  input: function(rule, inputName){
    // We'll set up the HTML elements first...
    var html = '<p>Type Of Search: <select class="form-control" name=' + inputName + '><option value="' + inputName + '_SUBSTRUCTURE">Substructure</option><option value="' + inputName + '_DUPLICATE">Exact</option><option value="' + inputName + '_SIMILARITY">Similarity</option><option value="' + inputName + '_SUPERSTRUCTURE">Superstructure</option></select></p><p>Type Of Structure : <select id="chemSearchMolType" name="chemSearchMolType"><option value="">ANY</option><option value="1">reactant</option><option value="2">reagent</option><option value="3">product</option><option value="10">attachment</option></select></p> <p>Draw a Structure Here:</p><input type="hidden" value="' + inputName + '" name="StructureSearchField" />';
    
    // Then we'll start getting the chemistry editor ready. When its done, it can append itself to the correct rule-value-container.
    getChemistryEditorMarkup(inputName, "StructureSearchField", "", 450, 300, false).then(function(editorHtml) {
      $("#" + rule.id + " > .rule-value-container").append(editorHtml);
    });

    // Return the non-async HTML elements for now.
    return html;
  },
  optgroup: "Chemical",
  operators: ['include','exclude']
},{
  id: 'chem_struct',
  label: 'Name Search',
  type: 'string',
  input: function(rule, inputName){
    retval = '<p>Type Of Structure : <select id="chemType_'+inputName+'_s" name="'+inputName+'_s"><option value="0">all/any</option><option value="1">reactant</option><option value="2">reagent</option><option value="3">reagent</option><option value="4">solvent</option><option value="5">product</option></select></p><input type="hidden" value="'+inputName+'" name="'+inputName+'" /><input type="text" id="chemType_'+inputName+'_t" name="'+inputName+'_t"></input>';
    return retval;
  },
  optgroup: 'Chemical',
  operators: ['contains', 'not_contains']
},{
  id: 'prod_yield',
  label: 'Product Yield Search',
  type: 'double',
  optgroup: 'Chemical',
  operators: ['between']
},{
  id: 'prod_purity',
  label: 'Product Purity Search',
  type: 'integer',
  optgroup: 'Chemical',
  operators: ['between']
}];

var auditTypeCodes = [];

  // Get workflow fields before initializing the query builder 
var promArray = [buildRequestTypeFilter(), getRequestItems()];

Promise.all(promArray).then(function(data){

  data.forEach(function(arr){
    arr.forEach(function(item){
      if (esFilters.find(function(x){ return x.id == item.id;}) == undefined) {
        esFilters.push(item);
      }
    });
  });
  initQueryBuilder(esFilters).then(function(){
    
    //This adds the history button
    var mySpan = $('<div>').appendTo('#builder_group_0');
    $('<input>', { type: 'checkbox', id : 'checkhistory', value: 'true', style: "display: inline-block;" }).appendTo($(mySpan));
    $('<label />', { 'for': 'checkhistory', text: '  Include Results from Experiment History' }).appendTo(mySpan);
    
    if (defSearch != "") {
      clickSearch("dateCreated", 'desc', true);
    }
  
  });

});



$('#btn-reset').on('click', function() {
  $('#builder-basic').queryBuilder('reset');
});

//This will reset the rules (if rules_basic is defnined)
$('#btn-set').on('click', function() {
  $('#builder-basic').queryBuilder('setRules', rules_basic);
});

//There was logic here to get all visible experiments, but that's been moved to nav_top_tool.asp so that every page
//could use elasticSearch.
var searchJSON;
var pageNum;
var pageSize = 40;

// Keeping a bunch of data about structure searches so the structure search can be finely tuned.
var struc_search;
var struc_counts = {};
var struc_details = [];
var structureSearchParams = [];
var hasStructureAttachmentHits = false;

// Global variables for sort ordering. These are the defaults and they're set as global
// variables because I couldn't think of a better way to make the search remember the
// sort ordering. I would normally set a value for each table header and update that, but
// the way this implementation of elasticSearch works is by creating an entirely new table
// whenever a search is performed, so the old table headers get deleted.
var notebookHeadOrder = "asc";
var experimentNameHeadOrder = "asc";
var creatorHeadOrder = "asc";
var dateHeadOrder = "desc";
var statusHeadOrder = "asc";
var revisionHeadOrder = "desc";

var lastCol;
var lastOrder;

$('#btn-get-es').on('click', function(){
  clickSearch("dateCreated", 'desc', true);
});

function clickSearch(colName, order, btn_click) {
  searchButtonStatus("#btn-get-es", true);
  //Update the search string and call the search function
  try{
    searchJSON = $('#builder').queryBuilder('getESBool');
    pageNum = 0;
  
    // Set struc_search to false on every search.
    struc_search = false;
    var myPromiseArray = [];
    myPromiseArray.push(prepareStructures());
    myPromiseArray.push(addDateFormat());
    myPromiseArray.push(formatChemNameSearch());

    Promise.all(myPromiseArray).then(function(){
      // Throwing the history search in a try-catch because it's the point of failure when we want
      // a search to happen when the page loads, I think?
      try {
        addHistorySearch();
      }
      catch (exception){
        //
      }
      addPermissionsFilter();
      search(colName, order, btn_click);      
    });
  } catch(e){
	console.error(e);
    searchButtonStatus("#btn-get-es", false);
  }
}

/**
 * Function to determine the current search type based on the rules in the querybuilder.
 */
function determineSearchType() {
  return new Promise(function(resolve, reject) {
    // Start by fetching the audit search codes. We can't determine the search type if we don't know what
    // codes we have.
    fetchAuditSearchCodes().then(function(typeCodesList) {

      // Pull those codes out of the list.
      var multiParamCode = filterCodeObj(typeCodesList, "Multi-Parameter");
      var textCode = filterCodeObj(typeCodesList, "Text");
      var structureCode = filterCodeObj(typeCodesList, "Structure");

      // Fetch the builder object and flatten it down into an array of unique fields.
      var builderRules = $('#builder').queryBuilder("getRules");
      var filterFieldsList = traverseRulesArr(builderRules);
    
      // We have a structure search if we have any structure search params.
      var hasStructureSearch = structureSearchParams.length;

      // We have a text search if we either have a structure search and more than just one filter field (the filter field would just be
      // "Structure" if we did only have one) or if we don't have a structure search and we have anything at all in the list.
      var hasTextSearch = (hasStructureSearch && filterFieldsList.length > 1) || !hasStructureSearch && filterFieldsList.length;
    
      // Resolve with the Multi-Parameter search if the above are both true, the Structure search if just structureSearch is true,
      // or the Text search if just textSearch is true.
      if (hasTextSearch && hasStructureSearch) {
        resolve(multiParamCode.codeValue);
      } else if (hasStructureSearch) {
        resolve(structureCode.codeValue);
      } else {
        resolve(textCode.codeValue);
      }
    }).catch(function(error) {
      // If there was an error, note it in the console and resolve with an invalid code.
      console.error(error);
      resolve(-1);
    });
  });
}

/**
 * Helper function to traverse the builderRules object and pull out the unique list of field names.
 * @param {JSON} builderRules The builder rules object.
 */
function traverseRulesArr(builderRules) {
  return traverseRulesArrT(builderRules, []);
}

/**
 * Helper function to recursively traverse the builderRulesObject and pull out the unique list of field names.
 * @param {JSON} builderRules The builder rules object.
 * @param {*} ruleNameStrArr The accumulated list of field names we're keeping track of.
 */
function traverseRulesArrT(builderRules, ruleNameStrArr) {

  // If we have a condition field in our current object, then we can go deeper. Run each of the children in this
  // object's "rules" array through this function recursively.
  if ("condition" in builderRules) {
    builderRules["rules"].forEach(function(ruleObj) {
      traverseRulesArrT(ruleObj, ruleNameStrArr)
    });
  }
  // Otherwise, we're on a node so grab the rule name and add it to the accumulator if we don't already have it.
  else {
    var ruleName = builderRules["field"];
    if (!ruleNameStrArr.includes(ruleName)) {
      ruleNameStrArr.push(ruleName);
    }
  }

  return ruleNameStrArr;
}

function addPermissionsFilter(){
  //console.log("ADDING PERMS");
  searchJSON.bool.filter = {};
  searchJSON.bool.filter.terms = {};
  //console.log("ADDED PERMS");
}

function addHistorySearch(){
  //only if this is true
  if ($('#checkhistory')[0].checked) {
      //https://www.elastic.co/guide/en/elasticsearch/reference/current/nested.html

	// When you get here looking for why it's not working on IE...
	// JSON.search is not implemented for IE, so those calls need to be replaced with something like function updateValuesStartingWith

    //MUST
    // using JSON xpath from defiantjs to get the right 
    res = JSON.search( searchJSON, '//must/..|//must_not/..|//should/..');
    res.forEach(function(element) {
      var tempQuery = JSON.parse(JSON.stringify(element)); //Apparently this is how you make a copy in JS
      //term|terms|match
      matchs = JSON.search( tempQuery, '//term|//terms|//match|//wildcard');
      matchs.forEach(function(match){
        Object.keys(match).forEach(function(key){
          match['history.'+key] = match[key];
          delete match[key];
        });
      });

      if (element.must_not !== undefined){
        //MUST_NOT
              //Create an object to hold the history query
        var n = {};
        n.nested = {};
        n.nested.path = 'history';
        n.nested.query = tempQuery.must_not;
        element.must_not.push(n);
      }
      if (element.should !== undefined){
        var n2 = {};
        n2.nested = {};
        n2.nested.path = 'history';
        n2.nested.query = tempQuery.should;
        element.should.push(n2);
      }
      if (element.must !== undefined){
        //MUST
        //move the history query and the orginal query into a "should" block
        var n3 = {};
        n3.nested = {};
        n3.nested.path = 'history';
        n3.nested.query = tempQuery.must;
        if(element.should === undefined){
          element.should = [];
        }
        element.should.push(element.must);
        element.should.push(n3);
        delete element.must;
      }
    });
  }
}

function addDateFormat() {
  return new Promise(function(resolve) {
    var search_arr = searchJSON['bool']['must']
    if (checkType(search_arr, "undefined")) {
      search_arr = searchJSON['bool']['should']
      if (checkType(search_arr, "undefined")) {
        console.log("No Chemical Names found");
        resolve();
      }
    }

    for (i = 0; i < search_arr.length; i++) {
      if (!checkType(search_arr[i]['range'], 'undefined')) {
        var match = search_arr[i]['range'];
        if (!checkType(match["dateCreated"],"undefined")) {
          match["dateCreated"]["format"] = "MM/dd/yyyy";
        }
        if (!checkType(match["dateUpdated"],"undefined")) {
          match["dateUpdated"]["format"] = "MM/dd/yyyy";
        }
      }
    }
    resolve();
  });
}

function formatChemNameSearch() {
  return new Promise(function(resolve) {
    // Update the search JSON to properly search for the selected chemical type and name.

    // Check if this is an "AND" query; if not, check if it's an "OR".
    // If neither, somehow, just stop and end the function.
    var search_arr = searchJSON['bool']['must'];
    if (checkType(search_arr, "undefined")) {
      search_arr = searchJSON['bool']['should']
      if (checkType(search_arr, "undefined")) {
        console.log("No Chemical Names found");
        resolve();
      }
    }

    // Iterate through the query values and replace chem_struct values
    // with appropriate chemical type values.
    for (i = 0; i < search_arr.length; i++) {
      if (!checkType(search_arr[i]['match'], 'undefined')) {
        var match = search_arr[i]['match'];
        if (!checkType(match["chem_struct"],"undefined")) {
          var b_rule = match["chem_struct"]
          var struct_type = $("#chemType_" + b_rule + "_s option:selected").text();
          var struct_val = $("#chemType_" + b_rule + "_t").val();
          match[struct_type] = struct_val;
          delete match["chem_struct"]
        }
      }
    }
    resolve();
  });
}

function prepareStructures(){
  return new Promise(function(resolve) {
    structureSearchParams = [];
    //Grab the mol data from any chemdraw/structure searchs and put it into the input fields
    var promiseArray = [];
    $.each($("[name='StructureSearchField']"), function(index, item){
      var itemId = $(item).attr('value');
      var molType = $(item).parent().find("p > #chemSearchMolType").val();
      var tempPromise = new Promise(function(resolve) {
        getChemistryEditorChemicalStructure(itemId, false, 'mol:V3').then(function(cdxml){
          resolve([cdxml,itemId,molType]);
        });
      });
      promiseArray.push(tempPromise);
    });

    if (promiseArray.length == 0){
      resolve();
    }
    Promise.all(promiseArray).then(function(data){
      data.forEach(function(thisArrayData, index){
        thisMolData = thisArrayData[0];
        itemId = thisArrayData[1];
        var molType = thisArrayData[2];
        var res = JSON.search( searchJSON, '//*[contains(Structure, "' + itemId + '")]' );
    
        //There should only be one, but it returns an array...
        res.forEach(function(element) {
          var searchParam = {};
          searchParam["molData"] = thisMolData;
          searchParam["molType"] = molType;
          searchParam["searchType"] = element.Structure.replace(itemId + "_", "");
		      console.log(searchParam);
          structureSearchParams.push(searchParam);
          element.Structure = [index];
          struc_search = true;
        }, this);
        resolve(structureSearchParams);
      });
    });
  });
}

// Expects the filter result JSON as a Object
function search(colName, order, btn_click) {
  lastCol = colName;
  lastOrder = order;
  $("#outputdiv").html("<p>loading...</p>");
  $("#pagingTableBody").html("");
  //search logic goes here
  var sortByCol;

  if (colName == "fullName" || colName == "e_name" || colName == "notebookName" || colName == "statusName") {
    sortByCol = colName + ".keyword";
  }
  else if (colName == "revisionNumber" || colName == "dateCreated" || colName == "dateUpdated") {
    sortByCol = colName;
  }
  else {
      sortByCol = colName + ".raw";
  }

  determineSearchType().then(function(searchTypeCode) {
    $.ajax({
        method: "POST",
		dataType: "json",
        url: "/arxlab/search/elasticSearch/search/elasticSearchSubmit.asp",
        data: {
          searchJSON: JSON.stringify(searchJSON),
          structureJSON: JSON.stringify(structureSearchParams),
          pageNum: pageNum,
          pageSize: pageSize,
          sortCol: sortByCol,
          sortOrder: order,
          attachments: isAttachmentSearch(),
          includeHistory: $('#checkhistory')[0].checked,
          searchCode: searchTypeCode,
        }
    }).done(function(resultData){
		//console.log("DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1111111");
		//console.log(resultData);
		
		// Populate struc_counts and struc_details from returned data
		struc_counts = {};
		struc_details = [];
		$.each(resultData["structureData"], function(index, item) {
			var strucExpId = "";
			if(item.hasOwnProperty("experiment_id"))
				strucExpId = item["experiment_id"].toString();
			
			if(strucExpId == "")
				return;
			
			var strucExpType = "";
			if(item.hasOwnProperty("experiment_type"))
				strucExpType = item["experiment_type"].toString();
			
			var strucRevNo = "";
			if(item.hasOwnProperty("revision_number"))
				strucRevNo = item["revision_number"].toString();
			
			var strucFileName = "";
			if(item.hasOwnProperty("full_filename"))
				strucFileName = item["full_filename"].toString();
			
			// Populate struc_details
			struc_details.push([strucFileName, strucExpId, strucExpType, strucRevNo]);
			
			// Populate struc_counts
			if(!struc_counts.hasOwnProperty(strucExpId))
				struc_counts[strucExpId] = {"attachments":0,"structures":0};
			
			if(strucFileName.length > 0)
				struc_counts[strucExpId]["attachments"] += 1;
			else
				struc_counts[strucExpId]["structures"] += 1;
		});
		
        try {
          //Clean up the table
          $("#outputdiv").html("");

          // Get search terms for hit identification.
          var attTextSearchWords = getAttachmentSearchValues(searchJSON, "attachmentText");
          var attNameSearchWords = getAttachmentSearchValues(searchJSON, "attachmentNames");

          // Are we doing a search that includes the date of creation?
          var createdSearch = checkDateCreated();

          //Add the header
          var headerHref = ' href="#" onClick="return false;"'
          var notebookHead = "<th id='notebookHead'><a{}><u>Notebook</u></a></th>".replace("{}", headerHref)
          var experimentNameHead = "<th id='experimentNameHead'><a{}><u>Experiment</u></a></th>".replace("{}", headerHref)
          var creatorHead = "<th id='creatorHead'><a{}><u>Creator</u></a></th>".replace("{}", headerHref)
          var resultHitsHead = (attTextSearchWords.length > 0 || attNameSearchWords.length > 0 || hasStructureAttachmentHits) ? "<th>Result Hits</th>" : "";
          var dateHead = "<th id='dateHead'><a{}><u>{dateText}</u></a></th>".replace("{dateText}", (createdSearch ? "Date Created" : "Last Saved"))
          dateHead = dateHead.replace("{}", headerHref)
          var statusHead = "<th id='statusHead'><a{}><u>Status</u></a></th>".replace("{}", headerHref)
          var revisionHead = "<th id='revisionHead'><a{}><u>Revision</u></a></th>".replace("{}", headerHref)
          var tableStr = "<tr id=\"searchTableHeadRow\">" + notebookHead + experimentNameHead + creatorHead + resultHitsHead + dateHead + statusHead + revisionHead + "</tr>";
          
          $("#elasticExperimentsTable").html(tableStr);
          
          $("#elasticExperimentsTable").show();
          $("#elasticPagingTable").show();
          
          //output logic goes here
          var jsonData = resultData["searchResults"];
          var structureResults = resultData["structureData"];
          var numHitsToRemove = 0;
          $.each(jsonData.hits.hits, function (i,hit){
              var src = hit._source;
              var expId = src.experimentId;
              var revNum = src.revisionNumber;

              var chemCount = 0;
              if (struc_search && expId in struc_counts) {
                /*if (!$("#checkhistory").is(":checked")) {
                  if (structureResults.filter(function(struc) {
                    return struc["experiment_id"] == expId && struc["revision_number"] == revNum;
                  }).length <= 0) {
                    numHitsToRemove++;
                    return;
                  }
                }*/

                chemCount = struc_counts[expId]["structures"]
              }
              
              // If we're doing an attachment search, then get the search term(s) and see if there are any matches in
              // the results.
              var textResults = [];
              var nameResults = [];
              if (attTextSearchWords.length > 0) {
                textResults = getAttachmentNameFromText(src.attachmentNames, src.attachmentText, attTextSearchWords, src.attachmentIds, src.experimentType, src.experimentId);
              }
              
              if (attNameSearchWords.length > 0) {
                nameResults = getAttachmentNameFromName(src.attachmentNames, attNameSearchWords, src.attachmentIds, src.experimentType, src.experimentId);
              }
              
              // Check the results if we're doing a structure search and discern whether there's an attachment hit in there.
              var strucResults = findStrucAttachments(struc_details, src.attachmentFileNames, src.attachmentIds, src.attachmentNames, src.experimentType, src.experimentId, src.revisionNumber);
              
              // Combine all three attachment results because the attachment handler does it all the same anyway.
              var attResults = textResults.concat(nameResults.concat(strucResults));

              var colNum = attTextSearchWords.length > 0 || attNameSearchWords.length > 0 || hasStructureAttachmentHits ? 7 : 6;
              var bigDiv =$('<tbody>').attr("colspan",colNum);  
              var row = $('<tr>');
              row.append($('<td>').html("<a href=/arxlab/show-notebook.asp?id="+src.notebookid+ addTargetBlank() +">"+src.notebookName+"</a><p><em>"+src.notebookDesc+"</em></p>"));
              row.append($('<td>').html("<a href="+getExpLink(src.experimentType, src.experimentId)+ addTargetBlank() +">"+src.e_name+"</a><p><em>"+src.e_details+"</em></p>"));
              row.append($('<td>').text(src.fullName));
              var expHits = generateHitsCol(chemCount, attResults);
              if (attTextSearchWords.length > 0 || attNameSearchWords.length > 0 || hasStructureAttachmentHits) {
                row.append($('<td>').html(expHits));
              }
              var creationDate = (checkType(src["dateUpdated"], "undefined") ? "" : src.dateUpdated);
              row.append($('<td>').text(convertLocalTime(createdSearch ? creationDate : src.dateCreated)));
              row.append($('<td>').text(src.statusName));
              row.append($('<td>').text(src.revisionNumber));

              if(src.visible == "0"){
                //however we want to style deleted rows goes here
                row.attr("style","text-decoration: line-through;");
              }
              $(bigDiv).append(row);
              //$("#outputTableBody").append(row);

              // Only show a RXN if we're looking at a chemistry experiment
              if (src.experimentType == '1') {
                var imgrow = $('<tr>');
                var labelrow = $('<tr>')
                var showLabel = false;
                //imgrow.append($('<h2>').text("Test"));

                var myImage = new Image();
                $(myImage).hide();
                $(labelrow).hide();
                myImage.crossOrigin = "Anonymous";
                myImage.onload = function(){
                    var imageData = removeImageBlanks(myImage); //Will return cropped image data"
                    var fixedImage = $('<img>').attr('src',imageData).css('max-width',800).css('max-height',100).css('margin','auto').css('display','block').css('position', 'relative'); 
                    $(this).replaceWith(fixedImage);
                    
                    if (this.width > 1){
                      $(labelrow).show();
                    }
                };
                myDiv = $('<div class="image">').append(myImage);
                imgrow.append($('<td>').attr("colspan",colNum).append(myDiv));
                var imgRowId = "imgRow_" + String(src.experimentId);
                $(myDiv).attr("id", imgRowId)
                //imgrow.append($('<td>').attr("colspan",colNum-1).append(myDiv));
                //$("#outputTableBody").append(imgrow);
                
                replaceText = (struc_search && chemCount == 0) ? " structure match is not in the reaction)" : "";
                var labelText = "Reaction Image{}".replace("{}", replaceText);
                labelrow.append($('<p>').css('max-width',800).css('max-height',100).css('margin','auto').css('display','block').text(labelText));
                $(bigDiv).append($('<td>').attr("colspan",colNum).append(labelrow));
                $(bigDiv).append(imgrow);


                var loadingImg = new Image();
                loadingImg.id = 'img_' + Math.random();
                loadingImg.src = window.location.origin + "/arxlab/images/loading_big.gif"
                loadingImg.style.width = '100px';
                loadingImg.style.height = '100px';

               
                getCdxDashboard(src.experimentId, imgRowId, loadingImg.id);

                
              }
              $("#elasticExperimentsTable").append(bigDiv);
                
          });
        } catch(e) {
          console.log(e.stack);
          swal("","No results found.","info");
          searchButtonStatus("#btn-get-es", false);
        }

        if (jsonData.hits.hits.length - numHitsToRemove == 0) {
          var row = $("<tr>");
          var td = $("<td>").attr("colspan",1).attr("align", "center");
          td.append("No results found.");
          row.append(td);
          $("#pagingTableBody").append(row);
        }

        // Paging buttons
        var row = $('<tr>');
        var td = $('<td>').attr("colspan",7).attr("align","right");
        if(pageNum > 0){
          td.append($('<img>').attr("src","/arxlab/images/resultset_previous.gif").click(function(){pageNum--;search(lastCol, lastOrder, false);}));
        }
        if (jsonData.hits.total.value > (pageNum + 1) * pageSize){
          td.append($('<img>').attr("src","/arxlab/images/resultset_next.gif").click(function(){pageNum++;search(lastCol, lastOrder, false);}));
        }
        row.append(td);
        $("#pagingTableBody").append(row);

        //Show the page number
        $("#pageCount").text("Page Number: "+ (1 + pageNum) + " Total Results: " + (jsonData.hits.total.value - numHitsToRemove));

        //scroll to the top
        $("html, body").animate({ scrollTop: 0 }, "slow");

        searchButtonStatus("#btn-get-es", false);

        if (btn_click) {
          initSortOrder();
        }
        
        // Make the sortable column headers clickable objects and update the sort value
        // when sorted.
        $('#notebookHead').on('click', function(){
          clickSearch("notebookName", notebookHeadOrder, false);
          notebookHeadOrder = setAscDesc(notebookHeadOrder);
        });
        $("#experimentNameHead").on('click', function(){
          clickSearch("e_name", experimentNameHeadOrder, false);
          experimentNameHeadOrder = setAscDesc(experimentNameHeadOrder);
        });
        $("#creatorHead").on('click', function(){
          clickSearch("fullName", creatorHeadOrder, false);
          creatorHeadOrder = setAscDesc(creatorHeadOrder);
        });
        $('#dateHead').on('click', function(){
          clickSearch("dateCreated", dateHeadOrder, false);
          dateHeadOrder = setAscDesc(dateHeadOrder);
        });
        $('#statusHead').on('click', function(){
          clickSearch("statusName", statusHeadOrder, false);
          statusHeadOrder = setAscDesc(statusHeadOrder);
        });
        $('#revisionHead').on('click', function(){
          clickSearch("revisionNumber", revisionHeadOrder, false);
          revisionHeadOrder = setAscDesc(revisionHeadOrder);
        });
    }).fail(function() {
         swal("Error Loading Search",null,'error');
         searchButtonStatus("#btn-get-es", false);
    });
  });
}

function getExpLink(type, expId){
  expPage = "experiment";
  if (type == "2"){
    expPage = "bio-experiment";
  }else if (type == "3"){
    expPage = "free-experiment";
  }else if (type == "4"){
    expPage = "anal-experiment";
  }else if (type == "5") {
    expPage = "cust-experiment";
  }
  return "/arxlab/" + expPage +".asp?id="+expId;
}

function addTargetBlank(){
  // Not 100% sure that target="_blank" doesn't work if _blank isn't surrounded
  // by double quotes so I'm just gonna make this a separate function to make sure.
  return ' target="_blank"';
}

function convertLocalTime(dateString){
  // Takes a dateString of the format "MM/DD/YYYY HH:MM:SS (AM/PM)" to break down
  // and find the actual local time. Really all this does is it breaks apart the
  // given string, constructs a new JS Date object in UTC time (because that's
  // what we get from the db), gets the hours from that because it's now in local
  // time, and reconstruct the original datestring with the localized hours.

  // Short circuiting in the event that we don't have a date to convert because it
  // doesn't exist. This should theoretically only come up in testing until both
  // date fields are properly indexed.
  if (dateString == "") {
    return dateString;
  }

  var dateTimeArr = dateString.split(" ");
  var dateArr = dateTimeArr[0].split("/");
  var timeArr = dateTimeArr[1].split(":");

  // js counts months from 0 so store the month as an int to subtract 1 as needed. thanks js
  var month = parseInt(dateArr[0]);
  var day = dateArr[1];
  var year = dateArr[2];

  // Remember that this is in UTC!
  var hour = timeArr[0];
  var min = timeArr[1];
  var sec = timeArr[2];

  var utcTime = Date.UTC(year, month - 1, day, hour, min, sec);
  var utcDate = new Date(utcTime);
  var locHour = utcDate.getHours();

  var dayTime;
  if (locHour < 12) {
    dayTime = "AM";
  } else {
    dayTime = "PM";
  }

  var retString = dateTimeArr[0] + " " + locHour + ":" + min + ":" + sec + " " + dayTime;

  return retString;
}

function getAttachmentNameFromText(names, text, search_terms, att_ids, expType, expId) {
  // Search all strings in text using the strings in search_terms to find matches.
  
  attResults = [];
  
  // Iterate through all values of text.
  for (i = 0; i < text.length; i++) {
    // Make sure text[i] is an actual string. Values can be null if the associated
    // file doesn't have any associated text.
    if (checkType(text[i], 'string')) {

      // Iterate through all values in search_terms.
      for (j = 0; j < search_terms.length; j++) {

        // If we find a match, add it to the result array and remove the matched strings
        // from the places they were found.
        if (findStringMatch(text[i], search_terms[j])) {
          var f = names[(i * 3)] != "" ? names[(i * 3)] : names[(i * 3) + 1];
          attResults.push(f);

          // Uncomment this block if we want attachment links - i.e. this isn't just generating hover text.
          /*
          if (checkType(att_ids, "undefined")) {
            attResults.push(f);
          } else {
            //attResults.push(genAttLink(expType, expId, att_ids[i], f));
          }*/
          text[i] = "";
          names[(i * 3)] = "";
          names[(i * 3) + 1] = "";
          names[(i * 3) + 2] = "";
        }
      }
    }
  }

  // Return the result array when complete.
  return attResults;
}

function getAttachmentNameFromName(names, search_terms, att_ids, expType, expId) {
  // Search all strings in names using the strings in search_terms to find matches.

  attResults = [];
  // Iterate through names, but only work off of every third value. names has a structure
  // of name,filename,description, so by going three at a time, we're only hitting each file once.
  for (i = 0; i < names.length / 3; i++) {
    // Iterate through all values in search_terms.
    for (j = 0; j < search_terms.length; j++) {

      // If there is a match, add it to the result array and remove the matched file.
      if (findStringMatch(names[i * 3], search_terms[j]) ||
          findStringMatch(names[(i * 3) + 1], search_terms[j]) ||
          findStringMatch(names[(i * 3) + 2], search_terms[j])) {
        var f = names[(i * 3)] != "" ? names[(i * 3)] : names[(i * 3) + 1];
        attResults.push(f);
        
        // Commented out because the attachment IDs aren't being used.
        /**
        if (checkType(att_ids, "undefined")) {
          attResults.push(f);
        } else {
          attResults.push(genAttLink(expType, expId, att_ids[i], f));
        }
        */
        names[(i * 3)] = "";
        names[(i * 3) + 1] = "";
        names[(i * 3) + 2] = "";
      }
    }
  }

  // Return the result array when complete.
  return attResults;
}

function getAttachmentSearchValues(res, field) {
  // Get the search strings used for attachment searching.

  var search_terms = [];

  // Check if this is an "AND" query; if not, check if it's an "OR".
  // If neither, somehow, just stop and end the function.
  var search_arr = res['bool']['must'];
  if (checkType(search_arr, "undefined")) {
    search_arr = res['bool']['should']
    if (checkType(search_arr, "undefined")) {
      return search_terms;
    }
  }

  var match = {}
  // Iterate through the query values and add values if we have valid
  // data for match[field]. This would correspond to
  // searchJSON['bool']['must']['match']['attachmentText'], for example.
  for (i = 0; i < search_arr.length; i++) {
    if (!checkType(search_arr[i]['match'], 'undefined')) {
      match = search_arr[i]['match'];
    } else if (!checkType(search_arr[i]['wildcard'], 'undefined')) {
      match = search_arr[i]['wildcard'];
    }
    if (!checkType(match[field],"undefined")) {
        search_terms.push(match[field]);
    }
  }
  return search_terms;
}

function checkType(obj, typeStr) {
  // Helper function that checks if obj is of type typeStr. Obj can be anything,
  // typeStr is a string.
  return typeof obj == typeStr;
}

function findStringMatch(matchStr, searchStr) {
  searchVal = (searchStr[0] == "*" && searchStr[searchStr.length-1] == "*") ? searchStr.substring(1, searchStr.length-1) : searchStr
  // Helper function that checks if searchStr is in matchStr at all.
  return matchStr.toLowerCase().search(searchVal.toLowerCase()) >= 0;
}

function generateHitsCol(chemCount, attResults) {
  // Generate the HTML for the Hits column for either the attachment search
  // or the structure search.
  var out = "<p{title}>";
  var chemString = "None";
  var bodyString = "None";
  attLength = attResults.length;
  var attsExist = attLength > 0;
  var attString = (attsExist ? attResults.join(", ") : "None");
  if (struc_search) {
    out += "Reaction: " + (chemCount > 0 ? "Yes" : "No") + "<br>" ;
  }
  out += "Attachments: " + (attsExist ? attLength : 0)

  out = out + "</p>";
  out = out.replace("{title}", (attsExist ? ' title="' + attString + '"' : ""))
  return out
}

function substringCount(str, substr) {
  // Count the number of times substr appears in str. Does NOT account for
  // overlap.
  if (checkType(str, "undefined") || str == null) {
    return 0;
  }
  return str.toLowerCase().split(substr.toLowerCase()).length - 1;
}

function countSearchHits(arr, searchArr) {
  // Count the number of times search hits appear in each element of arr.
  var count = 0;
  if (arr == null || checkType(arr, "undefined")) {
    return count;
  }
  for (i=0;i<arr.length;i++) {
    for (j=0;j<searchArr.length;j++) {
      count += substringCount(arr[i], searchArr[j]);
    }
  }
  return count;
}

function findStrucAttachments(fileDetails, srcFiles, att_ids, attNames, expType, expId, revNum) {
  // Structure Search helper method that tries to find matches between the structures if they were
  // found as attachments, and the search results. fileDetails contains a lot of metadata about
  // each structure attachment, taken from the JChem search table. Each element of fileDetails is
  // an array with the structure fileName, experimentId, experimentType and experimentRevision.
  retArr = [];

  if (checkType(srcFiles, "undefined")) {
    return retArr;
  }

  // Iterate through each file's metadata.
  for (i=0;i<fileDetails.length;i++) {

    // Store each field as a local variable for shorthand.
    var fName = fileDetails[i][0];
    var fId = fileDetails[i][1];
    var fType = fileDetails[i][2];
    var fRev = fileDetails[i][3];
    var srcIndex = srcFiles.indexOf(fName);
    
    // If the elasticSearch result contains the current file being looked at AND all three
    // of the other file details match with what was found in the result, then we can get
    // the attachmentId from the elasticSearch result and generate a link.
    if (srcIndex >= 0 &&
        fId == expId &&
        fType == expType &&
        fRev == revNum) {
      
      // If we have a match, then we need to use srcIndex to figure out where in attNames the
      // attachmentName is. attNames has three values for every value of att_ids and srcFiles,
      // so we grab the name by multiplying srcIndex by 3. If the name is blank, then we'll use
      // the filename instead, which is found at (srcIndex * 3) + 1.
      var f = attNames[(srcIndex * 3)] != "" ? attNames[(srcIndex * 3)] : attNames[(srcIndex * 3) + 1];
      retArr.push(f);
      // Comment this out if we want a clickable link and not just hover text.
      //retArr.push(genAttLink(expType, expId, att_ids[srcIndex], f));
    }
  }
  return retArr;  
}

function genAttLink(expType, expId, attId, attName) {
  // Generate an HTML link for attachment links.
  return "<a href="+getExpLink(expType, expId)+"&tab=attachmentTable&attachmentId="+ attId + addTargetBlank() +">"+attName+"</a>";
}

function countExpChemHits(molData, reaction, body, notes) {
  // Count the number of hits in the experiment for the searched molecular formula.
  var chemCount = 0;
  var chemNames = []

  // Start by counting hits in the reaction. We're doing this separate because
  // we want to get the molecule name too, which is stored right before the
  // chemical formula in the reaction list.
  for (i=0;i<molData.length;i++){
    if (!checkType(reaction, "undefined")) {
      reactionHit = reaction.indexOf(molData[i])
      if (reactionHit >= 0) {
        chemCount++;
        if (chemNames.indexOf(molData[i]) < 0) {
          chemNames.push(reaction[reactionHit-1]);
        }
      }
    }
  }

  // Combine our molData and chemNames lists so we can start counting in the other
  // experiment fields.
  molData = molData.concat(chemNames);
  var bodyCount = countSearchHits(body, molData);
  var noteCount = countSearchHits(notes, molData);  

  return [chemCount, bodyCount, noteCount];
}

function isAttachmentSearch() {
  out = false;
  $.each($(".form-control"), function(index, form) {
    var formVal = $(form).val().toLowerCase();
    if (findStringMatch(formVal, "attachment") || findStringMatch(formVal, "_all")) {
      out = true;
    }
  });

  return out;
}

function getRuleCount() {
  // Helper function to get the number of builder rules.
  return document.getElementsByClassName("rules-list")[0].children.length;
}

function searchButtonStatus(btnLabel, disabled) {
  var btnText = disabled ? "Loading..." : "Search"
  $(btnLabel).text(btnText);
  $(btnLabel).prop("disabled", disabled)
}

function setAscDesc(order) {
  return (order == 'asc' ? 'desc' : 'asc');
}

function initSortOrder() {
  // Reset the ordering values to default if the search was done via the button
  notebookHeadOrder = "asc";
  experimentNameHeadOrder = "asc";
  creatorHeadOrder = "asc";
  createdHeadOrder = "desc";
  dateHeadOrder = "desc";
  statusHeadOrder = "asc";
  revisionHeadOrder = "desc";
}

function checkDateCreated() {
  var mustArr = searchJSON.bool.must;
  var createSearch = false;
  if (!checkType(mustArr, "undefined")) {
    for (i = 0; i < mustArr.length & !createSearch; i++) {
      var curRule = mustArr[i];
      if (!checkType(curRule.range, "undefined")) {
        createSearch = checkType(curRule.range.dateCreated, 'undefined');
      }
    }
  } 
  return createSearch;
}

function checkQueryString() {
  var queryString = window.location.search.substring(1).split("&")[0];
  queryString = queryString.split("=")[1];
  return queryString == undefined ? "" : decodeDoubleByteString(unescape(queryString));
}

// text fields are an array of data types that are text based 
const textFields = [1, 2, 9];

/**
 * Build a list of item field filters.
 */
function getRequestItems() {
  return new Promise(function(resolve, reject) {
    // Start by getting the request item information.
  
    $.ajax({
      method: "POST",
      url: "/arxlab/search/ajax/load/getRequestItems.asp",
    }).done(function(result) {      
      var response = JSON.parse(result);
    
      var columnIndexes = [];
      var esFilter = [];
      response = sortArray(response)
      $.each(response, function(reqItemIndex, item) {
        var tableName = item.displayName;

        $.each(item.fields, function(fieldIndex, field) {
          var colName = field.displayName;
          var indexName = tableName + "." + colName;

          if (textFields.includes(field.dataTypeId)) {
          
            if (columnIndexes.indexOf(indexName) < 0) {
              // Build the filter object based on the reqItemObj.
              var filterObj = {
                id: indexName, //The elasticSearch index for a JSON would go [tableName].[colName]
                label: colName,
                type: 'string',
                optgroup: 'Item: ' + tableName,
                operators: ['contains', 'not_contains']
              };
  
              esFilter.push(filterObj);
              columnIndexes.push(indexName);
            }
          }
         
        });

      })
      
      resolve(esFilter);
    });
  })
}

/**
 * Build a list of request type field filters.
 */
function buildRequestTypeFilter() {
  return new Promise(function(resolve, reject) {
    // Start by getting the request field names. This used to be its own function and
    // buildESFilter passed the arguments down to it, but it seems silly to have a function
    // whose only purpose is to pass arguments down into another function with the same
    // signature.
  

    $.ajax({
      method: "POST",
      url: "/arxlab/search/ajax/load/getRequestFieldNames.asp",
    }).done(function(result) {      
   
      result = JSON.parse(result);
      
      var esFilter = []
      var reqFieldIds = [];
      result = sortArray(result)
      $.each(result, function(reqTypeIndex, reqType) {

        var reqFields = reqType.fields;

        $.each(reqFields, function(reqFieldIndex, reqField) {
          var reqFieldName = reqField.displayName;
  
          if (reqFieldName) {
            if (textFields.includes(reqField.dataTypeId)) {
          
              console.log(reqType.displayName);
              // Build a filter object for each request field name and add to the esFilter
              var filterObj = {
                id: reqFieldName,
                label: reqFieldName,
                type: 'string',
                optgroup: reqType.displayName,
                operators: ['contains', 'not_contains']
              };
      
              if (reqFieldIds.indexOf(filterObj.id) < 0 && esFilter.find(function(x){
                  return x.id == filterObj.id;
                }) == undefined) {
                reqFieldIds.push(filterObj.id);
                esFilter.push(filterObj);
              }
            }
          }
        })
          
      });

      // Move on to request items now.
      resolve(esFilter);
    });
  });
}

function initQueryBuilder(esFilters) {
  return new Promise(function(resolve, reject) {
    // Add the all/everything search information here at the very end so it's at the bottom of the list.
    // Note: The hard coded list is due to a limitation by elastic search where you cannot do a phrase prefix query on things that are dates or numbers.
    // This list is aproved by qa/ Amanda.
    esFilters.push({
      id: '_all',
      field: esFilters.filter(function(item){if (![ "Structure","prod_yield","prod_purity","statusId", "dateCreated", "dateUpdated"].includes(item.id)){return(true);}}).map(function(item){return item.id;}),
      label: 'All/Everything Search',
      type: 'string',
      optgroup: 'All',
      operators: ['contains', 'not_contains']
    });

    // Make the query builder.
    $('#builder').queryBuilder({
      plugins: ['bt-tooltip-errors'],      
      filters: esFilters,
      icons: {
        add_group: 'fa fa-plus-square',
        add_rule: 'fa fa-plus-circle',
        remove_group: 'fa fa-minus-square',
        remove_rule: 'fa fa-minus-circle',
        error: 'fa fa-exclamation-triangle',
        clear: 'fa fa-minus-circle'
      },    
      operators: $.fn.queryBuilder.constructor.DEFAULTS.operators.concat([
          { type: 'include',  optgroup: 'Chemical', nb_inputs: 1, multiple: false, apply_to: ['string'] },
          { type: 'exclude',	optgroup: 'Chemical',nb_inputs: 1, multiple: false, apply_to: ['string'] }
        ]),        
      lang: {
          operators: {
            include: 'Include',
            exclude: 'Exclude'
          }
        },
      lang_code: lang_code,    
      rules: rules_basic
    });
    resolve(true);
  })
}

function updateValuesStartingWith(obj, key, oldVal, newVal){
  if (obj instanceof Array) {
    for (var i in obj) {
        updateValuesStartingWith(obj[i], key, oldVal, newVal);
    }
  }

  if (obj[key] && String(obj[key]).startsWith(oldVal)) {
	obj[key] = newVal;
  }

  if ((typeof obj == "object") && (obj !== null) ){
	  var children = Object.keys(obj);
	  if (children.length > 0){
	  	for (i = 0; i < children.length; i++ ){
	        updateValuesStartingWith(obj[children[i]], key, oldVal, newVal);
	  	}
	  }
  }
}

function findValuesStartingWith(obj, key, val){
	return findValuesStartingWithImpl(obj, key, val, []);
}

function findValuesStartingWithImpl(obj, key, val, list) {
  if (!obj) return list;
  if (obj instanceof Array) {
    for (var i in obj) {
        list = list.concat(findValuesStartingWithImpl(obj[i], key, val, []));
    }
    return list;
  }

  if (obj[key] && String(obj[key]).startsWith(val)) {
	  list.push(obj[key]);
  }

  if ((typeof obj == "object") && (obj !== null) ){
	  var children = Object.keys(obj);
	  if (children.length > 0){
	  	for (i = 0; i < children.length; i++ ){
	        list = list.concat(findValuesStartingWithImpl(obj[children[i]], key, val, []));
	  	}
	  }
  }
  return list;
}

/**
 * Function to hit the configSvc to fetch the auditSearchType code set.
 */
function fetchAuditSearchCodes() {
  return new Promise(function(resolve, reject) {
    // If we already have the type codes, then we don't have to do anything.
    if (auditTypeCodes.length) {
      resolve(auditTypeCodes);
    }
    // Otherwise, prep and make a call to the config service to get the code set.
    else {
      var codeUrl = "/webservices/config/api/v1/codes?setName=auditSearchType&appName=ELN";

      $.ajax({
        url: codeUrl,
        headers: {
          Authorization: jwt,
        }
      }).then(function(result) {
        if (result["result"] == "success") {
          try {
            auditTypeCodes = JSON.parse(result["data"]);
          } catch(e) {
            console.error(e);
          }
        } else {
          console.error("Could not retrieve audit codes.");
        }
        resolve(auditTypeCodes);
      });
    }
  });
}

/**
 * Helper function to retrieve a specific code object by codeName.
 * @param {JSON[]} codeList The list of code types.
 * @param {string} codeName The code name to retrieve.
 */
function filterCodeObj(codeList, codeName) {
  var codeObj = {};

  var filteredCode = codeList.filter(function(x) {
    return x.codeDescription == codeName;
  });

  if (filteredCode.length) {
    codeObj = filteredCode[0];
  }

  return codeObj;
}

// 6397 - Watch the page for when the user hits Enter, and if they do, run the search by triggering a click on the button.
// I couldn't find any support for tying the keypress watcher to the querybuilder fields, so this will have to do.
// For some reason, the query builder doesn't like it when you try to search immediately the first time you use an input,
// so we're going to focus on the search button first.
$(document).keypress(function(e) {
  if(e.key == "Enter") {
    $("#btn-get-es").focus();
    $("#btn-get-es").click();
  }
});

/**
* Sort an array of JSON by the displayName key
* @param {JSON[]} arr Array to sort
* @returns {JSON[]}
*/
var sortArray = function(arr) {
  return arr.sort(function(a, b) {
    if (a.displayName < b.displayName) return -1;
    if (a.displayName > b.displayName) return 1;
    return 0;
  });
}
