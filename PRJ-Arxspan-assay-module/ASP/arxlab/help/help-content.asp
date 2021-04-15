<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%'should probably add globals to this file.  Also make email addresses global configs%>
<%If session("userId") <> "" then%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>ELN Help</title>
<link href="css/styles-help.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
</head>
<body>
<div class="helpContentDiv">
<%
Dim id
id = request("id")

If id = "1" Then %>

				<h1>Notebook</h1> 
				<p>View, manage, create and share Notebook data.</p>
		
				<h2><a name="name">Notebook Name and Description</a></h2>
				<p>At the top of the page are the Notebook owner, Notebook name and Notebook description that were provided when the Notebook was created.  Clicking on the blue ' i ' information button will give more detailed info about the notebook creator and shares.</p>

				<h2><a name="table">Notebook Table of Contents</a></h2>
				<p>A list of the Experiments in the Notebook is shown. Click on an Experiment name in the list to be taken to the Experiment Summary page for that Experiment. If this Notebook has been shared with you by another user, depending on the permissions you have been given by the Notebook owner you may only see Experiments you have created or you may see all of the Notebook contents.  Page through larger lists of experiments in the table of contents using blue arrow buttons in the lower right.  Sort the list of experiments by any column in the table of contents by clicking on the column header.</p>

				<h2><a name="create">Creating Notebook Experiments</a></h2>
				<p>To create a new Experiment in this Notebook, click on the button that corresponds to the type of Experiment you would like to create. You will be taken to the Experiment Summary page for your new Experiment. New experiments can be configured to be automatically named with the Notebook name followed by a sequential integer.  If this Notebook has been shared with you by another user, depending on the permissions you have been given by the Notebook owner you may not see the Create Experiment section and buttons. This means that you do not have permissions to create new Experiments in this Notebook.</p>

				<h2><a name="sharethis">Share This Notebook</a></h2>
				<p>To share this Notebook with another user or group, click on Share This Notebook below the Create Experiment section and a form will open. Select which users and groups you would like to share this Notebook with and specify the access level you would like to allow. Only the Notebook owner has permission to share a Notebook.</p>
				<ul>
				<li>	Selecting View/Read All Contents of Notebook will allow the user or group to view the contents of this Notebook, even if the content was created by you or another user with whom you have shared this Notebook. The user will not have the ability to create new content in the Notebook with this access level.

				<li>	Selecting Write/Create Experiments in Notebook will allow the user or group to create new Experiments in this Notebook. The user will have no authority to view or modify any Experiments not created by them, but will have full access to view and modify Experiments they create.
				</ul>

				<h2><a name="sharing">Notebook Sharing Invitations</a></h2>
				<p>If you navigate to a Notebook that you have been invited to share, you will need to accept or decline the invitation before having access to the Notebook. A sharing invitation will be displayed at the top of the page. Click the Accept button to accept the invitation to share the Notebook, or click the Decline button to refuse the invitation to share the Notebook.</p>
				<p>Click the Share button to send an Invitation to the selected users. Your Invitation to share this Notebook will appear in the Invitations section of the user's Dashboard with whom you shared the Notebook, as well as in the Invitations section of the navigation bar on the left side of their Dashboard.</p>

				<p>Click the Share button to send an Invitation to the selected users. Your Invitation to share this Notebook will appear in the Invitations section of the user's Dashboard with whom you shared the Notebook, as well as in the Invitations section of the navigation bar on the left side of their Dashboard.</p>

				<h2><a name="contribute">Notebook Contributors</a></h2>
				<p>Below the Share This Notebook section and at the bottom of the Notebook Summary page, all of the users and groups who have shared access to this Notebook are shown, along with the access level they have been granted to this Notebook. Only the Notebook owner has access to this information.</p>

				<p>Users who have Invitations to share this Notebook but who have not explicitly accepted or declined access to the Notebook are displayed with a status of "pending". These users cannot create Notebook content until they have accepted your invitation to share this Notebook. View privileges are granted as soon as the Invitation is sent.</p>

				<p>Access to this Notebook can be revoked at any time by clicking the Cancel button on that sharing summary of a particular user or group. Any Notebook content that has been created by that user, or the users of that group, will remain in the Notebook, even after you have revoked their sharing privileges.</p>

				<p>You can modify any access to this Notebook by selecting a different permission set from the drop-down menu in the summary and clicking the Change button. If your invitation to share this Notebook has already been accepted, the change will apply immediately. If not, the new permissions will apply when the sharing invitation is accepted.</p>
				




<% ElseIf id = "2" Then %>

			<h1>Create Notebook</h1>
			<p>Used to create new Notebooks. Enter a Name and Description for your new Notebook and click the Create Notebook button. You will be taken to the <a href="help-content.asp?id=1">Notebook Summary</a> for your new Notebook.</p>


<% ElseIf id = "3" Then %>

				<h1>Dashboard</h1>
				<p>The dashboard provides a centralized view of recent activity in the ELN system.</p>

				<h2><a  name="recent">Recently Viewed Experiments</a></h2><p>
				A summary of your five most recently-viewed Experiments is displayed in reverse chronological order.
				</p>
				<h2><a  name="notifications">Notifications</a></h2><p>
				The Notifications panel lists recent activity taken by other users that impacts your Experiments or Notebooks. Notifications will appear for actions such as another user accepting or declining an invitation from you to share a Notebook or when a witness request for a signed Experiment is confirmed or denied. Notifications are also used to announce scheduled maintenance windows for the ELN.
				</p>
				<p>To take action on a notification, click on the underlined link text in the message.  This will take you to the page where you can perform the requested task from the notification.
				</p>
				<p>Unread notifications appear in the Notifications list with a gray background.  Holding the mouse pointer over an unread notification will clear the gray background.  The green number in the 'New Notifications! ' icon at the top of the page is the number of unread notifications in the list.</p>

				<h2><a  name="invitations">Invitations</a></h2><p>
				<p>In order to gain access to a shared Notebook or Project, you must be invited by the Notebook owner and you must accept the invitation. Invitations that you have received to share Notebooks or Projects that have not been accepted or declined are listed in the Invitations panel. Click on any item in the list to view the Invitation.  Share invitations that have not been answered will appear as 'Pending' in the notebook or project owner's management page.
				</p>
				<h2><a  name="preferences">User Preferences</a></h2><p>
				<p>Clicking on your user name at the top-right of any notebook page will let you configure your user profile.  The User Profile pane is not editable but it tells you the personal information in your profile.  To change this info contact an ELN Admin at your company or click the 'contact support' link next to your name.  The 'Notifications' pane lets you pick how you would like notifications delivered, by online notifications, email or not at all.  The 'Options' pane lets you enable the use of the Chemdraw plugin, select the number of experiments shown on a page and who you prefer as your default witness. 
				</p>

<% ElseIf id = "4" Then %>

				<h1>Experiments</h1>
				<p>View, manage, sign and witness research data. Only the creator of an Experiment is allowed to make additions or changes to any data in the Experiment, and only the creator of an Experiment is allowed to electronically Sign and/or Close the Experiment.</p>

				<p>When making changes to any data in your Experiment, be sure to click the Save button which is always on the bottom-right corner of the page. This will ensure that your changes are saved and recorded in the Experiment History.</p>

				
				<h2><a  name="name">Name and Description</a></h2>
				<p>At the top of the page is the Experiment name. The Experiment is automatically named with the Notebook name followed by a sequential number.
				<p>The experiment description field is used to enter a brief description of the experiment.  This is editable and it appears in the <a href="help-content.asp?id=1">Notebook Table of Contents</a> in the 'Name' column.</p>

				<h2><a  name="watchlist">Watchlists</a></h2>
				<p>The Dashboard page displays a Watchlist pane and you can go directly to your watchlist using the Watchlist link in the black header menu bar of the ELN.  Scientists can maintain a watchlist showing their currently active experiments, Managers can monitor activity in their group or technicians can build a queue of experiments for analysis or purification.  A watchlist has a link directly to each experiment, several columns of information about the experiment and then four icons showing recent activity in each experiment.  </p>
				<p>Add an experiment to your watchlist by clicking the grey checkmark at the top-right of any experiment.  If the check is green then this experiment is already on your watchlist.  To remove an experiment from your watchlist either click the green checkmark in the experiment or click the red X in the right column of the watchlist.</p>

				<h2><a  name="chemistry">Chemistry Experiment Reaction Section</a></h2>
				<p>In order to use all of the features of the Chemistry Experiment, you must have a licensed copy of PerkinElmer ChemDraw&trade; installed on the computer from which you access the Experiment Summary page. If PerkinElmer ChemDraw&trade; is not installed on your computer, you can upload existing files in the CDX, CDXML, MOL or SKC file format and you can view existing chemistry content, but you cannot edit existing chemical drawings in-place. If you have the ChemDraw&trade; Plugin installed but cannot edit the chemistry, your account may be set *not* to use the plugin.  Contact your local administrator or Arxspan Support to check this setting.</p>
				<p>For the Chemistry Experiment, the Reaction section serves as the Experiment Summary. The Reaction section begins with a PerkinElmer ChemDraw&trade; drawing area in which you can enter any chemical structure or reaction. You can copy and paste from another application or enter the chemical information in the same way you would normally use PerkinElmer ChemDraw&trade;. To activate the Reaction section, simply click in the drawing area with your mouse. When you are finished entering or modifying the chemical information, click the Add/Update button on the lower-right corner of the drawing pane to save your changes.</p>
				<p>When chemical data is entered into the drawing pane and saved using the Add/Update button, a stoichiometry table will automatically be created and populated in the Experiment Summary page, appearing below the chemical diagram. Chemical name, molecular formula, molecular weight and formula mass are automatically populated for each reaction component. Each component has a tab at the top of the stoichiometry table. Clicking on that tab will display the data for that reaction component.</p>

				<p>Multi-step reactions are not currently supported.</p>

				<p>Below the stoichiometry table, there is an area to enter Preparation and Reaction Conditions data, with a drop-down available for common units of measure. To add solvent information, click the Add Solvent button below the Reaction Conditions table. A solvent entry will display. To enter multiple solvents, click the Add Solvent button for each solvent and enter the relevant information.</p>
				
				<p>When you select the 'Add Reagent' choice in the 'add' tab you are presented with three ways to add a reagent: manually, by entering a Chemical Abstracts (CAS) number or by selecting a reagent from your company's reagent database.  Contact your ELN Administrator or Arxspan Support if you would like to edit or add to your reagent database.</p>

				<p>When you have completed entering or changing the information in the Experiment Summary page, click the Save button on the lower-right of the page to save your changes.</p>

				<h2><a name="biology">Biology Experiment Protocol Section</a></h2>
				<p>In the Biology Experiment, the Protocol section serves as the Experiment Summary. The Protocol section is a large free text area in which you can directly enter protocol information or into which you can copy/paste an existing protocol description from another program. When you are finished entering or modifying the protocol information, click the Save button on the lower-right corner of the Experiment page to save your changes.</p>

				<p>Below the Protocol section, there is a free text area into which an Experimental Summary can be entered.</p>

				<p>When you have completed entering or changing the information in the Experiment Summary page, click the Save button on the lower-right of the page to save your changes.</p>

				<h2><a  name="free">Concept Experiment Description Section</a></h2>
				<p>In the Concept Experiment, the Detailed Description section serves as the Experiment Summary. The Detailed Description section is a large free text area in which you can directly enter experimental write-up or into which you can copy/paste an existing summary from another program. When you are finished entering or modifying the information, click the Save button on the lower-right corner of the Experiment page to save your changes.</p>

				<h2><a  name="template">Templates</a></h2>
				<p>Templates are created by an administrator at your company and can be used in Chemistry, Biology or Concept experiments.  There is only one template set for the whole company, individuals cannot maintain their own set.  If there is a certain protocol or action that Scientists repeat often in their work then a template will be useful.  </p>
				<p>Chemistry templates can be integrated with the stoichiometry grid so that reagent weights, names, solvents and workup information can be selected from dropdown menus instead of typing them  when writing the preparation section.   Biology and Concept experiment  templates can hold drop-down menus of commonly used materials or phrases or they can paste an entire standard protocol or procedure into an experiment.</p>

				<h2><a  name="sign">Signing Experiments</a></h2>
				<p>To electronically sign your Experiment data, click the Sign button located to the left of the Save button. A dialog will appear. Enter your login and password information and select whether you want the Experiment left open for further modifications or closed and submitted for witnessing when the signing procedure is complete. If you elect to Sign and Close your Experiment, you must select an appropriate witness who will receive a witness request after you sign the Experiment. Clicking the check box and entering your password indicate that you have performed the work as described in the Experiment. Click the Sign button to complete the process.</p>
				<p>If you have left the Experiment open for further modification, it will still be editable after the signing process is complete and the Experiment History will visually indicate that the Experiment was signed. If you have closed the Experiment, it will be put in a read-only state, all of the content in the Experiment will be rendered to PDF and the final PDF will be submitted to your selected witness who can either Witness or Reject your work. Experiments that have been signed and closed can be reopened by an administrator.  A record of the reopening with the administrator's justification for the action will be stored in the history of the experiment.</p>
				<p>The ELN can be configured to sign and witness experiments using the SAFE Biopharma Universal ID software credential.  Email Support for more information.</p>

				<h2><a  name="witness">Witnessing and Rejecting Experiments</a></h2>
				<p>If you are chosen to witness an Experiment, you will receive a Notification on your Dashboard and the witness request will also appear in the left navigation bar of your workspace. Click on the Experiment name and you will be brought to the Experiment page which will display a PDF of the completed Experiment. You also have access to the Experiment History to review any file attachments not rendered into the final PDF, etc. When you have reviewed the Experiment, scroll to the bottom of the page and click the Witness or the Reject button.<p>

				<p>When you witness an Experiment, a dialog box will appear. Enter your login and password information. Entering your password and clicking the check box indicates that you have reviewed the work in the Experiment. Click the Witness button. A dialog box will confirm that you have successfully witnessed the Experiment. When the dialog is dismissed, you will be taken to the Dashboard page.</p>

				<p>When you reject an Experiment, a dialog box will appear. You must enter a reason for rejecting the work as described. The reason for rejection will be entered into the Experiment History as a new Note and will be viewable by the owner of the Experiment. Click the Reject button. A dialog box will confirm that your rejection of the Experiment has been processed.</p>

				<h2><a  name="history">Experiment History</a></h2>
				<p>In the left navigation pane of the Experiment Summary page, you will see a section titled History. This History shows the audit trail of the Experiment. Specifically, a complete Version Control history of each Experiment that allows you to navigate back through each save point in the lifetime of the Experiment. There are several different icons to indicate the action that was taken at each save point, as follows:</p>
				<ul>
				<li>	The atom icon indicates the creation of the Experiment. When you create a new Experiment from your <link>Notebook Summary<link> page, the new experiment is automatically named and saved in the Created state. Edits you make after creating the Experiment take place in the first revision of the Experiment history.

				<li>	The floppy disk icon indicates that the Experiment was saved. A new entry is made in the History each time you click the Save button on the Experiment Summary, Attachments Table or Notes Table. The status of the Experiment is shown in the Notebook Summary as Saved.

				<li>	The green single check mark icon indicates that the Experiment was electronically signed. A new entry is made in the History each time you click the Sign button on the Experiment Summary, Attachments Table or Notes Table. If the Experiment is left open after signing, its status in the Notebook Summary is shown as Signed - Open. If the Experiment is closed, its status in the Notebook Summary is shown as Signed - Closed and it is rendered to PDF and submitted for witnessing. You always have access to Closed Experiments.

				<li>	The green double check mark icon indicates that the Experiment was electronically signed and witnessed by another person on your team. A new entry is made in the History when your Experiment is witnessed and its status in the Notebook Summary is shown as Witnessed. The Experiment, along with a PDF rendering of it, is stored in Arxspan's long term archive. You always have access to witnessed Experiments, but a witnessed Experiment cannot be edited.

				<li>	The letter X icon indicates that your selected witness has rejected your signed and closed Experiment. When your Experiment is rejected, the witness must enter a Note explaining why the Experiment was rejected. Its status in the Notebook Summary is shown as Rejected and the Experiment is automatically re-opened and put into an editable state so that you can resolve any issues with it.
				

				</ul>
				<p>Clicking on any point in the History will display the complete state of the Experiment at the time it was saved, including any file Attachments and Notes. The point in the History that you are viewing is shown in bold face type for easy identification. Except when viewing the Current point in the History of an open Experiment, the Experiment contents will be displayed in a read-only state and cannot be edited.</p>

				<p>To make a specific point in an Experiment's history editable you must create a copy of the Experiment at that time point. Click the Copy button at the bottom of the Experiment to make a copy of the Experiment at that time. A dialog box will be shown. Select the Notebook in which you want the new Experiment to be created and click the Copy button. You will be taken to the new Experiment, which will contain a copy of all of the data the History entry from which you made the copy.</p>


<% ElseIf id = "5" Then %>

				<h1>File Attachments</h1>

				<h2><a  name="adding">Adding Files to an Experiment</a></h2>
				<p>To add a file attachment to your Experiment, click on the Add File button at the top of the Experiment Summary. A dialog box will appear. Browse for the file on your computer or network using the Browse button. Optionally enter a label for the file in the Name field and a detailed Description. You will be able to change any of this information after the file is added. Click the Upload button and the file will be uploaded to your Experiment. This can take several minutes for large files. When the upload is complete, you will be brought to the Attachments Table for this Experiment. Click the Save button at the bottom of the Attachments Table to save your changes.</p>
				<p>Clicking the 'Upload Multiple' link in the upper right corner of the add file dialog will let you browse to a location on your file system and select multiple files.  To select multiple files hold down the control key and select each file.</p>

				<h2><a  name="managing">Managing Files in an Experiment</a></h2>
				<p>Files can be modified or removed from an experiment at any time from within the Attachments Table section of the Experiment Summary page. The Attachments Table displays a list of all of the files added to this Experiment. To remove a file, click the Remove button next to the file and it will be removed from the list.
				</p><p>
				To view a file in the Attachments Table, click on the file description in the Attachments Table. If the original file is a supported file type (Microsoft Word, Microsoft Excel, Microsoft PowerPoint, PDF and most image formats), a PDF of the original file will appear below the file name in the Attachments Table, allowing you to view the contents of the file within the ELN environment. If the original is not a supported file type, you will be asked to download the original file data to view on your desktop.
				</p><p>
				To download the original source file that you attached to your Experiment, click the Download button to the right of the file name. The original file data will be downloaded to your computer to view and modify on your desktop.
				</p><p>
				To update an existing file attached to your Experiment, download the original file from the Attachments Table and save it on your computer. Make the necessary modifications to the file on your computer. When your changes are complete and you are ready to update the file, click on the Replace button next to the file you wish to update. A dialog box will appear. Click the Browse button and locate the updated file on your machine. Click the Upload button and the modified file will replace the old version in your Experiment. Click the Save button at the bottom of the Attachments Table to save your changes. Use the Experiment History to access earlier revisions of files you have replaced.
				</p>

<% ElseIf id = "6" Then %>

				<h1>Experimental Notes</h1>

				<h2><a name="adding">Adding Notes to Experiments</a></h2>
				<p>To add a note attachment to your Experiment, click on the Add Note button at the top of the Experiment Summary. A dialog box will appear. Enter a label for the note in the Name field and the full text of your note in the Note field. You will be able to change any of this information after the note is added. Click the Add button and the note will be added to your Experiment. When the process is complete, you will be brought to the Notes Table for this Experiment. Click the Save button at the bottom of the Notes Table to save your changes.
				</p>

				<h2><a  name="managing">Managing Notes in an Experiment</a></h2>

				<p>Notes can be modified or removed from an experiment at any time from within the Notes Table section of the Experiment Summary page. The Notes Table displays a list of all of the Notes added to this Experiment. To remove a Note, click the Remove button next to the Note and it will be removed from the list. Notes from the Rejection of a witness request cannot be deleted or changed.
				</p><p>
				To see the details of an individual Note, or to make changes to a Note, click on the Note in the Notes Table. The Note will expand to show the details including the name and description of the Note. To Close the Note without making changes, click the Close button at the bottom of the Note description. To save changes, click the Save button at the bottom of the Note description.
				</p>

<% ElseIf id = "7" Then %>



				<h1 a name="profile">User Profile</a></h1>
				<p>To view your user profile, click on your name in the top-right corner of the screen, or in the Administration section of the left navigation panel. To change your password, enter your current password and your new password twice for confirmation then click the Change Password button. Passwords must contain at least six characters, one upper-case letter and one number or symbol.
				</p>

<% ElseIf id = "8" Then %>

			<h1>Create Project</h1>
			<p>Projects are used to track and share activity in a set of Notebooks and/or Experiments from a centralized location. Enter a Name and Description for your new Project and click the Create Project button. You will be taken to the <a href="help-content.asp?id=9">Project Summary</a> for your new Project.</p>

<% ElseIf id = "9" Then %>

				<h1>Project</h1> 
				<p>View, manage, create and share Notebook data.</p>
		
				<h2><a name="create">Create Project</a></h2>
			    <p>Projects are used to track and share activity in a set of Notebooks and/or Experiments from a centralized location. Enter a Name and Description for your new Project and click the Create Project button. You will be taken to the <a href="help-content.asp?id=9">Project Summary</a> for your new Project.</p>
				
				<h2><a name="name">Project Name and Description</a></h2>
				<p>At the top of the page is the Project owner, Project name and Project description that were provided when the Project was created.</p>

				<h2><a name="sections">Project Sections</a></h2>
				<p>Projects can be broken into different sections, which are displayed as Tabs in the Project page. If you have been granted read/write privileges to the project then you can add a new section.  To add a new section, click 'Add Tab' at the top of the page, to the right of any existing tabs. Enter the name of the new tab in the dialog box and click OK. The new tab is displayed to the right of any existing tabs.  If there are sections defined for a project, new content must be added to a section, it cannot be added to the root project.</p>

				<h2><a name="add-content">Adding Content to a Project</a></h2>
				<p>Projects can be used to track activity in Notebooks or individual Experiments. To add content to a Project, navigate to the Notebook or Experiment that you want to track in the Project, and click the Copy button (two-sheets-of-paper icon) in the upper-right corner of the page. Then navigate to the Project you want to add the content to, and select the Tab to which you want to add the content. By default the leftmost project section will be selected. Click the Paste button (clipboard) in the upper-right corner of the page. The copied content will be added to the Project.</p>

				<h2><a name="remove-content">Removing Content from a Project</a></h2>
				<p>To remove a Notebook from a Project, click the Delete button next to the Notebook name on the Project page. The Notebook will not be deleted from the system, just removed from the Project. To remove an Experiment from a Project, click the red delete button to the right of the Experiment you would like to delete from the project. The Experiment will be removed from the Project, and not deleted from its Notebook.</p>

				<h2><a name="sharing">Project Sharing Invitations</a></h2>
				<p>If you navigate to a Project that you have been invited to share, you will need to accept or decline the invitation before having access to the Project. A sharing invitation will be displayed at the top of the page. Click the Accept button to accept the invitation to share the Project, or click the Decline button to refuse the invitation to share the Project.</p>

				<h2><a name="sharethis">Share This Project</a></h2>
				<p>To share this Project with another user or group, click on Share This Project and a form will open. Select which users and groups you would like to share this Project with. Projects can only be shared with View permissions. To allow a user to contribute content, share the relevant Notebooks with them. Only the Project owner has permission to share a Project.</p>
				<p>Click the Share button to send an Invitation to the selected users. Your Invitation to share this Project will appear in the Invitations section of the user's Dashboard with whom you shared the Project, as well as in the Invitations section of the navigation bar on the left side of their Dashboard.</p>
				
				<h2><a name="contributors">Project Team</a></h2>
				<p>Below the Share This Project section and at the bottom of the Project Summary page, all of the users and groups who have shared access to this Project are shown, along with the access level they have been granted to this Project. Only the Project owner has access to this information.</p>

				<p>Users who have Invitations to share this Project but who have not explicitly accepted or declined access to the Project are displayed with a status of "pending". View priveliges are granted as soon as the Invitation is sent.</p>

				<p>Access to this Project can be revoked at any time by clicking the Cancel button on the sharing summary of a particular user or group.</p>
				</p>

<% ElseIf id = "10" Then %>

				<h1>Search</h1> 

				<h2><a name="search-types">Searching in the ELN</a></h2>
				<p>There are three ways to search in the ELN. All searches will return results for all content in Projects, Notebooks and Experiments that you have read access to.</p>
				<ul>
				<li>	<strong>Text Search</strong> - Type your query into the Search box at the top-left of the ELN menu bar and click the Search button or hit the Enter key. Search results will be displayed. Experiments to which you do not have read access will not be shown in search results.</li>
				<li>	<strong>Advanced Search</strong> - Click on the advanced search link under ELN Tools then open the query builder by clicking on the green '+' sign in the search window.  Select search criteria from the drop-down menus in the query builder, adding criteria by clicking green '+' signs and removing them with the '-' sign.  After performing an advanced search, your query will be remembered and will return when you click 'Advanced Search' again.  Advanced search can search for a list of text criteria.  To search for multiple strings select 'in list' from the second drop-down window and then enter a comma-separated list of text strings for the search.  (e.g. Reg IDs or Scientist names)</li>
				<li>	<strong>Chemical Search</strong> - Click on Chemical Search under the Tools header in the left menu bar. Enter your search query; PerkinElmer ChemDraw&trade; is not required for Chemical Search. Specify the search type: substructure, exact or similarity as well as results per page and sorting options. Click the Search button. Search results will be displayed. Experiments to which you do not have read access will not be shown in search results.</li>
				</ul>

<% ElseIf id = "11" Then %>

				<h1>System Administration</h1>
				<p>System administrators have access to the Manage Users, Manage Groups, and Backup pages which provide administrative functions for the ELN environment.</p>

				<h2><a  name="roles">User Roles in the ELN</a></h2>
				<p>Each user account in the ELN must be assigned a Role. There are several predefined Roles in the ELN, as follows:</p>

				<ul>
				<li>	Admin - System administrator role; admins have unrestricted access to the ELN.

				<li>	Group Manager - Group Managers (typically a Principal Investigator or other Research Manager) has the ability to create and modify user accounts within their own group, and is granted irrevocable read access to all Notebooks created by users within their group.

				<li>	Group Manager Assistant - A Group Manager can assign this role to another user within their group. Group Manager Assistants can create and modify user accounts within their group. Group Manager Assistants do not have access to the Group Manager account, nor do they have read access to Notebooks in the group unless the Notebook has been shared with the Group Manager Assistant by the owner of the Notebook.

				<li>	Create and Share Notebooks, Create Experiments, Witness - This role grants unrestricted access to create and share content within the ELN, as well as to witness the work of other users.

				<li>	Create Notebooks, Create Experiments, Witness - This role grants unrestricted access to create content within the ELN, as well as to witness the work of other users. Users with this role cannot share content with other users.

				<li>	Create Experiments, Witness - These users can witness the work of others, and can create content only in Notebooks that have been shared with Write priveliges by another user.

				<li>	Witness - Grants only permission to witness the work of other users.
				</ul>

				<h2><a  name="manage-users">Managing User Accounts</a></h2>

				<p>To manage user accounts, click on the Manage Users link in the left tool bar under Administration. You can search for a specific user account using the search tool at the top of the page, or add a new user account using the Add a New User link at the top of the page.</p>

				<p>A summary of each current user account is displayed in the table. To reset a user&#39;s password, click the Reset Password link and enter the new password in duplicate, then click the Reset Password button.</p>

				<p>Password Policy: ELN passwords must be at least six characters in length and contain at least one uppercase letter, one lowercase letter and one number.</p>

				<p>To add or modify a user account, populate the user profile fields. Field definitions follow: (an asterisk(*) indicates a required field) <p>
				<ul>
				<li>	First Name* - The user&#39;s given name.

				<li>	Last Name* - The user&#39;s surname.

				<li>	Email* - The user&#39;s email address. This will also be the user&#39;s login name.

				<li>	Title - The user&#39;s title.

				<li>	Address - The user&#39;s street address.

				<li>	City - The user&#39;s city.

				<li>	State - The user&#39;s state.

				<li>	Zip - The user&#39;s postal code.

				<li>	Country - The user&#39;s country.

				<li>	Role* - The user&#39;s role. See <a href="#roles">Roles</a> for additional information about predefined system roles.

				<li>	Groups - The user groups to which this user has access.

				<li>	Enabled* - Controls the active state of the account.

				<li>	Manager - The user&#39;s manager.

				<li>	Can Lead Projects - Controls the user&#39;s ability to create Projects in the system.

				<li>	Can Delete - Determines whether the user can delete their own projects.

				<li>	Can View Siblings - Lets the user view the work of other users with the same Manager.

				<li>	Use ChemDraw - Enables the user to enter/edit structures in a chemistry experiment.  If this is set to &#39;no&#39; structures are displayed as .gif pictures

				<li>	Soft Token - Set to &#39;yes&#39; the user can sign and witness experiments with the SAFE BioPharma signature credential.

				</ul>

				<h2><a  name="manage-groups">Managing User Groups</a></h2>
				<p>To manage user groups, click on the Manage Groups link in the left tool bar under ELN Administration. You can search for a specific group using the search tool at the top of the page, or add a new group using the Add a New Group link at the top of the page.</p>

				<p>User groups provide a way to easily manage Notebook and Project sharing and access permissions. A summary of each group is displayed in the table.</p>

				<p>When adding a group you must provide a group name. Add and remove users from the group as needed.<p>

				<p>Auto Share Groups automatically shares notebooks and projects of one group with another group.  Example: A member of the JP-CRO group creates an experiment and read access to that experiment is automatically given to members of the US-CRO-admin group.</p>

				<h2><a  name="backup">System Backups</a></h2>
				<p>To back up data in the ELN, click on the Backup link in the left tool bar under ELN Administration. The system caches the date and time of your most recent backup and only makes data created after that time available for backup. To reset the backup timer, please email <a href="mailto:support@arxspan.com">support@arxspan.com</a> and request that all data be made available for backup.</p>
				<p>Backups can be generated on a per-notebook basis. Search for the Notebook you would like to back up, or click the Get Experiments button to see all of the notebooks available for backup and select from a list.</p>
				<p>Click the Export button and a backup file will be generated for download to your system. A dialog will pop up on your screen when the backup file is ready for download.</p>

<% Else %>

	 <h2>Arxspan Help</h2>
	 <p>Select a help topic on the left.</p>

<% End If %>
</div>

</body></html>
<%End if%>