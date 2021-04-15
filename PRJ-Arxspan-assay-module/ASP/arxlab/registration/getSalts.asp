<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
Call getconnectedJchemReg
set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT cd_id,name FROM "&regSaltsTable & " ORDER BY name ASC"
rec.open strQuery,JchemRegConn,3,3
str = "["
Do While Not rec.eof
	str = str& "['"&rec("cd_id")&"','"&Replace(rec("name"),"'","\'")&"']"
	rec.movenext
	If Not rec.eof Then
		str = str &","
	End if
Loop
str = str &"]"
Call disconnectJchemReg
response.write(str)
%>