<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!--#include file="../../_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
If 1=2 then
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM "&regMoleculesTable
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		If rec("just_batch") = compoundBatchNumber Then
			jchemRegConn.execute("UPDATE "&regMoleculesTable&" SET parent_cd_id=0 WHERE cd_id="&SQLClean(rec("cd_id"),"N","S"))
		Else
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE just_batch="&SQLClean(compoundBatchNumber,"T","S")&" AND just_reg="&SQLClean(rec("just_reg"),"T","S")& " AND groupId="&SQLClean(rec("groupId"),"N","S")
			rec2.open strQuery,jchemRegConn,3,3
			jchemRegConn.execute("UPDATE "&regMoleculesTable&" SET parent_cd_id="&SQLClean(rec2("cd_id"),"N","S")&" WHERE cd_id="&SQLClean(rec("cd_id"),"N","S"))
		End if
		rec.movenext
	loop
	Call disconnectJchemReg
End if
%>