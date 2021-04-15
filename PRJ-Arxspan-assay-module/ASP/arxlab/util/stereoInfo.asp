<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isApiPage=true%>
<!-- #include file="../_inclds/globals.asp"-->

<%If request.Form("sub")<>"" Then
		Set d = JSON.parse("{}")
		d.Set "structure", CStr(request.Form("molData"))
		data = JSON.stringify(d)
		Set http = CreateObject("MSXML2.ServerXMLHTTP")
		http.setOption 2, 13056
		http.open "POST",chemAxonCipStereoUrl,True
		http.setRequestHeader "Content-Type","application/json" 
		http.setRequestHeader "Content-Length",Len(data)
		http.SetTimeouts 120000,120000,120000,120000
		http.send data
		http.waitForResponse(60)
		Set r = JSON.parse(http.responseText)
		r.Set "result",""
		%>
		<script type="text/javascript">
		jO = JSON.parse('<%=JSON.stringify(r)%>');
		console.log(jO);
		window.onload = function(){
			document.getElementById("theJSON").value = JSON.stringify(jO,null,2);
			cd_putData("addStructureCDX",'chemical/x-mdl-molfile',"<%=replace(request.form("molData"),vbcrlf,"\n")%>");
		}
		</script>
		<%
End if%>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->

<div style="border:2px solid black;width:304px;">
<div style="border:2px dotted black;">
<script type="text/javascript">
cd_insertObject("text/xml", 300, 300, "addStructureCDX","<%=mainAppPath%>/static/blank.cdx",false,true);
</script>
</div>
<form action="stereoInfo.asp" method="post" onsubmit="document.getElementById('molData').value=cd_getData('addStructureCDX','chemical/x-mdl-molfile');">
<input type="hidden" name="molData" id="molData">
<input type="submit" value="Submit" name="sub">
</form>
</div>
<textarea id="theJSON" rows=20 cols=60></textarea>