<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<%
sectionId = "reg"
subSectionId = "sd-rollback"
%>


<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<div class="registrationPage">
<h1>Bulk Reg Files</h1>
<%
Const dbName = 0
Const sortDbName = 1
Const displayName = 2
Const sortable = 3
Const doDisplay = 4
Const htmlTrans = 5

Dim fields()

reDim fields(6)
fields(0) = split("id:id:id:false:false:",":")
fields(1) = split("userName:userName:User Name:true:true:",":")
fields(2) = split("sdFilename:sdFilename:SD Filename:true:true:",":")
If session("useGMT") Then
	fields(3) = split("dateCreatedUTC:dateCreatedUTC:Date Created:true:true:",":")
else
	fields(3) = split("dateCreated:dateCreated:Date Created:true:true:",":")
End if
fields(4) = split("id:id::false:true:Rollback&#58; <a href='SDRollbackStart.asp?id=$id$&compounds=1&batches=0'>Compounds ($compoundCount$)</a> <a href='SDRollbackStart.asp?id=$id$&compounds=0&batches=1'>Batches ($batchCount$)</a> <a href='SDRollbackStart.asp?id=$id$&compounds=1&batches=1'>Both</a>" ,":")
fields(5) = split("batchCount:batchCount:batchCount:false:false:",":")
fields(6) = split("compoundCount:compoundCount:compoundCount:false:false:",":")

regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
If session("regRegistrarRestricted") then
	tableStrQuery = "SELECT sdImports.*,(SELECT count(*) FROM "&regMoleculesTable&" WHERE arxspan_sd_source_id=sdImports.id and just_batch<>'"&padWithZeros(0,regBatchNumberLength)&"') as batchCount,(SELECT count(*) FROM "&regMoleculesTable&" WHERE arxspan_sd_source_id=sdImports.id and just_batch='"&padWithZeros(0,regBatchNumberLength)&"') as compoundCount FROM sdImports WHERE userId="&SQLClean(session("userId"),"N","S")
Else
	tableStrQuery = "SELECT sdImports.*,(SELECT count(*) FROM "&regMoleculesTable&" WHERE arxspan_sd_source_id=sdImports.id and just_batch<>'"&padWithZeros(0,regBatchNumberLength)&"') as batchCount,(SELECT count(*) FROM "&regMoleculesTable&" WHERE arxspan_sd_source_id=sdImports.id and just_batch='"&padWithZeros(0,regBatchNumberLength)&"') as compoundCount FROM sdImports"
End if

whichTable = "sdImports"
If session("useGMT") Then
	defaultSort = "dateCreatedUTC"
else
	defaultSort = "dateCreated"
End if
defaultSortDirection = "DESC"
pageName = "SDRollback.asp?a=1"
forceNoMolecule = True
defaultRpp = 15
%>
	<!-- #INCLUDE file="_inclds/chemTable2.asp" -->
</div>
<!-- #include file="../_inclds/footer-tool.asp"-->