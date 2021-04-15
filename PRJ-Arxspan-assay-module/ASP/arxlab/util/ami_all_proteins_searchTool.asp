<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%server.scriptTimeout = 1800000%>

<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/_inclds/common/asp/lib_JChem.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/lib_reg.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/fnc_sendProteinToSearchTool.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
if session("userId") = "2" Or session("email")="support@arxspan.com" then

	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.setOption 2, 13056
	call getconnectedAdm
	call getconnectedAdm
	Call getConnectedJchemReg
	Set recST = server.CreateObject("ADODB.RecordSet")
	strQuery  = "SELECT cd_id, reg_id FROM "&regMoleculesTable&" WHERE groupId in (SELECT id from groupCustomFields WHERE visible=1) or groupId=0 or groupId is null order by cd_id DESC"
	recST.open strQuery,jchemRegConn,3,3
	Do While Not recST.eof
		response.write("processing reg_id: " & recST("reg_id") & "<br>")
		response.flush()
		a = sendProteinToSearchTool(recST("cd_id"),true,true)
		recST.movenext
	Loop
	response.write("DONE!")
	call disconnect	
	call disconnectadm
	Call disconnectJchemReg
end If
%>