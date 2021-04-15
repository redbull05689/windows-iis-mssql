<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% Server.ScriptTimeout = 300000%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/backup_and_pdf/functions/fnc_getCSXML.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_getExperimentStatus.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	exportRoot = getCompanySpecificSingleAppConfigSetting("bulkExportDirectory", session("companyId")) & session("companyId")
	sectionID = "tool"
	subSectionID="export"
	terSectionID=""
	pageTitle = "Arxspan Bulk Export"
	metaD=""
	metaKey=""
%>

<%
If request.Form("submit") <> "" Then

	companyId = request.form("companyId")
	notebookName = request.form("notebookName")

	if session("role")="Super Admin" or (session("role")="Admin") Then
		trash=1
	else
		response.redirect(loginScriptName)
	End if

	exportPath = uploadRoot&"\exports\"&session("userId")&"\backup"
	'response.write(exportPath)

	SET fso = Server.CreateObject("Scripting.FileSystemObject")
	If fso.FolderExists(exportPath) Then
		fso.DeleteFolder(exportPath)
	End if	

	a = recursiveDirectoryCreate(uploadRoot,exportPath)

	Call getconnected
	
	Function findExperiments(L,prevName)
		For q = 0 To L.count
			Set L2 = L.getItem(q)
			name = cleanFileName(L2.getData("name"))
			wholePath = Trim(exportPath)&prevName&"\"&name
			If L2.getData("type") = "experiment" Then
				If request.Form(L2.getData("id")) = "on" Then
					a = recursiveDirectoryCreate(uploadRoot,wholePath)
					response.write("processing: " & name & "<br>")
					response.flush()

					revisionNumber = getExperimentRevisionNumber(L2.getData("experimentType"),Trim(L2.getData("arxlabId")))

					' Figure out if we should sign it or not
					status = getExperimentStatus(L2.getData("experimentType"),Trim(L2.getData("arxlabId")),revisionNumber, true)
					sign = false
					witnessed = false
					if status = "signed - closed" then
						sign = true
					elseif status = "witnessed" then
						witnessed = true
					end if

					if not witnessed AND not sign then

						' Find any existing stuck records
						Set rec4 = server.CreateObject("ADODB.RecordSet")
						strQuery = "select id from pdfProcQueue where companyId = "&SQLClean(companyId,"N","S")& " AND experimentId = "&SQLClean(Trim(L2.getData("arxlabId")),"N","S")& " and revisionNumber = "&SQLClean(revisionNumber,"N","S")& " and experimentType = '" & pdfExpType & "' and (status = 'NEW' or status = 'inProgress')"
						'response.write(strQuery)
						rec4.open strQuery,conn,3,3
						idList = "-1," 'default value so I don't need to get fancy with the sql string
						Do While Not rec4.eof
							idList = idList & rec4("id") & ","
							rec4.moveNext
						loop
						idList = Left(idList, Len(idList) - 1)
						rec4.close

						b = savePDF(L2.getData("experimentType"),Trim(L2.getData("arxlabId")),revisionNumber,false,false,false)

						Select Case L2.getData("experimentType")
							Case "1"
								pdfExpType = "chem"
							Case "2"
								pdfExpType = "bio"
							Case "3"
								pdfExpType = "free"
							Case "4"
								pdfExpType = "anal"
							Case "5"
								pdfExpType = "cust"
						End select
						response.write("Waiting for PDF")
						Set rec3 = server.CreateObject("ADODB.RecordSet")
						strQuery = "select id from pdfProcQueue where companyId = "&SQLClean(companyId,"N","S")& " AND experimentId = "&SQLClean(Trim(L2.getData("arxlabId")),"N","S")& " and revisionNumber = "&SQLClean(revisionNumber,"N","S")& " and experimentType = '" & pdfExpType & "' and (status = 'NEW' or status = 'inProgress') and id not in (" & idList & ")"
						'response.write(strQuery)
						rec3.open strQuery,conn,3,3
						Do While Not rec3.eof
							response.write(".")
							response.flush()
							connAdm.execute("WAITFOR DELAY '00:00:01'")
							rec3.close
							rec3.open strQuery,conn,3,3
						loop
						response.write("<br />")
					end if

					a = backupExperiment(L2.getData("arxlabId"),L2.getData("experimentType"),wholePath)
				End if
			End if
			If L2.hasKey("children") Then
				Set L3 = L2.getItem("children")
				findExperiments L3,prevName&"\"&name
			End if
		next
	End function

	Set L = getBackupList(request.Form("topLevel"),request.Form("searchTerm"),"object")
	findExperiments L,""
				


	Call getconnectedadm

	' create the bulk export folders with company id's
	exportRootRoot = Replace(exportRoot, "\" & session("companyId"), "")	

	If Not fso.FolderExists(exportRoot) Then
		a = recursiveDirectoryCreate(exportRootRoot, exportRoot)
	End if

	If Not fso.FolderExists(exportRoot&"\exports\"&session("userId")) Then
		a = recursiveDirectoryCreate(exportRoot, exportRoot&"\exports\"&session("userId"))
	End if
	Set fso = Nothing	

	endFile = exportRoot&"\exports\"&session("userId")
	endFile = endFile & "\backup-"&Replace(date(),"/","")&"-"&Replace(FormatDateTime(now, 4),":","")&".zip"
	strQuery = "INSERT into exports(userId,exportPath,endFile,status) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(exportPath,"T","S")&","&SQLClean(endFile,"T","S")&",0)"
	connAdm.execute(strQuery)
	Call disconnectAdm
	response.write("<meta http-equiv=""refresh"" content=""1;url="&mainAppPath&"/exports/exportWait.asp"&""">")
	response.write("<script type=""text/javascript"">")
	response.write("window.location = """&mainAppPath&"/exports/exportWait.asp"&"""")
	response.write("</script>")
	response.write("</script>")
	response.write("</body>")
	response.write("</html>")
	response.end()
	'response.redirect(mainAppPath&"/exports/exportWait.asp")
End if
%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<script type="text/javascript">

function cycleObject(ob,level)
{
	if (arguments.length == 1)
	{
		var level
		level = 1
	}
	var str
	var i
	if (level == "1")
	{
		str = "<ul class='groupsList'>"
		str += "<li class='groupListUsers'><input type='checkbox' onclick='nodes = this.parentNode.parentNode.getElementsByTagName(\"input\");for(j=0;j<nodes.length;j++){if(this.checked){nodes[j].checked=true}else{nodes[j].checked=false}}' class='groupCheck' id='gSelectAll'>&nbsp;&nbsp;&nbsp;<a href='javascript:void(0);return false;'>Select All</a>"
	}
	else
	{
		str = "<ul class='groupsList' style='display:none;'>"
	}
	if(ob instanceof Array)
	{
		for(i=0;i<ob.length;i++)
		{
			if ('id' in ob[i])
			{
				//alert(i+' '+ob[i].id+'\n'+ob[i].name+'\n'+ob[i].type)
				if (ob[i].type == "project" || ob[i].type == "tab")
				{
					hrefStr = "<%=mainAppPath%>/show-project.asp?id="+ob[i].arxlabId
				}
				if (ob[i].type == "notebook")
				{
					hrefStr = "<%=mainAppPath%>/show-notebook.asp?id="+ob[i].arxlabId
				}
				if (ob[i].type == "experiment")
				{
					if (ob[i].subType == 'c')
					{
						hrefStr = "<%=mainAppPath%>/experiment.asp?id="+ob[i].arxlabId
					}
					if (ob[i].subType == 'b')
					{
						hrefStr = "<%=mainAppPath%>/bio-experiment.asp?id="+ob[i].arxlabId
					}
					if (ob[i].subType == 'f')
					{
						hrefStr = "<%=mainAppPath%>/free-experiment.asp?id="+ob[i].arxlabId
					}
					if (ob[i].subType == 'a')
					{
						hrefStr = "<%=mainAppPath%>/anal-experiment.asp?id="+ob[i].arxlabId
					}
					if (ob[i].subType == 'w')
					{
						hrefStr = "<%=mainAppPath%>/cust-experiment.asp?id="+ob[i].arxlabId
					}
				}
				if (ob[i].type == "user")
				{
					hrefStr = "<%=mainAppPath%>/users/user-profile.asp?id="+ob[i].arxlabId
				}
				str += "<li class='groupListUsers'><input type='checkbox' onclick='nodes = this.parentNode.getElementsByTagName(\"input\");for(j=0;j<nodes.length;j++){if(this.checked){nodes[j].checked=true}else{nodes[j].checked=false}}' class='groupCheck' id='"+ob[i].id+"' name='"+ob[i].id+"'>"
				if ('children' in ob[i])
				{
					if (ob[i].children.length > 0)
					{
						str += "<a href='javascript:void(0);' onclick='if(this.innerHTML==\"+\"){this.parentNode.getElementsByTagName(\"ul\")[0].style.display=\"block\";this.innerHTML=\"&ndash;\"}else{this.parentNode.getElementsByTagName(\"ul\")[0].style.display=\"none\";this.innerHTML=\"+\"};return false;' class='expandGroupLink''>+</a>"
					}
					else
					{
						str += "&nbsp;&nbsp;&nbsp;"
					}
				}
				str += "<a href='"+hrefStr+"'>"+ob[i].name+"</a>"
				if ('children' in ob[i])
				{
					str += " ("+ob[i].children.length+")"
					str += cycleObject(ob[i].children,level+1)
				}
				str += "</li>"
			}
			else
			{
				str+= cycleObject(ob[i],level+1)
			}
		}
	}

	str +="</ul>"

	return str
}

function getList()
{
	searchTerm = document.getElementById("searchTerm").value;
	topLevel = ""
	len = document.f1.topLevel.length
	for (i = 0; i <len; i++)
	{
		if (document.f1.topLevel[i].checked)
		{
			topLevel = document.f1.topLevel[i].value
		}
	}
	ob = eval(getFile("<%=mainAppPath%>/exports/ajax/load/getBackupTable.asp?searchTerm="+searchTerm+"&topLevel="+topLevel+"&random="+Math.random()))
	document.getElementById("experimentsDiv").innerHTML = cycleObject(ob)
	document.getElementById("submitButton").style.display = "block"
}
</script>

<h1>Bulk Export</h1>
<%Call getconnected%>
<form method="POST" action="<%=mainAppPath%>/exports/bulk-export.asp" name="f1">
	<fieldset style="width:300px;">
		<legend style="font-weight:bold;padding:0px 5px;">OPTIONS</legend>
		<table style="padding:8px;">
			<tr>
				<td nowrap style="padding-right:10px;">
					Search
				</td>
				<td>
					<input type="text" name="searchTerm" id="searchTerm" style="display:inline;" onkeypress="if (event.keyCode == 13){getList();return false;}">
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<table>
						<tr>
							<td>
								<input type="radio" name="topLevel" id="topLevel" value="project" style="display:inline;" checked>&nbsp;Project
							</td>
							<td>
								<input type="radio" name="topLevel" id="topLevel" value="notebook" style="display:inline;margin-left:10px;">&nbsp;Notebook
							</td>
							<td>
								<input type="radio" name="topLevel" id="topLevel" value="manager" style="display:inline;margin-left:10px;">&nbsp;Manager
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td colspan="2" id="listContainer">

				</td>
			</tr>
			<tr>
				<td colspan="2" align="right">
					<input type="button" value="Get Experiments" onClick="getList()" style="padding:2px;">
				</td>
			</tr>
		</table>
	</fieldset>
	<p id="errorP" style="display:none;">No experiments have been updated since your last export.</p>
	<div id="experimentsDiv">

	</div>
	<div style="width:400px;display:none;" align="right" id="submitButton">
		<input type="submit" name="submit" value="Export" style="width:200px;">
	</div>
</form>
<%Call disconnect%>
<!-- #include file="../_inclds/footer-tool.asp"-->