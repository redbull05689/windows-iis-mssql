	function deleteSubmit()
	{
		if (confirm('Are you sure you wish to delete this experiment?'))
		{
			//submit the delete experiment form (target=submitFrame) and trigger wait function
			$.ajax({
				url: $("#deleteForm").attr('action'),
				type: $("#deleteForm").attr('method'),
				data: $("#deleteForm").serialize(),
				success: function(data)
				{
					swal("Completed", "Experiment deleted." , "success");//strip the html and just alert the text 
					window.location = "dashboard.asp";
				},
				error: function(error, textStatus, errorThrown)
				{
					console.log("reopen error! ", error);
					swal("Sorry", $("<div/>").html(error.responseText).text() , "error");//strip the html and just alert the text 
				},
				complete: function()
				{
				}
			 });
			return false;
		}
	}
