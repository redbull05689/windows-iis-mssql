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
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
chemAxonAllMoleculesTable = getCompanySpecificSingleAppConfigSetting("chemAxonAllMoleculesTable", session("companyId"))
chemAxonAllReactionsTable = getCompanySpecificSingleAppConfigSetting("chemAxonAllReactionsTable", session("companyId"))
chemAxonDatabaseName = getCompanySpecificSingleAppConfigSetting("chemAxonDatabaseName", session("companyId"))

format = request.Form("format")
originalMolData = request.Form("structure")
targetElement = request.Form("targetElement")

molData = originalMolData
If format = "cdxml" Then
	cdxmlPos = InStr(molData, "<CDXML")
	If cdxmlPos > 0 Then
		molData = Right(molData, Len(molData) - cdxmlPos + 1)
	End If
	molData = JSON.stringify(molData)
	molData = mid(molData, 2, Len(molData)-2)
End If

isReaction = CX_isReaction(chemAxonDatabaseName,chemAxonAllMoleculesTable,molData)

dataTable = chemAxonAllMoleculesTable
If isReaction Then
	dataTable = chemAxonAllReactionsTable
End If

Set retVal = JSON.parse("{""sketchId"":-1}")
cxInsertResp = CX_addStructure(chemAxonDatabaseName,dataTable,molData,"")
retVal.Set "cxResponse", cxInsertResp

Set respJson = JSON.parse(cxInsertResp)
If IsObject(respJson) Then
	If respJson.Exists("cd_id") Then
		cdId = Abs(respJson.Get("cd_id"))
		strQuery = "insert into liveEditStructureDiagrams (companyId, userId, tagId, cd_id, chemicalSketch, format, dateCreated) output inserted.id as newId values (" &_
				   SQLClean(session("companyId"),"N","S") & "," & SQLClean(session("userId"),"N","S") & "," & SQLClean(targetElement, "T", "S") & "," & SQLClean(cdId,"N","S") & "," & SQLClean(originalMolData,"T","S") & "," & SQLClean(format,"T","S") & ",GETDATE())"
		Set rs = connAdm.execute(strQuery)
		retVal.Set "sketchId", CLng(rs("newId"))
	End If
End If

response.write(JSON.stringify(retVal))
response.end()
%>