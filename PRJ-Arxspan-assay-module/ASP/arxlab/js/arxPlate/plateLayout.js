var templateSpec = {
    'startPos': { 'x':1, 'y':1 },
    'plateWidth': 12,
    'plateHeight': 8,
    'reservedWells': [],
	'numSamples': 1,
	'numReplicates': 2,
	'numDilutions': 2,

    'samplePattern': {'wrap': false,
					  'samePlate': true,
					  'primaryLayout': 'topToBottom',
					  'secondaryLayout': 'leftToRight' },
    'replicatePattern': {'interleave': false, 					// Not implemented yet.
						 'orientation': 'horizontal',
					     'primaryLayout': 'rightToLeft',
					     'secondaryLayout': 'leftToRight' }, 	// Not implemented. This is used when samples are allowed be discontinuous.
    'dilutionPattern': { 'interleave': false, 					// Not implemented yet.
						 'flow': 'upstream'}
 }
 
function makePlateMaps() {
	var processData = setupProcessData(templateSpec);

	console.log('makePlateMaps starting with templateSpec: ' + JSON.stringify(templateSpec) + ' and processData: ' + JSON.stringify(processData));
	for(var sampleNo = 0; sampleNo < templateSpec['numSamples']; sampleNo++)
	{
		processData = findNextSampleWell(templateSpec, processData);
		
		for(var replicateNo = 0; replicateNo < templateSpec['numReplicates']; replicateNo++)
		{
			processData = findNextReplicateWell(templateSpec, processData);
			
			for(var dilutionNo = 0; dilutionNo < templateSpec['numDilutions']; dilutionNo++)
			{
				processData = findNextDilutionWell(templateSpec, processData);
				
				var thisDilution = JSON.parse(JSON.stringify(processData['currPos']));
				thisDilution['sampleNum'] = sampleNo;
				thisDilution['replicateNum'] = replicateNo;
				thisDilution['dilutionNum'] = dilutionNo;
				
				processData['plateMap'][processData['currPlate']].push(thisDilution);
			}
		}
	}
	
	templateSpec['plateMap'] = processData['plateMap'];
	console.log('returning templateSpec: ' + JSON.stringify(templateSpec));
	return templateSpec;
}

function findNextDilutionWell(templateSpec, processData) {
	if(isWellAvailable(templateSpec, processData, processData['currPos']))
		return processData;
	
	var dilUnit = 1;
	if(templateSpec['dilutionPattern']['interleave'] === true)
		dilUnit = 2;
	
	var dilPhase = 1;
	if(templateSpec['dilutionPattern']['flow'] === 'upstream')
		dilPhase = -1;
	
	var shift = {'x':0, 'y':0};
	if(templateSpec['replicatePattern']['orientation'] === 'horizontal')
		shift['x'] = dilUnit * dilPhase;
	else if(templateSpec['replicatePattern']['orientation'] === 'vertical')
		shift['y'] = dilUnit * dilPhase;

	processData['currPos']['x'] += shift['x'];
	processData['currPos']['y'] += shift['y'];
	return processData;
}

function findNextReplicateWell(templateSpec, processData) {
	if(isWellAvailable(templateSpec, processData, processData['currPos']))
		return processData;

	var shift = {'x':0, 'y':0};
	var flow = templateSpec['dilutionPattern']['flow'];
	var orientation = templateSpec['replicatePattern']['orientation'];
	var primaryLayout = templateSpec['replicatePattern']['primaryLayout'];
	
	if(primaryLayout === 'topToBottom' || primaryLayout === 'bottomToTop')
	{
		if(orientation === 'horizontal')
		{
			shift['y'] += 1;
			if(primaryLayout === 'bottomToTop')
				shift['y'] *= -1;

			shift['x'] += -1 * (templateSpec['numDilutions'] - 1);
			if(flow === 'upstream')
				shift['x'] *= -1;
		}
		else if(orientation === 'vertical')
		{
			if(flow === 'upstream')
				if(primaryLayout === 'topToBottom')
					shift['y'] += templateSpec['numDilutions'] + 1;
			else if(flow === 'downstream')
				if(primaryLayout === 'bottomToTop')
					shift['y'] += -1 * (templateSpec['numDilutions'] + 1);
		}
	}
	else if(primaryLayout === 'leftToRight' || primaryLayout === 'rightToLeft')
	{
		if(orientation === 'vertical')
		{
			shift['x'] += 1;
			if(primaryLayout === 'rightToLeft')
				shift['x'] *= -1;
				
			shift['y'] +=  -1 * (templateSpec['numDilutions'] - 1);
			if(flow === 'upstream')
				shift['y'] *= -1;
		}
		else if(orientation === 'horizontal')
		{
			if(flow === 'upstream')
				if(primaryLayout === 'leftToRight')
					shift['x'] += templateSpec['numDilutions'] + 1;
			else if(flow === 'downstream')
				if(primaryLayout === 'rightToLeft')
					shift['x'] += -1 * (templateSpec['numDilutions'] + 1);
		}
	}
		
	processData['currPos']['x'] += shift['x'];
	processData['currPos']['y'] += shift['y'];
	console.log('updated position: ' + JSON.stringify(processData['currPos']));

	return processData;
}

function findNextSampleWell(templateSpec, processData) {
	if(isWellAvailable(templateSpec, processData, processData['currPos']))
		return processData;

	// Traverse the primaryLayout axis from the start position until we find a space the sample will fit in
	var testPos = JSON.parse(JSON.stringify(templateSpec['startPos']));
	var primaryLayout = templateSpec['samplePattern']['primaryLayout'];
	var secondaryLayout = templateSpec['samplePattern']['secondaryLayout'];
	console.log('findNextSampleWell; testPos: ' + JSON.stringify(testPos));
	
	processData['currPos'] = JSON.parse(JSON.stringify(testPos));
	console.log('returning currPos: ' + JSON.stringify(processData['currPos']));
	return processData;
}

function setupProcessData(templateSpec) {
	// Initialize some status variables
	var processData = {};
	processData['currPlate'] = 0;
	processData['plateMap'] = [];
	processData['plateMap'].push([]);
	processData['currPos'] = JSON.parse(JSON.stringify(templateSpec['startPos']));
	
	// Figure out some metrics we will need all the time
	processData['repSize'] = templateSpec['numReplicates'];
	if(templateSpec['replicatePattern']['interleave'] === true)
		processData['repSize'] *= 2;

	processData['dilSize'] = templateSpec['numDilutions'];
	if(templateSpec['dilutionPattern']['interleave'] === true)
		processData['dilSize'] *= 2;

	var dilutionLayout = templateSpec['dilutionPattern']['primaryLayout'];
	if(dilutionLayout === 'leftToRight' || dilutionLayout === 'rightToLeft')
		processData['sampleSize'] = {'width': processData['dilSize'], 'height': processData['repSize']};
	else
		processData['sampleSize'] = {'width': processData['repSize'], 'height': processData['dilSize']};
	
	return processData;
}

function isWellAvailable(templateSpec, processData, coords) {
	// Is this a reserved well?
	for(var i = 0; i < templateSpec['reservedWells'].length; i++)
		if(templateSpec['reservedWells'][i]['x'] === coords['x'] && templateSpec['reservedWells'][i]['y'] === coords['y'])
			return false;

	// Did we already put something here?
	for(var i = 0; i < processData['plateMap'][processData['currPlate']].length; i++)
		if(processData['plateMap'][processData['currPlate']][i]['x'] === coords['x'] && processData['plateMap'][processData['currPlate']][i]['y'] === coords['y'])
			return false;
		
	// Free to use.
	return true;
}