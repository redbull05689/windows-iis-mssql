<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
response.charset = "UTF-8"
response.codePage = 65001
%>
<div class="dashboardObjectContainer changePassword"><div class="objHeader elnHead"><h2><%=preferencesLabel%></h2></div>
			<div class="objBody">

				<form method="post" action="<%=mainAppPath%>/users/my-profile.asp">
				<%If request.querystring("r") = "1" then%>
						<p class="changePasswordMessage">Options have been updated.</p>
				<%End if%>
						<%If errString <> "" then%>
							<p class="changePasswordMessage"><%=errString%></p>
						<%End if%>

						<label for="chemicalEditor"><%=chemicalEditorLabel%></label><br/>
						<select name="chemicalEditor" id="chemicalEditor">
							<option value="0" <%If session("noChemDraw") = True AND Not session("useMarvin") = True then%> SELECTED<%End if%>>Live Edit</option>
							<option value="1" <%If Not session("noChemDraw") = True AND Not session("useMarvin") = True then%> SELECTED<%End if%>>ChemDraw&#8482; Plugin</option>
							<% if session("companyHasMarvin") then %>
								<option value="2" <%If session("useMarvin") = True then%> SELECTED<%End if%>>Marvin JS</option>
							<% end if %>
						</select>

						<br/>

						<label for="defaultWitnessId"><%=defaultWitnessLabel%></label><br/>
							<select name="defaultWitnessId" id="defaultWitnessId" style="width:220px;">
							<option value="-2" <%If "-2" = session("defaultWitnessId") then%> SELECTED<%End if%>>--Please select a Witness--</option>
							<%If whichClient = "TAKEDA_VBU" Then%>
							<option value="-1" <%If "-1" = session("defaultWitnessId") then%> SELECTED<%End if%>>--Not Pursued--</option>
							<%Else%>
							<option value="-1" <%If "-1" = session("defaultWitnessId") then%> SELECTED<%End if%>>--No Witness--</option>
							<%End If%>
							<%
							usersTable = getDefaultSingleAppConfigSetting("usersTable")
							Set uRec = Server.CreateObject("ADODB.RecordSet")
							strQuery = "SELECT id, firstName, lastName FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id <>" & SQLClean(session("userId"),"N","S")&" AND id in ("&getUsersICanSee()&")"
							''412015
							If session("useSafe") Then
								strQuery = strQuery &" AND softToken=1"
							End if
							''/412015
							uRec.open strQuery,conn,3,3
							Do While Not uRec.eof
								%>
								<option value="<%=uRec("id")%>" <%If uRec("id") = session("defaultWitnessId") then%> SELECTED<%End if%>><%=uRec("firstName")%>&nbsp;<%=uRec("lastName")%></option>
								<%
								uRec.movenext
							loop
							%>
							</select>
						<br/>
						<label for="defaultMolUnits"><%=defaultMolUnitsLabel%></label><br/>
						<select name="defaultMolUnits" id="defaultMolUnit">
							<option value="" <%If session("defaultMolUnits") = "" then%> SELECTED<%End if%>>None</option>
							<option value="μmol" <%If session("defaultMolUnits") = "μmol" then%> SELECTED<%End if%>>μmol</option>
							<option value="mmol" <%If session("defaultMolUnits") = "mmol" then%> SELECTED<%End if%>>mmol</option>
							<option value="mol" <%If session("defaultMolUnits") = "mol" then%> SELECTED<%End if%>>mol</option>
						</select>

						<br/>
						<label for="leftNavSort">Left Navigation Sort</label><br/>
						<select name="leftNavSort" id="leftNavSort">
							<%
							If userOptions.exists("leftNavSort") Then
								leftNavSort = userOptions.Get("leftNavSort")
							Else
								leftNavSort = "recentlyViewed"
							End if
							%>
							<option value="recentlyViewed" <%If leftNavSort = "recentlyViewed" then%> SELECTED<%End if%>>Recently Viewed</option>
							<option value="dateCreated" <%If leftNavSort = "dateCreated" then%> SELECTED<%End if%>>Date Created</option>
						</select>
						
						<br/>
						<%'ELN-447
						Set rec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT redirectUserToSignedPDF FROM usersView WHERE id="&SQLClean(session("userId"),"N","S")
						rec.open strQuery,conn,3,3
						%>
							<label for="redirectToSignedPDFUser">Default Display for Closed Experiments</label><br/>
							<select name="redirectToSignedPDFUser" id="redirectToSignedPDFUser">
								<option value="1" <%If rec("redirectUserToSignedPDF") = 1 then%> SELECTED<%End if%>>PDF View</option>
								<option value="0" <%If rec("redirectUserToSignedPDF") = 0 then%> SELECTED<%End if%>>Experiment View</option>
							</select>
							
						<br/>
						
						
						<%'INV-316 - Letting the user select the printer 
						Set uRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT labelPrinterId FROM "&usersTable&" WHERE id="&SQLClean(session("userId"),"N","S")
						uRec.open strQuery,connAdm,3,3
						If Not uRec.eof Then
							'User has default printer selected
							defaultPrinterId = uRec("labelPrinterId")
						End If
						
						Set pRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT id, printerName FROM labelPrinterSettings WHERE companyId="&SQLClean(session("companyId"),"N","S")
						pRec.open strQuery,connAdm,3,3
						If Not pRec.eof Then
						
							%>
							<label for="labelPrinterId">Default Label Printer</label><br/>
							<select name="labelPrinterId" id="labelPrinterId" style="width:220px;">
								<option value="0">--No Printer Selected--</option>
							<%
							
							Do While Not pRec.eof
								selected = ""
								If not Isnull(defaultPrinterId) and not Isnull(pRec("id")) Then 	
									If CInt(pRec("id")) = CInt(defaultPrinterId) Then
										selected = "SELECTED"
									End If
								End If
								%>
								<option value="<%=pRec("id")%>" <%=selected%>><%=pRec("printerName")%></option>
								<%
								pRec.movenext
							loop
							%>
							</select>
							<%
						End If
						%>
							
						<br/>
						<%
						rec.close
						Set rec = nothing
						pRec.close
						Set pRec = nothing
						uRec.close
						Set uRec = nothing%>

						<input type="submit" value="<%=updateLabel%>" class="btn" name="optionsSubmit">

						</form>

		</div>
	</div>
