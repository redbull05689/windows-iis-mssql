<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
chemAxonDatabaseName = getCompanySpecificSingleAppConfigSetting("chemAxonDatabaseName", session("companyId"))
reagentDbTableName = getCompanySpecificSingleAppConfigSetting("reagentDbTableName", session("companyId"))

set fields = JSON.parse("[]")
fields.push("name")
fields.push("molecularformula")
fields.push("molecularweight")
fields.push("supplier")
fields.push("cas")
fields.push("barcode")
fields.push("molarity")
fields.push("density")
fields.push("solvent")
fields.push("trivialname")

'Find all metadata we care about by CD_ID in the reagent DB
set searchHitJson = JSON.parse(CX_getFieldDataByCdId(chemAxonDatabaseName, reagentDbTableName, SQLClean(request.querystring("id"),"N","S"), JSON.stringify(fields)))
' Case maters, so we have to translate some fields over because they are different.
searchHitJson.Set "molecularFormula",searchHitJson.get("molecularformula")
searchHitJson.Set "molecularWeight",searchHitJson.get("molecularweight")
searchHitJson.Set "trivialName",searchHitJson.get("trivialname")
response.write(JSON.stringify(searchHitJson))
%>