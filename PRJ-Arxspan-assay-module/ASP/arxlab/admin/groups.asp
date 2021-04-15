<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<%
sectionId = "tool"
subSectionId = "groups"
pageTitle = "Arxspan Manage Groups"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
hasGroupAutosharing = getCompanySpecificSingleAppConfigSetting("hasGroupAutosharing", session("companyId"))
If session("roleNumber") <> "1" And session("roleNumber") <> "0" Then
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
Dim fields()
If hasGroupAutosharing = 1 then
	reDim fields(3)
End if
fields(0) = split("id:pageId:text:Id:Id:number:none:false:false:false:true:false:$userId$:",":")
fields(1) = Split("name:name:text:Name:Name:text:none:true:true:true:true:true::",":")
fields(2) = split("none:userId:select*usersView*id*fullName****groupMembers*groupId*userId:Users:Users:number:none:false:true:false:true:true::@:",":")
If hasGroupAutosharing = 1 then
	fields(3) = split("none:autoShareGroupId:select*groups*id*name****groupAutoShare*groupId*shareToGroupId:Auto Share Groups:Auto Share Groups:number:none:false:true:false:true:true::@:",":")
End if
'editScroll = "false"
'noList = "true"
'redirect = "true"
'hideDelete = "true"
'hideExpander = "true"
dateCreatedKey = "none"
updateKey = "id"
deleteKey = "id"
defaultSort = "id"
tableName = "groups"
viewName = "groups"
handleClickId = "id"
tableTitle = "Groups"
addNewItemText = "Add a New Group"
addButtonText = "Add Group"

globalFilterKey = "companyId"
globalFilterValue = session("companyId")

'inline | table
addNewDisplay = "table"

pageAddItemEnabled = "true"
pageSearchEnabled = "false"

pageTitle = "Arxspan Manage Groups"
%>

<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->
<div id="xtranetDiv"">
<h1>Groups</h1>

<!-- #INCLUDE virtual="/arxlab/admin/cmshead.asp" -->
<!-- #INCLUDE virtual="/arxlab/admin/cmsbody.asp" -->
</div>
</div>
<!--#include file="../_inclds/footer-tool.asp"-->
