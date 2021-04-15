function parseRxn(rxnStr,updateData)
{
	//deprecated. Parses rxn files
	reactants = [];
	products = [];
	mols = [];
	numReactants = 0
	numProducts = 0
	tmp = rxnStr.split("\n")
	if (tmp[0].indexOf("$RXN") > -1)
	{
		rxnNumbers = tmp.slice(4)[0]
	}
	else
	{
		if (rxnStr != "")
		{
			rxnNumbers = "  1  0";
		}
		else
		{
			rxnNumbers = "  0  0";
		}
	}
	myRegEx = /[^\d]+(\d+)[^\d]+(\d+)/
	matches = myRegEx.exec(rxnNumbers)
	numReactants = parseInt(matches[1])
	numProducts = parseInt(matches[2])

	tmp = rxnStr.split("\r\n")
	if (tmp.length == 1)
	{
		tmp = rxnStr.split("\n")
	}

	rxnStr = tmp.join("@@@")
	matches = rxnStr.match(/(\$MOL.*?END)/g)
	if (matches == null)
	{
		matches = rxnStr.match(/(@@@@@@.*?END)/g)
		matches[0] = "\r\nChemDraw23423423400\r\n" + matches[0].substring(3)
	}
	for (i=0;i<matches.length ;i++ )
	{
		mols.push(matches[i].replace(/@@@/g,"\r\n").replace("$MOL\r\n",""))
	}
	for (i=0;i<mols.length ;i++ )
	{
		if (i < numReactants)
		{
			reactants.push(mols[i])
		}
		else
		{
			products.push(mols[i])
		}
	}



}