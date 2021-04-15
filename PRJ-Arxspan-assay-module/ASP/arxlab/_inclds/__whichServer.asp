<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
set scriptShell = createobject("WScript.Shell")
whichServer = scriptShell.ExpandEnvironmentStrings("%WHICHSERVER%")
Set scriptShell = Nothing
loginScriptName = getDefaultSingleAppConfigSetting("loginScriptPath")

elnDataBaseServerIP = getElnDataBaseServerIp()
elnDataBaseName = getElnDataBaseName()
elnDataBaseUserNameAdmin = getElnDataBaseAdminUserName()
elnDataBaseUserPasswordAdmin = getElnDataBaseAdminPassword()
elnDataBaseUserName = getElnDataBaseUserName()
elnDataBaseUserPassword = getElnDataBaseUserPassword()
logDataBaseServerIP = getLogDataBaseServerIp()
logDataBaseUserName = getLogDataBaseUserName()
logDataBaseUserPassword = getLogDataBasePassword()
logDataBaseName = getLogDataBaseName()
elnChemJsonSearchDatabaseServerIp = getDefaultSingleAppConfigSetting("elnChemJsonSearchDatabaseServerIp")
elnChemJsonSearchDataBaseName = getDefaultSingleAppConfigSetting("elnChemJsonSearchDataBaseName")
elnChemJsonSearchUserName = getDefaultSingleAppConfigSetting("elnChemJsonSearchUserName")
elnChemJsonSearchUserPassword = getDefaultSingleAppConfigSetting("elnChemJsonSearchPassword")
regDatabaseName = getCompanySpecificSingleAppConfigSetting("regDataBaseName", session("companyId"))
regDataBaseServerIP = getCompanySpecificSingleAppConfigSetting("regDataBaseServerIp", session("companyId"))
regDataBaseServerUserName = getCompanySpecificSingleAppConfigSetting("regDataBaseServerUserName", session("companyId"))
regDataBaseServerUserPassword = getCompanySpecificSingleAppConfigSetting("regDataBaseServerUserPassword", session("companyId"))
%>
<%whichLocation = "CLOUD"%> <%'CLOUD H3%>
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
chemAxonRootUrl = getCompanySpecificSingleAppConfigSetting("chemAxonEndpointUrl", session("companyId"))
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
mainAppPath = getCompanySpecificSingleAppConfigSetting("mainAppPath", session("companyId"))
mainCSSPath = mainAppPath & "/css"
regPath = mainAppPath & "/registration"

uploadRoot = uploadRootRoot & "\" & session("companyId")
uploadRootReg = uploadRootRoot & "\reg_uploads\" & session("companyId")

chemAxonStandardizerUrl = chemAxonRootUrl & "util/convert/standardizer"
chemAxonMolExportUrl = chemAxonRootUrl & "util/calculate/molExport"
chemAxonCipStereoUrl = chemAxonRootUrl & "util/calculate/cipStereoInfo"

%>
<script language="JScript" src="/arxlab/js/json2.asp" runat="server"></script>
<%
If session("userOptions") <> "" then
	Set userOptions = JSON.parse(session("userOptions"))
Else
	Set userOptions = JSON.parse("{}")
End if
%>

<%

regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
For i = 1 To regBatchNumberLength
	' This was previously defined up above as an empty string for the companies who wanted this.
	' I guess its used in tandem with the regBatchNumberLength to pad out the whole batch number with 0s.
	' As of this writing there are no companies that have this setting defined because ASP treats nonexistence
	' as an empty string.
	compoundBatchNumber = 	compoundBatchNumber & "0"
next
%>

<%
'START CONNECTION TO REG DATABASE
Sub getconnectedJchemReg
	trash = 1
End Sub

Function jchemRegConn()
	Dim thisJchemRegConn
	connStr = "Provider=sqloledb;Data Source="&regDataBaseServerIP&";Initial Catalog="&regDatabaseName&";User Id="&regDataBaseServerUserName&";Password="&regDataBaseServerUserPassword&";"

	Set thisJchemRegConn = Server.CreateObject("ADODB.CONNECTION")
	
	On Error Resume Next
	thisJchemRegConn.Open connStr
	If 0 <> Err.Number Then
		response.write("Error connecting to database. Error number: " & Err.Number & " Error description: " & Err.Description)
		response.End()
	End If
	On Error Goto 0
	
	Set jchemRegConn = thisJchemRegConn
	On Error GoTo 0
End function

Sub disconnectJchemReg
	trash = 1
End Sub
'END CONNECTION TO REG DATABASE

'START CONNECTION TO CAS NUMBER SEARCH DATABASE
Sub getconnectedCasDb
	trash = 1
End Sub

Function casDbConn()
	Dim thisCasDbConn
	connStr = ""
	connStr = "Provider=sqloledb;Data Source="&elnChemJsonSearchDatabaseServerIp&";Initial Catalog="&elnChemJsonSearchDataBaseName&";User Id="&elnChemJsonSearchUserName&";Password="&elnChemJsonSearchUserPassword&";"
	
	Set thisCasDbConn = Server.CreateObject("ADODB.CONNECTION")
	
	On Error Resume Next
	thisCasDbConn.Open connStr
	If 0 <> Err.Number Then
		response.write("Error connecting to database. Error number: " & Err.Number & " Error description: " & Err.Description)
		response.End()
	End If
	On Error Goto 0
	
	Set casDbConn = thisCasDbConn
	On Error GoTo 0
End function

Sub disconnectCasDb
	trash = 1
End Sub
'END CONNECTION TO ELN CHEM SEARCH DATABASE

'START CONNECTION TO ELN DATABASE
Sub getconnected
	trash = 1
End Sub

Function conn()
	Dim thisConn
	connStr = "Provider=sqloledb;Data Source="&elnDataBaseServerIP&";Initial Catalog="&elnDataBaseName&";User Id="&elnDataBaseUserName&";Password="&elnDataBaseUserPassword&";"

	Set thisConn = Server.CreateObject("ADODB.CONNECTION")
	thisConn.connectiontimeout = 15
	thisConn.CommandTimeout = 30
	
	On Error Resume Next
	thisConn.Open connStr
	If 0 <> Err.Number Then
		response.write("Error connecting to database. Error number: " & Err.Number & " Error description: " & Err.Description)
		response.End()
	End If
	On Error Goto 0
	
	Set conn = thisConn
	On Error GoTo 0
End function

Function connNoTimeout()
	Dim thisConn
	connStr = "Provider=sqloledb;Data Source="&elnDataBaseServerIP&";Initial Catalog="&elnDataBaseName&";User Id="&elnDataBaseUserName&";Password="&elnDataBaseUserPassword&";"
	
	Set thisConn = Server.CreateObject("ADODB.CONNECTION")
	thisConn.connectiontimeout=5
	thisConn.CommandTimeout = 0
	
	On Error Resume Next
	thisConn.Open connStr
	If 0 <> Err.Number Then
		response.write("Error connecting to database. Error number: " & Err.Number & " Error description: " & Err.Description)
		response.End()
	End If
	On Error Goto 0
	
	Set connNoTimeout = thisConn
	On Error GoTo 0
End function

Sub getconnectedadm
	trash = 1
End Sub

Function connAdm()
	Dim thisConnAdm
	connStr = "Network Library=DBMSSOCN;Provider=sqloledb;Data Source="&elnDataBaseServerIP&";Initial Catalog="&elnDataBaseName&";User Id="&elnDataBaseUserNameAdmin&";Password="&elnDataBaseUserPasswordAdmin&";"
	
	Set thisConnAdm = Server.CreateObject("ADODB.CONNECTION")
	thisConnAdm.connectiontimeout=5
	
	On Error Resume Next
	thisConnAdm.Open connStr
	If 0 <> Err.Number Then
		response.write("Error connecting to database. Error number: " & Err.Number & " Error description: " & Err.Description)
		response.End()
	End If
	On Error Goto 0
	
	Set connAdm = thisConnAdm
	On Error GoTo 0
End function

Sub getconnectedadmTrans
	Application("ConnAdmTrans") = "Network Library=DBMSSOCN;Provider=sqloledb;Data Source="&elnDataBaseServerIP&";Initial Catalog="&elnDataBaseName&";User Id="&elnDataBaseUserNameAdmin&";Password="&elnDataBaseUserPasswordAdmin&";"
	
	Set ConnAdmTrans = Server.CreateObject("ADODB.CONNECTION")
	ConnAdmTrans.connectiontimeout=5
	
	On Error Resume Next
	ConnAdmTrans.Open Application("ConnAdmTrans")
	If 0 <> Err.Number Then
		response.write("Error connecting to database. Error number: " & Err.Number & " Error description: " & Err.Description)
		response.End()
	End If
	On Error Goto 0
	
	On Error GoTo 0
End Sub

Sub getconnectedlog
	trash = 1
End Sub

Function connLog()
	Dim thisConnLog
	connStr = "Provider=sqloledb;Data Source="&logDataBaseServerIP&";Initial Catalog="&logDataBaseName&";User Id="&logDataBaseUserName&";Password="&logDataBaseUserPassword&";"
	
	Set thisConnLog = Server.CreateObject("ADODB.CONNECTION")
	thisConnLog.connectiontimeout=5
	
	On Error Resume Next
	thisConnLog.Open connStr
	If 0 <> Err.Number Then
		response.write("Error connecting to database. Error number: " & Err.Number & " Error description: " & Err.Description)
		response.End()
	End If
	On Error Goto 0
	
	Set connLog = thisConnLog
	On Error GoTo 0
End function


Sub disconnect
	trash = 1
End Sub


Sub disconnectadm
	trash = 1
End Sub

Sub disconnectlog
	trash = 1
End Sub

'END CONNECTION TO ELN DATABASE

%>
<!-- #include file="__standardizerConfigs.asp"-->
<%
'muf
mufName = "Collaboration"

If userOptions.Get("languageSelect")<>"" Then
	interfaceLanguage = userOptions.Get("languageSelect")
else
	interfaceLanguage = "English"
	If InStr(LCase(Request.ServerVariables("HTTP_ACCEPT_LANGUAGE")),",zh;")>0 Or InStr(LCase(Request.ServerVariables("HTTP_ACCEPT_LANGUAGE")),"zh-cn,")>0 Or InStr(LCase(Request.ServerVariables("HTTP_ACCEPT_LANGUAGE")),"zh,en-us;")>0 Or LCase(Request.ServerVariables("HTTP_ACCEPT_LANGUAGE"))="zh" Or LCase(Request.ServerVariables("HTTP_ACCEPT_LANGUAGE"))="zn-ch" then
		interfaceLanguage = "Chinese"
	End if
	If InStr(Request.ServerVariables("HTTP_ACCEPT_LANGUAGE"),",ja;")>0 Or InStr(Request.ServerVariables("HTTP_ACCEPT_LANGUAGE"),"ja-JP,")>0 Or InStr(Request.ServerVariables("HTTP_ACCEPT_LANGUAGE"),"ja,en-US;")>0 Or Request.ServerVariables("HTTP_ACCEPT_LANGUAGE")="ja" Or Request.ServerVariables("HTTP_ACCEPT_LANGUAGE")="ja-JP" then
		interfaceLanguage = "Japanese"
	End If
	If session("email") = "shsiao@broadinstitute.org" Then
		interfaceLanguage = "English"
	End If
End if
set languageJSON = JSON.Parse ( "{}")
Select Case interfaceLanguage

Case "Japanese"
noneLabel = "&#12394;&#12375;"
searchForaProjectLabel = "&#20837;&#21147;&#12375;&#12390;&#12503;&#12525;&#12472;&#12455;&#12463;&#12488;&#12434;&#26908;&#32034;"
singleProjectLabel = "&#20491;&#21029;&#12503;&#12525;&#12472;&#12455;&#12463;&#12488;"
requiredFieldLabel = "&#20837;&#21147;&#24517;&#38920;"
creatingLabel = "&#20316;&#25104;&#20013;"
fileSearchLabel = "&#12501;&#12449;&#12452;&#12523;&#26908;&#32034;"
contactSupportLabel = "&#36899;&#32097;&#12469;&#12509;&#12540;&#12488;"
welcomeLabel = "&#12424;&#12358;&#12371;&#12381;"
newNotificationsLabel = "&#26032;&#12375;&#12356;&#12362;&#30693;&#12425;&#12379;"
watchlistLabel = "&#12454;&#12458;&#12483;&#12481;&#12522;&#12473;&#12488;"
notebooksLabel = "&#12494;&#12540;&#12488;&#12502;&#12483;&#12463;"
projectsLabel = "&#12503;&#12525;&#12472;&#12455;&#12463;&#12488;"
ordersNavHeading = "Work Orders"
helpLabel = "&#12504;&#12523;&#12503;"
logoutLabel = "&#12525;&#12464;&#12450;&#12454;&#12488;"
arxlabToolsLabel = "&#12484;&#12540;&#12523;"
dashboardLabel = "&#12480;&#12483;&#12471;&#12517;&#12508;&#12540;&#12489;"
manageUsersLabel = "&#12518;&#12540;&#12470;&#12540;&#31649;&#29702;"
manageGroupsLabel = "&#12464;&#12523;&#12540;&#12503;&#31649;&#29702;"
userActivityLabel = "&#12518;&#12540;&#12470;&#12540;&#12398;&#29366;&#24907;"
uploadReagentDatabaseLabel = "&#35430;&#34220;&#12487;&#12540;&#12479;&#12505;&#12540;&#12473;&#12434;&#12450;&#12483;&#12503;&#12525;&#12540;&#12489;"
cdxmlConvertTestLabel = "Convert CDX/CDXML"
chemicalSearchLabel = "&#27083;&#36896;&#26908;&#32034;"
advancedSearchLabel = "&#35443;&#12375;&#12356;&#26908;&#32034;"
recentlyViewedExperimentsLabel = "&#26368;&#36817;&#38322;&#35239;&#12375;&#12383;&#23455;&#39443;"
notificationsLabel = "&#12362;&#30693;&#12425;&#12379;"
notificationsLabel2 = "&#36899;&#32097;"
moreLabel = "&#12373;&#12425;&#12395;"
detailsLabel = "&#35443;&#32048;"
templatesLabel = "&#12486;&#12531;&#12503;&#12524;&#12540;&#12488;"
customDropDownsLabel = "&#12489;&#12525;&#12483;&#12503;&#12480;&#12454;&#12531;&#12522;&#12473;&#12488;&#12398;&#35373;&#23450;"
biologyProtocolTemplatesLabel = "&#29983;&#29289;&#31995;&#25805;&#20316;&#12486;&#12531;&#12503;&#12524;&#12540;&#12488;"
biologySummaryTemplatesLabel = "&#29983;&#29289;&#31995;&#12469;&#12510;&#12522;&#12540;&#12486;&#12531;&#12503;&#12524;&#12540;&#12488;"
chemistryPreparationTemplatesLabel = "&#21270;&#23398;&#31995;&#25805;&#20316;&#12486;&#12531;&#12503;&#12524;&#12540;&#12488;"
conceptDescriptionTemplatesLabel = "&#12467;&#12531;&#12475;&#12503;&#12488;&#23450;&#32681;&#12486;&#12531;&#12503;&#12524;&#12540;&#12488;"
keywordEditorTemplatesLabel = "Allowed Tags"
invitationsLabel = "&#25307;&#24453;"
witnessRequestsLabel = "&#25215;&#35469;&#35201;&#35531;"
witnessedByMeLabel = "&#25215;&#35469;&#23653;&#27508;"
recentLabel = "&#26368;&#36817;"
newLabel = "&#26032;&#35215;"
viewMoreLabel = "&#12373;&#12425;&#12395;&#35211;&#12427;"
viewAllLabel = "&#20840;&#12390;&#12434;&#35211;&#12427;"
myNotebooksLabel = "&#12510;&#12452;&#12494;&#12540;&#12488;&#12502;&#12483;&#12463;"
sharedLabel = "&#20849;&#26377;"
experimentsLabel = "&#23455;&#39443;"
currentLabel = "&#29694;&#22312;"
historyLabel = "&#23653;&#27508;"
experimentNameLabel = "&#23455;&#39443;&#21517;"
deleteLabel = "&#28040;&#21435;"
deleteLabel2 = "&#21066;&#38500;"
experimentDescriptionLabel = "&#35500;&#26126;"
experimentLabel = "&#23455;&#39443;"
objectiveLabel = "&#30446;&#30340;"
summaryLabel = "&#12469;&#12510;&#12522;&#12540;"
addFileLabel = "&#12501;&#12449;&#12452;&#12523;&#12434;&#36861;&#21152;"
addNoteLabel = "&#12513;&#12514;&#12434;&#36861;&#21152;"
showArxlabHelpLabel = "&#12504;&#12523;&#12503;&#12434;&#35211;&#12427;"
sendSupportRequestLabel = "&#12469;&#12509;&#12540;&#12488;&#12522;&#12463;&#12456;&#12473;&#12488;&#12434;&#36865;&#12427;"
contactArxspanSupportLabel = "Arxspan &#12469;&#12509;&#12540;&#12488;&#12395;&#36899;&#32097;"
firstNameLabel = "&#21517;"
lastNameLabel = "&#22995;"
emailLabel = "&#12513;&#12540;&#12523;&#12450;&#12489;&#12524;&#12473;"
companyLabel = "&#20250;&#31038;&#21517;"
subjectLabel = "&#20027;&#38988;"
personsTitleLabel = "&#24441;&#32887;&#12539;&#32937;&#26360;&#12365;"
phoneNumberLabel = "&#38651;&#35441;&#30058;&#21495;"
typeOfRequestLabel = "&#12372;&#35201;&#26395;&#12398;&#12459;&#12486;&#12468;&#12522;&#12540;"
requestLabel = "&#12372;&#35201;&#26395;"
submitLabel = "&#36865;&#20449;"
pleaseSelectLabel = "&#36984;&#25246;"
somethingIsNotWorkingLabel = "&#24605;&#12358;&#12424;&#12358;&#12395;&#21205;&#20316;&#12375;&#12394;&#12356;"
iNeedHelpDoingSomethingLabel = "&#12393;&#12358;&#12375;&#12383;&#12425;&#12356;&#12356;&#12363;&#12431;&#12363;&#12425;&#12394;&#12356;"
newFeatureRequestLabel = "&#26032;&#12375;&#12356;&#12459;&#12486;&#12468;&#12522;&#12540;"
otherLabel = "&#12381;&#12398;&#20182;"
lastViewedLabel = "&#26368;&#32066;&#38322;&#35239;&#26085;"
creatorLabel = "&#20316;&#25104;&#32773;"
dateCreatedLabel = "&#20316;&#25104;&#26085;"
dateLastModifiedLabel = "&#26368;&#32066;&#26356;&#26032;&#26085;"
typeLabel = "&#12479;&#12452;&#12503;"
statusLabel = "&#29366;&#27841;"
grantSharingPermissionLabel = "&#12371;&#12398;&#12494;&#12540;&#12488;&#12502;&#12483;&#12463;&#12398;&#20849;&#26377;&#12434;&#35377;&#21487;"
closeWindowLabel = "&#38281;&#12376;&#12427;"
chemistryExperimentLabel = "&#21512;&#25104;&#32773;&#29992;"
biologyExperimentLabel = "&#29983;&#29289;&#32773;&#29992;"
conceptExperimentLabel = "&#30528;&#24819;"
analExperimentLabel = "&#20998;&#26512;&#32773;&#29992;"
reactionTabLabel = "&#21270;&#23398;&#21453;&#24540;"
attachmentsTableLabel = "&#28155;&#20184;&#12486;&#12540;&#12502;&#12523;"
saveButtonLabel = "&#20445;&#23384;"
showPdfVersionButtonLabel = "PDF &#12398;&#30906;&#35469;"
copyExperimentButtonLabel = "&#35079;&#35069;"
moveExperimentButtonLabel = "&#31227;&#21205;"
signExperimentButtonLabel = "&#32626;&#21517;"
rejectButtonLabel = "&#21364;&#19979;"
reopenButtonLabel = "&#20877;&#12458;&#12540;&#12503;&#12531;"
witnessButtonLabel = "&#32626;&#21517;"
uploadReactionLabel = "&#12501;&#12449;&#12452;&#12523;&#12398;&#35501;&#36796;"
quickViewLabel = "&#12469;&#12510;&#12522;&#12540;"
reactionConditionsLabel = "&#21453;&#24540;&#26465;&#20214;"
reactionPreparationLabel = "&#21453;&#24540;&#25163;&#38918;"
experimentLinksLabel = "&#12456;&#12463;&#12473;&#12506;&#12522;&#12513;&#12531;&#12488;&#12408;&#12398;&#12522;&#12531;&#12463;"
projectLinksLabel = "&#12503;&#12525;&#12472;&#12455;&#12463;&#12488;&#12408;&#12398;&#12522;&#12531;&#12463;"
myProfileLabel = "&#12510;&#12452;&#12503;&#12525;&#12501;&#12449;&#12452;&#12523;"
inventoryLabel = "&#12452;&#12531;&#12505;&#12531;&#12488;&#12522;&#12540;"
assayLabel = "&#12450;&#12483;&#12475;&#12452;"
registrationLabel = "&#12524;&#12472;&#12473;&#12488;&#12524;&#12540;&#12471;&#12519;&#12531;"
myExperimentsLabel = "&#12510;&#12452;&#12456;&#12463;&#12473;&#12506;&#12522;&#12513;&#12531;&#12488;"
plateHistoryLabel = "&#12503;&#12524;&#12540;&#12488;&#23653;&#27508;"
addSaltLabel = "&#22633;&#12398;&#36861;&#21152;"
registerLabel = "&#30331;&#37682;"
searchLabel = "&#26908;&#32034;"
customFieldsLabel = "&#12459;&#12473;&#12479;&#12512;&#12501;&#12451;&#12540;&#12523;&#12489;"
groupCustomFieldsLabel = "&#12459;&#12473;&#12479;&#12512;&#12501;&#12451;&#12540;&#12523;&#12489;&#12464;&#12523;&#12540;&#12503;"
adminApproveLabel = "&#30331;&#37682;&#12398;&#25215;&#35469;"
mappingTemplatesLabel = "&#12510;&#12483;&#12500;&#12531;&#12464;&#12486;&#12531;&#12503;&#12524;&#12540;&#12488;"
bulkRegistrationLabel = "&#12496;&#12523;&#12463;&#30331;&#37682;"
bulkUpdateLabel = "&#12496;&#12523;&#12463;&#26356;&#26032;"
SDRollbackLabel = "&#19968;&#25324;&#30331;&#37682;&#12398;&#12525;&#12464;"
currentPasswordLabel = "&#29694;&#22312;&#12398;&#12497;&#12473;&#12527;&#12540;&#12489;"
newPasswordLabel = "&#26032;&#12375;&#12356;&#12497;&#12473;&#12527;&#12540;&#12489;"
confirmPasswordLabel = "&#12497;&#12473;&#12527;&#12540;&#12489;&#12398;&#30906;&#35469;"
changePasswordLabel = "&#12497;&#12473;&#12527;&#12540;&#12489;&#12398;&#22793;&#26356;"
updateLabel = "&#26356;&#26032;"
chemicalEditorLabel = "&#27083;&#36896;&#24335;&#25551;&#30011;&#12484;&#12540;&#12523;"
defaultNumExperimentsInNotebooksLabel = "&#12456;&#12463;&#12473;&#12506;&#12522;&#12513;&#12531;&#12488;&#12398;&#30011;&#38754;&#20869;&#34920;&#31034;&#25968;"
defaultWitnessLabel = "&#31532;&#19968;&#35388;&#20154;&#32773;"
addressLabel = "&#20303;&#25152;"
address1Label = "&#20303;&#25152;1"
address2Label = "&#20303;&#25152;2"
countryLabel = "&#22269;"
userRoleLabel = "&#12518;&#12540;&#12470;&#27177;&#38480;"
userGroupsLabel = "&#12518;&#12540;&#12470;&#12464;&#12523;&#12540;&#12503;"
userManagerLabel = "&#19978;&#38263;&#21517;"
notificationOnHomePageLabel = "HP &#12391;&#21463;&#38936;"
notificationByEmailLabel = "&#12513;&#12540;&#12523;&#12391;&#21463;&#38936;"
preferencesLabel = "&#12522;&#12501;&#12449;&#12524;&#12531;&#12473;"
createProjectLabel = "&#12503;&#12525;&#12472;&#12455;&#12463;&#12488;&#12398;&#20316;&#25104;"
projectDescriptionLabel = "&#12503;&#12525;&#12472;&#12455;&#12463;&#12488;&#12398;&#35500;&#26126;"
createNotebookLabel = "&#12494;&#12540;&#12488;&#12502;&#12483;&#12463;&#12398;&#20316;&#25104;"
notebookDescriptionLabel = "&#12494;&#12540;&#12488;&#12502;&#12483;&#12463;&#12398;&#35500;&#26126;"
selectNotebookLabel = "&#12494;&#12540;&#12488;&#12502;&#12483;&#12463;&#12398;&#36984;&#25246;"
experimentTypeLabel = "&#12456;&#12463;&#12473;&#12506;&#12522;&#12513;&#12531;&#12488;&#12398;&#31278;&#39006;"
projectLabel = "&#12503;&#12525;&#12472;&#12455;&#12463;&#12488;"
ownerLabel = "&#12458;&#12540;&#12490;&#12540;"
addTabLabel = "&#12475;&#12463;&#12471;&#12519;&#12531;&#12398;&#36861;&#21152;"
shareThisProjectLabel = "&#12371;&#12398;&#12503;&#12525;&#12472;&#12455;&#12463;&#12488;&#12434;&#20849;&#26377;"
shareThisNotebookLabel = "&#12371;&#12398;&#12494;&#12540;&#12488;&#12502;&#12483;&#12463;&#12434;&#20849;&#26377;"
numberOfUsersSelectedLabel = "&#36984;&#25246;&#12373;&#12428;&#12383;&#12518;&#12540;&#12470;&#25968;"
numberOfGroupsSelectedLabel = "&#36984;&#25246;&#12373;&#12428;&#12383;&#12464;&#12523;&#12540;&#12503;&#25968;"
readAccessLabelNotebook = "&#20840;&#12390;&#12398;&#12494;&#12540;&#12488;&#12502;&#12483;&#12463;&#12398;&#38322;&#35239;&#35377;&#21487;"
writeAccessLabelNotebook = "&#26032;&#12375;&#12356;&#12494;&#12540;&#12488;&#12502;&#12483;&#12463;&#12398;&#20316;&#25104;&#35377;&#21487;"
createExperimentLabel = "&#12456;&#12463;&#12473;&#12506;&#12522;&#12513;&#12531;&#12488;&#12398;&#20316;&#25104;"
numberOfPagesToDisplayLabel = "&#30011;&#38754;&#12395;&#34920;&#31034;&#12377;&#12427;&#12506;&#12540;&#12472;&#25968;"
changeLabel = "&#22793;&#26356;"
cancelLabel = "&#12461;&#12515;&#12531;&#12475;&#12523;"
accessLabel = "&#12450;&#12463;&#12475;&#12473;"
sharedByLabel = "&#20849;&#26377;&#20803;"
requestCompoundsLabel = "&#21270;&#21512;&#29289;&#12398;&#20837;&#21147;"
importProgressLabel = "&#21462;&#36796;&#29366;&#27841;"
addSketchLabel = "&#12473;&#12465;&#12483;&#12481;&#12398;&#36861;&#21152;"
productsLabel = "&#29983;&#25104;&#29289;"
notesTableLabel = "&#27880;&#37320;&#12486;&#12540;&#12502;&#12523;"
annotateLabel = "&#27880;&#37320;"
addCommentLabel = "&#12467;&#12513;&#12531;&#12488;&#12398;&#36861;&#21152;"
userProfileLabel = "&#12518;&#12540;&#12470;&#12503;&#12525;&#12501;&#12449;&#12452;&#12523;"
searchTypeLabel = "&#26908;&#32034;&#12398;&#26041;&#27861;"
resultsPerPageLabel = "&#30011;&#38754;&#20869;&#12398;&#34920;&#31034;&#25968;"
sortByLabel = "&#20006;&#12409;&#26367;&#12360;"
sortDirectionLabel = "&#20006;&#12409;&#26367;&#12360;&#38918;"
viewLogsLabel = "&#12525;&#12464;&#12398;&#34920;&#31034;"
viewLastLoginsLabel = "&#26368;&#32066;&#12525;&#12464;&#12452;&#12531;"
userLoginHistoryLabel = "&#12518;&#12540;&#12470;&#12540;&#12525;&#12464;&#12452;&#12531;&#23653;&#27508;"
defaultMolUnitsLabel = "&#21021;&#26399;&#12514;&#12523;&#20516;"
myUsersLabel = "&#12510;&#12452;&#12518;&#12540;&#12470;"
searchOnlyMyExperimentsLabel = "&#33258;&#20998;&#12398;&#12494;&#12540;&#12488;&#12398;&#26908;&#32034;"
sendWitnessRequestLabel = "&#35388;&#20154;&#35201;&#35531;"
experimentViewLabel = "&#12494;&#12540;&#12488;&#24418;&#24335;&#12499;&#12517;&#12540;"
addNextStepLabel = "&#27425;&#12398;&#21453;&#24540;&#12408;"
protocolLabel = "&#12503;&#12525;&#12488;&#12467;&#12523;"
detailedDescriptionLabel = "&#35443;&#32048;&#35500;&#26126;"
accessOptionsLabel = "&#12450;&#12463;&#12475;&#12473;&#12458;&#12503;&#12471;&#12519;&#12531;"
searchThisNotebookLabel = "&#12371;&#12398;&#12494;&#12540;&#12488;&#20869;&#12398;&#26908;&#32034;"
createLabel = "&#20316;&#25104;"
addLabel = "&#36861;&#21152;"
shareLabel = "&#20849;&#26377;"
passwordLabel = "&#12497;&#12473;&#12527;&#12540;&#12489;"
selectLabel = "Select"
nameLabel = "&#21517;&#31216;"
descriptionLabel = "&#35500;&#26126;"
downloadLabel = "&#12480;&#12454;&#12531;&#12525;&#12540;&#12489;"
removeLabel = "&#21066;&#38500;"
replaceLabel = "&#32622;&#25563;"
summaryReportLabel = "Operational Report Summary"
detailedReportLabel = "Detailed Operational Report"
ordersSubmitNewRequestLabel = "Submit New Request"
ordersManageRequestsLabel = "Manage Requests"
ordersUserSettingsLabel = "User Settings"
ordersDashboardLabel = "My Requests"
ordersManageDropDowns = "Configure Drop Downs"
ordersManageFields = "Configure Fields"
ordersManageRequestsTypes = "Configure Request Types"
ordersManageRequestItemTypes = "Configure Item Types"
enterInfotoCreateProjectLabel = "Enter Information to create a new Project"
enterInfotoCreateNewNotebookLabel = "Enter Information to create a new Notebook"
assayDeleteFormWarning = "このResult Setを削除しても良いですか？"
downloadAllPDFsLabel = "&#20840;&#12390;&#12398;PDF&#12434;&#12480;&#12454;&#12531;&#12525;&#12540;&#12489;"
groupFilterLabel = "&#12464;&#12523;&#12540;&#12503;&#12501;&#12451;&#12523;&#12479;&#12540;"
advancedSearchHistoryLabel = "&#12450;&#12489;&#12496;&#12531;&#12473;&#12469;&#12540;&#12481;&#23653;&#27508;"
rowNumberLabel = "&#34892;&#25968;"
userNameLabel = "&#12518;&#12540;&#12470;&#21517;"
structureSearchesLabel = "&#27083;&#36896;&#24335;&#26908;&#32034;"
textSearchesLabel = "&#12486;&#12461;&#12473;&#12488;&#26908;&#32034;"
multiParamSearchesLabel = "&#35079;&#21512;&#26908;&#32034;"
totalSearchesLabel = "&#21512;&#35336;&#26908;&#32034;&#25968;"
exportAsCSVLabel = "CSV&#12501;&#12449;&#12452;&#12523;&#20986;&#21147;"
locale = "ja"
loginDateAndTimeLabel = "&#12525;&#12464;&#12452;&#12531;&#26085;&#26178;"
startDateLabel = "&#38283;&#22987;&#26085;"
endDateLabel = "&#26368;&#32066;&#26085;"
collaboratorsLabel = "&#20849;&#21516;&#32232;&#38598;&#32773;"
timesViewedLabel = "&#21442;&#29031;&#22238;&#25968;"
lastViewerLabel = "&#26368;&#32066;&#21442;&#29031;&#32773;"
lastViewDateLabel = "&#26368;&#32066;&#21442;&#29031;&#26085;"
collaboratorFilterLabel = "&#20849;&#21516;&#32232;&#38598;&#32773;&#12501;&#12451;&#12523;&#12479;&#12540;"
viewerGroupFilterLabel = "&#21442;&#29031;&#32773;&#12464;&#12523;&#12540;&#12503;&#12501;&#12451;&#12523;&#12479;&#12540;"
viewAdvancedSearchHistoryLabel = "&#12450;&#12489;&#12496;&#12531;&#12473;&#12469;&#12540;&#12481;&#23653;&#27508;&#21442;&#29031;"
experimentViewHistoryLabel = "&#23455;&#39443;&#12499;&#12517;&#12540;&#23653;&#27508;"
experimentNotPursuedLabel = "&#20013;&#27490;&#12375;&#12383;&#23455;&#39443;"
experimentNotPursuedWarningLabel = "&#12371;&#12398;&#12456;&#12463;&#12473;&#12506;&#12522;&#12513;&#12531;&#12488;&#12364;&#20013;&#27490;&#12473;&#12486;&#12540;&#12479;&#12473;&#12395;&#12394;&#12426;&#12289;&#20170;&#24460;&#32232;&#38598;&#12391;&#12365;&#12394;&#12356;&#29366;&#24907;&#12395;&#12394;&#12426;&#12414;&#12377;&#12290;&#20013;&#27490;&#12377;&#12427;&#22580;&#21512;&#12399;&#12481;&#12455;&#12483;&#12463;&#12508;&#12483;&#12463;&#12473;&#12434;&#12458;&#12531;&#12395;&#12375;&#12390;&#12497;&#12473;&#12527;&#12540;&#12489;&#12434;&#20837;&#21147;&#12375;&#12414;&#12377;&#12290;"
rejectNotPursuedLabel = "&#20013;&#27490;&#12398;&#25215;&#35469;&#12434;&#21364;&#19979;"
notPursuedReasonLabel = "&#20013;&#27490;&#12398;&#25215;&#35469;&#12434;&#21364;&#19979;&#12375;&#12383;&#29702;&#30001;&#12434;&#20837;&#21147;&#12375;&#12390;&#12367;&#12384;&#12373;&#12356;&#65288;&#24517;&#38920;&#65289;&#12290;"
notPursuedVerificationErrorLabel = "&#12354;&#12394;&#12383;&#12399;&#12456;&#12463;&#12473;&#12506;&#12522;&#12513;&#12531;&#12488;&#12434;&#20013;&#27490;&#12377;&#12427;&#38555;&#12398;&#12503;&#12525;&#12475;&#12473;&#12434;&#29702;&#35299;&#12375;&#12390;&#12356;&#12427;&#24517;&#35201;&#12364;&#12354;&#12426;&#12414;&#12377;&#12290;"
selectWitnessLabel = "&#25215;&#35469;&#32773;&#12434;&#36984;&#25246;&#12367;&#12384;&#12373;&#12356;&#12290;"
notPursuedButtonLabel = "&#20013;&#27490;"

Case "English"
noneLabel = "None"
searchForaProjectLabel = "Type to search for a project"
singleProjectLabel = "Single Project"
requiredFieldLabel = "This field is required"
creatingLabel = "Creating"
enterInfotoCreateNewNotebookLabel = "Enter Information to create a new Notebook" 
enterInfotoCreateProjectLabel = "Enter Information to create a new Project"
fileSearchLabel = "File Search"
contactSupportLabel = "CONTACT SUPPORT"
welcomeLabel = "Welcome"
newNotificationsLabel = "New Notifications!"
watchListLabel = "Watchlist"
notebooksLabel = "Notebooks"
projectsLabel = "Projects"
ordersNavHeading = "Work Orders"
helpLabel = "Help"
logoutLabel = "Logout"
arxlabToolsLabel = "Tools"
dashboardLabel = "Dashboard"
manageUsersLabel = "Manage Users"
manageGroupsLabel = "Manage Groups"
userActivityLabel = "User Activity"
uploadReagentDatabaseLabel = "Upload Reagent Database"
cdxmlConvertTestLabel = "Convert CDX/CDXML"
chemicalSearchLabel = "Chemical Search"
advancedSearchLabel = "Advanced Search"
advancedSearchHistoryLabel = "Advanced Search History"
recentlyViewedExperimentsLabel = "Recently Viewed Experiments"
notificationsLabel = "Notifications"
notificationsLabel2 = "Notifications"
moreLabel = "More"
detailsLabel = "Details"
templatesLabel = "Templates"
customDropDownsLabel = "Custom Drop Downs"
biologyProtocolTemplatesLabel = "Biology Protocol Templates"
biologySummaryTemplatesLabel = "Biology Summary Templates"
chemistryPreparationTemplatesLabel = "Chemistry Preparation Templates"
conceptDescriptionTemplatesLabel = "Concept Description Templates"
keywordEditorTemplatesLabel = "Allowed Tags"
invitationsLabel = "Invitations"
witnessRequestsLabel = "Witness Requests"
witnessedByMeLabel = "Witnessed By Me"
recentLabel = "Recent"
newLabel = "New"
viewMoreLabel = "View More"
viewAllLabel = "View All"
myNotebooksLabel = "My Notebooks"
sharedLabel = "Shared"
experimentsLabel = "Experiments"
currentLabel = "Current"
historyLabel = "History"
experimentNameLabel = "Experiment Name"
deleteLabel = "Delete"
deleteLabel2 = "Delete"
experimentDescriptionLabel = "Experiment Description"
experimentLabel = "Experiment"
objectiveLabel = "Objective"
summaryLabel = "Summary"
addFileLabel = "Add File"
addNoteLabel = "Add Note"
showArxlabHelpLabel = "Help"
sendSupportRequestLabel = "Send a Support Request"
contactArxspanSupportLabel = "Contact Arxspan Support"
firstNameLabel = "First Name"
lastNameLabel = "Last Name"
emailLabel = "E-mail"
companyLabel = "Company"
subjectLabel = "Subject"
personsTitleLabel = "Title"
phoneNumberLabel = "Phone Number"
typeOfRequestLabel = "Type of Request"
requestLabel = "Request"
submitLabel = "Submit"
pleaseSelectLabel = "Please Select"
somethingIsNotWorkingLabel = "Something is not working"
iNeedHelpDoingSomethingLabel = "I need help doing something"
newUserSupportRequestLabel = "I need to add a new user"
newFeatureRequestLabel = "New Feature Request"
newUserSupportRequestFirstNameLabel = "New User First Name"
newUserSupportRequestLastNameLabel = "New User Last Name"
newUserSupportRequestEmailLabel = "New User Email"
otherLabel = "Other"
lastViewedLabel = "Last Viewed"
creatorLabel = "Creator"
dateCreatedLabel = "Date Created"
dateLastModifiedLabel = "Date Last Modified"
typeLabel = "Type"
statusLabel = "Status"
grantSharingPermissionLabel = "Grant Sharing Permission"
closeWindowLabel = "Close Window"
chemistryExperimentLabel = "Chemistry Experiment"
biologyExperimentLabel = "Biology Experiment"
conceptExperimentLabel = "Concept Experiment"
analExperimentLabel = "Analytical Experiment"
reactionTabLabel = "Reaction"
attachmentsTableLabel = "Attachments Table"
saveButtonLabel = "Save"
showPdfVersionButtonLabel = "Show PDF Version"
copyExperimentButtonLabel = "Copy"
moveExperimentButtonLabel = "Move"
signExperimentButtonLabel = "Sign"
rejectButtonLabel = "Reject"
reopenButtonLabel = "Reopen"
witnessButtonLabel = "Witness"
uploadReactionLabel = "Upload Reaction"
quickViewLabel = "Overview"
reactionConditionsLabel = "Conditions"
reactionPreparationLabel = "Preparation"
experimentLinksLabel = "Experiment Links"
projectLinksLabel = "Project Links"
myProfileLabel = "My Profile"
inventoryLabel = "Inventory"
assayLabel = "Assay"
registrationLabel = "Registration"
myExperimentsLabel = "MY EXPERIMENTS"
plateHistoryLabel = "Plate History"
addSaltLabel = "Add Salt"
registerLabel = "Register"
searchLabel = "Search"
customFieldsLabel = "Custom Fields"
groupCustomFieldsLabel = "Group Custom Fields"
adminApproveLabel = "Admin Approve"
mappingTemplatesLabel = "Mapping Templates"
bulkRegistrationLabel = "Bulk Registration"
bulkUpdateLabel = "Bulk Update"
SDRollbackLabel = "Bulk Registration Log"
currentPasswordLabel = "Current Password"
newPasswordLabel = "New Password"
confirmPasswordLabel = "Confirm Password"
changePasswordLabel = "Change Password"
updateLabel = "Update"
chemicalEditorLabel = "Chemistry Drawing Tool"
defaultNumExperimentsInNotebooksLabel = "Default Number of Experiments Shown in Notebooks"
defaultWitnessLabel = "Default Witness"
addressLabel = "Address"
address1Label = "Address 1"
address2Label = "Address 2"
countryLabel = "Country"
userRoleLabel = "Permissions"
userGroupsLabel = "Groups"
userManagerLabel = "Manager"
notificationOnHomePageLabel = "Notification"
notificationByEmailLabel = "Email"
preferencesLabel = "Options"
createProjectLabel = "Create Project"
projectDescriptionLabel = "Project Description"
createNotebookLabel = "Create Notebook"
notebookDescriptionLabel = "Notebook Description"
selectNotebookLabel = "Select Notebook"
experimentTypeLabel = "Experiment Type"
projectLabel = "Project"
ownerLabel = "Owner"
addTabLabel = "Add Subproject"
shareThisProjectLabel = "Share This Project"
shareThisNotebookLabel = "Share This Notebook"
numberOfUsersSelectedLabel = "users selected"
numberOfGroupsSelectedLabel = "groups selected"
readAccessLabelNotebook = "View/Read All Contents of Notebook"
writeAccessLabelNotebook = "Write/Create Experiments in Notebook"
createExperimentLabel = "Create Experiment"
numberOfPagesToDisplayLabel = "Number of Experiments per Page"
changeLabel = "Change"
cancelLabel = "Cancel"
accessLabel = "Access"
sharedByLabel = "Shared By"
requestCompoundsLabel = "Request Compounds"
importProgressLabel = "Import Progress"
addSketchLabel = "Add&nbsp;Sketch"
productsLabel = "Products"
notesTableLabel = "Notes Table"
annotateLabel = "Annotate"
addCommentLabel = "Add Comment"
userProfileLabel = "User Profile"
searchTypeLabel = "Search Type"
resultsPerPageLabel = "Results Per Page"
sortByLabel = "Sort By"
sortDirectionLabel = "Sort Direction"
viewLogsLabel = "View Logs"
viewLastLoginsLabel = "View Last Logins"
userLoginHistoryLabel = "User Login History"
defaultMolUnitsLabel = "Default mol Units"
myUsersLabel = "My Users"
searchOnlyMyExperimentsLabel = "Search Only My Experiments"
sendWitnessRequestLabel = "Send Witness Request"
experimentViewLabel = "Experiment View"
addNextStepLabel = "Add Next Step"
protocolLabel = "Protocol"
detailedDescriptionLabel = "Detailed Description"
accessOptionsLabel = "Access Options"
searchThisNotebookLabel = "Search This Notebook"
createLabel = "Create"
addLabel = "Add"
shareLabel = "Share"
passwordLabel = "Password"
selectLabel = "Select"
nameLabel = "Name"
descriptionLabel = "Description"
downloadLabel = "Download"
removeLabel = "Remove"
replaceLabel = "Replace"
summaryReportLabel = "Operational Report Summary"
detailedReportLabel = "Detailed Operational Report"
ordersSubmitNewRequestLabel = "Submit New Request"
ordersManageRequestsLabel = "Manage Requests"
ordersUserSettingsLabel = "User Settings"
ordersDashboardLabel = "My Requests"
ordersManageDropDowns = "Configure Drop Downs"
ordersManageFields = "Configure Fields"
ordersManageRequestsTypes = "Configure Request Types"
ordersManageRequestItemTypes = "Configure Item Types"
assayDeleteFormWarning = "Are you sure you would like to delete this result set?"
downloadAllPDFsLabel = "Download All PDFs"
groupFilterLabel = "Group Filter"
rowNumberLabel = "Row Number"
userNameLabel = "User's Name"
structureSearchesLabel = "Structure Searches"
textSearchesLabel = "Text Searches"
multiParamSearchesLabel = "Multi Param Searches"
totalSearchesLabel = "Total Searches"
exportAsCSVLabel = "Export As CSV"
locale = "en-US"
loginDateAndTimeLabel = "Login Date and Time"
startDateLabel = "Start Date"
endDateLabel = "End Date"
collaboratorsLabel = "Collaborators"
timesViewedLabel = "Times Viewed"
lastViewerLabel = "Viewer"
lastViewDateLabel = "View Date"
collaboratorFilterLabel = "Collaborator Filter"
viewerGroupFilterLabel = "Viewer Group Filter"
viewAdvancedSearchHistoryLabel = "View Advanced Search History"
experimentViewHistoryLabel = "Experiment View History"
abandonLabel = "Abandon"
rejectAbandonRequestLabel = "Reject Abandon Label"
approveAbandonRequestLabel = "Approve Abandon Request"
pleaseEnterAReasonForRejectingAbandonRequestLabel = "Please Enter a Reason for Rejecting Abandon Request (required)"
confirmAbandonRequestLabel = "Confirm Abandon Request"
witnessRequestRejectionLabel = "Witness Request Rejection"
abandonRequestRejectionLabel = "Abandon Request Rejection"
experimentReopenedLabel = "Experiment Reopened"
yourExperimentHasBeenReopenedLabel = "Your experiment has been reopened"
successLabel = "Success"
areYouSureLabel = "Are you sure?"
onceAbandonedYouWillNotBeAbleToRecoverExperimentLabel = "Once abandoned, you will not be able to recover experiment"
abandonRequestSubmittedLabel = "Abandon Request Submitted"
experimentNotPursuedLabel = "Experiment Not Pursued"
experimentNotPursuedWarningLabel = "Checking this box and entering your password indicates that you are no longer pursuing this experiment. This experiment will no longer be editable."
rejectNotPursuedLabel = "Reject Not Pursued Request"
notPursuedReasonLabel = "Please Enter a Reason for Rejecting the Not Pursued Request (required)"
notPursuedVerificationErrorLabel = "You must verify that you understand the 'Not Pursued' process."
selectWitnessLabel = "Please select a witness."
notPursuedButtonLabel = "Not Pursued"

Case "Chinese"
noneLabel = "&#33707;"
searchForaProjectLabel = "&#36755;&#20837;&#20851;&#38190;&#35789;&#25628;&#32034;&#39033;&#30446;"
singleProjectLabel = "&#21333;&#20010;&#39033;&#30446;"
requiredFieldLabel = "&#35813;&#39033;&#24517;&#22635;"
creatingLabel = "&#21019;&#24314;&#20013;"
fileSearchLabel = "File Search"
contactSupportLabel = "&#32852;&#31995;&#25903;&#25345;"
welcomeLabel = "&#27426;&#36814;"
newNotificationsLabel = "&#26032;&#36890;&#30693;"
watchListLabel = "&#20851;&#27880;&#21015;&#34920;"
notebooksLabel = "&#23454;&#39564;&#31508;&#35760;&#26412;"
projectsLabel = "&#39033;&#30446;"
ordersNavHeading = "Work Orders"
helpLabel = "&#24110;&#21161;"
logoutLabel = "&#30331;&#20986;"
arxlabToolsLabel = "&#24037;&#20855;"
dashboardLabel = "&#20027;&#25511;&#38754;&#26495;"
manageUsersLabel = "&#31649;&#29702;&#29992;&#25143;"
manageGroupsLabel = "&#31649;&#29702;&#32452;"
userActivityLabel = "&#29992;&#25143;&#27963;&#21160;"
uploadReagentDatabaseLabel = "&#19978;&#20256;&#35797;&#21058;&#25968;&#25454;&#24211;"
cdxmlConvertTestLabel = "Convert CDX/CDXML"
chemicalSearchLabel = "&#21270;&#23398;&#26816;&#32034;"
advancedSearchLabel = "&#39640;&#32423;&#26816;&#32034;"
recentlyViewedExperimentsLabel = "&#26368;&#36817;&#26597;&#30475;&#30340;&#23454;&#39564;"
notificationsLabel = "&#36890;&#30693;"
notificationsLabel2 = "&#36890;&#30693;"
moreLabel = "&#26356;&#22810;"
detailsLabel = "&#32454;&#33410;"
templatesLabel = "&#27169;&#26495;"
customDropDownsLabel = "&#33258;&#23450;&#20041;&#19979;&#25289;&#21015;&#34920;"
biologyProtocolTemplatesLabel = "&#29983;&#29289;&#25253;&#21578;&#27169;&#26495;"
biologySummaryTemplatesLabel = "&#29983;&#29289;&#24635;&#32467;&#27169;&#26495;"
chemistryPreparationTemplatesLabel = "&#21270;&#23398;&#25805;&#20316;&#27169;&#26495;"
conceptDescriptionTemplatesLabel = "&#27010;&#24565;&#25551;&#36848;&#27169;&#26495;"
keywordEditorTemplatesLabel = "Allowed Tags"
invitationsLabel = "&#36992;&#35831;"
witnessRequestsLabel = "&#35265;&#35777;&#35831;&#27714;"
witnessedByMeLabel = "&#35265;&#35777;&#20102;&#25105;"
recentLabel = "&#26368;&#36817;&#30340;"
newLabel = "&#26032;&#30340;"
viewMoreLabel = "&#26597;&#30475;&#26356;&#22810;"
viewAllLabel = "&#26597;&#30475;&#20840;&#37096;"
myNotebooksLabel = "&#25105;&#30340;&#31508;&#35760;&#26412;"
sharedLabel = "&#20849;&#20139;&#30340;"
experimentsLabel = "&#23454;&#39564;&#31508;&#35760;"
currentLabel = "&#30446;&#21069;&#30340;"
historyLabel = "&#21382;&#21490;&#35760;&#24405;"
experimentNameLabel = "Experiment Name"
deleteLabel = "&#21024;&#38500;"
deleteLabel2 = "&#21024;&#38500;"
experimentDescriptionLabel = "&#23454;&#39564;&#25551;&#36848;"
experimentLabel = "&#23454;&#39564;"
objectiveLabel = "&#30446;&#26631;"
summaryLabel = "&#24635;&#32467;"
addFileLabel = "&#28155;&#21152;&#25991;&#20214;"
addNoteLabel = "&#28155;&#21152;&#27880;&#37322;"
showArxlabHelpLabel = "Help"
sendSupportRequestLabel = "&#21457;&#36865;&#25903;&#25345;&#35831;&#27714;"
contactArxspanSupportLabel = " &#32852;&#31995;Arxspan&#25903;&#25345;"
firstNameLabel = "&#21517;"
lastNameLabel = "&#22995;"
emailLabel = "&#30005;&#23376;&#37038;&#31665;"
companyLabel = "&#20844;&#21496;"
subjectLabel = "&#23398;&#31185;"
personsTitleLabel = "&#22836;&#34900;"
phoneNumberLabel = "&#30005;&#35805;&#21495;&#30721;"
typeOfRequestLabel = "&#35831;&#27714;&#31867;&#22411;"
requestLabel = "&#35831;&#27714;"
submitLabel = "&#25552;&#20132;"
pleaseSelectLabel = "&#35831;&#36873;&#25321;"
somethingIsNotWorkingLabel = "&#26576;&#39033;&#21151;&#33021;&#19981;&#24037;&#20316;"
iNeedHelpDoingSomethingLabel = "&#25105;&#38656;&#35201;&#24110;&#21161;"
newFeatureRequestLabel = "&#26032;&#21151;&#33021;&#35831;&#27714;"
otherLabel = "&#20854;&#23427;"
lastViewedLabel = "&#19978;&#27425;&#27983;&#35272;&#30340;"
creatorLabel = "&#21019;&#24314;&#20154;"
dateCreatedLabel = "&#21019;&#24314;&#26085;&#26399;"
dateLastModifiedLabel = "&#26368;&#21518;&#20462;&#25913;&#26085;&#26399;"
typeLabel = "&#31867;&#22411;"
statusLabel = "&#29366;&#24577;"
grantSharingPermissionLabel = "&#20801;&#35768;&#20849;&#20139;&#27492;&#31508;&#35760;&#26412;"
closeWindowLabel = "&#20851;&#38381;"
chemistryExperimentLabel = "&#21270;&#23398;&#23454;&#39564;"
biologyExperimentLabel = "&#29983;&#29289;&#23454;&#39564;"
conceptExperimentLabel = "&#35774;&#24819;&#23454;&#39564;"
analExperimentLabel = "&#20998;&#26512;&#23454;&#39564;"
reactionTabLabel = "&#21453;&#24212;&#26041;&#31243;&#24335;"
attachmentsTableLabel = "&#38468;&#20214;&#34920;"
saveButtonLabel = "&#20445;&#23384;"
showPdfVersionButtonLabel = "&#26174;&#31034;PDF&#27169;&#24335;"
copyExperimentButtonLabel = "&#22797;&#21046;&#23454;&#39564;&#31508;&#35760;"
moveExperimentButtonLabel = "&#31227;&#21160;&#23454;&#39564;&#31508;&#35760;"
signExperimentButtonLabel = "&#31614;&#21517;&#23454;&#39564;&#31508;&#35760;"
rejectButtonLabel = "&#25298;&#32477;&#23454;&#39564;&#31508;&#35760;"
reopenButtonLabel = "&#37325;&#26032;&#25171;&#24320;&#23454;&#39564;&#31508;&#35760;"
witnessButtonLabel = "&#35265;&#35777;&#23454;&#39564;&#31508;&#35760;"
uploadReactionLabel = "&#19978;&#20256;&#21453;&#24212;&#25991;&#20214;"
quickViewLabel = "&#27010;&#35272;"
reactionConditionsLabel = "&#21453;&#24212;&#26465;&#20214;"
reactionPreparationLabel = "&#21453;&#24212;&#25805;&#20316;"
experimentLinksLabel = "&#38142;&#25509;&#33267;&#20854;&#20182;&#23454;&#39564;"
projectLinksLabel = "&#39033;&#30446;&#38142;&#25509;"
myProfileLabel = "&#20010;&#20154;&#36164;&#26009;"
inventoryLabel = "&#35814;&#32454;&#30446;&#24405;"
assayLabel = "&#27979;&#35797;"
registrationLabel = "&#27880;&#20876;"
myExperimentsLabel = "&#25105;&#30340;&#23454;&#39564;"
plateHistoryLabel = "&#26495;&#22359;&#21382;&#21490;"
addSaltLabel = "&#25104;&#30416;"
registerLabel = "&#27880;&#20876;"
searchLabel = "&#26597;&#25214;"
customFieldsLabel = "&#33258;&#23450;&#20041;&#22495;"
groupCustomFieldsLabel = "&#33258;&#23450;&#20041;&#22495;&#32452;"
adminApproveLabel = "&#27880;&#20876;&#25209;&#20934;"
mappingTemplatesLabel = "&#26144;&#23556;&#27169;&#29256;"
bulkRegistrationLabel = "&#25209;&#37327;&#27880;&#20876;"
bulkUpdateLabel = "&#25209;&#37327;&#26356;&#26032;"
SDRollbackLabel = "&#25209;&#37327;&#27880;&#20876;&#35760;&#24405;"
currentPasswordLabel = "&#24403;&#21069;&#23494;&#30721;"
newPasswordLabel = "&#26032;&#23494;&#30721;"
confirmPasswordLabel = "&#30830;&#35748;&#23494;&#30721;"
changePasswordLabel = "&#20462;&#25913;&#23494;&#30721;"
updateLabel = "&#26356;&#26032;"
chemicalEditorLabel = "Chemistry Drawing Tool"
defaultNumExperimentsInNotebooksLabel = "&#31508;&#35760;&#26412;&#23454;&#39564;&#21015;&#34920;&#25968;&#30446;"
defaultWitnessLabel = "&#40664;&#35748;&#35265;&#35777;&#29992;&#25143;"
addressLabel = "&#22320;&#22336;"
address1Label = "&#22320;&#22336;1"
address2Label = "&#22320;&#22336;2"
countryLabel = "&#22269;&#23478;"
userRoleLabel = "&#29992;&#25143;&#35282;&#33394;"
userGroupsLabel = "&#29992;&#25143;&#32452;"
userManagerLabel = "&#29992;&#25143;&#31649;&#29702;&#21592;"
notificationOnHomePageLabel = "&#36890;&#36807;&#20027;&#39029;&#36890;&#30693;"
notificationByEmailLabel = "&#30005;&#23376;&#37038;&#20214;&#25509;&#25910;&#36890;&#30693;"
preferencesLabel = "&#39318;&#36873;&#39033;"
createProjectLabel = "&#21019;&#24314;&#39033;&#30446;"
projectDescriptionLabel = "&#39033;&#30446;&#25551;&#36848;"
createNotebookLabel = "&#26032;&#24314;&#23454;&#39564;&#31508;&#35760;&#26412;"
notebookDescriptionLabel = "&#31508;&#35760;&#26412;&#25551;&#36848;"
selectNotebookLabel = "&#36873;&#25321;&#31508;&#35760;&#26412;"
experimentTypeLabel = "&#23454;&#39564;&#31867;&#22411;"
projectLabel = "&#39033;&#30446;"
ownerLabel = "&#25317;&#26377;&#32773;"
addTabLabel = "&#28155;&#21152;&#21306;"
shareThisProjectLabel = "&#20849;&#20139;&#27492;&#39033;&#30446;"
shareThisNotebookLabel = "&#20849;&#20139;&#27492;&#23454;&#39564;&#31508;&#35760;&#26412;"
numberOfUsersSelectedLabel = "&#36873;&#25321;&#30340;&#29992;&#25143;&#25968;"
numberOfGroupsSelectedLabel = "&#36873;&#25321;&#30340;&#32452;&#25968;"
readAccessLabelNotebook = "&#20801;&#35768;&#38405;&#35835;&#25152;&#26377;&#23454;&#39564;&#35760;&#24405;"
writeAccessLabelNotebook = "&#20801;&#35768;&#21019;&#24314;&#26032;&#30340;&#23454;&#39564;"
createExperimentLabel = "&#26032;&#24314;&#23454;&#39564;"
numberOfPagesToDisplayLabel = "&#26174;&#31034;&#39029;&#38754;&#25968;&#37327;"
changeLabel = "&#26356;&#25913;"
cancelLabel = "&#21462;&#28040;"
accessLabel = "&#26435;&#38480;"
sharedByLabel = "&#20849;&#20139;&#32773;"
requestCompoundsLabel = "&#35201;&#27714;&#21270;&#21512;&#29289;"
importProgressLabel = "&#23548;&#20837;&#36827;&#23637;"
addSketchLabel = "&#28155;&#21152;&#31616;&#22270;"
productsLabel = "&#20135;&#29289;"
notesTableLabel = "&#38468;&#27880;&#34920;"
annotateLabel = "&#35780;&#27880;"
addCommentLabel = "&#28155;&#21152;&#35780;&#35770;"
userProfileLabel = "&#29992;&#25143;&#20449;&#24687;"
searchTypeLabel = "&#26816;&#32034;&#31867;&#22411;"
resultsPerPageLabel = "&#27599;&#39029;&#23637;&#31034;&#32467;&#26524;&#25968;"
sortByLabel = "&#25490;&#24207;&#26041;&#24335;"
sortDirectionLabel = "&#25490;&#24207;&#26041;&#21521;"
viewLogsLabel = "&#26597;&#30475;&#26085;&#24535;"
viewLastLoginsLabel = "&#26597;&#30475;&#26368;&#21518;&#19968;&#27425;&#30331;&#24405;"
userLoginHistoryLabel = " &#29992;&#25143;&#30331;&#24405;&#21382;&#21490;&#35760;&#24405;"
defaultMolUnitsLabel = "&#40664;&#35748;Mol&#21333;&#20301;"
myUsersLabel = "&#25105;&#30340;&#29992;&#25143;"
searchOnlyMyExperimentsLabel = "&#20165;&#25628;&#32034;&#25105;&#30340;&#23454;&#39564;&#31508;&#35760;&#26412;"
sendWitnessRequestLabel = "&#21457;&#36865;&#35265;&#35777;&#35831;&#27714;"
experimentViewLabel = "&#26174;&#31034;&#23454;&#39564;&#25805;&#20316;&#39029;&#38754;"
addNextStepLabel = "&#26032;&#24314;&#19979;&#19968;&#27493;"
protocolLabel = "&#23454;&#39564;&#26041;&#26696;"
detailedDescriptionLabel = "&#35814;&#32454;&#25551;&#36848;"
accessOptionsLabel = "&#26435;&#38480;&#36873;&#39033;"
searchThisNotebookLabel = "&#25628;&#32034;&#27492;&#23454;&#39564;&#31508;&#35760;&#26412;"
createLabel = "&#21019;&#24314;"
addLabel = "&#28155;&#21152;"
shareLabel = "&#20849;&#20139;"
passwordLabel = "&#23494;&#30721;"
selectLabel = "&#36873;&#25321;"
nameLabel = "&#21517;&#31216;"
descriptionLabel = "&#25551;&#36848;"
downloadLabel = "Download"
removeLabel = "Remove"
replaceLabel = "Replace"
summaryReportLabel = "Operational Report Summary"
detailedReportLabel = "Detailed Operational Report"
ordersSubmitNewRequestLabel = "Submit New Request"
ordersManageRequestsLabel = "Manage Requests"
ordersUserSettingsLabel = "User Settings"
ordersDashboardLabel = "My Requests"
ordersManageDropDowns = "Configure Drop Downs"
ordersManageFields = "Configure Fields"
ordersManageRequestsTypes = "Configure Request Types"
ordersManageRequestItemTypes = "Configure Item Types"
enterInfotoCreateProjectLabel = "&#36755;&#20837;&#20197;&#19979;&#20449;&#24687;&#20197;&#21019;&#24314;&#26032;&#39033;&#30446;"
enterInfotoCreateNewNotebookLabel = "&#36755;&#20837;&#20197;&#19979;&#20449;&#24687;&#20197;&#21019;&#24314;&#26032;&#23454;&#39564;&#31508;&#35760;&#26412;"
assayDeleteFormWarning = "&#24744;&#30830;&#23450;&#35201;&#21024;&#38500;&#36825;&#20123;&#35745;&#31639;&#25968;&#25454;&#21527;&#65311;"
downloadAllPDFsLabel = "&#19979;&#36733;&#20840;&#37096;PDF&#25991;&#20214;"
groupFilterLabel = "&#31579;&#36873;&#22242;&#38431;"
advancedSearchHistoryLabel = "&#39640;&#32423;&#25628;&#32034;&#21382;&#21490;&#35760;&#24405;"
rowNumberLabel = "&#34892;&#25968;"
userNameLabel = "&#29992;&#25143;&#22995;&#21517;"
structureSearchesLabel = "&#32467;&#26500;&#24335;&#25628;&#32034;"
textSearchesLabel = "&#25991;&#23383;&#25628;&#32034;"
multiParamSearchesLabel = "&#22810;&#21442;&#25968;&#25628;&#32034;"
totalSearchesLabel = "&#20840;&#37096;&#25628;&#32034;"
exportAsCSVLabel = "&#23548;&#20986;&#32467;&#26524;&#21040;CSV&#25991;&#20214;"
locale = "zh"
loginDateAndTimeLabel = "&#30331;&#24405;&#26085;&#26399;&#21644;&#26102;&#38388;"
startDateLabel = "&#36215;&#22987;&#26085;&#26399;"
endDateLabel = "&#32456;&#27490;&#26085;&#26399;"
collaboratorsLabel = "&#21512;&#20316;&#32773;"
timesViewedLabel = "&#38405;&#35272;&#27425;&#25968;"
lastViewerLabel = "&#26368;&#21518;&#30340;&#26597;&#38405;&#32773;"
lastViewDateLabel = "&#26368;&#36817;&#19968;&#27425;&#26597;&#30475;&#26085;&#26399;"
collaboratorFilterLabel = "&#31579;&#36873;&#21512;&#20316;&#32773;"
viewerGroupFilterLabel = "&#31579;&#36873;&#26597;&#38405;&#32773;&#30340;&#22242;&#38431;"
viewAdvancedSearchHistoryLabel = "&#26597;&#30475;&#39640;&#32423;&#25628;&#32034;&#21382;&#21490;&#35760;&#24405;"
experimentViewHistoryLabel = "&#26597;&#38405;&#23454;&#39564;&#21382;&#21490;&#35760;&#24405;"
abandonLabel = "&#25918;&#24323;"
rejectAbandonRequestLabel = "&#25298;&#32477;&#25209;&#20934;&#25918;&#24323;&#30003;&#35831;"
approveAbandonRequestLabel = "&#25209;&#20934;&#25918;&#24323;&#30003;&#35831;"
pleaseEnterAReasonForRejectingAbandonRequestLabel = "&#35831;&#22635;&#20889;&#19981;&#25209;&#20934;&#25918;&#24323;&#30003;&#35831;&#30340;&#21407;&#22240; &#65288;&#24517;&#22635;&#65289;"
confirmAbandonRequestLabel = "&#30830;&#35748;&#25552;&#20132;&#25918;&#24323;&#30003;&#35831;"
witnessRequestRejectionLabel = "&#25298;&#32477;&#25209;&#20934;&#35265;&#35777;&#30003;&#35831;"
abandonRequestRejectionLabel = "&#25298;&#32477;&#25209;&#20934;&#25918;&#24323;&#30003;&#35831;"
experimentReopenedLabel = "&#37325;&#26032;&#24320;&#25918;&#30340;&#23454;&#39564;"
yourExperimentHasBeenReopenedLabel = "&#24744;&#30340;&#23454;&#39564;&#24050;&#32463;&#37325;&#26032;&#24320;&#25918;"
successLabel = "&#25104;&#21151;"
areYouSureLabel = "&#24744;&#30830;&#23450;&#21527;&#65311;"
onceAbandonedYouWillNotBeAbleToRecoverExperimentLabel = "&#19968;&#26086;&#25918;&#24323;&#65292;&#24744;&#23558;&#26080;&#27861;&#24674;&#22797;&#23454;&#39564;&#31508;&#35760;"
abandonRequestSubmittedLabel = "&#25918;&#24323;&#30003;&#35831;&#24050;&#25552;&#20132;"
experimentNotPursuedLabel = "&#25918;&#24323;&#23454;&#39564;"
experimentNotPursuedWarningLabel = "&#21246;&#36873;&#27492;&#26694;&#24182;&#36755;&#20837;&#23494;&#30721;&#34920;&#31034;&#24744;&#23558;&#19981;&#20877;&#32487;&#32493;&#27492;&#23454;&#39564;&#12290;&#27492;&#23454;&#39564;&#23558;&#19981;&#33021;&#20877;&#34987;&#32534;&#36753;&#12290;"
rejectNotPursuedLabel = "&#25298;&#32477;&#25918;&#24323;&#23454;&#39564;&#35831;&#27714;"
notPursuedReasonLabel = "&#35831;&#36755;&#20837;&#25298;&#32477;&#35813;&#25918;&#24323;&#23454;&#39564;&#35831;&#27714;&#30340;&#21407;&#22240;&#65288;&#24517;&#22635;&#65289;"
notPursuedVerificationErrorLabel = "&#24744;&#24517;&#39035;&#30830;&#35748;&#24744;&#20102;&#35299;&#8220;&#25918;&#24323;&#23454;&#39564;&#8221;&#30340;&#27969;&#31243;&#12290;"
selectWitnessLabel = "&#35831;&#36873;&#25321;&#19968;&#20301;&#35265;&#35777;&#20154;&#65292;"
notPursuedButtonLabel = "&#20013;&#27490;"


End select
languageJSON.Set "noneLabel", noneLabel
languageJSON.Set "searchForaProjectLabel", searchForaProjectLabel
languageJSON.Set "singleProjectLabel", singleProjectLabel
languageJSON.Set "requiredFieldLabel", requiredFieldLabel
languageJSON.Set "creatingLabel", creatingLabel
languageJSON.Set "fileSearchLabel", fileSearchLabel
languageJSON.Set "contactSupportLabel", contactSupportLabel
languageJSON.Set "welcomeLabel", welcomeLabel
languageJSON.Set "newNotificationsLabel", newNotificationsLabel
languageJSON.Set "watchlistLabel", watchlistLabel
languageJSON.Set "notebooksLabel", notebooksLabel
languageJSON.Set "projectsLabel", projectsLabel
languageJSON.Set "ordersNavHeading", ordersNavHeading
languageJSON.Set "helpLabel", helpLabel
languageJSON.Set "logoutLabel", logoutLabel
languageJSON.Set "arxlabToolsLabel", arxlabToolsLabel
languageJSON.Set "dashboardLabel", dashboardLabel
languageJSON.Set "manageUsersLabel", manageUsersLabel
languageJSON.Set "manageGroupsLabel", manageGroupsLabel
languageJSON.Set "userActivityLabel", userActivityLabel
languageJSON.Set "uploadReagentDatabaseLabel", uploadReagentDatabaseLabel
languageJSON.Set "chemicalSearchLabel", chemicalSearchLabel
languageJSON.Set "advancedSearchLabel", advancedSearchLabel
languageJSON.Set "recentlyViewedExperimentsLabel", recentlyViewedExperimentsLabel
languageJSON.Set "notificationsLabel", notificationsLabel
languageJSON.Set "notificationsLabel2", notificationsLabel2
languageJSON.Set "moreLabel", moreLabel
languageJSON.Set "detailsLabel", detailsLabel
languageJSON.Set "templatesLabel", templatesLabel
languageJSON.Set "customDropDownsLabel", customDropDownsLabel
languageJSON.Set "biologyProtocolTemplatesLabel", biologyProtocolTemplatesLabel
languageJSON.Set "biologySummaryTemplatesLabel", biologySummaryTemplatesLabel
languageJSON.Set "chemistryPreparationTemplatesLabel", chemistryPreparationTemplatesLabel
languageJSON.Set "conceptDescriptionTemplatesLabel", conceptDescriptionTemplatesLabel
languageJSON.Set "keywordEditorTemplatesLabel", keywordEditorTemplatesLabel
languageJSON.Set "invitationsLabel", invitationsLabel
languageJSON.Set "witnessRequestsLabel", witnessRequestsLabel
languageJSON.Set "witnessedByMeLabel", witnessedByMeLabel
languageJSON.Set "recentLabel", recentLabel
languageJSON.Set "newLabel", newLabel
languageJSON.Set "viewMoreLabel", viewMoreLabel
languageJSON.Set "viewAllLabel", viewAllLabel
languageJSON.Set "myNotebooksLabel", myNotebooksLabel
languageJSON.Set "sharedLabel", sharedLabel
languageJSON.Set "experimentsLabel", experimentsLabel
languageJSON.Set "currentLabel", currentLabel
languageJSON.Set "historyLabel", historyLabel
languageJSON.Set "experimentNameLabel", experimentNameLabel
languageJSON.Set "deleteLabel", deleteLabel
languageJSON.Set "deleteLabel2", deleteLabel2
languageJSON.Set "experimentDescriptionLabel", experimentDescriptionLabel
languageJSON.Set "experimentLabel", experimentLabel
languageJSON.Set "objectiveLabel", objectiveLabel
languageJSON.Set "summaryLabel", summaryLabel
languageJSON.Set "addFileLabel", addFileLabel
languageJSON.Set "addNoteLabel", addNoteLabel
languageJSON.Set "showArxlabHelpLabelHelpLabel", showArxlabHelpLabel
languageJSON.Set "sendSupportRequestLabel", sendSupportRequestLabel
languageJSON.Set "contactArxspanSupportLabel", contactArxspanSupportLabel
languageJSON.Set "firstNameLabel", firstNameLabel
languageJSON.Set "lastNameLabel", lastNameLabel
languageJSON.Set "emailLabel", emailLabel
languageJSON.Set "companyLabel", companyLabel
languageJSON.Set "subjectLabel", subjectLabel
languageJSON.Set "personsTitleLabel", personsTitleLabel
languageJSON.Set "phoneNumberLabel", phoneNumberLabel
languageJSON.Set "typeOfRequestLabel", typeOfRequestLabel
languageJSON.Set "requestLabel", requestLabel
languageJSON.Set "submitLabel", submitLabel
languageJSON.Set "pleaseSelectLabel", pleaseSelectLabel
languageJSON.Set "somethingIsNotWorkingLabel", somethingIsNotWorkingLabel
languageJSON.Set "iNeedHelpDoingSomethingLabel", iNeedHelpDoingSomethingLabel
languageJSON.Set "newFeatureRequestLabel", newFeatureRequestLabel
languageJSON.Set "otherLabel", otherLabel
languageJSON.Set "lastViewedLabel", lastViewedLabel
languageJSON.Set "creatorLabel", creatorLabel
languageJSON.Set "dateCreatedLabel", dateCreatedLabel
languageJSON.Set "dateLastModifiedLabel", dateLastModifiedLabel
languageJSON.Set "typeLabel", typeLabel
languageJSON.Set "statusLabel", statusLabel
languageJSON.Set "grantSharingPermissionLabel", grantSharingPermissionLabel
languageJSON.Set "closeWindowLabel", closeWindowLabel
languageJSON.Set "chemistryExperimentLabel", chemistryExperimentLabel
languageJSON.Set "biologyExperimentLabel", biologyExperimentLabel
languageJSON.Set "conceptExperimentLabel", conceptExperimentLabel
languageJSON.Set "analExperimentLabel", analExperimentLabel
languageJSON.Set "reactionTabLabel", reactionTabLabel
languageJSON.Set "attachmentsTableLabel", attachmentsTableLabel
languageJSON.Set "saveButtonLabel", saveButtonLabel
languageJSON.Set "showPdfVersionButtonLabel", showPdfVersionButtonLabel
languageJSON.Set "copyExperimentButtonLabel", copyExperimentButtonLabel
languageJSON.Set "moveExperimentButtonLabel", moveExperimentButtonLabel
languageJSON.Set "signExperimentButtonLabel", signExperimentButtonLabel
languageJSON.Set "rejectButtonLabel", rejectButtonLabel
languageJSON.Set "reopenButtonLabel", reopenButtonLabel
languageJSON.Set "witnessButtonLabel", witnessButtonLabel
languageJSON.Set "uploadReactionLabel", uploadReactionLabel
languageJSON.Set "quickViewLabel", quickViewLabel
languageJSON.Set "reactionConditionsLabel", reactionConditionsLabel
languageJSON.Set "reactionPreparationLabel", reactionPreparationLabel
languageJSON.Set "experimentLinksLabel", experimentLinksLabel
languageJSON.Set "projectLinksLabel", projectLinksLabel
languageJSON.Set "myProfileLabel", myProfileLabel
languageJSON.Set "inventoryLabel", inventoryLabel
languageJSON.Set "assayLabel", assayLabel
languageJSON.Set "registrationLabel", registrationLabel
languageJSON.Set "myExperimentsLabel", myExperimentsLabel
languageJSON.Set "plateHistoryLabel", plateHistoryLabel
languageJSON.Set "addSaltLabel", addSaltLabel
languageJSON.Set "registerLabel", registerLabel
languageJSON.Set "searchLabel", searchLabel
languageJSON.Set "customFieldsLabel", customFieldsLabel
languageJSON.Set "groupCustomFieldsLabel", groupCustomFieldsLabel
languageJSON.Set "adminApproveLabel", adminApproveLabel
languageJSON.Set "mappingTemplatesLabel", mappingTemplatesLabel
languageJSON.Set "bulkRegistrationLabel", bulkRegistrationLabel
languageJSON.Set "bulkUpdateLabel", bulkUpdateLabel
languageJSON.Set "SDRollbackLabel", SDRollbackLabel
languageJSON.Set "currentPasswordLabel", currentPasswordLabel
languageJSON.Set "newPasswordLabel", newPasswordLabel
languageJSON.Set "confirmPasswordLabel", confirmPasswordLabel
languageJSON.Set "changePasswordLabel", changePasswordLabel
languageJSON.Set "updateLabel", updateLabel
languageJSON.Set "chemicalEditorLabel", chemicalEditorLabel
languageJSON.Set "defaultNumExperimentsInNotebooksLabel", defaultNumExperimentsInNotebooksLabel
languageJSON.Set "defaultWitnessLabel", defaultWitnessLabel
languageJSON.Set "addressLabel", addressLabel
languageJSON.Set "address1Label", address1Label
languageJSON.Set "address2Label", address2Label
languageJSON.Set "countryLabel", countryLabel
languageJSON.Set "userRoleLabel", userRoleLabel
languageJSON.Set "userGroupsLabel", userGroupsLabel
languageJSON.Set "userManagerLabel", userManagerLabel
languageJSON.Set "notificationOnHomePageLabel", notificationOnHomePageLabel
languageJSON.Set "notificationByEmailLabel", notificationByEmailLabel
languageJSON.Set "preferencesLabel", preferencesLabel
languageJSON.Set "createProjectLabel", createProjectLabel
languageJSON.Set "projectDescriptionLabel", projectDescriptionLabel
languageJSON.Set "createNotebookLabel", createNotebookLabel
languageJSON.Set "notebookDescriptionLabel", notebookDescriptionLabel
languageJSON.Set "selectNotebookLabel", selectNotebookLabel
languageJSON.Set "experimentTypeLabel", experimentTypeLabel
languageJSON.Set "projectLabel", projectLabel
languageJSON.Set "ownerLabel", ownerLabel
languageJSON.Set "addTabLabel", addTabLabel
languageJSON.Set "shareThisProjectLabel", shareThisProjectLabel
languageJSON.Set "shareThisNotebookLabel", shareThisNotebookLabel
languageJSON.Set "numberOfUsersSelectedLabel", numberOfUsersSelectedLabel
languageJSON.Set "numberOfGroupsSelectedLabel", numberOfGroupsSelectedLabel
languageJSON.Set "readAccessLabelNotebook", readAccessLabelNotebook
languageJSON.Set "writeAccessLabelNotebook", writeAccessLabelNotebook
languageJSON.Set "createExperimentLabel", createExperimentLabel
languageJSON.Set "numberOfPagesToDisplayLabel", numberOfPagesToDisplayLabel
languageJSON.Set "changeLabel", changeLabel
languageJSON.Set "cancelLabel", cancelLabel
languageJSON.Set "accessLabel", accessLabel
languageJSON.Set "sharedByLabel", sharedByLabel
languageJSON.Set "requestCompoundsLabel", requestCompoundsLabel
languageJSON.Set "importProgressLabel", importProgressLabel
languageJSON.Set "addSketchLabel", addSketchLabel
languageJSON.Set "productsLabel", productsLabel
languageJSON.Set "notesTableLabel", notesTableLabel
languageJSON.Set "annotateLabel", annotateLabel
languageJSON.Set "addCommentLabel", addCommentLabel
languageJSON.Set "userProfileLabel", userProfileLabel
languageJSON.Set "searchTypeLabel", searchTypeLabel
languageJSON.Set "resultsPerPageLabel", resultsPerPageLabel
languageJSON.Set "sortByLabel", sortByLabel
languageJSON.Set "sortDirectionLabel", sortDirectionLabel
languageJSON.Set "viewLogsLabel", viewLogsLabel
languageJSON.Set "viewLastLoginsLabel", viewLastLoginsLabel
languageJSON.Set "userLoginHistoryLabel", userLoginHistoryLabel
languageJSON.Set "defaultMolUnitsLabel", defaultMolUnitsLabel
languageJSON.Set "myUsersLabel", myUsersLabel
languageJSON.Set "searchOnlyMyExperimentsLabel", searchOnlyMyExperimentsLabel
languageJSON.Set "sendWitnessRequestLabel", sendWitnessRequestLabel
languageJSON.Set "experimentViewLabel", experimentViewLabel
languageJSON.Set "addNextStepLabel", addNextStepLabel
languageJSON.Set "protocolLabel", protocolLabel
languageJSON.Set "detailedDescriptionLabel", detailedDescriptionLabel
languageJSON.Set "accessOptionsLabel", accessOptionsLabel
languageJSON.Set "searchThisNotebookLabel", searchThisNotebookLabel
languageJSON.Set "createLabel", createLabel
languageJSON.Set "addLabel", addLabel
languageJSON.Set "shareLabel", shareLabel
languageJSON.Set "passwordLabel", passwordLabel
languageJSON.Set "selectLabel", selectLabel
languageJSON.Set "nameLabel", nameLabel
languageJSON.Set "descriptionLabel", descriptionLabel
languageJSON.Set "downloadLabel", downloadLabel
languageJSON.Set "removeLabel", removeLabel
languageJSON.Set "replaceLabel", replaceLabel
languageJSON.Set "summaryReportLabel", summaryReportLabel
languageJSON.Set "detailedReportLabel", detailedReportLabel
languageJSON.Set "ordersSubmitNewRequestLabel", ordersSubmitNewRequestLabel
languageJSON.Set "ordersManageRequestsLabel", ordersManageRequestsLabel
languageJSON.Set "ordersUserSettingsLabel", ordersUserSettingsLabel
languageJSON.Set "ordersDashboardLabel", ordersDashboardLabel
languageJSON.Set "ordersManageDropDowns", ordersManageDropDowns
languageJSON.Set "ordersManageFields", ordersManageFields
languageJSON.Set "ordersManageRequestsTypes", ordersManageRequestsTypes
languageJSON.Set "ordersManageRequestItemTypes", ordersManageRequestItemTypes
languageJSON.Set "enterInfotoCreateProjectLabel", enterInfotoCreateProjectLabel
languageJSON.Set "enterInfotoCreateNewNotebookLabel", enterInfotoCreateNewNotebookLabel
languageJSON.Set "groupFilterLabel", groupFilterLabel
languageJSON.Set "advancedSearchHistoryLabel", advancedSearchHistoryLabel
languageJSON.Set "rowNumberLabel", rowNumberLabel
languageJSON.Set "userNameLabel", userNameLabel
languageJSON.Set "structureSearchesLabel", structureSearchesLabel
languageJSON.Set "textSearchesLabel", textSearchesLabel
languageJSON.Set "multiParamSearchesLabel", multiParamSearchesLabel
languageJSON.Set "totalSearchesLabel", totalSearchesLabel
languageJSON.Set "exportAsCSVLabel", exportAsCSVLabel
languageJSON.Set "locale", locale
languageJSON.Set "loginDateAndTimeLabel", loginDateAndTimeLabel
languageJSON.Set "startDateLabel", startDateLabel
languageJSON.Set "endDateLabel", endDateLabel
languageJSON.Set "collaboratorsLabel", collaboratorsLabel
languageJSON.Set "timesViewedLabel", timesViewedLabel
languageJSON.Set "lastViewerLabel", lastViewerLabel
languageJSON.Set "lastViewDateLabel", lastViewDateLabel
languageJSON.Set "collaboratorFilterLabel", collaboratorFilterLabel
languageJSON.Set "viewerGroupFilterLabel", viewerGroupFilterLabel
languageJSON.Set "viewAdvancedSearchHistoryLabel", viewAdvancedSearchHistoryLabel
languageJSON.Set "experimentViewHistoryLabel", experimentViewHistoryLabel
languageJSON.Set "rejectAbandonRequestLabel", rejectAbandonRequestLabel
languageJSON.Set "approveAbandonRequestLabel", approveAbandonRequestLabel
languageJSON.Set "rejectAbandonRequestLabel", rejectAbandonRequestLabel
languageJSON.Set "pleaseEnterAReasonForRejectingAbandonRequestLabel", pleaseEnterAReasonForRejectingAbandonRequestLabel
languageJSON.Set "confirmAbandonRequestLabel", confirmAbandonRequestLabel
languageJSON.Set "witnessRequestRejectionLabel", witnessRequestRejectionLabel
languageJSON.Set "abandonRequestRejectionLabel", abandonRequestRejectionLabel
languageJSON.Set "experimentReopenedLabel", experimentReopenedLabel
languageJSON.Set "yourExperimentHasBeenReopenedLabel", yourExperimentHasBeenReopenedLabel
languageJSON.Set "successLabel", successLabel
languageJSON.Set "areYouSureLabel", areYouSureLabel
languageJSON.Set "onceAbandonedYouWillNotBeAbleToRecoverExperimentLabel", onceAbandonedYouWillNotBeAbleToRecoverExperimentLabel
languageJSON.Set "abandonRequestSubmittedLabel", abandonRequestSubmittedLabel

%>
<!-- #include file="__companyFeatures.asp"-->
