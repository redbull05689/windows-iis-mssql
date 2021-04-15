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
<div class="helpContentDiv">
<%
Dim id
id = request("id")

If id = "1" Then %>

				<h1>Searching</h1> 
				<p>Searching over your registered substances can be done in three different ways. Results for searches will only include items to which you have read access privileges.</p>
		
				<h2><a name="structure">Structure Searching</a></h2>
				<p>In a database where chemical structures are registered you can draw a structure in the structure window that appears when you click search.  Chemical structures can be entered into the structure search window using the ChemDraw&trade; plugin installed on your client.  In the abscence of the Chemdraw Plugin your browser will employ the Marvin Draw Java applet.  </p>
				<p>Structure searching can be done in any one of the following ways, substructure, exact structure, similarity or superstructure.   Select the search type you want to execute using the 'search type' drop-down menu below the structure input window.  </p>
				<p>The chemical searching routines used in the ELN products uses ChemAxon's J-Chem.</p>

				<h2><a name="text">Generic Text searching</a></h2>
				<p>The text window underneath the chemical structure window is for free text searching.  The free text search looks at all of the fields in your registration system.  Partial text strings or numbers will bring back hits, for example searching for "185" will return the compound number ARX-001851 as well as a compound with a melting point of 185.</p>

				<h2><a name="advanced">Advanced Text Searching</a></h2>
				<p>Provides you with a query builder.  The query builder opens a single search line when you click the green + sign next to advanced search.  Select the field you want to target from the drop-down menu.  The top fields in the list are Compound-level fields and the second group of field names are Batch fields.  </p>
				<p>Clicking the green '+'  icon to the right of your first line will open another line for your query.   You must separate lines in the query with an 'and' or an 'or'. </p> 
				<p>In text fields in an advanced search you can select 'in list' and then enter a series of criteria separated by commas.  The most common use for 'in list' is to retrieve a list of registered compounds, e.g. ARX-0001,ARX-0019,ARX-0992</p>
				<p>If you are doing an advanced search and click the 'Search' icon in the menu pane again, your last search will be remembered.</p>
			
<% ElseIf id = "2" Then %>

			<h1>Managing Search Results</h1>
			<p>Search results appear  in a table  and can be sorted, modified and exported.</p>

			<h2><a name="layout">Results Layout</a></h2>
				<p>Registration systems for small molecules will display the chemical structure of search results in the first column and the Reg Number in the second column.  If there are batches of compounds in your search results, there will be a large '+' sign to the left of the structure/reg number.  Clicking the icon will open the compound and show batches with hits.</p>
			<h2><a  name="organizing">Organizing Results</a></h2>
				<p>Clicking on the compound number link in search results will open a new tab in your browser and display that compound's information in the new tab.  At the bottom of the compound info screen is a list of all batches that belong to the parent compound.  Note that all batches are displayed under a compound but only search result hits appear in the search results tab.  Return to the search results tab at any time to see your original hits.	</p>
			<h2><a  name="exporting">Exporting Results</a></h2>
				<p>Export your hit list by clicking on the 'Export Results' link.  You will first be prompted to select what fields you would like to export.  After checking desired fields click the 'Download' button.  An SD file will be assembled and  downloaded to your computer.  If you have a large number of fields available in your Registration system you may need to scroll down to find the Download button at the bottom of the list.</p>
				
<% ElseIf id = "3" Then %>

				<h1>Compound Registration</h1>
				<p>Clicking on the 'Register Compound' link brings you to the single-compound registration page.  Here you enter information about the substance you wish to register.  If your substance is already in the registration system you will be prompted to enter information to create a new batch of the existing substance.   </p>

				<h2><a  name="required">Required Fields</a></h2>
				<p>Required Fields are identified by an asterisk after the field name in each case. The Registration system will not allow you to proceed until there is information in all required fields.		</p>
				<h2><a  name="batches">Registering Batches</a></h2>
				<p>Once you have successfully registered a new compound you will be prompted to enter a batch of that compound.  Batch level information is specific to the substance that is in your hand.  Chemist, amount, physical form and purity are common batch-level fields.	</p>
				<h2><a  name="unique">Enforced Uniqueness</a></h2>
				<p>Some fields can be set to require a unique entry.  These will normally be at the batch level.  Registration ID will always be a unique value but barcode and notebook page are also commonly designated as unique identifiers for a batch.</p>
				<h2><a  name="drop">Drop-Down Menus</a></h2>
				<p>Drop-down menus can be created and edited for registration fields by an administrator.  Using drop-down choices to populate your registration system as much as possible helps to normalize your data.  Storage conditions or physical form are common drop-down lists.</p>
				<h2><a  name="clones">Batches/Clones of Batches</a></h2>
				<p>In field groups that are not chemical structure-based, it is possible to create batches of batches.  A hierarchy of batches is necessary for keeping track of a cell line or oligonucleotide lineage.</p>
				<h2><a  name="projects">Projects</a></h2>
				<p>Projects are used to manage the security of substances and their associated data in the Registration system.  When a project is created, access to that project is given to users or to groups.  Only people who have been given access to a project can see the registered substances in that project.  Administrators and owners of a project can add or remove substances or users or groups from the project.  </p>

<% ElseIf id = "4" Then %>

				<h1>Field Groups</h1>
				<p>Administrators can create new field groups to register different groups of substances. </p>

				<h2><a  name="overview">Overview</a></h2>
				<p>A company may wish to maintain several different lines of registered products.  For example, separate registration lines can be created for small molecules,  natural product extracts and cell lines.  Each group of fields will have its own required fields, unique fields and registration forms.</p>
				<h2><a  name="selecting">Selecting Field Group</a></h2>
				<p>Whenever you register a new compound the available field groups will be presented to you in a drop-down menu.  The default field group is the Small Molecule one.  If the registration form does not look right to you then there is a good chance that you are in the wrong field group.</p>
		
<% ElseIf id = "10" Then %>

				<h1>Importing and Modifying Reg Data</h1>
				<p>Compounds or substances can be registered or edited <i>en masse</i> loading into the Registration system either an chemical Structure Data File (.sdf) or a Comma Separated Values (.csv) file.  </p>

				<h2><a  name="bulkreg">Bulk Registration</a></h2>
				<p>All information required to register compounds must be loaded into an SD file or a comma-separated values file. It is best to register a couple of test substances by hand before trying the bulk process.  Required fields must all have data populated in the loader file and fields with a unique constraint must be unique or the registration of each unqualified record will fail.  If there are any problems with a bulk load, an <a href="help-content.asp?id=10#errors" target="contentFrame">error file</a> will be generated.</p>
				<p>To register in bulk click on the 'Bulk Registration' link and then choose the <a href="help-content.asp?id=14#fgcreate" target="contentFrame">Field Group</a> to which you will be adding substances.  Next choose your loader file and then click 'UPLOAD'.   </p>
				<p>After a successful upload you will be presented with the field mapping worksheet.  On the left are the fields from your file and on the right are the fields for the field group to which you are registering new substances.  </p>
				<p>Match the fields keeping in mind several requirements. </p>
					<li>Starred fields are required
					<li>They are not marked but unique fields must be unique <i>e.g.</i> barcode or notebook page.
					<li>Fields that have a drop-down list in the registration system must match a value from the drop-down list.  Examples are 'Scientist' or 'Project Code'.
				</br>
				<p>Clicking on the 'Create Default' link on the right allows you to put a value in the field for all records in the import.  Example: Storage Conditions= "-20 Ultra Freezer" </p>
				<p>For bulk registrations that are repeated you can save your mapping  as a <a href="help-content.asp?id=10#maptemplates" target="contentFrame">field mapping template</a>. </p>
				<p>Registering compounds in bulk requires two cycles through the loader file.  On the first pass unique compounds are registered and on the second pass batches are added, either to the new compounds or to compounds that have already been registered.</p>
				<p>A progress screen will appear after you have pressed 'Register'.  This tells how many records have been processed, how many duplicates have been found and how many errors.  You can leave this page and the registration job will continue on the Registration server.  Check in any time by clicking the 'Import progress' link. </p>
				<p>When the registration process has been completed, you will receive an email notification that the job is finished.  If there were errors then there will be an SD file attached to the message.</p>
				
				<h2><a  name="bulkup">Bulk Update</a></h2>
				<p>Bulk update allows you to insert or change values in records in a compound registry.  Changes to existing info in the registration database may be required but more often than this, there is new information that comes in for a batch of product.  Analysis and purification data or comments are the most common fields to update.</p>
				<p>Bulk updates are very similar to bulk registration above, first click on the update link, select a file and map the fields you want to update in the file.</p>
				<p>Updating compounds with an SD or CSV file requires a key field in order to locate the batch that is to be updated.  The key field must be unique and it must be identified at the beginning of the update process and mapped in the 'Import Field Mapping' form. </p>
				<p>Any custom field in the Registration system can be used for the key field plus the system field 'Registration ID' is also a valid choice.  A typical registration ID looks like this:  ARX-001234-01 where the three sections delimited by dashes are 1- registration number prefix, 2- registration number and 3- batch number.</p>
				<p>Field <a href="help-content.asp?id=10#maptemplates" target="contentFrame">mapping templates</a> like the ones for bulk registration are available for bulk updating.</p>
				<p>If you are updating a long text field like 'Batch Comments' the Import Field Mapping for that field will give you the option to overwrite the existing data in the field or append it.</p>
				<p>An email notification of your update is sent to the user who ran it.  If there are <a href="help-content.asp?id=10#errors" target="contentFrame">errors</a> in the update then they will be attached as an SD file.</p>
				
				<h2><a  name="maptemplates">Mapping Templates</a></h2>
				<p>If you are running multiple bulk loads or updates you can save time and avoid entry errors by creating a mapping template.  </p>
				<p>To create a template, run a bulk process, load a file and map the fields.  Before continuing to the next step click on the 'ADD TEMPLATE' button, name your template and save it. </p>
				<p>When you return with an identical load you can select that template at the top of the mapping form.  If you enter a name that already exists then the system will ask you if you want to overwrite the old template.</p>
				
				<h2><a  name="rollback">Bulk Reg Rollback</a></h2>
				<p>Bulk updates and Registration actions can be rolled back if you are not satisfied with the outcome.</p>
				<p>To roll back a load click the 'Bulk Registration Log' link and you can view the files that have been loaded in reverse chronological order.  You can roll back only batches, only compounds or both.  </p>
				<p>Note that if anyone else has made additions or changes to batches or compounds after you loaded them and you roll back the creation of those items, the changes made by others will be lost.</p>
				
				<h2><a  name="errors">Error Files</a></h2>
				<p>If an error occurs during a bulk load or update process an error file will be attached to the email notification of the job.</p>
				<p>The error file is an SDF with all of the information from the original loaded file plus some new system information about records in the load plus a column called 'Error Reason'.  With the information in the error file you can make a well-informed decision about whether to roll back your load and fix the errors or to create a small update file and fix the errors by updating records.</p>
				<p>SD files can be opened using a variety of commercially available viewers.  Chemaxon's Marvin View is a free application that displays chemical structures.  You can also view SD files as text. </p>
				
<% ElseIf id = "11" Then %>
				<h1>Admin Approval</h1>
				<p>Registration can be configured to have a designated Registrar approve all compounds registered through the user interface. </p>

				<h2><a  name="approve">Approving/Rejecting Compounds</a></h2>
				<p>To approve compounds any user with Registrar or Admin privileges clicks on 'Admin Approve' to view all compounds pending approval.  The approver checks off compounds that they have reviewed and then can approve or reject them.  Approved compounds are published to the registry, rejected ones are sent back to the registering Scientist with a note of explanation from the Registrar. </p>				
				
<% ElseIf id = "12" Then %>
				<h1>Custom Drop-downs</h1>
				<p>Administrators can create and edit Custom Drop-down lists in the Registration system.</p>

				<h2><a  name="dropdown">Creating a Custom Drop-down List</a></h2>
				<p>To create a custom drop-down list click on the 'Custom Drop-downs' link and then on the 'New Drop-down' link.  The Custom Dropdowns page lists all drop-down lists for all of your Registration pools. You can add or remove items from any dropdown list from this page by clicking on the 'edit' pencil or the delete list X.</p>
				<p></p>Before creating a <a href="help-content.asp?id=13" target="contentFrame">Custom Field</a> that will use a drop-down list be sure the drop-down list exists.  You can create new choices in the list, but when you create a new field it must be pointed to a drop-down list.  

<% ElseIf id = "13" Then %>
				<h1>Custom Fields</h1>
				<p>Registration allows you to define an unlimited number of fields to hold information about the items in your system. </p>

				<h2><a  name="cfpool">Custom Field Pool</a></h2>
				<p>There is only one group of fields in the whole registry but <a href="help-content.asp?id=14" target="contentFrame">Custom Field Groups</a> are defined to manage the data for different categories of registered items.</p>
				<p>Some custom fields will be shared by multiple field groups such as 'Notebook Page' or 'amount submitted'.  Other custom fields will only be utilized by one group like 'incubation temperature'.</p>	

				<h2><a  name="datatypes">Data Types</a></h2>
				<p>Each custom field must be assigned a data type.   Before an item is registered, the data in each field is validated to be sure it is of the correct type.</p>
					<li>Integer – A whole number.
					<li>Real Number – Any number, positive or negative, represented as an integer and/or decimal amount.
					<li>Date/Time – Just that, represented in several possible formats like 01/15/2014 16:20
					<li>Text – Any standard ASCII characters in a limited number
					<li>Long Text- Standard characters but in a longer memo type field.
					<li>Drop-Down- A field pointed at an explicitly defined drop-down list in the 'Custom Drop-Down' area. 
					<li>File- A file can be uploaded into a registered compound from your computer.  Pdf files, .jpeg, .gif and .txt files can be viewed in the registry, all file types are stored in the system and can be downloaded to your machine at any time.

				<h2><a  name="options">Field Options</a></h2>
				<p>For each field group, a separate set of options is established for each field</p>
					<li>Show for Batch/Show for Compound:  In your field group any field you want to hold information for the batch or compound level of your registered compounds should be checked here. 
					<li>Require for Batch/Compound:  Any field checked here will not be allowed to be left blank on registration. 
					<li>Show for Add Batch/Compound:  These fields will appear in the 'register compound' or 'enter batch information' forms of the registration process.
					<li>Enforce uniqueness:  If this field will be used as a unique identifier for compounds or batches then you will want to enforce uniqueness.  Fields typically set to enforce uniqueness are barcode and notebook page. 
					<li>Is Identity:  Any field group needs to have criteria explicitly set to define the characteristics that identify a unique item in the registry.  With small molecules Identity is defined by the chemical structure.  With a natural product the identity of a registered substance might depend on two fields.  An example of this might be two identity fields –Mushroom species and –Distillation temperature.  Extracts of the same species with two different distillation temperatures will receive different registration numbers.
					<li>Is Linked Field: A field that is marked as linked will be linked to another Registration ID.  Linked fields are used to document the lineage of cloned cell lines.  
			
<% ElseIf id = "14" Then %>
				<h1>Custom Field Groups</h1>
				<p>The Registration system can be configured by any Administrator to register not only small molecules but biological compounds, cell lines or any group of items  that you want to register.</p>

				<h2><a  name="fgcreate">Creating New Field Groups</a></h2>
				<p>Creating new Field Groups – The best way to create a custom field group is to first draw an outline of what information you want at what level of your registration application.  Identify what fields you want to use to define unique registration items and which fields you want to be required.</p>
				<p>Once you have an outline,  create a new Field Group by clicking on 'Group Custom Fields' and then 'New Field Group'.  </p>
					<li>Pick a name for your new group.
					<li>Set a prefix for the registration numbers that identify the new group.
					<li>Check the structure and salt boxes if you are going to use chemical structures and salts (also structures).
					<li>Check if you will allow registration of batches of your registered compounds.
					<li>Check if you will allow batches of batches.  This hierarchy allows for batches that are products of an earlier batch.  Allowing batches of batches creates an unlimited 'family tree' of your registered substances.   This feature is useful for tracking clones of cell lines or copies of DNA oligonucleotides.

				<h2><a  name="fgedit">Editing Field Groups</a></h2>
				<p>You can add fields to your new field group only by selecting them from the custom fields pool.  Building a custom field group has to happen from the ground up.  You can create and name your new field group first, but the best procedure for building a new field group is to follow the order of operations below. </p>
					<li>Outline your registration system on paper defining the compound level and batch level fields and also defining any dropdown lists you will use.
					<li>Create your custom drop-down lists
					<li>Create your custom fields
					<li>And finally, go to the 'Group Custom Fields' page and edit the custom field group with your name on it.  You can still edit the Display name and Group Prefix  and options checkboxes at this point.  When you are ready to go, click the green 'ADD FIELD' button and select the fields you want to include in your new Custom Field Group.
				<br></br>
				<p>The options of any custom field can be changed by an Administrator at any time, but the field data type can not.</p>
<% Else %>

	 <h2>Arxspan Help</h2>
	 <p>Select a help topic on the left.</p>

<% End If %>
</div>

</body></html>
<%End if%>