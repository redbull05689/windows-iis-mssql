<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<div class="editableDescriptionHolder">
	<%If editDescriptionCriteria then%>
		<script type="text/javascript">
			function editDescription(id){
				document.getElementById(id+"_show").style.display = 'none';
				document.getElementById(id+"_edit").style.display = 'block';
			}
			function saveDescription(id,dataId,scriptName){
				data = document.getElementById(id+"_editData").value;
				result = getFile("<%=descriptionEditScript%>?id=<%=editDescriptionId%>&data="+encodeURIComponent(encodeIt(data)));
				if(result=="success"){
					document.getElementById(id).innerHTML = data;
					document.getElementById(id+"_originalText").value = data;
					document.getElementById(id+"_edit").style.display = 'none';
					document.getElementById(id+"_show").style.display = 'block';
				}else{
					alert(result);
				}
			}
			function cancelEditDescription(id){
				document.getElementById(id+"_edit").style.display = 'none';
				document.getElementById(id+"_show").style.display = 'block';
				document.getElementById(id+"_editData").value = document.getElementById(id+"_originalText").value;
			}
		</script>
	<%End if%>
	<div id="<%=descriptionFieldId%>_show" class="editableDescription">
		<p id="<%=descriptionFieldId%>"><%=originalData%></p>
		<%If editDescriptionCriteria then%>
			<a href="javascript:void(0);return false;"  onClick="editDescription('<%=descriptionFieldId%>')">
				<img border="0" src="<%=mainAppPath%>/images/btn_edit.gif">
			</a>
		<%End if%>
	</div>
	<%If editDescriptionCriteria then%>
		<div id="<%=descriptionFieldId%>_edit" class="editableDescription" style="display:none;">
			<textarea id="<%=descriptionFieldId%>_editData"><%=originalData%></textarea>
			<a href="javascript:void(0);return false;"  onClick="saveDescription('<%=descriptionFieldId%>',<%=editDescriptionId%>,'<%=mainAppPath%>/<%=descriptionEditScript%>')">
				<img border="0" src="<%=mainAppPath%>/images/cow-save.gif">
			</a>
			<a href="javascript:void(0);return false;"  onClick="cancelEditDescription('<%=descriptionFieldId%>')">
				<img border="0" src="<%=mainAppPath%>/images/delete.png">
			</a>
			<textarea id="<%=descriptionFieldId%>_originalText" style="display:none;"><%=originalData%></textarea>
		</div>
	<%End if%>
</div>
<div style="height:0px;clear:both;"></div>