// ****** Name: Single Cpd EC50 *******

// Cell EC50 assay
//
// The average background is subtracted from all signals, and the background-subtracted
// average of DMSO controls is set as 100% activity, while the background is set
// as 0% activity. The % activity of each sample is calculated using the
// following formula:
//
// % Activity = {{ Signal - Average Background } / { DMSO Average - Average Background }} * 100
//
// The curve fits will be performed by Arxspan Assay with 4-parameter (sigmoidal) fit using
// the following formula:
//
// Y = Bottom + (Top - Bottom) / (1 + 10 ^ ((LogIC50 - X) * HillSlope))
//
// Constraints: Bottom == 0; Top < 120
//
// Curve fits will be performed only when the % Activity at the highest concentration
// of compound is less than 65%
//

var getAssayResultFloat = function(theNumber, howManyDecimals)
{
	var numDigits = howManyDecimals + 4;
	var regExp = new RegExp('^-?\\d*\\.?0*\\d{0,'+numDigits+'}');
	var match = theNumber.toFixed(20).match(regExp)[0];
	return decimalAdjust('round', theNumber, -(match.length - 4));
}

var decimalAdjust = function(type, value, exp) {
    // If the exp is undefined or zero...
    if (typeof exp === 'undefined' || +exp === 0) {
        return Math[type](value);
    }
    value = +value;
    exp = +exp;
    // If the value is not a number or the exp is not an integer...
    if (isNaN(value) || !(typeof exp === 'number' && exp % 1 === 0)) {
        return NaN;
    }
    // Shift
    value = value.toString().split('e');
    value = Math[type](+(value[0] + 'e' + (value[1] ? (+value[1] - exp) : -exp)));
    // Shift back
    value = value.toString().split('e');
    return +(value[0] + 'e' + (value[1] ? (+value[1] + exp) : exp));
}

// Utility function for loading data to be displayed as exponents
var loadExp = function(valArray, concArray)
{
	// This is the sample concentration column
	for(var j=0; j < valArray.length; j++)
	{
		var num = Number.parseFloat(valArray[j]);
		if(!isNaN(num))
		{
			concArray.push(num);
			valArray[j] = num.toExponential(2);

			if(highConc['value'] < num)
			{
				highConc['index'] = j;
				highConc['value'] = num;
			}
		}
		else
		{
			concArray.push(valArray[j]);
		}
	}
}

// Sample data
var cpdSignal = thisResult.getFieldByName('Compound Signal').value;
if(!cpdSignal || cpdSignal.length <= 0)
	return;

// setup the serial dilutions
var topConc = parseFloat(thisResult.getFieldByName('Top Concentration (uM)').value);
var dilutionFactor = parseFloat(thisResult.getFieldByName('Dilution Factor').value);
var sampleConcentrations = [];
for(var i = 0; i < cpdSignal.length; i++)
{
	var conc = topConc;
	if(i > 0)
		conc = getAssayResultFloat(sampleConcentrations[i-1] * dilutionFactor, 4);

	sampleConcentrations.push(conc);
}

// Samples run from low to high concentration
sampleConcentrations = sampleConcentrations.reverse();

// Calculate % Activity
var background = 0;
var activities = [];
var dmsoSignal = thisResult.getFieldByName('DMSO Signal').value;
var controlSignal = thisResult.getFieldByName('Control Signal').value;
thisResult.getFieldByName('DMSO Percent Activity').value = decimalAdjust('round', (dmsoSignal / controlSignal) * 100, -2);

for(var i in cpdSignal)
{
	var pctInh = (cpdSignal[i] / controlSignal) * 100;
	pctInh = decimalAdjust('round', pctInh, -2);
	activities.push(pctInh);
}

// We will use log concentration on the x-axis so only calculate it once
var logConc = JSON.parse(JSON.stringify(sampleConcentrations));
for(var conc in logConc)
	logConc[conc] = Math.log10(logConc[conc]);

// Get initial parameters
var initialParams = [];
var initialParamList = ['Sigmoidal Lower Bound Initial Value','Hill Slope Initial Value','Inflection Point Initial Value','Sigmoidal Upper Bound Initial Value'];
for(var param in initialParamList)
{
	if(thisResult.getFieldByName(initialParamList[param]))
	{
		var val = thisResult.getFieldByName(initialParamList[param]).value;
		var num = Number.parseFloat(val);
		if(!isNaN(num))
			initialParams.push(num);
		else
			initialParams.push(undefined);
	}
	else
		initialParams.push(undefined);
}

// Get fixed parameters
var fitParams = [];
var fitParamList = [];
fitParamList.push({"fitParam":"minAsymptote",
					"params":[	{'resultSetName':'Fixed Sigmoidal Lower Bound','fitName':'fixed','type':'boolean'},
								{'resultSetName':'Sigmoidal Lower Bound Minimum Value','fitName':'minVal','type':'number'},
								{'resultSetName':'Sigmoidal Lower Bound Maximum Value','fitName':'maxVal','type':'number'}]
				  });

fitParamList.push({"fitParam":"hillSlope",
					"params":[	{'resultSetName':'Fixed Hill Slope','fitName':'fixed','type':'boolean'},
								{'resultSetName':'Hill Slope Minimum Value','fitName':'minVal','type':'number'},
								{'resultSetName':'Hill Slope Maximum Value','fitName':'maxVal','type':'number'}]
				  });

fitParamList.push({"fitParam":"inflectionPoint",
					"params":[	{'resultSetName':'Fixed Inflection Point','fitName':'fixed','type':'boolean'},
								{'resultSetName':'Inflection Point Minimum Value','fitName':'minVal','type':'number'},
								{'resultSetName':'Inflection Point Maximum Value','fitName':'maxVal','type':'number'}]
				  });

fitParamList.push({"fitParam":"maxAsymptote",
					"params":[	{'resultSetName':'Fixed Sigmoidal Upper Bound','fitName':'fixed','type':'boolean'},
								{'resultSetName':'Sigmoidal Upper Bound Minimum Value','fitName':'minVal','type':'number'},
								{'resultSetName':'Sigmoidal Upper Bound Maximum Value','fitName':'maxVal','type':'number'}]
				  });

for(var param in fitParamList)
{
	var paramObj = fitParamList[param];
	if(paramObj['fitParam'] && paramObj['params'] && paramObj['params'].length > 0)
	{
		var fitObj = {name:paramObj['fitParam']};
		for(var val in paramObj['params'])
		{
			var theObj = paramObj['params'][val];
			if(theObj['fitName'] && theObj['resultSetName'] && theObj['type'])
			{
				var theVal = undefined;
				if(theObj['type'] === 'boolean')
					theVal = false;

				if(resultSet.getFieldByName(theObj['resultSetName']))
					theVal = resultSet.getFieldByName(theObj['resultSetName']).value;

				if(theVal === undefined || theVal.length === 0)
					continue;

				if(theObj['type'] === 'number')
					theVal = Number.parseFloat(theVal);

				fitObj[theObj['fitName']] = theVal;
			}
		}

		fitParams.push(fitObj);
	}
}

var thisSample = {};
thisSample['fitType'] = new arxFitSigmoidal();
thisSample.fitType.parameterDisplayConfig.inflectionPoint.label = 'EC50 (uM)';

// Calculate IC0 and Hill Slope
var fitObj = {};
thisSample['x'] = logConc;
thisSample['y'] = activities;
thisSample['fitOptions'] = fitParams;
thisSample['initialParams'] = initialParams;

try {
	var curveFit = new arxFit(thisSample['fitType']);
	fitObj = curveFit.fitCurve(thisSample['x'], thisSample['y'], thisSample['initialParams'], thisSample['fitOptions']);
}
catch(err) {
	console.log('curve fit caught error:', err);
}

// populate hill slope and IC50
if(fitObj['params'])
{
	// populate ic50
	var ic50raw = Math.pow(10, fitObj['params'][2]);
	var ic50clean = ic50raw.toPrecision(3);

	thisSample['IC50'] = ic50clean;
	thisSample['params'] = fitObj['params'];
	thisSample['hillSlope'] = decimalAdjust('round', fitObj['params'][1], -2);

	if(fitObj['r2'])
		thisSample['r2'] = decimalAdjust('round', fitObj['r2'], -2);
}

if(thisSample['hillSlope'])
	thisResult.getFieldByName('Hill Slope').value = thisSample['hillSlope'];

if(thisSample['IC50'])
	thisResult.getFieldByName('EC50 (uM)').value = thisSample['IC50'];

//thisResult.getFieldByName('Cell Line').value = thisSample['compoundId'];
thisResult.getFieldByName('Percent Activity').value = activities;

var curveData = {};
curveData['params'] = thisSample['params'];
curveData['fitType'] = thisSample['fitType'];
curveData['fitOptions'] = thisSample['fitOptions'];
curveData['initialParams'] = thisSample['initialParams'];

curveData['pointData'] = [];
for(var i in thisSample['x'])
	curveData['pointData'].push([thisSample['x'][i], thisSample['y'][i]]);

thisResult['value'] = JSON.stringify(curveData);
var thePlot = new KnockoutPlot(thisResult, 'getImage');
curveData['image'] = thePlot.getImage();

thisResult.getFieldByName('IC50 Curve').value = JSON.stringify(curveData);
thisResult.getFieldByName('Compound ID').value = thisResult.getFieldByName('Compound ID List').value;

// Heat map properties
var heatMapProperties = {
	plateIdField:"",
	curveDataField:"IC50 Curve",
	curveLabelFields:["Compound ID","Cell Line"],
	columnLabels:sampleConcentrations,
	rowLabelField:"Cell Line",
	fieldsToHide:["Top Concentration (uM)", "Dilution Factor", "Data", "Compound Signal", "Percent Activity", "Well Address", "Compound ID", "Compound ID List", "Cell Lines Tested", "Cell Line"],
	readOnlyWells:[		{wellRowField:'emptyRowId',wellColumnField:'emptyColumnId',displayValueField:'topEmptyWellReads'},
						{wellRowField:'emptyLeftRowId',wellColumnField:'emptyLeftColumnId',displayValueField:'emptyLeftColumnReads'},
						{wellRowField:'emptyRightRowId',wellColumnField:'emptyRightColumnId',displayValueField:'emptyRightColumnReads'},
						{wellRowField:'emptyBottomRowId',wellColumnField:'emptyBottomColumnId',displayValueField:'emptyBottomRowReads'},
						{wellRowField:'dmsoRow',wellColumnField:'dmsoColumn',displayValueField:'DMSO Percent Activity',heatMap:true}
				  ],
	displayOnlyWells:[	{displayValue:100,wellColumn:'6',wellRow:'B',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'C',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'D',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'E',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'F',heatMap:true},
						{displayValue:100,wellColumn:'6',wellRow:'G',heatMap:true}
					 ]
};

for(var i = 0; i < allResults.length; i++)
{
	if(allResults[i] === thisResult)
	{
		thisResult.getFieldByName('Cell Line').value = thisResult.getFieldByName('Cell Lines Tested').value[i];;
		break;
	}
}

// Add column labels to heat map
if(heatMapProperties.columnLabels.length == 0)
	heatMapProperties.columnLabels.push('');
$.each(heatMapProperties.columnLabels, function(i, label) { heatMapProperties.columnLabels[i] = heatMapProperties.columnLabels[i].toString().substring(0,5); });
heatMapProperties.columnLabels.splice(4, 0, 'No Trt');
heatMapProperties.columnLabels.splice(5, 0, 'DMSO');
heatMapProperties.columnLabels.splice(0, 0, '');
heatMapProperties.columnLabels.push('');

thisResult.getFieldByName('heatMapProperties').value = JSON.stringify(heatMapProperties);






