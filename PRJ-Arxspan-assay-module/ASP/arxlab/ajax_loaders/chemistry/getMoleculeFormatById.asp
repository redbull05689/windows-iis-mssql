<%@Language="VBScript" CodePage = 65001 %>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
Response.CharSet = "UTF-8"
Response.CodePage = 65001
server.scriptTimeout = 10000
%>
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include file="../../_inclds/common/asp/lib_Jchem.asp"-->
<!-- #include file="../../_inclds/escape_and_filter/functions/fnc_decodeBase64.asp"-->
<!-- #include file="../../_inclds/experiments/common/functions/fnc_applyChemDrawStyles.asp"-->
<%
Set retVal = JSON.parse("{""format"":"""",""data"":""""}")
tagId = request.querystring("tagId")
sketchId = request.querystring("id")

strQuery = "SELECT chemicalSketch, format FROM liveEditStructureDiagrams WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND userId="&SQLClean(session("userId"),"N","S")&" AND tagId="&SQLClean(tagId,"T","S")&" AND id="&SQLClean(sketchId,"N","S")
Set aRec = server.CreateObject("ADODB.recordset")
aRec.open strQuery,conn,3,3

If Not aRec.eof Then
	retVal.Set "format", CStr(aRec("format"))
	retVal.Set "data", CStr(aRec("chemicalSketch"))
End If

response.write(JSON.stringify(retVal))
response.end()
%>