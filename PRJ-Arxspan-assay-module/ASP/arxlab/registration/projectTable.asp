<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%sectionId="reg"%>
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->



<%
Const dbName = 0
Const sortDbName = 1
Const displayName = 2
Const sortable = 3
Const doDisplay = 4
Const htmlTrans = 5

Dim fields()

reDim fields(7)
fields(0) = split("molecule:::false:true:",":")
fields(1) = Split("reg_id:reg_id:Reg Number:true:true:",":")
fields(2) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
fields(3) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")
fields(4) = split("just_batch:::false:false:",":")
fields(5) = split("just_reg:::false:false:",":")
fields(6) = split("groupId:::false:false:",":")
fields(7) = split("cd_id:::false:false:",":")

regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
tableStrQuery = "SELECT * FROM "&regMoleculesTable&" WHERE cd_id in ("&cdIdList&")"

whichTable = regMoleculesTable
defaultSort = "cd_timestamp"
defaultSortDirection = "DESC"
If inframe then
pageName = "show-project.asp?id="&request.querystring("parentId")
Else
pageName = "show-project.asp?id="&request.querystring("id")
End if
defaultRpp = 8
noSort = false
%>
	<!-- #INCLUDE file="_inclds/chemTable.asp" -->