<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="regInt"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
accordServicePath = getCompanySpecificSingleAppConfigSetting("accordServiceEndpointUrl", session("companyId"))
clientAlias = getCompanySpecificSingleAppConfigSetting("clientAlias", session("companyId"))
%>

<%server.scriptTimeout=300%>
<%
Function isGridField(fieldName)
	If LCase(fieldName) <> "notebookname" And LCase(fieldName) <> "experimentname" And LCase(fieldName) <> "todaysdateoracle" Then
		isGridField = True
	Else
		isGridField = False
	End If
End function

Function arxReg_isInteger(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_IsInteger = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
For i = 1 to Len( string )
      spec = Mid(string, i, 1)
      Set regExp = New RegExp
      regExp.Global = True
      regExp.IgnoreCase = True
      regExp.Pattern = "[0-9]"
      set match = regExp.Execute(spec)
      If match.count = 0 Then
			'if the char is not [0-9] return false(not an integer)
            arxReg_IsInteger = False
            Exit Function
      End If
      Set regExp = Nothing
Next
arxReg_IsInteger = True
End Function

Function arxReg_isDate(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_isDate = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
Set regExp = New RegExp
regExp.Global = True
regExp.IgnoreCase = True
regExp.Pattern = "^([0-1][0-9]|[1-9])\/([0-2][0-9]|[3][0-1]|[1-9])\/(([0-9][0-9])|(20|19)[0-9][0-9])$"
set match = regExp.Execute(Trim(string))
If match.count = 0 Then
	'if the char is not [0-9] return false(not an integer)
	arxReg_isDate = False
	Exit Function
End If
Set regExp = Nothing
arxReg_isDate = True
End Function

Function arxReg_isPercent(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_isPercent = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
Set regExp = New RegExp
regExp.Global = True
regExp.IgnoreCase = True
regExp.Pattern = "^[0-9]+(\.){0,1}[0-9]*( )*[%]{0,1}$"
set match = regExp.Execute(Trim(string))
If match.count = 0 Then
	'if the char is not [0-9] return false(not an integer)
	arxReg_isPercent = False
	Exit Function
End If
Set regExp = Nothing
arxReg_isPercent = True
End Function

Function arxReg_isNumber(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_isNumber = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
Set regExp = New RegExp
regExp.Global = True
regExp.IgnoreCase = True
regExp.Pattern = "^[0-9]+(\.){0,1}[0-9]*$"
set match = regExp.Execute(Trim(string))
If match.count = 0 Then
	'if the char is not [0-9] return false(not an integer)
	arxReg_isNumber = False
	Exit Function
End If
Set regExp = Nothing
arxReg_isNumber = True
End Function

Function arxReg_isOracleDate(byVal string)
'return true if the supplied value is an integer
If String = "" Then
	arxReg_isOracleDate = False
	Exit Function
End if
dim regExp, match, i, spec
'loop through each character of string
Set regExp = New RegExp
regExp.Global = True
regExp.IgnoreCase = True
regExp.Pattern = "^([0-2][0-9]|[3][0-1]|[1-9])\-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\-(([0-9][0-9])|(20|19)[0-9][0-9])$"
set match = regExp.Execute(trim(string))
If match.count = 0 Then
	'if the char is not [0-9] return false(not an integer)
	arxReg_isOracleDate = False
	Exit Function
End If
Set regExp = Nothing
arxReg_isOracleDate = True
End Function


success = false

If experimentId = "" Then
	experimentId = request.Form("experimentId")
	experimentType = request.Form("experimentNumber")
	revisionNumber = request.form("revisionNumber")
	regFieldId = request.form("regFieldId")
	molData = request.form("regMolData")
	regName = request.Form("regName")
	regExperimentName = request.Form("regExperimentName")
	regNotebookId = request.Form("regNotebookId")
	molPrefix = request.Form("molPrefix")
	notebookName = request.Form("regNotebookName")
End if

Function getElnVar(elnVar)
	Select Case LCase(elnVar)
		Case "notebookname"
			getElnVar = notebookName
		Case "experimentname"
			getElnVar = regExperimentName
		Case "todaysdateoracle"
			getElnVar = Day(now)&"-"&MonthName(Month(Now()),true)&"-"&Right(Year(Now()),2)
	End select
End Function

molData = request.form("regMolData")
molDataLines = Split(molData,vbcrlf)
If UBound(molDataLines) = 0 Then
	molDataLines = Split(molData,vbcr)
End If
If UBound(molDataLines) = 0 Then
	molDataLines = Split(molData,vblf)
End If
If Not isInteger(Trim(Left(molDataLines(3),3))) Then
	molData = vbcrlf & molData
End if

'If request.form("emailTest") = "" Then
'	emailTest = "andrew@broadinstitute.org"
'Else
'	emailTest = request.Form("emailTest")
'End if
theEmailAddress = session("email")
If theEmailAddress="support@arxspan.com" And clientAlias="A1" Then
	theEmailAddress = "andrew@broadinstitute.org"
End If

set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
xmlhttp.setOption 2, 13056
xmlhttp.Open "GET",accordServicePath&"/getFieldTypes?email="&server.urlencode(theEmailAddress),True
xmlhttp.setRequestHeader "Content-Type", "text/xml"
xmlhttp.send soapEnv
xmlhttp.waitForResponse(60)
bXML = xmlhttp.responsexml.xml
If bXML = "" Then
	bXML = xmlhttp.responseText
End If
If 1=2 Then 'manual xml file
	bXml = "<?xml version=""1.0"" enco"&"ding=""utf-8"" ?>"
	bXml = bXml & "<SDFile companyname=""Sage Therapeutics"" reportdate=""9/14/2012"">"
	bXml = bXml & "<EntryList>"
	bXml = bXml & "	<entry>"
	bXml = bXml & "		<name>arxspan_notebook_name</name>"
	bXml = bXml & "		<description>Notebook Name</description>"
	bXml = bXml & "		<required>true</required>"
	bXml = bXml & "		<hidden>false</hidden>"
	bXml = bXml & "		<type>string</type>"
	bXml = bXml & "		<defaultvalue></defaultvalue>"
	bXml = bXml & "		<validation></validation>"
	bXml = bXml & "		<elnVar>notebookName</elnVar>" 'change
	bXml = bXml & "		<readOnly>true</readOnly>" 'change
	bXml = bXml & "	</entry>"
	bXml = bXml & "	<entry>"
	bXml = bXml & "		<name>DATE_PREPARED</name>"
	bXml = bXml & "		<description>Date Synthesized</description>"
	bXml = bXml & "		<required>true</required>"
	bXml = bXml & "		<hidden>false</hidden>"
	bXml = bXml & "		<type>OracleDate</type>"
	bXml = bXml & "		<defaultvalue></defaultvalue>"
	bXml = bXml & "		<validation>arxReg_isOracleDate</validation>"
	bXml = bXml & "		<elnVar>todaysDateOracle</elnVar>" 'change
	bXml = bXml & "	</entry>"
	bXml = bXml & "	<entry>"
	bXml = bXml & "		<name>DESCRIPTION</name>"
	bXml = bXml & "		<description>Chemical Name</description>"
	bXml = bXml & "		<required>true</required>"
	bXml = bXml & "		<hidden>false</hidden>"
	bXml = bXml & "		<type>string</type>"
	bXml = bXml & "		<defaultvalue></defaultvalue>"
	bXml = bXml & "		<validation></validation>"
	bXml = bXml & "		<elnVar>name</elnVar>" 'change
	bXml = bXml & "		<readOnly>true</readOnly>" 'change
	bXml = bXml & "	</entry>"
	bXml = bXml & "	<entry>"
	bXml = bXml & "		<name>NOTEBOOK_PAGE</name>"
	bXml = bXml & "		<description>Page#</description>"
	bXml = bXml & "		<required>true</required>"
	bXml = bXml & "		<hidden>false</hidden>"
	bXml = bXml & "		<type>string</type>"
	bXml = bXml & "		<defaultvalue></defaultvalue>"
	bXml = bXml & "		<validation></validation>" 'change
	bXml = bXml & "		<elnVar>experimentName</elnVar>" 'change
	bXml = bXml & "		<readOnly>true</readOnly>" 'change
	bXml = bXml & "	</entry>"
	bXml = bXml & "	<entry>"
	bXml = bXml & "		<name>PURITY</name>"
	bXml = bXml & "		<description>Purity</description>"
	bXml = bXml & "		<required>true</required>"
	bXml = bXml & "		<hidden>false</hidden>"
	bXml = bXml & "		<type>string</type>"
	bXml = bXml & "		<defaultvalue></defaultvalue>"
	bXml = bXml & "		<validation>arxReg_isPercent</validation>"
	bXml = bXml & "		<elnVar>purity</elnVar>" 'change
	bXml = bXml & "		<readOnly>true</readOnly>" 'change
	bXml = bXml & "	</entry>"'project name removed ' supplier removed 'scientist name removed
	bXml = bXml & "	<entry>" 'completely new entry
	bXml = bXml & "		<name>AMTPREPARED</name>"
	bXml = bXml & "		<description>Amount Prepared</description>"
	bXml = bXml & "		<required>true</required>"
	bXml = bXml & "		<hidden>false</hidden>"
	bXml = bXml & "		<type>string</type>"
	bXml = bXml & "		<defaultvalue></defaultvalue>"
	bXml = bXml & "		<validation></validation>"
	bXml = bXml & "		<elnVar>measuredMass</elnVar>" 'change
	bXml = bXml & "		<readOnly>true</readOnly>" 'change
	bXml = bXml & "	</entry>"
	bXml = bXml & "	<entry>"
	bXml = bXml & "		<name>SALT_NAME</name>"
	bXml = bXml & "		<description>Salt Name</description>"
	bXml = bXml & "		<required>false</required>"  'change
	bXml = bXml & "		<hidden>false</hidden>"
	bXml = bXml & "		<type></type>"
	bXml = bXml & "		<values><value>Iodomethane</value><value>Trifluoro-2,2-dihydroxypropanoic acid</value></values>"
	bXml = bXml & "		<defaultvalue>1</defaultvalue>"
	bXml = bXml & "		<validation></validation>"
	bXml = bXml & "	</entry>"
	bXml = bXml & "</EntryList>"
	bXml = bXml & "</SDFile>"
End If

If 1=2 Then
	bXml = "<?xml version=""1.0"" enco"&"ding=""utf-8"" ?>"
	bXml = bXml & "<EntryList>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<name>Project</name>"
	bXml = bXml & "<description>CBIP Project Code and Name</description>"
	bXml = bXml & "<required>true</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "<values>"
	bXml = bXml & "<value>2001 General HTS Sets</value>"
	bXml = bXml & "</values>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<name>Chemist</name>"
	bXml = bXml & "<description>Vendor Name or Chemist's Institution</description>"
	bXml = bXml & "<required>true</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "<values>"
	bXml = bXml & "<value>UBologna</value>"
	bXml = bXml & "<value>RyanSci</value>"
	bXml = bXml & "<value>BioFocus</value>"
	bXml = bXml & "<value>Toronto</value>"
	bXml = bXml & "<value>UMinnesota</value>"
	bXml = bXml & "<value>UCLA</value>"
	bXml = bXml & "<value>Albany</value>"
	bXml = bXml & "<value>Asinex</value>"
	bXml = bXml & "<value>InterBioScreen</value>"
	bXml = bXml & "<value>Vitas-M</value>"
	bXml = bXml & "<value>Sequoia</value>"
	bXml = bXml & "<value>Stanley</value>"
	bXml = bXml & "<value>Stanford</value>"
	bXml = bXml & "<value>MLSC/UPitt</value>"
	bXml = bXml & "<value>UKansas</value>"
	bXml = bXml & "<value>UCDavis</value>"
	bXml = bXml & "<value>DanaFarber</value>"
	bXml = bXml & "<value>BU</value>"
	bXml = bXml & "<value>UKentucky</value>"
	bXml = bXml & "<value>MLSC/Columbia</value>"
	bXml = bXml & "<value>MLSC/UNM</value>"
	bXml = bXml & "<value>OregonState</value>"
	bXml = bXml & "<value>Sai</value>"
	bXml = bXml & "<value>Steraloids</value>"
	bXml = bXml & "<value>Matreya</value>"
	bXml = bXml & "<value>Nu-Chek</value>"
	bXml = bXml & "<value>Oakwood</value>"
	bXml = bXml & "<value>Novartis</value>"
	bXml = bXml & "<value>BioVision</value>"
	bXml = bXml & "<value>Tufts</value>"
	bXml = bXml & "<value>Abcam</value>"
	bXml = bXml & "<value>CombiBlocks</value>"
	bXml = bXml & "<value>Fermentek</value>"
	bXml = bXml & "<value>TSZ</value>"
	bXml = bXml & "<value>Anichem</value>"
	bXml = bXml & "<value>NIH AIDS</value>"
	bXml = bXml & "<value>MDAnderson</value>"
	bXml = bXml & "<value>Princeton</value>"
	bXml = bXml & "<value>Cellagen</value>"
	bXml = bXml & "<value>Karyopharm</value>"
	bXml = bXml & "<value>Eutropics</value>"
	bXml = bXml & "<value>Symansis</value>"
	bXml = bXml & "<value>FloridaAM</value>"
	bXml = bXml & "<value>Yale</value>"
	bXml = bXml & "<value>LightBio</value>"
	bXml = bXml & "<value>AvaChem</value>"
	bXml = bXml & "<value>UCBerkeley</value>"
	bXml = bXml & "<value>UHawaiiManoa</value>"
	bXml = bXml & "<value>Glixx</value>"
	bXml = bXml & "<value>Serva</value>"
	bXml = bXml & "<value>UUtah</value>"
	bXml = bXml & "<value>Evotec-In</value>"
	bXml = bXml & "<value>CalTech</value>"
	bXml = bXml & "<value>UkrOrgSynthesis</value>"
	bXml = bXml & "<value>PharmaMar</value>"
	bXml = bXml & "<value>Ontario Chemicals</value>"
	bXml = bXml & "<value>Chempartners</value>"
	bXml = bXml & "<value>Chemdea</value>"
	bXml = bXml & "<value>Adipogen</value>"
	bXml = bXml & "<value>Bachem</value>"
	bXml = bXml & "<value>BayerPharma</value>"
	bXml = bXml & "<value>Synchem</value>"
	bXml = bXml & "<value>SciLab</value>"
	bXml = bXml & "<value>BioVendor</value>"
	bXml = bXml & "<value>Acros</value>"
	bXml = bXml & "<value>Pfizer</value>"
	bXml = bXml & "<value>Edelris</value>"
	bXml = bXml & "<value>UVirginia</value>"
	bXml = bXml & "<value>XCESSBIO</value>"
	bXml = bXml & "<value>LiverpoolJMU</value>"
	bXml = bXml & "<value>Beryllium</value>"
	bXml = bXml & "<value>NCState</value>"
	bXml = bXml & "</values>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<name>Project Role</name>"
	bXml = bXml & "<description>Project Role</description>"
	bXml = bXml & "<required>true</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "<values>"
	bXml = bXml & "<value>Adding to HTS set</value>"
	bXml = bXml & "<value>Poscon</value>"
	bXml = bXml & "<value>Dry Powder Purchase Early Series</value>"
	bXml = bXml & "<value>Dry Powder Purchase Late Series</value>"
	bXml = bXml & "<value>Probe</value>"
	bXml = bXml & "<value>Synthesized Analog Early Series</value>"
	bXml = bXml & "<value>Synthesized Analog Late Series</value>"
	bXml = bXml & "<value>Resynthesis of a DOS compound</value>"
	bXml = bXml & "<value>DOS analog</value>"
	bXml = bXml & "</values>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<name>Restricted Access</name>"
	bXml = bXml & "<required>true</required>"
	bXml = bXml & "<description>Restricted Access</description>"
	bXml = bXml & "<type>Bool</type>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<name>Sample Name</name>"
	bXml = bXml & "<description>Sample Name</description>"
	bXml = bXml & "<required>false</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<name>Comment</name>"
	bXml = bXml & "<description>Comment</description>"
	bXml = bXml & "<required>false</required>"
	bXml = bXml & "<type>MultiLineString</type>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<groupName>SolidTubes</groupName>"
	bXml = bXml & "<name>Barcode</name>"
	bXml = bXml & "<description>barcode</description>"
	bXml = bXml & "<required>false</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<validation>arxreg_isNumber</validation>"
	bXml = bXml & "<groupName>SolidTubes</groupName>"
	bXml = bXml & "<name>Weight</name>"
	bXml = bXml & "<description>weight</description>"
	bXml = bXml & "<required>false</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<groupName>SolidTubes</groupName>"
	bXml = bXml & "<name>Units</name>"
	bXml = bXml & "<description>units</description>"
	bXml = bXml & "<required>true</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "<values>"
	bXml = bXml & "<value>mg</value>"
	bXml = bXml & "<value>g</value>"
	bXml = bXml & "</values>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<groupName>LiquidTubes</groupName>"
	bXml = bXml & "<name>Barcode</name>"
	bXml = bXml & "<description>barcode</description>"
	bXml = bXml & "<required>false</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<validation>arxreg_isNumber</validation>"
	bXml = bXml & "<groupName>LiquidTubes</groupName>"
	bXml = bXml & "<name>Volume</name>"
	bXml = bXml & "<description>volume</description>"
	bXml = bXml & "<required>false</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<groupName>LiquidTubes</groupName>"
	bXml = bXml & "<name>Volume Units</name>"
	bXml = bXml & "<description>volume units</description>"
	bXml = bXml & "<required>false</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "<values>"
	bXml = bXml & "<value>mL</value>"
	bXml = bXml & "<value>uL</value>"
	bXml = bXml & "</values>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<validation>arxreg_isNumber</validation>"
	bXml = bXml & "<groupName>LiquidTubes</groupName>"
	bXml = bXml & "<name>Concentration</name>"
	bXml = bXml & "<description>concentration</description>"
	bXml = bXml & "<required>false</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "</entry>"
	bXml = bXml & "<entry>"
	bXml = bXml & "<groupName>LiquidTubes</groupName>"
	bXml = bXml & "<name>Concentration Units</name>"
	bXml = bXml & "<description>concentration units</description>"
	bXml = bXml & "<required>false</required>"
	bXml = bXml & "<type>String</type>"
	bXml = bXml & "<values>"
	bXml = bXml & "<value>mg/mL</value>"
	bXml = bXml & "<value>mM</value>"
	bXml = bXml & "<value>M</value>"
	bXml = bXml & "</values>"
	bXml = bXml & "</entry>"
	bXml = bXml & "</EntryList>"
End if

'response.write(bxml)

If bXml = "Invalid Email Address" Then
	getFieldTypesError = True
	errorText = "Invalid Email Address"
Else
	If instr(bXml,"<Errors>") > 0 Then
		getFieldTypesError = True
		errorText = getXMLTag("Message",bxml)
	else
		Set xml = server.CreateObject("Microsoft.XMLDOM")
		xml.loadXML(bXML)
		For Each oNode In xml.GetElementsByTagName("EntryList")
			numVisibleFields = 0
			For Each subNode In oNode.SelectNodes("*")
				hidden = false
				For Each entry In subNode.selectNodes("*")
					if entry.nodeName = "hidden" then
						If entry.text = "true" Then
							hidden = True
						End if
					End if
				Next
				If Not hidden Then
					numVisibleFields = numVisibleFields + 1
				End if
			Next
		Next
	End if
End if

sectionId = "regInt"
subSectionId = "add-structure"

addBatch = false
moleculeAdded = false

inFrame = True

If experimentId = "" Then
	experimentId = request.Form("experimentId")
	experimentType = request.Form("experimentNumber")
	revisionNumber = request.form("revisionNumber")
	regFieldId = request.form("regFieldId")
	molData = request.form("regMolData")
	regName = request.Form("regName")
	regExperimentName = request.Form("regExperimentName")
End if


If request.Form("addStructureSubmitHidden") <> "" Then
	efields = ""
	Set xml = server.CreateObject("Microsoft.XMLDOM")
	xml.loadXML(bXML)
	lastGroupName = ""
	For Each oNode In xml.getElementsByTagName("EntryList")
		counter = 0
		For Each subNode In oNode.SelectNodes("*")
			counter = counter + 1
			required = False
			validationFunction = ""
			hidden = False
			isList = False
			theValue = ""
			groupName = ""
			groupStart = False
			isGroup = false
			For Each entry In subNode.selectNodes("*")
				if entry.nodeName = "Hidden" then
					If entry.text = "true" Then
						hidden = True
					End If
				End if
				Select Case LCase(entry.nodeName)
					Case "groupname"
						groupName = entry.text
						isGroup = true
						If groupName <> lastGroupName Then
							groupStart = true
							lastGroupName = groupName
						End if
						counter = counter + 30
						Do While counter Mod 100 <> 0
							counter = counter + 1
						loop
					Case "name"
						name = entry.text
					Case "description"
						description = entry.text
					Case "required"
						If entry.text = "true" Then
							required = True
						Else
							required = False
						End If
					Case "values"
						isList = true
						foundItem = false
						For Each value In entry.selectNodes("*")
							If value.text <> "" Then
								theValue = value.text
							Else
								theValue = value.getAttribute("ID")
							End If
							If theValue = request.Form("formItem_"&counter) Then
								foundItem = true
							End if
						Next
					Case "type"
						fieldType = LCase(entry.text)
					Case "validation"
						validationFunction = LCase(entry.text)
				End Select
			Next
			If groupName = "" And lastGroupName <> "" Then
				counter = counter + 100
				lastGroupName = ""
			End if
			If Not isGroup then
				If hidden Then 
					isList = False
				End If
				If required And Not hidden And request.Form("formItem_"&counter) = "" Or (fieldType="bool" And LCase(request.Form("formItem_"&counter))="false")Then
					efields = efields & "formItem_"&counter&","
				Else
					If validationFunction <> "" Then
						Select Case validationFunction
							Case "arxreg_isinteger"
								If Not arxReg_isInteger(request.Form("formItem_"&counter)) Then
									efields = efields & "formItem_"&counter&","
									errorStr = errorStr & description &": please enter only numbers<br/>"
								End if
							Case "arxreg_isdate"
								If Not arxReg_isDate(request.Form("formItem_"&counter)) Then
									efields = efields & "formItem_"&counter&","
									errorStr = errorStr & description &": please enter a valid date<br/>"
								End If
							Case "arxreg_ispercent"
								If Not arxReg_isPercent(request.Form("formItem_"&counter)) Then
									efields = efields & "formItem_"&counter&","
									errorStr = errorStr & description &": please enter a valid percentage<br/>"
								End If
							Case "arxreg_isnumber"
								If Not arxReg_isNumber(request.Form("formItem_"&counter)) Then
									efields = efields & "formItem_"&counter&","
									errorStr = errorStr & description &": please enter a number<br/>"
								End if
							Case "arxreg_isoracledate"
								If Not arxReg_isOracleDate(request.Form("formItem_"&counter)) Then
									efields = efields & "formItem_"&counter&","
									errorStr = errorStr & description &": please enter a valid date<br/>"
								End if
						End select
					End if
				End If
				If required And isList And Not foundItem Then
					efields = efields & "formItem_"&counter&","
				End If
			Else
				For q = 1 To request.Form(groupName&"_numRows")
					If hidden Then 
						isList = False
					End If
					If required And Not hidden And request.Form("formItem_"&counter) = "" Then
						efields = efields & "formItem_"&counter&","
					Else
						If validationFunction <> "" Then
							Select Case validationFunction
								Case "arxreg_isinteger"
									If Not arxReg_isInteger(request.Form("formItem_"&counter)) Then
										efields = efields & "formItem_"&counter&","
										errorStr = errorStr & groupName&" "& " row "&q&" "& description &" please enter only numbers<br/>"
									End if
								Case "arxreg_isdate"
									If Not arxReg_isDate(request.Form("formItem_"&counter)) Then
										efields = efields & "formItem_"&counter&","
										errorStr = errorStr & groupName&" "& " row "&q&" "& description &" please enter a valid date<br/>"
									End If
								Case "arxreg_ispercent"
									If Not arxReg_isPercent(request.Form("formItem_"&counter)) Then
										efields = efields & "formItem_"&counter&","
										errorStr = errorStr & groupName&" "& " row "&q&" "& description &" please enter a valid percentage<br/>"
									End If
								Case "arxreg_isnumber"
									If Not arxReg_isNumber(request.Form("formItem_"&counter)) Then
										efields = efields & "formItem_"&counter&","
										errorStr = errorStr & groupName&" "& " row "&q&" "& description &" please enter a number<br/>"
									End if
								Case "arxreg_isoracledate"
									If Not arxReg_isOracleDate(request.Form("formItem_"&counter)) Then
										efields = efields & "formItem_"&counter&","
										errorStr = errorStr & groupName&" "& " row "&q&" "& description &" please enter a valid date<br/>"
									End if
							End select
						End if
					End If
					If required And isList And Not foundItem Then
						efields = efields & "formItem_"&counter&","
					End If
					counter = counter + 1
				next
			End if
		Next
	Next
	
	If efields = "" Then
		sdFile = ""
		sdFile = sdFile & request.Form("regMolData")
		If Left(sdFile,2) = vbcrlf Then
			sdFile = "Untitled" & sdFile
		End if
		If Right(sdFile,2) <> vbcrlf Then
			sdFile = sdFile & vbcrlf
		End if
		Call getconnected
		Set tRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT e.name, e.notebookId, u.firstName, u.lastName, u.email FROM experiments e, users u WHERE u.id = e.userId and e.id="&SQLClean(request.Form("experimentId"),"N","S")
		tRec.open strQuery,conn,3,3
		If Not tRec.eof Then
			notebookId = tRec("notebookId")
			userFirstName = tRec("firstName")
			userLastName = tRec("lastName")
			userEmail = tRec("email")
			expName = tRec("name")
		End If
		tRec.close
		strQuery = "SELECT * FROM notebooks WHERE id="&SQLClean(notebookId,"N","S")
		tRec.open strQuery,conn,3,3
		If Not tRec.eof Then
			notebookName = tRec("name")
		End If
		tRec.close
		Set tRec = nothing
		Call disconnect

		experimentPage = ""
		rootAppServerHostName = getCompanySpecificSingleAppConfigSetting("rootAppServerHostName", session("companyId"))
		experimentUrl = "https://" & rootAppServerHostName & "/arxlab/"
		Select Case experimentType
			 Case 1
				experimentPage = "experiment.asp"
			Case 2
				experimentPage = "bio-experiment.asp"
			Case 3
				experimentPage = "free-experiment.asp"
			Case 4
				experimentPage = "anal-experiment.asp"
		End Select
		
		If experimentPage = "" Then
			experimentPage = "experiment.asp"
		End If
		
		experimentUrl = experimentUrl & experimentPage & "?id=" & request.Form("experimentId")
		
		sdFile = sdFile & ">  <arxspan_experiment_name>"&vbcrlf&server.HTMLEncode(request.Form("regExperimentName"))&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_project_name>"&vbcrlf&server.HTMLEncode(projectName)&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_local_reg_number>"&vbcrlf&localRegNumber&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_foreign_reg_number>"&vbcrlf&foreignRegNumber&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_experiment_id>"&vbcrlf&request.Form("experimentId")&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_experiment_url>"&vbcrlf&experimentUrl&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_experiment_owner>"&vbcrlf&userFirstName & " " & userLastName & " ("&userEmail&")"&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_owner_name>"&vbcrlf&notebookOwner&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_owner_email>"&vbcrlf&notebookOwnerEmail&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_owner_fname>"&vbcrlf&userFirstName&" "&userLastName&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_page>"&vbcrlf&expName&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_page_number>"&vbcrlf&Trim(Replace(Replace(regExperimentName,notebookName&" -",""),"-",""))&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_experiment_revision_number>"&vbcrlf&request.form("revisionNumber")&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_name>"&vbcrlf&server.HTMLEncode(notebookName)&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_description>"&vbcrlf&server.HTMLEncode(notebookDescription)&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_notebook_id>"&vbcrlf&notebookId&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_user_email>"&vbcrlf&session("email")&vbcrlf&vbcrlf
		sdFile = sdFile & ">  <arxspan_user_full_name>"&vbcrlf&session("firstName")&" "&session("lastName")&vbcrlf&vbcrlf
		Set xml = server.CreateObject("Microsoft.XMLDOM")
		xml.loadXML(bXML)
		lastGroupName = ""
		For Each oNode In xml.getElementsByTagName("EntryList")
			counter = 0
			For Each subNode In oNode.SelectNodes("*")
				counter = counter + 1
				required = False
				hidden = False
				theValue = ""
				groupName = ""
				groupStart = False
				isGroup = False
				For Each entry In subNode.selectNodes("*")
					isList = False
					if entry.nodeName = "Hidden" then
						If entry.text = "true" Then
							hidden = True
						End If
					End if
					Select Case LCase(entry.nodeName)
						Case "groupname"
							groupName = entry.text
							isGroup = true
							If groupName <> lastGroupName Then
								groupStart = true
								lastGroupName = groupName
							End if
							counter = counter + 30
							Do While counter Mod 100 <> 0
								counter = counter + 1
							loop
						Case "name"
							name = entry.text
						Case "description"
							description = entry.text
						Case "values"
							isList = true
							foundItem = false
							For Each value In entry.selectNodes("*")
								If value.text <> "" Then
									theValue = value.text
								Else
									theValue = value.getAttribute("ID")
								End If
								If theValue = request.Form("formItem_"&counter) Then
									foundItem = true
								End if
							Next
						Case "type"
							fieldType = LCase(entry.text)
					End Select
				Next
				If groupName = "" And lastGroupName <> "" Then
					counter = counter + 100
					lastGroupName = ""
				End if
			If Not isGroup then
				If hidden And theValue <> "" Then
					theData = theValue
					If fieldType = "oracleDate" Then
						theData = UCase(theData)
					End if
				Else
					If request.Form("formItem_"&counter) = "-1" then
						theData = ""
					Else
						theData = request.Form("formItem_"&counter)
						
					End if
				End If
				If fieldType = "bool" Then
					If request.Form("formItem_"&counter) ="on" Then
						theData = "true"
					Else
						theData = "false"
					End if
				End if
				sdFile = sdFile & ">  <"&name&">"&vbcrlf&server.HTMLEncode(Trim(theData))&vbcrlf&vbcrlf
			Else
				If groupStart Then
					sdFile = sdFile & ">  <"&groupName&"_numRows>"&vbcrlf&server.HTMLEncode(request.Form(groupName&"_numRows"))&vbcrlf&vbcrlf
				End if
				For q = 1 To request.Form(groupName&"_numRows")
					If hidden And theValue <> "" Then
						theData = theValue
						If fieldType = "oracleDate" Then
							theData = UCase(theData)
						End if
					Else
						If request.Form("formItem_"&counter) = "-1" then
							theData = ""
						Else
							theData = request.Form("formItem_"&counter)
						End if
					End If
					If fieldType = "bool" Then
						If request.Form("formItem_"&counter) ="on" Then
							theData = "true"
						Else
							theData = "false"
						End if
					End if
					sdFile = sdFile & ">  <"&groupName&"_"&name&"_"&q&">"&vbcrlf&server.HTMLEncode(Trim(theData))&vbcrlf&vbcrlf
					counter = counter + 1
				Next
			End if
			Next
		Next
		sdFile = sdFile & "$$$$"
		'response.write("addStructureInt2: " & sdFile)

		soapEnv = "<?xml version=""1.0"" encoding=""utf-8""?>" &_
		"    <insertStructure>"&_
		"      <sdfile>"&server.HTMLEncode(sdFile)&"</sdfile>"&_
		"    </insertStructure>"
		'response.write("<label for='insertStructureText'>For testing. Call to insert structure "&accordServicePath&"/insertStructure?email="&server.urlencode(theEmailAddress)&"</label>")
		'response.write("<textarea name='insertStructureText' rows='30' cols='85'>")
		'response.write(soapEnv)
		'response.write("</textarea>")

		set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
		xmlhttp.setOption 2, 13056
		xmlhttp.Open "POST",accordServicePath&"/insertStructure?email="&server.urlencode(theEmailAddress),True
		xmlhttp.setRequestHeader "Content-Type", "text/xml"
		xmlhttp.send soapEnv
		xmlhttp.waitForResponse(60)
		retStr = HTMLDecode(xmlhttp.responsexml.xml)
		firstRetStr = retStr
		'retStr = "<result><regnumber>SEP-324232</regnumber></result>"
		'retStr = "<result><errors><message>hey</message></errors></result>"
		firstRetStr = retStr
		'response.write("<br/><label for='insertStructureTextReturn'>For testing. Return from insert structure</label>")
		'response.write("<textarea name='insertStructureTextReturn' rows='15' cols='85'>")
		'If retStr = "" Then
		'	response.write(xmlhttp.responseText)
		'else
		'	response.write(retStr)
		'End if
		'response.write("</textarea>")
		If retStr = "" Then
			response.write("<br/><label>Insert Structure did not return xml showing html(?) in Iframe</label>")
			response.write("<iframe width=700 height=200 src='data:text/html;charset=utf-8,"&HTMLDecode(Replace(Replace(xmlhttp.responseText,"'","\'"),vbcrlf,""))&"'></iframe>")
		End if
		If InStr(lcase(retStr),"<regnumber>") >0 Then
			success = True
			compoundNumber = getXMLTag("regnumber",retStr)
			compoundURL = getXMLTag("URL",retStr)

		Else
			regError = True
			errorText = getXMLTag("Message",retStr)
			If errorText = "" Then
				errorText = "Unspecified Error"
			End if
		End if
		Set xmlhttp = Nothing

		Call getconnected
		a = logAction(2,experimentId,"",16)
		Call disconnect

	End if
End if
%>

<html>
<head>
<link href="<%=mainCSSPath%>/reg-styles.css?<%=jsRev%>" rel="stylesheet" type="text/css" media="screen">

<script src="/arxlab/jqfu/js/jquery-1.10.2.js?<%=jsRev%>"></script>
<style type="text/css">@import url(<%=mainAppPath%>/js/jscalendar/calendar-win2k-1.css);</style>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/lang/calendar-en.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar-setup.js?<%=jsRev%>"></script>

<script type="text/javascript" src="<%=mainAppPath%>/js/getFile2.js?<%=jsRev%>"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript">
	hasMarvin = <%=LCase(CStr(session("useMarvin")))%>
</script>

<style type="text/css">
	.regIntGroupHolder input{
		width:100px!important;
	}
	.regIntGroupHolder select{
		width:105px!important;
	}
	.regIntGroupHolder table{
		margin-left:8px;
	}
	.regIntGroupHolder th{
		font-size:14px;!important;
		text-align:center;
	}
	.regIntGroupHolder label{
		padding-top:16px;
		font-size:16px;!important;
	}
	.regIntGroupHolder img{
		border:none;!important;
	}
	.regIntGroupHolder .addLink img{
		margin-left:8px;
		vertical-align:middle;
		margin-right:3px;
	}
	.regIntGroupHolder .addLink{
		display:block;
		margin-top:5px;
		margin-bottom:5px;
		color:#666;
	}
	.regIntGroupHolder .errField{
		border:1px solid red;
	}
	.regIntGroupHolder table td,th{
		padding:2px;
		text-align:center;
		border-collapse:collapse;
		border:1px solid #888;
		background-color:#eee;
	}
	.regIntGroupHolder .deleteTD{
		width:25px;
	}
</style>

</head>
<body>
<%If Not success And efields = "" And not regError And not getFieldTypesError And session("hasAccordInt") then%>
<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM finalRegNumbers WHERE accMolId="&SQLClean(accMolsId,"N","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
%>
<script type="text/javascript">
 if(!confirm("This compound has already been registered from this notebook.  Are you sure you want to re-register it?")){
	 window.parent.hidePopup('regDiv');
 }
</script>
<%
End If
rec.close
Set rec = nothing
Call disconnectJchemReg
%>
<%End if%>

<div class="registrationPage" style="font-family:Arial">
<br>
<%If moleculeAdded then%>
<div class="regSuccessDiv">
	Molecule Added: <%=wholeRegNumberLink%>
</div>
<%End if%>
<form action="addStructureInt2.asp?inFrame=<%=request.querystring("inFrame")%>&sourceId=<%=sourceId%>" method="post" onsubmit="document.getElementById('addStructureSubmit').disabled=true;document.getElementById('addStructureSubmit').value='WAIT';processGroups();return true;">
<div style="z-index:100000;">
<H1 style="margin-left:10px;margin-top:0px;">Register Compound</H1>
<%If efields <> "" Or regError Or getFieldTypesError Then%>
<div style="margin-bottom:5px;"><p style="color:red;margin-left:10px;font-weight:bold;margin-bottom:10px;"><%If regError Or getFieldTypesError then%><%=errorText%><%else%>Please correct the errors highlighted in red<%End if%><%If errorStr <> "" then%><br/><%=errorStr%><%End if%></p></div>
<%End if%>
</div>

<!--<% response.write("regMolData: " & Replace(request.Form("regMolData"),vbcrlf,vbnl))%>-->

<div id="addStructureContainer" style="width:400px;height:200px">
<div class="objectBox" style="width:400px;height:200px">
<div id="chemDrawWin" class="chemDrawWin" style="width:400px;height:200px">
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<div id="addStructureIntTwoAspChemBox">
</div>
<script type="text/javascript">
	<%If session("useChemDrawForLiveEdit") Then%>
		useChemDrawForLiveEdit = true;
	<%End If%>
	var initialMolData = "";
	<%if molData <> "" then%>
		initialMolData = "<%=replace(molData,vbcrlf,"\n")%>";
    <%end if%>
    getChemistryEditorMarkup("addStructureCDX", "", initialMolData, 400, 200, true).then(function (theHtml) {
        $("#addStructureIntTwoAspChemBox").html(theHtml);
    });

	function getMappedElnVar(elnElemName,formElemName,mapType) {
		elnElem = window.parent.document.getElementById(elnElemName);
		
		//console.log(elnElemName);
		//console.log(formElemName);
		//console.log(mapType);
		
		if (mapType == "") {
			//console.log("no map, regturning: ",elnElem.value);
			return elnElem.value;
		}
		else if (mapType == "string") {
			return elnElem.value.replace(/[0-9.]/g,'').trim();
		}
		else if (mapType == "int" || mapType == "integer") {
			return elnElem.value.replace(/[^0-9]/g,'').trim();
		}
		else if (mapType == "ranges" || mapType == "select") {
			formElem = document.getElementById(formElemName);
			if (formElem.tagName === 'SELECT') {
				tvalue = elnElem.value.replace(/[^0-9]/g,'');

				//console.log("checking ranges",tvalue);
				
				for (i = 0; i < formElem.options.length;i++) {
					val = formElem.options[i].value.replace(/[[%-]/g,' ').trim();
					vals = val.split(" ");
					
					if (val.startsWith(">")) {
						num = parseInt(val.replace(/[^0-9]/g,''),10)+1;
						vals = [num.toString(),"-1"]
					}
					else if (val.startsWith("<")) {
						num = parseInt(val.replace(/[^0-9]/g,''),10)-1;
						vals = ["-1",num.toString()]
					}
					
					//console.log(val);
					//console.log(vals);
					
					if (vals.length == 2) {
						min = parseInt(vals[0],10);
						max = parseInt(vals[1],10);
					
						if ((min == -1 || tvalue >= min) && (max == -1 || tvalue <= max)) {
							//console.log("returning",formElem.options[i].value);
							return formElem.options[i].value;
						}
					}
				}
			}
		}
	}
</script>
</div>
</div>
</div>
<div class="regInfoDiv regIntegrated">
<%
If Not getFieldTypesError then
	Dim values()
	Dim texts()
	Set xml = server.CreateObject("Microsoft.XMLDOM")
	xml.loadXML(bXML)
	response.write(xml.parseError.reason)
	jsGridStr = ""
	jsGroupStr = ""
	jsSubmitStr = ""
	lastGroupName = ""
	For Each oNode In xml.getElementsByTagName("EntryList")
		counter = 0
		visibleCounter = 0 
		For Each subNode In oNode.SelectNodes("*")
			counter = counter + 1
			required = False
			hidden = False
			isList = False
			defaultValue = ""
			readOnly = False
			elnVar = ""
			mapType = ""
			groupName = ""
			groupStart = False
			isGroup = False
			For Each entry In subNode.selectNodes("*")
				if entry.nodeName = "hidden" then
					If entry.text = "true" Then
						hidden = True
						fieldType = "hidden"
					End if
				End if
				Select Case LCase(entry.nodeName)
					Case "groupname"
						groupName = entry.text
						isGroup = true
						If groupName <> lastGroupName Then
							groupStart = true
							lastGroupName = groupName
						End if
						counter = counter + 30
						Do While counter Mod 100 <> 0
							counter = counter + 1
						loop
					Case "name"
						name = entry.text
					Case "elnvar"
						elnVar = entry.text
					Case "maptype"
						mapType = entry.text
					Case "readonly"
						If LCase(entry.text) = "true" Then
							readOnly = true
						End if
					Case "description"
						description = entry.text
					Case "required"
						If entry.text = "true" Then
							required = True
						Else
							required = False
						End If
					Case "defaultvalue"
						defaultValue = entry.text
					Case "values"
						isList = true
						valuesCounter = 0
						For Each value In entry.selectNodes("*")
							valuesCounter = valuesCounter + 1
						Next
						ReDim values(valuesCounter - 1)
						ReDim texts(valuesCounter - 1)
						valuesCounter = 0
						For Each value In entry.selectNodes("*")
							valuesCounter = valuesCounter + 1
							If value.text <> "" Then
								theValue = value.text
							Else
								theValue = value.getAttribute("ID")
							End If
							theText = value.text
							values(valuesCounter-1)=theValue
							If theText = "" Then
								theText = theValue
							End if
							texts(valuesCounter-1)=theText
						Next
					Case "type"
						fieldType = LCase(entry.text)
				End Select
			Next
			If groupName = "" And lastGroupName <> "" Then
				counter = counter + 100
				lastGroupName = ""
			End if
			If elnVar <> "" Then
				If Not isGridField(elnVar) then
					defaultValue = getElnVar(elnVar)
				Else
					jsGridStr = jsGridStr & "document.getElementById('formItem_"&counter&"').value=getMappedElnVar('"&molPrefix&"_"&elnVar&"','formItem_"&counter&"','"&mapType&"');"&vbcrlf
				End if
			End If
			
			If groupStart Then
				jsGroupStr = jsGroupStr & "processGroup('"&groupName&"');"
				If request.Form(groupName&"_numRows") = "" Then
					thisGroupNumRows = 1
				Else
					thisGroupNumRows = request.Form(groupName&"_numRows")
				End if
				%><input type="hidden" id="<%=Replace(groupName,"""","\""")%>_numRows" name="<%=Replace(groupName,"""","\""")%>_numRows" class="<%=Replace(groupName,"""","\""")%>_numRows" value="<%=Replace(thisGroupNumRows,"""","\""")%>"><%
			End if
			If 1=1 Then
			%>
			<%If fieldType <> "hidden" then 
				visibleCounter = visibleCounter + 1
			%>
				<%If groupStart then%>
					<div id="<%=groupName&"_holder"%>" class="regIntGroupHolder">
					<label for="formItem_<%=counter%>" style="width:260px;"><%=groupName%></label>
					</div>
				<%else%>
					<%If Not isGroup then%>
					<label for="formItem_<%=counter%>" <%If InStr(efields,"formItem_"&counter&",") Then%>style="color:red;width:260px;"<%End if%> style="width:260px;"><%=description%><%if required then%>*<%End if%></label>
					<%End if%>
				<%End if%>
			<%End if%>
			<%If isGroup then%>
				<input type="hidden" class="<%=Replace(groupName,"""","\""")%>_fieldName" value="<%=Replace(name,"""","\""")%>">
				<input type="hidden" class="<%=Replace(groupName,"""","\""")%>_fieldDescription" value="<%=Replace(description,"""","\""")%>">
				<input type="hidden" class="<%=Replace(groupName,"""","\""")%>_defaultValue" value="<%=Replace(defaultValue,"""","\""")%>">
				<%
					optionStr = ""
					If isList then
						For i = 0 To UBound(values)
							If i <> 0 Then
								optionStr = optionStr & "###"
							End If
							optionStr = optionStr & values(i)
						next
					End If
				%>
				<input type="hidden" class="<%=Replace(groupName,"""","\""")%>_options" value="<%=Replace(optionStr,"""","\""")%>">
				<%
					theType = LCase(fieldType)
					If LCase(fieldType)="multilinestring" Then
						theType = "textarea"
					End If
					If LCase(fieldType)="string" Then
						theType = "text"
					End If
					If LCase(fieldType)="bool" Then
						theType = "checkbox"
					End If
					If isList Then
						theType = "select"
					End If
				%>
				<input type="hidden" class="<%=Replace(groupName,"""","\""")%>_type" value="<%=Replace(theType,"""","\""")%>">
				<input type="hidden" class="<%=Replace(groupName,"""","\""")%>_startCounter" value="<%=Replace(counter,"""","\""")%>">
			<%End if%>
			<%
			If isList Then
				%>
				<%If isGroup then%>
					<%For j = 1 To thisGroupNumRows%>
						<select name="formItem_<%=counter%>" id="formItem_<%=counter%>" groupfield="<%=Replace(groupName,"""","\""")%>_<%=Replace(name,"""","\""")%>" <%If InStr(efields,"formItem_"&counter&",") Then%>class="errField"<%End if%>>
						<option value="-1">--SELECT--</option>
						<%
						For i = 0 To UBound(values)
							%>
							<option value="<%=values(i)%>" <%If request.Form("formItem_"&counter)=values(i) Then response.write("selected")End if%><%If Not IsNull(defaultValue) And Not IsNull(texts(i)) then%><%If request.Form("addStructureSubmitHidden") = "" And CStr(defaultValue) = CStr(texts(i)) then%> selected <%End if%><%End if%>><%=texts(i)%></option>
							<%
						Next
						%>
							</select>					
					<%
						counter = counter + 1
					next%>
				<%else%>
					<select name="formItem_<%=counter%>" id="formItem_<%=counter%>">
					<option value="-1">--SELECT--</option>
					<%
					For i = 0 To UBound(values)
						%>
						<option value="<%=values(i)%>" <%If request.Form("formItem_"&counter)=values(i) Then response.write("selected")End if%><%If Not IsNull(defaultValue) And Not IsNull(texts(i)) then%><%If request.Form("addStructureSubmitHidden") = "" And CStr(defaultValue) = CStr(texts(i)) then%> selected <%End if%><%End if%>><%=texts(i)%></option>
						<%
					Next
					%>
						</select><br/>
				<%End if%>
				<%
			Else
				If fieldType = "multilinestring" Then
					%>
					<%If isGroup then%>
						<%For j = 1 To thisGroupNumRows%>
							<textarea name="formItem_<%=counter%>" id="formItem_<%=counter%>" groupfield="<%=Replace(groupName,"""","\""")%>_<%=Replace(name,"""","\""")%>" <%If InStr(efields,"formItem_"&counter&",") Then%>class="errField"<%End if%>><%If request.Form("addStructureSubmitHidden") = "" And defaultValue <> "" then%><%=defaultValue%><%else%><%=request.Form("formItem_"&counter)%><%End if%></textarea>
						<%
							counter = counter + 1
						next%>
					<%else%>
						<textarea name="formItem_<%=counter%>" id="formItem_<%=counter%>" style="width:260px;"><%If request.Form("addStructureSubmitHidden") = "" And defaultValue <> "" then%><%=defaultValue%><%else%><%=request.Form("formItem_"&counter)%><%End if%></textarea><br/>			
					<%End if%>
					<%
				else
			%>
				<%If fieldType <> "bool" And fieldType <> "hidden" Then%>
					<%If isGroup then%>
						<%For j = 1 To thisGroupNumRows%>
							<input type="text" name="formItem_<%=counter%>" id="formItem_<%=counter%>" <%If request.Form("addStructureSubmitHidden") = "" And defaultValue <> "" then%>value="<%=defaultValue%>"<%else%>value="<%=request.Form("formItem_"&counter)%>"<%End if%> <%If readOnly then%>readonly<%End if%> groupfield="<%=Replace(groupName,"""","\""")%>_<%=Replace(name,"""","\""")%>" <%If InStr(efields,"formItem_"&counter&",") Then%>class="errField"<%End if%>>
							<%If fieldType="date" then%>
							<script type="text/javascript">
							  Calendar.setup(
								{
								  inputField  : "formItem_<%=counter%>",         // ID of the input field
								  ifFormat    : "%m/%d/%Y",    // the date format
								  showsTime   : false,
								  timeFormat  : "12",
								  electric    : false
								}
							  );
							</script>
							<%End if%>
							<%If fieldType="oracledate" then%>
							<script type="text/javascript">
							  Calendar.setup(
								{
								  inputField  : "formItem_<%=counter%>",         // ID of the input field
								  ifFormat    : "%d-%b-%y",    // the date format
								  showsTime   : false,
								  timeFormat  : "12",
								  electric    : false
								}
							  );
							</script>
							<%End if%>
						<%
							counter = counter + 1
						next%>
					<%else%>
						<%
						styleStr = ""
						If fieldType<>"date" And fieldType<>"oracledate" And fieldType<>"bool" Then
							styleStr = "style=""width:260px;"""
						End If
						%>
						<input type="text" name="formItem_<%=counter%>" id="formItem_<%=counter%>" <%=styleStr%> <%If request.Form("addStructureSubmitHidden") = "" And defaultValue <> "" then%>value="<%=defaultValue%>"<%else%>value="<%=request.Form("formItem_"&counter)%>"<%End if%> <%If readOnly then%>readonly<%End if%>><br/>
						<%If fieldType="date" then%>
						<script type="text/javascript">
						  Calendar.setup(
							{
							  inputField  : "formItem_<%=counter%>",         // ID of the input field
							  ifFormat    : "%m/%d/%Y",    // the date format
							  showsTime   : false,
							  timeFormat  : "12",
							  electric    : false
							}
						  );
						</script>
						<%End if%>
						<%If fieldType="oracledate" then%>
						<script type="text/javascript">
						  Calendar.setup(
							{
							  inputField  : "formItem_<%=counter%>",         // ID of the input field
							  ifFormat    : "%d-%b-%y",    // the date format
							  showsTime   : false,
							  timeFormat  : "12",
							  electric    : false
							}
						  );
						</script>
						<%End if%>
					<%End if%>
				<%else%>
					<%If fieldType <> "hidden" Then%>
						<%If isGroup then%>
							<%For j = 1 To thisGroupNumRows%>
								<input type="checkbox" name="formItem_<%=counter%>" id="formItem_<%=counter%>" <%If request.Form("formItem_"&counter) = "on" then%> checked<%else%><%If request.Form("addStructureSubmitHidden") = "" And LCase(defaultValue)="true" then%> checked<%End If End if%> groupfield="<%=Replace(groupName,"""","\""")%>_<%=Replace(name,"""","\""")%>" <%If InStr(efields,"formItem_"&counter&",") Then%>class="errField"<%End if%>>
							<%
								counter = counter + 1
							next%>
						<%else%>
							<input type="checkbox" name="formItem_<%=counter%>" id="formItem_<%=counter%>" <%If request.Form("formItem_"&counter) = "on" then%> checked<%else%><%If request.Form("addStructureSubmitHidden") = "" And LCase(defaultValue)="true" then%> checked<%End If End if%>>
						<%End if%>
					<%End if%>
				<%End if%>
				<%If fieldType = "hidden" Then%>
					<%If isGroup then%>
							<%For j = 1 To thisGroupNumRows%>
								<input type="hidden" name="formItem_<%=counter%>" id="formItem_<%=counter%>" <%If request.Form("addStructureSubmitHidden") = "" And defaultValue <> "" then%>value="<%=defaultValue%>"<%else%>value="<%=request.Form("formItem_"&counter)%>"<%End if%> groupfield="<%=Replace(groupName,"""","\""")%>_<%=Replace(name,"""","\""")%>">
							<%
								counter = counter + 1
							next%>
					<%else%>
						<input type="hidden" name="formItem_<%=counter%>" id="formItem_<%=counter%>" <%If request.Form("addStructureSubmitHidden") = "" And defaultValue <> "" then%>value="<%=defaultValue%>"<%else%>value="<%=request.Form("formItem_"&counter)%>"<%End if%>><br/>
					<%End if%>
				<%End if%>
			<%
				End if
			End If
			End if
		Next
	next
End if

%>
</div>
<div style="height:0px;width:0px;clear:both;">

<input type="hidden" name="oldCDX" id="oldCDX" value="<%=replace(oldCdxml,"""","&quot;")%>">
<input type="hidden" name="experimentId" id="experimentId" value="<%=experimentId%>">
<input type="hidden" name="experimentType" id="experimentType" value="<%=experimentType%>">
<input type="hidden" name="revisionNumber" id="revisionNumber" value="<%=revisionNumber%>">
<input type="hidden" name="regMolData" id="regMolData" value="<%=molData%>">
<input type="hidden" name="regMolData2000" id="regMolData2000" value="<%=request.Form("regMolData2000")%>">
<input type="hidden" name="regName" id="regName" value="<%=regName%>">
<input type="hidden" name="regExperimentName" id="regExperimentName" value="<%=regExperimentName%>">
<input type="hidden" name="regFieldId" id="regFieldId" value="<%=regFieldId%>">
<input type="hidden" name="addStructureSubmitHidden" id="addStructureSubmitHidden" value="REGISTER">
<input type="hidden" name="regNotebookId" id="regNotebookId" value="<%=regNotebookId%>">
<input type="hidden" name="foreignRegNumber" name="foreignRegNumber" value="<%=foreignRegNumber%>">
<input type="hidden" name="localRegNumber" name="localRegNumber" value="<%=localRegNumber%>">
<input type="hidden" name="molPrefix" name="molPrefix" value="<%=molPrefix%>">
<input type="hidden" name="regNotebookName" name="regNotebookName" value="<%=notebookName%>">
</div>

<%If Not getFieldTypesError then%>
<input type="submit" name="addStructureSubmit" id="addStructureSubmit" value="REGISTER" style="margin-bottom:10px;">
<%End if%>
</form>




</div>

<%If jsGridStr <> "" then%>
	<script type="text/javascript">
		<%=jsGridStr%>
	</script>
<%End if%>

<%If jsGroupStr <> "" then%>
	<script src="/arxlab/jqfu/js/jquery-1.10.2.js?<%=jsRev%>"></script>
	<script type="text/javascript">
		function processGroup(groupName){
			fieldNames = [];
			fieldDescriptions = [];
			fieldTypes = [];
			numRows = 0;
			numFields = 0;
			$("."+groupName+"_numRows").each(function(i,el){
				numRows = $(el).val();
			})
			$("."+groupName+"_fieldName").each(function(i,el){
				fieldNames.push($(el).val());
				numFields += 1;
			})
			$("."+groupName+"_fieldDescription").each(function(i,el){
				fieldDescriptions.push($(el).val());
			})
			table = document.createElement("table");
			table.setAttribute("id",groupName+"_table");
			table.setAttribute("cellspacing","0");
			table.setAttribute("cellpadding","0");
			tbody = document.createElement("tbody");
			tr = document.createElement("tr");
			for(var i=0;i<fieldDescriptions.length;i++){
				th = document.createElement("th");
				th.appendChild(document.createTextNode(fieldDescriptions[i]))
				tr.appendChild(th);
			}
			th = document.createElement("th");
			tr.appendChild(th)
			tbody.appendChild(tr);
			for(var i=0;i<numRows;i++){
				tr = document.createElement("tr");
				for(var j=0;j<fieldNames.length;j++){
					td = document.createElement("td");
					$("[groupfield='"+groupName+"_"+fieldNames[j]+"']").each(function(k,el){
						if (k==0){
							$(el).detach().appendTo(td)
						}
					})
					tr.appendChild(td)
				}
				a = document.createElement("a")
				a.href = "javascript:void(0)";
				a.onclick = function(){
					$(this).parent().parent().remove()
				}
				img = document.createElement("img");
				img.src = "/arxlab/images/delete.gif";
				img.setAttribute("border","0");
				img.setAttribute("width","12")
				a.appendChild(img);
				td = document.createElement("td");
				td.className = "deleteTD"
				td.appendChild(a);
				tr.appendChild(td);
				tbody.appendChild(tr)
			}

			table.appendChild(tbody)
			document.getElementById(groupName+"_holder").appendChild(table);
			div = document.createElement("div")
			a = document.createElement("a");
			a.href = "javascript:void(0)";
			a.onclick = function(){
				addNewRow(groupName);
			}
			img = document.createElement("img");
			img.src = "/arxlab/images/add.gif";
			img.setAttribute("border","0");
			img.setAttribute("width","16");
			a.appendChild(img);
			a.className = "addLink"
			a.appendChild(document.createTextNode("Add Row"))
			document.getElementById(groupName+"_holder").appendChild(a);
		}

		function addNewRow(groupName){
			fieldNames = [];
			fieldDescriptions = [];
			fieldTypes = [];
			fieldDefaultValues = [];
			fieldOptions = [];
			$("."+groupName+"_fieldName").each(function(i,el){
				fieldNames.push($(el).val());
			})
			$("."+groupName+"_fieldDescription").each(function(i,el){
				fieldDescriptions.push($(el).val());
			})
			$("."+groupName+"_type").each(function(i,el){
				fieldTypes.push($(el).val().toLowerCase());
			})
			$("."+groupName+"_defaultValue").each(function(i,el){
				fieldDefaultValues.push($(el).val());
			})
			$("."+groupName+"_options").each(function(i,el){
				fieldOptions.push($(el).val());
			})
			tr = document.createElement("tr");
			for(var i=0;i<fieldNames.length;i++){
				td = document.createElement("td");
				if(fieldTypes[i]=="select"){
					el = document.createElement("select");
					option = document.createElement("option")
					option.setAttribute("value","-1");
					option.appendChild(document.createTextNode("--SELECT--"));
					el.appendChild(option);
					theOptions = fieldOptions[i].split("###");
					for(var j=0;j<theOptions.length;j++){
						option = document.createElement("option")
						option.setAttribute("value",theOptions[j]);
						option.appendChild(document.createTextNode(theOptions[j]));
						el.appendChild(option);
					}
					
				}
				if(fieldTypes[i]=="text"){
					el = document.createElement("input");
					el.setAttribute("type","text")
				}
				if(fieldTypes[i]=="textarea"){
					el = document.createElement("textarea");
				}
				if(fieldTypes[i]=="checkbox"){
					el = document.createElement("input");
					el.setAttribute("type","checkbox")
				}
				if(fieldTypes[i]=="date"){
					el = document.createElement("input");
					el.setAttribute("type","text");
					//turning on calendar doesnt work start
					randomId = Math.random();
					el.setAttribute("id",randomId);
					Calendar.setup(
						{
						  inputField  : randomId,         // ID of the input field
						  ifFormat    : "%m/%d/%Y",    // the date format
						  showsTime   : false,
						  timeFormat  : "12",
						  electric    : false
						}
					  );
					//turning on calendar doesnt work end
				}
				if(fieldTypes[i]=="oracledate"){
					el = document.createElement("input");
					el.setAttribute("type","text");
					//turning on calendar doesnt work start
					randomId = Math.random();
					el.setAttribute("id",randomId);
					Calendar.setup(
						{
						  inputField  : randomId,         // ID of the input field
						  ifFormat    : "%d-%b-%y",    // the date format
						  showsTime   : false,
						  timeFormat  : "12",
						  electric    : false
						}
					  );
					//turning on calendar doesnt work end
				}
				<%If request.Form("addStructureSubmitHidden") = "" then%>
				if(fieldDefaultValues[i]!=""){
					if(fieldTypes[i]!="checkbox"){
						$(el).val(fieldDefaultValues[i]);
					}else{
						if(fieldDefaultValues[i].toLowerCase()=="true"){
							$(el).prop("checked",true);
						}else{
							$(el).prop("checked",false);
						}
					}
				}
				<%end if%>
				el.setAttribute("groupfield",groupName+"_"+fieldNames[i])
				td.appendChild(el)
				tr.appendChild(td);
			}

			a = document.createElement("a")
			a.href = "javascript:void(0)";
			a.onclick = function(){
				$(this).parent().parent().remove()
			}
			img = document.createElement("img");
			img.src = "/arxlab/images/delete.gif";
			img.setAttribute("border","0");
			img.setAttribute("width","12")
			a.appendChild(img);
			td = document.createElement("td");
			td.appendChild(a);
			tr.appendChild(td);
			
			document.getElementById(groupName+"_table").getElementsByTagName("tbody")[0].appendChild(tr)
		}
		<%=jsGroupStr%>
		function processGroups(){
			groupNames = [];
			$(".regIntGroupHolder").each(function(i,el){
				groupNames.push($(el).attr("id").replace("_holder",""));
			})
			for(var i=0;i<groupNames.length;i++){
				groupName = groupNames[i];
				fieldNames = [];
				fieldCounters = [];
				$("."+groupName+"_fieldName").each(function(j,el){
					fieldNames.push($(el).val());
				})
				$("."+groupName+"_startCounter").each(function(j,el){
					fieldCounters.push($(el).val());
				})
				for(var j=0;j<fieldNames.length;j++){
					counter = parseInt(fieldCounters[j]);
					numRows = 0
					$("[groupfield='"+groupName+"_"+fieldNames[j]+"']").each(function(k,el){
						numRows += 1;
						$(el).attr("id","formItem_"+counter);
						$(el).attr("name","formItem_"+counter);
						counter += 1;
					})
				}
				$("#"+groupName+"_numRows").val(numRows);
			}
		}
	</script>
<%End if%>

<%If success then%>
	<script type="text/javascript">
		window.parent.document.getElementById(document.getElementById("regFieldId").value).value = '<a href="<%=compoundURL%>"><%=compoundNumber%></a>';
		window.parent.experimentJSON[document.getElementById("regFieldId").value] = '<a href="<%=compoundURL%>"><%=compoundNumber%></a>';
		window.parent.hidePopup('regDiv');
		window.location='<%=mainAppPath%>/static/blank.html'
		window.parent.unsavedChanges=false;
		window.parent.experimentSubmit(false,false,false);
	</script>
<%End if%>

<%
	regIntTurnOffAutoComplete = checkBoolSettingForCompany("disableAutoCompleteForRegIntegration", session("companyId"))
	If regIntTurnOffAutoComplete Then
%>
<script type="text/javascript">
$(document).ready(function(){
    $( document ).on( 'focus', ':input', function(){
        $( this ).attr( 'autocomplete', 'off' );
    });
});
</script>
<%End if%>

</body>
</html>