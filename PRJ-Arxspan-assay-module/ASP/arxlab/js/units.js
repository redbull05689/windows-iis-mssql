var lastTextBoxId = "";
var maxUnits = 0
var unitPos = 0

function appendUnits(unit)
{
	//add unit to field value in correct format i.e. 123.45 g
	el = document.getElementById(lastTextBoxId)
	el.value = el.value.replace(/[^0-9.]/ig,"") +" " + unit
	sendAutoSave(el.id,el.value);
	document.getElementById(el.id +"_units").style.display = "none";
	units(el)
	try{
	el.onchange()
	}catch(err){}
}

function checkFocus()
{
	f = false
	if (document.activeElement.id == lastTextBoxId)
	{
		f = true
	}
	if (!f)
	{//if focus has moved into a new text box hide the previous units box and down image
		try{document.getElementById(lastTextBoxId+"_units").style.display = "none";}catch(err){}
		unitPos = 0
		try{clearSelectedClass(document.getElementById(lastTextBoxId+"_units_num_0"))}catch(err){}
		document.getElementById(lastTextBoxId +"_down_image").style.left = "-4000px";
	}
}

function clearSelectedClass(el)
{//clears the 'selected' class off of all the units in the units box and sets the passed elements class to selected
	for (i=0;i<=maxUnits ;i++)
	{
		document.getElementById(lastTextBoxId + "_units_num_"+i).setAttribute("class","")
	}
	try
	{
	el.focus()	
	}
	catch(err){}
	
	document.getElementById(el.id).setAttribute("class","selectedLink")
	re = /[\d]*$/
	unitPos = parseInt(re.exec(el.id))
}

function unitArrows(el)
{//not currently used. allows navigation of unit box by pressing arrow keys
	re = /[\d]*$/
	unitPos = parseInt(re.exec(el.id))

	if (event.keyCode == 40)
	{
		nextEl = document.getElementById(el.id.replace(/[\d]*$/ig,'')+parseInt(unitPos+1))
		if (nextEl == null)
		{
			unitPos = 0
			nextEl = document.getElementById(el.id.replace(/[\d]*$/ig,'')+0)
		}
		else
		{
			unitPos += 1
		}
		clearSelectedClass(nextEl)
	}
	if (event.keyCode == 38)
	{
		nextEl = document.getElementById(el.id.replace(/[\d]*$/ig,'')+parseInt(unitPos-1))
		if (nextEl == null)
		{
			unitPos = 0
			nextEl = document.getElementById(el.id.replace(/[\d]*$/ig,'')+maxUnits)
		}
		else
		{
			unitPos -= 1
		}
		clearSelectedClass(nextEl)
	}
	if (event.keyCode == 13)
	{
		unitStr = document.getElementById(el.id).value
		appendUnits(unitStr)
		downEl = el.id.replace(/_units.*/ig,"")
		document.getElementById(downEl +"_down_image").style.marginLeft = w+5+"px";
		document.getElementById(downEl +"_down_image").style.left = "5px";
	}
}

var lastOnchange = null;

function units(el)
{
	
	//if (el.id == "r1_sampleMass" && el.onchange != null)
	//{
	//	thisId = el.id.replace("_down_image","")
	//	lastOnchange = document.getElementById(thisId).onchange;
	//	document.getElementById(thisId).onchange = null;
	//	//document.getElementById("e_name").value = thisId;
	//	//document.getElementById("e_name").value = lastOnchange;
	//}
	try{
		//dummy width spans are used to calculate the length of the text in the textboxes
		//this sets the text in the dummy span to the text in the textbox
		document.getElementById(el.id +"_dummy_width").innerHTML = el.value
	}catch(err){}
	if (el.id != lastTextBoxId && lastTextBoxId != '' && lastTextBoxId.indexOf("down_image") == -1 && lastTextBoxId != 'experimentForm'&& el.id != 'experimentForm')
	{//if we are in a new textbox and we were in a textbox before, hide the down image and units box of the last textbox
		try{document.getElementById(lastTextBoxId +"_units").style.display = "none";}catch(err){}
		try{document.getElementById(lastTextBoxId +"_down_image").style.left = "-4000px";}catch(err){}
	}
	openUp = false;
	closeFlag = false;

	try{
		if (el.id.indexOf("_down_image")>= 0)
		{
			//if function was called through the down image then set the element to the parent textbox
			el = document.getElementById(el.id.replace("_down_image",""))
			if(document.getElementById(el.id + "_units").style.display == 'none')
			{
				//if the unitsbox isnt showing for the element when the down image was clicked then show them
				openUp = true
			}
			else
			{
				//otherwise close the units box
				closeFlag = true
			}	
		}
	}catch(err){return}
	try{document.getElementById(el.id +"_units").style.backgroundColor = "white";}catch(err){}
	if (closeFlag)
	{//hide down image
		document.getElementById(lastTextBoxId +"_down_image").style.left = "-4000px";
	}
	if (el.getAttribute("type") == "text")
	{
		//if we are in a text box then set the global lastTextBoxId to the id of this element
		lastTextBoxId = el.id
	}

	//get the width of text in text box via hidden element then set that as the margin for units display
	try{document.getElementById(el.id +"_dummy_width").innerHTML = el.value;
	w = document.getElementById(el.id +"_dummy_width").offsetWidth;
	}catch(err){return;}
	
	//if there is text in the box show the down arrow
	if (el.value.length > 0)
	{
		document.getElementById(el.id +"_down_image").style.marginLeft = w+5+"px";
		document.getElementById(el.id +"_down_image").style.left = "5px";
	}
	
	
	if (openUp)
	{//show unitsbox
		//document.getElementById(lastTextBoxId).focus()
		document.getElementById(el.id +"_units").style.marginLeft = w+5+"px";
		document.getElementById(el.id +"_units").style.display = "block";
		document.getElementById(el.id +"_units").style.zIndex = "100";

		for (i=0;i<100 ;i++ )
		{
			try
			{
				el3 = document.getElementById(el.id+"_units_num_"+i);
				if (el3 != null)
				{
					maxUnits = i;
				}
			}
			catch(err){}
		}
		unitPos = 0
		clearSelectedClass(document.getElementById(el.id +"_units_num_0"))
	}

	if (closeFlag)
	{// hide unitsbox
		document.getElementById(el.id +"_units").style.display = "none";
	}
}