function replicateCSS3calc(){
	var currentBodyWidth = $("body").width();

	//console.log(currentBodyWidth);

	currentContentSectionWidth = $(".contentSection").width();
	var contentSectionWidthAdjustedForContentDisplay = currentContentSectionWidth - 381;
	$(".contentDisplaySection").css('width', contentSectionWidthAdjustedForContentDisplay + "px");

	if(currentBodyWidth <= 1920 && currentBodyWidth >= 1256){
		$(".sidebarContainer").css('width','380px').css('min-width','380px');

		$(".sidebarContainerDashboard ul.sidebarContent .viewAllRecentButtonInner").css('max-width','359px').css('text-align','center');

		$(".sidebarContainerInner").css('min-width','379px');
	}
	else if(currentBodyWidth <= 1255){
		var bodyWidthAdjustedForSidebarContainer = currentBodyWidth - 874;
		$(".sidebarContainer").css('min-width',bodyWidthAdjustedForSidebarContainer + "px");
		$(".sidebarContainer").css('width',bodyWidthAdjustedForSidebarContainer + "px");

		$(".sidebarContainerDashboard ul.sidebarContent .viewAllRecentButtonInner").css('max-width',currentBodyWidth).css('text-align','center');
		// Taking into account the 874px subtracted from the sidebar - need to make up for the fact the actual stylesheet uses 100% width on this element that has a parent with a defined width
		var bodyWidthAdjustedForSidebarContainerInner = currentBodyWidth - (874 + 1);
		$(".sidebarContainerInner").css('min-width',bodyWidthAdjustedForSidebarContainerInner);

		$(".contentDisplaySection").css('width', '873px');
	}
	else if(currentBodyWidth <= 1030){
		$(".sidebarContainerDashboard ul.sidebarContent .viewAllRecentButtonInner").css('max-width','30px').css('text-align','left');
	}
				
}

var ltIE9 = !document.addEventListener;

function checkSidebarHeight(){
	// Get the inner sidebar container's height:
	window.sideBarContainerInnerHeight = $(".sidebarContainerInner").height();
	// Set the height of the outer sidebar container to that of the inner sidebar container
	$(".sidebarContainer").height(window.sideBarContainerInnerHeight + 4);
	// Get the <body> element's height & subtract 73px (height of the header)
	var sidebarContainerNewHeight = $("body").height() - 73;
	// Make sure that the sidebar is NEVER able to be shorter than the main content section
	//$(".sidebarContainer").css('min-height',sidebarContainerNewHeight + 'px');
	$(".sidebarContainerInner").css('min-height',sidebarContainerNewHeight + 'px');

	if(ltIE9){
		replicateCSS3calc();
	}
}
