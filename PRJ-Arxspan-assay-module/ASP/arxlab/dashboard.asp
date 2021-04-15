<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
regEnabled = true%>
<%
sectionId = "dashboard"
%>
<!-- #include file="_inclds/globals.asp"-->
<%
	redirectToInventory = checkBoolSettingForCompany("redirectDashboardToInventory", session("companyId"))
	If redirectToInventory Then
		response.redirect(mainAppPath&"/inventory2/index.asp")
	End if
%>
<%
session("fromWitnessRequestList") = False
%>

<%
	sectionID = "tool"
	subSectionID="dashboard"
	terSectionID=""

	pageTitle = "Dashboard"
	metaD=""
	metaKey=""
%>
<%If request.querystring("searchButton") <> "" Then
	notebookId = request.querystring("notebookId")
	collection = request.querystring("collection")
	statusId = request.querystring("statusId")
	sortBy = request.querystring("sortBy")
	sortDir = request.querystring("sortDir")

	If Not isinteger(notebookId) Then
		notebookId = 0
	Else
		notebookId = CInt(notebookId)
	End If
	If Not isinteger(statusId) Then
		statusId = 0
	Else
		statusId = CInt(statusId)
	End If

	If sortBy = "" Then
		sortBy = "dateUpdated"
		sortDir = "DESC"
	End If
	If sortDir = "" Then
		sortDir = "ASC"
	End if
	
	strQuery = "SELECT [notebookName], [firstName], [lastName], [status], [id], [name], [preparation], [statusId], [cdx], [notebookId], [pressure], [temperature], [userId], [dateSubmitted], [dateUpdated], [molData], [reactionMolarity], [revisionNumber], [visible], [beenExported], [companyId], [sigdigs], left([details],1000) as details, [email], [dateSubmittedServer], [currLetter], [craisStatus], [softSigned], [dateUpdatedServer], [resultSD], [userExperimentName], [mrvData] FROM experimentView"
	
	If session("role") <> "admin" Then
		strQuery = strQuery & " AND userId="&SQLClean(session("userId"),"N","S")
	End If
	If notebookId <> 0 Then
		strQuery = strQuery & " AND notebookId="&SQLClean(notebookId,"N","S")
	End if
	If statusId <> 0 Then
		strQuery = strQuery & " AND statusId="&SQLClean(statusId,"N","S")
	End If
	If collection <> "" Then
		strQuery = strQuery & " AND collection LIKE '%"&Replace(SQLClean(collection,"T","S"),"'","")&"%'"
	End If
	
	strQuery = strQuery &  " ORDER BY " & Replace(SQLClean(sortBy,"T","S"),"'","") & " " & Replace(SQLClean(sortDir,"T","S"),"'","")

	Call getconnected
	Set expRec = server.CreateObject("ADODB.RecordSet")
	expRec.open strQuery,conn,3,3
End if
%>
<%
If request.Form("noteText") <> "" Then
	addIt = false
	tmp = Split(request.Form("experimentId"),"_")
	If UBound(tmp) = 1 Then
		experimentType = tmp(0)
		experimentId = tmp(1)
		addIt = true
	End if

	If addIt then
		If ownsExperiment(experimentType,experimentId,session("userId")) Then
			Call getconnectedadm
			a = addNoteToExperiment(experimentType,experimentId,"Quick Note",request.Form("noteText"),false)
			session("addIt") = True
			response.redirect("dashboard.asp?sent=true")
		End if
	End if
End if
%>
<%st = timer%>
<!-- #include file="_inclds/header-tool.asp"-->
		<%If session("email") = "support@arxspan.com" Or session("companyId") = "1" then 
			'response.write(timer-st)
		End if%>
<%st = timer%>
<!-- #include file="_inclds/nav_tool.asp"-->
		<%If session("email") = "support@arxspan.com" Or session("companyId") = "1" then 
			'response.write(timer-st)
		End if%>

<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->

<%If request.querystring("sent") = "true" And session("addIt") then%>
	<script type="text/javascript">
		window.setTimeout("document.getElementById('noteSaved').style.display='block';",1500)
	</script>
	<%session("addIt") = False%>
<%End if%>

<script type="text/javascript">
	var clearNotificationTO;
	function clearNotification(notificationId)
	{
		document.getElementById("notification_body_"+notificationId).classList.add("dismissed");
		ajaxNoReturn('<%=mainAppPath%>/misc/ajax/do/clearNotification.asp?id='+notificationId);
	}
	function clearAllNotifications(){
		$(".notificationBody").each(function(){
			$(this)[0].remove();
		})
		$('#noNotificationsMessage').show();
		$('.notificationDateDividerText + br, .notificationDateDividerText').hide();
		ajaxNoReturn('<%=mainAppPath%>/ajax_doers/clearAllNotifications.asp');
	}
</script>

<script type="text/javascript">
	var newNotSack = new sack();
	var getNewNotSack = new sack();
	var newNotNode;

function insertAfter(parent, node, referenceNode) {
  parent.insertBefore(node, referenceNode.nextSibling);
}

var lastNotificationIdInitialCheck = "<%=getLastNotificationId()%>";
function checkNewNotifications()
{
	if($("#lastNotificationId").length < 1){
		lastNotificationId = lastNotificationIdInitialCheck;
	}
	else{
		lastNotificationId = document.getElementById("lastNotificationId").value;
	}
	console.log(lastNotificationId);
	newNotSack.requestFile = "<%=mainAppPath%>/misc/ajax/check/checkNewNotifications.asp?id="+lastNotificationId+"&random="+Math.random();
	newNotSack.onCompletion = checkNewNotificationsComplete;
	newNotSack.runAJAX();
}

function checkNewNotificationsComplete()
{
	if (newNotSack.response != '')
	{
		if($("#lastNotificationId").length < 1){
			lastNotificationId = lastNotificationIdInitialCheck;
		}
		else{
			lastNotificationId = document.getElementById("lastNotificationId").value;
		}

		$('#noNotificationsMessage').hide();
		$('.notificationDateDividerText + br, .notificationDateDividerText').show();
		document.getElementById("notificationLoadingDiv").style.display = "block";
		newLast = newNotSack.response
		newNotSack.requestFile = "<%=mainAppPath%>/misc/ajax/load/getNewNotification.asp?id="+lastNotificationId+"&random="+Math.random();
		newNotSack.onCompletion = getNewNotificationComplete;
		newNotSack.runAJAX();
		document.getElementById("lastNotificationId").value = newLast
	}
}

function getNewNotificationComplete()
{
	newDIV = document.createElement("div")
	newDIV.innerHTML = newNotSack.response
	newNotNode = newDIV
	window.setTimeout('showNewSack()',1000)
}

function showNewSack()
{
	try{
	insertAfter(document.getElementById("notificationLoadingDiv").parentNode,newNotNode,document.getElementById("notificationLoadingDiv"))
	document.getElementById("notificationLoadingDiv").style.display = "none";
	}catch(err){}
}

checkNewNotificationsInterval2 = window.setInterval('checkNewNotifications()',60000)

</script>

<script type="text/javascript">
var wlSack = new sack();

function deleteWatchlistItem(id)
{
	if (confirm("Are you sure you would like to delete this item from your watchlist?"))
	{
		wlSack.requestFile = "<%=mainAppPath%>/misc/ajax/do/deleteWatchlistItem.asp?id="+id+"&random="+Math.random();
		wlSack.onCompletion = redrawWatchlist;
		wlSack.runAJAX();
	}
}

function redrawWatchlist()
{
	window.location.href = window.location.href;
}

function redrawWatchlistComplete()
{
	document.getElementById("watchlistHolder").innerHTML = wlSack.response
}

</script>

<table width="100%">
<%If session("hasELN") then%>
<tr>
	<td colspan="2" id="recentlyViewedExperimentsHolder">
		<script type="text/javascript" src="<%=mainAppPath%>/search/elasticSearch/imgCrop.js"></script>
		<script src="_inclds/experiments/chem/js/getRxn.js?<%=jsRev%>"></script>
		<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/misc/show-notifications.asp" style="text-decoration:none;"><h2><%=recentlyViewedExperimentsLabel%></h2></a></div>
		<img src="images/loading.gif" style="display:block;margin:auto;margin-top:5px;margin-bottom:5px;" border="0"/>
		<script type="text/javascript">
			addLoadEvent(function(){getFileA('ajax_loaders/recentlyViewedExperiments.asp?recLimit=3&random='+Math.random(),function(r){document.getElementById('recentlyViewedExperimentsHolder').innerHTML = r;delayedRunJS(r)})});
		</script>
	</td>
</tr>
	<%If whichClient = "CRISPR" Then%>
	<tr>
		<td colspan="2">
			<div id="witnessRequestHolder">
			<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/misc/show-witnessRequests.asp" style="text-decoration:none;"><h2><%=witnessRequestsLabel%></h2></a></div>
			<img src="images/loading.gif" style="display:block;margin:auto;margin-top:5px;margin-bottom:5px;" border="0"/>
			<script type="text/javascript">
				addLoadEvent(function(){getFileA('ajax_loaders/witnessRequests.asp?recLimit=5&random='+Math.random(),function(r){document.getElementById('witnessRequestHolder').innerHTML = r;delayedRunJS(r)})});
			</script>
			</div>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<div id="watchlistHolder">
			<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/misc/show-notifications.asp" style="text-decoration:none;"><h2><%=watchListLabel%></h2></a></div>
			<img src="images/loading.gif" style="display:block;margin:auto;margin-top:5px;margin-bottom:5px;" border="0"/>
			<script type="text/javascript">
				addLoadEvent(function(){getFileA('ajax_loaders/watchlist.asp?recLimit=3&random='+Math.random(),function(r){document.getElementById('watchlistHolder').innerHTML = r;delayedRunJS(r)})});
			</script>
			</div>
		</td>
	</tr>
	<%Else%>
	<tr>
		<td colspan="2">
			<div id="watchlistHolder">
			<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/misc/show-notifications.asp" style="text-decoration:none;"><h2><%=watchListLabel%></h2></a></div>
			<img src="images/loading.gif" style="display:block;margin:auto;margin-top:5px;margin-bottom:5px;" border="0"/>
			<script type="text/javascript">
				addLoadEvent(function(){getFileA('ajax_loaders/watchlist.asp?recLimit=3&random='+Math.random(),function(r){document.getElementById('watchlistHolder').innerHTML = r;delayedRunJS(r)})});
			</script>
			</div>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<div id="witnessRequestHolder">
			<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/misc/show-witnessRequests.asp" style="text-decoration:none;"><h2><%=witnessRequestsLabel%></h2></a></div>
			<img src="images/loading.gif" style="display:block;margin:auto;margin-top:5px;margin-bottom:5px;" border="0"/>
			<script type="text/javascript">
				addLoadEvent(function(){getFileA('ajax_loaders/witnessRequests.asp?recLimit=5&random='+Math.random(),function(r){document.getElementById('witnessRequestHolder').innerHTML = r;delayedRunJS(r)})});
			</script>
			</div>
		</td>
	</tr>
	<%End if%>
<%End if%>
<tr>
	<td width="100%" valign="top" colspan="2" id="notificationsHolder">
		<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/misc/show-notifications.asp" style="text-decoration:none;"><h2><%=notificationsLabel%></h2></a></div>
		<img src="images/loading.gif" style="display:block;margin:auto;margin-top:5px;margin-bottom:5px;" border="0"/>
		<script type="text/javascript">
			addLoadEvent(function(){getFileA('ajax_loaders/notifications.asp?recLimit=20&random='+Math.random(),function(r){document.getElementById('notificationsHolder').innerHTML = r;delayedRunJS(r)})});
		</script>
		</div>
	</td>
</tr></table>
<!-- #include file="_inclds/footer-tool.asp"-->