<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
			<table border="0" style="margin-left:50px;">
				<tr>
					<td>
						<span><%=searchTypeLabel%>:</span>
					</td>
				</tr>
				<tr>
					<td>
						<select id="searchType" name="searchType">
							<option value="s" <%If request.Form("searchType") = "SUBSTRUCTURE" Then%>selected<%End if%>>Substructure Search</option>
							<option value="d" <%If request.Form("searchType") = "DUPLICATE" Then%>selected<%End if%>>Exact Search</option>
							<option value="i" <%If request.Form("searchType") = "SIMILARITY" Then%>selected<%End if%>>Similarity Search</option>
							<option value="u" <%If request.Form("searchType") = "SUPERSTRUCTURE" Then%>selected<%End if%>>Superstructure Search</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<span><%=resultsPerPageLabel%>:</span>
					</td>
				</tr>
				<tr>
					<td>
						<select name="rpp" id="rpp">
							<option value="10" <%If resultsPerPage = 10 then%>selected<%End if%>>10</option>
							<option value="25" <%If resultsPerPage = 25 then%>selected<%End if%>>25</option>
							<option value="50" <%If resultsPerPage = 50 then%>selected<%End if%>>50</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<span>Type:</span>
					</td>
				</tr>
				<tr>
					<td>
						<select name="chemSearchMolType" name="chemSearchMolType">
							<option value="" <%If request.form("chemSearchMolType") = "" Then%>selected<%End if%>>ANY</option>
							<option value="1" <%If request.form("chemSearchMolType") = "1" Then%>selected<%End if%>>reactant</option>
							<option value="2" <%If request.form("chemSearchMolType") = "2" Then%>selected<%End if%>>reagent</option>
							<option value="3" <%If request.form("chemSearchMolType") = "3" Then%>selected<%End if%>>product</option>
							<option value="10" <%If request.form("chemSearchMolType") = "10" Then%>selected<%End if%>>attachment</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<span><%=sortByLabel%>:</span>
					</td>
				</tr>
				<tr>
					<td>
						<select name="s" name="s">
							<option value="date_updated" <%If s="date_updated" Then%>selected<%End if%>>Date Updated</option>
							<option value="first_name,last_name" <%If s="first_name,last_name" Then%>selected<%End if%>>Creator</option>
							<option value="experiment_name" <%If s="experiment_name" Then%>selected<%End if%>>Experiment Name</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<span><%=sortDirectionLabel%></span>
					</td>
				</tr>
				<tr>
					<td>
						<select name="d" id="d">
							<option value="ASC" <%If sortDir="ASC" then%>selected<%End if%>>First to Last</option>
							<option value="DESC" <%If sortDir="DESC" then%>selected<%End if%>>Last to First</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2"><label style="margin-right:0px!important;"><%=searchOnlyMyExperimentsLabel%></label><input style="margin-left:10px;" type="checkbox" <%If userOptions.Get("searchOnlyMyExperiments") then%>CHECKED<%End if%> onclick="if(this.checked){setUserOption('searchOnlyMyExperiments',true)}else{setUserOption('searchOnlyMyExeriments',false)}"></td>
				</tr>
				<tr>
					<td>
					&nbsp;
					</td>
				</tr>
				<tr>
					<td align="right">
						<input type='hidden' name="molData" id="molData" value='<%If session("noChemDraw") then%><%=request.Form("molData")%><%End if%>'>
						<input type='hidden' name="smilesData" id="smilesData" value=''>
						<input type='hidden' name="pageNum" id="pageNum" value='<%=request.Form("pageNum")%>'>
						<input id="chemSearchSubmit" type="button" value="Search" onclick="document.getElementById('searchId').value='';document.getElementById('pageNum').value='1';setMolData()">
					</td>
				</tr>
			</table>