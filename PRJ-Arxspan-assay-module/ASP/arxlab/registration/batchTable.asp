<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include file="../_inclds/frame-header-tool.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
clientAlias = getCompanySpecificSingleAppConfigSetting("clientAlias", session("companyId"))

theCdId = request.querystring("cdId")
wholeRegNumber = request.querystring("regNumber")
fieldsToShow = request.querystring("fieldsToShow")
linkField = request.querystring("tableLinkField")
groupId = request.querystring("groupId")
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))

Const dbName = 0
Const sortDbName = 1
Const displayName = 2
Const sortable = 3
Const doDisplay = 4
Const htmlTrans = 5

' clientAlias == A2 => Ultragenyx
' clientAlias == A1 => Broad

If groupId="31" And clientAlias = "A1" And whichServer="MODEL" Then
	fieldsToShow = "molecule,just_batch,AM_Litter_Size,AM_Birth_Date,AM_Wean_Date"
End If
If clientAlias = "A2" And groupId="47" then
		fieldsToShow = "molecule,just_batch,Active,user_name,cd_timestamp,source" 
End if
If clientAlias = "A2" And groupId="51" then
		fieldsToShow = "molecule,just_batch,MFG_Sample_Type,MFG_Assay,Volume__mL_" 
End if
If clientAlias = "A2" And groupId="52" then
		fieldsToShow = "molecule,just_batch,WR_TestMethod,Number_of_Samples,Priority,WR__Assay_Status" 
End if
If clientAlias = "A2" And groupId="53" then
		fieldsToShow = "molecule,just_batch,Active_Lot,Assay_Usage,Batch_Comment" 
End if
If clientAlias = "A2" And groupId="62" then
		fieldsToShow = "molecule,just_batch,MFG_Date,Purpose,CT_Mean___2E10" 
End if
If clientAlias = "A2" And groupId="77" then
		fieldsToShow = "molecule,just_batch,Purification_Step,Sample_Description,Batch_Comment" 
End if
If clientAlias = "A2" And groupId="79" then
		fieldsToShow = "molecule,just_batch,Date,Company___Department,Activity_Performed" 
End if
If clientAlias = "A2" And groupId="83" then
		fieldsToShow = "molecule,just_batch,MFG_Sample_Type,MFG_Assay,Volume__mL_" 
End if
If clientAlias = "A2" And groupId="85" then
		fieldsToShow = "molecule,just_batch,Testing_Lab,CTL_Test_Description,Approved" 
End if
If clientAlias = "A2" And groupId="124" then
		fieldsToShow = "just_batch,QCWR_TestMethod,Number_of_Samples,Priority,WR__Assay_Status" 
End if
If clientAlias = "A2" And (groupId="92" OR groupId="93" OR groupId="94" OR  groupId="95" OR groupId="97" OR groupId="98") then
	fieldsToShow = "molecule,just_batch,Cell_Line,Production_Type,PCL_Clone "
End If

' PWR (Production Work Request): Batch#, Product ID, Status, Batch Comments
if clientAlias = "A2" and groupId = "105" then
	fieldsToShow = "molecule,just_batch,Product_ID,PWR_Batch_Status,Batch_Comment"
End if

' DTX-Doc (Document Registration): Batch#, Report Title, Status, Comments
if clientAlias = "A2" and groupId = "76" then
	fieldsToShow = "molecule,just_batch,Report_Description,Report_Status,Batch_Comment"
End if

' PCLC: Batch#, Bank Date, Parent Bank ID, Comments
if clientAlias = "A2" and groupId = "99" then
	fieldsToShow = "molecule,just_batch,Bank_Date,Parent_Bank_ID,Batch_Comment"
End if

' CS: Batch#, Bank Date, Parent Bank ID, Passage #
if clientAlias = "A2" and groupId = "101" then
	fieldsToShow = "molecule,just_batch,Bank_Date,Parent_Bank_ID,Passage_Number"
End if

' ATXPROT
If groupId="2" And whichClient = "ACCENT_TX" And whichServer="PROD" Then
	fieldsToShow = "just_batch,cd_timestamp,Protein_Batch__Viva_,Plasmid,Storage_buffer"
end if

' ATXCMPLX
If groupId="3" And whichClient = "ACCENT_TX" And whichServer="PROD" Then
	fieldsToShow = "just_batch,cd_timestamp,Protein_Batch__Viva_,Plasmid,Protein_1,Protein_2,Protein_3,Storage_buffer"
end if

' Oligo DNA/RNA
If groupId="6" And whichClient = "ACCENT_TX" And whichServer="PROD" Then
	fieldsToShow = "just_batch,Date_Ordered,Vendor_ID,Purchase_Order__,Description"
end if

' CRISPR
If whichClient = "CRISPR" Then
	fieldsToShow = "just_batch,Manufacturer,Manufacture_Date,Lot,Concentration,user_name,cd_timestamp,source"
end if

'Sage 
if whichClient = "SAGE" Then
	fieldsToShow = "just_batch,cd_molweight,salt_names,cd_timestamp,source"
end if

Dim fields()
If fieldsToShow = "" then
	reDim fields(8)
	fields(0) = split("molecule:::false:false:",":")
	fields(1) = Split("just_batch:just_batch:Batch Number:true:true:<a href='showBatch.asp?regNumber="&wholeRegNumber&"-$just_batch$' target='parent'>$just_batch$</a>",":")
	fields(2) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
	fields(3) = split("user_name:user_name:User Name:true:true:",":")
	fields(4) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")
	fields(5) = split("source:source:Source:true:true:",":")
	fields(6) = split("experiment_id:::false:false:",":")
	fields(7) = split("revision_number:::false:false:",":")
	fields(8) = split("experiment_name:::false:false:",":")
Else
	noMolcule = true
	Call getconnectedJchemReg
	fieldList = Split(fieldsToShow,",")
	fieldMax = UBound(fieldList)+3
	hasBatch = false
	For i=0 To UBound(fieldList)
		If fieldList(i) = "just_batch" Then
			hasBatch = true
		End if
	Next
	If Not hasBatch Then
		fieldMax = fieldMax + 1
	End if
	ReDim fields(fieldMax)
	For i=0 To UBound(fieldList)
		If fieldList(i)="molecule" Or fieldList(i)="just_batch" Or fieldList(i)="cd_molweight" Or fieldList(i)="user_name" Or fieldList(i)="cd_timestamp" Or fieldlist(i)="source" Or fieldlist(i)="salt_names"Then
			Select Case fieldList(i)
				Case "molecule"
					fields(i) = split("molecule:::false:false:",":")
				Case "just_batch"
					fields(i) = Split("just_batch:just_batch:Batch Number:true:true:<a href='showBatch.asp?regNumber="&wholeRegNumber&"-$just_batch$' target='parent'>$just_batch$</a>",":")
				Case "cd_molweight"
					fields(i) = split("cd_molweight:cd_molweight:Molecular Weight:true:true:",":")
				Case "user_name"
					fields(i) = split("user_name:user_name:User Name:true:true:",":")
				Case "cd_timestamp"
					fields(i) = split("cd_timestamp:cd_timestamp:Date Created:true:true:",":")
				Case "source"
					fields(i) = split("source:source:Source:true:true:",":")
				Case "salt_names"
					fields(i) = split("salt_names:salt_names:Salt:true:true:",":")
			End select
		Else
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM customFields WHERE formName="&SQLClean(fieldList(i),"T","S")			
			rec.open strQuery,jchemRegConn,3,3
			If Not rec.eof Then
				sStr = rec("actualField")&":"&rec("actualField")&":"&rec("displayName")&":true:true:"
				If fieldList(i) = linkField Then
					sStr = sStr & "<a href='showBatch.asp?regNumber="&wholeRegNumber&"-$just_batch$' target='parent'>$"&rec("actualField")&"$</a>"
				End If
				fields(i) = split(sStr,":")
			End If
		End if
	Next
	fields(i) = split("experiment_id:::false:false:",":")
	fields(i+1) = split("revision_number:::false:false:",":")
	fields(i+2) = split("experiment_name:::false:false:",":")
	If Not hasBatch Then
		fields(i+3) = split("just_batch:::false:false:",":")
	End if
	Call disconnectJchemReg
End if

if whichClient = "SAGE" Then
	regSaltsView = getCompanySpecificSingleAppConfigSetting("regSaltMappingView", session("companyId"))
	'The XML PATH stuff concats the salts into one column
	tableStrQuery = "SELECT bm.*, (STUFF((SELECT CAST(', ' + smv.[name] as VARCHAR(MAX)) from " & regSaltsView & " smv WHERE (bm.cd_id = smv.molId) FOR XML PATH ('')), 1, 2, '')) AS 'salt_names' FROM " & regMoleculesTable & " bm WHERE (bm.status_id <> 2 or bm.status_id is null) AND parent_cd_id=" & SQLClean(theCdId,"N","S")
else
	tableStrQuery = "SELECT * FROM "&regMoleculesTable&" WHERE (status_id <> 2 or status_id is null) AND parent_cd_id="&SQLClean(theCdId,"N","S")
end if

whichTable = regMoleculesTable
defaultSort = "cd_timestamp"
defaultSortDirection = "DESC"
pageName = "batchTable.asp?cdId="&theCdId&"&regNumber="&wholeRegNumber&"&tableLinkField="&linkField&"&fieldsToShow="&fieldsToShow
defaultRpp = 10
emptyError = "No Batches"
inFrame = true
%>
	<!-- #INCLUDE file="_inclds/chemTable.asp" -->