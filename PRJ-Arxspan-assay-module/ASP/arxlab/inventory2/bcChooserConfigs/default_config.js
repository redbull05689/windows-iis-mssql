useUse = true; //take amounts out of inventory
templateName = "blank_acs1996.cdx";  //acs,default
volumeUnits = ["ml","ul","l"]; //units in inventory that should match volume
warnNoUnits = true;
errorNoUnits = true;
useAmountForNonChemistry = true;
warnOnAmountToHigh = true;
requireAmount = true;
useLabels = false; //for use with compound tracking puts experiment name labels on molecules in scheme

chooserSearchField = "barcode";
chooserFields = []
f = {
	"fieldName" : "name",
	"headerName" : "Name",
	"displayInTable":true,
	"searchAgainst":true,
	"displayInTypeahead":true
}
chooserFields.push(f)
f = {
	"fieldName" : "location",
	"headerName" : "Location",
	"displayInTable":true,
	"searchAgainst":false,
	"displayInTypeahead":true
}
chooserFields.push(f)
f = {
	"fieldName" : "barcode",
	"headerName" : "Barcode",
	"displayInTable":true,
	"isNameField":true,
	"searchAgainst":true,
	"displayInTypeahead":true
}
chooserFields.push(f)
f = {
	"fieldName" : "structure",
	"headerName" : "Structure",
	"displayInTable":true,
	"isStructureField" : true,
	"searchAgainst":false,
	"displayInTypeahead":false
}
chooserFields.push(f)
f = {
	"fieldName" : "Purity",
	"headerName" : "Purity",
	"displayInTable":true,
	"destinationField":"percentWT",
	"isMassField":true,
	"userAdded":true,
	"isReactantField":true,
	"isReagentField":true,
	"suffix":" %",
	"searchAgainst":false,
	"displayInTypeahead":false
}
chooserFields.push(f)
//f = {
//	"fieldName" : "Density (g/mL)",
//	"headerName" : "Density",
//	"displayInTable":true,
//	"destinationField":"density",
//	"isVolumeField":true,
//	"userAdded":true,
//	"isReactantField":true,
//	"isReagentField":true,
//	"suffix":" g/mL"
//}
//chooserFields.push(f)
f = {
	"fieldName" : "Amount",
	"headerName" : "Amount",
	"isAmountField":true,
	"dbName":"amount",
	"searchAgainst":false,
	"displayInTypeahead":false
}
chooserFields.push(f)
f = {
	"fieldName" : "Unit Type",
	"headerName" : "Units",
	"isUnitsField":true,
	"searchAgainst":false,
	"displayInTypeahead":false
}
chooserFields.push(f)
f = {
	"fieldName" : "Formula",
	"destinationField":"molecularFormula",
	"isReactantField":true,
	"isReagentField":true,
	"searchAgainst":false,
	"displayInTypeahead":false
}
chooserFields.push(f)
f = {
	"fieldName" : "Chemical Name",
	"destinationField":"name",
	"isReactantField":true,
	"isReagentField":true,
	"isSolventField":true,
	"searchAgainst":false,
	"displayInTypeahead":false
}
chooserFields.push(f)
f = {
	"fieldName" : "Mol Weight",
	"destinationField":"molecularWeight",
	"isReactantField":true,
	"isReagentField":true,
	"fixedDigits":2,
	"searchAgainst":false,
	"displayInTypeahead":false
}
chooserFields.push(f)
f = {
	"fieldName" : "CAS Number",
	"destinationField":"cas",
	"isReactantField":true,
	"isReagentField":true,
	"searchAgainst":true,
	"displayInTypeahead":true
}
chooserFields.push(f)
