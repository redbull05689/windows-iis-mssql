<script type="text/javascript" src="<%=mainAppPath%>/js/common/chemdraw/chemdraw.js"></script>
<%
'This file defines async funtion hasChemdraw() to replace variable hasChemdrow which does not work well and could cause multiple page reloads in race condition. 
%>
<script>
hasChemdraw().then(function(isInstalled) {
	turnedOffChemdraw = false;
	
	if (isInstalled) {
<%If session("noChemDraw") Then%>
		setNoChemDrawMode();
		turnedOffChemdraw = true;
<%Else%>
		// 5301: handle exception in IE 11
		var obj = cd_getSpecificObject("test");
		if (obj)
		{
			var v = obj.Version;
			if (v)
			{
				versionNumber = /[0-9]+\./i.exec(v).toString()
				versionNumber = versionNumber.replace(".","")

				if (versionNumber < 10) {
					setNoChemDrawMode();
					turnedOffChemdraw = true;
				}
			}
		}
<%End If%>
	}
	
	if((!isInstalled) || turnedOffChemdraw) {
		$.ajax({
			async: true,
			method: "GET",
			url: "<%=mainAppPath%>/ajax_doers/user_settings/switchToNoChemdrawMode.asp"
		});
	}
});
</script>
