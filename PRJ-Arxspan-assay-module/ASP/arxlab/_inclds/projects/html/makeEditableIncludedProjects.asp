<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<div class="includeProjectsHolder">
	<%If includeProjectsCriteria then
		jsIds = "["
		projectList = Split(originalIncludedProjects, "|")
		for each project in projectList
			pin = Split(project, ":")
			if UBound(pin) = 1 Then
				jsIds = jsIds & pin(0) & ","
			End If
		next
		if Len(jsIds) > 1 then
			jsIds = Left(jsIds, Len(jsIds) - 1)
		end if
		jsIds = jsIds & "];"
	%>
		<script type="text/javascript">
			var originalIncludedProjectIds = <%=jsIds%>
			function includeProjects(id){
				document.getElementById(id+"_show").style.display = 'none';
				document.getElementById(id+"_edit").style.display = 'block';
			}
			function saveIncludedProjects(id,dataId,scriptName){
				data = $('#'+id+'_editData').val();
				if(data.length === 1 && data[0] === '')
					data = [];
				
				result = postDataToFile("<%=includeProjectsEditScript%>?id=<%=editIncludedProjectsId%>&data="+encodeURIComponent(data));
				
				if(result=="success"){
					window.location.href = "show-project.asp?id=<%=editIncludedProjectsId%>"
					/*
					// Store the new fallback values
					originalIncludedProjectIds = data;
					
					// Populate the table
					var displayRow = null;
					$('#includedProjectsTable').empty();
					if(originalIncludedProjectIds.length > 0)
						displayRow = $('#includedProjectsTable').append('</tr>');
						
					if(displayRow)
					{
						$.each(originalIncludedProjectIds, function(i, val) {
							var valTxt = $("#<%=includeProjectsFieldId%>_editData option[value='"+val+"']").text();
							$(displayRow).append('<td><a href="show-project.asp?id='+val+'">'+valTxt+'</a></td>');
						});
					}
					
					// Toggle the display
					document.getElementById(id+"_edit").style.display = 'none';
					document.getElementById(id+"_show").style.display = 'block';
					*/
				}else{
					console.log("GET FILE ERROR");
					console.log(result);
				}
			}
			function cancelIncludeProjects(id){
				$('#'+id+'_editData').scrollTop(0);
				$('#'+id+'_editData').val(originalIncludedProjectIds);
				document.getElementById(id+"_edit").style.display = 'none';
				document.getElementById(id+"_show").style.display = 'block';
			}
		</script>
	<%End if%>
	<div id="<%=includeProjectsFieldId%>_show" class="editableIncludedProjects">
		<div id="<%=includeProjectsFieldId%>"><table id="includedProjectsTable">
		<%If Len(originalIncludedProjects) > 0 Then%>
			<tr>
			<%
				projectList = Split(originalIncludedProjects, "|")
				for each project in projectList
					pin = Split(project, ":")
					if UBound(pin) = 1 Then
						projId = pin(0)
						projName = pin(1)
			%>
						<td><a href="show-project.asp?id=<%=projId%>"><%=projName%></a></td>
			<%		End If
				next
			%>
			</tr>
		<%End If%>
		</table></div>
		<%If includeProjectsCriteria then%>
			<a href="javascript:void(0);return false;"  onClick="includeProjects('<%=includeProjectsFieldId%>')">
				<img border="0" src="<%=mainAppPath%>/images/btn_edit.gif">
			</a>
		<%End if%>
	</div>
	<%If includeProjectsCriteria then%>
		<div id="<%=includeProjectsFieldId%>_edit" class="editableIncludedProjects" style="display:none;">
			<select multiple id="<%=includeProjectsFieldId%>_editData" style="display:inline;">
			<option value="">--SELECT--</option>
			<%
			Set nRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT DISTINCT projectId,userId,name,visible,lastViewed,description,fullName FROM allProjectPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and ((accepted=1 and canRead=1) or (accepted is null and canRead=1) or canRead is null) and parentprojectId is null order by name"
			nRec.open strQuery,conn,3,3
			Do While Not nRec.eof
				If CStr(projectId)<>CStr(nRec("projectId")) Then
			%>
					<option value="<%=nRec("projectId")%>" <%If InStr(originalIncludedProjects, "|"&CStr(nRec("projectId"))&":") <> 0 then%>SELECTED<%End if%>><%=nRec("name")%></option>
			<%
				End If
				nRec.movenext
			Loop
			nRec.close
			Set nRec = nothing
			%>
			</select>
			<a href="javascript:void(0);return false;"  onClick="saveIncludedProjects('<%=includeProjectsFieldId%>',<%=editIncludedProjectsId%>,'<%=mainAppPath%>/<%=includeProjectsEditScript%>')">
				<img border="0" src="<%=mainAppPath%>/images/cow-save.gif">
			</a>
			<a href="javascript:void(0);return false;"  onClick="cancelIncludeProjects('<%=includeProjectsFieldId%>')">
				<img border="0" src="<%=mainAppPath%>/images/delete.png">
			</a>
		</div>
	<%End if%>
</div>
<div style="clear:both;height:0px;"></div>