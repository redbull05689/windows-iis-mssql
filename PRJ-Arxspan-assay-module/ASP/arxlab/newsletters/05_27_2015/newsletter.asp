	<%regEnabled=true%>
	<%
		sectionID = "tool"
		subSectionID="dashboard"
		terSectionID=""

		pageTitle = "ArxLab Newsletter"
		metaD=""
		metaKey=""

	%>
	<!-- #include file="../../_inclds/globals.asp"-->
	<!-- #include file="../../_inclds/header-tool.asp"-->
	<!-- #include file="../../_inclds/nav_tool.asp"-->
	
<div class=WordSection1>
<style type="text/css">
h1{
font-size:26px!important;
margin-bottom:20px;
}
h2{
	padding-top:10px;
	padding-bottom:10px;
}
image p{
	padding-top:5px;
	padding-bottom:5px;
}
.underline{
	text-decoration:underline;
	padding-top:5px;
	padding-bottom:5px;
}
.listChecks li{
	list-style-image:url("data:image/gif;base64,R0lGODlhCgAKAJEAAAAAAP///////wAAACH5BAEAAAIALAAAAAAKAAoAAAISlG8AeMq5nnsiSlsjzmpzmj0FADs=");
}
</style>
<h1>Newsletter Five</h1>


<h2 id="feature">Feature of the Month</h2>

<p class="underline">Live editing of documents in ArxLab Notebook</p>
<p>Arxspan has introduced an in-line editor in ArxLab Notebook whereby live edits can be made to any document, including Excel, Word, image and text files, and analysis files such as TIBCO Spotfire, Geneious, GraphPad Prism, etc.  Any file that can be double-clicked and that is recognized and opened within your operating system can be edited live in the ArxLab Notebook.  </p>

<p>Please contact ArxLab Support for information on activating Live Editing.</p>

<p class="underline">Live Editing Screenshot</p>

<img src="images/image001.png" width="700">

<br/>

<p class="underline">Watch a video of live editing of attached files here:</p>

<iframe width="630" height="463" src="//www.youtube.com/embed/ibOjPTjNlT4" frameborder="0" allowfullscreen></iframe>

<h2 id="latest_news">Latest News</h2>

<p class="underline">CRAIS Checker: Functionality for regulatory checks on chemical compounds in ArxLab Notebook</p>

<p>Arxspan has collaborated with Patcore to provide integration with CRAIS Checker as part of ArxLab Notebook.  CRAIS Checker is a system that checks whether a chemical compound, based upon its structure, falls under any law, regulation, or ordinance internationally, including the United States, Europe, and Japan.  CRAIS Checker has a large and growing compound regulatory database which makes management of global compliance laws manageable.  Once the "CRAIS Check" button underneath the reaction scheme is pressed, regulations governing compounds appear within the Quick View box of the stoichiometry table, enabling appropriate management of compounds in your organization.</p>

<p>CRAIS Checker organizes regulations governing:</p>
<ul>
<li>Drugs/Medication</li>
<li>Toxic, deleterious and dangerous substances</li>
<li>Security</li>
<li>Safety and health</li>
<li>Environment Protection</li>
</ul>

<p>It includes the following international convention and regulations:</p>
<ul>
<li>Rotterdam Convention on the Prior Informed Consent Procedure for Certain Hazardous Chemicals and Pesticides in International Trade (PIC)</li>
<li>Montreal Protocol on Substances that Deplete the Ozone Layer</li>
<li>United Nations Recommendations on the Transport of Dangerous Goods</li>
<li>US Controlled Substance Act Schedule I-V</li>
</ul>

<p>Please contact ArxLab Support for information on activating CRAIS Checker.</p>

<p class="underline">CRAIS Checker Screen Shot</p>

<img src="images/image003.png" width="700">


<h2 id="recent_enhancements">Recent Enhancements</h2>

<ol>
<li>Synthesis mapping: An optional new module available that tracks compounds produced in one experiment that are subsequently used as reaction components in another experiment, producing a tree that traces a specific chemical compound through multiple experiments.</li>

<li>Inventory container integration with ArxLab Notebook: It is now possible to create a link in your Experiment that references a container in Inventory.  In the Inventory audit trail there is a link leading you to any Experiment where the substance in that container was used.</li>

<li>ArxLab Chinese localization: Arxspan has released a Chinese localization of ArxLab Notebook.  If your browser’s preferred language is set to Chinese, this will take effect automatically when implemented.</li>

<li>Assay field groups: It is now possible to insert a field group into an Assay upload template in order to customize presentation of data in an Assay result set.  The field group allows users to select noncontiguous data columns and arrange them side by side within the result set, enabling better representation of data for the user.</li>

<li>Permissions and bulk importing in inventory: Arxspan has added the ability to create groups with customizable usage permissions.  When an organization has multiple research groups with inventories that are separate, an administrator can now restrict read and write access to users within each group, or users on a case-by-case basis.  Arxspan has also added the ability to bulk upload samples to Inventory from an Excel spreadsheet.</li>
</ol>

<h2 id="upcoming_enhancements">Upcoming Enhancements</h2>

<ol>
<li>ArxLab FT: ArxLab Filter and Transform (FT) is a decision support tool with cross-product searching. It is a module of the ArxLab platform that provides a means for searching data from the ArxLab Registration, Assay, and Inventory modules.  ArxLab FT allows users to perform real-time searching and sorting of compound, material, assay, and inventory data, and to customize the layout of these results. Within the tool, users have the option to save search and filter parameters, perform basic mathematical calculations, create customizable graphs, export tables to Microsoft Excel, and more.</li>

<li>Plate-based workflows: We will be introducing an end-to-end workflow for plate-based studies.  This will include full life cycle management of plates in the Inventory module, as well as cherry picking, heat-mapping, hit list management, curve analysis and results publishing in the Assay module.  These will be configurable to work in tandem across both products, or on a standalone basis.</li>

<li>Registration integration with Inventory: A link in the details page for a substance in Registration will take you to the container in its location in Inventory.  At the same time, a link in the Inventory container takes you to the compound’s Registration information.</li>

<li>Molecular biology viewing and editing tool: A tool for viewing and editing linear and circular gene sequences live in ArxLab Notebook.  The tool will allow users to upload files and view gene sequences for many purposes including cloning, PCR, genome editing, and mutagenesis.</li>

<li>Improved assay search tool: Allowing users to search and sort assay results, and to customize the layout of these results.</li>

</ol>

<h2 id="tips_and_tricks">Tips &amp; Tricks</h2>

<p>Browsing in the Notebooks and Projects Table of Contents</p>

There are two different kinds of generic searches available over the content of ArxLab Notebook.

<ol>
<li>The generic search window in the upper left corner of the ELN searches data in experiment titles, experiment free text boxes, and attached files in experiments.  For example, searching for the word "goat" will find experiments with "goat" in their name or description, experiments with "goat" in their free text content, or any occurrence of "goat" in attached data files such as PDF documents, Excel spreadsheets, or instrument output files.</li>
</ol>
<img src="images/image005.png" width="700">
<ol start="2">
<li>Using the search window from a Notebooks or Projects Table of Contents will search only the titles and descriptions of those collections.  This is effectively searching the ‘Table of Contents’ of your notebooks or projects rather than the content itself.  </li>
</ol>
<p>When searching for a keyword such as "Goat" in the Notebooks Table of Contents, results are returned, showing the word "Goat" located in notebook names and descriptions:</p>
<img src="images/image007.png" width="700">

<p>Similarly, when searching for a keyword such as "Goat" in the Projects Table of Contents, results are returned showing the word "Goat" located in project names and descriptions.</p>
<img src="images/image009.png" width="700">

<ul class="listChecks">
<li>Use the generic search at the top of the ELN if you are looking for a specific term, phrase, or result.  This will yield comprehensive search results of what you are looking for.</li>
<li>Use the Notebook or Project search for browsing one user’s work or a specific project.  This will yield targeted search results that direct you to the appropriate Notebooks or Projects for more information</li>
</ul>

<p>To open the Notebook or Projects pages, click on the "Notebooks" or "Projects" links in the top navigation bar of the ELN dashboard:</p>
<img src="images/image011.png" width="700">

<p>Or click on the green "View All" buttons at the bottom of the Notebooks or Projects section in the left hand ELN window:</p>
<img src="images/image013.png" width="700">

<p>Within the Notebooks Table of Contents, you also have the ability to sort on the Name, Description, Creator, or Last Viewed date stamp of a Notebook.  You can sort the Notebook list by clicking on the header of the list to sort by that column:</p>
<img src="images/image015.png" width="700">


<p>Similarly, within the Projects Table of Contents, you also have the ability to sort on the Name, Description, Creator, or Last Viewed date stamp of a Project.  You can sort the Project list by clicking on the header of the list to sort by that column:</p>
<img src="images/image017.png" width="700">

</div>

<!-- #include file="../../_inclds/footer-tool.asp"-->