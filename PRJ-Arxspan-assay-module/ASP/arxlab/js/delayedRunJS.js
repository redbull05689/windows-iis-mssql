function delayedRunJS(inString)
{
	matches = inString.match(/<.cript[^>]*>([\s\S]*?)<\/.cript>/ig)
	javascriptString = ""
	if(matches)
	{
		for (q=0;q<matches.length ;q++ )
		{
			javascriptString += matches[q].replace(/<.cript[^>]*>/,"").replace(/<\/.cript>/,"") + "\n"
		}
		theRand = Math.random().toString().replace(".","");
		javascriptString = "function misc"+theRand+"_go(){"+javascriptString+"}"
		includeJS('misc'+theRand+'_script','',javascriptString)
		setTimeout("misc"+theRand+"_go()",500)
	}
}