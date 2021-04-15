<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%

hideRegIdFromRestrictedUsers = checkBoolSettingForCompany("hideRegIdFromRestrictedUsers", session("companyId"))
hasRegIntegration = checkBoolSettingForCompany("elnHasRegIntegration", session("companyId"))
regIntOpenInNewWindow = checkBoolSettingForCompany("openRegIntegrationInNewWindow", session("companyId"))
showRegLinkInGrid = checkBoolSettingForCompany("showRegLinkInStoichiometryGrid", session("companyId"))
regIntDontUseMol3000IfAvailable = checkBoolSettingForCompany("useLegacyMolFormatWithRegIntegration", session("companyId"))
useRegIntStructInfo = checkBoolSettingForCompany("useRegIntStructInfo", session("companyId"))
gridCutoff = getCompanySpecificSingleAppConfigSetting("stoichGridFeatureCutoverPoint", session("companyId"))
gridCutoff = normalizeIntSetting(gridCutoff)
submissionIdBaseUrl = getCompanySpecificSingleAppConfigSetting("submissionIdBaseUrl", session("companyId"))
accordServicePath = getCompanySpecificSingleAppConfigSetting("accordServiceEndpointUrl", session("companyId"))
On Error Resume Next
'a = draftSet("test","test")
If Err.number <> 0 Then
	Function draftSet(none,inString)
		draftSet = inString
	End function
End If
On Error goto 0
Function addBreakSpaces(inString,cutoff)
	newString = ""
	numSpaces = 0
	stopNum = Len(inString)
	itx = 0
	Do While itx < stopNum
		itx = itx + 1
		If itx Mod cutoff = 0 Then
			newString = newString & " "
			numSpaces = numSpaces + 1
			stopNum = stopNum + 1
		Else
			newString = newString & Mid(inString,itx-numSpaces,1)
		End if
	loop
	addBreakSpaces = newString
End Function

Function getAnchorText(url)
	A1 = split(url,">")
	A2 = split(A1(1),"<")
	getAnchorText = A2(0)
End Function

Function getObjectForm(experimentId,revisionId,obType,number,notForm,quickView,numCols,forPDF)
	'intended to be used for getting any type of object and displaying it as a table/form
	'currently only used to get tables/forms for the stochiometry grid
	'number: the current record e.g reactant 2
	'notForm: displays a table instead of a form
	'quickview: 'nxq no longer used
	'numCols: the number of columns for the table
	'forPdf: removes the mouse over tool tip for the chemical name

	'check whether logged in user owns the specified experiment
	ownsExp = ownsExperiment("1",experimentId,session("userId"))
	Dim fields()

	'constants for array index so that you can use an array like a dictionary e.g. fields(0)(formType)
	Const formName = 0
	Const displayText = 1
	Const formType = 2
	Const units = 3
	Const calc = 4
	Const unitMultipliers = 5
	Const abbr = 6
	Const fieldsQV = 7
	Const defaultUnits = 8
	Const columnNumber = 9
	If experimentId <> "" Then
		Call getconnected

		'get the notebookId of the experiment test if the user can write to the notebook
		'if they cannot then dont draw a form
		'nxq only for chemistry experiments
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT notebookId FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			canWrite = canWriteNotebook(CStr(rec("notebookId")))
			If Not canWrite Then
				notForm = True
			End if
		End If
		rec.close
		Set rec = Nothing


		'select the right data query for the object type so that we can load the existing values into the form
		'nxq should only be using the object type id
		tableName = ""
		Select Case obType
			Case "Reactant"
				obType = 1
				tableName = "reactants"
			Case "1"
				obType = 1
				tableName = "reactants"
			Case "Reagent"
				obType = 2
				tableName = "reagents"
			Case "2"
				obType = 2
				tableName = "reagents"
			Case "Product"
				obType = 3
				tableName = "products"
			Case "3"
				obType = 3
				tableName = "products"
			Case "Solvent"
				obType = 4
				tableName = "solvents"
			Case "4"
				obType = 4
				tableName = "solvents"
		End Select

		If revisionId = "" then
			strQuery = "SELECT * FROM " & tableName & " WHERE experimentId="& SQLClean(experimentId,"N","S") & " ORDER BY sortOrder,userAdded,id ASC"
		Else
			strQuery = "SELECT * FROM " & tableName & "_history WHERE experimentId="& SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionId,"N","S")&" ORDER BY sortOrder,userAdded,id ASC"
		End If
		
		'get moldata for molecule types that have moldata
		Set rec = server.CreateObject("ADODB.RecordSet")
		rec.open strQuery,conn,3,3
		num = CInt(number) - 1
		For q = 1 To num
			If Not rec.eof then
				rec.movenext
			End If
		Next

		If Not rec.eof then
			If rec("userAdded") = 1 Then
				userAdded = True
			Else
				userAdded = False
			End If
		Else
			userAdded = true
		End if

		If Not rec.eof Then
			If Len(rec("molData") & vbNullString) > 0 Then
				molData = Replace(Server.HTMLEncode(rec("molData")),"'","&apos;")
			else
				molData = vbNullString
			end if
			If Len(rec("molData3000") & vbNullString) > 0 Then
				molData3000 = Replace(Server.HTMLEncode(rec("molData3000")),"'","&apos;")
			else
				molData3000 = vbNullString
			end if
			cxsmiles = rec("cxsmiles")
			inchiKey = rec("inchiKey")
			fragmentId = rec("fragmentId")
			fragmentCdxmlForRegIntegration = rec("cdxml")
			If fragmentCdxmlForRegIntegration <> "" Then
				fragmentCdxmlForRegIntegration = Server.HTMLEncode(fragmentCdxmlForRegIntegration)
			End If
			If revisionId = "" then
				smiles = rec("smiles")
			End If
			If obType = 1 Or obType = 2 then
				productId = rec("productId")
			End if
		End If

		If Not rec.eof Then
			If session("hasCrais") Then
				If Not IsNull(rec("craisClass")) Then
					craisClass = rec("craisClass")
				Else
					craisClass = ""
				End If
				If Not IsNull(rec("craisText")) Then
					craisText = rec("craisText")
				Else
					craisText = ""
				End if
			End if
		End if

		inventoryItems = "[]"
		If Not rec.eof then
			If session("hasInventoryIntegration") Or session("hasBarcodeChooser") Then
				dbInventoryItems = rec("inventoryItems")
				If (Not IsNull(dbInventoryItems)) And inventoryItems<>"" Then
					inventoryItems = dbInventoryItems
				End if
			End if
		Else
			inventoryItems = "[]"
		End if

		On Error Resume next
		UAStates = rec("gridState")
		If IsNull(UAStates) Then
			UAStates = ""
		End If
		If Err.number <> 0 Then
			UAStates = ""
		End If
		On Error goto 0
	End If

	'Get the atom/bond UUIDs so we can highlight them in marvin
	uuidQuery = "SELECT * FROM fragmentMap WITH (NOLOCK) WHERE experimentId="& SQLClean(experimentId,"N","S") & " AND fragmentId = " & SQLClean(fragmentId,"N","S")
	Set uuidrec = server.CreateObject("ADODB.RecordSet")
	uuidrec.open uuidQuery,conn,3,3

	uuidList = ""

	do while Not uuidrec.eof
		uuidList = uuidList & uuidrec("atomUUID") & ":::" ' asp sucks
		uuidrec.movenext
	loop
	' uuidList = split(uuidList, ":::")

	'use the mapping table to load the fields array with the appropriate variables for the field
	'fields(0) = [formName, displayText, formType, units, calc, unitMultipliers, abbr, fieldsQV, defaultUnits ]
	Set mapRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM ctFieldMappingView WHERE objectTypeId="&SQLClean(obType,"N","S") & " AND enabled=1 ORDER BY columnNumber, sortOrder"
	mapRec.open strQuery,conn,3,3
	ReDim fields(mapRec.recordCount-1)
	If session("hasInventoryIntegration") Or session("hasBarcodeChooser") Then
		ReDim fields(mapRec.recordCount)
		If obType = 1 Or obType = 2 Then
			ReDim fields(mapRec.recordCount+1)		
		End if
	End if

	counter = 0
	numVisibleColumns = 0
	'loop through all fields for this object type
	Do While Not mapRec.eof
		'concatenate all the data into a string
		fieldString = mapRec("fieldName")&":"&mapRec("displayName")&":"&mapRec("formType")
		If Not IsNull(mapRec("units")) then
			fieldString = fieldString &":"&mapRec("units")
		Else
			fieldString = fieldString &":"
		End If
		fieldString = fieldString &":"&mapRec("calc")
		fieldString = fieldString &":"&mapRec("multipliers")
		fieldString = fieldString &":"&mapRec("abbr")
		fieldString = fieldString &":"&mapRec("quickView")
		If Not IsNull(mapRec("defaultUnits")) Then
			fieldString = fieldString &":"&mapRec("defaultUnits")
		Else
			fieldString = fieldString &":"
		End If
		fieldString = fieldString &":"&mapRec("columnNumber")
		'if visible then add to the counter of visible fields
		If mapRec("formType") <> "hidden" Then
			numVisibleColumns = numVisibleColumns + 1
		End If
		'break the string into an array in the fields array
		fields(counter) = Split(fieldString,":")
		mapRec.movenext
		counter = counter + 1
	loop
	mapRec.close
	Set mapRec = nothing
	
	If session("hasInventoryIntegration") Or session("hasBarcodeChooser") Then
		fields(counter) = Split("inventoryItems:Inventory Items:text:::::::3:",":") ' Hard coded field: formName = "inventoryItems", displayText = "Inventory Items", formType = "text", columnNumber = "3"
		counter = counter + 1
		If obType = 1 Or obType = 2 then
			fields(counter) = Split("productId:Product Id:text:::::::3:",":") ' Hard coded field: formName = "productId", displayText = "Product Id", formType = "text", columnNumber = "3"
			counter = counter + 1
		End if

	End if

	'start the html construction
	HTML = ""
	Set objectTypeRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT prefix from ctObjectTypes WHERE id="&SQLClean(obType,"N","S") 
	objectTypeRec.open strQuery,conn,3,3
	If Not objectTypeRec.eof Then
		'set prefix number for object by combining with number
		prefix = objectTypeRec("prefix") & number
		id = objectTypeRec("prefix") & number & "_body"
		objectPrefix = objectTypeRec("prefix")
		css = "display:none;"
	End If
	objectTypeRec.close
	Set objectTypeRec = nothing

	'start body table with the proper id
	HTML = HTML & "<table class='caseTable' cellpadding='0' cellspacing='0' id="""&id&""" style="""&css&"width:100%;"">"
	If ForPDF Then
		If obType=4 Then
			cutoff = 30
		Else
			cutoff = 160
		End If
		If Not rec.eof then
			s = rec(fields(0)(formName))
			If IsNull(s) Then
				s = ""
			End If
		Else
			s = ""
		End If
		HTML = HTML & "<tr><td colspan='3'><table><tr><td style='width:60px;' valign='top'>"&fields(0)(displayText)&"</td><td align='left'>"&addBreakSpaces(s,cutoff)&"</td></tr></table></td></tr>"
	End if
	HTML = HTML & "<tr><td valign='top'>"
	colNumber = 1
	'loop through all the fields
	For gfi = 0 To UBound(fields)

		If gfi = 0 Then
			HTML = HTML & "<table>"
		End If

		If forPDF And gfi = 0 Then
			gfi = gfi + 1
			numVisibleColumns = numVisibleColumns - 1 
		End if
		
		' Set the colNumber base on the value from the Database
		if fields(gfi)(columnNumber) <> "" then
			colNumber = CInt(fields(gfi)(columnNumber))
		else
			colNumber = 0
		end if

		' This makes the different columns in the grid, by checking to see if the previous field had a different column number		
		if gfi > 0 then
			if fields(gfi)(columnNumber) <> fields(gfi - 1)(columnNumber) then
				HTML = HTML & "</table></td><td valign='top'><table>"
			end if
		end if

		'get the form name as in <input type='text' name='[this]'>
		fname =  objectPrefix & number & "_" & fields(gfi)(formName)

		If fields(gfi)(formType) <> "hidden" then
			HTML = HTML & "<tr>"
			If Not quickView Then
				css = "width:115px;"
			Else
				css = "width:2px;"
			End If
			'make the field name td
			HTML = HTML & "<td class='caseInnerTitle' nowrap valign='top' style='"&css&"'>"
			HTML = HTML & fields(gfi)(displayText)
			HTML = HTML & "<span class=""requiredExperimentFieldNotice simpleAbsolute"" data-fieldname=""" & fName & """>*</span></td>"
			css = "width:180px;"
			'td for data or form item
			HTML = HTML & "<td class='caseInnerData' style='"&css&"'>"
		End if

		If experimentId <> "" Then
			'select the type and get the proper data for the field
			'only different on check box. needs to return checked instead of a value
			Select Case fields(gfi)(formType)
				Case "text"
					'On Error Resume Next
					If Not rec.eof Then
						formVal = rec(fields(gfi)(formName))
					End If
				Case "date"

				Case "hidden"
					'On Error Resume Next
					If Not rec.eof Then
						formVal = rec(fields(gfi)(formName))
					End If
				Case "checkbox"
					If Not rec.eof Then
						tinyInt = rec(fields(gfi)(formName))
						If tinyInt = 1 Then
							formVal = "CHECKED"
						End if
					End if				
			End Select
		End if
		
		'select form type for building the table
		Select Case fields(gfi)(formType)
			Case "text"
				If revisionId = "" And Not notForm And ownsExp Then
					'if all the criteria for showing the form is met
					If fields(gfi)(units) <> "" Then
						'draw the units div
						HTML = HTML & "<div style='position:relative;z-index:10000!important;'><div class='unitsDiv' id='"&fName & "_units"&"' style='display:none;z-index:10000!important;'>"
						HTML = HTML & "<ul>"
						theseUnits = split(fields(gfi)(units),",")
						'make the units List
						For j = 0 To UBound(theseUnits)
							HTML = HTML & "<li><a id='"&fname&"_units_num_"&j&"' onmouseover='clearSelectedClass(this)' onclick=""appendUnits('"&theseUnits(j)&"')"">"&theseUnits(j)&"</a></li>"
						next
						HTML = HTML & "</ul>"
						HTML = HTML & "</div></div>"
						'used for the units javascript to get the width of the form data so that it knows where to put the arrow
						HTML = HTML & "<span id='"&fName & "_dummy_width"&"' style='position:absolute;left:-4000px;'></span>"
					End If
					'holder for the units javascript to grab the default units if no units are provided
					HTML = HTML & "<span id='"&fName&"_du' style='position:absolute;left:-4000px;'>"&fields(gfi)(defaultUnits)&"</span>"
					'draw the main div for the form field
					HTML = HTML & "<div style='position:relative;'>"
					'set the tab index
					tabIndex = ((gfi Mod (numVisibleColumns)/numCols)) * 10 + colNumber
					If ((numVisibleColumns+1) \ numCols)*numCols < gfi+1.0 Then
						tabIndex = tabIndex + ((numVisibleColumns+1) \ numCols) * 10
					End if
					tabIndex = tabIndex + (obType*100)
					If obType = 3 Then
						tabIndex = ((gfi Mod (numVisibleColumns+1)/numCols)+1) * 100 + colNumber
					End If
					If Not IsNull(formVal) Then
						'escape apostropes in the form value
						formVal = Replace(formVal,"'","&apos;")
					End If
					'make the input field
					extraCss = ""
					hideRegIdTextFieldInGrid = checkBoolSettingForCompany("hideRegIdInStoichiometryGrid", session("companyId"))
					If (hideRegIdTextFieldInGrid Or session("hasAccordInt")) And (obType=3 And (fields(gfi)(formName)="regId") Or (fields(gfi)(formName)="compoundNumber")) Then
						extraCss = "display:none;"
					End If
					If (session("hasInventoryIntegration") Or session("hasBarcodeChooser")) And (fields(gfi)(formName) = "inventoryItems" Or fields(gfi)(formName) = "productId") Then
						extraCss = "display:none;"
					End if

					maxWidth = 50
					if fields(gfi)(formName) = "solvent" then
						maxWidth = 99
					end if

					HTML = HTML & "<input type='text' name='"&fName&"' id='"&fName&"' value='"&draftSet(fName,formVal)&"' class='"&fields(gfi)(formName)&" stochTextBox'  maxlength='" & maxWidth & "' style='position:relative;z-index:10;"&extraCss&"' onKeyUp='units(this)' onfocus='units(this)' tabIndex="""&tabIndex&""" obType='"&obType&"' onkeypress='if(event.keyCode == 13){return false;}'>"

					If showRegLinkInGrid And formVal<>"" And not hasRegIntegration And (fields(gfi)(formName)="regId" Or fields(gfi)(formName)="compoundNumber") Then
						If session("regRestrictedUser") And hideRegIdFromRestrictedUsers Then
							HTML = HTML & "<i>Hidden</i>"
						Else
							HTML = HTML & "<a target='_new' href='"&regPath&"/showRegItem.asp?regNumber="&formVal&"'>"&formVal&"</a>"
						End If
					End if

					If session("hasReg") And Not IsNull(session("regRoleNumber")) And Not session("hasAccordInt") And accordServicePath="" then
						If (fields(gfi)(formName)="compoundNumber" Or fields(gfi)(formName)="regId") And (Trim(formVal) = "" Or IsNull(formVal)) Then
						
							regIntUseCdxmlIfAvailable = getCompanySpecificSingleAppConfigSetting("regIntUseCdxmlIfAvailable", session("companyId"))
							If regIntDontUseMol3000IfAvailable Then
								HTML = HTML & "<a id='"&prefix&"_"&fields(gfi)(formName)&"_regLink' href='javascript:void(0);' onclick='isIntReg=false;document.getElementById(""regExperimentName"").value=document.getElementById(""e_name"").value;document.getElementById(""regName"").value=document.getElementById("""&prefix&"_trivialName"").value;if("&LCase(cStr(regIntUseCdxmlIfAvailable = 1)) &" && document.getElementById("""&prefix&"_fragmentCdxmlForRegIntegration"").value){document.getElementById(""regMolData"").value=document.getElementById("""&prefix&"_fragmentCdxmlForRegIntegration"").value;}else{document.getElementById(""regMolData"").value=document.getElementById("""&prefix&"_molData"").value;}try{document.getElementById(""regAmount"").value=document.getElementById("""&prefix&"_measuredMass"").value}catch(err){};document.getElementById(""regFieldId"").value="""&prefix&"_"&fields(gfi)(formName)&""";document.getElementById(""molPrefix"").value="""&prefix&""";document.getElementById(""regForm"").submit();showPopup(""regDiv"");return false;'>Register</a>"
							Else
								HTML = HTML & "<a id='"&prefix&"_"&fields(gfi)(formName)&"_regLink' href='javascript:void(0);' onclick='isIntReg=false;document.getElementById(""regExperimentName"").value=document.getElementById(""e_name"").value;document.getElementById(""regName"").value=document.getElementById("""&prefix&"_trivialName"").value;if("&LCase(cStr(regIntUseCdxmlIfAvailable = 1))&" && document.getElementById("""&prefix&"_fragmentCdxmlForRegIntegration"").value){document.getElementById(""regMolData"").value=document.getElementById("""&prefix&"_fragmentCdxmlForRegIntegration"").value;}else{if(document.getElementById("""&prefix&"_molData3000"").value){document.getElementById(""regMolData"").value=document.getElementById("""&prefix&"_molData3000"").value}else{document.getElementById(""regMolData"").value=document.getElementById("""&prefix&"_molData"").value;}}try{document.getElementById(""regAmount"").value=document.getElementById("""&prefix&"_measuredMass"").value}catch(err){};document.getElementById(""regFieldId"").value="""&prefix&"_"&fields(gfi)(formName)&""";document.getElementById(""molPrefix"").value="""&prefix&""";document.getElementById(""regForm"").submit();showPopup(""regDiv"");return false;'>Register</a>"
							End If
						End If
					End If
					
					If obType=3 And Not session("hasAccordInt") And hasRegIntegration Then
						If Not userAdded then
							scriptName = regPath&"/addStructureInt2.asp"							
							If (fields(gfi)(formName)="compoundNumber" Or fields(gfi)(formName)="regId") And (Trim(formVal) = "" Or IsNull(formVal)) Then
								'HTML = HTML & "<script>alert('"&formVal&"');</script>"
    							regIntWindowWidth = getCompanySpecificSingleAppConfigSetting("customRegIntegrationWindowWidth", session("companyId"))
								If CStr(regIntWindowWidth) <> "" Then
									theWidth = regIntWindowWidth
								Else
									theWidth = "580px"
								End if
								'HTML = HTML & "<script>alert('"&prefix&"');</script>"
								If regIntDontUseMol3000IfAvailable Then
									HTML = HTML & "<a id='"&prefix&"_"&fields(gfi)(formName)&"_regLink' href='javascript:void(0);' onclick='isIntReg=true;document.getElementById(""regForm"").target=""regFrame"";document.getElementById(""regFrame"").style.width="""&theWidth&""";document.getElementById(""regDiv"").style.width="""&theWidth&""";document.getElementById(""regExperimentName"").value=document.getElementById(""e_name"").value;document.getElementById(""regName"").value=document.getElementById("""&prefix&"_trivialName"").value;document.getElementById(""regMolData"").value=document.getElementById("""&prefix&"_molData"").value;document.getElementById(""regFieldId"").value="""&prefix&"_"&fields(gfi)(formName)&""";document.getElementById(""molPrefix"").value="""&prefix&""";document.getElementById(""regForm"").action="""&scriptName&""";document.getElementById(""regForm"").submit();showPopup(""regDiv"");return false;'>Register</a>"
								Else	
									HTML = HTML & "<a id='"&prefix&"_"&fields(gfi)(formName)&"_regLink' href='javascript:void(0);' onclick='isIntReg=true;document.getElementById(""regForm"").target=""regFrame"";document.getElementById(""regFrame"").style.width="""&theWidth&""";document.getElementById(""regDiv"").style.width="""&theWidth&""";document.getElementById(""regExperimentName"").value=document.getElementById(""e_name"").value;document.getElementById(""regName"").value=document.getElementById("""&prefix&"_trivialName"").value;if(document.getElementById("""&prefix&"_molData3000"").value){document.getElementById(""regMolData"").value=document.getElementById("""&prefix&"_molData3000"").value}else{document.getElementById(""regMolData"").value=document.getElementById("""&prefix&"_molData"").value;}document.getElementById(""regFieldId"").value="""&prefix&"_"&fields(gfi)(formName)&""";document.getElementById(""molPrefix"").value="""&prefix&""";document.getElementById(""regForm"").action="""&scriptName&""";document.getElementById(""regForm"").submit();showPopup(""regDiv"");return false;'>Register</a>"
								End If
							End If
							If ((fields(gfi)(formName)="regId" Or regIntOpenInNewWindow And fields(gfi)(formName)="compoundNumber")) And Not (Trim(formVal) = "" Or IsNull(formVal)) Then
								'HTML = HTML & "<script>alert('"&formVal&"');</script>"
								If useRegIntStructInfo Then
									subId = getAnchorText(formVal)
									If Not forPDF Then
										scriptName2 = regPath&"/showStructureInt.asp?regId="&subId
										HTML = HTML & "<a id='regIntLink' href='javascript:void(0);' onclick='isIntReg=true;document.getElementById(""regForm"").action="""&scriptName2&""";document.getElementById(""regForm"").target=""regFrame2"";document.getElementById(""regExperimentName"").value="""&subId&""";document.getElementById(""experimentId"").value="""&experimentId&""";document.getElementById(""regOwnsExp"").value="""&ownsExp&""";document.getElementById(""regFieldId"").value="""&prefix&"_"&fields(gfi)(formName)&""";document.getElementById(""experimentType"").value="""&experimentType&""";document.getElementById(""molPrefix"").value="""&prefix&""";document.getElementById(""regForm"").submit();showPopup(""regDiv2"");return false;'>View</a>"
									Else
										subURL = submissionIdBaseUrl & subId
										HTML = HTML & "<a href='" & subURL & "' target='_new'>" & subId & "</a>"
									End IF
								Else
									If (fields(gfi)(formName)="regId") And Not (Trim(formVal) = "" Or IsNull(formVal)) Then
										HTML = HTML & Replace(formVal,"<a","<a target='_new'")
									End If
								End If
							End If
						End if
					End If

					If session("hasInventoryIntegration") Or session("hasBarcodeChooser") Then
						If fields(gfi)(formName) = "inventoryItems" Then
							inventoryItems = draftSet(fName,inventoryItems)
							If inventoryItems = "" Or IsNull(inventoryItems) Then
								inventoryItems = "[]"
							End if
							If obType = 3 And inventoryItems = "[]" Then
								HTML = HTML & "<a href='javascript:void(0);' onclick='showInventoryPopupAdd("""&prefix&""");return false;'>Inventory</a><br/>"
							End If
							Set items = JSON.parse(join(array(inventoryItems)))
							if items.length = 1 then 
								For Each item In items
									If item.Get("id") <> "" then
										HTML = HTML & "<a target='_new' href='"&mainAppPath&"/inventory2/index.asp?id="&item.Get("id")&"'>"&item.Get("name")&"</a><br/>"
									End if
								next
							ElseIf items.length > 1 then
								HTML = HTML & "<a href='#invLinks'>Go to Links</a>"
							end if 
						End If
						If fields(gfi)(formName) = "productId" And (obType = 1 Or obType = 2) Then
							productId = draftSet(fName,productId)
							If productId <> "" Then
								parts = Split(productId,"-")
								If UBound(parts)>=1 then
									experimentName = Mid(parts(0),2,Len(parts(0))-1)&" - "&parts(1)
								End if
								HTML = HTML & "<a href='"&mainAppPath&"/experiments/experimentByName.asp?name="&experimentName&"'>"&productId&"</a>"
							End if
						End if
					End If

					If session("hasAccordInt") Then
						If Not userAdded then
							scriptName = regPath&"/addStructureIntAcc.asp"
							If (fields(gfi)(formName)="compoundNumber" Or fields(gfi)(formName)="regId") And (Trim(formVal) = "" Or IsNull(formVal)) Then
								HTML = HTML & "<a id='"&prefix&"_"&fields(gfi)(formName)&"_regLink' href='javascript:void(0);' onclick='isIntReg=true; document.getElementById(""checkComRequested"").value = document.getElementById(""showTOCLink"").getAttribute(""CheckComReq""); document.getElementById(""requestId"").value = document.getElementById(""showTOCLink"").getAttribute(""requestid"");document.getElementById(""regFrame"").style.width=""580px"";document.getElementById(""regDiv"").style.width=""580px"";document.getElementById(""regExperimentName"").value=document.getElementById(""e_name"").value;document.getElementById(""molPrefix"").value="""&prefix&""";document.getElementById(""regName"").value=document.getElementById("""&prefix&"_trivialName"").value;document.getElementById(""regMolData"").value=document.getElementById("""&prefix&"_molData3000"").value;document.getElementById(""regMolData2000"").value=document.getElementById("""&prefix&"_molData"").value;document.getElementById(""regFieldId"").value="""&prefix&"_"&fields(gfi)(formName)&""";document.getElementById(""molPrefix"").value="""&prefix&""";document.getElementById(""regForm"").action="""&scriptName&""";document.getElementById(""regForm"").submit();showPopup(""regDiv"");return false;'>Register</a>"
							End If
							If fields(gfi)(formName)="regId" And Not (Trim(formVal) = "" Or IsNull(formVal)) Then
								HTML = HTML & Replace(formVal,"<a","<a target='_new'")
							End If
						End if
					End if
					
					'add the script for the calculations
					HTML = HTML & "<script type='text/javascript'>"
					'add the calc as an on change event for the form element
					
					if int(experimentId) > int(gridCutoff) Then
						HTML = HTML & "addChangeEvent('"&fName&"',function(){gridFieldChanged(this)});"
					Else
						'nxq old grid calcs
						If fields(gfi)(calc) <> "" Then
							calcStr = Replace(fields(gfi)(calc),"|",":")
							HTML = HTML & "addChangeEvent('"&fName&"',function(){"&calcStr&"('"&objectPrefix&number&"')});"
						End If					
					End if
					
					
					myUnits = Split(fields(gfi)(units),",")
					myMultis = Split(fields(gfi)(unitMultipliers),",")
					For y = 0 To UBound(myUnits)
						'make the javascript array for the multipliers that each unit value has
						HTML = HTML & "unitMultis[""" & Replace(LCase(Trim(myUnits(y))),"&micro;","u") & """] = "& Trim(myMultis(y)) & ";"
					next
					HTML = HTML & "</script>"
					If UBound(fields(gfi)) > 2 Then
						'make units down arrow
						HTML = HTML & "<a href='javascript:void(0)' id='" & fName &"_down_image' style='position:absolute;top:5px;left:-4000px;z-index:10;' onclick='units(this);return false;'><img src='images/down.gif' border='0'></a>"
					End if
					HTML = HTML & "</div>"
				Else
					If fields(gfi)(formName) = "inventoryItems" Then
						inventoryItems = formVal
						If inventoryItems = "" Or IsNull(inventoryItems) Then
							inventoryItems = "[]"
						End if
						Set items = JSON.parse(join(array(inventoryItems)))
						if items.length = 1 then 
							For Each item In items
								If item.Get("id") <> "" then
									HTML = HTML & "<a target='_new' href='"&mainAppPath&"/inventory2/index.asp?id="&item.Get("id")&"'>"&item.Get("name")&"</a><br/>"
								End if
							next
						ElseIf items.length > 1 then
							HTML = HTML & "<a href='#invLinks'>Go to Links</a>"
						end if 
					End If
					If fields(gfi)(formName) = "productId" And (obType = 1 Or obType = 2) Then
						productId = formVal
						If productId <> "" Then
							parts = Split(productId,"-")
							If UBound(parts)>=1 then
								experimentName = Mid(parts(0),2,Len(parts(0))-1)&" - "&parts(1)
							End if
							If forPdf Then
								formVal = productId
							else
								formVal = "<a href='"&mainAppPath&"/experiments/experimentByName.asp?name="&experimentName&"'>"&productId&"</a>"
							End if
						End if
					End if
					'if we are read-only or in table mode
					If Not forPDF And fields(gfi)(formName)<>"regId" Then
						'if this is not being made for a pdf then add a tool tip mouse over of chemical names
						'for long chemical names
						If Len(formVal) > 20 And Not (fields(gfi)(formName)="inventoryItems" Or fields(gfi)(formName)="productId") Then
							'make the tooltip if the name is over 20 characters
							HTML = HTML & "<div style='position:absolute;left:0;z-index:1000;width:300px;background-color:#dfdfdf;border:2px solid #999;display:none;' onmouseout='this.style.display =""none""' id='"&fName&"_tooltip'>"&formVal&"</div>"
							shortVal = Mid(formVal,1,20)
							If InStr(shortVal,"&#") > 0 And Not InStr(shortVal,";") > 0 Then
								If InStr(formVal,";") > 0 then
									shortVal = Mid(formVal,1,InStr(formVal,";"))
								End if
							End if
							HTML = HTML & "<div class='stochDataDiv' onmouseover='document.getElementById("""&fName&"_tooltip"").style.display=""block""' style='width:130px;'>"
							HTML = HTML & shortVal & "</div>"
						Else	
							'make the div with the form value inside it if the chemical name is short enough to be displayed
							if (fields(gfi)(formName)="compoundNumber") and (session("regRegistrar") Or session("regUser")) then
									HTML = HTML & "<a target='_new' href='"&regPath&"/showRegItem.asp?regNumber="&formVal&"'>"&formVal&"</a>"
								else
									HTML = HTML & "<div class='stochDataDiv' style='width:130px;'>" & formVal & "</div>"
							end if
						End if
					Else
						If obType=3 And (fields(gfi)(formName)="regId" or fields(gfi)(formName)="compoundNumber") And useRegIntStructInfo And Not (Trim(formVal) = "" Or IsNull(formVal)) Then
							subId = getAnchorText(formVal)

							If Not forPDF Then
								If Not Trim(formVal) = "" Or IsNull(formVal) Then
									scriptName2 = regPath&"/showStructureInt.asp?regId="&subId
									HTML = HTML & "<a id='regIntLink' href='javascript:void(0);' onclick='isIntReg=true;document.getElementById(""regForm"").action="""&scriptName2&""";document.getElementById(""regForm"").target=""regFrame2"";document.getElementById(""regExperimentName"").value="""&subId&""";document.getElementById(""experimentId"").value="""&experimentId&""";document.getElementById(""regOwnsExp"").value="""&ownsExp&""";document.getElementById(""regFieldId"").value="""&prefix&"_"&fields(gfi)(formName)&""";document.getElementById(""experimentType"").value="""&experimentType&""";document.getElementById(""molPrefix"").value="""&prefix&""";document.getElementById(""regName"").value="""&ownsExp&""";document.getElementById(""regForm"").submit();showPopup(""regDiv2"");return false;'>View</a>"
								End If
							Else
								subURL = submissionIdBaseUrl & subId
								HTML = HTML & "<a href='" & subURL & "'>" & subId & "</a>"
							End If
						Else
							'make the div with the form value inside it
							If session("regRestrictedUser") And hideRegIdFromRestrictedUsers Then
								HTML = HTML & "<div class='stochDataDiv' style='width:130px;'><i>Hidden</i></div>"
							Else
								if (fields(gfi)(formName)="regId") and (session("regRegistrar") Or session("regUser")) then
									HTML = HTML & "<a target='_new' href='"&regPath&"/showRegItem.asp?regNumber="&formVal&"'>"&formVal&"</a>"
								else
									HTML = HTML & "<div class='stochDataDiv' style='width:130px;'>" & formVal & "</div>"
								end if
							End If
						End If
					End If
					'nxq not really sure about this line
					val = draftSet(fName,formVal)
					If IsNull(val) Then
						val = ""
					End if
					HTML = HTML & "<input type='hidden' id='"&fName&"' value='"&Replace(val,"'","&#39;")&"'>"
				End if
			Case "date"
				If revisionId = "" And Not notForm And ownsExp Then
					'make the field if we are in form mode
					HTML = HTML & "<input type='text' name='"&fName&"' id='"&fName&"' value='"&draftSet(fName,formVal)&"'>"
				Else
					'make the div with the form value inside it if we arent in form mode
					HTML = HTML & "<div class='stochDataDiv' style='width:130px;'>" & formVal & "</div>"
				End If
			Case "hidden"
					'make the div with the form value inside it
					val = draftSet(fName,formVal)
					If IsNull(val) Then
						val = ""
					End if
					HTML = HTML & "<input type='hidden' name='"&fName&"' id='"&fName&"' value='"&Replace(val,"'","&#39;")&"'>"
			Case "checkbox"
				If revisionId = "" And Not notForm And ownsExp Then
					tabIndex = (gfi Mod (numVisibleColumns+1)/numCols) * 10 + colNumber
					If obType = 3 Then
						tabIndex = (gfi Mod (numVisibleColumns+1)/numCols) * 100 + colNumber
					End If
					
					'add the calc stuff
					HTML = HTML & "<script type='text/javascript'>"
					'HTML = HTML & "function testf_"&fName&"(){document.getElementById('populateRow').innerHTML = '"&fName&"';}"
					jsStr = ""

					if int(experimentId) > int(gridCutoff) then
						HTML = HTML & "addChangeEvent('"&fName&"',function(){gridFieldChanged(this)});"
					else
						'nxq grid change
						If fields(gfi)(calc) <> "" Then
							calcStr = Replace(fields(gfi)(calc),"|",":")
							HTML = HTML & "addChangeEvent('"&fName&"',function(){"&calcStr&"('"&objectPrefix&number&"')});"
						End if
					End if

					'add javascript array of multipliers for unit values 'nxq dont think this is necessary for a checkbox
					myUnits = Split(fields(gfi)(units),",")
					myMultis = Split(fields(gfi)(unitMultipliers),",")
					For y = 0 To UBound(myUnits)
						HTML = HTML & "unitMultis[""" & Replace(LCase(Trim(myUnits(y))),"&micro;","u") & """] = "& Trim(myMultis(y)) & ";"
					next

					HTML = HTML & "</script>"
					
					'set the tab index
					tabIndex = ((gfi Mod (numVisibleColumns)/numCols)) * 10 + colNumber
					If Not quickView Then
						tabIndex = tabIndex + (obType*100)
					End if
					If obType = 3 Then
						tabIndex = ((gfi Mod (numVisibleColumns+1)/numCols)+1) * 100 + colNumber
					End If
					
					'make the form field
					HTML = HTML & "<input type='checkbox' name='"&fName&"'  class='"&fields(gfi)(formName)&"' id='"&fName&"' "&draftSet(fName,formVal)&" tabIndex="""&tabIndex&""" obType='"&obType&"'>"
				Else
					'display data if in read only mode
					If formVal = "CHECKED" Then
						HTML = HTML & "<div class='stochDataDiv' style='width:130px;'>TRUE</div>"
					Else
						HTML = HTML & "<div class='stochDataDiv' style='width:130px;'>FALSE</div>"
					End If
					HTML = HTML & "<input type='checkbox' name='"&fName&"'  class='"&fields(gfi)(formName)&"' id='"&fName&"' "&draftSet(fName,formVal)&" tabIndex="""&tabIndex&""" obType='"&obType&"' style='display:none;'>"
				End if
		End Select
		If fields(gfi)(formType) <> "hidden" then
			HTML = HTML & "</td>"
			HTML = HTML & "</tr>"
		End if

	Next
	
	HTML = HTML & "</table>"
	HTML = HTML & "<input type='hidden' name='"&prefix&"_molData"&"' id='"&prefix&"_molData"&"' value='"&molData&"'>"
	HTML = HTML & "<input type='hidden' name='"&prefix&"_molData3000"&"' id='"&prefix&"_molData3000"&"' value='"&molData3000&"'>"
	HTML = HTML & "<input type='hidden' name='"&prefix&"_fragmentCdxmlForRegIntegration"&"' id='"&prefix&"_fragmentCdxmlForRegIntegration"&"' value="""&fragmentCdxmlForRegIntegration&""">"
	If session("hasCrais") then
		HTML = HTML & "<input type='hidden' name='"&prefix&"_craisClass"&"' id='"&prefix&"_craisClass"&"' value='"&craisClass&"'>"
		HTML = HTML & "<input type='hidden' name='"&prefix&"_craisText"&"' id='"&prefix&"_craisText"&"' value='"&craisText&"'>"
	End if
	If Not notForm Then
		'if we are in a form then add the moldata
		HTML = HTML & "<input type='hidden' name='"&prefix&"_cxsmiles"&"' id='"&prefix&"_cxsmiles"&"' value='"&cxsmiles&"'>"
		HTML = HTML & "<input type='hidden' name='"&prefix&"_smiles"&"' id='"&prefix&"_smiles"&"' value='"&smiles&"'>"
		HTML = HTML & "<input type='hidden' name='"&prefix&"_inchiKey"&"' id='"&prefix&"_inchiKey"&"' value='"&inchiKey&"'>"
		HTML = HTML & "<input type='hidden' name='"&prefix&"_fragmentId"&"' id='"&prefix&"_fragmentId"&"' value='"&fragmentId&"'>"
		HTML = HTML & "<input type='hidden' name='"&prefix&"_hasChanged"&"' id='"&prefix&"_hasChanged"&"' value='"&draftSet(prefix&"_hasChanged","0")&"'>"
		HTML = HTML & "<input type='hidden' name='"&prefix&"_UAStates"&"' id='"&prefix&"_UAStates"&"' value='"&draftSet(prefix&"_UAStates",UAStates)&"'>"
		HTML = HTML & "<input type='hidden' name='"&prefix&"_uuidList"&"' id='"&prefix&"_uuidList"&"' value='" & uuidList & "'>"
		
	End if
	HTML = HTML & "</td></tr></table>"
	HTML = HTML & "<script type='text/javascript'>loadUAStates('"&prefix&"');</script>"
	' This is for Marvin. Marvin does its thing, then we call this function to do the calulations on the grid data
	HTML = HTML & "<script type='text/javascript'>if (typeof getObjectCallBacks['"&prefix&"'] === 'function') {getObjectCallBacks['"&prefix&"']();}</script>"
	getObjectForm = HTML
End function
%>