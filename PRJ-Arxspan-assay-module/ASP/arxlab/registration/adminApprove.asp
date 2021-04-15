<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include file="_inclds/fnc_regChangeStatus.asp"-->
<!-- #include file="_inclds/fnc_removeCdIdsFromFT.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
sectionId = "reg"
subSectionId = "admin-approve"
if Not session("regRegistrar") Or session("regRegistrarRestricted") Then
	response.redirect("logout.asp")
End If
%>

<%
If request.Form("approveSubmit") <> "" Then
	call getconnectedJchemReg
	cdIds = Split(request.Form("cdIds"),",")
	For z = 0 To UBound(cdIds)
		thisCdId = cdIds(z)
		If request.Form("check_"&thisCdId) = "on" then
			a = regChangeStatus("approve",thisCdId)
		End if
	Next
	call disconnectJchemReg
End If
If request.Form("deleteSubmit") <> "" Then
	call getconnectedJchemReg
	cdIds = Split(request.Form("cdIds"),",")
	For z = 0 To UBound(cdIds)
		thisCdId = cdIds(z)
		If request.Form("check_"&thisCdId) = "on" then	
			a = removeCdIdsFromFT(thisCdId) 	' remove the cd id records from FT
			b = regChangeStatus("delete",thisCdId) 	' remove the cd id records from Reg
		End if
	Next
	call disconnectJchemReg
End if
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<div class="registrationPage">
<h1>Unapproved Records</h1>
<%
Const dbName = 0
Const sortDbName = 1
Const displayName = 2
Const sortable = 3
Const doDisplay = 4
Const htmlTrans = 5

Dim fields()

reDim fields(10)
fields(0) = split("molecule:::false:true:",":")
fields(1) = Split("reg_id:reg_id:Reg Number:true:true:",":")
fields(2) = split("user_name:user_name:User:true:true:",":")
fields(3) = split("date_created:cd_timestamp:Date Created:true:true:",":")
fields(4) = split("source:source:Source:true:true:",":")
fields(5) = split("just_batch:::false:false:",":")
fields(6) = split("just_reg:::false:false:",":")
fields(7) = split("cd_id:::false:true:<input type='checkbox' name='check_$cd_id$'>",":")
fields(8) = split("experiment_id:::false:false:",":")
fields(9) = split("revision_number:::false:false:",":")
fields(10) = split("experiment_name:::false:false:",":")
fields(10) = split("groupId:::false:false:",":")

regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
tableStrQuery = "SELECT * FROM "&regMoleculesTable&" WHERE (is_permanent is null or is_permanent=0) and (status_id <> 2 or status_id is null)"
whichTable = regMoleculesTable
defaultSort = "cd_timestamp"
defaultSortDirection = "DESC"
pageName = "adminApprove.asp?a=1"
defaultRpp = 10
queryMol = ""
searchType = "SUBSTRUCTURE"'session("regSearchType")
%>
<form method="POST" action="adminApprove.asp">
	<div id="unapprovedTable">
	<!-- #INCLUDE file="_inclds/chemTable.asp" -->
	</div>
<input type="hidden" name="cdIds" value="<%=Replace(Trim(theCdIds)," ",",")%>">
<%If Not noResults then%>
<input type="submit" name="approveSubmit" value="APPROVE SELECTED">
<input type="submit" name="deleteSubmit" value="DELETE SELECTED" onclick="return confirm('Are you sure you wish to delete the selected items?')">
<%End if%>
</form>
</div>
	<!-- #include file="../_inclds/footer-tool.asp"-->