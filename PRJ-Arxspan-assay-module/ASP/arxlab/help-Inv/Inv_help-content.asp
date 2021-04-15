<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%'should probably add globals to this file.  Also make email addresses global configs%>
<%If session("userId") <> "" then%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Help</title>
<link href="css/styles-help.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
</head>
<body>
<div class="Inv_helpContentDiv">
<%
Dim id
id = request("id")

If id = "1" Then %>

				<h1>Inventory Main Pane</h1> 
				<p>When an object is selected in the left hand location navigation pane, containers inside the item will be displayed by default.  If you want to see the properties of the location itself right-click and select 'view'.</p>
		
				
<% ElseIf id = "2" Then %>

			<h1>Creating a Container</h1>
			<p>To create a new container highlight any location in the left-nav pane that can hold containers, right-click and select 'Add' from the context menu.  Inventory will guide you through the creation of a new container, choosing a container type and then filling the container if applicable.</p>


<% ElseIf id = "3" Then %>

				<h1>Login</h1>
				<p>To go to the Inventory system, log into the ELN "https://eln.arxspan.com/login.asp" and find the Inventory icon in the upper right corner of your screen.  If you do not have the Inventory icon, ask your local Administrator to add the Inventory role to your account.</p>

				
<% ElseIf id = "4" Then %>

				<h1>Containers</h1>
				<p>Containers are the last object in a nested system of locations; they hold the items that you want to track in inventory.  Most containers hold a single substance like bottle, vial or drum but there are several types of specialized containers that hold multiple substances or containers.  </p>

<% ElseIf id = "5" Then %>

				<h1>Action Buttons</h1>
				<p>Actions can be taken on a container in two different ways.  You can either (A) right-click on the container in the left-nav pane to view the actions menu or (B) scroll down the container details to the panel of action buttons.</p>
				
<% ElseIf id = "6" Then %>

				<h1>Audit Trail</h1>

				<p>Scrolling to the very bottom of the container (or location) details pane will bring you to the audit trail for the container.  Every time any of the actions from the action menu above are taken on the container it will be logged in the audit trail.</p>

<% ElseIf id = "7" Then %>



				<h1>Entering Container Contents</h1>
				<p>Inventory items with known chemical structures can be drawn into the structure field of Inventory using the ChemDraw Plugin.  If the Chemdraw Plugin ('pro' version 12 or higher) is installed on your machine then clicking on the structure window will start the plugin and display the chemical drawing toolbar.  If the plugin is not present then Inventory will display structure information as gif images in the structure window.</p>
				<p>Compounds with a known Chemical Abstracts CAS number can be looked up by clicking the CAS lookup button at the bottom of the page and entering the number here.  CAS lookups will populate the structure and name of the compound for you. </p>

<% ElseIf id = "8" Then %>

			<h1>Bulk Operations</h1>
			<p>Compounds with a known Chemical Abstracts CAS number can be looked up by clicking the CAS lookup button at the bottom of the page and entering the number here.  CAS lookups will populate the structure and name of the compound for you. </p>


<% ElseIf id = "9" Then %>

				<h1>Location Navigation Pane</h1> 
				<p>The location pane is organized hierarchically and whatever location is highlighted in this pane will be shown in greater detail in the main pane to the right.</p>
                                <p>Right-clicking on an item in the left-nav pane will bring up a context menu that allows you to perform actions on the highlighted object in the pane.  </p>
                                <p>In the location pane you will find three types of object, locations, containers and substances.  Each of these object types has a defined list of what you can put inside.  For instance, if you right-click on a high level location like 'Chemical Stockroom' and select 'Add'  the things you can add are appropriate for a room: Freezer, Cabinet, Hood etc.  A container like 'Bottle' will not appear as a choice in your add list until you are adding it to a bin, bench or shelf.</p>
		
<% ElseIf id = "10" Then %>

				<h1>Overview</h1> 

				<h2><a name="overview">Inventory Overview</a></h2>
				<p>The Inventory system is a secure, web-based application that allows you to organize locations at your facility and the containers and substances in those locations.  Reagents, cell lines, plates and instruments --anything you can hold in your hand-- can be tracked, sampled, used up and disposed.</p>
				

<% ElseIf id = "11" Then %>

				<h1>Managing Locations</h1>
				<p>Just like containers, menus for taking action on locations can be found in the right-click context menu in the location pane or as buttons in the details of the location in the main pane.  Actions not allowed from your selected location will be gray in the menu.  </p>

<% ElseIf id = "12" Then %>

				<h1>Other Bulk Operations</h1>
				<p>From the 'Bulk Operations' menu at the top of the left-nav bar you can update, move or dispose of any number of containers using their unique barcodes.  For move and dispose operations you only have to enter the barcodes of the containers to move and choose a location. </p>
				<p>To update containers  you need to upload a table file with the barcodes and update information, map the fields to use in the update and then execute the update.  Inventory supports the use of SD files, Excel and CSV for this purpose.</p>

<% ElseIf id = "13" Then %>

				<h1>Search</h1> 

				<h2><a name="search-types">Searching in the ELN</a></h2>
				<p>There are two different seaching schema available in Inventory, standard application searching (detailed below) and the more advanced 'Filter and Transform' FT application.  FT bridges all of the Arxspan product modules: ELN, Registration, Assay and Inventory.</p>
				<p>There are three ways to do a traditional search in the ELN. All searches will return results for all content in Projects, Notebooks and Experiments that you have read access to.</p>
				<ul>
				<li>	<strong>Text Search</strong> - Type your query into the Search box at the top-left of the ELN menu bar and click the Search button or hit the Enter key. Search results will be displayed. Experiments to which you do not have read access will not be shown in search results.</li>
				<li>	<strong>Advanced Search</strong> - Click on the advanced search link under Tools then open the query builder by clicking on the green '+' sign in the search window.  Select search criteria from the drop-down menus in the query builder, adding criteria by clicking green '+' signs and removing them with the '-' sign.  After performing an advanced search, your query will be remembered and will return when you click 'Advanced Search' again.  Advanced search can search for a list of text criteria.  To search for multiple strings select 'in list' from the second drop-down window and then enter a comma-separated list of text strings for the search.  (e.g. Reg IDs or Scientist names)</li>
				<li>	<strong>Chemical Search</strong> - Click on Chemical Search under the Tools header in the left menu bar. Enter your search query; PerkinElmer ChemDraw&trade; is required for Chemical Searching in Inventory. Specify the search type: substructure, exact or similarity as well as results per page and sorting options. Click the Search button. Search results will be displayed. Results to which you do not have read access will not be shown in search results.</li>
				</ul>


<% ElseIf id = "14" Then %>

				<h1>Receiving</h1>
				<p>Inventory has a receiving feature that allows a technician to rapidly create container records for compounds that arrive at the receiving doc.  For each container just enter a chemical name or CAS number for the substance, scan or enter the location where the container is to be created and then scan or enter the barcode for the new container.</p>
				
	
<% Else %>

	 <h2>Arxspan Help</h2>
	 <p>Select a help topic on the left.</p>

<% End If %>
</div>

</body></html>
<%End if%>