<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
sectionId = "experiment"
signedSection = true
%>
<!-- #include file="_inclds/globals.asp"-->
<%

'get experiment Id it is used everywhere
experimentId = request.querystring("id")
experimentType = request.querystring("experimentType")
revisionNumber = request.querystring("revisionNumber")
fromSign = request.querystring("fromSign")
safeVersion = request.querystring("safeVersion")

rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
' Check if the current user is a coauthor on the experiment if this is a cust exp.
isCoAuthor = checkCoAuthors(experimentId, experimentType, "pdfExperimentSignButtons")

prefix = GetPrefix(experimentType)
expTable = GetFullName(prefix, "experiments_history", true)
strQuery = "SELECT TOP 1 revisionNumber,userId{custExp} from " & expTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " ORDER BY revisionNumber DESC"

custExpStr = ""

if experimentType = 5 then
	custExpStr = ", requestId, requestRevisionNumber"
end if

strQuery = Replace(strQuery, "{custExp}", custExpStr)

Call getconnected
Set rRec = server.CreateObject("ADODB.RecordSet")

rRec.open strQuery,conn,3,3
If Not rRec.eof Then
	currentRevision = CStr(rRec("revisionNumber"))
	expUserId = CStr(rRec("userId"))
	
	if experimentType = 5 then
		requestId = CStr(rRec("requestId"))
		requestRevisionId = CStr(rRec("requestRevisionNumber"))	
	end if
	
End if

%>
<% 'Putting the deleteExperiment includes here so that experimentType and experimentId
   'are already defined %>
<!-- #include file="_inclds/experiments/common/html/deleteExperimentForm.asp"-->
<!-- #include virtual="/arxlab/_inclds/experiments/common/js/abandonExperimentFncs.asp"-->
<script src="js/deleteExperiment.js"></script>

<%If canViewExperiment(experimentType,experimentId,session("userId")) then%>

<%
	sectionID = "tool"

	prefix = GetPrefix(request.querystring("experimentType"))
	subSectionID = GetSubsectionId(prefix)
	expHistView = GetFullName(prefix, "experimentHistoryView", true)
	expTable = GetFullName(prefix, "experiments", true)

	strQuery = "SELECT notebookId, statusId, firstName, lastName, notebookName, userId, revisionNumber, name FROM " & expHistView & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
	strQuery2 = "SELECT id FROM " & expTable & " WHERE id="&SQLClean(experimentId,"N","S")& " AND softSigned=1 and statusId=5"

	terSectionID=""

	pageTitle = "Arxspan Experiment"
	metaD=""
	metaKey=""

	Call getconnected
	Set expRec = server.CreateObject("ADODB.Recordset")
	expRec.open strQuery,conn,3,3
	
	If Not expRec.eof then
		notebookId = CStr(expRec("notebookId"))
		canRead = canReadNotebook(notebookId,session("userId"))
		statusId = expRec("statusId")
		experimentOwner = expRec("firstName")&" "&expRec("lastName")
		notebookName = expRec("notebookName")
		experimentName = expRec("name")
	End If
	Set expRec2 = server.CreateObject("ADODB.RecordSet")
	expRec2.open strQuery2,conn,3,3
	If Not expRec2.eof Then
		softSigned = True
	Else
		softSigned = false
	End If
	expRec2.close
	Set expRec2 = Nothing
	Set expRec3 = server.CreateObject("ADODB.RecordSet")
	strQuery3 = "SELECT unsavedChanges FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	expRec3.open strQuery3,conn,3,3
	If expRec3.eof Then
		hasUnsavedChanges = False	
	else
		If expRec3("unsavedChanges") = 1 Then
			hasUnsavedChanges = True
		Else
			hasUnsavedChanges = False
		End If
	End if
	expRec3.close
	Set expRec3 = nothing
%>

<!-- #include file="_inclds/header-tool.asp"-->
<!-- #include file="_inclds/nav_tool.asp"-->
<!-- #include file="_inclds/common/html/infoBox.asp"-->
<!-- #include file="_inclds/common/html/popupDivs.asp"-->
<!-- #include file="_inclds/experiments/common/js/signedJS.asp"-->

<div id="topRightFunctionsAsp"></div>
<script type="text/javascript">
$(document).ready(function() {
    $.ajax({
        url: "<%=mainAppPath%>/_inclds/experiments/common/html/experimentTopRightFunctions.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&comments=<%=request.querystring("comments")%>&pdfView=1",
        type: "GET",
        async: true,
        cache: false
    })
    .success(function (html) {
        $("#topRightFunctionsAsp").html(html);
    })
    .fail(function () {
        console.error("Unable to load experimentTopRightFunctions. Please contact support@arxspan.com.");
    });
});
</script>

<!-- #include file="experiments/fileUploadForm.asp"-->
<%If session("companyId")="1" And whichServer="DEV" then%>
<%
	vzServer = "https://api-universalid-int.verizon.com/oauth20/authorize"
	clientId = "OjpaTO1lBwS1SXmeQeuUq4Z8L8wKERnS"
%>
<%else%>
<%
vzServer = "https://api.universalid.icsl.net/oauth20/authorize"
Select Case whichServer
	Case "PROD"
		clientId = "OrIsgf7p8sSRaVbxqVrnWkIV3PaqrjUO"
	Case "MODEL"
		clientId = "B1OzrLpI31ANfDv9MiM6SojG658OoOCG"
	Case "BETA"
		clientId = "B1OzrLpI31ANfDv9MiM6SojG658OoOCG"
	Case "DEV"
		clientId = "B1OzrLpI31ANfDv9MiM6SojG658OoOCG"
End select
%>
<%End if%>


<% If experimentType = 5 Then %>
	<input type="hidden" id="requestId" value="<%=requestId%>">
	<input type="hidden" id="requestRevisionId" value="<%=requestRevisionId%>">
<% End if %>

<%If session("useGoogleSign") then%>
	<form method="GET" id="softTokenForm" action="https://accounts.google.com/o/oauth2/auth" class="loginForm" style="margin:0;">
		<input type="hidden" name="response_type" value="code">
		<input type="hidden" name="scope" value="openid email">
		<input type="hidden" name="client_id" value="819343142027-dgdnuapm9s9kn378siln34f3fecmmrca.apps.googleusercontent.com">
		<input type="hidden" name="redirect_uri" value="https://<%=rootAppServerHostName%>/arxlab/googleSign/authorize.asp">
		<%
			state = getRandomString(32)
			session("state") = state
		%>
		<input type="hidden" id="softTokenState" name="state" value="<%=state%>">
		<input type="hidden" name="login_hint" value="<%=session("email")%>">
		<input type="hidden" name="notebookId" id="notebookId" value="<%=notebookId%>">
	</div>

</form>
<%End if%>
<script type="text/javascript" src="js/common/experiments/commonFunctions.js"></script>
<script type="text/javascript">
function softSign(){
	<%if session("useGoogleSign") then%>
		document.getElementById("submitFrame").src = "https://www.google.com/accounts/Logout";
	<%end if%>
	showPopup('softSignDiv');
}
<%

'Figure out if this can be coAuthorSigned
isCoAuthorSign = False
if statusId = 5 then
	Set signerRec = server.CreateObject("ADODB.RecordSet")
	signerQuery = "SELECT * FROM experimentSignatures WHERE signed=0 AND userId = " & SQLClean(session("userId"),"N","S") & " AND experimentId=" & SQLClean(experimentId,"N","S") & " AND experimentType = " & SQLClean(experimentType,"N","S")
	signerRec.open signerQuery, conn, 3, 3
	If not signerRec.eof then
		isCoAuthorSign = True
	end if
	signerRec.close
	set SignerRec = nothing
end if

' This is the "state" that is used as a tracking token for SAFE so we can track one request

maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
prefix = GetPrefix(experimentType)
folderName = GetAbbreviation(experimentType)
experimentTableName = GetFullName(prefix, "experiments", true)
experimentHistoryTableName = GetFullName(prefix, "experimentHistoryView", true)
set rec2 = server.CreateObject("ADODB.RecordSet")

strQuery = "SELECT userId FROM "&experimentHistoryTableName&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND "
if experimentType <> 5 then
	strQuery = strQuery & "experimentType="&SQLClean(experimentType,"N","S") & " AND "
else
	'for Custom experiments, the experimentType is NULL in custexperimentHistoryView. Leaving this as a "OR" in case it ever gets fixed
	strQuery = strQuery & "(experimentType="&SQLClean(experimentType,"N","S") & " OR experimentType IS NULL) AND "
end if
strQuery = strQuery & "revisionNumber="&SQLClean(maxRevisionNumber,"N","S")

rec2.open strQuery,conn,3,3
experimentUserId = rec2("userId")
rec2.close
Set rec2 = Nothing

canSafeSign = true
safeErrorReason = ""
isWitness = -1
safeState = getRandomString(10) 'This is just a random default so its not blank

Call getconnectedAdm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM witnessRequests WHERE accepted=0 and denied=0 and requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S")
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	canWitnessThis = True
	isWitness = 1
Else
	canWitnessThis = False
End If
If ownsExperiment(experimentType,experimentId,session("userId")) Then
	maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
	If CInt(maxRevisionNumber) <> CInt(revisionNumber) Then
		safeErrorReason = "ERROR: There is a newer version of this experiment."
		canSafeSign = false
	End If
	
	set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM "&experimentHistoryTableName&" WHERE "&_
		"experimentId="&SQLClean(experimentId,"N","S") & " AND " &_
		"experimentType="&SQLClean(experimentType,"N","S") & " AND " &_
		"revisionNumber="&SQLClean(maxRevisionNumber,"N","S") & " AND (statusId=5 or statusId=6)"
	rec2.open strQuery,conn,3,3
	If Not rec2.eof Then
		safeErrorReason = "ERROR: Experiment already signed."
		canSafeSign = false
	End If
	rec2.close
	Set rec2 = Nothing
	
	if canSafeSign = true then
		isWitness = 0
	end if
end if

if canSafeSign = true OR canWitnessThis = true then	
	if isCoAuthorSign then
		safeState = getRandomString(4)&"_"&request.querystring("experimentType")&"_"&request.querystring("id")&"_"&revisionNumber&"_"&session("userId")&"_" & isWitness & "_2_0_"&getRandomString(4)
	else
		safeState = getRandomString(4)&"_"&request.querystring("experimentType")&"_"&request.querystring("id")&"_"&revisionNumber&"_"&session("userId")&"_" & isWitness & "_0_0_"&getRandomString(4)
	end if
	safeStateKeepOpen = getRandomString(4)&"_"&request.querystring("experimentType")&"_"&request.querystring("id")&"_"&revisionNumber&"_"&session("userId")&"_" & isWitness & "_1_0_"&getRandomString(4) ' This is ugly, but the user picks "keep open" after this page is already loaded, so I need to make both options so I can pick whatever one we need later from the session.
	' without these, even if someone was to enter the URL manually, the safe code will break
	' Safe this into the session so that the SAFE SIGN code can find the PDF.
	session.Save()
	session("SAFEPDFPath_" & safeState) = uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber&"\"&folderName&"\sign.pdf"
	session("SAFEPDFOutPath_" & safeState) = uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber + 1&"\"&folderName&"\sign.pdf"
	session("SAFEPDFPath_" & safeStateKeepOpen) = uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber&"\"&folderName&"\sign.pdf"
	session("SAFEPDFOutPath_" & safeStateKeepOpen) = uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber + 1&"\"&folderName&"\sign.pdf"
	session.Save()
end if
%>
function softSign2(isCoAuthor){
	<% if canSafeSign = true then %>
		softVerify = "softVerify";
		softSignStatusBox = "softSignStatusBox";
		softSignDiv = "softSignDiv";
		if (isCoAuthor){
			softVerify = "softCoAuthorVerify";
			softSignStatusBox = "softSignCoAuthorStatusBox";
			softSignDiv = "softCoAuthorSignDiv";
		}

		err = false;
		if (!document.getElementById(softVerify).checked){
			swal("Please click reviewed to continue.");
			err = true;
		}
		el = document.getElementById(softSignStatusBox);
		keepOpen = el.options[el.selectedIndex].value;

		if (isCoAuthor){
			requesteeId = "0";
		}else{
			el = document.getElementById("requesteeIdBox")
			requesteeId = el.options[el.selectedIndex].value;
			if (requesteeId == "-1"){
				requesteeId = "0";
			}
		}

		if(!err){
			killIntervals();
			hidePopup(softSignDiv);

			//' Send Witness request
			var fd = {
			'experimentType': '<%=experimentType%>',
			'experimentId': '<%=experimentId%>',
			'requesteeId': $('select#requesteeIdBox').val(),
			'state': '<%=safeState%>'
			}

			$.ajax({
				url: "/arxlab/SAFE/requestWitness.asp",
				data: fd,
				type: 'POST'
			})
			.done(function() {
				console.log("Stored Witness Request");
			})
			.fail(function() {
				console.error("Witness Request Failed");
			})
			.always(function(){
				if(keepOpen == "1"){
					window.location = 'https://<%=rootAppServerHostName%>/safeoauth/safe/?state=<%=safeStateKeepOpen%>';
				}else{
					window.location = 'https://<%=rootAppServerHostName%>/safeoauth/safe/?state=<%=safeState%>';
				}
			});
		}
	<% else %>
		swal("<%=safeErrorReason%>");
	<% end if %>
}

function softWitness(skip){
	<%if session("useGoogleSign") then%>
		if(!skip){
			document.getElementById("submitFrame").src = "https://www.google.com/accounts/Logout";
			document.getElementById("submitFrame").onload = function(){softWitness(true);}
			return false;
		}
	<%end if%>
	<%if softSigned and not session("softToken") then%>
		alert("You must have a soft token to witness this experiment.");
	<%else%>
	killIntervals();
	<%If not session("useGoogleSign") then%>
		window.location = 'https://<%=rootAppServerHostName%>/safeoauth/safe/?state=<%=safeState%>';
	<%end if%>
	<%end if%>
}
</script>
<iframe id="pdfFrame" width="100%" height="800" src="<%=mainAppPath%>/experiments/waitSign.asp?id=<%=request.querystring("id")%>&experimentType=<%=request.querystring("experimentType")%>&revisionNumber=<%=revisionNumber%>&safeVersion=<%=safeVersion%>&fromSign=<%=fromSign%>&credError=<%=request.querystring("credError")%>&short=<%=request.querystring("short")%>" standby="Loading PDF..." style="background-color:white;margin-top:10px;"></iframe>
<%
experimentId = request.querystring("id")
experimentType = request.querystring("experimentType")
revisionNumber = request.querystring("revisionNumber")

Call getconnectedadm
If int(revisionNumber)=int(getExperimentRevisionNumber(experimentType,experimentId)) And (ownsExperiment(experimentType,experimentId,session("userId")) or isCoAuthor) then
	strQuery = "INSERT into hungExperiments(theDate,userId,experimentId,experimentType,revisionNumber,serial,firstTimeout,secondTimeout,ipAddress,uaString,theForm) output inserted.id as newId values(GETDATE()," &_
					SQLClean(session("userId"),"N","S") & "," &_
					SQLClean(experimentId,"N","S") & "," &_
					SQLClean(experimentType,"N","S") & "," &_
					SQLClean(request.querystring("revisionId"),"N","S") & "," &_
					SQLClean(hungSaveSerial,"T","S") & "," &_
					SQLClean(0,"N","S") & "," &_
					SQLClean(0,"N","S") & "," &_
					SQLClean(request.servervariables("REMOTE_ADDR"),"T","S") & "," &_
					SQLClean(request.servervariables("HTTP_USER_AGENT"),"T","S") & "," &_
					SQLClean("","T","S") & ")"
	Set rs = connAdm.execute(strQuery)
	hungSaveSerial = CStr(rs("newId"))
	connAdm.execute("UPDATE hungExperiments SET serial="&SQLClean(hungSaveSerial,"T","S")&" WHERE id="&SQLClean(hungSaveSerial,"N","S"))
End If

%>

<script type="text/javascript">
experimentJSON = {};
function experimentSubmit(approve,sign,autoSave,refreshPageAfterSave, requestId, workflowRevisionId)
{
	killIntervals();
	experimentId = <%=experimentId%>;
	experimentJSON["experimentId"] = experimentId;
    experimentJSON["notebookId"] = "<%=notebookId%>";	// Need double-quotes around the variable since it would crash when it is an empty string.
	experimentJSON["hungSaveSerial"] = "<%=hungSaveSerial%>";
	hidePopup('signDiv')
	showPopup('savingDiv')
	
	if (sign)
	{
		experimentJSON["signEmail"] = document.getElementById("signEmail").value;
		experimentJSON["password"] = document.getElementById("password").value;
		experimentJSON["typeId"] = document.getElementById("typeId").value;
		experimentJSON["sign"] = document.getElementById("sign").value;
		experimentJSON["signStatus"] = document.getElementById("signStatusBox").options[document.getElementById("signStatusBox").selectedIndex].value;
		experimentJSON["requesteeId"] = document.getElementById("requesteeIdBox").options[document.getElementById("requesteeIdBox").selectedIndex].value;
		experimentJSON["verifyState"] = document.getElementById("verify").checked;
		experimentJSON["e_name"] = "<%=experimentName%>";

		if (requestId) {
			experimentJSON["requestId"] = requestId;
		}

		if (workflowRevisionId) {
			experimentJSON["workflowRevisionId"] = workflowRevisionId;
		}

		var requestTypeId = $("#requestTypeId").val();
		if (requestTypeId) {
			experimentJSON["requestTypeId"] = requestTypeId;
		}
		
		if(document.getElementById('isSsoUser').value === 'true' && document.getElementById('ssoSignValue').value === 'true' && document.getElementById('isSsoCompany').value === 'true') {
			experimentJSON["password"] = "";
			experimentJSON["signEmail"] = "";
			experimentJSON["typeId"] = document.getElementById("ssoTypeId").value;
			experimentJSON["sign"] = document.getElementById("ssoSignValue").value;
			experimentJSON["signStatus"] = document.getElementById("ssoSignStatusBox").options[document.getElementById("ssoSignStatusBox").selectedIndex].value;
			experimentJSON["requesteeId"]  = document.getElementById("requesteeIdBox").options[document.getElementById("requesteeIdBox").selectedIndex].value;
			experimentJSON["verifyState"] = document.getElementById("ssoVerify").checked;
		}
	}
	/*
	theForm = document.createElement("form");
	theForm.id = "formDiv";
	theForm.method = "POST"
	theForm.action = "<%=mainAppPath%>/experiments/pdfSign.asp?hss=<%=hungSaveSerial%>";
	hiddenExperimentJSON = document.createElement("input");
	hiddenExperimentJSON.setAttribute("type","hidden")
	hiddenExperimentJSON.setAttribute("id","hiddenExperimentJSON")
	hiddenExperimentJSON.setAttribute("name","hiddenExperimentJSON")
	hiddenExperimentJSON.setAttribute("value",JSON.stringify(experimentJSON))
	theForm.appendChild(hiddenExperimentJSON)
	window.frames["submitFrame"].document.getElementById("formDiv").appendChild(theForm)
	*/
	experimentJSON["hungSaveSerial"] = '<%=hungSaveSerial%>';
	$.ajax({
		url: "<%=mainAppPath%>/experiments/pdfSign.asp?hss=<%=hungSaveSerial%>",
		data: {
			"hiddenExperimentJSON": JSON.stringify(experimentJSON)
		},
		type: "POST"
	}).done(function(response) {

		console.log(response);
		hidePopup("savingDiv");
		var respText = $(response).text();
		
		if (respText != "success") {
			swal("Warning", respText);
		} else {
			if (sign){
				window.location = "dashboard.asp?id=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=revisionNumber+1%>";
			} else{
				window.location = '<%=expPage%>?id=' + experimentId;
			}
		}
	})
}

function reloadSubmitFrame()
{
	f = document.getElementById("submitFrame")
	f.src = f.src
}

numberOfSaveTries = 0;
restartSaveFlag = false;
failCount = 0;
function waitForSave(sign)
{
	//Thanks IE
	sign = sign || false;

	numberOfSaveTries += 1;
	if (numberOfSaveTries == 25 || numberOfSaveTries == 75){
		document.getElementById("hungSaveForm").submit();
	}
	if(numberOfSaveTries % 10 == 0){
		$.get( "<%=mainAppPath%>/experiments/ajax/check/serialAck.asp", { serial: "<%=hungSaveSerial%>"} )
			.done(function( data ) {
				if(data==""){
					restartSaveFlag = true;
					failCount += 1;
				}else{
					hideOverMessage("networkProblem");
				}
			})
			.fail(function() {
				restartSaveFlag = true;
				failCount += 1;
			});
	}
	try
	{
		results = window.frames["submitFrame"].document.getElementById("resultsDiv").innerHTML
		if (results == "success") 
		{
			//experimentId = window.frames["submitFrame"].document.getElementById("frameExperimentId").innerHTML
			<%
			prefix = GetPrefix(experimentType)
			expPage = GetExperimentPage(prefix)
			%>
			if (sign){
				window.location = "dashboard.asp?id=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=revisionNumber+1%>";
			}else{
				window.location = '<%=expPage%>?id=' + experimentId;
			}
			
		}
		else
		{
			swal(results)
			document.getElementById("signEmail").value=""
			document.getElementById("password").value=""
			hidePopup('savingDiv');
		}
		reloadSubmitFrame()		
	}
	catch(err)
	{
		if(!restartSaveFlag){
			setTimeout('waitForSave('+sign+')',400);
		}else{
			restartSaveFlag = false;
			showOverMessage("networkProblem");
			if(failCount % 2 == 0 && failCount != 0){
				showOverMessage("networkProblem2");
				window.setTimeout(function(){hideOverMessage("networkProblem2");},2000)
			}
			try{
				reloadSubmitFrame();
				experimentSubmit(false,false,false);
			}catch(err){
				setTimeout('waitForSave('+sign+')',400)
			}
		}
	}
	return false;
}


</script>
<%If Not expRec.eof then%>
	<%If CStr(expRec("userId")) = CStr(session("userId")) then%>

<%If session("roleNumber") <= 30 And expRec("statusId") = 5 And CStr(expRec("revisionNumber")) = CStr(currentRevision) then%>
<h1 style="margin-top:10px;"><%=sendWitnessRequestLabel%></h1>
<form method="post" action="<%=mainAppPath%>/experiments/ajax/do/requestWitness.asp" id="submitNewWitnessRequestForm" target="submitFrame" class="chunkyForm" style="margin-top:5px;">
<label for="requesteeId">user</label>
<select name="requesteeId">
<option value="-1">--SELECT--</option>
<%
usersTable = getDefaultSingleAppConfigSetting("usersTable")
Set uRec = Server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id <>" & SQLClean(session("userId"),"N","S")& " AND id in("&getUsersICanSee()&") and enabled=1"
''412015
If session("useSafe") Then
	strQuery = strQuery &" AND softToken=1"
End if
''/412015
strQuery = strQuery & " ORDER by firstName"

uRec.open strQuery,conn,3,3
Do While Not uRec.eof
	%>
	<%If canViewExperiment(experimentType,experimentId,uRec("id")) then%>
		<option value="<%=uRec("id")%>"><%=uRec("firstName")%>&nbsp;<%=uRec("lastName")%></option>
	<%End if%>
	<%
	uRec.movenext
loop
%>
</select>
<input type="hidden" name="experimentId" value="<%=experimentId%>">
<input type="hidden" name="experimentType" value="<%=experimentType%>">
<input type="hidden" name="revisionNumber" value="<%=revisionNumber%>">
<a href="javascript:void(0);" style="margin-top:13px;" onclick="requestNewWitness();" class="createLink">Send Request</a>
</form>

<%End if%>
		
	<%End if%>
<%End if%>

<input type="hidden" id="safeExperimentId" value="<%=experimentId%>">
<input type="hidden" id="safeExperimentType" value="<%=experimentType%>">

<%
maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
Call getconnected
Set witnessRec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT * FROM witnessRequests WHERE accepted=0 and denied=0 and requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S")
witnessRec.open strQuery,conn,3,3
%>
<!-- #include file="_inclds/experiments/common/html/savePopups.asp"-->
<!-- #include file="_inclds/experiments/common/html/signPopups.asp"-->
<!-- #include file="_inclds/experiments/common/html/witnessPopups.asp"-->
<%If statusId = 5 And checkIfAllSigned(experimentId, experimentType, revisionNumber) And Not witnessRec.eof then%>


<div class="buttonHolder" style="margin-top:15px;" id="witnessButtons">
	<%If softSigned Or session("useGoogleSign") then%>
	<a href="javascript:void(0);" onclick="softWitness()" class="createLink"><%=witnessButtonLabel%></a>
	<%ElseIf companyUsesSso() And session("isSsoUser") then%>
	<a href="javascript:void(0);" onclick="$('#ssoWitnessSignDiv #witnessSubmitButton').prop('disabled',false);showPopup('ssoWitnessSignDiv')" class="createLink"><%=witnessButtonLabel%></a>
	<%else%>
	<a href="javascript:void(0);" onclick="showPopup('witnessSignDiv')" class="createLink"><%=witnessButtonLabel%></a>
	<%End if%>
	<a href="javascript:void(0);" onclick="showPopup('reasonDiv')" class="createLink"><%=rejectButtonLabel%></a>
</div>
<%End if%>


<%If statusId = 5 And isCoAuthorSign then%>
	<% If session("useSafe") Then%>
		<a href="javascript:void(0);" onclick="showPopup('softCoAuthorSignDiv');return false;" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
	<% elseif session("isSsoUser") then%>
		<a href="javascript:void(0);" onclick="showPopup('ssoCoAuthorSignDiv');return false;" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
	<% else %>
		<%If Not (session("hasInventoryIntegration") Or session("hasCompoundTracking")) then%>
			<a href="javascript:void(0);" onclick="showPopup('coAuthorSignDiv');return false;" class="createLink" id="signExperimentButton"><%=signExperimentButtonLabel%></a>
		<%End if%>
	<% End if %>
<%End if%>

<%If statusId = 10 And Not witnessRec.eof and revisionNumber = maxRevisionNumber  then%>
	<a href="javascript:void(0);" onclick="abandonExperiment(true);" class="createLink"><%="Approve"%></a>
	<a href="javascript:void(0);" onclick="showPopup('rejectAbandonReasonDiv')" class="createLink"><%="Reject"%></a>
<%End if%>

<div style="display:none;">
<form method="post" id="denyForm" name="denyForm" action="<%=mainAppPath%>/experiments/denyWitness.asp" target="submitFrame">
<input type="hidden" name="experimentId" value="<%=experimentId%>">
<input type="hidden" name="experimentType" value="<%=experimentType%>">
<%If Not witnessRec.eof then%>
<input type="hidden" name="requestId" value="<%=witnessRec("id")%>">
<%End if%>
<input type="hidden" name="reason" id="reason" value="">
</form>
</div>

<%
''412015 -- Check for revision number added on 8/22/16
If (session("roleNumber") Or session("canReopen")) <2 And (statusId = 6 Or statusId = 5) And CStr(expRec("revisionNumber")) = CStr(currentRevision) Then
''/412015
%>
<div class="buttonHolder" style="margin-top:15px;" id="witnessButtons">
	<a href="javascript:void(0);" onclick="showPopup('reopenDiv')" class="createLink"><%=reopenButtonLabel%></a>
</div>
<%
End if
%>
<%

prefix = GetPrefix(experimentType)
expPage = GetExperimentPage(prefix)
hrefStr = expPage & "?id=" & experimentId
If statusId = 6 Or statusId = 5 Then
	If revisionNumber = 1 Then
		hrefStr = hrefStr & "&revisionId=" & revisionNumber	
	else
		'constellation data migration work around
		If statusId = 6 Then
			If revisionNumber > 2 And Not session("hasShortPdf") then
				hrefStr = hrefStr & "&revisionId=" & revisionNumber-1
			Else
				hrefStr = hrefStr & "&revisionId=" & revisionNumber			
			End if
		else
			hrefStr = hrefStr & "&revisionId=" & revisionNumber
		End if
	End if
Else
	If revisionNumber <> maxRevisionNumber Then
		hrefStr = hrefStr & "&revisionId=" & revisionNumber
	end If
End if
%>
<!-- #include file="_inclds/experiments/common/buttons/html/pdfExperimentSignButtons.asp"-->
<a href="<%=hrefStr%>&expView=true" class="createLink" style="float:right;margin-right:60px;"><%=experimentViewLabel%></a>

<%'start tyler%>
<style type="text/css">

table.witnessRequest {
    border: 1px solid #A2A2A2;
    border-spacing: 0px;
}

table.witnessRequest td {
    padding: 3px 9px;
    font-size: 13px;
}

table.witnessRequest thead td {
    background-color: #F9F9F9;
    border-bottom: 1px solid #7B7B7B;
}

</style>
<%If statusId = 5 Then %>
<%If experimentType = 5 Then%>
<table class="witnessRequest">
<thead>
	<tr>
		<td>Signer</td>
		<td>Approved</td>
	</tr>
</thead>
<tbody><tr>

<%
	Set signRec = server.CreateObject("ADODB.RecordSet")
	signQuery = "SELECT firstName + ' ' + lastName AS userName, " &_
			  		 "signed " &_
				"FROM experimentSignatures " &_
				"JOIN users " &_
				"ON experimentSignatures.userId = users.id " &_
				"AND experimentId = " & experimentId & " " &_
				"AND experimentType = " & experimentType & " " &_
				"AND revisionNumber = " & revisionNumber
	signRec.open signQuery, conn, 3, 3
	do while not signRec.eof
		userName = signRec("userName")
		signed = signRec("signed")
		signed = IIF(signed = "1", "Yes", "No")
%>
	<td><%=userName%></td>
	<td><%=signed%></td>
<tr>
<%
		signRec.movenext
	loop
	signRec.close
	Set signRec = nothing
%>

</tr></tbody>
</table>
<%End If%>
<%
' query the experimentDrafts table and select witnessRequestView 
	Set expRec3 = server.CreateObject("ADODB.RecordSet")
	strQuery3 = "SELECT requesteeFirstName, requesteeLastName, dateSubmitted, dateWitnessed, accepted FROM witnessRequestsView WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentTypeId="&SQLClean(experimentType,"N","S")
	expRec3.open strQuery3,conn,3,3
	%>
	<table class="witnessRequest">
	<thead>
		<tr>
			<td>Name</td>
			<td>Date Requested</td>
			<td>Date Witnessed</td>
			<td>Accepted</td>
		</tr>
	</thead>
	<tbody><tr>
	<%
	counter = 0
	Do While Not expRec3.eof
		counter = counter + 1
		requesteeFirstName = expRec3("requesteeFirstName")
		requesteeLastName = expRec3("requesteeLastName")
		dateSubmitted = expRec3("dateSubmitted")
		dateWitnessed = expRec3("dateWitnessed")
		accepted = expRec3("accepted")

		If accepted = 0 Then
			accepted = "False"
		Else
			accepted = "True"
		End If

		%>
		<tr>
		<td>
		<%= requesteeFirstName & " " & requesteeLastName %>
		</td>
		<td id="submitted_row_<%=counter%>">
		<script>setElementContentToDateString("submitted_row_<%=counter%>", "<%=dateSubmitted%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
		</td>
		<td id="witnessed_row_<%=counter%>">
		<script>setElementContentToDateString("witnessed_row_<%=counter%>", "<%=dateWitnessed%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
		</td>
		<td>
		<%= accepted %>
		</td>
		</tr>
		<%
		expRec3.moveNext
	Loop
	expRec3.close
	Set expRec3 = nothing
	%>
	</tr></tbody>
	</table>
<%End if%>
<%'end tyler%>

<%
'soft token div
%>
<div id="softTokenDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Sign/Witness Experiment</div>
<iframe id="softTokenFrame" name="softTokenFrame" src="javascript:void(0);" style="width:590px;height:585px"></iframe>
</div>

<%
'safe soft signing div
%>
<div id="softSignDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Sign Experiment</div>
<form name="sign_form" method="post" action="sign-experiment.asp" OnSubmit="return false;" class="popupForm" z-index="-1">
	<section>
		<label for="signStatusBox" class="select-style-label">Status</label>
		<div class="select-style">
			<select name="softSignStatusBox" id="softSignStatusBox" style='margin-top:3px;' onchange="if(this.options[this.selectedIndex].value == 1){document.getElementById('softRequesteeIdBoxDiv').style.display='none'}else{document.getElementById('softRequesteeIdBoxDiv').style.display='block'}">
				<option value="2">Sign and Close</option>
				<option value="1">Sign and Keep Open</option>
			</select>
		</div>
	</section>
	<section>
		<div id="softWitnessListLoadingMessage">Loading witness list...</div>
		<div id="softRequesteeIdBoxDiv">
		</div>
	</section>
	<input type="hidden" name="requesteeId" id="requesteeId" value="">
	<section class="bottomDisclaimer">
		<div>*Checking this box and entering your <%If session("companyId") <> "4" then%>password<%else%>employee id<%End if%> indicates that you have performed the work as described.
		</div>
	</section>
	<section id="softSignDivButtons" class="bottomButtons buttonAlignedRight">
		<input type="checkbox" name="softVerify" id="softVerify" class="<%If bCheck<>"IE 8.0" Then%>css-checkbox<%else%>css-checkbox-ie8<%End if%>">
		<label for="softVerify" class="css-label checkboxLabel">*Reviewed</label>
		<button type="submit" onclick="softSign2()">Sign</button>
	</section>
</form>
</div>

<%
'safe soft signing div Co Author (no witness)
%>
<div id="softCoAuthorSignDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Sign Experiment</div>
<form name="sign_form" method="post" action="sign-experiment.asp" OnSubmit="return false;" class="popupForm" z-index="-1">
	<section>
		<label for="signStatusBox" class="select-style-label">Status</label>
		<div class="select-style">
			<select name="softSignStatusBox" id="softSignCoAuthorStatusBox" style='margin-top:3px;' onchange="if(this.options[this.selectedIndex].value == 1){document.getElementById('softRequesteeIdBoxDiv').style.display='none'}else{document.getElementById('softRequesteeIdBoxDiv').style.display='block'}">
				<option value="2">Sign and Close</option>
				<option value="1">Sign and Keep Open</option>
			</select>
		</div>
	</section>
	<section class="bottomDisclaimer">
		<div>*Checking this box and entering your credentials indicates that you have performed the work as described.
		</div>
	</section>
	<section id="softCoAuthorSignDivButtons" class="bottomButtons buttonAlignedRight">
		<input type="checkbox" name="softVerify" id="softCoAuthorVerify" class="<%If bCheck<>"IE 8.0" Then%>css-checkbox<%else%>css-checkbox-ie8<%End if%>">
		<label for="softCoAuthorVerify" class="css-label checkboxLabel">*Reviewed</label>
		<button type="submit" onclick="softSign2(true)">Sign</button>
	</section>
</form>
</div>


<!-- #include file="_inclds/common/html/submitFrame.asp"-->
<!-- #include file="_inclds/footer-tool.asp"-->
<%
Call getconnected
trash = addToRecentlyViewed(experimentId,experimentType)
Call disconnect
%>
<%else%>
<%response.redirect(mainAppPath&"/static/error.asp")%>
<%End if%>

<%'Making sure the experimentId, experimentType and experimentStatusId variables
'are properly initialized.%>
<script>
	experimentId = "<%=experimentId%>"
	experimentType = "<%=experimentType%>"
	experimentStatusId = "<%=statusId%>"
    statusId = <%=statusId%>
</script>
