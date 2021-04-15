<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%If session("userId") <> "" then%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Contents</title>
<link href="css/styles-help.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
</head>
<body>

<div class="tableOfContents">
<h3 style="margin-top:8px;"><a href="help-content.asp?id=1" target="contentFrame">Registration Users Help</a></h3>
<h3><a href="help-content.asp?id=1" target="contentFrame">Searching</a></h3>
	<ul>
		<li><a href="help-content.asp?id=1#structure" target="contentFrame">Structure Searching</a></li>
		<li><a href="help-content.asp?id=1#text" target="contentFrame">Generic Text Searching </a></li>
		<li><a href="help-content.asp?id=1#advanced" target="contentFrame">Advanced Text Searching</a></li>
	</ul>
<h3><a href="help-content.asp?id=2" target="contentFrame">Managing Search Results</a></h3>
	<ul>
		<li><a href="help-content.asp?id=2#layout" target="contentFrame">Results Layout</a></li>
		<li><a href="help-content.asp?id=2#organizing" target="contentFrame">Organizing Results </a></li>
		<li><a href="help-content.asp?id=2#exporting" target="contentFrame">Exporting Results</a></li>
	</ul>
<h3><a href="help-content.asp?id=3" target="contentFrame">Compound Registration</a></h3>
	<ul>
		<li><a href="help-content.asp?id=3#required" target="contentFrame">Required Fields</a></li>
		<li><a href="help-content.asp?id=3#batches" target="contentFrame">Registering Batches </a></li>
		<li><a href="help-content.asp?id=3#unique" target="contentFrame">Enforced Uniqueness</a></li>
		<li><a href="help-content.asp?id=3#drop" target="contentFrame">Drop-Down Menus</a></li>
		<li><a href="help-content.asp?id=3#clones" target="contentFrame">Batches of Batches</a></li>
		<li><a href="help-content.asp?id=3#projects" target="contentFrame">Projects</a></li>
	</ul>

<h3><a href="help-content.asp?id=4" target="contentFrame">Field Groups</a></h3>
	<ul>
		<li><a href="help-content.asp?id=4#overview" target="contentFrame">Overview</a></li>
		<li><a href="help-content.asp?id=4#selecting" target="contentFrame">Selecting Field Group</a></li>
	</ul>	
<h3 style="margin-top:8px;"><a href="help-content.asp?id=98" target="contentFrame">Registration Admin Guide</a></h3>
<h3><a href="help-content.asp?id=10" target="contentFrame">Importing and Modifying Reg Data</a></h3>
	<ul>
		<li><a href="help-content.asp?id=10#bulkreg" target="contentFrame">Bulk Registration</a></li>
		<li><a href="help-content.asp?id=10#bulkup" target="contentFrame">Bulk Update</a></li>
		<li><a href="help-content.asp?id=10#maptemplates" target="contentFrame">Mapping Templates</a></li>
		<li><a href="help-content.asp?id=10#rollback" target="contentFrame">Bulk Registration Log</a></li>
		<li><a href="help-content.asp?id=10#errors" target="contentFrame">Error Files</a></li>
	</ul>
<h3><a href="help-content.asp?id=11" target="contentFrame">Admin Approval</a></h3>
	<ul>
		<li><a href="help-content.asp?id=11#approve" target="contentFrame">Approve/Reject Compounds</a></li>
	</ul>

<h3><a href="help-content.asp?id=12" target="contentFrame">Custom Drop-downs</a></h3>
	<ul>
		<li><a href="help-content.asp?id=12#dropdown" target="contentFrame">Creating a Custom Drop-down List</a></li>
	</ul>

<h3><a href="help-content.asp?id=13" target="contentFrame">Custom Fields</a></h3>
	<ul>
		<li><a href="help-content.asp?id=13#cfpool" target="contentFrame">Custom Field Pool</a></li>
		<li><a href="help-content.asp?id=13#datatypes" target="contentFrame">Data Types</a></li>
		<li><a href="help-content.asp?id=13#options" target="contentFrame">Field Options</a></li>
	</ul>

<h3><a href="help-content.asp?id=14" target="contentFrame">Custom Field Groups</a></h3>
	<ul>
		<li><a href="help-content.asp?id=14#fgcreate" target="contentFrame">Creating New Field Groups</a></li>
		<li><a href="help-content.asp?id=14#fgedit" target="contentFrame">Editing Field Groups</a></li>
	</ul>
	
</div>
</body>
</html>
<%End if%>