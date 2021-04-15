<% 'revisionId
' mainAppPath
' canWrite
' ownsExp
' draftSet("e_Molarity",reactionMolarity)
' pressure
' temperature
' experimentId
%>

<td align="center" colspan="2">
			<table cellpadding="0" cellspacing="0" class="reactionContainerTable">
			<tr>
			<td align="left" style="background-color:transparent;">
			<div class="tabs"><ul id="reactionTabs"><div style="background-color:white;"><%If revisionId <> "" then%><span style="font-size:18px;padding:4px;">Loading</span><img src="<%=mainAppPath%>/images/ajax-loader.gif"><%End if%></div></ul></div>
			</td>
			</tr>
			<tr>
				<td align="left" width="100%" valign="top">
					<div id="formDiv" align="left" class="reactionFormDiv">
						<%If experimentId = "" then%>
						<div style="background-color:white;margin-bottom:5px;padding:4px;"><h1 style="display:inline;">Loading...</h1>&nbsp;&nbsp;<img src="<%=mainAppPath%>/images/ajax-loader.gif"></div>
						<%End if%>

						<div id="qv_body_container">
					
						</div>
						<table class="caseTable" cellpadding="0" cellspacing="0" style="width:100%;display:none;margin-bottom:0px;" id="rc_body">
							<tr>
								<td class="caseInnerTitle" valign="top" style="width:70px;" nowrap>
									Reaction&nbsp;Molarity<span class="requiredExperimentFieldNotice simpleAbsolute" data-fieldname="e_Molarity">*</span>
								</td>
								<td class="caseInnerData" >
									<%If revisionId = "" and canWrite And ownsExp then%>
										<div style="position:relative;z-index:10000;">
										<div class='unitsDiv' id='e_Molarity_units' style='display:none;z-index:1000;'>
										<ul>
										<li><a id='e_Molarity_units_num_0' onmouseover='clearSelectedClass(this)' onclick="appendUnits('&micro;M')">&micro;M</a></li>
										<li><a id='e_Molarity_units_num_1' onmouseover='clearSelectedClass(this)' onclick="appendUnits('mM')">mM</a></li>
										<li><a id='e_Molarity_units_num_2' onmouseover='clearSelectedClass(this)' onclick="appendUnits('M')">M</a></li>
										</ul>
										</div></div>
										<span id='e_Molarity_dummy_width' style='position:absolute;left:-4000px;'></span>
										<span id='e_Molarity_du' style='position:absolute;left:-4000px;'>M</span>

										<div style='position:relative;'>
										<input style='z-index:10;' type="text" name="e_Molarity" id='e_Molarity' value="<%=draftSet("e_Molarity",reactionMolarity)%>" onKeyUp='units(this)' onfocus='units(this)'>
										<a href='javascript:void(0)' id='e_Molarity_down_image' style='position:absolute;top:5px;left:-4000px;z-index:10;' onclick='units(this);return false;'><img src='images/down.gif' border='0'></a>
										</div>
									<%else%>
										<div class='reactionPropertiesDiv' style='width:130px;'><%=reactionMolarity%></div>
									<%End if%>
								</td>
							</tr>
							<tr>
								<td class="caseInnerTitle" valign="top" style="width:70px;">
									Pressure<span class="requiredExperimentFieldNotice simpleAbsolute" data-fieldname="e_pressure">*</span>
								</td>
								<td class="caseInnerData">
									<%If revisionId = "" and canWrite And ownsExp then%>
										<div style='position:relative;z-index:10000;'>
										<div class='unitsDiv' id='e_pressure_units' style='display:none;z-index:10000;'>
										<ul>
										<li><a id='e_pressure_units_num_0' onmouseover='clearSelectedClass(this)' onclick="appendUnits('kPa')">kPa</a></li>
										<li><a id='e_pressure_units_num_1' onmouseover='clearSelectedClass(this)' onclick="appendUnits('Pa')">Pa</a></li>
										<li><a id='e_pressure_units_num_2' onmouseover='clearSelectedClass(this)' onclick="appendUnits('atm')">atm</a></li>
										<li><a id='e_pressure_units_num_3' onmouseover='clearSelectedClass(this)' onclick="appendUnits('torr')">torr</a></li>
										<li><a id='e_pressure_units_num_4' onmouseover='clearSelectedClass(this)' onclick="appendUnits('bar')">bar</a></li>
										<li><a id='e_pressure_units_num_5' onmouseover='clearSelectedClass(this)' onclick="appendUnits('mbar')">mbar</a></li>
										<li><a id='e_pressure_units_num_6' onmouseover='clearSelectedClass(this)' onclick="appendUnits('psi')">psi</a></li>
										</ul>
										</div></div>
										<span id='e_pressure_dummy_width' style='position:absolute;left:-4000px;'></span>
										<span id='e_pressure_du' style='position:absolute;left:-4000px;'>atm</span>

										<div style='position:relative'>
										<input type="text" name="e_pressure" id="e_pressure" value="<%=draftSet("e_pressure",pressure)%>" style='position:relative;z-index:10;' onKeyUp='units(this)' onfocus='units(this)'>
										<a href='javascript:void(0)' id='e_pressure_down_image' style='position:absolute;top:5px;z-index:10;left:-4000px;' onclick='units(this);return false;'><img src='images/down.gif' border='0'></a>
										</div>
									<%else%>
										<div class='reactionPropertiesDiv' style='width:130px;'><%=pressure%></div>
									<%End if%>
								</td>
							</tr>
							<tr>
								<td class="caseInnerTitle" valign="top" style="width:70px;">
									Temperature<span class="requiredExperimentFieldNotice simpleAbsolute" data-fieldname="e_temperature">*</span>
								</td>
								<td class="caseInnerData">
									<%If revisionId = "" and canWrite And ownsExp then%>
										<div style='position:relative;z-index:10000;'>
										<div class='unitsDiv' id='e_temperature_units' style='display:none;z-index:10000;'>
										<ul>
										<li><a id='e_temperature_units_num_1' onmouseover='clearSelectedClass(this)' onclick="appendUnits('&deg;C')">&deg;C</a></li>
										<li><a id='e_temperature_units_num_0' onmouseover='clearSelectedClass(this)' onclick="appendUnits('K')">K</a></li>
										<li><a id='e_temperature_units_num_2' onmouseover='clearSelectedClass(this)' onclick="appendUnits('&deg;F')">&deg;F</a></li>
										</ul>
										</div>
										<span id='e_temperature_dummy_width' style='position:absolute;left:-4000px;'></span>
										<span id='e_temperature_du' style='position:absolute;left:-4000px;'>&deg;C</span>
										</div>
										<div style="position:relative;">
										<input type="text" name="e_temperature" id="e_temperature" value="<%=draftSet("e_temperature",temperature)%>" style='position:relative;z-index:10;' onKeyUp='units(this)' onfocus='units(this)'>
										<a href='javascript:void(0)' id='e_temperature_down_image' style='position:absolute;top:5px;z-index:10;left:-4000px;' onclick='units(this);return false;'><img src='images/down.gif' border='0'></a>
										</div>
									<%else%>
										<div class='reactionPropertiesDiv' style='width:130px;'><%=temperature%></div>
									<%End if%>												
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			</table>

		</td>