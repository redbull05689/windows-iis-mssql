function showOfficeFrames()
{
	//show office pdf frames
	els = document.getElementsByTagName("iframe")
	for(i=0;i<els.length;i++)
	{
		if (els[i].className == "officeFrame")
		{
			els[i].style.visibility = "visible"
		}
	}
}

function hideOfficeFrames()
{
	//hide office pdf frames, because they like to show over layers that are above them
	els = document.getElementsByTagName("iframe")
	for(i=0;i<els.length;i++)
	{
		if (els[i].className == "officeFrame")
		{
			els[i].style.visibility = "hidden"
		}
	}
}