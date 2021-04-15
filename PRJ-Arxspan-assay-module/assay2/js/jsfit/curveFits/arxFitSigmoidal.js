var arxFitSigmoidal = function() {
	// fit type (should be unique)
	this.type = 'arxFitSigmoidal';
	// parameters from the fit that should be displayed on the plot image
	this.displayParameters = ['hillSlope','inflectionPoint'];
	// names of parameters that are used in the curve fit (these are passed in the fitOptions object)
	this.curveParameterNames = ['minAsymptote', 'hillSlope', 'inflectionPoint', 'maxAsymptote'];
	// Display names for the initial, minimum and maximum values for the parameters in the array above
	this.curveParameterConditions = ['Initial Value','Fixed','Min Value','Max Value', 'Calculated Outputs'];
	
	// Object defining the display label for each condition in the array above, and the names of the assay Data Dictionary elements that correspond to them
this.parameterDisplayConfig = {
		minAsymptote:{label:'Min Asymptote', conditions:['Sigmoidal Lower Bound Initial Value','Fixed Sigmoidal Lower Bound','Sigmoidal Lower Bound Minimum Value','Sigmoidal Lower Bound Maximum Value','Sigmoidal Calculated Value']},
		hillSlope:{label:'Hill Slope', conditions:['Hill Slope Initial Value','Fixed Hill Slope','Hill Slope Minimum Value','Hill Slope Maximum Value','Hill Slope Calculated Value']},
		inflectionPoint:{label:'Inflection Point', conditions:['Inflection Point Initial Value','Fixed Inflection Point','Inflection Point Minimum Value','Inflection Point Maximum Value', 'Inflection Point Calculated Value']},
		maxAsymptote:{label:'Max Asymptote', conditions:['Sigmoidal Upper Bound Initial Value','Fixed Sigmoidal Upper Bound','Sigmoidal Upper Bound Minimum Value','Sigmoidal Upper Bound Maximum Value', 'Sigmoidal Upper Bound Calculated Value']}
		//calOutputs:{label:'Calculated Outputs', conditions:['Calculated Outputs Initial Value','Fixed Calculated Outputs','Calculated Outputs Minimum Value','Calculated Outputs Maximum Value']}
	};
}

// The curve fit function
arxFitSigmoidal.curveFunction = function (x, params) {
	var minAsymptote = params[0];
	var hillSlope = params[1];
	var inflectionPoint = params[2];
	var maxAsymptote = params[3];
	return minAsymptote + (maxAsymptote - minAsymptote) / (1 + Math.pow(10, ((inflectionPoint - x) * hillSlope)));
}

// The initial guesses for the fit parameters if they have not been provided by the user
arxFitSigmoidal.calculateInitialFitParams = function(xVals, yVals, params, parInfo) {
	var maxY = Math.max(...yVals);
	var minY = Math.min(...yVals);
	var avgX = numeric.sum(xVals) / xVals.length;	
	var slope = (maxY - minY) / (xVals[yVals.indexOf(maxY)] - xVals[yVals.indexOf(minY)]);

	var passParams = [minY, slope, avgX, maxY];
	for(var param in params)
		if(params[param] != undefined)
			passParams[param] = params[param];
		
	return passParams;
}
