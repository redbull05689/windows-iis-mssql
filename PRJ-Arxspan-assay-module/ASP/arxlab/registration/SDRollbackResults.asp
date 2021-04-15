<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.scripttimeout=180%>
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
sectionId = "reg"
subSectionId = "search"
regSearchResultsPage = true
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))

if (Not (session("regRegistrar") Or session("regUser")) Or session("regRestrictedUser")) Then
	response.redirect("logout.asp")
End If

whatToDelete = request.querystring("type")
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<div class="registrationPage">
<h1>Confirm Bulk Registration Rollback</h1>
<p>
<%Select case request.querystring("m")%>
<%Case "1"
	whatToDelete = "batches AND compounds"
%>
The following batches AND compounds will be deleted from this SD file.
<%Case "2"%>
The following <%=whatToDelete%> will be deleted.
<%End select%>
<form method="POST" action="SDRollbackDelete.asp?id=<%=request.querystring("id")%>" onsubmit="return confirm('Are you sure you wish to delete these <%=whatToDelete%>?');">
	<input type="SUBMIT" value="DELETE RECORDS">
</form>
</p>
<%
Const dbName = 0
Const sortDbName = 1
Const displayName = 2
Const sortable = 3
Const doDisplay = 4
Const htmlTrans = 5

Dim fields()
reDim fields(8)
fields(0) = split("molecule:::false:true:",":")
fields(1) = Split("reg_id:reg_id:Reg Number:true:true:",":")
fields(2) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
fields(3) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")
fields(4) = split("source:source:Source:true:true:",":")
fields(5) = split("just_batch:::false:false:",":")
fields(6) = split("just_reg:::false:false:",":")
fields(7) = split("groupId:::false:false:",":")
fields(8) = split("cd_id:::false:false:",":")

If session("rollBackCdIds") = "" Then
	tableStrQuery = "SELECT * FROM "&regMoleculesTable&" WHERE 1=2"
Else
	Dim i
	cdIdArray = Split(session("rollbackCdids"),",")
	rollbackCdIdStr = "("
	For i=0 To UBound(cdIdArray)
		If i Mod 999 = 0 Then
			If i<>0 Then 
				rollbackCdIdStr = rollbackCdIdStr & ") or "
			End If
			rollbackCdIdStr = rollbackCdIdStr & "cd_id in ("
		End If
		rollbackCdIdStr = rollbackCdIdStr & cdIdArray(i)
		If i <> UBound(cdIdArray) And (i + 1) Mod 999 > 0 Then
			rollbackCdIdStr = rollbackCdIdStr & ","
		End If
	Next
	rollbackCdidStr = rollbackCdIdStr & "))"
	session("rollbackCdidStr") = rollbackCdidStr
	tableStrQuery = "SELECT * FROM "&regMoleculesTable&" WHERE "&rollbackCdIdStr
End if

whichTable = regMoleculesTable
defaultSort = "cd_timestamp"
defaultSortDirection = "DESC"
pageName = "SDRollBackResults.asp?m="&request.querystring("m")&"&id="&request.querystring("id")
defaultRpp = 5
%>
	<!-- #INCLUDE file="_inclds/chemTable.asp" -->

</div>
	<!-- #include file="../_inclds/footer-tool.asp"-->