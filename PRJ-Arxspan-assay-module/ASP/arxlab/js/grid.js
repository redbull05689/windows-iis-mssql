function trim(stringToTrim) {
	return stringToTrim.replace(/^\s+|\s+$/g,"");
}

limittingEquivalents = '';
limittingMoles = '';

var sigdigs = 2;

function uncheckClass(cName)
{
	els = document.getElementsByTagName("input")
	for(i=0;i<els.length;i++)
	{
		var type = els[i].getAttribute("type");
		if (type && type.toLowerCase() == "checkbox")
		{
			if (els[i].className == cName)
			{
				els[i].checked = false;
				experimentJSON[els[i].id] = "";
			}
		}
	}
}

function setAllObjectsOfType(obType,name,value,caller)
{
	els = document.getElementsByTagName("input")
	for(i=0;i<els.length;i++)
	{
		if (typeof caller == 'undefined')
		{
			if(els[i].getAttribute('obType') == obType && els[i].className == name)
			{
				//alert("f1"+" "+obType+" "+name+" "+value+" "+caller)
				els[i].value = value;
				setTimeout("document.getElementById('"+els[i].id+"').onchange()",500);
			}
		}
		else
		{
			if(els[i].getAttribute('obType') == obType && els[i].className == name && caller.id != els[i].id && caller.id.replace("sampleMass","moles") != els[i].id)
			{
				//alert("f2"+" "+obType+" "+name+" "+value+" "+caller)
				els[i].value = value;
				setTimeout("document.getElementById('"+els[i].id+"').onchange()",500);
			}
		}
	}
}

function runOnchangeForObjectsOfType(obType,name,caller)
{
	els = document.getElementsByTagName("input")
	for(i=0;i<els.length;i++)
	{

		if (typeof caller == 'undefined')
		{
			if(els[i].getAttribute('obType') == obType.toString() && els[i].className == name)
			{
				setTimeout("document.getElementById('"+els[i].id+"').onchange()",500);
			}
		}
		else
		{
			if(els[i].getAttribute('obType') == obType.toString() && els[i].className == name && caller.id != els[i].id && caller.id.replace("sampleMass","moles") != els[i].id)
			{
				setTimeout("document.getElementById('"+els[i].id+"').onchange()",500);
			}
		}
	}
}

function getBaseNumber(inStr)
{
	inStr = trim(inStr);
	if (inStr.search(/^[0-9\.]*$/) != -1)
	{
		return parseFloat(inStr)
	}
	numPart = inStr.match(/[0-9\.]+/)
	unitPart = inStr.match(/[^0-9\.]*?$/)
	//alert(unitPart)
	if (numPart && unitPart)
	{
		numPart = parseFloat(numPart[0])
		unitPart = trim(unitPart[0].toLowerCase()).replace('µ','u')
		//alert(numPart + " " + unitPart)	
	}
	else
	{
		if (numPart)
		{
			return parseFloat(numPart)
		}
		else
		{
			return false;
		}
	}
	//alert(parseFloat(numPart * unitMultis[unitPart]))
	return parseFloat(numPart * unitMultis[unitPart])

}

var unitMultis = new Array();