function showTR(id)
{//this function is for displaying an element as a table row
 //this function fixes compatibility with earlier versions of internet explorer
	try
	{
		document.getElementById(id).style.display = "table-row"
	}
	catch(err)
	{
		try{document.getElementById(id).style.display = "block"}catch(err){}
	}
}