<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
titleData = "Arxspan Inventory"
isObjectTemplates = true
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header.asp"-->

<div class="importFromSciQuestContainer">
	<h1>Import from SciQuest</h1>
	<div id="sciQuestImportDynaTree"></div>
	<div class="sciQuestFileUploadContainer">
		<input type="file" id="sciQuestFileUploadInput" name="files[]">
	</div>
	<div class="sciQuestImportSubmitButtonContainer">
		<button type="button" id="sciQuestImportSubmitButton" class="sciQuestImportSubmitButton" disabled="disabled">Import SciQuest File</button>
	</div>
	<div class="importInProgress">Import is in progress...</div>
	<div class="importResponseSection">
		<div class="successCount"></div>
		<div class="failureCount"></div>
		<div class="errorsContainer"></div>
	</div>
</div>

<script type="text/javascript">
	$(document).ready(function(){
		$("#sciQuestImportDynaTree").dynatree({
			initAjax: {url: "/getTree/",
					   data: {key: "root", // Optional arguments to append to the url
							  mode: "all",
							  type: "root",
							  connectionId:connectionId
							  }
					   },
			onLazyRead: function(node){
				node.appendAjax({url: "/getTree/",
								   data: {"key": node.data.key.replace("_",""), // Optional url arguments
										  "mode": "all",
										  "type": node.data.type,
										  connectionId:connectionId
										  }
								  });
			},
			onClick: function(node){
				node.appendAjax({url: "/getTree/",
								   data: {"key": node.data.key.replace("_",""), // Optional url arguments
										  "mode": "all",
										  "type": node.data.type,
										  connectionId:connectionId
										  },
									  success: function(data){
										node.expand();
										
										window.sciQuestImportDynaTreeActiveNodeType = $("#sciQuestImportDynaTree").dynatree("getActiveNode").data.type
										allowedChildren = restCall("/getAllowedChildren/","POST",{"type":window.sciQuestImportDynaTreeActiveNodeType});
										if(allowedChildren.indexOf("bottle")!=-1){
											$('#sciQuestImportSubmitButton').prop('disabled',false)
										}
										else{
											$('#sciQuestImportSubmitButton').prop('disabled',true)
										}
									  }
								  });
			},
			imagePath: "images/treeIcons/"
		});

		$('body').on('click','button#sciQuestImportSubmitButton',function(event){
			var fileInputData = new FormData();
            fileInputData.append("fileInput", $("#sciQuestFileUploadInput")[0].files[0]);
            $.ajax({
                url: 'sciQuestImport_submit.asp?targetLocation='+$("#sciQuestImportDynaTree").dynatree("getActiveNode").data.key,
                type: 'POST',
                cache: false,
                data: fileInputData,
                processData: false,
                contentType: false,
                beforeSend: function (response) {
                    $(".importInProgress").addClass('makeVisible');
                	$('.importResponseSection .errorsContainer, .importResponseSection .failureCount, .importResponseSection .successCount').empty();
                },
                success: function (response) {
                    response = JSON.parse(response);
                    $('.importResponseSection .successCount').text('Successful: ' + response.successCount)
                    $('.importResponseSection .failureCount').text('Failed: ' + response.failureCount)
                    $.each(response['errors'], function(){
                    	$('.importResponseSection .errorsContainer').append('<div>' + 'Line Number in File: ' + this['Line Number in File'] + '<br />Field Name: ' + this['Field Name'] + '<br />Field Value: ' + this['Field Value'] + '<br />Error Reason: ' + this['Error Reason']);
                    });
                },
                complete: function (response) {
                    $(".importInProgress").removeClass('makeVisible');
                },
                error: function () {
                    alert("An unexpected error occurred.");
                }
            });
		});
	});
</script>
<!-- #include file="_inclds/footer.asp"-->