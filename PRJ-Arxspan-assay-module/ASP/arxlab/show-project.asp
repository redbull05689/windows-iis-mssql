<!DOCTYPE html>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="arxlab/entityDecode/decodeFunctions.asp" -->
<%Server.ScriptTimeout=108000%>
<%
Response.ContentType = "text/html"
Response.AddHeader "Content-Type", "text/html;charset=UTF-8"
Response.CodePage = 65001
Response.CharSet = "UTF-8"
sectionId = "show-project"
subsectionId = "show-project"
%>

<script>
	window.CurrentPageMode = "custExp"
	window.currApp = "Workflow";
</script>

<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/common/html/popupDivs.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link rel="stylesheet" type="text/css" href="js/chosen/chosen.css">
<link rel="stylesheet" type="text/css" href="js/select2-3.5.1/select2.css">
<link href="css/project_buttons.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<script type="text/javascript" src="js/projectTabNaming.js"></script>

<%

	' Check to see if this user has Registration and access to it.
	hasReg = session("hasReg") AND session("regRoleNumber") <> 1000

    projectId = request.querystring("id")
    tab = request.querystring("t")
	projectVisible = false

	' Check to make sure this is the right company
	if CStr(getProjectCompanyId(projectId)) <> CStr(session("companyId")) then
		response.status = "404"
		response.end
	end if

	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT parentProjectId, name, description, firstName, lastName, userId " &_
               "FROM projectsView " &_
               "WHERE id=" & SQLClean(projectId,"N","S") &_
               " AND visible=1"
    rec.open strQuery,conn

    if not rec.eof then
        If Not IsNull(rec("parentProjectId")) Then
				response.redirect("show-project.asp?id="&rec("parentProjectId")&"&t="&projectId)
        End if
        projectName = rec("name")
		projectDescription = rec("description")
		projectCreator = rec("firstName") & " " & rec("lastName")
		projectOwner = (CStr(rec("userId")) = cstr(session("userId")))
		projectUserId = rec("userId")
		projectVisible = true
    end if
    rec.close
    
	strQuery = "SELECT fromProjectId, fromProjectName FROM projectAutoLinksView WHERE disabled=0 AND toProjectId=" & SQLClean(projectId,"N","S")
	rec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
	includedProjects = "|"
	Do While Not rec.eof
		includedProjects = includedProjects & rec("fromProjectId") & ":" & rec("fromProjectName") & "|"
		rec.movenext()
	Loop
	rec.close

	strQuery = "SELECT id, name, includedFromProjectId " &_
	"FROM projects " &_
	"WHERE parentProjectId=" & projectId &_
	" ORDER BY id;"
	rec.open strQuery,conn
	subProjects = ""
	Do While Not rec.eof
		subProjects = subProjects & rec("name") & ":::" & rec("id") & ";;;"
		rec.movenext()
	Loop
	rec.close

	header = projectName
	pageTitle = header
%>

<!-- #include file="_inclds/common/js/invites.asp"-->
<!-- #include file="_inclds/common/js/groupsJS.asp"-->
<!-- #include file="_inclds/header-tool.asp"-->
<!-- #include file="_inclds/nav_tool.asp"-->
<script src="js/jquery.dataTables.1.10.15.min.js"></script>
<script src="js/moment.min.js"></script>
<script src="js/datetime-moment.js"></script>
<script src="_inclds/experiments/chem/js/getRxn.js?<%=jsRev%>"></script>
<script src="_inclds/common/functions/getCookie.js?<%=jsRev%>"></script>
<link href="css/jquery.dataTables.1.10.15.css" rel="stylesheet" type="text/css">
<link href="css/buttons.dataTables.min.css" rel="stylesheet" type="text/css">

<div class="itemDataContainer">

    <%
	canRead = canReadProject(projectId, session("userId"))
	canWrite = canWriteProject(projectId, session("userId"))
	invitePending = False
    Set inviteRec = server.CreateObject("ADODB.RecordSet")
    strQuery = "SELECT id, accepted FROM projectInvitesView WHERE projectId=" & SQLClean(projectId,"N","S")& " AND denied=0 AND shareeId="&SQLClean(session("userId"),"N","S")
    inviteRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
    If Not inviteRec.eof then
		inviteId = inviteRec("id")
		if inviteRec("accepted") = 0 then
			invitePending = True
		end if
		
        invStr = "with "
        if canRead then
            invStr = invStr & "read "
        end If

        if canWrite then
            if canRead then
                invStr = invStr & "and "
            end if
            invStr = invStr & "write "
        end if
        invStr = invStr & "access"

    %>
		<iframe id="submitFrame" name="submitFrame" style="display:none;"></iframe>
		<% if invitePending then %>
        <div class="inviteDiv" style="border:5px solid black;">
            <span style="display:block;">
                You have been invited to share this project <%=invStr%>
            </span>
            <form action="<%=mainAppPath%>/projects/accept-project-invite.asp" method="post" target="submitFrame" id="acceptForm">
                <input type="hidden" id="inviteId" name="inviteId" value="<%=inviteId%>">
                <input type="hidden" id="notebookAcceptStatus" name="notebookAcceptStatus" value="">
                <input type="button" onClick="notebookAccept()" value="Accept" class="btn">
                <input type="button" onClick="notebookDecline()" value="Decline" class="btn">
            </form>
        </div>
		<% end if %>
    <%
    End if
	inviteRec.close
	set inviteRec = nothing
    %>
</div>
<br>
<div class="container">
	<% If not isAdminUser(session("userId")) and Not ownsProject(projectId) And Not canRead = True And Not canWrite = True Then %>
		<span>You are not authorized to read or write to this project.</span>
	<% Else %>
	
    <!-- #include file="_inclds/projects/html/projectTopRightFunctions.asp"-->
    <!-- #include file="_inclds/common/html/infoBox.asp"-->

<div style='display:inline-block'>
<h1 id="ProjectTitle"><%=header%></h1>
<%If session("canDelete") then%>
	<div class="tabDeleteButtonsContainer"><button class="rightSideTabButton" onclick="deleteProject(<%=projectId%>)"><%=deleteLabel%></button></div>
<%End if%>

<%If projectOwner then%> 
	<div class="tabRightSideButtonsContainer"><button class="rightSideTabButton" onclick="showPopup('addTabDiv');document.getElementById('projectId').value='<%=projectId%>';document.getElementById('tabName').focus();return false;"><%=addTabLabel%></button></div>
<%End if%>
</div>

<form>
	<fieldset>
		<div class="formRow">
			<span class="label_value" style="vertical-align:top;">
				<b>Owner:</b><br>
				<span class="label_value" id="projectOwnerSpan"><span id="projectOwnerSpanInner"><%=projectCreator%></span>
				<%If session("role") = "Admin" Then%>
					<a href="javascript:void(0);" onClick="document.getElementById('projectOwnerSpan').style.display='none';document.getElementById('changeOwnerDiv').style.display = 'inline-block'"><img border="0" src="images/btn_edit.gif"></a></span>
					<input type="hidden" id="projectIdForChange" value="<%=projectId%>">
					<div id="changeOwnerDiv" style="display:none;">
					<select id="changeProjectUserId" style="display:inline;" onChange="changeOwner()">
					<%
					Set tRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT id, firstName, lastName FROM usersView WHERE canLeadProjects=1 AND companyId="&SQLClean(session("companyId"),"N","S") & " AND enabled=1 ORDER BY firstName,lastName"
					tRec.open strQuery,conn,3,3
					Do While Not tRec.eof
						%>
							<option value="<%=tRec("id")%>" <%If CStr(tRec("id")) = CStr(projectUserId) then%>selected<%End if%>><%=tRec("firstName")%>&nbsp;<%=tRec("lastName")%></option>
						<%
						tRec.movenext
					loop
					%>
					</select>
					</div>
				<%End if%>
			</span>
		</div>

		<div class="formRow">
			<%
				descriptionFieldId = "projectDescription"
				editDescriptionCriteria = projectOwner
				editDescriptionId = projectId
				descriptionEditScript = mainAppPath&"/ajax_doers/changeProjectDescription.asp"
				originalData = HTMLDecode(projectDescription)
			%>
			<span class="label_value" style="vertical-align:top;">
				<b>Description: </b>
				<!-- #include file="_inclds/projects/html/makeEditableDescription.asp"-->
			</span>
		</div>

		<div class="formRow">
			<%
				includeProjectsFieldId = "includedProjects"
				includeProjectsCriteria = projectOwner
				editIncludedProjectsId = projectId
				includeProjectsEditScript = mainAppPath&"/ajax_doers/changeIncludedProjects.asp"
				originalIncludedProjects = includedProjects
			%>
			<span class="label_value" style="vertical-align:top;">
				<b>Included Projects: </b>
				<!-- #include file="_inclds/projects/html/makeEditableIncludedProjects.asp"-->
			</span>
		</div>
		<%
		
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
			linkSvcResp = getChildLinks(3, projectId, "ELN", 8, 1)
			set linkSvcData = JSON.parse(linkSvcResp)

			if linkSvcData.get("result") = "success" then
				set linksArr = JSON.parse(linkSvcData.get("data"))
				requestTypeFieldId = linksArr.get(0).get("targetId")
				if requestTypeFieldId <> "" then
					set requestObj = JSON.parse(decode(requestTypeFieldId, 8))
				end if			
			end if

			if requestObj = undefined then

				linkSvcResp = getChildLinks(3, projectId, "ELN", 9, 1)
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

		%>
	</fieldset>
</form>
		<div id="Subprojects">
		</div>
		<br>
		<div id="NotebookTableDiv">
			<h1>Notebooks</h1>
			<table id="NotebookTable" class="display" cellspacing="100" width="100%">
				<thead>
					<tr>
						<th>Notebook Name</th>
						<th>Description</th>
						<th>Owner</th>
						<th></th>
					</tr>
				</thead>
			</table>
		</div>
		<br>
		<div id="ExperimentTableDiv">
			<h1>Experiments</h1>
			<table id="ExperimentTable" class="display" cellspacing="100">
				<thead>
					<tr>
						<th>Experiment Name</th>
						<th>Description</th>
						<th>Status</th>
						<th>Type</th>
						<th>Creator</th>
						<th>Date Created (EDT)</th>
						<th></th>
					</tr>
				</thead>
			</table>
		</div>
		<br>
		
		<%	If hasReg then  %>
		<div id="RegistrationItemsDiv">
			<h1>Registration Items</h1>
			<table id="RegItemsTable" class="display" cellspacing="100">
				<thead>
					<tr>
						<th>Reg Number</th>
						<th>Structure</th>
						<th>Molecular Weight</th>
						<th>Date Created</th>
						<th></th>
					</tr>
				</thead>
			</table>
		</div>
		<%  End if  %>

	<% End if %>
</div>

<%If (projectOwner Or isAdminUser(session("userId"))) And Not inFrame then%>
		<!-- #include file="_inclds/common/html/groupsDiv.asp"-->
		<iframe id="submitFrame" name="submitFrame" style="display:none;"></iframe>
		<a href="javascript:void(0)" onClick="showShare()" class="shareNotebookLink" id="shareNotebookLink"><%=shareThisProjectLabel%></a>
			<div id="shareNotebookDiv" style="display:none;">
				<form method="post" action="<%=mainAppPath%>/projects/share-project.asp" id="shareForm" target="submitFrame" class="chunkyForm">
					<p><span id="numUsers">0</span> <%=numberOfUsersSelectedLabel%> <a href="javascript:void(0)" onclick="showPopup('groupsDiv');toggleGroup(0);" class="groupSelectLink">(<%=addLabel%>)</a></p>
					<p><span id="numGroups">0</span> <%=numberOfGroupsSelectedLabel%> <a href="javascript:void(0)" onclick="showPopup('groupsDiv')" class="groupSelectLink">(<%=addLabel%>)</a></p>
					<label for="notebookId"><%=accessOptionsLabel%></label>
					<input type="hidden" name="projectId" id="projectId" value="<%=projectId%>"><br>
					<input type="checkbox" name="canRead" id="canRead" style="display:inline;margin:5px 4px 5px 20px;padding:0px;width:10px;">View/Read All Contents of Project<br/>
					<input type="checkbox" name="canWrite" id="canWrite" style="display:inline;margin:5px 4px 20px 20px;padding:0px;width:10px;">Write/Create Experiments in Project
					<input type="hidden" name="groupIds" id="groupIds">
					<input type="hidden" name="userIds" id="userIds">
					<input type="hidden" name="allUserIds" id="allUserIds">
					<input type="button" value="<%=shareLabel%>" onclick="shareSubmit()" class="btn">
				<div>&nbsp;</div>
				</form>
			</div>
			<br>

<%End if%>
		<div id="invitesDiv" style="margin-left:10px;">
		</div>
		<%If (ownsProject(projectId) Or session("role")="Admin") And Not inframe then%>
		<script type="text/javascript">
			addLoadEvent(getInvites);
		</script>
<%End if%>

<div id="customExperimentTypesJson" style="display:none;">
<%response.write(getCustomExperimentTypes())%>
</div>
<script>
var searchWait = 0;
var searchWaitInterval;

try { experimentTypeData = JSON.parse($("#customExperimentTypesJson").text()); } catch(err) { console.log("ERROR parsing experimentTypeData"); console.log(err); }
if(typeof experimentTypeData == "undefined")
	experimentTypeData = [];
var projectId = <%=projectId%>;

var subprojects = parseSubprojects("<%=subProjects%>")
makeSubprojectButtons(subprojects);

// Hack for ELN-1606: projects with no subprojects won't have a "firstSubproject"
var firstSubproject = projectId;

if (Object.keys(subprojects).length > 0) {
	firstSubproject = Object.keys(subprojects)[0];
	changePasteProj(firstSubproject);
}

var descCol = 1;

var experimentTableHeaders = [
	{"displayName":"Experiment Name","dbCol":"name"},
	{"displayName":"Description","dbCol":"details"},
	{"displayName":"Status","dbCol":"status"},
	{"displayName":"Type","dbCol":"ae.experimenttype"},
	{"displayName":"Creator","dbCol":"u.firstName, u.lastName"},
	{"displayName":"Date Created","dbCol":"ae.dateSubmitted"},
	{"displayName":"Request Type ID","dbCol":"requestTypeId"}
];

function makeTableConf(cookieId) {
	var tableConfig = {
		"columnDefs": [
			{
				"targets": [ descCol ],
				"visible": false,
				"searchable": true
			}
		],
		"pagingType": "full_numbers",
		// Put B in front to restore the CSV button
		dom: 'fiprtip',
		buttons: [
			{
				extend: 'csvHtml5',
				exportOptions: {
					columns: ':visible'
				}
			}
		],
		stateSave: true,
		stateSaveCallback: function(settings, data) {
			var date = new Date();
			date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
			document.cookie="show" + cookieId + "Cookie=" + JSON.stringify(data) + ";expires=" + date.toGMTString();
		},
		stateLoadCallback: function(settings) {
			return JSON.parse(getCookie("show" + cookieId + "Cookie"));
		},
		oLanguage: { sEmptyTable: "No data." }
	}
	return tableConfig;
}

var notebookTable = $('#NotebookTable').DataTable(makeTableConf("ProjectNotebook"));

var curProjectId;
function setProjectId(projectId){
	curProjectId = projectId;
}

function makeExpTable(projectId){

	try { experimentTypeData = JSON.parse($("#customExperimentTypesJson").text()); } catch(err) { console.log("ERROR parsing experimentTypeData"); console.log(err); }
	if(typeof experimentTypeData == "undefined"){
		experimentTypeData = [];
		}

	setProjectId(projectId);
	if ($.fn.DataTable.isDataTable( '#ExperimentTable' ) ) {
		var expTable = $('#ExperimentTable').dataTable();
		expTable.fnDraw();
	}else{
		var expTable = $('#ExperimentTable').DataTable({
			"destroy": true, //If we are switching tabs, just update the server params
			"bServerSide": true,
			"sServerMethod": "POST",			
			"sAjaxSource": "get-project-experiment.asp",
			"fnServerParams": function ( aoData ) {
				var sortStr = "";
				if(expTable) {
					$.each(expTable.order(), function(i, obj) {
						if(sortStr.length) {
							sortStr += ", ";
						}
						
						sortStr += experimentTableHeaders[obj[0]].dbCol + " " + obj[1];
					});
				}
				else {
					sortStr += "lpeId desc";
				}
				
				aoData.push({"name": "sortOrder", "value": sortStr});
				aoData.push({"name": "projId", "value": curProjectId});
			},
			"columnDefs": [
				{
					"targets": [7,8,9],
					"visible": false
				}
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
			oLanguage: { sEmptyTable: "There are no experiments." },
			stateSave: true,
			stateSaveCallback: function(settings, data) {
				var date = new Date();
				date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
				document.cookie="showAjaxProjectExperimentCookie=" + JSON.stringify(data) + ";expires=" + date.toGMTString();
			},
			stateLoadCallback: function(settings) {
				return JSON.parse(getCookie("showAjaxProjectExperimentCookie"));
			},
			drawCallback: function(settings) {
				expTable.rows().every( function ( rowIdx, tableLoop, rowLoop ) {
					var descRow = [];
					// If there is a chemistry reaction, put it in a child row
					if(expTable.cell(rowIdx, 7).data() == "1") {
						descRow.push(expTable.cell(rowIdx, 8).data());
					}

					// Make the child row, if one is needed
					if(descRow.length) {
						this.child(descRow).show();
					}
					
					// Put in the correct names for the custom experiment types
					if(expTable.cell(rowIdx, 7).data() == "5") {
						var myRequestTypeId = expTable.cell(rowIdx, 9).data();
						$.each(experimentTypeData, function(i, obj) {
							if(obj.hasOwnProperty("displayName") && obj.hasOwnProperty("id") && obj["id"] == myRequestTypeId) {
								expTable.cell(rowIdx, 3).data(obj["displayName"]);
								return false;
							}
						});
					}
				} );
				addRxnToVisible(expTable, 8);
			}
		});
		expTable.on( 'page.dt', function() {
			addRxnToVisible(expTable, 8);
		})

		expTable.on( 'order.dt', function() {
			addRxnToVisible(expTable, 8);
		})

		expTable.on( 'search.dt', function() {
			addRxnToVisible(expTable, 8);
		})		
	}	

	// This unbinding and binding of the search input for the experiments table
	// makes it so that there is a delay before the server call is made,
	// which prevents multiple calls being made to the server
	$("#ExperimentTable_filter :input")
    .unbind()
    .bind('input', function(e){
        var item = $(this);
        if(!searchWaitInterval) searchWaitInterval = setInterval(function(){
			clearInterval(searchWaitInterval);
			searchWaitInterval = '';
			searchTerm = $(item).val();
			expTable.search(searchTerm).draw();
        },800);
    });
}

<%	If hasReg then  %>
	var regTable = $("#RegItemsTable").DataTable(makeTableConf("ProjectReg"));
<%  End if  %>

$.fn.dataTable.moment();

populateTable("notebook", firstSubproject);
makeExpTable(firstSubproject);

<%	If hasReg then  %>
	populateTable("registration", firstSubproject);	
<%  End if  %>

function parseSubprojects(subprojects) {
	var returnObj = {};
	var projList = subprojects.split(";;;");
	projList.pop();
	projList.forEach(function(element) {
		returnObj[element.split(":::")[1]] = element.split(":::")[0];
	});
	return returnObj;
}

function makeSubprojectButtons(subprojectJson) {
	projectIds = Object.keys(subprojectJson);
	projectIds.forEach(function(id) {
		var disable = (id == projectIds[0]);
		var classStr = "btn-xl";
		if (disable) {
			classStr += " selected";
		}
		var btnContainer = $("<div>").attr({ id: id,
											class: "btnContainer"});

		var btn = "<input onclick='switchTab(" + id + ");' type='button' id='" + id +"_button' class='" + classStr + "' value='" + subprojectJson[id] + "'";
		if (disable) {
			btn = btn + " disabled='disabled'";
		}
		btn = btn + ">";

		btnContainer.append(btn);

		var edit = "<input type='text' id='" + id +"_text' value='" + subprojectJson[id] + "' class='editField'>"
		var saveEdit = '<button type="submit" class="btn-xl submitTabEdit" onclick="saveTabName(' + id + ')">Save</button>'
		var nameEditDiv = $("<div style='display:none'>").attr({
			class: "edit_name",
			id: id  + "_input"
		}).append(edit).append(saveEdit)

		var modDiv = $("<div>").attr({class: "editTab"})
		var editDiv = "";
		var deleteDiv = "";

		<% if session("canDelete") Then %>
			deleteDiv = $("<a>").attr({ onClick: "deleteProjectTab(" + id + ")", href: "#" }).text("Delete");
		<% End if %>

		<% if projectOwner Or session("role") = "Admin" Then %>
			editDiv = $("<a>").attr({ onClick: "editTabName(" + id + ")", href: "#" }).text("Edit");

			modDiv.append(editDiv).append("<br>").append(deleteDiv);

			btnContainer.append(modDiv).append(nameEditDiv);
		<% End if %>


		$("#Subprojects").append(btnContainer);
	});
}

function switchTab(id) {
	$(".selected").prop("disabled", false).removeClass("selected");

	btnId = "#" + id + "_button";
	$(btnId).prop("disabled", true).addClass("selected");

	populateTable("notebook", id);
	//populateTable("experiment", id);
	makeExpTable(id);
	populateTable("registration", id);	

	changePasteProj(id);
}

function changePasteProj(id) {
	document.getElementsByName("linkTargetId")[0].value = id
}

function populateTable(tableType, projId) {
	var table = notebookTable;
	var dataUrl = "get-project-notebook.asp"
	if (tableType == "registration") {
		if (typeof regTable == "undefined")
		{
			return
		}
		table = regTable;
		dataUrl = "get-reg-molecules.asp";
	}

	table.clear();
	table.draw();

	$.ajax({
        method: "POST",
        url: dataUrl,
		data: {"id": projId, "projectOwner": "<%=projectOwner%>"},
		async: true
		}).done(function(msg) {
			msg = decodeDoubleByteString(msg);
			var rows = msg.split(";;;");
			rows.pop();
			
			if(rows.length > 0) {
				for (j = 0; j < rows.length; ++j) {
					dataRow = rows[j].split(":::");
					desc = dataRow[descCol];
					childData = []
					if (desc != "") {
						childData.push(dataRow[descCol])
					}
					table.row.add(dataRow);
					if (tableType == "experiment") {
						if (dataRow[3] == "Chemistry") {
							expId = dataRow[7];
							childData.push(expId);
							//molData = getCdx(expId, j, table);
						}
					}
					table.row(j).child(childData, "childRow").show();
				}
			}
			else {
				table.context[0].oLanguage.sEmptyTable = 'There is no content to display in this section.';
			}
			
			if (tableType == "experiment") {				
				$("#ExperimentTableDiv").attr("hidden", rows.length == 0);
			}
			else if (tableType == "notebook") {
				$("#NotebookTableDiv").attr("hidden", rows.length == 0);
			}
		}).always(function() {
				table.draw();
				//$("#LoadingGif").remove();
				//$("#NotebookTableDiv").attr("hidden", false);
				if (tableType == "experiment") {
					addRxnToVisible(table, 7);
				}
		});
}

function deleteProjectNotebook(notebookId, projectId) {
	sweetAlert(
        {
            title: "Are you sure?",
            text: "Are you sure you would like to delete this notebook from this project?",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#5CB85C',
            confirmButtonText: 'Yes',
            cancelButtonText: 'No'
        },
        function(isConfirm) {
            if (isConfirm) {
                $.ajax({
                    method: "GET",
                    url: "projects/project-remove-notebook.asp",
                    data: {"projectId": projectId, "notebookId": notebookId},
                    async: true
                }).done(function() {
					populateTable("notebook", projectId);
                });
            }
        }
    )
}

function deleteProjectExperiment(expId, expType, projectId) {
	sweetAlert(
        {
            title: "Are you sure?",
            text: "Are you sure you would like to delete this experiment from this project?",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#5CB85C',
            confirmButtonText: 'Yes',
            cancelButtonText: 'No'
        },
        function(isConfirm) {
            if (isConfirm) {
                $.ajax({
                    method: "GET",
                    url: "projects/project-remove-experiment.asp",
                    data: {"projectId": projectId, "experimentId": expId, "experimentType": expType},
                    async: true
                }).done(function() {
					populateTable("experiment", projectId);
                });
            }
        }
    )
}

function deleteProjectMolecule(projectId, cd_id) {
	swal(
        {
            title: "Are you sure?",
            text: "Are you sure you would like to delete this molecule from this project?",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#5CB85C',
            confirmButtonText: 'Yes',
            cancelButtonText: 'No'
        },
        function(isConfirm) {
			removeMolecule(projectId, cd_id).then(function() {
				populateTable("registration", projectId);
			});
        }
    )
}

function removeMolecule(projectId, cd_id) {
	return new Promise(function(resolve, reject) {		
		$.ajax({
			method: "GET",
			url: "projects/project-remove-regItem.asp",
			data: {
				projectId: projectId,
				cd_id: cd_id
			}
		}).done(function() {
			resolve(true);
		});
	});
}

function deleteProject(projectId)
	{
		sweetAlert(
        {
            title: "Are you sure?",
            text: "Are you sure you want to delete this project?",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#5CB85C',
            confirmButtonText: 'Yes',
            cancelButtonText: 'No'
        },
        function(isConfirm) {
            if (isConfirm) {
                a = getFile("<%=mainAppPath%>/projects/delete-project.asp?projectId="+projectId)
				if (a==""){
					window.location = "<%=mainAppPath%>/dashboard.asp"
				}else{
					alert(a);
				}
            }
        }
    	)
	}

function deleteProjectTab(tabId)
	{
		if(confirm('Are you sure you want to delete this subproject?'))
		{
			a = getFile("<%=mainAppPath%>/projects/ajax/do/delete-project-tab.asp?tabId="+tabId)
			if (a==""){
				location.reload();
			}else{
				alert(a);
			}
		}
		else
		{
			return false;
		}
	}

function editTabName(id)
{
	document.getElementById(id+"_input").onkeypress = function(evt){try{if (evt.keyCode == 13){saveTabName(id);return false;}}catch(err){if (event.keyCode == 13){saveTabName(id);return false;}}}
	document.getElementById(id+"_input").style.display = "flex";
	document.getElementById(id+"_button").style.display = "none";
	document.getElementById(id).className = document.getElementById(id).className + " editingTab ";
}

/**
 * Update the sub project name.
 * @param {Number} Sub project ID.
 */
function saveTabName(id)
{
	nn = document.getElementById(id+"_text").value
	if (nn.length > 60)
	{
		nn = nn.substring(0,60)
	}
	document.getElementById(id+"_input").style.display = "none";
	document.getElementById(id+"_button").value = nn;
	document.getElementById(id+"_button").style.display = "block";
	document.getElementById(id).className = document.getElementById(id).className.replace("editingTab","");
	// Encode it for the double bite char and then url encode it because we the build a url out of it. 
	nn = encodeURIComponent(encodeIt(nn))
	getFile("/arxlab/projects/change-project-tab-name.asp?tabId="+id+"&name="+nn+"&r="+Math.random())
}

function pasteLink(formId)
{
	document.getElementById(formId).submit();
	waitForPasteLink();
}

function waitForPasteLink()
{
	<%if inframe then%>
	frameName = "submitFrameFrame"
	<%else%>
	frameName = "submitFrame"
	<%end if%>
	try
	{
		result = window.frames[frameName].document.getElementById("resultsDiv").innerHTML
		if (result == "success"){
			window.frames[frameName].document.getElementById("resultsDiv").innerHTML = "";
			window.location = window.location
		}else{
			if(result == ""){
				setTimeout('waitForPasteLink()',150)
			}
			else{
				alert(result);
			}
		}
	}
	catch(err)
	{
		setTimeout('waitForPasteLink()',150)
	}
}

function changeOwner()
{
	if (confirm("Are you sure you wish to change the owner of this project?"))
	{
		newUserId = document.getElementById("changeProjectUserId")
		newUserId = newUserId.options[newUserId.selectedIndex].value
		projectId = document.getElementById("projectIdForChange").value
		ret = getFile("<%=mainAppPath%>/projects/changeProjectOwner.asp?projectId="+projectId+"&newUserId="+newUserId+"&rand="+Math.random())
		document.getElementById("projectOwnerSpanInner").innerHTML = ret;
		document.getElementById('projectOwnerSpan').style.display='inline-block';
		document.getElementById('changeOwnerDiv').style.display = 'none'
		<%if projectUserId <> "" then%>
		if (newUserId == <%=session("userId")%> ||  <%=projectUserId%> == <%=session("userId")%>)
		{
			document.location.href = document.location.href;
		}
		<%end if%>
	}
}

</script>
<!-- #include file="workflow/_inclds/Workflow_Includes.asp"-->
<!-- #include file="_inclds/footer-tool.asp"-->
</html>
<%

function getProjectCompanyId(projectId)
	'get the company id for the specified notebook
	Set geRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT companyId FROM projectView WHERE id="&SQLClean(projectId,"N","S")
	geRec.open strQuery,conn,3,3
	If Not geRec.eof Then
		'return the company Id
		getProjectCompanyId = CStr(geRec("companyId"))
	End If
	geRec.close
	Set geRec = nothing
end function

'Lets do this last
addToRecentlyViewedProjects(projectId)
%>