<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<script type="text/javascript">
var saveInProgress = false;

<!-- #include file="../../common/js/experimentLinksJS.asp"-->
<!-- #include file="../../common/js/experimentCommonJS.asp"-->
<!-- #include file="../../../common/js/uploadJS.asp"-->
</script>

<!-- #include file="../../common/js/allExperimentInclude.asp"-->

<script type="text/javascript">
function hideUnsavedChanges(){
    us = document.getElementById("unsavedChanges");
    us.style.display = "none";
    us = document.getElementById("unsavedChanges2");
    us.style.display = "none";
}
</script>

<script type="text/javascript">
	var attachments = [];
	var notes = []
	var mainTabs = ['experimentDiv'];
	<%if hasAttachments then%>
		mainTabs.push('attachmentTable')
	<%end if%>
	<%if hasNotes then%>
		mainTabs.push('noteTable')
	<%end if%>

	var currentTab = "";
	<%if request.querystring("id") <> "" then%>
		var id = <%=request.querystring("id")%>;
	<%else%>
		var id = '';
	<%end if%>
	<%if request.querystring("revisionId") <> "" then%>
		var revisionId = <%=request.querystring("revisionId")%>;
	<%else%>
		var revisionId = '';
	<%end if%>
	var currentMainTab = "";
	var mainTabSelected = "experimentDiv";
	var hungSaveSerial = <%=hungSaveSerial%>;
	function showMainDiv(divId)
	{
		foundIt = false
		for (i=0;i<mainTabs.length ;i++ )
		{
			if (mainTabs[i] != divId)
			{
				try
				{
					document.getElementById(mainTabs[i]).style.display='none';
					document.getElementById(mainTabs[i]+"_tab").className = ""
				}
				catch(err){}
			}
			else
			{
				try
				{
					foundIt = true
					document.getElementById(mainTabs[i]).style.display='block';
					document.getElementById(mainTabs[i]+"_tab").className = "tabSelected selectedTab"
					currentMainTab = mainTabs[i]
					helpId = '4'
					if (currentMainTab == 'noteTable')
					{
						helpId = '6'
					}
					if (currentMainTab == 'attachmentTable')
					{
						helpId = '5';
						<%if ownsExp then%>
							el = document.getElementById("uploadFormHolder");
							if (el) {
								elRow = document.getElementById("attachmentTableFileUploadRow")
								if (elRow) {
									elRow.appendChild(el.parentNode.removeChild(el));
								}
								el.style.display = "block";
							}
						<%end if%>
					}
					try
					{
						el = document.getElementById(mainTabs[i]+"_att")
						newSrc = document.getElementById(mainTabs[i]+"_src").innerHTML.replace("&amp;","&")
						oldSrc = el.src.substring(el.src.lastIndexOf('/')+1)
						if (oldSrc == "loading.html" || oldSrc == "loading.gif")
						{
							el.src = newSrc
						}
					}
					catch(err){}
				}
				catch(err){}
			}
		}
		if(!foundIt){showMainDiv(mainTabs[0])}

		Array.prototype.forEach.call(document.querySelectorAll("iFrame.cke_wysiwyg_frame"), function(element, index, array){
			element.style.width='100%';
		});
	}

	function displayTab(tabName)
	{
		if (currentTab != "")
		{
			document.getElementById(currentTab+"_body").style.display = "none";
			document.getElementById(currentTab+"_tab").className = "";
		}
		document.getElementById(tabName+"_body").style.display = "block";
		currentTab = tabName;
		document.getElementById(currentTab+"_tab").className = "tabSelected selectedTab"
	}

	<%
	experimentTypeName = GetAbbreviation(experimentType)
	%>
	
	// include the file that contains the server save function
	<!-- #include file="../../common/js/serverSaveExperimentJS.asp"-->
	
	function experimentSubmit(approve,sign,autoSave,refreshPageAfterSave)
	{
		showPopup('savingDiv')
		killIntervals();
		if(sign){
			isForSign = true;
		}else{
			isForSign = false;
		}
		
		/* ELN-1077 adding a sketch with AJAX save causes different issues then the issues already in prod
		if (!(experimentId === parseInt(experimentId))){
			experimentId = experimentId.value;
			experimentType = experimentType.value;
		}
		*/
		
		experimentId = <%=experimentId%>;
		experimentType = <%=experimentType%>;
		
		experimentJSON["experimentId"] = experimentId;
		experimentJSON["hungSaveSerial"] = hungSaveSerial;

		document.getElementById("addFile_tab").style.display = "block";

		<%
		'create a string of the attachment names present on the form for processing by the 
		'save experiment form ie, name 1,name 2,name 3
		%>
		attachmentsString = ""
		for (i=0;i<attachments.length ;i++ )
		{
			attachmentsString += attachments[i]
			if (i < attachments.length - 1)
			{
				attachmentsString += ","
			}
		}
		experimentJSON["attachments"] = attachmentsString;
		<%
		'set form value for approval
		%>
		if (approve)
		{
			experimentJSON["approve"] = "true";
		}
		
		<%
		'copy the value of the notebookid into the new form in case the element is disabled
		%>
		if (sign)
		{
			var signSignEmail = document.getElementById("signEmail").value;
			var signPassword = document.getElementById("password").value;
			var signTypeId = document.getElementById("typeId").value;
			var signSign = document.getElementById("sign").value;
			var signSignStatus = document.getElementById("signStatusBox").options[document.getElementById("signStatusBox").selectedIndex].value;
			var signRequesteeId = document.getElementById("requesteeIdBox").options[document.getElementById("requesteeIdBox").selectedIndex].value;
			var signVerifyState = document.getElementById("verify").checked
			
			if(document.getElementById('isSsoUser').value === 'true' && document.getElementById('ssoSignValue').value === 'true' && document.getElementById('isSsoCompany').value === 'true')
			{
				signPassword = "";
				signSignEmail = "";
				signTypeId = document.getElementById("ssoTypeId").value;
				signSign = document.getElementById("ssoSignValue").value;
				signSignStatus = document.getElementById("ssoSignStatusBox").options[document.getElementById("ssoSignStatusBox").selectedIndex].value;
				signRequesteeId = document.getElementById("requesteeIdBox").options[document.getElementById("requesteeIdBox").selectedIndex].value;
				signVerifyState = document.getElementById("ssoVerify").checked
			}

			experimentJSON["signEmail"] = signSignEmail;
			experimentJSON["password"] = signPassword;
			experimentJSON["typeId"] = signTypeId;
			experimentJSON["sign"] = signSign;
			experimentJSON["signStatus"] = signSignStatus;
			experimentJSON["requesteeId"] = signRequesteeId;
			experimentJSON["verifyState"] = signVerifyState;
		}
		if(CKEDITOR.instances.e_protocol.hasChanges){
			experimentJSON["e_protocol"] = CKEDITOR.instances.e_protocol.getData()
		}
		if(CKEDITOR.instances.e_summary.hasChanges){
			experimentJSON["e_summary"] = CKEDITOR.instances.e_summary.getData()
		}
		tas = document.getElementsByTagName("textarea")
		for (i=0;i<tas.length;i++ )
		{
			try{
				textData = CKEDITOR.instances[tas[i].id].getData();
				document.getElementById(tas[i].id).value = CKEDITOR.instances[tas[i].id].getData()
				experimentJSON[tas[i].id] = document.getElementById(tas[i].id).value
			}catch(err){
				try{
					experimentJSON[tas[i].id] = document.getElementById(tas[i].id).value
				}catch(err){}
			 }
        }

        var hiddenExperimentJSON = experimentJSON
        for (var key in hiddenExperimentJSON) {
          if (hiddenExperimentJSON.hasOwnProperty(key)) {
		  
            if (key.startsWith("note_") && (key.endsWith("_name") || key.endsWith("_description"))){
                hiddenExperimentJSON[key] = Encoder.htmlEncode(fixHTMLForCKEditor(hiddenExperimentJSON[key]));
            }
			if (key.startsWith("file_") && key.endsWith("_description")){
                hiddenExperimentJSON[key] = Encoder.htmlEncode(fixHTMLForCKEditor(hiddenExperimentJSON[key]));
            }
			
			if (typeof hiddenExperimentJSON[key] == "string"){
            hiddenExperimentJSON[key] = encodeJSON(hiddenExperimentJSON[key]);
            }
          }
        }
        //Clear all the timeouts so it doesn't draft save after saving
        if (Array.isArray(editorsOnTimeout)){
            editorsOnTimeout.forEach(function(e){
                window.clearTimeout(e);
            });
        }
		
		// ajax call to the server to save experiment
		doServerSaveExperiment("<%=mainAppPath%>/experiments/bio-saveExperiment.asp",{hiddenExperimentJSON: JSON.stringify(hiddenExperimentJSON) },sign);
    }

    function updateAttachments(){
       	//$('#formresetbutton').click();
        el = document.getElementById("uploadFormHolder");
        if (el) {
            el.style.display = "none";
            elHolder = document.getElementById("uploadFormHolderHolder");
            if (elHolder) {
                elHolder.appendChild(el.parentNode.removeChild(el));
            }
        }

        htmlStr = getFile("/arxlab/ajax_loaders/getAttachmentTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&rand="+Math.random());
        document.getElementById("attachmentTable").innerHTML = htmlStr;
        for (k=0;k<tableItemsToRemove.length ;k++ )
        {
            try{document.getElementById(tableItemsToRemove[k]).style.display = 'none';}catch(err){}
        }
        delayedRunJS(htmlStr);
        unsavedChanges = true;

		el = document.getElementById("uploadFormHolder");
        if (el) {
            elRow = document.getElementById("attachmentTableFileUploadRow")
            if (elRow) {
                elRow.appendChild(el.parentNode.removeChild(el));
            }
            el.style.display = "block";
        }
        positionButtons();
        $(".droptouploadtext").text("Drag files to upload");
	    $(".droptouploadtextIEonly").text("Drag files to upload");
		
		//ELN-1184 Reinitialize blueimp fileupload dropzone
		reInitializeDropZone()
	}
    function updateNotes(){
         $.get("<%=mainAppPath%>/experiments/ajax/load/getNoteTable.asp?experimentId="+experimentId+"&experimentType="+experimentType+"&time="+$.now(), function(data) {
            //console.log(data);
            $("#noteTable").html(data);
         });
    }


    function updateBottomButtons(thisRevisionNumber){
        notebookId = document.getElementById("notebookId").value
        $.get("<%=mainAppPath%>/_inclds/experiments/common/buttons/html/ajaxExperimentBottomButtons.asp?experimentId="+experimentId+"&experimentType="+experimentType+"&notebookId="+notebookId, function(data) {
            //console.log(data);
            $("#bottomButtons").html(data);
            positionButtons();
            document.getElementById("submitRow").style.display = 'block';
			updateShowPDFButton(thisRevisionNumber);
         });
    }

    function updateShowPDFButton(revNumber){
        $('#makePDFLink').attr('href',"<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=" + revNumber);
        $('#makeShortPDFLink').attr('href',"<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber="+ revNumber +"&short=1");
    }

	window.requiredFieldsJSON = <%
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT experimentConfigJson FROM companies WHERE id="&SQLClean(session("companyId"),"N","S")&" AND experimentConfigJson is not null"
	rec.open strQuery,connAdm,3,3
	experimentConfigJson = "{}"
	Do While Not rec.eof
		For Each field in rec.Fields
			experimentConfigJson = field
		Next
		rec.movenext
	Loop
	response.write experimentConfigJson
	%>
	indicateRequiredFields();

	function notebookChange()
	{
		experimentName = getFile("<%=mainAppPath%>/experiments/ajax/load/nextExperimentName.asp?notebookId=<%=notebookId%>&random"+Math.random())
		document.getElementById("e_name").value = experimentName;
		showTR("sectionRow");
		document.getElementById("experimentDiv").style.display = "block"
	}

<%If request.querystring("revisionId") = "" and ownsExp Then%>
addLoadEvent(function(){attachEdits(document.getElementById("pageContentTD"))})
<%end if%>
</script>
