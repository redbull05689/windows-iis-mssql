<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
hideSmallMolecule = checkBoolSettingForCompany("hideSmallMolecule", session("companyId"))
Call getconnectedJchemReg
set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT id,name FROM groupCustomFields WHERE name is not null AND visible<>0"
If session("regRestrictedGroups") <> "" Then
	strQuery = strQuery & " AND id not in ("&session("regRestrictedGroups")&")"
End If
strQuery = strQuery &" ORDER BY name ASC"

rec.open strQuery,JchemRegConn,3,3
If not hideSmallMolecule then
	str = "[['0','Small Molecule']"
	If Not rec.eof Then
		str = str & ","
	End if
Else
	str = "["
End if
Do While Not rec.eof
	str = str& "['"&rec("id")&"','"&Replace(rec("name"),"'","\'")&"']"
	rec.movenext
	If Not rec.eof Then
		str = str &","
	End if
Loop
str = str &"]"
Call disconnectJchemReg
response.write(str)
%>