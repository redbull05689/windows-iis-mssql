function Molecule(theMol) {
	this.molFile = (theMol['molFile'] || '');
	
	this.attrList = Object.keys(theMol);
	this.attrList.splice(this.attrList.indexOf('molFile'), 1);
	
	this.attrVals = {};
	for(var i = 0; i < this.attrList.length; i++)
		this.attrVals[this.attrList[i]] = theMol[this.attrList[i]];
}

Molecule.prototype = {
	constructor:Molecule,
	
	molFile:function() {
		return this.molFile;
	},
	
	attributes:function() {
		return this.attrList;
	},
	
	getValues:function(attr) {
		return this.attrVals[attr];
	},
	
	isValid:function() {
		return this.molFile.endsWith('END') || this.molFile.endsWith('END\n');
	}
}
	
function SDFReader(fileContents) {
	this.fileContents = fileContents;
	this.molecules = [];
}

SDFReader.prototype = {
	constructor:SDFReader,
	
	getMolecules:function() {
		if(this.molecules.length == 0)
			this._parseFileContents();
		
		return this.molecules;
	},
	
	_parseFileContents:function() {
		var fileLines = this.fileContents.replace(new RegExp('\r', 'g'), '').split('\n');
		
		var theRecord = '';
		for(var i = 0; i < fileLines.length; i++) {
			while(i < fileLines.length && !fileLines[i].includes('$$$$')) {
				theRecord += fileLines[i] + '\n';
				i++;
			}
			
			theRecord += fileLines[i];

			theMol = this._parseSdfRecord(theRecord);
			if(theMol.isValid()) {
				this.molecules.push(theMol);
			}
			
			theRecord = '';
		};
	},
	
	_parseSdfRecord:function(theRecord) {
		var recordLines = theRecord.split('\n');
		
		var i = 0, theMol = {'molFile':''};
		for(; i < recordLines.length; i++) {
			theMol['molFile'] += recordLines[i] + '\n';
			
			if(recordLines[i].startsWith('M') && recordLines[i].endsWith('END'))
				break;
		}

		var theKey = '';
		for(; i < recordLines.length; i++) {
			if(recordLines[i].includes('$$$$'))
				break;
			
			if(recordLines[i].length == 0) {
				theKey = '';
				continue;
			}
			
			if(recordLines[i].startsWith('>') && (recordLines[i].match(new RegExp('>', 'g')) || []).length === 2 && (recordLines[i].match(new RegExp('<', 'g')) || []).length === 1) {
				theKey = recordLines[i].substring(recordLines[i].indexOf('<') + 1, recordLines[i].lastIndexOf('>'));
				
				if(theKey.length > 0)
					if(!theMol.hasOwnProperty(theKey))
						theMol[theKey] = [];
					
				continue;
			}
			
			if(theKey.length > 0)
				theMol[theKey].push(recordLines[i]);
		}
		
		return new Molecule(theMol);
	}
}

function SDFWriter(jsonArray) {
	this.jsonArray = (jsonArray || []);
	this.sdFile = '';
}

SDFWriter.prototype = {
	constructor:SDFWriter,
	
	getSDFile:function() {
		if(this.sdFile.length == 0)
			this._makeSDF();
		
		return this.sdFile;
	},
	
	_makeSDF:function() {
		var parser = this;
		$.each(this.jsonArray, function(index, value) {
			var sdRecord = {'sdText':'','foundMolFile':false};
			parser._writeSD(value, sdRecord);

			if(!sdRecord['foundMolFile'])
				sdRecord['sdText'] = 'Untitled\n  noStructureSDF\nno comment\n  0  0  0  0  0  0  0  0  0  0999 V2000\nM  END\n' + sdRecord['sdText'];

			if(sdRecord['sdText'].length > 0)
				parser.sdFile += sdRecord['sdText'] + '$$$$\n';
		});
	},
	
	_writeSD:function(value, sdRecord) {
		if(!sdRecord['foundMolFile'] && value.hasOwnProperty('molFile') && value['molFile'].length > 0)
		{
			sdRecord['sdText'] = value['molFile'] + '\n' + sdRecord['sdText'];
			sdRecord['foundMolFile'] = true;
		}

		if(value.hasOwnProperty('numComponents'))
			delete value['numComponents'];
		
		if(value.hasOwnProperty('wellCoordinates'))
			delete value['wellCoordinates'];
			
		var parser = this;
		$.each(Object.keys(value), function(i, val) {
			if(value[val] instanceof Object && (Object.prototype.toString.call(value[val]) !== '[object Array]' || value[val][0] instanceof Object))
			{
				parser._writeSD(value[val], sdRecord);
			}
			else if(val != 'molFile')
			{
				sdRecord['sdText'] += '> <' + val + '>\n';
				var values = [].concat(value[val]);
				
				$.each(values, function(j, v) {
					sdRecord['sdText'] += v + '\n';
				});
				
				sdRecord['sdText'] += '\n';
			}
		});
	}
}
