<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
server.scripttimeout = 500000
%>
<!-- #include file="_inclds/globals.asp"-->
<script type="text/javascript" src="js/arxXml.js"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript">
    hasChemdraw().then(function (isInstalled) {
        if (isInstalled) {
            cd_insertObject("chemical/x-mdl-molfile", 860, 300, "tempCDX", "", false, true);
        }
    });
</script>
<%
if session("userId") = "2" then
	call getconnectedadm
	
	set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experiments"
	rec.open strQuery,connAdm,3,3
	counter = 0
	Do While Not rec.eof
		%>
		  <script type="text/javascript">
			cd_insertObject("text/xml", 860, 300, "mycdx-<%=rec("id")%>","<%=mainAppPath%>/experiments/ajax/load/getCDX.asp?id=<%=rec("id")%>&revisionNumber=<%=revisionId%>",false,true);
		  </script>
		<%
		counter = counter + 1
		rec.movenext
	Loop
	rec.close

%>
<script type="text/javascript">
function alerts()
{
	longStr = ""
<%
	set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experiments"
	rec.open strQuery,connAdm,3,3
	counter = 0
	Do While Not rec.eof
	%>
		//alert(sqlReactantIds)
		//alert(sqlReagentIds)
		//alert(sqlProductIds)
		rxnStr = cd_getData("mycdx-<%=rec("id")%>","text/xml")
		xmlDoc = loadXML(rxnStr)
		steps = xmlDoc.getElementsByTagName("step")
		try{colorTable = xmlToString(xmlDoc.getElementsByTagName("colortable")[0])}catch(err){colorTable = ""}
		//alert(colorTable)
		if (steps.length > 0)
		{
			reactionStepProducts = steps[0].getAttribute("ReactionStepProducts").trim()
			productIds = reactionStepProducts.split(" ")
			products = []
			fragments = xmlDoc.getElementsByTagName("fragment")

			cdxmlData = '<'+'?' + 'xml version="1.0" encoding="UTF-8" ?'+'>'+'<'+'!'+'DOCTYPE CDXML SYSTEM "http://www.cambridgesoft.com/xml/cdxml.dtd" ><CDXML>'+colorTable+'<page>'
			for(i=0;i<productIds.length;i++)
			{
				for (j=0;j<fragments.length ;j++ )
				{
					if (fragments[j].getAttribute("id") == productIds[i])
					{
						cdxmlData+= xmlToString(fragments[j])
					}
				}
			}
			cdxmlData += "</page></CDXML>"
			cd_putData("mycdx-<%=rec("id")%>","text/xml",cdxmlData)
		}
		//for(i=0;i<products.length;i++)
		//{
			//alert(cd_getData("mycdx-<%=rec("id")%>","text/xml"))
			longStr += "UPDATE experiments SET molData='"+cd_getData("mycdx-<%=rec("id")%>","text/xml")+"' WHERE id=<%=rec("id")%>\n"
			//try{
			//document.getElementById("sql").innerHTML += "UPDATE experiments SET molData='"+cd_getData("mycdx-<%=rec("id")%>","text/xml")+"' WHERE id=<%=rec("id")%>\n";
			//}catch(err){alert(err)}
		//}
<%
	counter = counter + 1
	rec.movenext
loop
%>
document.mimetype = "text/plain"
document.write(longStr)
document.close()
}
</script>
<div id="sql">

</div>
<a href="javascript:void(0)" onclick="alerts()">GO</a>
<%
end If
%>
