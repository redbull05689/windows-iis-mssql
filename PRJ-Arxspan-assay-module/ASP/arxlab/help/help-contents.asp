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
<h3><a href="help-content.asp?id=10" target="contentFrame">Search</a></h3>
	<ul>
		<li><a href="help-content.asp?id=10#search-types" target="contentFrame">Text Search</a></li>
		<li><a href="help-content.asp?id=10#search-types" target="contentFrame">Advanced Search</a></li>
		<li><a href="help-content.asp?id=10#search-types" target="contentFrame">Chemical Search</a></li>
	</ul>

<h3><a href="help-content.asp?id=3" target="contentFrame">Dashboard</a></h3>
	<ul>
		<li><a href="help-content.asp?id=3#recent" target="contentFrame">Recent Experiments</a></li>
		<li><a href="help-content.asp?id=3#notifications" target="contentFrame">Notifications</a></li>
		<li><a href="help-content.asp?id=3#invitations" target="contentFrame">Invitations</a></li>
		<li><a href="help-content.asp?id=3#preferences" target="contentFrame">User Preferences</a></li>
	</ul>

<h3><a href="help-content.asp?id=9" target="contentFrame">Projects</a></h3>
	<ul>
		<li><a href="help-content.asp?id=9#create" target="contentFrame">Create Project</a></li>
		<li><a href="help-content.asp?id=9#name" target="contentFrame">Name and Description</a></li>
		<li><a href="help-content.asp?id=9#sections" target="contentFrame">Project Sections</a></li>
		<li><a href="help-content.asp?id=9#add-content" target="contentFrame">Adding Content</a></li>
		<li><a href="help-content.asp?id=9#remove-content" target="contentFrame">Removing Content</a></li>
		<li><a href="help-content.asp?id=9#sharing" target="contentFrame">Sharing Invitations</a></li>
		<li><a href="help-content.asp?id=9#sharethis" target="contentFrame">Share This Project</a></li>
		<li><a href="help-content.asp?id=9#contributors" target="contentFrame">Project Team</a></li>
	</ul>

<h3><a href="help-content.asp?id=1" target="contentFrame">Notebooks</a></h3>
	<ul>
		<li><a href="help-content.asp?id=2" target="contentFrame">Create Notebook</a></li>
		<li><a href="help-content.asp?id=1#name" target="contentFrame">Name and Description</a></li>
		<li><a href="help-content.asp?id=1#table" target="contentFrame">Table of Contents</a></li>
		<li><a href="help-content.asp?id=1#create" target="contentFrame">Creating Experiments</a></li>
		<li><a href="help-content.asp?id=1#sharethis" target="contentFrame">Share This Notebook</a></li>
		<li><a href="help-content.asp?id=1#sharing" target="contentFrame">Sharing Invitations</a></li>
		<li><a href="help-content.asp?id=1#contribute" target="contentFrame">Notebook Contributors</a></li>
	</ul>

<h3><a href="help-content.asp?id=4" target="contentFrame">Experiments</a></h3>
	<ul>
		<li><a href="help-content.asp?id=4" target="contentFrame">Experiment Overview</a></li>
		<li><a href="help-content.asp?id=4#name" target="contentFrame">Name and Description</a></li>
		<li><a href="help-content.asp?id=4#watchlist" target="contentFrame">Watchlists</a></li>
		<li><a href="help-content.asp?id=4#chemistry" target="contentFrame">Chemistry Experiments</a></li>	
		<li><a href="help-content.asp?id=4#biology" target="contentFrame">Biology Experiments</a></li>
		<li><a href="help-content.asp?id=4#free" target="contentFrame">Concept Experiments</a></li>
		<li><a href="help-content.asp?id=4#template" target="contentFrame">Templates</a></li>
		<li><a href="help-content.asp?id=4#sign" target="contentFrame">Signing Experiments</a></li>
		<li><a href="help-content.asp?id=4#witness" target="contentFrame">Witnessing and Rejection</a></li>
		<li><a href="help-content.asp?id=4#history" target="contentFrame">Audit Trail</a></li>

	</ul>

<h3><a href="help-content.asp?id=5" target="contentFrame">File Attachments & Notes</a></h3>
	<ul>
		<li><a href="help-content.asp?id=5#adding" target="contentFrame">Adding File Attachments</a></li>
		<li><a href="help-content.asp?id=5#managing" target="contentFrame">Managing File Attachments</a></li>
		<li><a href="help-content.asp?id=6#adding" target="contentFrame">Adding Notes</a></li>
		<li><a href="help-content.asp?id=6#managing" target="contentFrame">Managing Notes</a></li>
	</ul>

<h3><a href="help-content.asp?id=7" target="contentFrame">User Profiles</a></h3>
	<ul>
		<li><a href="help-content.asp?id=7#profile" target="contentFrame">Change User Profile</a></li>
	</ul>

<h3><a href="help-content.asp?id=11" target="contentFrame">System Administration</a></h3>
	<ul>
		<li><a href="help-content.asp?id=11#roles" target="contentFrame">ELN User Roles</a></li>
		<li><a href="help-content.asp?id=11#manage-users" target="contentFrame">User Account Management</a></li>
		<li><a href="help-content.asp?id=11#manage-groups" target="contentFrame">User Group Management</a></li>
		<li><a href="help-content.asp?id=11#backup" target="contentFrame">System Backups</a></li>
	</ul>

</div>
</body>
</html>
<%End if%>