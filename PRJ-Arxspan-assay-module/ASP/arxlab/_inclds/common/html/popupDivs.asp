<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	hasCombi = checkBoolSettingForCompany("hasCombi", session("companyId"))
	hasCombiPlate = checkBoolSettingForCompany("hasCombiPlate", session("companyId"))
	hasAnalExperiment = getCompanySpecificSingleAppConfigSetting("hasAnalyticalExperiments", session("companyId"))
	blockNewColab = getCompanySpecificSingleAppConfigSetting("disableFreeExps", session("companyId"))
	whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
	hasFreeExperiment = getCompanySpecificSingleAppConfigSetting("hasFreeExperiments", session("companyId"))
%>
<link href="<%=mainAppPath%>/css/jquery.dataTables.1.10.15.css" rel="stylesheet" type="text/css">
<link href="<%=mainAppPath%>/css/buttons.dataTables.min.css" rel="stylesheet" type="text/css">
<link href="<%=mainAppPath%>/css/fixedHeader.dataTables.min.css" rel="stylesheet" type="text/css">
<link href="/arxlab/js/flatpickr/flatpickr.min.css" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="/arxlab/js/flatpickr/flatpickr.js?<%=jsRev%>"></script>

<link href="<%=mainAppPath%>/css/inventoryLinkPopup.css" rel="stylesheet" type="text/css">

<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<!-- #include file="../js/popupDivsJS.asp"-->
<script type="text/javascript" src="<%=mainAppPath%>/js/select2-3.5.1/select2.js?<%=jsRev%>"></script>
<script type="text/javascript">
	hasMarvin = <%=LCase(CStr(session("useMarvin")))%>
</script>

<!-- #include file="../../experiments/common/html/savePopups.asp"-->
<!-- #include file="../../experiments/common/html/signPopups.asp"-->
<!-- #include file="../../experiments/common/html/witnessPopups.asp"-->

<%If (subSectionId="experiment" Or subSectionId="bio-experiment" Or subSectionId="free-experiment" Or subSectionId="anal-experiment" Or subSectionId="cust-experiment" Or sectionId="reg") then%>
<%'registration div %>
<div style="width:380px;height:500px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="regDiv" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopup('regDiv');return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif"></a>
<iframe src="<%=mainAppPath%>/static/blankRegForm.html" style="width:380px;height:500px;" id="regFrame" name="regFrame"></iframe>
</div>
<%'reg integration structure info div %>
<div style="width:600px;height:800px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="regDiv2" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopup('regDiv2');return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif"></a>
<iframe src="<%=mainAppPath%>/static/blankRegForm.html" style="width:600px;height:800px;" id="regFrame2" name="regFrame2"></iframe>
</div>
<%End if%>

<%If (subSectionId="experiment" Or subSectionId="bio-experiment" Or subSectionId="free-experiment" Or subSectionId="anal-experiment" Or subSectionId="cust-experiment") then%>

<%'multiple files div%>
<div style="width:460px;height:520px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;padding:10px;" id="multiFileDiv" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopup('multiFileDiv');return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif"></a>
        <form id="multiUploadForm" method="POST" target="submitFrame2">    
            <% 
                'Dim uploader    
                'Set uploader=new AspUploader
                'uploader.UploadUrl = "upload-file-multi.asp?experimentId="&request.querystring("id")&"&experimentType="&experimentType&"&random="&rnd
				'uploader.MultipleFilesUpload=True
				'uploader.ProgressTextTemplate = "%F%.. %P% %SEND%/%SIZE% , %KBPS%"
				''uploader.UploadType = "IFrame"
				'uploader.ButtonOnClickScript = "multiFileUploadStart()"
				'uploader.Render()
				''response.write(uploader.GetString())
            %>
        </form>    
</div>


<%'addElementalMachinesDataDiv div%>
<!-- #include file="../../experiments/common/functions/elementalMachinesApi.asp"-->

<div id="elementalMachinesSignDiv" class="popupDiv popupBox">
	<div class="popupFormHeader">Elemental Machine Sign In</div>
	<form name="em_sign_form" method="post" action="sign-experiment.asp" OnSubmit="return false;" class="popupForm" z-index="-1">
		<section>
			<label for="emEmail">Email</label>
			<input type="text" id="emEmail" name="emEmail" value="" style="box-sizing: content-box;">
		</section>
		<section>
			<label for="emPass"><%=passwordLabel%></label>
			<input type="password" name="emPass" id="emPass" value=""  autocomplete="off" style="box-sizing: content-box;">
		</section>

		<section class="bottomButtons checkbox">	
			<button id="EMSignDivSignButton" onclick="checkEMCreds();">Sign</button>
		</section>
	</form>
</div>

<div id="addElementalMachinesDataDiv" class="popupDiv popupBox" style="width:800px;height:120px;">
	<div class="popupFormHeader">Collect Data From Elemental Machines</div>
	<form id="elementalMachinesData_form" name="elementalMachinesData_form" method="post" action="<%=mainAppPath%>/experiments/addElementalMachinesData.asp" onsubmit="return false;" class="popupForm" style="position:relative">
		<section style="margin-top:25px;">
			<table>
				<tr>
					<td>
						<div class="select-style" style="margin-left:80px;">
							<select name="elementalMachineName" id="elementalMachineName">
							</select>
							<script type="text/javascript">
								$("#elementalMachineName").change(function(){
									populateElementalMachineTimePoints();
								});
							</script>
						</div>
					</td>
					<td>
						<div class="select-style" style="margin-left:125px;">
							<select name="elementalMachineCollectionMethod" id="elementalMachineCollectionMethod">
								<option value="-1" title="Select Collection Method">Select Collection Method</option>
								<option value="selectTimePoints" title="Time Points">Time Points</option>
								<option value="selectTimeRange" title="Time Range">Time Range</option>
							</select>
							<script type="text/javascript">
								$("#elementalMachineCollectionMethod").change(function(){
									var machines = document.getElementById("elementalMachineCollectionMethod");
									var collectionType = machines.options[machines.selectedIndex].value;
									
									if(collectionType == "-1")
									{
										$("#addElementalMachinesDataDiv").css("height","120px");
										$("#specifyTimePoints").css("display","none");
										$("#specifyTimeRange").css("display","none");
										$("#emDataSaveButton").css("display","none");
									}
									else if(collectionType == "selectTimeRange")
									{
										$("#addElementalMachinesDataDiv").css("height","575px");
										$("#specifyTimePoints").css("display","none");
										$("#specifyTimeRange").css("display","block");
										$("#emButtonSection").css("top", "476px");
										$("#emDataSaveButton").removeAttr("style");
										$("#emDataSaveButton").css("display","block");
									}
									else if(collectionType == "selectTimePoints")
									{
										$("#addElementalMachinesDataDiv").css("height","575px");
										$("#specifyTimePoints").css("display","block");
										$("#specifyTimeRange").css("display","none");
										$("#emDataSaveButton").css("display","none");
										$("#emButtonSection").css("bottom", "-20px");
										populateElementalMachineTimePoints();
									}
								});
							</script>
						</div>
					</td>
				</tr>
			</table>
		</section>
		<section style="margin-top:25px;">
			<div id="specifyTimePoints" style="display:none;">
				<table name="elementalMachineDataPoints" id="elementalMachineDataPoints" style="width:100%">
				</table>
			</div>
		</section>
		<section style="margin-top:25px;position:relative;">
			<table id="specifyTimeRange" style="display:none;">
				<tr>
					<td style="position:absolute;left:24px">
						<input id="elementalMachinesStartTime" name="elementalMachinesStartTime" class="flatpickr flatpickr-input active" type="text" placeholder="Data Collection Start Time.." data-id="datetime" readonly="readonly">
						<script type="text/javascript">
							var thisPickr = $("#elementalMachinesStartTime").flatpickr(
								{"enableTime":true,
								"altInput":true,
								"inline":true,
								"onValueUpdate": function(selectedDates, dateStr, instance) {
									if(selectedDates.length == 1)
									{
										$("#startTimeEpoch").val(selectedDates[0].getTime());
										$("#elementalMachinesEndTime").flatpickr(
											{"enableTime":true,
											"altInput":true,
											"inline":true,
											"minDate":selectedDates[0],
											"onValueUpdate": function(selectedDates, dateStr, instance) {
												if(selectedDates.length == 1)
												{
													$("#endTimeEpoch").val(selectedDates[0].getTime());
													$(".flatpickr-calendar").css("margin-left","57px");
												}
											}});
											
										$(".flatpickr-calendar").css("margin-left","57px");
									}
								}});
						</script>
					</td>
					<td style="position:absolute;right:37px">
						<input id="elementalMachinesEndTime" name="elementalMachinesEndTime" class="flatpickr flatpickr-input active" type="text" placeholder="Data Collection End Time.." data-id="datetime" readonly="readonly">
						<script type="text/javascript">
							$("#elementalMachinesEndTime").flatpickr(
								{"enableTime":true,
								"altInput":true,
								"inline":true,
								"onValueUpdate": function(selectedDates, dateStr, instance) {
									if(selectedDates.length == 1)
									{
										$("#endTimeEpoch").val(selectedDates[0].getTime());
										$(".flatpickr-calendar").css("margin-left","57px");
									}
								}});
							
							$(".flatpickr-calendar").css("margin-left","57px");
						</script>
					</td>
				</tr>
			</table>
		</section>
		<section class="bottomButtons buttonAlignedRight" style="position:absolute;right:0" id="emButtonSection">
			<button id="emDataSaveButton" onclick="checkElementalMachinesAndSubmit();" style="display:none;">Submit</button>
		</section>
		<input type="hidden" id="emFormExperimentId" name="experimentId" value="<%=experimentId%>">
		<input type="hidden" id="emFormExperimentType" name="experimentType" value="<%=experimentType%>">
		<input type="hidden" id="startTimeEpoch" name="startTimeEpoch" value="">
		<input type="hidden" id="endTimeEpoch" name="endTimeEpoch" value="">
	</form>
</div>

<%'add file div%>
<% popupFrmHdrTxt = "Upload File or Folder" %>

<div id="addFileDiv" class="popupDiv popupBox">
<div class="popupFormHeader"><%=popupFrmHdrTxt%></div>
<%If bCheck="IE 8.0" Then%>
<a href="javascript:void(0);" onclick="hidePopup('addFileDiv');showPopup('multiFileDiv');return false;" style="position:absolute;right:6px;top:6px;font-size:12px;font-weight:bold;display:none;">Upload Multiple</a>
<%End if%>
<form name="file_form" method="post" action="<%=mainAppPath%>/experiments/upload-file.asp?<% = PID %>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&random=<%=rnd%>" ENCTYPE="multipart/form-data" OnSubmit="unsavedChanges=true;sendAutoSave('experimentId',experimentJSON['experimentId']);return preUpload(0);"  target="submitFrame2" class="popupForm">
	<section>
		<label for="fileName">File Name</label>
		<input type="text" id="fileName" name="fileName">
	</section>
	<section class="popupFileUploadSection">
		<label for="file1">File</label>
		<div id="fileInputContainer" class="popupFileInputContainer"><input type="file" name="file1" id="file1"></div>
	</section>
	<section class="Splitter">
		<label for="Split1">OR</label>
	</section>
	<section class="popupFolderUploadSection">
		<label for="Folder1">Folder</label>
		<div id="FolderInputContainer" class="popupFileInputContainer"><input type="file" name="Folder1" id="Folder1" webkitdirectory mozdirectory msdirectory odirectory directory multiple></div>
	</section>
	<section class="popupCKeditorSection buttonAlignedLeft">
		<label for="fileDescription">Description</label>
		<textarea name="fileDescription" id="fileDescription" rows="4" cols="25" ></textarea>
		<script type="text/javascript">
			CKEDITOR.replace('fileDescription',{toolbar : 'arxspanToolbar'});
			CKEDITOR.instances.fileDescription.on('change',function(e){unsavedChanges=true;})
		</script>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<button type="submit">Upload</button>
	</section>
	<input type="hidden" id="fileExperimentId" name="fileExperimentId" value="">
</form>
</div>

<div id="addResumableFileDiv" class="popupDiv popupBox">
<div class="popupFormHeader"><%=popupFrmHdrTxt%></div>
<%If bCheck="IE 8.0" Then%>
<a href="javascript:void(0);" onclick="hidePopup('addFileDiv');showPopup('multiFileDiv');return false;" style="position:absolute;right:6px;top:6px;font-size:12px;font-weight:bold;display:none;">Upload Multiple</a>
<%End if%>
	<div id="resumableBrowserHolder" class="popupForm">
		<div id="resumableFileToUse" value="None" hidden></div>
		<section>
			<label for="resumableFileName">File Name</label>
			<input type="text" id="resumableFileName" name="resumableFileName">
		</section>
		<section class="popupFileUploadSection">
			<label for="resumableFile1">File</label>
			<div id="fileInputContainer" class="popupFileInputContainer">
				<div class="resumableFileHolder resumableFile">
					<button id="resumableFile1" name="resumableFile1" class="resumable-browse">Choose File</button>
					<div id="resumableActualFileName">No file chosen</div>
				</div>
			</div>
		</section>
		<section class="Splitter">
			<label for="Split1">OR</label>
		</section>
		<section class="popupFolderUploadSection">
			<label for="resumableFolder1">Folder</label>
			<div id="folderInputContainer" class="popupFileInputContainer">
				<div class="resumableFileHolder resumableFolder">
					<button id="resumableFolder1" name="resumableFolder1" class="resumable-browse">Choose Folder</button>
					<div id="resumableFolderName">No folder chosen</div>
				</div>
			</div>
		</section>
		<section class="popupCKeditorSection buttonAlignedLeft">
			<label for="resumableFileDescription">Description</label>
			<textarea name="resumableFileDescription" id="resumableFileDescription" rows="4" cols="25" ></textarea>
			<script type="text/javascript">
				CKEDITOR.replace('resumableFileDescription',{toolbar : 'arxspanToolbar'});
				CKEDITOR.instances.resumableFileDescription.on('change',function(e){unsavedChanges=true;})
			</script>
		</section>
		<section class="bottomButtons buttonAlignedRight">
			<button type="submit" class="resumableUploadButton">Upload</button>
		</section>
		<input type="hidden" id="fileExperimentId" name="fileExperimentId" value="">
	</div>
</div>

<%'do not allow folder selection when in IE11 - since it does not support it%>
<script type="text/javascript">
	var isIE = (window.navigator.userAgent.indexOf("MSIE ") > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./));
    if (isIE) {
        $(".popupFormHeader").each(function (index, value) {
            if ($(this).text() === "<%=popupFrmHdrTxt%>") {
                $(this).text("Upload File");
                $(".Splitter").hide();
                $(".popupFolderUploadSection").hide();
            }
        });
	}
</script>

<%'add file div%>
<div id="addFileDivBase64" class="popupDiv popupBox">
<form name="file_form" method="post" action="<%=mainAppPath%>/experiments/upload-file.asp?<% = PID %>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&base64=true&random=<%=rnd%>" OnSubmit="unsavedChanges=true;sendAutoSave('experimentId',experimentJSON['experimentId']);return preUploadBase64();"  target="submitFrame2" id="base64AttachmentForm" class="popupForm">
	<section>
		<label for="fileName">File Name</label>
		<input type="text" id="fileNameBase64" name="fileName" >
	</section>
	<section>
		<label for="base64File">File</label>
		<span class="clipboardData">Clipboard Data</span>
		<div id="clipboardFileHolder">
			<input type="hidden" name="base64File" id="base64File">
			<input type="hidden" name="base64FileExtension" id="base64FileExtension">
			<input type="hidden" name="base64FileCKEditorId" id="base64FileCKEditorId">
		</div>
	</section>
	<section class="popupCKeditorSection">
		<label for="fileDescription">Description</label>
		<textarea name="fileDescription" id="fileDescriptionBase64"></textarea>
		
		<script type="text/javascript">
			CKEDITOR.replace('fileDescriptionBase64',{toolbar : 'arxspanToolbar'});
			CKEDITOR.instances.fileDescription.on('change',function(e){unsavedChanges=true;})
		</script>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<button type="submit">Upload</button>
	</section>
</form>
</div>

<%'upload reaction div%>
<div id="uploadRXNDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Upload Reaction</div>
	<% if session("useMarvin") THEN %>
		<form action="<%=mainAppPath%>/experiments/echoMarvin.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&serial=<%=hungSaveSerial%>" method="post" target="upload_frame" enctype="multipart/form-data" id="uploadRXNForm" class="popupForm">
			<section class="popupFileUploadSection">
				<label for="file">Upload Reaction File:</label>	
				<div class="popupFileInputContainer">
					<input type="file" name="file" id="rxnFile" />
				</div>
			</section>
			<section class="bottomButtons buttonAlignedRight">
				<button Upload onclick="if(document.getElementById('rxnFile').value != ''){hidePopup('uploadRXNDiv');showPopup('uploadingDiv');unsavedChanges=false}" style="width:100px;margin-left:130px;">Upload</button>
			</section>
		</form>

	<% ELSE %>
		<form action="<%=mainAppPath%>/experiments/echo.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&serial=<%=hungSaveSerial%>" method="post" target="upload_frame" enctype="multipart/form-data" id="uploadRXNForm" class="popupForm">
			<section class="popupFileUploadSection">
				<label for="file">Upload Reaction File:</label>	
				<div class="popupFileInputContainer">
					<input type="file" name="file" id="rxnFile" />
				</div>
			</section>
			<section class="bottomButtons buttonAlignedRight">
				<button Upload onclick="if(document.getElementById('rxnFile').value != ''){hidePopup('uploadRXNDiv');showPopup('uploadingDiv');unsavedChanges=false;rxnSubmit()}" style="width:100px;margin-left:130px;">Upload</button>
			</section>
		</form>
	<% END IF %>
		
</div>

<%If hasCombi then%>
	<%'combi div%>
	<div id="uploadCombiDiv" class="popupDiv popupBox">
	<div class="popupFormHeader">Upload Combi</div>
	<form action="<%=mainAppPath%>/experiments/combi/uploadCombi.asp?experimentId=<%=experimentId%>" method="post" target="upload_frame" enctype="multipart/form-data" id="uploadCombiForm" class="popupForm">
		<section>
			<label for="file">SD File</label>	
			<div id="fileInputContainer" class="popupFileInputContainer"><input type="file" name="file" id="sdFile" /></div>
		</section>
		<section class="bottomButtons buttonAlignedRight">	
			<button onclick="if(document.getElementById('sdFile').value != ''){hidePopup('uploadCombiDiv');showPopup('uploadingDiv');unsavedChanges=false;combiSubmit()}" style="width:100px;margin-left:130px;">Upload</button>
		</section>
	</form>
	</div>
	<%If hasCombiPlate then%>
		<script type="text/javascript">
			function submitResultsSD(){
				var formData = new FormData();
				formData.append('file', $('#sdResultsFile')[0].files[0]);

				$.ajax({
					   url : '<%=mainAppPath%>/experiments/combi/echoText.asp',
					   type : 'POST',
					   data : formData,
					   processData: false,  // tell jQuery not to process the data
					   contentType: false,  // tell jQuery not to set contentType
					   success : function(data) {
							if( $("#resultSD").val() == "") {
								updatedData = data;
							}
							else {
								exSdfReader = new SDFReader($("#resultSD").val());
								exData = exSdfReader.getMolecules();
								
								newSdfReader = new SDFReader(data);
								newData = newSdfReader.getMolecules();
																
								//loop through the objects and update
								$.each(newData, function(index, value) {
									var id;
									idFound = false;
									if(value["attrList"].indexOf("id") > -1) {
										id = value["attrVals"]["id"][0];
										$.each(exData, function(i, val){
											if(val["attrList"].indexOf("id") > -1) {
												exId = val["attrVals"]["id"][0];
												if (exId == id){	
													$.each(val["attrList"], function (key, data) {
														keyVal = val["attrList"][key];
														if(val["attrVals"][keyVal] == "" && value["attrVals"][keyVal] != ""){
															console.log(keyVal +" - "+ value["attrVals"][keyVal]);
															val["attrVals"][keyVal] = value["attrVals"][keyVal];
														}
													});
													idFound = true
												}
											}
										});
										if(!idFound){
											console.log("not Found :: ", value);
											exData.push(value);
										}
									}
									console.log('got wellId: ' + id);
								});
								
								//Convert back into sdfile
								sdfWriter = new SDFWriter(exData);
								updatedData = sdfWriter.getSDFile();
							}
							
							$("#resultSD").val(updatedData)
							experimentJSON["resultSD"]=updatedData;
							sendAutoSave("resultSD",updatedData);
							unsavedChanges = true;
							hidePopup('uploadingDiv');
							$("#downloadResultsSDLink").show();
							$("#uploadResultsSDLink").css({width:"130px"})
							$("#uploadResultsSDLink").text("Re-upload Results SD")
							buildPlate('#thePlateHolder',8, 12, '30px',updatedData);
					   }
				});
			}
		</script>
		<div id="uploadCombiResultsDiv" class="popupDiv popupBox">
		<div class="popupFormHeader">Upload Results</div>
		<form action="<%=mainAppPath%>/experiments/combi/echoText.asp" method="post" target="upload_frame" enctype="multipart/form-data" id="uploadCombiResultsForm" class="popupForm">
			<section>
				<label for="file">SD File</label>	
				<div id="fileInputContainer" class="popupFileInputContainer"><input type="file" name="file" id="sdResultsFile" /></div>
			</section>
			<section class="bottomButtons buttonAlignedRight">	
				<button onclick="if(document.getElementById('sdResultsFile').value != ''){hidePopup('uploadCombiResultsDiv');showPopup('uploadingDiv');submitResultsSD()}" style="width:100px;margin-left:130px;">Upload</button>
			</section>
		</form>
		</div>
	<%End if%>
<%End if%>

<%'add note div%>
<div style="width:420px;height:460px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="noteDiv" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopup('noteDiv');return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif"></a>
<form name="note_form" method="post" action="<%=mainAppPath%>/experiments/ajax/do/note.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>" OnSubmit="unsavedChanges=false;waitForNote();" class="chunkyForm" style="margin-top:20px;margin-left:30px;" target="submitFrame2">
	<label for="noteText">Name</label>
	<input type="text" name="noteName" id="noteName" style="margin-left:10px;width:340px;">
	<label for="noteText">Note</label>
	<textarea name="noteText" id="noteText" rows="8" cols="25" style="margin-left:10px;width:420px;"></textarea>

	<script type="text/javascript">
		CKEDITOR.replace('noteText',{toolbar : 'arxspanToolbar'});
		CKEDITOR.instances.noteText.on('change',function(e){unsavedChanges=true;})
	</script>
	<input type="submit" value="Add" style="width:100px;margin-left:250px;margin-top:10px;">
</form>
</div>




<%'copy experiment div%>
<div id="copyDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Copy Experiment</div>
<form name="copy_form" method="post" action="<%=mainAppPath%>/static/error.asp" onSubmit="return false;" class="popupForm">
	<section>
		<label for="newNotebookId" class="select-style-label"><%=selectNotebookLabel%></label>
		<div class="select-style">
			<select name="newNotebookId" id="newNotebookId">
			</select>
		</div>
	</section>
	<section>
		<label for="numCopies" class="select-style-label">Number of Copies</label>
		<div class="select-style">
			<select id="numCopies" name="numCopies">
				<option value="1">1</option>
				<option value="2">2</option>
				<option value="3">3</option>
				<option value="4">4</option>
				<option value="5">5</option>
				<option value="6">6</option>
				<option value="7">7</option>
				<option value="8">8</option>
				<option value="9">9</option>
				<option value="10">10</option>
			</select>
		</div>
	</section>
	<section>
		<label for="copyAttachments" class="select-style-label">Copy Attachments</label>
		<div class="select-style">
			<select id="copyAttachments" name="copyAttachments">
					<option value="yes" selected>Yes</option>
					<option value="no">No</option>
			</select>
		</div>
	</section>
	<section>
		<label for="copyNotes" class="select-style-label">Copy Notes</label>
		<div class="select-style">
			<select id="copyNotes" name="copyNotes">
				<option value="yes" selected>Yes</option>
				<option value="no">No</option>
			</select>
		</div>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<%craisError = false
		If session("hasCrais") And experimentType="1" then
			If craisStatusId=3 Or craisStatusId=0 Then
				craisError = True
			End if
		End if%>
		<button onClick="this.disabled=true;try{unsavedChanges=false;}catch(err){};ca=document.getElementById('copyAttachments');ca = ca.options[ca.selectedIndex].value;cn=document.getElementById('copyNotes');cn = cn.options[cn.selectedIndex].value;nc=document.getElementById('numCopies');nc = nc.options[nc.selectedIndex].value;nbId = document.getElementById('newNotebookId').options[document.getElementById('newNotebookId').selectedIndex].value;if(nbId !='-1'){window.location='<%=mainAppPath%>/experiments/copyExperiment.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&revisionNumber=<%=revisionId%>&numCopies='+nc+'&copyAttachments='+ca+'&newNotebookId='+nbId+'&copyNotes='+cn;}else{alert('Please enter a notebook.')}">Copy</button>
	</section>
</form>
</div>



<%'move experiment div%>
<div id="moveDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Move Experiment</div>
<form name="copy_form" method="post" action="<%=mainAppPath%>/static/error.asp" onSubmit="return false;" class="popupForm">
	<section>
		<label for="newNotebookIdMove" class="select-style-label"><%=selectNotebookLabel%></label>
		<div class="select-style">
			<select name="newNotebookIdMove" id="newNotebookIdMove">
			</select>
		</div>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<button style="width:100px;margin-left:130px;margin-top:10px;" onClick="this.disabled=true;try{unsavedChanges=false;}catch(err){};nbId = document.getElementById('newNotebookIdMove').options[document.getElementById('newNotebookIdMove').selectedIndex].value;if(nbId !='-1'){window.location='<%=mainAppPath%>/experiments/moveExperiment.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&newNotebookId='+nbId;}else{alert('Please enter a notebook.')}">Move</button>
	</section>
</form>
</div>

<%'divs for replacing files%>
<div id="replacingFiles"></div>



<%
If experimentType <> "" then

attachmentsPreSaveTable = getPrefix(experimentType)
attachmentsPreSaveTable = getFullName(attachmentsPreSaveTable, "attachments_preSave", true)
strQuery = "SELECT id, name FROM " & attachmentsPreSaveTable & " WHERE experimentId="&SQLClean(experimentId,"N","S")

Set attachmentRec = server.CreateObject("ADODB.RecordSet")
attachmentRec.open strQuery,conn,0,-1
Do While Not attachmentRec.eof
%>
	<div id="addFileDiv_p<%=attachmentRec("id")%>" class="popupDiv popupBox">
	<div class="popupFormHeader">Replace File</div>
	<form name="file_form_p<%=attachmentRec("id")%>" method="post" action="<%=mainAppPath%>/experiments/upload-file.asp?<% = PID %>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&attachmentId=<%=attachmentRec("id")%>&pre=true&random=<%=rnd%>" ENCTYPE="multipart/form-data" OnSubmit="unsavedChanges=true;sendAutoSave('experimentId',experimentJSON['experimentId']);return preUpload('p<%=attachmentRec("id")%>');" class="popupForm" target="submitFrame2">
		<section class="popupFileUploadSection">
			<label for="file1">Replace Data For File: <%=attachmentRec("name")%></label>
			<div id="fileInputContainer" class="popupFileInputContainer">
				<input type="file" name="file1_p<%=attachmentRec("id")%>" id="file1_p<%=attachmentRec("id")%>">
			</div>
		</section>
		<section class="bottomButtons buttonAlignedRight">
			<button type="submit">Upload</button>
		</section>
	</form>
	</div>
<%
	attachmentRec.movenext
Loop
End if
%>



<script type="text/javascript">
//Update the popup divs for replace attachments
replacePopupDivStr = getFile('<%=mainAppPath%>/ajax_doers/popupDivsToReplaceAttachments.asp?<%=PID%>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand='+Math.random());
document.getElementById("replacingFiles").innerHTML = replacePopupDivStr;
</script>

<div id="showCasResultsDiv" class="popupDiv popupBox" style="position:absolute;top:0;left:0;z-index:101;">
<div class="popupFormHeader">Search Results</div>
<a href="javascript:void(0)" onClick="hidePopup('showCasResultsDiv',true);showPopup('addMolDiv');$('#lean_overlay').hide();$('#overlay_select2Compatible').addClass('makeVisible');return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif" style="border:none;"></a>
<div id="chemAxonResultDiv" style="overflow:auto;height:750px;"></div>
</div>

<div id="addMolDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Add Molecule</div>
<form name="addMolForm" method="post" onSubmit="return false;" class="popupForm">
	<section>
		<label for="molType" class="select-style-label">Type:</label>
		<div class="select-style">
		
			<select name="molType" id="molType" onchange="setUserOption('defaultMolType',this.options[this.selectedIndex].value);molTypeChange()" autocomplete="off">
				<option value="0">--SELECT--</option>
				<option value="1" <%If  userOptions.Get("defaultMolType")="1" then%> selected<%End if%>>Reactant</option>
				<option value="2" <%If  userOptions.Get("defaultMolType")="2" then%> selected<%End if%>>Reagent</option>
				<!-- <option value="3" <%If  userOptions.Get("defaultMolType")="3" then%> selected<%End if%>>Product</option> -->
				<option value="4" <%If  userOptions.Get("defaultMolType")="4" then%> selected<%End if%>>Solvent</option>
			</select>
		</div>
	</section>
	<section>
		<label for="molAddType" class="select-style-label">Add by:</label>
		<div class="select-style">
			<select name="molAddType" id="molAddType" onchange="setUserOption('defaultMolAddType',this.options[this.selectedIndex].value);molTypeChange()" autocomplete="off">
				<option value="0">--SELECT--</option>
				<option value="1" <%If  userOptions.Get("defaultMolAddType")="1" then%> selected<%End if%>>Manual</option>
				<option value="2" <%If  userOptions.Get("defaultMolAddType")="2" then%> selected<%End if%>>CAS Database</option>
				<option value="3" <%If  userOptions.Get("defaultMolAddType")="3" then%> selected<%End if%> id="reagentDatabaseOption" disabled>Reagent Database</option>
			</select>
		</div>
	</section>
	<section id="extraMolData" <%If (CInt( userOptions.Get("defaultMolType")) > 0) And (CInt( userOptions.Get("defaultMolAddType")) = 1) Then%> style="display:block;" <%Else%> style="display:none;" <%End If%>>
		<label for="addMolName">Chemical Name:</label>
		<input type="text" id="addMolName" name="addMolName">
	</section>

	<section id="extraMolData2-1" <%If ( userOptions.Get("defaultMolType") = "1" or  userOptions.Get("defaultMolType") = "2" or  userOptions.Get("defaultMolType") = "3") And (CInt( userOptions.Get("defaultMolAddType")) = 1) Then%> style="display:block;" <%Else%> style="display:none;" <%End If%>>
		<label for="addMolMW">Molecular Weight:</label>
		<input type="text" id="addMolMW" name="addMolMW">
	</section>
	<section id="extraMolData2-2" <%If ( userOptions.Get("defaultMolType") = "1" or  userOptions.Get("defaultMolType") = "2" or  userOptions.Get("defaultMolType") = "3") And (CInt( userOptions.Get("defaultMolAddType")) = 1) Then%> style="display:block;" <%Else%> style="display:none;" <%End If%>>
		<label for="addMolFormula">Formula:</label>
		<input type="text" id="addMolFormula" name="addMolFormula">
	</section>


	<section id="reagentDatabaseDiv" <%If ( userOptions.Get("defaultMolType") = "1" or  userOptions.Get("defaultMolType") = "2" or  userOptions.Get("defaultMolType") = "3") And (CInt( userOptions.Get("defaultMolAddType")) = 3) Then%> style="display:block;" <%Else%> style="display:none;" <%End If%>>
		<label for="reagentDatabaseDiv" id="reagentDatabaseSelectLabel" class="select-style-label">Reagent:</label>
	</section>

	<section id="casDiv" <%If (CInt( userOptions.Get("defaultMolType")) > 0) And (CInt( userOptions.Get("defaultMolAddType")) = 2) Then%> style="display:block;" <%Else%> style="display:none;" <%End If%>>
		<label for="addMolCAS">CAS Number:</label>
		<input type="text" id="addMolCAS" name="addMolCAS">
	</section>
	<section id="casDiv-1" <%If (CInt( userOptions.Get("defaultMolType")) > 0) And (CInt( userOptions.Get("defaultMolAddType")) = 2) Then%> style="display:block;" <%Else%> style="display:none;" <%End If%>>
		<div>
			<label for="addCasName">Name:</label>
			<input type="text" name="addCasName" id="addCasName" placeholder="Type here to search by name" secretvalue="" value="" style="">
		</div>

		<script type="text/javascript">
			casNameSearchBox = $("#addCasName").select2({
				formatSearching: null,
				createSearchChoice: function (term, data) {
				},
				multiple: true,
				selectOnBlur: false,
				minimumInputLength: 3,
				formatResult: function(result, container, query){
					var casNumber = "N/A";
					if(result.hasOwnProperty("cas") && result["cas"].length > 0)
						casNumber = result["cas"];
						
					var reagentName = "";
					if(result.hasOwnProperty("traditional_name"))
						reagentName = result["traditional_name"];
						
					var contentHTML = "";
					if(casNumber.length == 0 && reagentName.length == 0)
						return contentHTML;
						
					contentHTML += '<div class="resultContent">';
					contentHTML += '<div class="resultNameRow"><div class="resultExperimentName">' + reagentName + '</div><div class="resultNotebookName"><div class="notebookNameLabel">CAS</div><div class="notebookNameValue">' + casNumber + '</div></div></div>';
					contentHTML += '</div>'
					return contentHTML
				},
				ajax: {
					url: "/arxlab/ajax_loaders/casNameSearchTypeahead.asp",
					dataType: "html",
					delay: 250,
					method: "POST",
					type: "POST",
					contentType: "application/x-www-form-urlencoded",
					data: function (params) {
						return {
							casName: params
						};
					},
					results: function (data, params) {
						//console.log("typeahead returns: ", data);
						
						// !!! select2 requires the objects in the returned array
						// to have *at least* an "id" and a "text" key
						var i = 0;
						resultsArray = JSON.parse(data)
						while(i < resultsArray.length)
						{
							resultsArray[i]["id"] = resultsArray[i]["cd_id"]
							resultsArray[i]["text"] = resultsArray[i]["traditional_name"]
							i++
						}
						return {results: resultsArray};
					},
					cache: false
				},
				dropdownCssClass : "elnSearchTypeaheadDropdown experimentSearchTypeaheadDropdown",
				formatInputTooShort: function () {
					return "Please enter at least 3 characters";
				},
				openOnEnter: false,
				placeholder: "",
				width: "element",
			}).data("select2");
			
			// This is a hacky way to make the links in the results of the typeahead clickable. Select2 stops the click event when you click a link in the dropdown by default...
			casNameSearchBox.onSelect = (function(fn) {
				return function(data, options) {
					if(data.hasOwnProperty("id") && data["id"].length > 0)
					{
						$("#addCasName").val("");
						$("#addCasCdId").val(data["id"]);
						$("#addCasName").select2("close");
						$("#addMolbtn").click();
					}
					else
					{
						setTimeout(function(){
							$("#addCasName").select2("data", {id: data["text"], text: data["text"]}).trigger("change");
						},100)
					}
				}
			})(casNameSearchBox.onSelect);

			$("#addCasName").on("select2-open", function() {
				$("#addCasName").val($("#addCasName").attr("secretvalue"));
				$("#addCasName").val("");
			})

			$("#addCasName").on("select2-close", function(something) {
				$("#addCasName").val($("#addCasName").attr("secretvalue"));
			});

			$("#addCasName").on("keyup", function(e) {
				$("#addCasName").attr("secretvalue", $(this).val());
			});
		</script>
	</section>
	<input type="hidden" id="addCasCdId" name="addCasCdId">
					
	<section class="bottomButtons checkbox">	
		<input type="checkbox" name="addStructureToReaction" id="addStructureToReaction" class="css-checkbox" style="visibility:hidden;">
		<label id="addStructureToReactionLabel" for="addStructureToReaction" class="css-label checkboxLabel" style="visibility:hidden;">Add Structure To Reaction</label>
		<% if session("useMarvin") THEN %>
			<button id="addMolbtn" onclick="this.disabled=true;this.style.color='grey';addMolMarvin(this.id)"><%=addLabel%></button>
		<% ELSE %>
			<button id="addMolbtn" onclick="this.disabled=true;this.style.color='grey';addMol(this.id)"><%=addLabel%></button>
		<% END IF %>
	</section>
</form>
</div>

<div id="addMolDivInv" class="popupDiv popupBox">
<div class="popupFormHeader">Add Molecule</div>
<form name="addMolFormInv" method="post" onSubmit="return false;" class="popupForm">
	<section>
		<label for="molTypeInv" class="select-style-label">Type:</label>
		<div class="select-style">
			<select name="molTypeInv" id="molTypeInv" autocomplete="off">
				<option value="">--SELECT--</option>
				<option value="left">Reactant</option>
				<%'//change for reagent swap%>
				<option value="top">Reagent</option>
				<option value="bottom">Solvent</option>
			</select>
		</div>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<button onclick="addMolInv()"><%=addLabel%></button>
	</section>
</form>
</div>



<%End if%>

<%'new Experiment Next Step%>
<div id="newExperimentNextStepDiv" class="popupDiv popupBox">
<div class="popupFormHeader"><%=addNextStepLabel%></div>
<form name="copy_form" method="post" action="<%=mainAppPath%>/experiments/createExperiment.asp" onSubmit="return false;" class="popupForm">
	<section>
		<label for="nextStepExperimentNotebookId" class="select-style-label"><%=selectNotebookLabel%></label>
		<div class="select-style">
			<select id="nextStepExperimentNotebookId" name="nextStepExperimentNotebookId">
			</select>
		</div>
	</section>
	<section class="popupTextareaSection">
		<label for="newExperimentDescription">Description</label>
		<textarea name="newExperimentDescription"></textarea>
	</section>
	<section>
		<label for="nextStepExperimentType" class="select-style-label"><%=experimentTypeLabel%></label>
		<div class="select-style">
			<select id="nextStepExperimentType" name="newExperimentType" class="selectStyles">
				<option value="">--- SELECT ---</option>
			</select>
		</div>
	</section>
	<section>
		<label for="linkProjectId" class="select-style-label"><%=projectLabel%></label>
		<div style="width: 60%; display: inline-block;">
			<input name="linkProjectId" id="linkProjectIdNextStep">
				<%=projectDD%>
			</input>
		</div>
	</section>
	<input type="hidden" id="nextStepRequestTypeId" name="nextStepRequestTypeId" value="">
	<input type="hidden" name="originalExperimentId" value="<%=experimentId%>">
	<input type="hidden" name="originalExperimentType" value="<%=experimentType%>">
	<input type="hidden" name="originalRevisionNumber" value="<%=maxRevisionNumber%>">
	<input type="hidden" name="isNextStep" value="1">
	<input type="hidden" id="makeNextStepRxn" name="rxn">
	<section class="bottomButtons buttonAlignedRight">
	<label style="display:none; color:red;">Experiment Type Required</label>
		<%craisError = false
		If session("hasCrais") And experimentType="1" then
			If craisStatusId=3 Then
				craisError = True
			End if
		End if%>
		<%If Not craisError then%>
		<button type="Submit" onclick="this.disabled=true;this.style.color='gray';splitCustomExperimentTypeAndRequestTypeId();this.form.submit();"><%=addNextStepLabel%></button>
		<%else%>
		<button type="Submit" onclick="alert('Experiment may not be continued without regulatory check.')"><%=addNextStepLabel%></button>
		<%End if%>
	</section>
</form>
</div>


<%'link experiment to project%>
<div id="projectLinkDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Add Project</div>
<form name="copy_form" method="post" action="<%=mainAppPath%>/static/error.asp" onSubmit="return false;" class="popupForm">
	<section>
		<label for="linkProjectId" class="select-style-label"><%=projectLabel%></label>
		<div class="select-style">
			<select id="linkProjectId2" name="linkProjectId2">
				<%=projectDD%>
			</select>
		</div>
	</section>
	<section class="bottomButtons buttonAlignedRight">
		<button onClick="newProjectLink()"><%=addLabel%></button>
	</section>
</form>
</div>


<% 'ELN-933 Improved linking of experiments %>
<div id="linkingPopup" class="popupDiv popupBox" linktotype="experiment" linkas="referenceLink">
	<div class="popupFormHeader">Link Experiment</div>
	<div class="linkingPopupContent popupForm">
		<section class="linkToSection"><label for="linkToType" class="select-style-label">Link to</label><div class="select-style"><select name="linkToType" id="linkToType" class="linkToType"><option value="experiment">Experiment</option><option value="project">Project</option><%If session("hasReg") And session("regRoleNumber") <> 1000 then%><option value="registration">Registration ID</option><%End If%></select></div></section>
		<section class="searchForExperimentSection"><label for="searchForExperiment">Search for experiment</label><input type="text" class="searchForExperiment" id="searchForExperiment" name="searchForExperiment"></section>
		<section class="searchRegistrationSection"><label for="searchRegistration">Search Registration</label><input type="text" class="searchRegistration" id="searchRegistration" name="searchRegistration"></section>
		<section class="searchForProjectSection"><label class="select-style-label" for="searchForProject">Search for project</label><div class="select-style"><input class="searchForProject" id="searchForProject" name="searchForProject"><%=projectDD%></input></div></section>
		<section class="linkAsSection"><label for="linkAs" class="select-style-label">Link as</label><div class="select-style"><select name="linkAs" id="linkAs"><option value="referenceLink">Reference Link</option><option value="previousStep">Previous Step</option><option value="nextStep">Next Step</option></select></div></section>
		<section class="linkCommentSection popupTextareaSection"><label for="linkComment">Comment</label><textarea class="linkComment" id="linkComment" name="linkComment" placeholder="Add a comment for this link"></textarea></section>
		<section class="biDirectionalSection bottomButtons checkbox buttonAlignedRight"><input type="checkbox" name="biDirectionalCheckbox" id="biDirectionalCheckbox" class="css-checkbox" checked><label for="biDirectionalCheckbox" class="css-label checkboxLabel">Bi-directional Link</label><input type="checkbox" name="regIdColCheckbox" id="regIdColCheckbox" class="css-checkbox"><label for="regIdColCheckbox" class="css-label checkboxLabel">Bulk Registration ID Link</label><button class="confirmLinkButton">Confirm Link</button></section>
	</div>
</div>

<%'Bulk reg id link progress bar%>
<div id="bulkRegProgressBar" class="popupDiv popupBox progressBarDiv">
	<div class="popupFormHeader">Bulk Registration Progress</div>
	<div id="bulkRegProgress">
		<div id="bulkRegBar">0%</div>
	</div>
</div>

<%'add tab div(projects)%>
<div id="addTabDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Add Tab</div>
<form name="add_tab_form" method="post" action="<%=mainAppPath%>/projects/add-tab.asp" OnSubmit="try{unsavedChanges = false;}catch(err){}document.getElementById('tabName').value = encodeIt(document.getElementById('tabName').value);" class="popupForm">
	<section>
		<label for="noteText">Tab Name</label>
		<input type="text" name="tabName" id="tabName" style="margin-left:10px;">
	</section>
	<input type="hidden" id="projectId" name="projectId" value="">
	<section class="bottomButtons buttonAlignedRight">
		<button type="submit"><%=addLabel%></button>
	</section>
</form>
</div>

<%'div shown when there when processing white box in middle of screen%>
<div style="width:300px;height:100px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="processingDiv" class="popupDiv">
<table height="100%" width="100%">
	<tr>
		<td valign="middle" align="center">
			<h1 style="display:inline;">Processing...</h1>
		</td>
	</tr>
</table>
</div>

<%
'div shown when there when uploading white box in middle of screen
%>
<div style="width:300px;height:100px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0;z-index:101;" id="uploadingDiv" class="popupDiv">
<table height="100%" width="100%">
	<tr>
		<td valign="middle" align="center">
			<h1 style="display:inline;">Uploading...</h1>
		</td>
	</tr>
</table>
</div>

<%'sketch div%>
<script type="text/javascript">
	sketchColor = '#000000';
</script>
<div id="sketchDiv" class="popupDiv popupBox">
<div class="popupFormHeader">Sketch/Annotate</div>
	<div id="sketchHolder" style="border:1px solid blue;position:relative;cursor:crosshair;">
		<img src="<%=mainAppPath%>/images/colorsDown.gif" border="0" style="position:absolute;top:25;left:0;cursor:pointer;" onclick="el=document.getElementById('colors');if(el.style.display=='none'){el.style.display='block';this.src='<%=mainAppPath%>/images/colorsUp.gif';}else{el.style.display='none';this.src='<%=mainAppPath%>/images/colorsDown.gif';}">
		<div style="position:absolute;top:25px;left:0;height:16px;width:16px;display:none;" id="colors">
		<table cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<a style="background-color:#000000;height:32px;width:32px;display:block;" onclick="sketchColor='#000000';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#800000;height:32px;width:32px;display:block;" onclick="sketchColor='#800000';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#ff0000;height:32px;width:32px;display:block;" onclick="sketchColor='#ff0000';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#ff00ff;height:32px;width:32px;display:block;" onclick="sketchColor='#ff00ff';return false;" title="select color">&nbsp;</a>
			</td>
		</tr>
		<tr>
			<td>
				<a style="background-color:#00ffff;height:32px;width:32px;display:block;" onclick="sketchColor='#00ffff';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#008000;height:32px;width:32px;display:block;" onclick="sketchColor='#008000';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#00ff00;height:32px;width:32px;display:block;" onclick="sketchColor='#00ff00';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#00ffff;height:32px;width:32px;display:block;" onclick="sketchColor='#00ffff';return false;" title="select color">&nbsp;</a>
			</td>
		</tr>
		<tr>
			<td>
				<a style="background-color:#000080;height:32px;width:32px;display:block;" onclick="sketchColor='#000080';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#800080;height:32px;width:32px;display:block;" onclick="sketchColor='#800080';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#0000ff;height:32px;width:32px;display:block;" onclick="sketchColor='#0000ff';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#aaaaaa;height:32px;width:32px;display:block;" onclick="sketchColor='#aaaaaa';return false;" title="select color">&nbsp;</a>
			</td>
		</tr>
		<tr>
			<td>
				<a style="background-color:#888888;height:32px;width:32px;display:block;" onclick="sketchColor='#888888';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#808000;height:32px;width:32px;display:block;" onclick="sketchColor='#808000';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#ffff00;height:32px;width:32px;display:block;" onclick="sketchColor='#ffff00';return false;" title="select color">&nbsp;</a>
			</td>
			<td>
				<a style="background-color:#ffffff;height:32px;width:32px;display:block;" onclick="sketchColor='#ffffff';return false;" title="select color">&nbsp;</a>
			</td>
		</tr>
		</table>
	</div>

	</div>
	<div class="popupForm">
		<section class="bottomButtons buttonAlignedRight">
			<label for="replaceSketch">Replace Attachment</label>
			<input type="checkbox" id="replaceSketch" style="display:inline;" class="marginRight10">
			<button onclick="saveSketch()">Save</button>
		</section>
		<div id="replaceSketchHolder" style="position:absolute;display:none;bottom:12px;right:20px;">

		</div>
	</div>
	<form name="file_formSketch" method="post" action="" OnSubmit="unsavedChanges=false;return preUploadBase64();" class="chunkyForm" class="popupForm" target="submitFrame2" id="base64AttachmentFormSketch">
		<input type="hidden" id="sketchAttachmentId" value="">
		<input type="hidden" id="sketchPre" value="">
		<input type="hidden" id="fileNameBase64Sketch" name="fileName">
		<input type="hidden" name="base64File" id="base64FileSketch">
		<input type="hidden" name="base64FileExtension" id="base64FileExtensionSketch">
		<input type="hidden" name="base64FileCKEditorId" id="base64FileCKEditorIdSketch">
		<input type="hidden" name="fileDescription" id="fileDescriptionBase64Sketch">
	</form>
</div>

<%'cytoscape experiment link node map%>
<div id="cytoscapeExperimentLinkNodeMapPopup" class="popupDiv popupBox">
	<div class="popupFormHeader">Experiment Link Node Map</div>
	<div id="cytoscapeExperimentLinkNodeMap" class="cytoscape"></div>
	<div class="nodeMapInfoBox"></div>
	<div class="closeExperimentLinkNodeMap" id="closeExperimentLinkNodeMap">x</div>
</div>

<%'inventory div%>
<div style="width:850px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0px;z-index:101;" id="inventoryPopup" class="popupDiv">
<a href="javascript:void(0)" onClick="hidePopup('inventoryPopup',true);return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif" style="border:none;"></a>
<iframe id="inventorySearchFrame" style="border:none;" width="100%" height="100%" src=""></iframe>
</div>

<div id="inventoryLinkSelectorDiv" class="inventoryLinkSelectorDiv">
	<div id="existingInvItemBtnDiv" class="inventoryLinkSelectorBtn">
		<input type="radio" id="linkToExistingInvItem" name="inventoryLinkRadio" value="existingItem">
		<label for="linkToExistingInvItem">Link to an existing Inventory Item</label>
	</div>
	<div id="newInvItemBtnDiv" class="inventoryLinkSelectorBtn">
		<input type="radio" id="createNewInvItem" name="inventoryLinkRadio" value="newItem">
		<label for="createNewInvItem">Create a new Inventory Item</label>
	</div>
	<a class="createLink" href="javascript:void(0);" onclick="submitInventoryLinkDiv()">Submit</a>
</div>
<script type="text/javascript">

function loadNewNotebookSelect() {
	$.ajax({
		url: "<%=mainAppPath%>/ajax_loaders/newNotebookSelect.asp",
		type: "GET",
		async: true,
		cache: false
	})
		.success(function (selectData) {
			$("#newNotebookId").html(selectData);
		})
		.fail(function () {
			alert("Unable to load project list. Please contact support@arxspan.com.");
		});
}

function loadNotebookDropDowns() {
	$.ajax({
		url: "<%=mainAppPath%>/ajax_loaders/notebooksThisUserCanWriteTo.asp",
		type: "GET",
		async: true,
		cache: false
	})
		.success(function (selectData) {
			$("#newNotebookIdMove").html(selectData);
			$("#nextStepExperimentNotebookId").html(selectData);
		})
		.fail(function () {
			alert("Unable to load notebook list. Please contact support@arxspan.com.");
		});
}


// we initialize the select2 after everything is loaded because loading the dataTables.js can disrupt the select2 data
$(document).ready(function () {
	try {
		initProjectLinkDD("#linkProjectId");
	} catch(e) {
		console.log("Select2 not initialized");
	}
	loadNewNotebookSelect();
	loadNotebookDropDowns();
});
</script>