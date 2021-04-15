<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
For i = 0 To UBound(fields)
	If fields(i)(dbName) <> "molecule" then	
		fieldsStr = fieldsStr & fields(i)(dbName) & " "
	End if
Next
fieldsStr = Trim(fieldsStr)

If request.querystring("d") = "" Then
	sortDir = defaultSortDirection
Else
	d = request.querystring("d")
	If d = "ASC" Then
		sortDir = "ASC"
	Else
		sortDir = "DESC"
	End if
End If

If request.querystring("s") = "" Then
	sortBy = defaultSort
Else
	s = request.querystring("s")
	foundIt = False
	For i = 0 To UBound(fields)
		If fields(i)(sortDbName) = s Then
			foundIt = True
		End if
	next
	If foundIt Then
		sortBy = s
	Else
		sortBy = defaultSort
	End if
End If
%><!-- #include virtual="/arxlab/_inclds/common/asp/saveTableSort.asp"--><%
If s = "" Then
	sortBy = defaultSort
else
	foundIt = False
	For i = 0 To UBound(fields)
		If fields(i)(sortDbName) = s Then
			foundIt = True
		End if
	next
	If foundIt Then
		sortBy = s
	Else
		sortBy = defaultSort
	End if
End if

rpp = request.querystring("rpp")
If Not isInteger(rpp) Then
	rpp = defaultRpp
Else
	rpp = CInt(rpp)
	If rpp < 5 or rpp > 50 Then
		rpp = defaultRpp
	End if
End if

pageNum = request.querystring("pageNum")
If Not isInteger(pageNum) Then
	pageNum = 1
Else
	pageNum = CInt(pageNum)
End if

If regSearchResultsPage Or regSearchResultsBatches Then
	If regSearchResultsPage Then
		forSQL = "as fy"
		forSQL2 = "as fy2"
		
		tableStrQueryNoSorting = tableStrQuery
		If sortBy <> "sim" then
			tableStrQuery = tableStrQuery & " ORDER BY "&sortBy&" "& sortDir 
		End if

		'updated for batches of batches
		tableStrQuery = "SELECT * FROM searchView WHERE cd_id in (SELECT parent_cd_id FROM ("&tableStrQueryNoSorting&") "&forSQL&") or (parent_cd_id=0 and cd_id in (SELECT cd_id FROM ("&tableStrQueryNoSorting&") "&forSQL&")) "& " ORDER BY "&sortBy&" "& sortDir

		'response.write(tableStrQuery)
	Else
		'updated for batches of batches
		tableStrQuery = tableStrQuery & " AND parent_cd_id="&SQLClean(batchParentCdId,"T","S")&" ORDER BY just_batch"'&sortBy&" "& sortDir
	End if
else
	tableStrQuery = tableStrQuery & " ORDER BY "&sortBy&" "& sortDir 
End if

Dim totalRecords
If queryMol = "" Then
	queryMol = "*"
End If
If searchType = "" Then
	searchType = "SUBSTRUCTURE"
End if
Set ctRec = server.CreateObject("ADODB.RecordSet")
ctRec.pageSize = rpp
ctRec.CacheSize = rpp
ctRec.CursorLocation = 3
'response.write(tableStrQuery)
'response.end
'response.write(tableStrQuery)
originalTableStrQuery = tableStrQuery
ctRec.open tableStrQuery,jchemRegConn,3,3
If Not ctRec.eof then
	ctRec.absolutePage = pageNum
	eofFlag = False
Else
	eofFlag = True
End If

noMolecule = True
Set structureGroupIds = JSON.parse(getGroupIdsThatHaveStructure())
If Not forceNoMolecule Then
	Do While Not ctRec.eof
		If IsNull(ctRec("groupId")) Or structureGroupIds.Exists(ctRec("groupId")) Then
			noMolecule = False
			Exit Do
		End If
		ctRec.movenext
	Loop
	ctRec.close
	ctRec.open tableStrQuery,jchemRegConn,3,3
	If Not ctRec.eof Then
		ctRec.absolutePage = pageNum
	End If
End If
%>
<script type="text/javascript">
function checkAll(el)
{
	if (el.checked)
	{
		isOn = true
	}
	else
	{
		isOn = false
	}
	els = document.getElementById("unapprovedTable").getElementsByTagName("input")
	for(i=0;i<els.length;i++)
	{
		if (els[i].getAttribute("type") == "checkbox")
		{
			els[i].checked = isOn;
		}
	}
}

function checkAllExport(el)
{
	if (el.checked)
	{
		isOn = true
	}
	else
	{
		isOn = false
	}
	els = document.getElementById("regMolTable").getElementsByTagName("input")
	for(i=0;i<els.length;i++)
	{
		if (els[i].getAttribute("type") == "checkbox")
		{
			els[i].checked = isOn;
		}
	}
}
</script>

<table class="regMolTable" id="regMolTable" width="100%">
<tr class="regMolTableHeader">
<%If Not regSearchResultsBatches then%>
	<td></td>
<%
For i = 0 To UBound(fields)
    If Not (noMolecule And fields(i)(dbName) = "cd_molweight") Then
%>
	<%If fields(i)(doDisplay) = "true" then%>
		<td>
			<%If fields(i)(sortable) = "true" then%>
				<%
				sortHref = pageName&"&s="&fields(i)(sortDbName)&"&rpp="&rpp
				If sortBy = fields(i)(sortDbName) And sortDir = "ASC" Then
					sortHref = sortHref & "&d=DESC"
				End If
				If sortBy = fields(i)(sortDbName) And sortDir = "DESC" Then
					sortHref = sortHref & "&d=ASC"
				End if			
				%>
				<a href="<%=sortHref%>"><%=fields(i)(displayName)%></a>
				<%If sortBy = fields(i)(sortDbName) then%>
					<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
				<%End if%>
			<%else%>
				<%=fields(i)(displayName)%>
			<%End if%>
			<%If fields(i)(dbName) = "cd_id" then%>
				<%If fields(i)(sortDbName) = "cd_idexport" then%>
					<input type="checkbox" onclick="checkAllExport(this)">			
				<%else%>
					<input type="checkbox" onclick="checkAll(this)">
				<%End if%>
			<%End if%>
		</td>
	<%End if%>
    <%End If%>
<%next%>
<%End if%>
</tr>
<%If eofFlag then%>
	<tr class="regNoResults">
		<td colspan="<%=UBound(fields)+1%>">
				No Results
			<%noResults = true%>
		</td>
	</tr>
<%End if%>
<%
For i = 1 To ctRec.pageSize
If Not ctRec.eof then
	groupId = ctRec("groupId")
    hasStructure = False
    If structureGroupIds.Exists(groupId) Or IsNull(groupId) Then
        hasStructure = True
    End If
%>
	<tr class="regMolTableRow">
	<%If Not regSearchResultsBatches then%>
		<%For j = 0 To UBound(fields)%>
			<%If fields(j)(dbName) = "cd_id" Then
				thisTableCdId = ctRec("cd_id")
			End if%>
		<%next%>
		<%
		Set nrRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE parent_cd_id="&SQLClean(thisTableCdId,"N","S")&" AND status_id=1"
		nrRec.open strQuery,jchemRegConn,3,3
		If Not nrRec.eof then
		%>
		<td><a href="javascript:void(0)" onclick="toggleSearchTR('<%=ctRec("just_reg")%>','<%=groupId%>','<%=ctRec("cd_id")%>')" id="a_<%=groupId%>_<%=ctRec("just_reg")%>"><img src="<%=mainAppPath%>/images/plus.gif" border="0" style="border:none;" id="img_<%=thisTableCdId%>"></a></td>
		<%else%>
		<td>&nbsp;</td>
		<%End If
		nrRec.close
		Set nrRec = nothing
		%>
	<%End if%>
	<%For j = 0 To UBound(fields)%>
		<%If fields(j)(dbName) = "cd_id" Then
			thisTableCdId = ctRec("cd_id")
			theCdIds = theCdIds & ctRec("cd_id") & " "
		End if%>
		<%If fields(j)(doDisplay) = "true" then%>
			<%If fields(j)(dbName) = "molecule" Then
				If Not regSearchResultsBatches And hasStructure Or 1=1 then
					Set jcRec = server.CreateObject("ADODB.RecordSet")
					queryStr = "select cd_id from "&ctRec("tableName")&" WHERE cd_id="&ctRec("cd_id")
					jcRec.open queryStr,jchemRegConn,3,3
					numCdIds = jcRec.RecordCount
					jcRec.close
					Set jcRec = Nothing
				End if
			%>
			<td style="width:120px;">
				<%If Not regSearchResultsBatches And hasStructure Or 1=1 then%>
					<%If groupIdHasStructure(ctRec("groupId")) then
						displayCdId = ctRec("cd_id")
						Set dispRec = server.CreateObject("ADODB.RecordSet")
						idQuery = "SELECT cdxml FROM cdxml WHERE cd_id="&SQLClean(displayCdId,"N","S")
						dispRec.open idQuery,jchemRegConn,3,3
						
						theCdxml = ""
						showCdxml = False
						If Not dispRec.eof Then
							theCdxml = dispRec("cdxml")
							cdxmlPos = InStr(theCdxml, "&lt;CDXML")
							If cdxmlPos = 0 Then
								cdxmlPos = InStr(theCdxml, "<CDXML")
							End If

							If cdxmlPos > 0 Then
								showCdxml = True
								theCdxml = Mid(theCdxml, cdxmlPos)
							End If
						End If
						dispRec.close
						Set dispRec = Nothing
						
						If showCdxml Then
							displaySvg = CX_convertStructure(theCdxml, "cdxml", CX_getSvgParams(height, width))

							' if the convert structure fails to generate an image...
							If IsEmpty(displaySvg) Then
								displaySvg = CX_getSvgByCdId(jChemRegDB, regMoleculesTable, displayCdId, 200, 200)
							End If
						Else
							displaySvg = CX_getSvgByCdId(jChemRegDB, regMoleculesTable, displayCdId, 200, 200)
						End If
					%>
						<div formname="structureImage" class="reg-chem-image" style="width:<%=imageWidth%>px;height:<%=imageHeight%>px;">
						<%=displaySvg%>
						</div>
					<%else%>
						<%
						If ctRec("tableName") = regMoleculesTable Then
							Set idRec = server.CreateObject("ADODB.RecordSet")
							idQuery = "SELECT * FROM groupCustomFieldFields WHERE isIdentity=1 AND groupId="&SQLClean(ctRec("groupId"),"N","S")
							idRec.open idQuery,jchemRegConn,3,3
							Do While Not idRec.eof
								If cstr(ctRec("parent_cd_id")) = CStr(0) then
									val = ctRec(CStr(idRec("actualField")))
									If Len(val) > Len(maxChars(val,20)) then
										val = maxChars(val,20)&"..."
									End if
								%>
									<%=val%><br/>
								<%
								Else
									'only goes one level up not sure if right
									'if not, must write a function that gets the top level compound from a cd_id and opens that here.
									Set parentRec = server.CreateObject("ADODB.RecordSet")
									strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(ctRec("parent_cd_id"),"N","S")
									parentRec.open strQuery,jchemRegConn,3,3
									If Not parentRec.eof then
										val = parentRec(CStr(idRec("actualField")))
										If Len(val) > Len(maxChars(val,20)) then
											val = maxChars(val,20)&"..."
										End if
										%>
											<%=val%><br/>
										<%
									End if
									parentRec.close
									Set parentRec = nothing
								End if
								idRec.movenext
							loop
							idRec.close
							Set idRec = nothing
						End if
						%>
					<%End if%>
					<%
					Set idRec = server.CreateObject("ADODB.RecordSet")
					idQuery = "SELECT * FROM groupCustomFields WHERE id="&SQLClean(ctRec("groupId"),"N","S")&" and not groupPrefix is null and groupPrefix <> ''"
					idRec.open idQuery,jchemRegConn,3,3
					If Not idRec.eof then
						groupPrefix = idRec("groupPrefix")
					Else
						groupPrefix = getCompanySpecificSingleAppConfigSetting("regNumberPrefix", session("companyId"))
					End If
					idRec.close
					Set idrec = nothing
					%>
				<%End if%>
			</td>
			<%else%>
			<%
			If fields(j)(htmlTrans) <> "" Then
				dispStr = fields(j)(htmlTrans)			
				Set RegEx = New regexp
				RegEx.Pattern = "\$.*?\$"
				RegEx.Global = True
				RegEx.IgnoreCase = True
				set matches = RegEx.Execute(fields(j)(htmlTrans))
				for each match in matches
					name = replace(match.value,"$","")
					If name = "cd_id" Or name="sim" Then
						value = ctRec(fields(j)(dbName))
					else
						For x = 0 To UBound(fields)
							If hasStructure then
								If fields(x)(dbName) = name Then
									If Not regSearchResultsBatches And hasStructure Or 1=1 then
										Set jcRec = server.CreateObject("ADODB.RecordSet")
										queryStr = "select "&fields(x)(dbName)&" from "&ctRec("tableName")&" WHERE cd_id="&ctRec("cd_id")
										jcRec.open queryStr,jchemRegConn,3,3
										value = jcRec(fields(x)(dbName))
										jcRec.close
										Set jcRec = Nothing
									Else
										value = ctRec(fields(x)(dbName))									
									End if
								End if
							Else
								If fields(x)(dbName) = name Then
									value = ctRec(fields(x)(dbName))
								End if
							End if
						next
					End if
					if isnull(value) then 
						value = ""
					end If
					dispStr = replace(dispStr,match.value, value)
				Next
				dispStr = Replace(dispStr,"&#58;",":")
			Else
				If fields(j)(dbName) = "source" And ctRec(fields(j)(dbName))="ELN" Then
					For x = 0 To UBound(fields)
						If fields(x)(dbName) = "experiment_name" Then
							experimentName = ctRec("experiment_name")
						End If
						If fields(x)(dbName) = "experiment_id" Then
							experimentId = ctRec("experiment_id")
						End If
						If fields(x)(dbName) = "revision_number" Then
							revisionNumber = ctRec("revision_number")
						End if
						If fields(x)(dbName) = "type_id" Then
							experimentType = ctRec("type_id")
						End If
					Next
					If experimentType = "2" Then
						dispStr = "<a href='"&mainAppPath&"/bio-experiment.asp?id="&experimentId&"'>"&experimentName&"</a>"
					else
						dispStr = "<a href='"&mainAppPath&"/"&session("expPage")&"?id="&experimentId&"'>"&experimentName&"</a>"
					End if
				Else
					If fields(j)(dbName) = "reg_id" Then
						For x = 0 To UBound(fields)
							If fields(x)(dbName) = "just_reg" Then
								regNumber = ctRec("just_reg")
							End If
							If fields(x)(dbName) = "just_batch" Then
								batchNumber = ctRec("just_batch")
							End If
						Next
						dispStr = makeRegLink(groupPrefix,regNumber,batchNumber)
					Else
						'qqq
						If fields(j)(dbName) = "cd_molweight" Then
                            If noMolecule Then
                                dispStr = "NODISPLAY"
                            Else
                                If hasStructure And (Not IsNull(ctRec(fields(j)(dbName)))) then
                                    dispStr = Round(ctRec(fields(j)(dbName)),2)
                                Else
                                    dispStr = ""
                                End if
                            End If
						else
							dispStr = ctRec(fields(j)(dbName))
						End if
					End if
				End If
				If fields(j)(dbName) = "needsPurification" Or fields(j)(dbName) = "outForAnalysis" Or fields(j)(dbName) = "analysisComplete" Then
					If dispStr = "1" Then
						dispStr = "True"
					Else
						dispStr = "False"
					End if
				End if
			End If
			If dispStr="-1" Then
				dispStr = ""
			End if
			%>
            <%If dispStr <> "NODISPLAY" Then%>
			<td>
				<%=dispStr%>
			</td>
            <%End If%>
			<%End if%>
		<%End if%>
	<%next%>
	</tr>
	<%If Not regSearchResultsBatches then%>
		<tr id="tr_<%=thisTableCdId%>" style="display:none;">
		<td style="background-color:#aaa;">
		&nbsp;
		</td>
		<td colspan="6">
			<div id="div_<%=thisTableCdId%>"></div>
			<hr style="border-bottom:2px solid #aaa;width:20%;float:right;">
		</td>
		</tr>
	<%End if%>
<%
	ctRec.movenext
End if
next
%>
<%
hrefStr = pageName&"&s="&sortBy&"&d="&sortDir&"&rpp="&rpp&"&inframe="&request.querystring("inframe")&"&fieldsToShow="&request.querystring("fieldsToShow")
%>
<%
If session("regSearchNumPages") = "" Or session("regSearchNumRecords")= "" Or subsectionId="sd-rollback" then
	numPages = ctRec.pageCount
	numRecords = ctRec.recordCount
	session("regSearchNumPages") = numPages
	session("regSearchNumRecords") = numRecords
Else
	If Not regSearchResultsBatches then
		numPages = session("regSearchNumPages")
		numRecords = session("regSearchNumRecords")
	Else
		numPages = ctRec.pageCount
		numRecords = ctRec.recordCount
	End if
End if
%>
<tr class="regTableNav">
<td colspan="<%=UBound(fields)+1%>" align="right">
<div style="float:right">
<%If pageNum > 1 then%>
	<a href="<%=hrefStr & "&pageNum=1"%>"><img src="<%=mainAppPath%>/images/resultset_first.gif" alt="First" border="0"></a><a href="<%=hrefStr & "&pageNum=" & pageNum-1%>" title="Previous Page"><img src="<%=mainAppPath%>/images/resultset_previous.gif" alt="Previous" border="0"></A>
<%End if%>
<%if pageNum < numPages then%>
	<a href="<%=hrefStr & "&pageNum=" & pageNum + 1%>" title="Next Page"><img src="<%=mainAppPath%>/images/resultset_next.gif" border="0" alt="Next"></A><a href="<%=hrefStr & "&pageNum=" & numPages%>"><img src="<%=mainAppPath%>/images/resultset_last.gif" border="0" alt="Last"></a>
<%End if%>
</div>
<%If Not regSearchResultsBatches then%>
	<%If numPages > 1 then%>
		<script type="text/javascript">
		var numPages = <%=numPages%>
		function gotoPage(number)
		{
			if (number >= 1 && number <=numPages){
				window.location.href= "<%=hrefStr%>&pageNum="+number
			}
			else{
				alert("Please enter a number between 1 and "+numPages)
			}
		}
		</script>
		<div style="float:right;">
		<div style="position:relative;">
		<div style="<%If Not inApiFrame then%>margin-top:-8px;"<%End if%>>
		<span style="padding-top:3px;">Go to Page</span>
		<input type="text" onkeypress="if (event.keyCode == 13){gotoPage(this.value);return false;}" style="font-size:12px;width:12px;padding:0px;">
		</div>
		</div>
		</div>
		<div style="float:left;margin-bottom:2px;margin-left:12px;"><%If Not inFrame And Not inApiFrame then%><a href="javascript:void(0);" onClick="beforeExport();showPopup('exportFieldsDiv')">Export Results</a><%End if%></div>
		<div style="float:right;margin-bottom:2px;margin-right:12px;">Page <%=pageNum%> of <%=numPages%>&nbsp;(<%=numRecords%> Records)&nbsp;</div>
	<%End if%>
<%else%>
	<div style="float:right;margin-bottom:2px;margin-right:4px;"><%=numRecords%><%If numRecords =1 then%> Batch<%else%> Batches<%end if%></div>
<%End if%>
</td>
</tr>


<input type="hidden" name="exportCdids" id="exportCdids" value="<%=theCdids%>">
</table>
<script type="text/javascript">
	document.getElementById('headerResults').innerHTML = '<%=numRecords%> Compounds'
</script>