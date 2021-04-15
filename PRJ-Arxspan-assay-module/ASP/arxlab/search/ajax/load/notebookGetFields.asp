<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->

<%
	If session("hasChemistry") then
		objectTypeList = "["&"[""1"",""Experiment Id""],[""2"",""Reactant""],[""3"",""Product""],[""4"",""Solvent""],[""5"",""Attachment""],[""6"",""Note""],[""7"",""Comment""]"&"]"
	Else
		objectTypeList = "["&"[""1"",""Experiment Id""],[""5"",""Attachment""],[""6"",""Note""],[""7"",""Comment""]"&"]"
	End If
	If session("hasChemistry") then
		experimentTypeList = "["&"[""1"",""Chemistry""],[""2"",""Biology""],[""3"",""Concept""],[""4"",""Analysis""]]"
	Else
		experimentTypeList = "["&"[""2"",""Biology""],[""3"",""Concept""],[""4"",""Analysis""]]"
	End if
	statusList = "["&"[""created"",""created""],[""saved"",""saved""],[""signed - open"",""signed - open""],[""reopened"",""reopened""],[""signed - closed"",""signed - closed""],[""witnessed"",""witnessed""],[""rejected"",""rejected""]"&"]"
	intBoolList = "["&"[""1"",""True""],[""2"",""False""]"&"]"
	selectOptions = "[["""",""OTHER"",""none""],["" "",""----"",""none""],[""objectTypeId"",""Object Type"",""actual_number"","&objectTypeList&"],[""experimentType"",""Experiment Type"",""actual_number"","&experimentTypeList&"],[""projectId|parentProjectId"",""Project"",""actual_number"","&session("projectJSON")&"],["" "","" "",""none""],["" "",""Experiment"",""none""],["" "",""----"",""none""],[""experimentName"",""Name"",""text""],[""dateSubmitted"",""Date Created"",""date""],[""dateSubmitted"",""Date Modified"",""date""],[""firstName"",""First Name"",""text""],[""lastName"",""Last Name"",""text""],[""status"",""Status"",""text"","&statusList&"],[""revisionNumber"",""Revision Number"",""actual_number""],"
	If session("hasChemistry") then
		selectOptions = selectOptions & "[""searchPreparation"",""Preparation"",""long_text""],[""pressure"",""Pressure"",""actual_number""],[""temperature"",""Temperature"",""actual_number""],[""reactionMolarity"",""Reaction Molarity"",""actual_number""],"
	End if
	selectOptions = selectOptions & "[""protocol"",""Protocol"",""long_text""],[""summary"",""Summary"",""long_text""],[""details"",""Experiment Description"",""text""],[""notebookName"",""Notebook Name"",""text""],["" "","" "",""none""],["" "",""Attachment"",""none""],["" "",""----"",""none""],[""[name]"",""Attachment Name"",""text""],[""dateSubmitted"",""Date Created"",""date""],[""description"",""Attachment Description"",""text""],[""filename"",""File Name"",""text""],[""searchText"",""Text In File"",""long_text""],["" "","" "",""none""],["" "",""Note"",""none""],["" "",""----"",""none""],[""[name]"",""Note Name"",""text""],[""dateSubmitted"",""Date Created"",""date""],[""note"",""Note"",""text""],["" "","" "",""none""],["" "",""Comment"",""none""],[""[name]"",""Comment"",""text""],[""dateSubmitted"",""Date Created"",""date""],["" "","" "",""none""]"
	If session("hasChemistry") then
		selectOptions = selectOptions & ",["" "",""Reactant/Reagent"",""none""],["" "",""----"",""none""],[""chemicalName"",""Reactant Name"",""text""],[""molecularWeight"",""Molecular Weight"",""actual_number""],[""molecularFormula"",""Molecular Formula"",""text""],[""supplier"",""Supplier"",""text""],[""equivalents"",""Equivalents"",""actual_number""],[""sampleMass"",""Sample Mass"",""actual_number""],[""volume"",""Sample Volume"",""actual_number""],[""moles"",""Moles"",""actual_number""],[""regId"",""Registration Number"",""text""],[""percentWT"",""Percent Weight"",""actual_number""],[""molarity"",""Molarity"",""actual_number""],[""density"",""Density"",""actual_number""],[""cas"",""CAS Number"",""text""],[""limit"",""Limit"",""actual_number"","&intBoolList&"],["" "","" "",""none""],["" "",""Product"",""none""],["" "",""----"",""none""],[""chemicalName"",""Product Name"",""text""],[""molecularWeight"",""Molecular Weight"",""actual_number""],[""molecularFormula"",""Molecular Formula"",""text""],[""regId"",""Registration Number"",""text""],[""equivalents"",""Equivalents"",""actual_number""],[""theoreticalMass"",""Theoretical Mass"",""actual_number""],[""theoreticalMoles"",""Theoretical Moles"",""actual_number""],[""purity"",""Purity"",""actual_number""],[""sampleMass"",""Measured Mass"",""actual_number""],[""actualMass"",""Actual Mass"",""actual_number""],[""actualMoles"",""Actual Moles"",""actual_number""],[""yield"",""Yield"",""actual_number""],["" "","" "",""none""],["" "",""Solvent"",""none""],["" "",""----"",""none""],[""name"",""Solvent Name"",""text""],[""ratio"",""Ratio"",""text""],[""volume"",""Volume"",""actual_number""],[""ratio"",""Ratio"",""text""],[""reactionMolarity"",""Reaction Molarity"",""actual_number""],[""moles"",""Moles"",""actual_number""],[""supplier"",""Supplier"",""text""]"
	End if
	selectOptions = selectOptions & "]"
	response.write(selectOptions)
%>
<%
'""[""yield"",""Yield"",""actual_number""]
'""[""[name]"",""Name"",""text""],
'""[""userId"",""User Id"",""actual_number""],
'""[""searchPreparation"",""Search Preparation"",""text""],
'""[""reactionMolarity"",""Reaction Molarity"",""text""],
'""[""Pressure"",""Pressure"",""text""],
'""[""temperature"",""Temperature"",""text""],
'""[""protocol"",""Protocol"",""text""],
'""[""summary"",""Summary"",""text""],
'""[""description"",""Description"",""text""],
'""[""chemicalName"",""Chemical Name"",""text""],
'""[""regId"",""Registration Id"",""text""],
'""[""chemicalName"",""Chemical Name"",""text""],
'""[""dateExpires"",""Date Expires"",""text""],
'""[""chemicalName"",""Chemical Name"",""text""],
'""[""molecularFormula"",""Molecular Formula"",""text""],
'""[""molecularWeight"",""Molecular Weight"",""text""],
'""[""actualMass"",""Actual Mass"",""text""],
'""[""actualMoles"",""Actual Moles"",""text""],
'""[""yield"",""Yield"",""text""],
'""[""purity"",""Purity"",""text""],
'""[""theoreticalMass"",""Theoretical Mass"",""text""],
'""[""theoreticalMoles"",""Theoretical Moles"",""text""],
'""[""equivalents"",""equivalents"",""text""],
'""[""submittedAmount"",""Submitted Amount"",""text""],
'""[""barcode"",""Barcode"",""text""],
'""[""compoundNumber"",""Compound Number"",""text""],
'""[""tempId"",""Temp Id"",""text""],
'""[""formulaMass"",""Formula Mass"",""text""],
'""[""loading"",""Loading"",""text""],
'""[""updated"",""Updated"",""text""],
'""[""limit"",""Limit"",""text""],
'""[""moles"",""Moles"",""text""],
'""[""sampleMass"",""Sample Mass"",""text""],
'""[""volume"",""Volume"",""text""],
'""[""supplier"",""Supplier"",""text""],
'""[""cas"",""CAS Number"",""text""],
'""[""molarity"",""Molarity"",""text""],
'""[""density"",""Density"",""text""],
'""[""percentWT"",""Percent Weight"",""text""],
'""[""reactantMass"",""Reactant Mass"",""text""],
'""[""ratio"",""Ratio"",""text""],
'""[""note"",""Note"",""text""],
'""[""[filename]"",""Filename"",""text""],
'""[""searchText"",""File Text"",""text""]"
%>