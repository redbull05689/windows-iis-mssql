<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/backup_and_pdf/functions/fnc_getCSXML.asp"-->
<%
	sectionID = "tool"
	subSectionID="export"
	terSectionID=""
	pageTitle = "Arxspan Bulk Export"
	metaD=""
	metaKey=""
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<!-- #include file="../_inclds/common/js/groupsJS.asp"-->
<script type="text/javascript">

//build the zip file
$.get("<%=mainAppPath%>/exports/exportZIP.asp?random="+Math.random(), function (data){		
	if (data == "DONE"){			
		$("#mainP").html("");
		$('<a>',{
			text: 'Download ZIP File',
			title: 'Download',
			href: '<%=mainAppPath%>/exports/getExport.asp',
			click: function(){ $("#mainP").html("<p>Have A Nice Day!</p>")}
		}).appendTo("#mainP");					
	}
	else
	{
		$("#mainP").html("An unexpected error has occurred in creating of this export ZIP file.");
	}
});

</script>

<h1 style="padding-bottom:10px;">Bulk Export</h1>
<%If request.querystring("from") <> "nav" then%><p id="mainP">Your export is being processed.  Please wait here.</p><%End if%>
<%Call disconnect%>
<!-- #include file="../_inclds/footer-tool.asp"-->