var arxFit = function(fitType) {
	this.fitType = fitType;
}

arxFit.prototype.help = function() {
	return 'Call the fitCurve function with the following parameters: fitType, xVals[], yVals[], params[] and parInfo{}.';
}

arxFit.prototype.arxFitPlotCurve = function (xLow, xHigh, func, resolution)
{
	var x = [], y = [];
	var step = (xHigh-xLow)/resolution;
	for (var i = xLow; i < xHigh; i += step)
	{
		x.push(i);
		y.push(func(i));
	}

	return {'x':x, 'y':y};
}

arxFit.prototype.fitCurve = function(xVals, yVals, params, parInfo) {
	if(xVals.length <= 0 || (xVals.length !== yVals.length))
		return {'error':'xVals and yVals arrays must be of the same nonzero length'};

	var fitObj = {};
	var fitterOptions = {'parInfo':parInfo,'maxIterations':1000};
	var passParams = window[this.fitType.type]['calculateInitialFitParams'](xVals, yVals, params, parInfo);
	
	var retVal = {'initialParams':passParams, 'fitOptions':fitterOptions};
	fitObj = jsfit.fit(window[this.fitType.type]['curveFunction'], [xVals, yVals], passParams, fitterOptions);

	if(fitObj['r2'])
		retVal['r2'] = fitObj['r2'];

	if(fitObj['params'])
		retVal['params'] = fitObj['params'];
	
	if(Object.keys(retVal).length === 0)
		retVal['error'] = 'There was an unknown error';
	
	return retVal;
/*	
	var avgX = numeric.sum(xVals) / xVals.length;
	var avgY = numeric.sum(yVals) / yVals.length;
	
	var maxYpos = 0, maxY = yVals[0], minYpos = 0, minY = yVals[0];
	for(var i=0; i < yVals.length; i++)
	{
		if(yVals[i] > maxY) {
			maxY = yVals[i];
			maxYpos = i;
		}
		
		if(yVals[i] < minY) {
			minY = yVals[i];
			minYpos = i;
		}
	}
	
	var yIntercept = 0, expAsymptote = 0, expRate = 1;
	var slope = (maxY - minY) / (xVals[maxYpos] - xVals[minYpos]);
	if(slope > 0)
	{
		yIntercept = minY;
		expAsymptote = maxY;
	}
	else
	{
		expRate *= -1;
		yIntercept = maxY;
		expAsymptote = minY;
	}

	var fitObj = {};
	var fitterOptions = {'parInfo':parInfo,'maxIterations':1000};
	var retVal = {'fitType':fitType,'initialParams':params, 'fitOptions':fitterOptions};
	
	if(fitType === 'linear')
	{
		var passParams = [slope, yIntercept];
		for(var param in params)
			if(params[param] != undefined)
				passParams[param] = params[param];
			
		fitObj = jsfit.fit(arxFitLinear, [xVals, yVals], passParams, fitterOptions);

		retVal['r2'] = fitObj['r2'];
		retVal['params'] = fitObj['params'];
		retVal['paramNames'] = ['slope', 'yIntercept'];
	}
	else if(fitType === 'exponential')
	{
		var passParams = [expAsymptote, yIntercept, expRate];
		for(var param in params)
			if(params[param] != undefined)
				passParams[param] = params[param];
			
		fitObj = jsfit.fit(this.curveFits[fitType], [xVals, yVals], passParams, fitterOptions);

		retVal['r2'] = fitObj['r2'];
		retVal['params'] = fitObj['params'];
		retVal['paramNames'] = ['asymptote', 'intercept', 'rate'];
	}
	else if(fitType === 'logarithmic')
	{
		var passParams = [maxY, avgY];
		for(var param in params)
			if(params[param] != undefined)
				passParams[param] = params[param];
			
		fitObj = jsfit.fit(this.curveFits[fitType], [xVals, yVals], passParams, fitterOptions);

		retVal['r2'] = fitObj['r2'];
		retVal['params'] = fitObj['params'];
		retVal['paramNames'] = ['largestValue', 'averageValue'];
	}
	else if(fitType === 'sigmoidal')
	{
		var passParams = [minY, slope, avgX, maxY];
		for(var param in params)
			if(params[param] != undefined)
				passParams[param] = params[param];
			
		fitObj = jsfit.fit(this.curveFits[fitType], [xVals, yVals], passParams, fitterOptions);

		retVal['paramNames'] = ['minAsymptote', 'hillSlope', 'inflectionPoint', 'maxAsymptote'];
	}

	if(fitObj['r2'])
		retVal['r2'] = fitObj['r2'];

	if(fitObj['params'])
		retVal['params'] = fitObj['params'];
	
	if(Object.keys(retVal).length === 0)
		retVal['error'] = 'There was an unknown error';
	
	return retVal;
*/
}

function arxFitLogarithmic(x, params) {
  var largestValue = params[0]; 
  var averageValue = params[1]; 
  return largestValue + (averageValue * Math.log(x));
}

function arxFitLinear(x, params)
{
	slope = params[0];
	yIntercept = params[1];
	return slope*x + yIntercept;
}

function arxFitExponential(x, params)
{
	var asymptote = params[0];
	var intercept = params[1];
	var rate = params[2];
	return (asymptote + intercept * Math.exp(rate * x));
}

