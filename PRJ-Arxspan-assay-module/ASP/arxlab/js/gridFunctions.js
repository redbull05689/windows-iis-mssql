	Number.prototype.toFixed = function(precision){
	 var num = (Math.round(this*Math.pow(10,precision))).toString();
	 return num.substring(0,num.length-precision) + "." + 
			num.substring(num.length-precision, num.length);
	}

function hasUnits(val)
{
	if (val.match(/.*[A-Za-z]+.*/g))
	{
		return true;
	}
	else
	{
		return false;
	}
}


function solventReactionMolarity(prefix)
{
	if(document.getElementById(prefix+"_moles").value != '')
	{
		if(document.getElementById(prefix+"_reactionMolarity").value != '')
		{
			document.getElementById(prefix+"_volume").value = (getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_reactionMolarity").value)*1000).toFixed(sigdigs) + ' mL';
		}
	}
}

function solventMoles(prefix)
{
	if(document.getElementById(prefix+"_reactionMolarity").value != '')
	{
		if(document.getElementById(prefix+"_volume").value == '')
		{
			document.getElementById(prefix+"_volume").value = (getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_reactionMolarity").value)*1000).toFixed(sigdigs) + ' mL';
		}
	}
	else
	{
		if(document.getElementById(prefix+"_reactionMolarity").value == '')
		{
			if(document.getElementById(prefix+"_volume").value != '')
			{
				document.getElementById(prefix+"_reactionMolarity").value = (getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_volume").value)).toFixed(sigdigs) + ' M';
			}
		}
	}
}

function reactantLimit(prefix)
{
	uncheckClass('limit');
	document.getElementById(prefix+"_limit").checked=true;
	document.getElementById(prefix+"_moles").onchange();
}

function reactantEquivalents(prefix)
{
	if(document.getElementById(prefix+"_equivalents").value !='')
	{
		if(document.getElementById(prefix+"_limit").checked)
		{
			limittingEquivalents = document.getElementById(prefix+"_equivalents").value;
			limittingMoles = document.getElementById(prefix+"_moles").value;
			runOnchangeForObjectsOfType(1,'moles');
			runOnchangeForObjectsOfType(2,'moles');
		}
		if(limittingMoles)
		{
			document.getElementById(prefix+"_moles").value = (getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_equivalents").value)/limittingEquivalents*1000).toFixed(sigdigs) + ' mmol';
			document.getElementById(prefix+"_moles").onchange();
		}
	}
}

function reactantMoles(prefix)
{
	if(document.getElementById(prefix+"_moles").value != '')
	{
		if(document.getElementById(prefix+"_percentWT").value ==''){document.getElementById(prefix+"_percentWT").value = '100 %';} 		q = document.getElementById(prefix+"_sampleMass").onchange;
		document.getElementById(prefix+"_sampleMass").onchange=null;
		if(document.getElementById(prefix+"_limit").checked)
		{
			setAllObjectsOfType(3,'theoreticalMoles',(getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_moles").value)*getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_percentWT").value)*1000).toFixed(sigdigs)+' mmol');
			setAllObjectsOfType(2,'moles',(getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_moles").value)*1000).toFixed(sigdigs) +' mmol',document.getElementById(prefix+"_moles"));
			//others should prob be changed to reflect this
			setAllObjectsOfType(4,'moles',(getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_equivalents").value)/limittingEquivalents*1000).toFixed(sigdigs) + ' mmol',document.getElementById(prefix+"_moles"));
			setAllObjectsOfType(1,'moles',(getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_moles").value)*1000).toFixed(sigdigs) +' mmol',document.getElementById(prefix+"_moles"));
			limittingEquivalents = document.getElementById(prefix+"_equivalents").value;
			limittingMoles = document.getElementById(prefix+"_moles").value;
			document.getElementById(prefix+"_sampleMass").value = (getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_percentWT").value)*getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)).toFixed(sigdigs)+' g';
			runOnchangeForObjectsOfType(2,'equivalents');
			runOnchangeForObjectsOfType(3,'equivalents');
			runOnchangeForObjectsOfType(1,'equivalents',document.getElementById(prefix+"_equivalents"));
		}
		else
		{
			if(limittingMoles)
			{
				document.getElementById(prefix+"_sampleMass").value = (getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)*(getBaseNumber(document.getElementById(prefix+"_equivalents").value)/limittingEquivalents)/getBaseNumber(document.getElementById(prefix+"_percentWT").value)).toFixed(sigdigs)+' g';
			}
			else
			{
				document.getElementById(prefix+"_sampleMass").value = (getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_percentWT").value)*getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)).toFixed(sigdigs)+' g';
			}
		}
		document.getElementById(prefix+"_sampleMass").onchange = q;
		if(document.getElementById(prefix+"_density").value != '')
		{
			document.getElementById(prefix+"_density").onchange();
		}
		else
		{
			if(document.getElementById(prefix+"_molarity").value != '')
			{
				document.getElementById(prefix+"_molarity").onchange();
			}
		}
	}
}

function reactantSampleMass(prefix)
{
	if(document.getElementById(prefix+"_sampleMass").value != '')
	{
		a = document.getElementById(prefix+"_moles").onchange;
		document.getElementById(prefix+"_moles").onchange=null;
		b = document.getElementById(prefix+"_percentWT").onchange;
		document.getElementById(prefix+"_percentWT").onchange=null;
		if(document.getElementById(prefix+"_percentWT").value ==''){document.getElementById(prefix+"_percentWT").value = '100 %';}
		document.getElementById(prefix+"_moles").value = ((getBaseNumber(document.getElementById(prefix+"_sampleMass").value)/getBaseNumber(document.getElementById(prefix+"_molecularWeight").value))*1000*getBaseNumber(document.getElementById(prefix+"_percentWT").value)).toFixed(sigdigs) + ' mmol';
		if(document.getElementById(prefix+"_limit").checked)
		{
			setAllObjectsOfType(3,'theoreticalMoles',(getBaseNumber(document.getElementById(prefix+"_moles").value)*getBaseNumber(document.getElementById(prefix+"_percentWT").value)/getBaseNumber(document.getElementById(prefix+"_equivalents").value)*1000).toFixed(sigdigs)+' mmol');
			setAllObjectsOfType(2,'moles',(getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_equivalents").value)*1000).toFixed(sigdigs) +' mmol',document.getElementById(prefix+"_sampleMass"));
			setAllObjectsOfType(4,'moles',(getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_equivalents").value)*1000).toFixed(sigdigs) +' mmol',document.getElementById(prefix+"_sampleMass"));
			setAllObjectsOfType(1,'moles',(getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_equivalents").value)*1000).toFixed(sigdigs) +' mmol',document.getElementById(prefix+"_sampleMass"));
			limittingEquivalents = document.getElementById(prefix+"_equivalents").value;
			limittingMoles = document.getElementById(prefix+"_moles").value;
		}
		document.getElementById(prefix+"_moles").onchange = a;
		document.getElementById(prefix+"_percentWT").onchange = b;
	}
}

function reactantVolume(prefix)
{
	if(document.getElementById(prefix+"_volume").value != '')
	{
		(document.getElementById(prefix+"_percentWT").value =='') ? document.getElementById(prefix+"_percentWT").value = '100 %' : a=1;
		if(document.getElementById(prefix+"_volume").value != '')
		{
			if(document.getElementById(prefix+"_density").value == '')
			{
				if(document.getElementById(prefix+"_molarity").value != '')
				{
					document.getElementById(prefix+"_moles").value = ((getBaseNumber(document.getElementById(prefix+"_molarity").value)*getBaseNumber(document.getElementById(prefix+"_volume").value))*1000).toFixed(sigdigs) + ' mmol';
				}
			}
			else
			{
				if(document.getElementById(prefix+"_density").value != '')
				{
					document.getElementById(prefix+"_moles") = ((getBaseNumber(document.getElementById(prefix+"_density").value)*getBaseNumber(document.getElementById(prefix+"_volume").value)/getBaseNumber(document.getElementById(prefix+"_molecularWeight").value))*1000).toFixed(sigdigs) + ' mmol';
				}
			}
		}
		document.getElementById(prefix+"_moles").onchange();
	}
}

function reactantMolarity(prefix)
{
	if (hasUnits(document.getElementById(prefix+"_molarity").value))
	{
		if(document.getElementById(prefix+"_moles").value != '' && document.getElementById(prefix+"_volume").value != '')
		{
			q = document.getElementById(prefix+"_volume").onchange;
			document.getElementById(prefix+"_volume").onchange=null;
			document.getElementById(prefix+"_volume").value = (getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_molarity").value)*1000).toFixed(sigdigs) + ' mL';
			document.getElementById(prefix+"_volume").onchange = q;
		}
		else
		{
			if(document.getElementById(prefix+"_volume").value != '')
			{
				(document.getElementById(prefix+"_molarity").value =='') ? document.getElementById(prefix+"_molarity").value = '1.0 M' : a=1;
				if(document.getElementById(prefix+"_moles").value == '')
				{
					document.getElementById(prefix+"_moles").value = ((getBaseNumber(document.getElementById(prefix+"_molarity").value)*getBaseNumber(document.getElementById(prefix+"_volume").value))*1000).toFixed(sigdigs) + ' mmol';
					document.getElementById(prefix+"_molarity_qv").value = document.getElementById(prefix+"_molarity").value;
					document.getElementById(prefix+"_moles").onchange();
				}
			}
			else
			{
				if(document.getElementById(prefix+"_molarity").value != '')
				{
					if(document.getElementById(prefix+"_moles").value != '')
					{
						q = document.getElementById(prefix+"_volume").onchange;
						document.getElementById(prefix+"_volume").onchange=null;
						document.getElementById(prefix+"_volume").value = (getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_molarity").value)*1000).toFixed(sigdigs) + ' mL';
						document.getElementById(prefix+"_volume").onchange = q;
					}
				}
			}
		}
	}
}

function reactantDensity(prefix)
{
	if (hasUnits(document.getElementById(prefix+"_density").value))
	{
		if(document.getElementById(prefix+"_moles").value != '' && document.getElementById(prefix+"_volume").value != '')
		{
			q = document.getElementById(prefix+"_volume").onchange;
			document.getElementById(prefix+"_volume").onchange=null;
			document.getElementById(prefix+"_volume").value = (getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)*getBaseNumber(document.getElementById(prefix+"_moles").value)/(getBaseNumber(document.getElementById(prefix+"_density").value))).toFixed(sigdigs) + ' mL';
			document.getElementById(prefix+"_volume").onchange = q;
		}
		else
		{
			if(document.getElementById(prefix+"_volume").value != '')
			{
				(document.getElementById(prefix+"_density").value =='') ? document.getElementById(prefix+"_density").value = '1.0 g/mL' : a=1;
				if(document.getElementById(prefix+"_moles").value == '')
				{
					document.getElementById(prefix+"_moles").value = ((getBaseNumber(document.getElementById(prefix+"_density").value)*getBaseNumber(document.getElementById(prefix+"_volume").value)/getBaseNumber(document.getElementById(prefix+"_molecularWeight").value))*1000000).toFixed(sigdigs) + ' mmol';
					document.getElementById(prefix+"_molarity").value='';
					document.getElementById(prefix+"_moles").onchange();
				}
			}
			else
			{
				if(document.getElementById(prefix+"_density").value != '')
				{
					if(document.getElementById(prefix+"_moles").value != '')
					{
						q = document.getElementById(prefix+"_volume").onchange;
						document.getElementById(prefix+"_volume").onchange=null;
						document.getElementById(prefix+"_volume").value = (getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)*getBaseNumber(document.getElementById(prefix+"_moles").value)/(getBaseNumber(document.getElementById(prefix+"_density").value))).toFixed(sigdigs) + ' mL';
						document.getElementById(prefix+"_volume").onchange = q;
					}
				}
			}
		}
	}
}

function reactantPercentWT(prefix)
{
	(document.getElementById(prefix+"_percentWT").value =='') ? document.getElementById(prefix+"_percentWT").value = '100 %' : a=1;
	if(document.getElementById(prefix+"_sampleMass").value != '')
	{
		if(document.getElementById(prefix+"_limit").checked)
		{
			document.getElementById(prefix+"_moles").value = ((getBaseNumber(document.getElementById(prefix+"_sampleMass").value)/getBaseNumber(document.getElementById(prefix+"_molecularWeight").value))*getBaseNumber(document.getElementById(prefix+"_percentWT").value)*1000).toFixed(sigdigs) + ' mmol';
			document.getElementById(prefix+"_moles").onchange()
		}
		else
		{
			document.getElementById(prefix+"_sampleMass").value =(getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)*(getBaseNumber(document.getElementById(prefix+"_equivalents").value)/limittingEquivalents)/getBaseNumber(document.getElementById(prefix+"_percentWT").value)).toFixed(sigdigs)+' g';
		}
	}
}

function productPurity(prefix)
{
	if(document.getElementById(prefix+"_purity").value != '')
	{
		document.getElementById(prefix+"_actualMoles") = (getBaseNumber(document.getElementById(prefix+"_actualMass").value)/getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)*1000).toFixed(sigdigs)+' mmol';
		if(document.getElementById(prefix+"_measuredMass").value !='')
		{
			document.getElementById(prefix+"_actualMass").value = (getBaseNumber(document.getElementById(prefix+"_measuredMass").value)*getBaseNumber(document.getElementById(prefix+"_purity").value)).toFixed(sigdigs)+' g';
			document.getElementById(prefix+"_yield").value = (100*getBaseNumber(document.getElementById(prefix+"_measuredMass").value)/getBaseNumber(document.getElementById(prefix+"_theoreticalMass").value)*getBaseNumber(document.getElementById(prefix+"_purity").value)).toFixed(sigdigs) + ' %';
			document.getElementById(prefix+"_yield").onchange();
			document.getElementById(prefix+"_yield_qv").value = document.getElementById(prefix+"_yield").value;
		}
		document.getElementById(prefix+"_actualMoles").onchange();
	}
}

function productTheoreticalMass(prefix)
{
	if(document.getElementById(prefix+"_theoreticalMass").value !='')
	{
		(document.getElementById(prefix+"_purity").value == '')?document.getElementById(prefix+"_purity").value='100 %':a=1;
		if(document.getElementById(prefix+"_measuredMass").value!='')
		{
			document.getElementById(prefix+"_yield").value = (100*getBaseNumber(document.getElementById(prefix+"_measuredMass").value)/getBaseNumber(document.getElementById(prefix+"_theoreticalMass").value)*getBaseNumber(document.getElementById(prefix+"_purity").value)).toFixed(sigdigs) + ' %';
		}
	}
}

function productTheoreticalMoles(prefix)
{
	if(document.getElementById(prefix+"_theoreticalMoles").value != '')
	{
		document.getElementById(prefix+"_theoreticalMoles").value=(getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_equivalents").value)/limittingEquivalents*1000).toFixed(sigdigs) + ' mmol';
		document.getElementById(prefix+"_theoreticalMass").value = (getBaseNumber(document.getElementById(prefix+"_theoreticalMoles").value)*getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)).toFixed(sigdigs) + ' g';
		document.getElementById(prefix+"_theoreticalMass").onchange();
	}
}

function productEquivalents(prefix)
{
	if(document.getElementById(prefix+"_equivalents").value != '')
	{
		document.getElementById(prefix+"_theoreticalMoles").value =(getBaseNumber(limittingMoles)*getBaseNumber(document.getElementById(prefix+"_equivalents").value)/limittingEquivalents*1000).toFixed(sigdigs) + ' mmol';
		document.getElementById(prefix+"_theoreticalMass").value = (getBaseNumber(document.getElementById(prefix+"_theoreticalMoles").value)*getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)).toFixed(sigdigs) + ' g';
		if(document.getElementById(prefix+"_measuredMass").value != '')
		{
			document.getElementById(prefix+"_theoreticalMass").onchange();
		}
	}
}

function productVolume(prefix)
{
	if(document.getElementById(prefix+"_moles").value != '')
	{
		if(document.getElementById(prefix+"_volume").value != '')
		{
			document.getElementById(prefix+"_reactionMolarity").value = (getBaseNumber(document.getElementById(prefix+"_moles").value)/getBaseNumber(document.getElementById(prefix+"_volume").value)).toFixed(sigdigs) + ' M';
		}
	}
}

function productMeasuredMass(prefix)
{
	if(document.getElementById(prefix+"_measuredMass").value !='')
	{
		(document.getElementById(prefix+"_purity").value == '')?document.getElementById(prefix+"_purity").value='100 %':a=1;
		document.getElementById(prefix+"_actualMass").value = (getBaseNumber(document.getElementById(prefix+"_measuredMass").value)*getBaseNumber(document.getElementById(prefix+"_purity").value)).toFixed(sigdigs)+' g';
		document.getElementById(prefix+"_actualMoles").value = (getBaseNumber(document.getElementById(prefix+"_actualMass").value)/getBaseNumber(document.getElementById(prefix+"_molecularWeight").value)*1000).toFixed(sigdigs)+' mmol';
		document.getElementById(prefix+"_yield").value = (100*getBaseNumber(document.getElementById(prefix+"_measuredMass").value)/getBaseNumber(document.getElementById(prefix+"_theoreticalMass").value)*getBaseNumber(document.getElementById(prefix+"_purity").value)).toFixed(sigdigs) + ' %';
	}
}