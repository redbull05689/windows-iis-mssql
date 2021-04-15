<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
	<%
	hrefStr = Request.ServerVariables("SCRIPT_NAME") & "?search=" & request("search") _
							& "&o=" & sortby & "&d=" & curdir & "&prevUrl=" & Server.URLEncode(request.querystring("prevurl"))
	rtnStr = ""
	For Each item In Request.QueryString
		If Mid(item,1,3) = "rtn" then
			rtnStr = rtnStr & "&" & item & "=" & request.querystring(item)
		End if
	Next
	hrefStr = hrefStr & rtnStr
	%>

			<%if pageSearchEnabled = "true" then%>
			<table style="border:none;">
			<tr>
			<td valign="top" style="border:none;">
			<div id="topDiv" style="width:570px;">
			<div id="SearchForm">
			<form name="form" id="form" action="<%=hrefStr%>" method="post">
				<input type="hidden" name="searchType" id="searchType" value="<%=request("searchType")%>">
				<fieldset>
				<legend>
					<input name="search" type="submit" value="Search" style="display:inline;"><input style="display:inline;margin-left:12px;" name="search" type="button" value="Reset Search" onclick="javascript:clearSearchFields()">
				</legend>
				<div>
				<div id="simpleSearch" <% if cint(searchType) = 1 then %> style="display:none;" <%end if%>>
					<label for="strSearch">Search Text<span align="center" style="margin-left:80px;"><a style="font-weight:normal;font-size:11px;" href="javascript:showAdvancedSearch();">Advanced Search</a></span></label>
					<input name="strSearch" id="strSearch" type="text" value="<%= request("strSearch") %>">
				</div>
				<div id="advSearch" <% if searchType = 0 then %> style="display:none;" <%end if%>>
					<%
					lastSearchi = 0
					for i = 0 to ubound(fields)
						if fields(i)(searchEnabled) = "true" Then
							lastSearchi = i
						end if
					next
					%>
					<%
					for i = 0 to ubound(fields)
						if fields(i)(searchEnabled) = "true" then
					%>
					<label for="s<%=fields(i)(formName)%>"><%=fields(i)(formLabel)%>
					<%If i = lastSearchi then%><span align="center" style="margin-left:80px;"><a style="font-weight:normal;font-size:11px;" href="javascript:showSimpleSearch();">Simple Search</a></span><%End if%></label>
					<input name="s<%=fields(i)(formName)%>" id="s<%=fields(i)(formName)%>" type="text" value="<%=request("s"&fields(i)(formName))%>">
					<%
						end if
					next
					%>
					</div>
					<div>
					<br class="clearfloats">
					</div>
				</div>
				</fieldset>
			</form>

			</div>
			<%else%>
			<table style="border:none;">
			<tr>
			<td valign="top" style="border:none;">
			<div id="topDiv" style="width:570px;">

			<%end if%>

<%
	for j = 0 to ubound(fields)
		if fields(j)(searchEnabled) = "true" or fields(j)(searchEnabled) = "true*hidden" and request("searchType") = cStr(1) then
			if request.form("s"&fields(j)(formName)) <> "" then
				hrefStr = hrefStr & "&s" & fields(j)(formName) & "=" & request.form("s"&fields(j)(formName))
			end if
			if request.querystring("s"&fields(j)(formName)) <> "" then
			hrefStr = hrefStr & "&s" & fields(j)(formName) & "=" & request.querystring("s"&fields(j)(formName))
			end if
		end if
	next
	%>
		<%if pageAddItemEnabled = "true" then%>
		<div><span><a href="javascript:showAdditem();"><%if addOnly <> "true" then%><h3><%=addNewItemText%><%end if%></h3></a></span></div>
		<div id="progressDivContainer" style="position:absolute;background-color:black;opacity:.8;filter: alpha(opacity=80);-moz-opacity:0.8;">
		</div>
		<div id="progressDiv" style="position:absolute;z-index:100;opacity:1;background-color:white;">
		</div>

		<%
		if addItemDivId = "" then
			addItemDivId = "addItemDiv"
		end if
		%>

		<div id="<%=addItemDivId%>" style="display:none;z-index:1;">
	
		<%if emailDuplicate = true AND onlyDuplicateError = true then%>
		    <p style="color:red;text-align:left;margin-bottom:0px;">The email address for this user already exists</p>
		<%elseif addError = true then%>
			<p style="color:red;text-align:left;margin-bottom:0px;">Please Correct Error Highlighted in Red</p>
			<%If errorStr <> "" then%>
				<p style="color:red;text-align:left;margin-top:0px;"><%=errorStr%></p>
			<%End if%>
		<%end if%>
			<%
			pairs = split(Request.QueryString,"&")
			qsh = ""
			for i=0 to UBOUND(pairs)
				key = split(pairs(i),"=")(0)
				value = split(pairs(i),"=")(1)
				if instr(key,"hidden") then
					qsh = qsh & "&" & key & "=" & value
				end if
			next
		%>
		<form name="form" id="addForm" action="<%=hrefStr&qsh%>" method="post">
		<fieldset>

				<%
				pairs = split(Request.QueryString,"&")
				for i=0 to UBOUND(pairs)
					key = split(pairs(i),"=")(0)
					value = split(pairs(i),"=")(1)
					if instr(key,"hidden") then
					%>
						<input type="hidden" name="a<%=replace(key,"hidden","")%>" value="<%=value%>">
					<%
					end if
				next
				if addNewDisplay = "table" then
					response.write "<table bgcolor=""#F1F1F1"" style='z-index:1;'>"
				end if
				for i = 0 to ubound(fields)
				if fields(i)(addEnabled) = "true" then
					fieldType = split(fields(i)(formType),"*")(0)
					args = split(fields(i)(formType),"*")
					select case fieldType

					case "file"
						%>
						<%
						fileBoxName = "a"&fields(i)(formName)
						args = split(fields(i)(formType),"*")
						if ubound(args) > 0 then
							textboxSize  = args(1)
						else
							textboxSize = 140
						end if
						if instr(efields,"a"&fields(i)(formName)) or formError = false then
							value = ""
						else
							value = request.form("a"&fields(i)(formName))
						end if
						%>
						<iframe id="nhiddenIframe" name="nhiddenIframe" width="100" style="display:none;">
						</iframe>
						<%select case addNewDisplay%>
							<%case "inline"%>	
								<label for="a<%=fields(i)(formName)%>"><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%>
								<%if request.form("addItem") <> "" then%>
								<b><%=request.form("a"&fields(i)(formName))%> uploaded successfully</b>
								<input type="hidden" value="<%=request.form("a"&fields(i)(formName))%>" name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>">
								<%else%>
								<input name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>" type="file" value="<%=value%>" style="width:<%=textboxSize%>px;"></label>
								<%end if%>
							<%case "table"%>
								<tr>
									<td><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%></td>
									<%if request.form("addItem") <> "" then%>
									<td><b><%=request.form("a"&fields(i)(formName))%> uploaded successfully</b></td>
									<input type="hidden" value="<%=request.form("a"&fields(i)(formName))%>" name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>">
									<%else%>
									<td><input name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>" type="file" value="<%=value%>" style="width:<%=textboxSize%>px;"></td>
									<%end if%>
								</tr>
						<%end select%>
						<%

					case "text"
						%>
						<%
						args = split(fields(i)(formType),"*")
						if ubound(args) > 0 then
							textboxSize  = args(1)
						else
							textboxSize = 140
						end if
						if instr(efields,"a"&fields(i)(formName)) or formError = false then
							value = ""
						else
							value = request.form("a"&fields(i)(formName))
						end if
						%>
						<%select case addNewDisplay%>
							<%case "inline"%>	
								<label for="a<%=fields(i)(formName)%>"><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%>
								<input name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>" type="text" value="<%=value%>" style="width:<%=textboxSize%>px;" onKeyPress="return disableEnterKey(event)"></label>
							<%case "table"%>
								<tr>
									<td><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%></td>
									<td><input name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>" type="text" value="<%=value%>" style="width:<%=textboxSize%>px;" onKeyPress="return disableEnterKey(event)"></td>
								</tr>
						<%end select%>
						<%

					case "divider"
						%>
							<tr>
									<td colspan="2">
										<h1 style="margin-top:10px;"><%=fields(i)(defaultValue)%></h1><hr style="margin-bottom:4px;width:80%">
									</td>
							</tr>						
						<%


					case "textarea"
						%>
						<%
						args = split(fields(i)(formType),"*")
						if ubound(args) > 0 then
							taRows  = args(1)
							taCols = args(2)
						else
							taRows = 2
							taCols = 20
						end if
						if instr(efields,"a"&fields(i)(formName)) or formError = false then
							value = ""
						else
							value = request.form("a"&fields(i)(formName))
						end if
						%>
						<%select case addNewDisplay%>
							<%case "inline"%>	
								<label for="a<%=fields(i)(formName)%>"><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%>
								<textarea rows="<%=taRows%>" cols="<%=taCols%>" name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>"><%=value%></textarea>
								</label>
							<%case "table"%>
								<tr>
									<td><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%></td>
									<td>
										<textarea rows="<%=taRows%>" cols="<%=taCols%>" name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>"><%=value%></textarea>
									</td>
								</tr>
						<%end select%>
						<%
					case "password"
						%>
						<%
						if instr(efields,"a"&fields(i)(formName)) or formError = false then
							value = ""
						else
							value = request.form("a"&fields(i)(formName))
						end if
						%>
						<%select case addNewDisplay%>
							<%case "inline"%>	
								<label for="a<%=fields(i)(formName)%>"><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%>
								<input name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>" type="password" value="<%=value%>"></label>
							<%case "table"%>
								<tr>
									<td><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%></td>
									<td><input name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>" type="password" value="<%=value%>"></td>
								</tr>
						<%end select%>
						<%
					case "date"
						%>
						<%
						if instr(efields,"a"&fields(i)(formName))  or formError = false then
							if request.form("a"&fields(i)(formName)) <> "" then
								value = ""
							else
								value = dateAddZeros(split(now()," ")(0))
							end if
						else
							value = dateAddZeros(request.form("a"&fields(i)(formName)))
						end if
						%>
						<%select case addNewDisplay%>
							<%case "inline"%>	
								<label for="a<%=fields(i)(formName)%>"><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%>
								<input type="text" name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>" value="<%=value%>" size="16" onclick="cal<%="a"&fields(i)(formName)%>.select(document.getElementById('<%="a"&fields(i)(formName)%>'),'dummyA','MM/dd/yyyy'); return false;"><a name='dummyA' id='dummyA' href='#'></a></label>
							<%case "table"%>
								<tr>
									<td><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%></td>
									<td><input type="text" name="a<%=fields(i)(formName)%>" id="a<%=fields(i)(formName)%>" value="<%=value%>" size="16" onclick="cal<%="a"&fields(i)(formName)%>.select(document.getElementById('<%="a"&fields(i)(formName)%>'),'dummyA','MM/dd/yyyy'); return false;"><a name='dummyA' id='dummyA' href='#'></a></td>
								</tr>
						<%end select%>
						<%
					case "fck"
						%>
							<%
							if instr(efields,"a"&fields(i)(formName))  or formError = false then
								value = ""
							else
								value = request.form("a"&fields(i)(formName))
							end if
							%>
						<%select case addNewDisplay%>
							<%case "inline"%>	
								<label for="a<%=fields(i)(formName)%>"><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%>
										<textarea id="a<%=fields(i)(formName)%>" name="a<%=fields(i)(formName)%>" rows="10" cols="80"><%=value%></textarea>
								</label>
							<%case "table"%>
								<tr>
									<td><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%></td>
									<td>
										<textarea id="a<%=fields(i)(formName)%>" name="a<%=fields(i)(formName)%>" rows="10" cols="80"><%=value%></textarea>
									</td>
								</tr>
						<%end select%>
						<%
					case "select"
						%>
						<%
						if instr(efields,"a"&fields(i)(formName))  or formError = false then
							value = ""
						else
							value = request.form("a"&fields(i)(formName))
						end if
						if ubound(fields(i)) > 13 Then
							If fields(i)(defaultValue) <> "" And formError = false then
								value = fields(i)(defaultValue)
							End if
						end if
						args = split(fields(i)(formType),"*")
						selTable = args(1)
						abbrCol = args(2)
						dispCol = args(3)
						if ubound(args) = 6 then
							dependColName = args(4)
							if args(6) = "number" then
								dependColValue = SQLclean(request("s"&args(5)),"N","S")
							else
								dependColValue = SQLclean(request("s"&args(5)),"T","S")
							end if
							dependColType = args(6)
						else
							dependColName = ""
							dependColValue = ""
							dependColType = fields(i)(sqlType)
							'response.write(dependColType)
						end If
						multiSelect = false
						If UBound(args) = 9 Then
							multiTable = args(7)
							multiRecordId = args(8)
							multiValueId = args(9)
							multiSelect = true
						End If
						%>
						<%select case addNewDisplay%>
							<%case "inline"%>	
								<label for="a<%=fields(i)(formName)%>"><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%>
								<%call SelectFromTable(selTable, abbrCol, dispCol,"a"&fields(i)(formName), value,dependColName,dependColValue,dependColType,isSupportAccount)%></label>
							<%case "table"%>
								<tr>
									<td valign="top"><% errorchktext fields(i)(formLabel),"a"&fields(i)(formName)%></td>
									<td>
										<%
										If Not multiSelect then
											call SelectFromTable(selTable, abbrCol, dispCol,"a"&fields(i)(formName), value,dependColName,dependColValue,dependColType,isSupportAccount)
										Else
											multi = Split(multis(i),",")
											If addError Then 
												value = multi(0)
											End if
											call SelectFromTable(selTable, abbrCol, dispCol,"a"&fields(i)(formName)&"_1", value,dependColName,dependColValue,dependColType,isSupportAccount)
											counter = 1
											For q = 2 To UBound(multi)
												counter = counter + 1
												value = multi(counter-1)
												call SelectFromTable(selTable, abbrCol, dispCol,"a"&fields(i)(formName)&"_1", value,dependColName,dependColValue,dependColType,isSupportAccount)
											Next
											counter = counter + 1
											%>
											<div id="<%="a"&fields(i)(formName)%>_1_end"></div>
											<a href="javascript:void(0);" number="<%=counter%>" onclick="addMulti('<%="a"&fields(i)(formName)&"_1"%>',this)" id="pGroups_add_endLink">add</a>
											<%
										End if
										%>
									</td>
								</tr>
						<%end select%>
						<%
						If TypeName(notes) = "Dictionary" Then
							If notes.exists(fields(i)(formName)) Then
							%>
								<td></td>
								<td><p style="width:260px;padding-top:0px!important;"><%=notes(fields(i)(formName))%></p></td>
							<%
							End if
						End if					
					end select
				end if

				Next
				if addNewDisplay = "table" then
					response.write "</table>"
				end if
				%>
				
				<br class="clearfloats">				
				<%
				if addButtonText <> "" then
					buttonText = addButtonText
				else
					buttonText = "Add Record"
				end if
				%>
				<input type="hidden" name="addItem" id="addItem" value="addItem">
				<%if request.form("addItem") <> "" or fileBoxName = "" then%>
				<input id="submitBtn" value="<%=buttonText%>" type="button" style="display:inline;" onclick='document.getElementById("addForm").submit(); document.getElementById("submitBtn").disabled = true;' >
				<input type="RESET" value="Cancel" style="display:inline;margin-left:5px;" onClick="showAdditem()">
				<%else%>
				<input value="<%=buttonText%>" type="button" onclick="validateUpload('<%=fileBoxName%>','trash')">
				<%end if%>

			</fieldset>
		</form>

		<%if fileBoxName <> "" then%>
			<form action="uploader.pl?" method="post" ENCTYPE="multipart/form-data" target="nhiddenIframe" name="uploadFormn" id="uploadForm" style="display:none;">
				<!--<input type="button" value="Upload" class="deletebutton" id="ub" NAME="uploadButton" onClick="validateUpload()">-->
			</form>
		<%end if%>
		</div>
		</div>
		<%If extraLink <> "" then%>
		<div style="margin-top:10px;"><span><%=extraLink%></span></div>
		<%End if%>
		</td>

		</tr>
		</table>
		<br>
		<%end if%>


			<%If not rec.eof then
			Set columns=Server.CreateObject("Scripting.Dictionary")
			counter = 0
			for each x in rec.Fields
				columns.Add LCase(x.name), counter
				counter = counter + 1
			next
			rs = rec.getrows()
			%>

			<%if addOnly <> "true" then%>
			<%'=efields%>
			<table>
				
				<thead>
				<%if formError= true and updateError = true then%>
				<tr>
				<td colspan="<%=numListColumns-1%>">
				<font color="red">Please Correct Errors Highlighted in Red.</font>
				<%If errorStr <> "" then%>
					<p style="color:red;text-align:left;margin-top:0px;"><%=errorStr%></p>
				<%End if%>
				</td>
				</tr>
				<%end if%>
				<tr>
				<td colspan="<%=numListColumns%>" class="caption"><%=tableTitle%></td>
				</tr>
					<tr <%if noList = "true" then%>style="display:none;"<%end if%>>
						<%If numberRows then%>
							<td style="width:16px;height:16px;">&nbsp;</td>
						<%End if%>
						<td style="width:16px;height:16px;">&nbsp;</td>
						<%
						for i = 0 to ubound(fields)
							if fields(i)(listEnabled) = "true" then
								hrefStr = Request.ServerVariables("SCRIPT_NAME") & "?d=" & dir & "&s=" & request("search") _
														&"&strSearch=" & request("strSearch") & "&searchType=" & request("searchType") & "&prevUrl=" & Server.URLEncode(request.querystring("prevurl"))
								if fields(i)(sortEnabled) = "true" then
									if fields(i)(dbName) <> "none" then
										If fields(i)(dispSQL) <> "@" then 
											hrefStr = hrefStr & "&o=" & fields(i)(dbName)
										Else
											Set RegEx = New regexp
											RegEx.Pattern = "\$.*?\$"
											RegEx.Global = True
											RegEx.IgnoreCase = True
											set matches = RegEx.Execute(fields(i)(HTML))											
											myO = matches(0)
											hrefStr = hrefStr & "&o=" & Replace(myO,"$","")
										End if

									Else
										Set RegEx = New regexp
										RegEx.Pattern = "#.*?#"
										RegEx.Global = True
										RegEx.IgnoreCase = True
										set matches = RegEx.Execute(fields(i)(HTML))
										for each match in matches
											o = replace(match,"#","")
										next
											hrefStr = hrefStr & "&o=" & o
										Set RegEx = nothing
									end if
								else
									hrefStr = hrefStr & "&o=" & defaultSort
								end if
								for j = 0 to ubound(fields)
									if fields(j)(searchEnabled) = "true" or fields(j)(searchEnabled) = "true*hidden" then
										if request.form("s"&fields(j)(formName)) <> "" then
											hrefStr = hrefStr & "&" & "s" & fields(j)(formName) & "=" & request.form("s"&fields(j)(formName))
										end if
										if request.querystring("s"&fields(j)(formName)) <> "" then
											hrefStr = hrefStr & "&" & "s" & fields(j)(formName) & "=" & request.querystring("s"&fields(j)(formName))
										end if
									end if
								next
								'response.write(hrefStr)
						%>
							<td><a href="<%=hrefStr%>"><b><%=fields(i)(listLabel)%></b></a></td>		
						<%
							end if
						next
						%>
					</tr>
				</thead>
				<tbody>
					<!-- Start Loop Here-->
					<%
					
					
					iRows = UBound(rs, 2)
					iCols = UBound(rs, 1)
					iPages = Irows / Ioffset
										
					If instr(ipages,".")=0 then
						ipages = ipages& ".00"
					End if
					
					If iRows > (iOffset + iStart) Then
						iStop = iOffset + iStart - 1
					Else
						iStop = iRows
					End If

					  For iRowLoop = iStart to iStop

							totalrows = (ubound(rs,2))
														
							If changecolor="Yes" then
								bgcolor="#ffffff"
								changecolor="no"
							Else
								bgcolor="#F1F1F1"
								changecolor="Yes"
							End if

							handleClickValue = rs(columns(LCase(handleClickId)),iRowLoop)
					   %>
					   <%
						If handleClickOverRide <> "" then
							Set RegEx = New regexp
							RegEx.Pattern = "\$.*?\$"
							RegEx.Global = True
							RegEx.IgnoreCase = True
							set matches = RegEx.Execute(handleClickOverRide)
							for each match in matches
								name = replace(match.value,"$","")
								value = rs(columns(LCase(name)),iRowLoop)

								if isnull(value) then 
									value = ""
								end if
								handleClickOverRide2 = replace(handleClickOverRide,match.value, value)
							next
							set RegEx = Nothing
						End if
					   %>
						<tr id="front-<%= handleClickValue %>" bgcolor="<%=bgcolor%>" class="front"<%if noList = "true" then%>style="display:none;"<%end if%>>
							<%If numberRows then%>
							<td>
								<%=iRowLoop+1%>
							</td>
							<%End if%>
							<td id="icon-<%= handleClickValue %>" <%If handleClickOverRide <> "" then%>OnClick="<%=handleClickOverRide2%>"<%else%>OnClick="handleClick('<%= handleClickValue %>')"<%End if%>><img id="icon-<%= handleClickValue %>-img" src="<%=mainAppPath%>/images/plus.gif" alt="Edit Record" style="width:16px;height16px;" border="0"></td>
							<%
							for i = 0 to ubound(fields)
								if fields(i)(listEnabled) = "true" then
									'if companyUsesSso()  and fields(i)(formName) = "resetPassword" then    
										'response.write("pw")
									'end if
									if fields(i)(dbName) = "none" Or fields(i)(dispSQL) = "@" then

									if companyUsesSso()  and fields(i)(formName)  = "resetPassword" then 
										'htmlStr = "unabled"
										Set RegEx = New regexp
										RegEx.Pattern = "#.*?#"
										RegEx.Global = True
										RegEx.IgnoreCase = True
										htmlStr = RegEx.Replace(fields(i)(HTML),"")
										Set RegEx = nothing

										Set RegEx = New regexp
										RegEx.Pattern = "\$.*?\$"
										RegEx.Global = True
										RegEx.IgnoreCase = True
										set matches = RegEx.Execute(fields(i)(HTML))
										for each match in matches
											name = replace(match.value,"$","")
											value = rs(columns(LCase(name)),iRowLoop)
											if isnull(value) then 
												value = ""
											end if
											htmlStr = replace(htmlStr,match.value, value)
										next
										set RegEx = nothing
										
									else
										Set RegEx = New regexp
										RegEx.Pattern = "#.*?#"
										RegEx.Global = True
										RegEx.IgnoreCase = True
										htmlStr = RegEx.Replace(fields(i)(HTML),"")
										Set RegEx = nothing

										Set RegEx = New regexp
										RegEx.Pattern = "\$.*?\$"
										RegEx.Global = True
										RegEx.IgnoreCase = True
										set matches = RegEx.Execute(fields(i)(HTML))
										for each match in matches
											name = replace(match.value,"$","")
											value = rs(columns(LCase(name)),iRowLoop)
											if isnull(value) then 
												value = ""
											end if
											htmlStr = replace(htmlStr,match.value, value)
										next
										set RegEx = nothing
									end if

									elseif fields(i)(dispSQL) <> "" and fields(i)(dispSQL) <> "none" then
										dispSQLdbName = split(fields(i)(dispSQL),"*")(0)
										SQL = split(fields(i)(dispSQL),"*")(1)
										Set RegEx = New regexp
										RegEx.Pattern = "\$.*?\$"
										RegEx.Global = True
										RegEx.IgnoreCase = True
										set matches = RegEx.Execute(fields(i)(dispSQL))
										for each match in matches
											name = replace(match.value,"$","")										
											value = rs(columns(LCase(fields(i)(dbName))),iRowLoop)
											if isnull(value) then 
												value = ""
											end if
											value = replace(value,"'","")
											if value <> "" then
												strQuery = replace(SQL,match.value,value)
												call getconnectedadm
												Set join_rs = Server.CreateObject("ADODB.RecordSet")					
												join_rs.Open strQuery,ConnAdm,3,3 
												if not join_rs.eof then
													htmlStr = join_rs(dispSQLdbName) 
											    else
													htmlStr = "none"
												end if
												call disconnectadm
											else
												htmlStr = "none"
											end if
										next
										set RegEx = nothing									
									Else
										htmlStr = rs(columns(LCase(fields(i)(dbName))),iRowLoop)
										if htmlStr = "support@arxspan.com" then
										isSupportAccount = true
									end if
									end if
							%>

									<%if updateError = true and cStr(updateId) = cStr(handleClickValue) and fields(i)(dbName) = handleClickId then%>
										<td><font color="red"><%=htmlStr%></font></td>				
									<%else%>
										<td><%=htmlStr%></td>
									<%end if%>
							<%
								end if
							next
							%>
							
						</tr>
						<tr id="edit-<%= handleClickValue %>" bgcolor="<%=bgcolor%>" class="editable">
							<td></td>
							<%
							cs = numListColumns -1
							if cs > 2 then 
								cs = cs - 2
							end if
							%>
							<td colspan="<%=numListColumns-1%>">
							<%
							hrefStr = Request.ServerVariables("SCRIPT_NAME") & "?search=" & request("search") _
													& "&strSearch=" & request("strSearch") & "&o=" & sortby & "&d=" & curdir & "&Start=" & iStart & "&prevUrl=" & Server.URLEncode(request.querystring("prevurl"))
							for j = 0 to ubound(fields)
								if fields(j)(searchEnabled) = "true" or fields(j)(searchEnabled) = "true*hidden" then
									if request.form("s"&fields(j)(formName)) <> "" then
										hrefStr = hrefStr & "&" & "s" & fields(j)(formName) & "=" & request.form("s"&fields(j)(formName))
									end if
									if request.querystring("s"&fields(j)(formName)) <> "" then
										hrefStr = hrefStr & "&" & "s" & fields(j)(formName) & "=" & request.querystring("s"&fields(j)(formName))
									end if
								end if
							next
							%>
							<form name="update-<%=handleClickValue%>" id="update-<%=handleClickValue%>" method="POST" action="<%=hrefStr%>" enctype="application/x-www-form-urlencoded">

								<!--Start Edit Section-->
								<table class="editItemTable">
								<%
								Call getconnectedAdm
								for i = 0 to ubound(fields)
									if fields(i)(editEnabled) = "true" then
										fieldType = split(fields(i)(formType),"*")(0)
										args = split(fields(i)(formType),"*")


									if fields(i)(dbName) = "none" and fields(i)(formType) = "HTML" then
										Set RegEx = New regexp
										RegEx.Pattern = "#.*?#"
										RegEx.Global = True
										RegEx.IgnoreCase = True
										htmlStr = RegEx.Replace(fields(i)(HTML),"")
										Set RegEx = nothing

										Set RegEx = New regexp
										RegEx.Pattern = "\$.*?\$"
										RegEx.Global = True
										RegEx.IgnoreCase = True
										set matches = RegEx.Execute(fields(i)(HTML))
										for each match in matches
											name = replace(match.value,"$","")
											value = rs(columns(LCase(name)),iRowLoop)
											if isnull(value) then 
												value = ""
											end if
											htmlStr = replace(htmlStr,match.value, value)
										next
										set RegEx = nothing										
									end if	
										select case fieldType
										case "HTML"
										
										%>
											<tr style="border-bottom: 1px solid #D9D9D9;">
													<td>
														<%=fields(i)(formName)%>
													</td>
													<td>
														<%=htmlStr%>
													</td>
													<td></td>
											</tr>
										<%
									
										case "divider"
										%>
											<tr style="border-bottom: 1px solid #D9D9D9;">
													<td colspan="2">
														<h1 style="margin-top:10px;"><%=fields(i)(defaultValue)%></h1><hr style="margin-bottom:4px;width:80%">
													</td>
													<td></td>
											</tr>
										<%
										case "text"
											if ubound(args) > 0 then
												textboxSize  = args(1)
											else
												textboxSize = 140
											end if
											 
											%>
													<tr style="border-bottom: 1px solid #D9D9D9;">
														<td>
														<% 
														if cStr(rs(columns(LCase(handleClickId)),iRowLoop)) = updateId and updateError = true then
															errorchktext fields(i)(formLabel),"u"&fields(i)(formName)
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
										
																value = ""
															else
																value = request.form("u"&fields(i)(formName)& "-" & handleClickValue)
																
															end if
														else
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
																value = ""
															else
																if fields(i)(dbName) = "none" and  fields(fieldColumns(replace(fields(i)(formName),"match","")))(validationFunction) = "match" then
																	value = rs(columns(LCase(fields(fieldColumns(replace(fields(i)(formName),"match","")))(dbName))),iRowLoop)
																else
																	value = rs(columns(LCase(fields(i)(dbName))),iRowLoop)
																end if
															end if

															response.write fields(i)(formLabel)
														end If
														'response.write("hey"&value&" "&fields(i)(dbName)&" "&columns(fields(i)(dbName))&" h")
														if fields(i)(dbName) = "none" and  fields(fieldColumns(replace(fields(i)(formName),"match","")))(validationFunction) = "match" then
															thisFormName = "u" & replace(fields(i)(formName),"match","") & "-" & handleClickValue & "match"
														else
															thisFormName = "u" & fields(i)(formName) & "-" & handleClickValue
														end if
														%>
														</td>
														<td><input name="<%=thisFormName%>" id="<%=thisFormName%>" type="text" value="<%=EscapeQuotes(value)%>" style="width:<%=textboxSize%>px;"></td>
														<td></td>
													</tr>
											<%
										case "textarea"
											if ubound(args) > 0 then
												taRows  = args(1)
												taCols = args(2)
											else
												taRows  = 2
												taCols = 20
											end if
											%>
													<tr style="border-bottom: 1px solid #D9D9D9;">
														<td>
														<% 
														if cStr(rs(columns(LCase(handleClickId)),iRowLoop)) = updateId and updateError = true then
															errorchktext fields(i)(formLabel),"u"&fields(i)(formName)
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
																value = ""
															else
																value = request.form("u"&fields(i)(formName)& "-" & handleClickValue)
															end if
														else
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
																value = ""
															else
																if fields(i)(dbName) = "none" and  fields(fieldColumns(replace(fields(i)(formName),"match","")))(validationFunction) = "match" then
																	value = rs(columns(LCase(fields(fieldColumns(replace(fields(i)(formName),"match","")))(dbName))),iRowLoop)
																else
																	value = rs(columns(LCase(fields(i)(dbName))),iRowLoop)
																end if
															end if
															response.write fields(i)(formLabel)
														end if
														if fields(i)(dbName) = "none" and  fields(fieldColumns(replace(fields(i)(formName),"match","")))(validationFunction) = "match" then
															thisFormName = "u" & replace(fields(i)(formName),"match","") & "-" & handleClickValue & "match"
														else
															thisFormName = "u" & fields(i)(formName) & "-" & handleClickValue
														end if
														%>
														</td>
														<td>
														<textarea rows="<%=taRows%>" cols="<%=taCols%>" name="<%=thisFormName%>" id="<%=thisFormName%>"><%=EscapeQuotes(value)%></textarea></td>
														<td></td>
													</tr>
											<%
										case "password"
											%>
													<tr style="border-bottom: 1px solid #D9D9D9;">
														<td>
														<% 
														if cStr(rs(columns(LCase(handleClickId)),iRowLoop)) = updateId and updateError = true then
															errorchktext fields(i)(formLabel),"u"&fields(i)(formName)
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
																value = ""
															else
																value = request.form("u"&fields(i)(formName) & "-" & handleClickValue)
																'password matching was broken before this 12/14/09
																if value = "" then
																	value = request.form("u" & replace(fields(i)(formName),"match","") & "-" & handleClickValue & "match")
																end if
															end if
														else
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
																value = ""
															else
																if fields(i)(dbName) = "none" and  fields(fieldColumns(replace(fields(i)(formName),"match","")))(validationFunction) = "match" then
																	value = rs(columns(LCase(fields(fieldColumns(replace(fields(i)(formName),"match","")))(dbName))),iRowLoop)
																else
																	value = rs(LCase(columns(fields(i)(dbName))),iRowLoop)
																end if
															end if
															response.write fields(i)(formLabel)
														end if
														if fields(i)(dbName) = "none" and  fields(fieldColumns(replace(fields(i)(formName),"match","")))(validationFunction) = "match" then
															thisFormName = "u" & replace(fields(i)(formName),"match","") & "-" & handleClickValue & "match"
														else
															thisFormName = "u" & fields(i)(formName) & "-" & handleClickValue
														end if
														%>
														</td>
														<td><input name="<%=thisFormName%>" id="<%=thisFormName%>" type="password" value="<%=EscapeQuotes(value)%>"></td>
														<td></td>
													</tr>

											<%
										case "date"
											%>
													<tr style="border-bottom: 1px solid #D9D9D9;">
														<td>
														<% 
														if cStr(rs(columns(LCase(handleClickId)),iRowLoop)) = updateId and updateError = true then
															errorchktext fields(i)(formLabel),"u"&fields(i)(formName)
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
																value = ""
															else
																value = dateAddZeros(request.form("u"&fields(i)(formName) & "-" & handleClickValue))
															end if
														else
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
																value = ""
															else
																value = dateAddZeros(rs(columns(LCase(fields(i)(dbName))),iRowLoop))
															end if
															response.write fields(i)(formLabel)
														end if
														%>
														</td>
															<td><input type="text" name="u<%=fields(i)(formName)%>-<%=handleClickValue%>" id="u<%=fields(i)(formName)%>-<%=handleClickValue%>" value="<%=value%>" size="16" onclick="cal<%="u"&fields(i)(formName)%>-<%=handleClickValue%>.select(document.forms['update-<%=handleClickValue%>'].<%="u"&fields(i)(formName)%>,'dummyA<%=handleClickValue%>','MM/dd/yyyy'); return false;">
															<a name='dummyA<%=handleClickValue%>' id='dummyA<%=handleClickValue%>' href='#'></a></td>
															<td></td>
													</tr>
											<%
										case "fck"
											%>
													<tr style="border-bottom: 1px solid #D9D9D9;">
														<td>
														<% 
														if cStr(rs(columns(LCase(handleClickId)),iRowLoop)) = updateId and updateError = true then
															errorchktext fields(i)(formLabel),"u"&fields(i)(formName)
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
																value = ""
															else
																value = request.form("u" & fields(i)(formName) & "-" & handleClickValue)
															end if
														else
															if instr(efields,"u"&fields(i)(formName)&",") and updateError = true and handleClickValue = updateId then
																value = ""
															else
																value = HTMLDecode(rs(columns(LCase(fields(i)(dbName))),iRowLoop))
															end if
															response.write fields(i)(formLabel)
														end if
														%>
														<td id="u<%=fields(i)(formName)%>-<%=handleClickValue%>Container">
														<textarea id="u<%=fields(i)(formName)%>-<%=handleClickValue%>" name="u<%=fields(i)(formName)%>-<%=handleClickValue%>" rows="10" cols="80" style="width: 600px; height: 600px"><%=value%></textarea>
														</td>
														<td></td>
															
													</tr>
											<%
										case "select"
											if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
												value = ""
											else
												value = rs(columns(LCase(fields(i)(dbName))),iRowLoop)

											end if
											args = split(fields(i)(formType),"*")
											selTable = args(1)
											abbrCol = args(2)
											dispCol = args(3)
											if ubound(args) = 6 then
												dependColName = args(4)
												dependColValue = rs(columns(LCase(args(5))),iRowLoop)
												dependColType = args(6)
											else
												dependColName = ""
												dependColValue = ""
												dependColType = fields(i)(sqlType)
											end If
											multiSelect = false
											If UBound(args) = 9 Then
												multiTable = args(7)
												multiRecordId = args(8)
												multiValueId = args(9)
												multiSelect = true
											End If											
										 %><tr style="border-bottom: 1px solid #D9D9D9;"><td valign="top"><%
											if cStr(rs(columns(LCase(handleClickId)),iRowLoop)) = updateId and updateError = true then
												errorchktext fields(i)(formLabel),"u"&fields(i)(formName)
												if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
													value = ""
												else
													value = request.form("u"&fields(i)(formName) & "-" & handleClickValue)
												end if
											else
												if instr(efields,"u"&fields(i)(formName)&",") and updateError = true then
													value = ""
												else
													value = rs(columns(LCase(fields(i)(dbName))),iRowLoop)
												end if
											     response.write fields(i)(formLabel)
											end if
											%>
												</td>
												<td>
												<%
												If Not multiselect then 

													if  fields(i)(formLabel) = "Use SSO" then
														'response.write("sso")
													end if

													 If isSupportAccount = true and fields(i)(formLabel) = "Role*" then
													 	response.write("Admin")
													 end if
																
													 If isSupportAccount = true and fields(i)(formLabel) = "Enabled*" then
													 	response.write("yes")
													 end if

													 call SelectFromTable(selTable, abbrCol, dispCol,"u"&fields(i)(formName) & "-" & handleClickValue, value,dependColName,dependColValue,dependColType,isSupportAccount)
																					        
																									
												Else
													If updateError = false Or CStr(handleClickValue) <> CStr(updateId) then
														strQuery = "SELECT * FROM "&multiTable&" WHERE " & multiRecordId & "=" & SQLClean(handleClickValue,"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
														Set mRec = server.CreateObject("ADODB.RecordSet")
														mRec.open strQuery,conn,3,3
														If Not mRec.eof then
															value = CStr(mRec(multiValueId))
															mRec.movenext
														Else 
															value = "-1"
														End If
														thisSelectId = "u"&fields(i)(formName) & "-" & handleClickValue&"_1"
														call SelectFromTable(selTable, abbrCol, dispCol, thisSelectId , value,dependColName,dependColValue,dependColType,isSupportAccount)
														counter = 1
														Do While Not mRec.eof
															counter = counter + 1
															value = CStr(mRec(multiValueId))
															thisSelectId = "u"&fields(i)(formName) & "-" & handleClickValue&"_"&counter
															call SelectFromTable(selTable, abbrCol, dispCol, thisSelectId, value,dependColName,dependColValue,dependColType,isSupportAccount)
															mRec.movenext
														Loop
													Else
														multi = Split(multis(i),",")
														value = multi(0)
														thisSelectId = "u"&fields(i)(formName) & "-" & handleClickValue&"_1"
														call SelectFromTable(selTable, abbrCol, dispCol,thisSelectId, value,dependColName,dependColValue,dependColType,isSupportAccount)
														counter = 1
														For q = 1 To UBound(multi)
															If multi(q) <> "-1" And multi(q) <> "" Then
																counter = counter + 1
																value = multi(q)
																thisSelectId = "u"&fields(i)(formName) & "-" & handleClickValue&"_"&counter
																call SelectFromTable(selTable, abbrCol, dispCol,thisSelectId, value,dependColName,dependColValue,dependColType,isSupportAccount)
															End if
														Next
													End if
												 counter = counter + 1
													%>
													<div id="<%="u"&fields(i)(formName)%>-<%=handleClickValue%>_1_end">
														
													</div>
													<a href="javascript:void(0);" number="<%=counter%>" onclick="addMulti('<%="u"&fields(i)(formName) & "-" & handleClickValue&"_1"%>',this)" id="">add</a>
													<%
												End if													
												%>
													
												</td>
												<td></td>



											</tr>
										<%
											If TypeName(notes) = "Dictionary" Then
												If notes.exists(fields(i)(formName)) Then
												%>
													<td></td>
													<td><p style="width:260px;padding-top:0px!important;"><%=notes(fields(i)(formName))%></p></td>
													<td></td>
												<%
												End if
											End if		
										end select
									end if
								next
								%>
									<tr>
									    
										<td><input type="submit" name="update" value="Update"></td>
										 
										<%if redirect = "true" then%>
											<%if hideDelete <> "true"  then%>										 
											  <td><input type="submit" name="delete" value="Disable" onClick="return confirmDelete()" 
											  <%if  isSupportAccount = true then %> style="display: none" <%end if%>></td>																
											<%end if%>										
									          <td ><input type="button" name="cancel" value="Cancel" OnClick="window.location='<%=request.querystring("prevURL")%>';"></td>
										      									
											<%if hideDelete = "true" then%>
												<td></td>
											<%end if%>						
										<%else%>
											<%if hideDelete <> "true"  then%>
											  <td><input type="submit" name="delete" value="Disable" onClick="return confirmDelete()"  <%if  isSupportAccount = true then %> style="display: none" <%end if%>></td>
											<%end if%>
											  <td ><input type="button" name="cancel" value="Cancel" OnClick="handleClick('<%= handleClickValue %>')"></td>
																				
											<%if hideDelete = "true" then%>
												<td></td>
											<%end if%>
										<%end if%>
									</tr>
								</table>

								<%
								isSupportAccount = false
								if fields(fieldColumns(deleteKey))(editEnabled) <> "true" then
								%>
									<input name="u<%=fields(fieldColumns(deleteKey))(formName)%>" id="u<%=fields(fieldColumns(deleteKey))(formName)%>" value="<%=rs(columns(LCase(deleteKey)),iRowLoop)%>" type="hidden">
								<%
								end if
								%>
								</form>
							</td>

						</tr>
					<% Next 			
					%>
					<!-- END Loop Here-->
					<tr>
						<td colspan="<%=numListColumns%>" align="right">
							<%
							hrefStr = Request.ServerVariables("SCRIPT_NAME") & "?search=" & request("search") _
													& "&strSearch=" & request("strSearch") & "&o=" & sortby & "&d=" & curdir & "&searchType=" & request("searchType")& "&prevUrl=" & Server.URLEncode(request.querystring("prevurl")) & rtnStr
							for j = 0 to ubound(fields)
								if fields(j)(searchEnabled) = "true" or fields(j)(searchEnabled) = "true*hidden" then
									if request.form("s"&fields(j)(formName)) <> "" then
										hrefStr = hrefStr & "&" & "s" & fields(j)(formName) & "=" & request.form("s"&fields(j)(formName))
									end if
									if request.querystring("s"&fields(j)(formName)) <> "" then
										hrefStr = hrefStr & "&" & "s" &  fields(j)(formName) & "=" & request.querystring("s"&fields(j)(formName))
									end if
								end if
							next
							%>
							<%if iStart > 0 then %>
								<a href="<%=hrefStr & "&p=f"%>"><img src="<%=mainAppPath%>/images/resultset_first.gif" alt="First" border="0"></a> | <a href="<%=hrefStr & "&Start=" & iStart-iOffset%>" title="Previous Page"><img src="<%=mainAppPath%>/images/resultset_previous.gif" alt="Previous" border="0"></A>
							<%end if
							if iStop < iRows then%>
								<a href="<%=hrefStr & "&Start=" & iStart+iOffset %>" title="Next Page"><img src="<%=mainAppPath%>/images/resultset_next.gif" border="0" alt="Next"></A> | <a href="<%=hrefStr & "&Start=" & left(ipages,instr(iPages,".")-1) * iOffset %> "><img src="<%=mainAppPath%>/images/resultset_last.gif" border="0" alt="Last"></a>
							<%end if%>
						</td>

					</tr>
					<%'=hrefStr%>

				</tbody>
			</table>
			<!--End edit section-->
		<%end if%>
		<%Else%>
			<%if addOnly <> "true" then%>
				No data to display. Please search again.
			<%end if%>
		<%End if%>

	<!--</div>-->
	<!--</div>
	</div>
	</div>-->

<%
if updateError = true then
%>
<script type="text/javascript">
handleClick('<%=updateId%>');
</script>
<%
end if
%>
<%
if addError = true or request.querystring("addId")<>"" or addOnly = "true" then
%>
<script type="text/javascript">
showAdditem();
</script>
<%
end if
%>
<%
if request("searchType") = cStr(1) then
%>
<script type="text/javascript">
try
{
	showAdvancedSearch();
}
catch(err){}
</script>
<%
end if
%>

<%
if request.queryString("editId") <> "" then
%>
<script type="text/javascript">
handleClick('<%=request.queryString("editId")%>');
</script>
<%
end if
%>
<div id="tempDiv"></div>
	</body>
	</html>