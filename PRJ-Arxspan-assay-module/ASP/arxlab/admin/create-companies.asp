<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "tool"
subSectionId = "create-companies"
pageTitle = "Arxspan Create Companies"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
If session("roleNumber") <> 0 Then
	response.redirect(loginScriptName)
End if
%>

<%
Const dbName = 0
Const formName = 1
Const formType = 2
Const formLabel = 3
Const listLabel = 4
Const sqlType = 5
Const validationFunction = 6
Const searchEnabled = 7
Const addEnabled = 8
Const listEnabled = 9
Const sortEnabled = 10
Const editEnabled = 11
Const HTML = 12
Const dispSQL = 13
Const defaultValue = 14

'config setup
'412015
Dim fields(59) ' If this is too big, the whole script dies. Make sure it's right.
'/412015
fields(0) = split("id:pageId:text:Id:Id:number:none:false:false:false:true:false:$userId$::",":")
fields(1) = split("name:name:text:Name*:Name:text:notEmpty:true:true:true:true:true:$userId$::",":")
fields(2) = split("expirationDate:expirationDate:text:Expiration Date:Expiration Date:text:none:false:true:true:true:true:$userId$::",":")
fields(3) = split("disabled:disabled:select*yesno*num*display:Disabled:Disabled:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(4) = split("passwordRegEx:passwordRegEx:text:Password Regex:Password Regex:text:none:true:true:false:false:true:::^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$",":")
fields(5) = split("passwordMessage:passwordMessage:text:Password Message:Password Message:text:none:true:true:false:false:true:::Minimum eight characters, at least one letter and one number",":")
fields(6) = split("hasReg:hasReg:select*yesno*num*display:Registration:Registration:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(7) = split("hasInv:hasInv:select*yesno*num*display:Inventory:Inventory:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(8) = split("hasAssay:hasAssay:select*yesno*num*display:Assay:Assay:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(9) = split("hasRegApi:hasRegApi:select*yesno*num*display:Reg API:Reg API:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(10) = split("hasELN:hasELN:select*yesno*num*display:ELN:ELN:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
fields(11) = split("redirectToSignedPDF:redirectToSignedPDF:select*yesno*num*display:Redirect to PDF:Redirect to PDF:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
fields(12) = split("autoNotebookNumber:autoNotebookNumber:select*yesno*num*display:Auto Number Notebook:Auto Number Notebook:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
fields(13) = split("autoNotebookPrefix:autoNotebookPrefix:text:Notebook Prefix:Notebook Prefix:text:none:true:true:false:false:true:$userId$::ARX",":")
fields(14) = split("autoNotebookStartNumber:autoNotebookStartNumber:text:Notebook Start Number:Notebook Start Number:number:none:true:true:false:false:true:$userId$::0",":")
fields(15) = split("autoNotebookNumDigits:autoNotebookNumDigits:text:Notebook Num Digits:Notebook Num Digits:text:none:true:true:false:false:true:$userId$::6",":")
fields(16) = split("autoSaveOnUnload:autoSaveOnUnload:select*yesno*num*display:Auto Save On Unload:Auto Save On Unload:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:1",":")
fields(17) = split("canChangeExperimentNames:canChangeExperimentNames:select*yesno*num*display:Can Change Experiment Names:Can Change Experiment Names:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(18) = split("showFullChemicalNameInQuickView:showFullChemicalNameInQuickView:select*yesno*num*display:Full Chemical Name in Quick View:Full Chemical Name in Quick View:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(19) = split("requireProjectLink:requireProjectLink:select*yesno*num*display:Require Project Link:requireProjectLink:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(20) = split("requireProjectLinkForNB:requireProjectLinkForNB:select*yesno*num*display:Require Project Link For Notebook:requireProjectLink:number:notEmpty:false:true:false:false:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(21) = split("autoApproveReg:autoApproveReg:select*yesno*num*display:autoApproveReg:autoApproveReg:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(22) = split("hasAccordInt:hasAccordInt:select*yesno*num*display:hasAccordInt:hasAccordInt:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(23) = split("registerFromBio:registerFromBio:select*yesno*num*display:Register From Bio Expt:Register From Bio Expt:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(24) = split("hasInventoryIntegration:hasInventoryIntegration:select*yesno*num*display:hasInventoryIntegration:hasInventoryIntegration:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(25) = split("useSafe:useSafe:select*yesno*num*display:Use Safe:Use Safe:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(26) = split("useGoogleSign:useGoogleSign:select*yesno*num*display:Use Google Sign:Use Google Sign:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(27) = split("barcodeLength:barcodeLength:text:Barcode Length:Barcode Length:text:none:true:true:false:false:true:::10",":")
fields(28) = split("hasGroupFields:hasGroupFields:select*yesno*num*display:Has Group Fields:Has Group Fields:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(29) = split("ipBlock:ipBlock:select*yesno*num*display:IP Block:IP Block:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(30) = split("ipRanges:ipRanges:text:IP Ranges:IP Ranges:text:none:false:true:false:true:true:$userId$::0.0.0.0",":")
fields(31) = split("hasChemistry:hasChemistry:select*yesno*num*display:Has Chemistry:Has Chemistry:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(32) = split("canChangeHasChemistry:canChangeHasChemistry:select*yesno*num*display:Can Set Chemistry Enabled:Can Set Chemistry Enabled:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(33) = split("ccAdminsOnSupport:ccAdminsOnSupport:select*yesno*num*display:CC admins on support reqs:CC admins on support reqs:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(34) = split("limitLoginAttempts:limitLoginAttempts:select*yesno*num*display:Limit Login Attempts:Limit Login Attempts:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(35) = split("maxLoginAttempts:maxLoginAttempts:text:Max Login Attempts:Max Login Attempts:number:none:true:true:false:false:true:::15",":")
fields(36) = split("useGMT:useGMT:select*yesno*num*display:Use GMT:Use GMT:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(37) = split("requirePasswordChange:requirePasswordChange:select*yesno*num*display:Require Password Change:Require Password Change:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(38) = split("requirePasswordChangeDays:requirePasswordChangeDays:text:Password Change Days:Password Change Days:number:none:true:true:false:false:true:::60",":")
fields(39) = split("sessionTimeout:sessionTimeout:select*yesno*num*display:Session Timeout:Session Timeout:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(40) = split("sessionTimeoutMinutes:sessionTimeoutMinutes:text:Session Timeout Minutes:Session Timeout Minutes:number:none:false:true:false:false:true:::60",":")
'412015
fields(41) = split("hasCrais:hasCrais:select*yesno*num*display:Crais Integration:Crais Integration:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(42) = split("hasProductsSD:hasProductsSD:select*yesno*num*display:Products SD Download:Products SD Download:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(43) = split("hasCompoundTracking:hasCompoundTracking:select*yesno*num*display:Compound Tracking:Compound Tracking:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(44) = split("companyHasFT:companyHasFT:select*yesno*num*display:Has FT:Has FT:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(45) = split("FTDB:FTDB:text:FT Database:FT Database:text:none:true:true:false:false:true:false:$userId$:",":")
fields(46) = split("companyHasFTLiteAssay:companyHasFTLiteAssay:select*yesno*num*display:Has FT Lite Assay:Has FT Lite Assay:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(47) = split("FTDBLiteAssay:FTDBLiteAssay:text:FT Lite Assay Database:FT Lite Assay Database:text:none:true:true:false:false:true:false:$userId$:",":")
fields(48) = split("companyHasFTLiteInventory:companyHasFTLiteInventory:select*yesno*num*display:Has FT Lite Inventory:Has FT Lite Inventory:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(49) = split("FTDBLiteInventory:FTDBLiteInventory:text:FT Lite Inventory Database:FT Lite Inventory Database:text:none:true:true:false:false:true:false:$userId$:",":")
fields(50) = split("companyHasFTLiteReg:companyHasFTLiteReg:select*yesno*num*display:Has FT Lite Reg:Has FT Lite Reg:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(51) = split("FTDBLiteReg:FTDBLiteReg:text:FT Lite Reg Database:FT Lite Reg Database:text:none:true:true:false:false:true:false:$userId$:",":")
fields(52) = split("hasShortPdf:hasShortPdf:select*yesno*num*display:Short PDF:Short PDF:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
'muf also change the ubound up top
fields(53) = split("hasMUFExperiment:hasMUFExperiment:select*yesno*num*display:Has Multi User Experiment:Has Multi User Experiment:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(54) = split("hideNonCollabExperiments:hideNonCollabExperiments:select*yesno*num*display:Hide Non-collab expts:Hide Non-collab expts:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(55) = split("hasBarcodeChooser:hasBarcodeChooser:select*yesno*num*display:Has Barcode Chooser:Has Barcode Chooser:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(56) = split("hasD2S:hasD2S:select*yesno*num*display:Has Document to Structure:Has Document to Structure:number:notEmpty:false:true:true:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(57) = split("logoutRedirectUrl:logoutRedirectUrl:text:Logout Redirect URL:Logout Redirect Url:text:none:true:true:false:false:true:::",":")
fields(58) = split("companyHasMarvin:companyHasMarvin:select*yesno*num*display:Has Marvin:Has Marvin:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
fields(59) = split("hasOrdering:hasOrdering:select*yesno*num*display:Has Workflow:Has Workflow:number:notEmpty:false:true:false:true:true:$state$:display*select display from yesno where num=$enabled$:0",":")
'/412015
'editScroll = "false"
'noList = "true"
'redirect = "true"
'hideDelete = "true"
'hideExpander = "true"
'dateCreatedKey = "dateOfSignup"
updateKey = "id"
deleteKey = "id"
defaultSort = "id"
tableName = "companies"
viewName = "companies"
handleClickId = "id"
tableTitle = "Companies"
addNewItemText = "Add a New Company"
addButtonText = "Add Company"

viewExtra = "(disabled=0 or disabled is null)"

'globalFilterKey = "companyId"
'globalFilterValue = session("companyId")

'inline | table
addNewDisplay = "table"

pageAddItemEnabled = "true"
pageSearchEnabled = "true"

pageTitle = "Companies "
%>

<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->
<div id="xtranetDiv">
<h1>Companies</h1>

<!-- #INCLUDE virtual="/arxlab/admin/cmshead.asp" -->
<!-- #INCLUDE virtual="/arxlab/admin/cmsbody.asp" -->
</div>
</div>
<!--#include file="../_inclds/footer-tool.asp"-->

<%
if recordAdded = true then
%>
	<!-- #include file="../_inclds/misc/functions/fnc_initPrepTemplates.asp" -->
<%
	companyId = CStr(newId)
	Call getconnectedadm
	connAdm.execute("INSERT INTO apiKeys (companyId, apiKey, allowedIpList) VALUES("&SQLClean(companyId,"N","S")&",NEWID(),'8.20.189.169,71.192.175.210,100.0.175.27,8.20.189.59,8.20.189.188')")
	initPrepTemplates(companyId)
	disconnectAdm
end If
%>