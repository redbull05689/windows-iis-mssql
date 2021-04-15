<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<%
sectionId = "reg"
subSectionId = "show-salts"

if Not (session("regRegistrar") Or session("regUser")) Then
	response.redirect("logout.asp")
End If
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<div class="registrationPage">

<h2>Salts</h2>
<%
Const dbName = 0
Const sortDbName = 1
Const displayName = 2
Const sortable = 3
Const doDisplay = 4
Const htmlTrans = 5

Dim fields()

reDim fields(4)
fields(0) = split("molecule:::false:true:",":")
fields(1) = Split("name:name:Name:true:true:",":")
fields(2) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
fields(3) = split("salt_code:salt_code:Code:true:true:",":")
fields(4) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")

regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
tableStrQuery = "SELECT * FROM "&regSaltsTable

whichTable = regSaltsTable
defaultSort = "cd_timestamp"
defaultSortDirection = "DESC"
pageName = "viewSalts.asp?"
defaultRpp = 5
%>
	<!-- #INCLUDE file="_inclds/chemTable.asp" -->
</div>
<!-- #include file="../_inclds/footer-tool.asp"-->