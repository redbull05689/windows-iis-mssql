<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/frame-header-tool.asp"-->
<!-- #include file="../_inclds/frame-nav_tool.asp"-->
<%
notebookId = request.querystring("notebookId")
notebookName = request.querystring("notebookName")
canRead = canReadNotebook(notebookId,session("userId"))
canWrite = canWriteNotebook(notebookId)
hasInvite = hasNotebookInvite(notebookId,session("userId"))
notebookVisible = isNotebookVisible(notebookId)
%>
<%If (canRead Or hasInvite Or canWrite) And notebookVisible then%>
<%If session("hasAccordInt") then%>
<%
Call getConnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM accMols WHERE notebookId="&SQLClean(notebookId,"N","S")&" AND included=1"
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
%>
<script type="text/javascript" src="<%=mainAppPath%>/js/promisePolyfill.min.js?<%=jsRev%>"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="/arxlab/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script>
	hasMarvin = <%=LCase(CStr(session("useMarvin")))%>
</script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<script type="text/javascript">
	<%If session("useChemDrawForLiveEdit") Then%>
		useChemDrawForLiveEdit = true;
	<%End If%>
</script>
<script type="text/javascript">
	function clickSet(that){
		locationString = "setMolAsStarted.asp?id="+that.getAttribute("molid")+"&started=";
		if(that.checked){
			locationString += "1";
		}else{
			locationString += "0";
		}
		getFile(locationString);
	}
	function clickSetCancel(that){
		locationString = "setMolAsCancelled.asp?id="+that.getAttribute("molid")+"&cancelled=";
		if(that.checked){
			locationString += "1";
		}else{
			locationString += "0";
		}
		getFile(locationString);
	}
</script>
<a href="javascript:void(0);" id="showTOCLink" onclick="document.getElementById('TOCDiv').style.display='block';this.style.display='none';document.getElementById('hideTOCLink').style.display='block';resizeIFrame('tocIframe');" style="display:none;">Show TOC</a>
<a href="javascript:void(0);" id="hideTOCLink" onclick="document.getElementById('TOCDiv').style.display='none';this.style.display='none';document.getElementById('showTOCLink').style.display='block';window.parent.document.getElementById('tocIframe').style.height='20px';">Hide TOC</a>
<div id="TOCDiv" style="">
<table class="experimentsTable" style="background-color:#eee;width:820px;">
<tr>
<th colspan="4">
Table Of Contents
</th>
<tr>
<%
	counter = 0
	Do While Not rec.eof
		counter = counter + 1
		%>
		<td valign="top">
			<script type="text/javascript">
			var thisId = 'mol_mycdx_<%=rec("id")%>';
			var holderDivId = 'mol_mycdx_<%=rec("id")%>_holder';
			document.write('<div style="height:200px;width:200px;" id="'+holderDivId+'"></div>');

			$.ajax({
				url: '<%=mainAppPath%>/accint/getCDX.asp?id=<%=rec("id")%>',
				type: 'GET',
                thisId1: thisId,
                holderDivId1: holderDivId, 
				success: function(data)
				{
					console.log("accint/getCDX success");
					var holderDivId2 = this.holderDivId1;
                    getChemistryEditorMarkup(this.thisId1, "", data, 200, 200, true).then(function (theHtml) {
                        $("#" + holderDivId2).html(theHtml);
                    });
				},
				error: function(error, textStatus, errorThrown)
				{
					console.error("ERROR in accint/getCDX.asp");
					//nothing for now
				},
				complete: function()
				{
				}
				});
		
            </script><br/>
			<%=rec("localRegNumber")%><br/>
			<%
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT foreignRegNumberFinal FROM finalRegNumbers WHERE accMolId="&SQLClean(rec("id"),"N","S")
			rec2.open strQuery,jchemRegConn,3,3
			Do While Not rec2.eof
				%>
				<%=rec2("foreignRegNumberFinal")%><br/>
				<%
				rec2.movenext
			Loop
			rec2.close
			Set rec2 = nothing
			%>
			CD_ID: <%=rec("cd_id")%><br/>
			<label for="<%=rec("id")%>_started" style="padding:0px;">Started:</label>
			<input id="<%=rec("id")%>_started" type="checkbox" <%If rec("started") = 1 then%>checked<%End if%> molid="<%=rec("id")%>" onclick="clickSet(this)" style="display:inline;margin-left:4px;">
			<br/>
			<label for="<%=rec("id")%>_cancelled" style="padding:0px;">Cancelled:</label>
			<input id="<%=rec("id")%>_cancelled" type="checkbox" <%If rec("cancelled") = 1 then%>checked<%End if%> molid="<%=rec("id")%>" onclick="clickSetCancel(this)" style="display:inline;margin-left:4px;">
		</td>
		<%
		rec.movenext
		If counter Mod 4 = 0 And Not rec.eof Then
			%>
			</tr><tr>
			<%
		End if
	loop
For i = 1 To counter Mod 4
	%>
		<td>&nbsp;</td>
	<%
next
%>
</tr>
<tr>
	<td colspan="4" align="right">
		<a href="downloadNotebookTOC.asp?notebookId=<%=notebookId%>&notebookName=<%=notebookName%>">Download</a>
	</td>
</tr>
</table>
</div>
<%
End if
rec.close
Set rec = nothing
Call disconnectJchemReg
%>
<script type="text/javascript">
window.onload = function(){
	resizeIFrame('tocIframe');
}
</script>
<%End If 'has accord int%>
<%End If 'perms to view%>

<!-- #include file="../_inclds/frame-footer-tool.asp"-->