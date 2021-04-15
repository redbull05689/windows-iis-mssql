<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
chemAxonDatabaseName = getCompanySpecificSingleAppConfigSetting("chemAxonDatabaseName", session("companyId"))
reagentDbTableName = getCompanySpecificSingleAppConfigSetting("reagentDbTableName", session("companyId"))

' list of fields we want back
set fields = JSON.parse("[]")
fields.push "cd_id"
fields.push "trivialname"

' conditions to impose on the query
set eqJson = JSON.parse("{}")
eqJson.set "$eq", session("companyId")
set conditions = JSON.parse("{}")
conditions.set "company_id", eqJson

'2147483647 is Java Max Int
searchHitJson = CX_structureSearch(chemAxonDatabaseName, reagentDbTableName, "", JSON.stringify(conditions), "", JSON.stringify(fields), 2147483647, 0)

set searchObj = JSON.parse(searchHitJson)

set defaultOption = JSON.parse("{}")
defaultOption.set "value", 0
defaultOption.set "text", "--SELECT--"

set optionsObj = JSON.parse("[]")
optionsObj.push defaultOption

' add each row to the final object
set dataRow = JSON.parse("{}")

For Each data in searchObj.get("data")
	if data.get("cd_id") <> "" AND data.get("trivialname") <> "" then
		dataRow.set "value", data.get("cd_id")
		dataRow.set "text", data.get("trivialname")
		optionsObj.push(JSON.parse(JSON.stringify(dataRow)))
	end if
Next

set output = JSON.parse("{}")
output.set "name", "reagentDatabaseSelect"
output.set "id", "reagentDatabaseSelect"
output.set "options", optionsObj

response.write(JSON.stringify(output))
%>