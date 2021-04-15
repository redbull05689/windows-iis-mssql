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
			cd_insertObject("chemical/x-mdl-molfile", 860, 300, "mycdx-<%=rec("id")%>","<%=mainAppPath%>/experiments/ajax/load/getCDX.asp?id=<%=rec("id")%>&revisionNumber=<%=revisionId%>",false,true);
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
<%
	set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experiments"
	rec.open strQuery,connAdm,3,3
	counter = 0
	Do While Not rec.eof
	%>
		sqlReactantIds = [];
		sqlReagentIds = [];
		sqlProductIds = [];
		<%
		set rec2 = server.createobject("ADODB.RecordSet")
		strQuery = "SELECT * from reactants WHERE experimentId="&SQLClean(rec("id"),"N","S")
		rec2.open strQuery,connAdm,3,3
		do while not rec2.eof
			%>
			sqlReactantIds.push(<%=rec2("id")%>)
			<%
			rec2.movenext
		loop
		%>
		<%
		set rec2 = server.createobject("ADODB.RecordSet")
		strQuery = "SELECT * from reagents WHERE experimentId="&SQLClean(rec("id"),"N","S")
		rec2.open strQuery,connAdm,3,3
		do while not rec2.eof
			%>
			sqlReagentIds.push(<%=rec2("id")%>)
			<%
			rec2.movenext
		loop
		%>
		<%
		set rec2 = server.createobject("ADODB.RecordSet")
		strQuery = "SELECT * from products WHERE experimentId="&SQLClean(rec("id"),"N","S")
		rec2.open strQuery,connAdm,3,3
		do while not rec2.eof
			%>
			sqlProductIds.push(<%=rec2("id")%>)
			<%
			rec2.movenext
		loop
		%>
		//alert(sqlReactantIds)
		//alert(sqlReagentIds)
		//alert(sqlProductIds)
		rxnStr = cd_getData("mycdx-<%=rec("id")%>","text/xml")
		xmlDoc = loadXML(rxnStr)
		steps = xmlDoc.getElementsByTagName("step")
		if (steps.length > 0)
		{
			reactionStepReactants = steps[0].getAttribute("ReactionStepReactants").trim()
			reactionStepProducts = steps[0].getAttribute("ReactionStepProducts").trim()
			reagentString = ""
			if (steps[0].getAttribute("ReactionStepObjectsAboveArrow") != null)
			{
				reagentString += steps[0].getAttribute("ReactionStepObjectsAboveArrow").trim()
			}
			if (steps[0].getAttribute("ReactionStepObjectsBelowArrow") != null)
			{
				reagentString += " " + steps[0].getAttribute("ReactionStepObjectsBelowArrow").trim()
			}
			reagentString = reagentString.trim()
			reactantIds = reactionStepReactants.split(" ")
			productIds = reactionStepProducts.split(" ")
			reagentIds = reagentString.split(" ")
			reactants = []
			products = []
			reagents = []
			for(i=0;i<reactantIds.length;i++)
			{
				fragments = xmlDoc.getElementsByTagName("fragment")
				for (j=0;j<fragments.length ;j++ )
				{
					if (fragments[j].getAttribute("id") == reactantIds[i])
					{
						cdxmlData = '<?xml version="1.0" encoding="UTF-8" ?><!DOCTYPE CDXML SYSTEM "http://www.cambridgesoft.com/xml/cdxml.dtd" ><CDXML><page>'+xmlToString(fragments[j])+"</page></CDXML>"
						cd_putData("tempCDX","text/xml",cdxmlData)
						molData = cd_getData("tempCDX","chemical/x-mdl-molfile")
						reactants.push(molData)
					}
				}
			}
			for(i=0;i<reagentIds.length;i++)
			{
				fragments = xmlDoc.getElementsByTagName("fragment")
				for (j=0;j<fragments.length ;j++ )
				{
					if (fragments[j].getAttribute("id") == reagentIds[i])
					{
						cdxmlData = '<?xml version="1.0" encoding="UTF-8" ?><!DOCTYPE CDXML SYSTEM "http://www.cambridgesoft.com/xml/cdxml.dtd" ><CDXML><page>'+xmlToString(fragments[j])+"</page></CDXML>"
						cd_putData("tempCDX","text/xml",cdxmlData)
						molData = cd_getData("tempCDX","chemical/x-mdl-molfile")
						reagents.push(molData)
					}
				}
			}
			for(i=0;i<productIds.length;i++)
			{
				fragments = xmlDoc.getElementsByTagName("fragment")
				for (j=0;j<fragments.length ;j++ )
				{
					if (fragments[j].getAttribute("id") == productIds[i])
					{
						cdxmlData = '<?xml version="1.0" encoding="UTF-8" ?><!DOCTYPE CDXML SYSTEM "http://www.cambridgesoft.com/xml/cdxml.dtd" ><CDXML><page>'+xmlToString(fragments[j])+"</page></CDXML>"
						cd_putData("tempCDX","text/xml",cdxmlData)
						molData = cd_getData("tempCDX","chemical/x-mdl-molfile")
						products.push(molData)
					}
				}
			}
		}
		for(i=0;i<sqlReactantIds.length;i++)
		{
			try{
			document.getElementById("sql").innerHTML += "UPDATE reactants SET molData='"+reactants[i]+"' WHERE id="+sqlReactantIds[i]+'\n';
			}catch(err){}
		}
		for(i=0;i<sqlReagentIds.length;i++)
		{
			try{
			document.getElementById("sql").innerHTML += "UPDATE reagents SET molData='"+reagents[i]+"' WHERE id="+sqlReagentIds[i]+'\n';
			}catch(err){}
		}
		for(i=0;i<sqlProductIds.length;i++)
		{
			try{
			document.getElementById("sql").innerHTML += "UPDATE products SET molData='"+products[i]+"' WHERE id="+sqlProductIds[i]+'\n';
			}catch(err){}
		}
<%
	counter = counter + 1
	rec.movenext
loop
%>
}
</script>
<div id="sql">

</div>
<a href="javascript:void(0)" onclick="alerts()">GO</a>
<%
end If
%>
