function createSelect(selectObject)
{
	theSelect = document.createElement("select")
	theSelect.setAttribute("id",selectObject.id)
	theSelect.setAttribute("name",selectObject.name)
	optionList = eval(selectObject.options)
	for (i=0;i<optionList.length;i++)
	{
		theOption = document.createElement("option")
		theText = document.createTextNode(optionList[i].text)
		theOption.appendChild(theText)
		theOption.setAttribute("value",optionList[i].value)
		theSelect.appendChild(theOption)
	}
	return theSelect
}