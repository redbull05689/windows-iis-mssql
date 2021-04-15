<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
regNumber = request.querystring("regNumber")
isBatch = False
isReg = False
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(regNumber,"T","S")
rec.open strQuery,jchemRegConn,0,-1
If rec.eof Then
	isReg = True
Else
	isBatch = True
End If
Call disconnectJchemReg
if isReg then
	response.redirect("showReg.asp?regNumber="&regNumber)
end if
if isBatch then
	response.redirect("showBatch.asp?regNumber="&regNumber)
end if
%>