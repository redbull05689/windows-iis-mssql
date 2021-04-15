<script type="text/javascript" src="<%=mainAppPath%>/common/popper.js-1.12.3/dist/umd/popper.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/common/bootstrap-3.3.5/js/bootstrap.js?<%=jsRev%>"></script>


<script>
	window.CurrentPageMode = "custExp"
	window.currApp = "Workflow";
</script>





<script type="text/javascript">


	function showReq(requestId)
	{
		
		var width = ($(window).width()/3)*2,
			height = ($(window).height()/3)*2 ,
			left = ($(window).width() - width) / 2,
			top = ($(window).height() - height) / 2,
			url = "<%=mainAppPath%>/workflow/viewIndividualRequest.asp?base=true&inFrame=true&requestid=" + requestId,
			opts = 'status=1' +
					',width=' + width +
					',height=' + height +
					',top=' + top +
					',left=' + left;

		window.open(url, 'twitte', opts);

	}


</script>