<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%

' Helper function to determine the format of the given fileData. Ported from JS.
function getFileFormat(fileData)
    fileType = ""
    
    ' Set up a ton of regexes, one for each case.
    set mrvRegExp = new RegExp
    mrvRegExp.global = true
    mrvRegExp.pattern = "^<cml>"
    set rxnRegExp = new RegExp
    rxnRegExp.global = true
    rxnRegExp.pattern = "\$RXN"
    set molRegExp = new RegExp
    molRegExp.global = true
    molRegExp.pattern = "\$MOL"
    set mrv2RegExp = new RegExp
    mrv2RegExp.global = true
    mrv2RegExp.pattern = "ChemAxon file format v\d\d"
    set rxnv3RegExp = new RegExp
    rxnv3RegExp.global = true
    rxnv3RegExp.pattern = "\$RXN V3000"
    set sdfRegExp = new RegExp
    sdfRegExp.global = true
    sdfRegExp.pattern = "V[23]000[^$]*\$\$\$\$"
    set molv3RegExp = new RegExp
    molv3RegExp.global = true
    molv3RegExp.pattern = "\s*0\s+0\s+0\s+0\s+0\s+999\sV3000"
    set cdxmlRegExp = new RegExp
    cdxmlRegExp.global = true
    cdxmlRegExp.pattern = "<CDXML"
    set b64cdxRegExp = new RegExp
    b64cdxRegExp.global = true
    b64cdxRegExp.pattern = "ChemDraw \d\d"
    set b64cdx2RegExp = new RegExp
    b64cdx2RegExp.global = true
    b64cdx2RegExp.pattern = "^Vmp"
    set mol2RegExp = new RegExp
    mol2RegExp.global = true
    mol2RegExp.pattern = "^\s*\d+\s*\d+\s*\d+\s*\d+\s*\d+\s*\d+\s*\d+\s*V2000"
    if mrvRegExp.test(fileData) then
        fileType = "mrv"
    elseif rxnRegExp.test(fileData) then
        fileType = "rxn"
    elseif molRegExp.test(fileData) then
        fileType = "mol"
    elseif mrv2RegExp.test(fileData) then
        fileType = "mrv"
    elseif rxnv3RegExp.test(fileData) then
        fileType = "rxn:V3"
    elseif sdfRegExp.test(fileData) then
        fileType = "sdf"
    elseif molv3RegExp.test(fileData) then
        fileType = "mol:V3"
    elseif cdxmlRegExp.test(fileData) then
        fileType = "cdxml"
    elseif b64cdxRegExp.test(fileData) then
        fileType = "base64:cdx"
    elseif b64cdx2RegExp.test(fileData) then
        fileType = "base64:cdx"
    elseif mol2RegExp.test(fileData) then
        fileType = "mol"
    end if
    getFileFormat = fileType
End Function


%>