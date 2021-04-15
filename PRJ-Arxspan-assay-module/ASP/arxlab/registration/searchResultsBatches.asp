<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->

<%
sectionId = "reg"
subSectionId = "search"
regSearchResultsBatches = True
batchesRegNumber = request.querystring("regNumber")
batchParentCdId = request.querystring("cdId")

if (Not (session("regRegistrar") Or session("regUser")) Or session("regRestrictedUser")) Then
	response.redirect("logout.asp")
End If

If request.querystring("inFrame") = "true" Then
	inFrame = True
Else
	inFrame = false
End If
%>


<%
Const dbName = 0
Const sortDbName = 1
Const displayName = 2
Const sortable = 3
Const doDisplay = 4
Const htmlTrans = 5

Dim fields()
If Not inframe then
	reDim fields(10)
	fields(0) = split("molecule:::false:true:",":")
	fields(1) = Split("reg_id:reg_id:Reg Number:true:true:",":")
	fields(2) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
	fields(3) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")
	fields(4) = split("source:source:Source:true:true:",":")
	fields(5) = split("just_batch:::false:false:",":")
	fields(6) = split("just_reg:::false:false:",":")
	fields(7) = split("experiment_id:::false:false:",":")
	fields(8) = split("revision_number:::false:false:",":")
	fields(9) = split("experiment_name:::false:false:",":")
	fields(10) = split("cd_id:cd_idexport::false:true:<input type='checkbox' class='exportCheck' cd_id='$cd_id$' onchange='updateSearchKeyCdIds(this)'>",":")
Else
	reDim fields(7)

	fields(0) = split("molecule:::false:true:",":")
	fields(1) = Split("reg_id:reg_id:Reg Number:true:true:",":")
	fields(2) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
	fields(3) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")
	fields(4) = split("fp_1:selectSearchResult:Select:true:true:<a href='javascript&#58;void(0)' onclick='window.parent.regSelectLink(""$reg_id$"")'>Select</a>",":")
	fields(5) = split("just_batch:::false:false:",":")
	fields(6) = split("just_reg:::false:false:",":")
	fields(7) = split("cd_id:cd_id::false:false:",":")
End if

tableStrQuery = "select * from searchView where just_reg="&SQLClean(batchesRegNumber,"T","S")&" and just_batch like '%[1-9]%'"
'session("tableStrQuery") = tableStrQuery
%>





<%
whichTable = "searchView"
defaultSort = "cd_timestamp"
defaultSortDirection = "DESC"
pageName = "searchResults.asp?a=1"
defaultRpp = 5000


Call getconnectedJchemReg
%>
	<!-- #INCLUDE file="_inclds/chemTable2.asp" -->
</div>