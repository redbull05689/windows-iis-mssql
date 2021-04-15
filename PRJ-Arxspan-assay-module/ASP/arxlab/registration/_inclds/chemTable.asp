<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
regNumberPrefix = getCompanySpecificSingleAppConfigSetting("regNumberPrefix", session("companyId"))
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

cdIdList = "("
If queryMol <> "" Then
	If hasStructure then
		Set params = JSON.parse("{}")
		If searchType <> "" Then
			params.Set "searchType", searchType
		End If
		
		searchHitsJson = CX_structureSearch(jChemRegDB,whichTable,queryMol,"",JSON.stringify(params),"[""cd_id""]",2147483647,0)
		Set searchHits = JSON.parse(searchHitsJson)
		If IsObject(searchHits) And searchHits.Exists("data") Then
			Set results = searchHits.Get("data")
			If IsObject(results) Then
				numResults = results.Length
				recordNumber = 0
				numHits = 0
				
				Do While recordNumber < numResults
					Set thisResult = results.Get(recordNumber)
					If thisResult.Exists("cd_id") Then
						If numHits > 0 Then
							cdIdList = cdIdList & ","
						End If
						
						numHits = numHits + 1
						cdIdList = cdIdList & thisResult.Get("cd_id")
					End If
					
					recordNumber = recordNumber + 1
				Loop
			End If
		End If
	End If
End If

cdIdList = cdIdList & ")"
If cdIdList <> "()" Then
	If InStr(tableStrQuery, "where") Or InStr(tableStrQuery, "WHERE") Then
		tableStrQuery = tableStrQuery & " AND "
	Else
		tableStrQuery = tableStrQuery & " WHERE "
	End If
	
	tableStrQuery = tableStrQuery & " cd_id in " & cdIdList
End If

tableStrQuery = tableStrQuery & " ORDER BY "&sortBy&" "& sortDir
Set idRec = server.CreateObject("ADODB.RecordSet")
idRec.open tableStrQuery,jchemRegConn,adUseClient,adLockReadOnly
recordCount = idRec.RecordCount

If recordCount > 0 Then
	'paging
	idRec.PageSize = rpp
	idRec.AbsolutePage = pageNum
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
</script>
<table class="experimentsTable" width="100%" style="/*margin-left:6px;*/">
<tr class="regMolTableHeader">
<%For i = 0 To UBound(fields)%>
	<%If fields(i)(doDisplay) = "true" then%>
		<%
			Set re = new RegExp
			re.IgnoreCase = true
			re.Global = true
			re.Pattern = "[^A-Za-z0-9]"
			formName = re.Replace(fields(i)(displayName),"_")
			set re = nothing
		%>
		<th id="<%=formName%>_col_header">
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
				<%If Not noSort then%>
				<a href="<%=sortHref%>"><%=fields(i)(displayName)%></a>
				<%else%>
				<%=fields(i)(displayName)%>
				<%End if%>
				<%If Not noSort then%>
					<%If sortBy = fields(i)(sortDbName) then%>
						<a href="<%=sortHref%>"><%If sortDir="DESC" then%><img src="<%=mainAppPath%>/images/sort_down.gif" border="0"><%else%><img src="<%=mainAppPath%>/images/sort_up.gif" border="0"><%End if%></a>
					<%End if%>
				<%End if%>
			<%else%>
				<%=fields(i)(displayName)%>
			<%End if%>
			<%If fields(i)(dbName) = "cd_id" then%>
				<input type="checkbox" onclick="checkAll(this)">
			<%End if%>
		</th>
	<%End if%>
<%next%>
	<%If subsectionId = "show-project" then%>
	<th>
	</th>
	<%End if%>
</tr>
<%If recordCount <= 0 then%>
	<tr class="regNoResults">
		<td colspan="<%=recordCount+1%>">
			<%If emptyError <> "" then%>
				<%=emptyError%>
			<%else%>
				No Results
			<%End if%>
			<%noResults = true%>
		</td>
	</tr>
<%End if%>
<%
Call getconnectedJchemReg
Set structureGroupIds = JSON.parse(getGroupIdsThatHaveStructure())
Do While Not ( idRec.eof Or idRec.AbsolutePage <> pageNum )

%>
	<%If recordCount = 0 then
		Exit Do
	End if

	groupId = Null
	If whichTable = regMoleculesTable Then
		groupId = idRec("groupId")
	End If

    hasStructure = False
    If structureGroupIds.Exists(groupId) Or IsNull(groupId) Then
        hasStructure = True
    End If
    %>
	<tr class="regMolTableRow">
	<%For j = 0 To UBound(fields)%>
		<%If fields(j)(dbName) = "cd_id" Then
			theCdIds = theCdIds & idRec("cd_id") & " "
			thisCdId = idRec("cd_id")
		End if%>
		<%If fields(j)(doDisplay) = "true" then%>
			<%If fields(j)(dbName) = "molecule" Then%>
			<td>
			<%
			If Not hasStructure Then
				For x = 0 To UBound(fields)
					If fields(x)(dbName) = "groupId" Then
						groupId = idRec(fields(x)(dbName))
					End If
					If fields(x)(dbName) = "cd_id" Then
						thisCdId = idRec(fields(x)(dbName))
					End If
				Next
				Set idRecc = server.CreateObject("ADODB.RecordSet")
				idQuery = "SELECT * FROM groupCustomFieldFields WHERE isIdentity=1 AND groupId="&SQLClean(groupId,"N","S")
				idRecc.open idQuery,jchemRegConn,3,3
				Do While Not idRecc.eof
					Set idRec2 = server.CreateObject("ADODB.RecordSet")
					idQuery2 = "SELECT * FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(thisCdId,"N","S")
					idRec2.open idQuery2,jchemRegConn,3,3
					val = idRec2(CStr(idRecc("actualField")))
					If Len(val) > Len(maxChars(val,20)) Then
						val = maxChars(val,20)&"..."
					End if
					%>
						<%=val%><br/>
					<%
					idRec2.close
					Set idRec2 = nothing
					idRecc.movenext
				loop
				idRecc.close
				idQuery = "SELECT * FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")&" and not groupPrefix is null and groupPrefix <> ''"
				idRecc.open idQuery,jchemRegConn,3,3
				If Not idRecc.eof then
					groupPrefix = idRecc("groupPrefix")
				Else
					groupPrefix = regNumberPrefix
				End if
				idRecc.close
				Set idRecc = nothing
			else
				groupPrefix = regNumberPrefix
				displayCdId = idRec("cd_id")
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
					displaySvg = CX_getSvgByCdId(jChemRegDB, whichTable, displayCdId, 200, 200)
				End If
			%>
				<div formname="structureImage" class="reg-chem-image" style="width:<%=imageWidth%>px;height:<%=imageHeight%>px;">
				<%=displaySvg%>
				</div>
			<%End if
			%>
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
					For x = 0 To UBound(fields)
						If fields(x)(dbName) = name Then
							value = idRec(fields(x)(dbName))
						End if
					next
					if isnull(value) then 
						value = ""
					end If
					dispStr = replace(dispStr,match.value, value)
				Next
			Else
				If fields(j)(dbName) = "source" And idRec(fields(j)(dbName))="ELN" Then
					For x = 0 To UBound(fields)
						If fields(x)(dbName) = "experiment_name" Then
							experimentName = idRec(fields(x)(dbName))
						End If
						If fields(x)(dbName) = "experiment_id" Then
							experimentId = idRec(fields(x)(dbName))
						End If
						If fields(x)(dbName) = "revision_number" Then
							revisionNumber = idRec(fields(x)(dbName))
						End if
					Next
					targetStr = ""
					If inFrame Then
						targetStr = "target='_parent'"
					End if
					dispStr = "<a "&targetStr&" href='"&mainAppPath&"/"&session("expPage")&"?id="&experimentId&"&revisionId="&(revisionNumber+1)&"'>"&experimentName&"</a>"
				Else
					If fields(j)(dbName) = "reg_id" Then
						For x = 0 To UBound(fields)
							If fields(x)(dbName) = "just_reg" Then
								regNumber = idRec(fields(x)(dbName))
							End If
							If fields(x)(dbName) = "just_batch" Then
								batchNumber = idRec(fields(x)(dbName))
							End If
						Next
						dispStr = makeRegLink(groupPrefix,regNumber,batchNumber)
					else
						If fields(j)(dbName) = "cd_molweight" Then
							If hasStructure And (idRec(fields(j)(dbName)) <> "") then
								dispStr = Round(idRec(fields(j)(dbName)),2)
							Else
								dispStr = ""
							End if
						else
							dispStr = idRec(fields(j)(dbName))
						End if
					End if
				End if
			End if
			%>
			<td><%=dispStr%></td>
			<%End if%>
		<%End if%>
	<%next%>
	<%If subsectionId = "show-project" then%>
		<td>
			<%If inframe then%>
				<a onclick="if(confirm('Are you sure you wish to remove this item?')){document.getElementById('submitFrame2Frame').src='<%=mainAppPath%>/projects/project-remove-regItem.asp?projectId=<%=projectId%>&cd_id=<%=thisCdId%>';this.parentNode.parentNode.style.display='none';}" class="deleteObjectLink"><img border="0" src="images/delete.png" class="png"></a>
			<%else%>
				<a onclick="if(confirm('Are you sure you wish to remove this item?')){document.getElementById('submitFrame2').src='<%=mainAppPath%>/projects/project-remove-regItem.asp?projectId=<%=projectId%>&cd_id=<%=thisCdId%>';this.parentNode.parentNode.style.display='none';}" class="deleteObjectLink"><img border="0" src="images/delete.png" class="png"></a>
			<%End if%>
		</td>
	<%End if%>
	</tr>
<%
	idRec.MoveNext
Loop
%>
<%
hrefStr = pageName&"&s="&sortBy&"&d="&sortDir&"&rpp="&rpp
%>
<tr class="regTableNav">
<td colspan="<%=UBound(fields)+1%>" align="right" valign="top">
<%If recordCount > 0 then%>
<%
numPages = Int(recordCount/rpp)
If recordCount Mod 5 <> 0 then
	numPages = numPages + 1
End if
%>
<span>Page <%=pageNum%> of <%=numPages%>&nbsp;(<%=recordCount%> Records)</span>
<%If pageNum > 1 then%>
	<a href="<%=hrefStr & "&pageNum=1"%>"><img src="<%=mainAppPath%>/images/resultset_first.gif" alt="First" border="0"></a><a href="<%=hrefStr & "&pageNum=" & pageNum-1%>" title="Previous Page"><img src="<%=mainAppPath%>/images/resultset_previous.gif" alt="Previous" border="0"></A>
<%End if%>
<%If pageNum < numPages And recordCount > rpp then%>
	<a href="<%=hrefStr & "&pageNum=" & pageNum + 1%>" title="Next Page"><img src="<%=mainAppPath%>/images/resultset_next.gif" border="0" alt="Next"></A><a href="<%=hrefStr & "&pageNum=" & CInt(recordCount/rpp)+1%>"><img src="<%=mainAppPath%>/images/resultset_last.gif" border="0" alt="Last"></a>
<%End if%>
<%End if%>
</td>
</tr>



</table>