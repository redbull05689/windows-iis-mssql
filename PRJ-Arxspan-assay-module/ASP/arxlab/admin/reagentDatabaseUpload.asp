<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="../registration/_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<!-- #include virtual="/arxlab/util/stringBuilder.asp"-->
<%
chemAxonDatabaseName = getCompanySpecificSingleAppConfigSetting("chemAxonDatabaseName", session("companyId"))

sectionId = "tools"
subSectionId = "reagentDb"

if session("role") <> "Admin" Then
	response.redirect(mainAppPath&"/logout.asp")
End If
%>
<%
server.scripttimeout = 10000
response.buffer = false
%>
<%

	Set Upload = Server.CreateObject("Persits.Upload")
	Upload.ProgressID = Request.QueryString("PID")

	Upload.overwriteFiles = true
	Upload.Save(uploadRoot)
	For Each File in Upload.Files
		filepath = File.Path
	Next

	set FSO = server.createObject("Scripting.FileSystemObject")
	set file = FSO.GetFile(Filepath)
    Set TextStream = file.OpenAsTextStream(1, -2)
	Set sdFileStr = new Stringbuilder

	' append company id to each object in the SD file
	Do While Not TextStream.AtEndOfStream
		line = TextStream.readline
		If Trim(line) = "$$$$" Then
			line = ">  <company_id>"&vbcrlf&session("companyId")&vbcrlf&vbcrlf&"$$$$"
		End if
        sdFileStr.append(line & vbCRLF)
    Loop
	TextStream.close
	Set TextStream = nothing
	Set file = Nothing
	Set FSO = Nothing

	sdFileStr = sdFileStr.toString()
	
	reagentDbTableName = getCompanySpecificSingleAppConfigSetting("reagentDbTableName", session("companyId"))

	' This will delete anything currently in the reagent database for this company
	a = CX_removeStructures(chemAxonDatabaseName,reagentDbTableName,"")
	If a = True Then
		' fieldMappingObj. Will change anything named "Key" to "Value"
		Set fieldMappingObj = JSON.parse("{}")
		fieldMappingObj.Set "Chemical Name", "name"
		fieldMappingObj.Set "Molecular Formula", "molecularFormula"
		fieldMappingObj.Set "Molecular Weight", "molecularWeight"
		fieldMappingObj.Set "Supplier", "supplier"
		fieldMappingObj.Set "CAS Number", "cas"
		fieldMappingObj.Set "Reg Number", "regNumber"
		fieldMappingObj.Set "Barcode", "barcode"
		fieldMappingObj.Set "Molarity", "molarity"
		fieldMappingObj.Set "Density", "density"
		fieldMappingObj.Set "Solvent", "solvent"
		fieldMappingObj.Set "Trivial Name", "trivialName"
		fieldMappingObj.Set "company_id", "company_id"

		On Error goto 0
		monitorId = CX_importSdFile(chemAxonDatabaseName, reagentDbTableName, sdFileStr, fieldMappingObj)
		response.write("<h2>Your reagent database is being imported.</h2><h3>This may take up to 10 minutes to complete.</h3>")
%>
		<div id="progressDiv"><p>Progress: Starting</p></div>
		<div id="response"><p></p></div>
		<script>

		function pollJchem(){
			$.get('reagentDatabaseStatus.asp', { key: <%=monitorId%> })         
				.done(function(data) {
					try{
						objData = JSON.parse(data)
						// Uncomment to see details about the process. Error codes are sometimes in here even if it doesn't return FAILED
						//$( "#response" ).append( "<p>" + data + "</p>" );
						$( "#progressDiv" ).html( "<p>Progress: " + objData["data"]["progress"] + "%</p>" );

						if(objData["state"] == "FAILED"){
							$( "#response" ).append( "<p>Successful: " + objData["data"]["successful"] + " Failed: " + objData["data"]["failed"] + "</p>" );
							$( "#response" ).append( "<p>Upload Reagent Database failed. Reason: " + JSON.stringify(objData['error']) + "</p>" );
							return false;
						}else if (objData["state"] == "FINISHED") {
							$( "#response" ).append( "<p>Successful: " + objData["data"]["successful"] + " Failed: " + objData["data"]["failed"] + "</p>" );
							$( "#response" ).append( "<p>Finished!</p>" );
							return true;
						}
					}catch(err){
						$( "#response" ).append( "<p>Failed to read response.</p>");
					}
					setTimeout(pollJchem, 250); 
					
				}).fail(function(data){
					$( "#response" ).append( "<p>Failed to get response. Please try again</p>" );
				});
		}

		$( document ).ready(function() {
			pollJchem();
		});
		</script>

<%
	Else
		response.write("<div id='resultsDiv'>There was a problem clearing the existing structures from the database. Please contact support@arxspan.com.</div>")
	End If
%>
<!-- #include file="../_inclds/footer-tool.asp"-->