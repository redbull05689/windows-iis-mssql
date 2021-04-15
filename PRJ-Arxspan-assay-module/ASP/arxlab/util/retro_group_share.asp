<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
' not constellation anymore  
if session("companyId") = "1" And session("roleNumber") <= 1 then

	If request.Form("formSubmit") <> "" Then
		call getconnectedAdm
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery  = "SELECT * FROM notebooks WHERE id in (select notebookId from notebookIndexView WHERE companyId="&SQLClean(request.Form("companyId"),"N","S")&") and id not in (select notebookId from groupNotebookInvitesView WHERE companyId="&SQLClean(request.Form("companyId"),"N","S")&")"
		rec.open strQuery,connAdm,3,3
		notebookCount = 0
		Do While Not rec.eof
			notebookCount = notebookCount + 1
			strQuery2 = "INSERT INTO groupNotebookInvites(notebookId,sharerId,shareeId,accepted,denied,canRead,canWrite,readOnly) values(" &_
							SQLClean(rec("id"),"N","S") & "," &_
							SQLClean(rec("userId"),"N","S") & "," &_
							SQLClean(request.Form("groupId"),"N","S") & ",1,0,1,0,1)"
			connAdm.execute(strQuery2)
			rec.movenext
		Loop

		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery  = "SELECT * FROM projectsView WHERE parentProjectId is null and id in (select id from projectsView WHERE companyId="&SQLClean(request.Form("companyId"),"N","S")&") and id not in (select projectId from groupProjectInvitesView WHERE companyId="&SQLClean(request.Form("companyId"),"N","S")&")"
		rec.open strQuery,connAdm,3,3
		projectCount = 0
		Do While Not rec.eof
			projectCount = projectCount + 1
			strQuery2 = "INSERT INTO groupProjectInvites(projectId,sharerId,shareeId,accepted,denied,canRead,canWrite,readOnly) values(" &_
							SQLClean(rec("id"),"N","S") & "," &_
							SQLClean(rec("userId"),"N","S") & "," &_
							SQLClean(request.Form("groupId"),"N","S") & ",1,0,1,1,1)"
			connAdm.execute(strQuery2)
			rec.movenext
		Loop
		
		call disconnectadm
	End if
%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<script type="text/javascript">
	function getGroupSelect(companyId){
		selectObject = eval('('+getFile("getGroupsByCompanyIdSelect.asp?id="+companyId+"&rand="+Math.random())+')')
		try{
			document.getElementById("groupDiv").removeChild(document.getElementById("groupId"))
		}catch(err){}
		document.getElementById("groupDiv").appendChild(createSelect(selectObject));
		document.getElementById("groupId").onchange = function(){validate();clearDivs();};
	}
	function validate(){
		companyId = document.getElementById("companyId").options[document.getElementById("companyId").selectedIndex].value
		groupId = document.getElementById("groupId").options[document.getElementById("groupId").selectedIndex].value
		if(!(groupId > 0 && companyId > 0)){
			clearDivs();
		}
		if(!document.getElementById("groupId")){
			clearDivs();
		}
	}
	function clearDivs(){
		document.getElementById("div2").style.display = "none";
		document.getElementById("div3").style.display = "none";
		document.getElementById("div4").style.display = "none";
		document.getElementById("div5").style.display = "none";
	}
</script>
<%
If request.Form("formSubmit") <> "" Then
%>
Notebook shares added: <%=notebookCount%><br/>
Project shares added: <%=projectCount%><br/>
<%
End If
%>
<h1>Company</h1>
<form action="retro_group_share.asp" method="post">
<select id="companyId" name="companyId" onchange="getGroupSelect(this.options[this.selectedIndex].value);validate();">
	<option value="0"> --SELECT--</option>
<%
Call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM companies order by name asc"
rec.open strQuery,conn,3,3
Do While Not rec.eof
	%>
	<option value="<%=rec("id")%>"><%=rec("name")%></option>
	<%
	rec.movenext
loop
%>
</select>
<h1>Groups</h1>
<div id="groupDiv">

</div>
<%

rec.close
Set rec = nothing
Call disconnect
%>
</select>
<input type="button" value="add shares to all notebooks and projects" onclick="document.getElementById('div2').style.display='block';validate();" style="padding:2px;">
<div id="div2" style="display:none;">
	<input type="button" value="are you sure" onclick="document.getElementById('div3').style.display='block'" style="padding:2px;">
</div>
<div id="div3" style="display:none;">
	<input type="button" value="like really really sure" onclick="document.getElementById('div4').style.display='block'" style="padding:2px;">
</div>
<div id="div4" style="display:none;">
	<input type="button" value="you should look and confirm have a positive and negative test case. I am about to let you do it." onclick="document.getElementById('div5').style.display='block'" style="padding:2px;">
</div>
<div id="div5" style="display:none;">
	<input type="submit" value="just do it already" name="formSubmit" style="padding:2px;">
</div>
</form>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%
end If
%>