<!DOCTYPE html>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="arxlab/entityDecode/decodeFunctions.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
hasAnalExperiment = getCompanySpecificSingleAppConfigSetting("hasAnalyticalExperiments", session("companyId"))
blockNewColab = getCompanySpecificSingleAppConfigSetting("disableFreeExps", session("companyId"))
hasFreeExperiment = getCompanySpecificSingleAppConfigSetting("hasFreeExperiments", session("companyId"))
Server.ScriptTimeout=108000%>
<%
Response.ContentType = "text/html"
Response.AddHeader "Content-Type", "text/html;charset=UTF-8"
Response.CodePage = 65001
Response.CharSet = "UTF-8"
sectionId = "show-notebook"
subSectionID = "show-notebook"
notebookId = Request.querystring("id")
%>

<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/common/js/invites.asp"-->
<!-- #include file="_inclds/common/js/groupsJS.asp"-->

<link href="<%=mainAppPath%>/search/elasticSearch/jQuery-QueryBuilder-2.4.3/css/query-builder.dark.min.css" rel="stylesheet" type="text/css">
<link href="<%=mainAppPath%>/css/font-awesome/4.7.0/font-awesome.min.css" rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" crossorigin="anonymous">
<link href="<%=mainAppPath%>/search/elasticSearch/nobootstrap.css" rel="stylesheet" type="text/css">
<%

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT n.name, " &_
            "       n.description, " &_
            "       u.firstName, " &_
            "       u.lastName, " &_
            "       n.userId " &_
            "FROM notebooks n " &_
            "INNER JOIN users u " &_
            "ON n.userId = u.id " &_
            "WHERE n.id=" & SQLClean(notebookId,"N","S")
rec.Open strQuery,conn

If not rec.eof Then
    notebookName = rec("name")
    notebookDescription = rec("description")
    notebookCreator = rec("firstName") & " " & rec("lastName")
    notebookUserId = rec("userId")
End If
rec.Close

strQuery = "SELECT id " &_
           "FROM notebookInvites " &_
           "WHERE notebookId=" & SQLClean(notebookId,"N","S") &_
           " AND shareeId=" & SQLClean(session("userId"),"N","S") &_
           " AND canRead=1"
rec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
If Not rec.eof Then
    readInvite = True
Else
    readInvite = False
End if
rec.close
notebookCompanyId = getnotebookCompanyId(notebookId)
canRead = canReadNotebook(notebookId,session("userId"))
canWrite = canWriteNotebook(notebookId)
hasInvite = hasNotebookInvite(notebookId,session("userId"))
hasInviteRead = hasNotebookInviteRead(notebookId,session("userId"))
hasInviteWrite = hasNotebookInviteWrite(notebookId,session("userId"))
notebookOwner = ownsNotebook(notebookId)
notebookShared = isNotebookShared(notebookId)
notebookVisible = isNotebookVisible(notebookId)
descriptionFieldId = "notebookDescription"
editDescriptionCriteria = notebookOwner
editDescriptionId = notebookId
descriptionEditScript = mainAppPath&"/ajax_doers/changeNotebookDescription.asp"
originalData = HTMLDecode(notebookDescription)

' Check to make sure this is the right company
if CStr(notebookCompanyId) <> CStr(session("companyId")) then
	response.status = "404"
	response.end
end if

%>

<%
	header = notebookName
	pageTitle = header
%>

<!-- #include file="_inclds/header-tool.asp"-->
<!-- #include file="_inclds/nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script src="js/jquery.dataTables.1.10.15.min.js"></script>
<script src="js/moment.min.js"></script>
<script src="js/datetime-moment.js"></script>
<script src="_inclds/experiments/chem/js/getRxn.js?<%=jsRev%>"></script>
<script src="_inclds/common/functions/getCookie.js?<%=jsRev%>"></script>
<link href="css/jquery.dataTables.1.10.15.css" rel="stylesheet" type="text/css">
<link href="css/buttons.dataTables.min.css" rel="stylesheet" type="text/css">
<link href="css/fixedHeader.dataTables.min.css" rel="stylesheet" type="text/css">

<% if canRead = True or canWrite = True or hasInvite = True or isAdminUser(session("userId")) then %>

<!-- #include file="_inclds/common/html/infoBox.asp"-->
<!-- #include file="_inclds/notebooks/html/notebookTopRightFunctions.asp"-->

<h1 id="NotebookTitle"><%=header%>
<%If (session("canDelete") = True And ownsNotebook(notebookId) = True) Or (session("role")="Admin" And session("canDelete") = true) then%>
	<form method="post" action="<%=mainAppPath%>/notebooks/ajax/do/delete-notebook.asp" id="deleteForm" target="submitFrame">
		<input type="hidden" name="notebookId" value="<%=notebookId%>">
		<a href="javascript:void(0);" onclick="deleteSubmit()" class="deleteObjectLink">(<%=deleteLabel%>)</a>
	</form>
<%End if%>
</h1>

<%If session("role") = "Admin" then%>
	<input type="hidden" id="notebookIdForChange" value="<%=notebookId%>">
	<div id="ownerDiv" style="padding-top:6px;">
		<span class="notebookCreator"><span class="notebookCreatorTitle"><%=ownerLabel%>:&nbsp;</span><span id="notebookOwnerSpan"><%=notebookCreator%></span> <a href="javascript:void(0);" onClick="document.getElementById('ownerDiv').style.display='none';document.getElementById('changeOwnerDiv').style.display = 'block'"><img border="0" src="images/btn_edit.gif"></a></span>
	</div>
	<div id="changeOwnerDiv" style="display:none;padding-top:6px;">
	<span class="notebookCreator"><span class="notebookCreatorTitle"><%=ownerLabel%>:&nbsp;</span>
	<select id="changeNotebookUserId" style="display:inline;" onChange="changeOwner()">
	<%
	Set tRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id, firstName, lastName FROM users WHERE roleId <= 30 AND companyId="&SQLClean(session("companyId"),"N","S") & " AND enabled=1 ORDER BY firstName"
	tRec.open strQuery,conn,adOpenStatic,adLockReadOnly
	Do While Not tRec.eof
		%>
			<option value="<%=tRec("id")%>" <%If CStr(tRec("id")) = CStr(notebookUserId) then%>selected<%End if%>><%=tRec("firstName")%>&nbsp;<%=tRec("lastName")%></option>
		<%
		tRec.movenext
	loop
	%>
	</select>
	<a href="javascript:void(0);" onClick="document.getElementById('ownerDiv').style.display='block';document.getElementById('changeOwnerDiv').style.display = 'none'"><img border="0" style="width:12px;height:12px;" src="images/delete.png"></a>
	</span>
	</div>
<%else%>
	<span class="notebookCreator"><span class="notebookCreatorTitle"><%=ownerLabel%>:&nbsp;</span><%=notebookCreator%></span>
<%End if%>

<!-- #include file="_inclds/notebooks/html/makeEditableDescription.asp"-->

<%
	If session("hasAccordInt") then
		Call getConnectedJchemReg
		Set reca = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cd_id FROM accMols WHERE notebookId="&SQLClean(notebookId,"N","S")&" AND included=1"
		reca.open strQuery,jchemRegConn,adOpenStatic,adLockReadOnly

		If Not reca.eof Then
%>
	<a href="javascript:void(0);" id="showTOCLink" onclick="document.getElementById('tocIframe').src='<%=mainAppPath%>/accint/frame-show-toc.asp?notebookId=<%=notebookId%>&notebookName=<%=notebookName%>';this.style.display='none';">Show TOC</a>
	<iframe id="tocIframe" width="880" height="1" style="width:880px;height:1px;" scrolling="no" frameborder="0" style="border:none;" src="javascript:void(0);"></iframe>
<%
		End if
	
		reca.close
		Set reca = nothing
		Call disconnectJchemReg
		
	Else
		' The first magic number is the parent type code, the second is the target type code, and the third is the depth of the family tree we want.
		' Type Codes:
		' 1 - Request
		' 2 - Reg
		' 3 - Project
		' 4 - Notebook
		' 5 - Experiment
		' 6 - Inventory
		' 7 - Assay
		' 8 - Request Field Value
		' 9 - Request Item Field Value
		linkSvcResp = getChildLinks(4, notebookId, "ELN", 8, 1)
		set linkSvcData = JSON.parse(linkSvcResp)

		if linkSvcData.get("result") = "success" then
			set linksArr = JSON.parse(linkSvcData.get("data"))
			requestTypeFieldId = linksArr.get(0).get("targetId")
			if requestTypeFieldId <> "" then
				set requestObj = JSON.parse(decode(requestTypeFieldId, 8))
			end if			
		end if

		if requestObj = undefined then

			linkSvcResp = getChildLinks(4, notebookId, "ELN", 9, 1)
			set linkSvcData = JSON.parse(linkSvcResp)

			if linkSvcData.get("result") = "success" then
				set linksArr = JSON.parse(linkSvcData.get("data"))
				requestTypeFieldId = linksArr.get(0).get("targetId")
				if requestTypeFieldId <> "" then
					set requestObj = JSON.parse(decode(requestTypeFieldId, 9))
				end if			
			end if

		end if 

		if requestObj <> undefined then
			%>
				<div class="formRow">
					<a href="javascript:void(0);" id="showTOCLink" onClick="showReq(<%=requestObj.get("linkId")%>)">Show Request</a>			
					<iframe id="workflowRequestIframe" style="width:100%;height:600px;display:none;" frameborder="0" style="border:none;" src="javascript:void(0);"></iframe>
				</div>
			<%
		end if 

	End if
	
Set expDefaultRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT useDefaultExperimentTypes FROM companySettings WHERE companyId="&SQLClean(session("companyId"),"T","S")
expDefaultRec.open strQuery,conn,0,-1

loadDefaultExperiments = True
If Not expDefaultRec.eof Then
	If expDefaultRec("useDefaultExperimentTypes") = 0 Or expDefaultRec("useDefaultExperimentTypes") = "0" Then
		loadDefaultExperiments = False
	End If
End If

If loadDefaultExperiments and canWrite and notebookVisible Then
%>
		<script type="text/javascript"> 
				// check what browser we're using and display the appropriate div
				$(document).ready(function () {
					if (msieversion()) {
						$(".newReactExperimentButton").show()
					} else {
						$(".createExperimentDiv").show();
					}
				}); 
		</script>
		
		<div class="createExperimentDiv" hidden="true" style="display: none;">
			<h2><%=createExperimentLabel%></h2>
			<%If session("hasChemistry") then%>
				<%If Not session("hideNonCollabExperiments") then%>
					<a href="<%=session("expPage")%>?notebookId=<%=notebookId%>" class="createLink"><%=chemistryExperimentLabel%></a>
				<%End if%>
			<%End if%>
			<%If Not session("hideNonCollabExperiments") then%>
				<a href="bio-experiment.asp?noteBookId=<%=notebookId%>" class="createLink"><%=biologyExperimentLabel%></a>
			<%End if%>
			<%If hasFreeExperiment and not blockNewColab Then %>
				<a href="free-experiment.asp?notebookId=<%=notebookId%>" class="createLink">
				<%If session("hasMUFExperiment") then%>
					<%=mufName%>
				<%else%>
					<%=conceptExperimentLabel%>
				<%End if%>
				</a>
			<% End If %>
			<%If hasAnalExperiment And Not session("hideNonCollabExperiments") then%>
				<%If Not session("hideNonCollabExperiments") then%>
					<a href="anal-experiment.asp?notebookId=<%=notebookId%>" class="createLink"><%=analExperimentLabel%></a>
				<%End if%>
			<%End if%>
		</div>

		<div class="newReactExperimentButton" hidden="true" style="display: none;">
		<a href="javascript:void(0)" onclick="if (window.InterCom){window.InterCom.props.openNewExperiment(<%=notebookId%>)}" class="createLink"><%=createExperimentLabel%></a>
		</div>

		<div id="createExpDropdownDiv" class="createExpDropdownDiv"
			<% If not canWrite then %>
			style="display: none;"
			<% end if %>
		>
			<select id="createCustExpList" name="newExperimentType" class="custExpSelect" style="display: none;">
				<option value="-1">--- SELECT ---</option>
			</select>
				<button id="createCustExpButton" class="query-builder btn btn-xl" data-target="basic" style="display: none;">Create</button>
		</div>
		
	<%End If%>
	<% end if %>

	<% if session("canDownloadAllNotebookPDFs") then %>
		<a id="downloadPDFsButton" href="javascript:void(0)" onclick="downloadAllPDFs()" class="createLink"><%=downloadAllPDFsLabel%></a>
	<% end if %>

	<%
			Set inviteRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT id, canRead, canWrite FROM notebookInvites WHERE notebookId=" & SQLClean(notebookId,"N","S")& " AND accepted=0 AND denied=0 AND shareeId="&SQLClean(session("userId"),"N","S")
			inviteRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
			If Not inviteRec.eof then
				if inviteRec("canRead") = 1 then
					canRead = True
				end if
				if inviteRec("canWrite") = 1 then
					canWrite = true
				end if
				invStr = "with "
				if canRead = True then
					invStr = invStr & "read "
				end If

				if canWrite then
					if canRead = True then
						invStr = invStr & "and "
					end if
					invStr = invStr & "write "
				end if
				invStr = invStr & "access"

	%>
	<div class="inviteDiv" style="border:5px solid black;">
		<span style="display:block;">
            You have been invited to share this notebook <%=invStr%>
		</span>
		<form action="<%=mainAppPath%>/notebooks/accept-invite.asp" method="post" target="submitFrame" id="acceptForm">
			<input type="hidden" id="inviteId" name="inviteId" value="<%=inviteRec("id")%>">
			<input type="hidden" id="notebookAcceptStatus" name="notebookAcceptStatus" value="">
			<input type="button" onClick="notebookAccept()" value="Accept" class="btn">
			<input type="button" onClick="notebookDecline()" value="Decline" class="btn">
		</form>
	</div>
<%
End if
%>

<script type="text/javascript">

	var notebookTableHeaders = [
		{"displayName":"Experiment Name","dbCol":"name"},
		{"displayName":"Status","dbCol":"status"},
		{"displayName":"Type","dbCol":"type"},
		{"displayName":"Creator","dbCol":"creator"},
		{"displayName":"Date Created","dbCol":"dateSubmittedServer"},
		{"displayName":"Last Modified","dbCol":"dateUpdatedServer"},
		{"displayName":"Actions","dbCol":""},
		{"displayName":"Description","dbCol":"desc"},
		{"displayName":"Experiment Type ID","dbCol":"typeId"},
		{"displayName":"Experiment ID","dbCol":"expId"},
		{"displayName":"Request Type ID","dbCol":"requestTypeId"}
	];
</script>

<div id="NotebookTableDiv" style="margin-top:25px;">
	<hr>
    <table id="NotebookTable" class="display responsive dtr-column" cellspacing="100" width="100%">
        <thead>
            <tr>
			<script type="text/javascript">
				$.each(notebookTableHeaders, function(i, obj) {
					document.write("<th>" + obj.displayName + "</th>")
				});
			</script>
            </tr>
        </thead>
    </table>
</div>

<%If canWrite = True And notebookVisible = True then%>

<table style="width:100%;margin-top:10px;">
	<tr>
		<td align="left" style="background-color:black;padding-bottom:0!important;" valign="top" colspan="2">
			<%If revisionId = "" And ownsExp then%>
				<a href="javascript:void(0)" onClick="showPopup('projectLinkDiv');return false;" id="projectLinkLink" title="New Project Link"><img border="0" src="images/Add.gif" class="png" style="position:absolute;right:5px;"></a>
			<%End if%>
			<div class="tabs"><h2><%=projectLinksLabel%></h2></div>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<table class="caseTable" cellpadding="0" cellspacing="0" style="width:100%;">
				<tr>
					<td class="caseInnerTitle" valign="top" id="projectLinksTD">
						<%
						Set lRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT p.name, p.id, p.description, p.parentProjectId from linksProjectNotebooks l inner join projects p on p.id=l.projectId where l.notebookId="&SQLClean(notebookId,"N","S")
						lRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
						Do While Not lRec.eof
							If canReadProject(lRec("id"), session("userId")) = True Then
								projectName = lRec("name")
								projectId = lRec("id")
								projectDescription = lRec("description")
								If canReadProject(projectId,session("userId")) = True Then
									If Not IsNull(lRec("parentProjectId")) Then
										Set lRec2 = server.CreateObject("ADODB.RecordSet")
										strQuery = "SELECT name, description FROM projects WHERE id="&SQLClean(lRec("parentProjectId"),"N","S")
										lRec2.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
										If Not lRec2.eof Then
											parentProjectName = lRec2("name")
										End If
										projectName = parentProjectName & " => "&projectName
										projectDescription = lRec2("description")
									End if
									%>
										<a href="show-project.asp?id=<%=projectId%>"><%=projectName%></a>
										<p class="linkDescription"><%=projectDescription%></p>
									<%
								End if
							End If
							lRec.moveNext
						loop
						%>
					</td>
				</tr>
			</table>
		</td>
	</tr>

  </table>
<%End if%>

<%If ((notebookOwner = True And hasShareNotebookPermission(false) = True) Or canShareNotebook(notebookId) = True) And notebookVisible = True then%>


<!-- #include file="_inclds/common/html/groupsDiv.asp"-->
<a href="javascript:void(0)" onClick="showShare()" class="shareNotebookLink" id="shareNotebookLink"><%=shareThisNotebookLabel%></a>
<div id="shareNotebookDiv" style="display:none;">
	<form method="post" action="<%=mainAppPath%>/notebooks/share-notebook.asp" id="shareForm" target="submitFrame" class="chunkyForm">
		<p><span id="numUsers">0</span> <%=numberOfUsersSelectedLabel%> <a href="javascript:void(0)" onclick="showPopup('groupsDiv');toggleGroup(0);" class="groupSelectLink">(<%=addLabel%>)</a></p>
		<p><span id="numGroups">0</span> <%=numberOfGroupsSelectedLabel%> <a href="javascript:void(0)" onclick="showPopup('groupsDiv')" class="groupSelectLink">(<%=addLabel%>)</a></p>
		<label for="notebookId"><%=accessOptionsLabel%></label>
		<input type="hidden" name="notebookId" id="notebookId" value="<%=notebookId%>"><br>
		<%If canRead = True then%>
			<input type="checkbox" name="canRead" id="canRead" style="float:left;margin:5px 4px 5px 20px;padding:0px;width:10px;"><span style="float:left;margin-top:5px;"><%=readAccessLabelNotebook%></span><div style="clear:both;height:1px;"></div>
		<%End if%>
		<%If canWrite = True then%>
			<input type="checkbox" name="canWrite" id="canWrite" style="float:left;margin:5px 4px 20px 20px;padding:0px;width:10px;"><span style="float:left;margin-top:5px;"><%=writeAccessLabelNotebook%></span><div style="clear:both;height:1px;"></div>
		<%End if%>
		<%If (notebookOwner = True And hasShareNotebookPermission(false) = True) Or canShareNotebook(notebookId) = True then%>
			<input type="checkbox" name="canShare" id="canShare" style="float:left;margin:5px 4px 20px 20px;padding:0px;width:10px;" onClick="if(this.checked){document.getElementById('notebookCanShareSharingCheck').style.display='block';this.style.marginBottom ='5px';}else{document.getElementById('notebookCanShareSharingCheck').style.display='none';this.style.marginBottom ='20px';document.getElementById('canShareShare').checked=false;}"><span style="float:left;margin-top:5px;"><%=grantSharingPermissionLabel%></span><div style="height:1px;clear:both;"></div>
			<div id="notebookCanShareSharingCheck" style="display:none;padding-top:0px;">
				<input type="checkbox" name="canShareShare" id="canShareShare" style="float:left;margin:5px 4px 20px 20px;padding:0px;width:10px;"><span style="float:left;margin-top:5px;">Allow User to Grant Sharing Permission to Others</span><div style="height:1px;clear:both;"></div>
			</div>
		<%End if%>
		<br/>
		<input type="hidden" name="groupIds" id="groupIds">
		<input type="hidden" name="userIds" id="userIds">
		<input type="hidden" name="allUserIds" id="allUserIds">
		<input type="button" value="<%=shareLabel%>" onclick="shareSubmit()" class="btn">
		<div>&nbsp;</div>
	</form>
</div>
<br/>
<%End if%>
<div id="invitesDiv">
</div>
<br>

<!-- #include file="_inclds/common/html/submitFrame.asp"-->
<%If (notebookOwner Or canShareNotebook(notebookId)) Or session("role")="Admin" then%>
<script type="text/javascript">
	invTable = getFile("<%=mainAppPath%>/notebooks/ajax/load/notebookInvitesTable.asp?id=<%=notebookId%>&random="+Math.random())
    document.getElementById("invitesDiv").innerHTML = invTable;
</script>
<%else%>
<%
If notebookVisible = True then
	If Not canRead = True And Not canWrite = True And Not hasInvite = True and not isAdminUser(session("userId")) Then
		%>
		<script>
			$("#NotebookTableDiv").remove();
		</script>
		<p>You are not authorized to read or write to this notebook</p><%
	End if
Else
	%>
		<script>
			$("#NotebookTableDiv").remove();
		</script>
		<p>This notebook has been deleted</p><%
End if

%>
<%End if%>
<div id="customExperimentTypesJson" style="display:none;">
<%response.write(getCustomExperimentTypes())%>
</div>
<script>

try { experimentTypeData = JSON.parse($("#customExperimentTypesJson").text()); } catch(err) { console.log("ERROR parsing experimentTypeData"); console.log(err); }
if(typeof experimentTypeData == "undefined")
	experimentTypeData = [];

<%
	If notebookVisible AND ((canRead = True or canWrite = True or hasInvite = true) OR notebookOwner Or canShareNotebook(notebookId)) then
%>
var notebookTable = $("#NotebookTable").DataTable( {
				"bServerSide": true,
				"sServerMethod": "POST",
				"sAjaxSource": "get-notebook.asp",
				"fnServerParams": function ( aoData ) {
					var sortStr = "";
					if(notebookTable) {
						$.each(notebookTable.order(), function(i, obj) {
							if(sortStr.length) {
								sortStr += ", ";
							}
							
							sortStr += notebookTableHeaders[obj[0]].dbCol + " " + obj[1];
						});
					}
					else {
						sortStr += "dateUpdatedServer desc";
					}
					
					aoData.push({"name": "sortOrder", "value": sortStr});
					aoData.push({"name": "notebookId", "value": "<%=notebookId%>"});
				},
                "columnDefs": [
                    {
                        "targets": [7,8,9,10],
                        "visible": false					}
				],
				"pageLength": 25,
				"lengthMenu": [ [10, 25, 50, 100], [10, 25, 50, 100] ],
				// Put B in front to restore the CSV button
				dom: "lfiprtip",
        		buttons: [
					{
						extend: "csvHtml5",
						exportOptions: {
							columns: ":visible"
						}
					}
				],
				"pagingType": "full_numbers",
				order: [[5, "desc"]],
                oLanguage: { sEmptyTable: "There are no experiments in this notebook." },
				stateSave: true,
				stateSaveCallback: function(settings, data) {
					var date = new Date();
					date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
					document.cookie="showAjaxNotebookCookie=" + JSON.stringify(data) + ";expires=" + date.toGMTString();
				},
				stateLoadCallback: function(settings) {
					return JSON.parse(getCookie("showAjaxNotebookCookie"));
				},
				drawCallback: function(settings) {
					notebookTable.rows().every( function ( rowIdx, tableLoop, rowLoop ) {
						var descRow = [];
						// If there is a description, put it in a child row
						if(notebookTable.cell(rowIdx, 7).data() != "") {
							descRow.push("<div class='multiLineSpacing' style='margin-left:25px;width=100%'>" + notebookTable.cell(rowIdx, 7).data() + "</div>");
						}
						
						// If there is a chemistry reaction, put it in a child row
						if(notebookTable.cell(rowIdx, 8).data() == "1") {
							descRow.push(notebookTable.cell(rowIdx, 9).data());
						}

						// Make the child row, if one is needed
						if(descRow.length) {
							this.child(descRow).show();
						}
						
						// Put in the correct names for the custom experiment types
						if(notebookTable.cell(rowIdx, 8).data() == "5") {
							var myRequestTypeId = notebookTable.cell(rowIdx, 10).data();
							$.each(experimentTypeData, function(i, obj) {
								if(obj.hasOwnProperty("displayName") && obj.hasOwnProperty("id") && obj["id"] == myRequestTypeId) {
									notebookTable.cell(rowIdx, 2).data(obj["displayName"]);
									return false;
								}
							});
						}
					} );

					addRxnToVisible(notebookTable, 9);
				}
});
$.fn.dataTable.moment();
<%
	End if
%>

/**
 * Disables the download PDFs button and sends a request to the downloadPDFsForNotebook endpoint.
 */
function downloadAllPDFs() {
	$("#downloadPDFsButton").attr("onclick", "").text("Processing");
	$.ajax({
		url: "/arxlab/ajax_doers/downloadPDFsForNotebook.asp",
		data: {
			notebookId: "<%=notebookId%>"
		}
	}).done(function(response) {
		swal("Processing PDFs", "The system is currently processing all of the PDFs to be downloaded. Please give up to 24 hours for this task to be completed and an email to be sent with further instructions.");
	}).fail(function(response) {
		swal("Error!", "Could not perform the requested action.", "warning");
	});
}

</script>
<!-- #include file="workflow/_inclds/Workflow_Includes.asp"-->
<!-- #include file="_inclds/footer-tool.asp"-->
</html>
<%
'Lets do this last
addToRecentlyViewedNotebooks(notebookId)
%>
