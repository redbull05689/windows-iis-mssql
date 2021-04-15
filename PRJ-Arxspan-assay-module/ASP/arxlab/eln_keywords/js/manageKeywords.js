$(document).ready(function($){
	function addKeyword(){
		var addingKeywordTextInputValue = $('#addingKeywordTextInput').val();
		if(addingKeywordTextInputValue.substr(0,1) == "#"){
			addingKeywordTextInputValue = addingKeywordTextInputValue.substr(1);
		}

		if(addingKeywordTextInputValue.indexOf('#') > -1){
			alert("Your keyword contains a disallowed character: '#'");
			return false;
		}

		if(addingKeywordTextInputValue == ""){
			return false;
		}

		$.ajax({
			url: 'addKeyword.asp',
			type: 'POST',
			dataType: 'html',
			data: {keywordValue: addingKeywordTextInputValue},
		})
		.done(function(response) {
			if(response !== "duplicate"){
				$('#addingKeywordTextInput').val('');

				if($('.noKeywordsFound').length > -1){
					$('.noKeywordsFound').parent().remove();
				}
				
				rowToAppend = '<tr keywordid="' + response + '"><td><div class="keywordValue">#' + addingKeywordTextInputValue + '</div></td><td><div class="keywordDateAdded">Just Now</div></td><td><div class="keywordDisabledCheckboxContainer"><input type="checkbox" class="keywordDisabledCheckbox"></div></td></tr>';
				$('table.experimentsTable.keywordsTable > tbody .addingKeywordTextInputContainer').parent().parent().after(rowToAppend);
			}
			else if(response == "duplicate"){
				alert("This keyword already exists.")
			}
		})
		.fail(function() {
			alert("Sorry, there was an error adding your Keyword. Please try again or contact Arxspan Support.")
		})
		.always(function() {
			$('#addingKeywordTextInput').focus();
		});
		
	}

	$('body').on('click','.newKeywordButton',function(event){
		addKeyword();
	});

	$('body').on('change','.keywordDisabledCheckbox',function(event){
		thisKeywordId = $(this).parent().parent().parent().attr('keywordid');
		$.ajax({
			url: 'toggleKeywordDisabled.asp',
			type: 'POST',
			dataType: 'html',
			data: {keywordId: thisKeywordId, checkboxStatus: $(this).prop('checked')},
		})
		.fail(function(){
			alert("There was an issue disabling/enabling this keyword. Please try again or contact Arxspan Support.")
		})
	});

    $('#addingKeywordTextInput').bind("change input",function(e){
    	console.log(e);
    	if (e.keyCode == 32) {
    	    $(this).val($(this).val() + "-"); // append '-' to input
    	    return false; // return false to prevent space from being added
    	}
    	else if (e.keyCode == 13) {
    		addKeyword();
    	}
    	else if (!e.keyCode) {
    		$(this).val(function (i, v) { return v.replace(/ /g, "-"); }); 
    	}
    });
    $('#addingKeywordTextInput').bind("keyup",function(e){
    	if(e.keyCode == 13){
    		addKeyword();
    	}
    });
});