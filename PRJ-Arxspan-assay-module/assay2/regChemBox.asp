<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header-frame.asp"-->
<!-- #include file="../registration/_inclds/lib_reg.asp"-->
<!-- #include file="../_inclds/common/asp/lib_jchem.asp"-->
<!-- #include file="../_inclds/parse/functions/fnc_getXMLTag.asp"-->
<!-- #include file="../_inclds/escape_and_filter/functions/fnc_HTMLDecode.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<style type="text/css">
*{
	margin:0;
	padding:0;
	border:none;
	background-color:white;
}
</style>
<script type="text/javascript" src="../js/windowSize.js"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<%
regNumber = request.querystring("regNumber")
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
if ubound(split(regNumber,"-")) = 1 then
    regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
	regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
	strQuery = "SELECT cd_id,groupId FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(regNumber&"-"&padWithZeros(0,regBatchNumberLength),"T","S")
end if
if ubound(split(regNumber,"-")) > 1 then
	strQuery = "SELECT cd_id,groupId FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(regNumber,"T","S")
end if
Set rec = server.CreateObject("ADODB.RecordSet")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
	theSvg = CX_getSvgByCdId(jChemRegDB, regMoleculesTable, rec("cd_id"), request.querystring("w"), request.querystring("h"))
	%><%=theSvg%>
<%End If%>
<!-- #include file="_inclds/footer-frame.asp"-->