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
.pageContent .newsletterSectionHeader {
    font-family: Lato, Arial, Helvetica;
    font-weight: 300;
    padding-top: 20px;
    font-size: 33px!important;
}

.pageContent .WordSection1 p {
    font-size: 14px;
    max-width: 765px;
    padding-left: 23px;
    padding-top: 0!important;
    text-align: justify;
}

.pageContent .WordSection1 li {
	font-size: 14px;
	text-align: justify;
}

td.pageContentTD {
    background-color: white;
}

.pageContent .WordSection1 p.underline {
    padding-right: 10px;
    padding-left: 10px;
    margin-left: 6px;
    display: inline-block;
    border-bottom: 1px solid gainsboro;
    margin-bottom: 0;
}

.pageContent .WordSection1 p.readMoreLinkContainer {
    padding-left: 0;
    margin-top: 14px;
}

.pageContent .WordSection1 p.readMoreLinkContainer a {
    text-decoration: none;
    padding: 6px 14px;
    border: 1px solid gainsboro;
    font-weight: 300;
    font-size: 18px;
    display: inline-block;
    color: #343434;
    -webkit-transition: background-color 80ms linear, border-color 80ms linear, color 80ms linear;
    -moz-transition: background-color 80ms linear, border-color 80ms linear, color 80ms linear;
    -o-transition: background-color 80ms linear, border-color 80ms linear, color 80ms linear;
    -ms-transition: background-color 80ms linear, border-color 80ms linear, color 80ms linear;
    transition: background-color 80ms linear, border-color 80ms linear, color 80ms linear;
    background: transparent;
    border: 1px solid rgb(164, 164, 164);
    border-radius: 4px;
    -webkit-border-radius: 4px;
    margin-top: 3px;
    margin-bottom: 5px;
}

.pageContent .WordSection1 p.readMoreLinkContainer a:hover, .pageContent .WordSection1 p.readMoreLinkContainer a:focus {
    background: #29C0C0;
    border-color: #29C0C0;
    color: white;
    outline: none;
}

.twoUpTipsTricksRow {
    margin-top: 38px;
    margin-bottom: 0px;
}
.pageContent .WordSection1 p.imageDescription {
    border-left: 3px solid #00B2BA;
    padding-left: 12px;
    max-width: 100%;
}

div.WordSection1 img {
    margin-bottom: 8px;
    max-width: 758px;
    padding-top: 18px;
    padding-bottom: 18px;
}
.WordSection1 {
    width: 795px;
}
</style>
<h1 class="newsletterSectionHeader">ArxLab Newsletter - May 2016</h1>
<h2 id="feature" class="underline">Feature of the Month: Barcode Selector</h2>

<p>ArxLab Notebook is fully integrated with ArxLab Inventory, allowing users to link Inventory containers to experiments using the new Barcode Selector.  From inside an experiment, users can scan or enter barcodes for existing containers, creating a link between the experiment and the container in Inventory. The barcode selector comes up when one clicks on the barcode icon in an experiment, either in the stoichiometry table of a chemistry experiment or in the Inventory bar of a Biology experiment.  We show the chemistry experiment route below.</p>

<img src="images/image1.png" alt="">

<p>After clicking the barcode icon, one will be presented with the barcode chooser.  Scan the representative barcode(s) of containers into the chooser and the items will be listed for approval and prompt the user to enter the amounts of material used.  In chemistry experiments, each item will need to be designated as a reactant, reagent, solvent, or product.  Note that if one is typing or pasting barcodes into the entry window of the chooser, one has to hit the “ENTER” key in order to submit the barcode.  This is the equivalent of a quick scan or pulling the trigger on a hand-held barcode scanner.</p>

<img src="images/image2.png" alt="">

<p>Once this is done, click “Add to Experiment” and the components of the reaction will be drawn in the reaction scheme of the experiment.</p>

<img src="images/image3.png" alt="">

<h2 id="latest_news" class="underline">Latest News: Table Tool in Protocol and Summary Sections of Experiment</h2>

<p>The free text sections of experiments now feature a table editor.  Clicking on the table button to create a new table gives one the ability to set the number of rows and columns, as well as the header and title of the table.</p>

<img src="images/image4.png" alt="">

<img src="images/image5.png" alt="">

<p>A table object can also be created by copying cells from an existing spreadsheet or table and pasting them into the Summary or Protocol sections of one's experiment.  When one pastes table data, the ELN recognizes it as such and creates a table to hold the data.  After pasting data into a table, the properties of the table can be adjusted as if one were in Excel or Word.  Right-clicking in a table brings up the table editing context menu.  From here one can add rows/columns/cells, adjust table size and column and row dimensions, etc.</p>

<img src="images/image6.png" alt="">

<p>The table editor is designed to give easy access to simple tables.  Scientists looking for the full functionality of a spreadsheet program should edit their data in that program and then add the file to the attachments table of an experiment.</p>

<h2 id="recent_enhancements" class="underline">Recent Enhancements</h2>
<h2>Advanced Decision Support and Reporting for Inventory</h2>

<p>Decision support and reporting capability in ArxLab Inventory has been improved, with real-time searching and sorting of all Inventory data as well as customized layout of search results.  Within the search tool, ArxLab Inventory users can search and filter parameters; search materials on hand by chemical structure, name, or quantity; find storage locations of containers in their lab, generate safety reports, export tables to Microsoft Excel, and more.</p>

<img src="images/image7.png" alt="">

<h2>Antibody-Drug Conjugate (ADC) Registration</h2>

<p>Biological registration can be difficult because many biological molecules are large complexes of multiple subunits, with some subunits being biological in nature and some being chemical in nature. This makes it difficult to create a page that effectively describes the complex as well as the individual subunits. ArxLab Registration provides live links in its pages, allowing one Registration page to be connected to one, two, or many additional Registration pages. This functionality is useful for registering complexes such as antibody-drug conjugates (ADCs). ADC registration within ArxLab consists of a master registration page for the ADC that contains links to three separate Registration pages: an antibody, a small molecule drug compound, and a small molecule linker compound. Users have the ability to populate the biological (antibody) registration page with biology-centric information, such as amino acid sequence, specificity, immunogen, etc.:</p>

<img src="images/image8.png" alt="">

<p>Users also have the ability to populate the chemical (drug and linker compounds) Registration pages with chemistry-centric information, such as formula, molecular weight, and SMILES string. The registered ADC compound can be established as unique based upon the identities of these three component subunits, and more descriptive information on the ADC can be entered into its main Registration page.</p>

<h2>FT Form View</h2>

<p>The Form View functionality within ArxLab Filter and Transform (FT) allows users to view a report of all information available for a registered item, such as a drug candidate, cell line, or animal. FT Form View compiles a summary of information from (1) ArxLab Registration for chemistry and biology, (2) ArxLab Assay Registration, and (3) ArxLab Inventory. FT Form View allows scientists to expand each Registration ID in a search result into a group of three tables. This layout lets the user view physical information about the registered item, a summary of assay data associated with this item, and inventory information about the location and status of the material itself. Clicking on links in the form tables will take you to the item that you want to investigate further, whether it is the Registration ID, the Assay result set, or the Inventory container.</p>

<p>For a single Registration ID, FT Form View can be accessed by clicking on the Form View button above the FT search result (“A” below) or by clicking on the Form View icon to the right of the Registration ID in the FT search result (see “B” below).</p>

<p>For multiple Registration IDs, the Form View button will build tables for all of the Registration IDs in the FT search result.  For many Registration IDs, Form View will return an extensive amount of information - perhaps more information than is useful.  Arxspan recommends the use of Form View for one to five Registration IDs at a time.</p>

<img src="images/image9.png" alt="">

<p>Pictured here are the Assays result table and the top of the Containers results table for a Cell Line with a Registration ID of CL-0045 (from the FT search result above):</p>

<img src="images/image10.png" alt="">

<h2>File Search Function in ArxLab Notebook</h2>

<p>ArxLab Notebook supports rapid searching of files stored in experiments. Experiment files are indexed and searchable by text in the file, filename, chemical structure, and upload date.</p>

<img src="images/image11.png" alt="">

<p>Search results contain a link that takes you to each file in its respective experiment, and each file can be selected and downloaded to one's computer. If one selects multiple files for download, ArxLab Notebook will package them together in a single compressed folder for the user. A representative search result is shown below:</p>

<img src="images/image12.png" alt="">

<h2>ArxDraw for Molecular Biology</h2>

<p>ArxDraw for Molecular Biology is a tool allowing molecular biologists to create, visualize, and share nucleotide sequence files for the purposes of cloning, PCR, sequencing, mutagenesis studies, and more. ArxDraw users now have the capability to create DNA sequence files from scratch or to import files from GenBank and other sources. Sequences can be viewed in linear and plasmid form, with full feature representation and a map of restriction sites. DNA can be searched, open reading frames identified, and primers identified and annotated. Plasmids can be exported as an image and linear sequences can be exported in GenBank format. The ArxDraw module is a part of the ArxLab platform and integrates with ArxLab Notebook, allowing molecular biologists to seamlessly document their work in relevant biology experiments.</p>

<img src="images/image13.png" alt="">

<h2 id="upcoming_enhancements" class="underline">Upcoming Enhancements</h2>

<h2>Plate-Based Workflows</h2>

<p>During 2016, Arxspan will be introducing end-to-end plate based workflows that span all of our modules. The first of these will support plate-based parallel synthesis in ArxLab Notebook (See screenshot below) and the upload as well as automatic analysis of plate-based assay data in ArxLab Assay.</p>

<img src="images/image14.png" alt="">

<p>In Assay, raw data will be able to be uploaded and automatically processed, a feature that will not be enabled by default, as it requires configuration. In order to have this feature activated, please contact <a href="mailto:support@arxspan.com">support@arxspan.com</a>.</p>

<h2>Table View in Assay Result Set</h2>

<p>In ArxLab Assay, data contained within a result set is presented in a vertical fashion, with each new data field being displayed underneath the previous data field, as represented in the diagram below. By selecting the “Show Table” link (see “A” below) in the result set, the vertical representation of data fields changes to a horizontal table view.</p>

<img src="images/image15.png" alt="">

<p>The diagram below shows the same information as above represented in table view:</p>

<img src="images/image16.png" alt="">

<h2>Representation of Multiple Values in One Field in a Registration Object</h2>

<p>Within ArxLab Registration, it is now possible to enter multiple values into a particular Registration custom field and have these values represented in a comma delimited format in search results within FT. Within Registration, separate custom fields can be created for inputting multiple text, integer, and real number values. Users can enter multiple text or numerical values into fields in a line delimited format:</p>

<img src="images/image17.png" alt="">

<p>Upon conducting a search in ArxLab FT, Registration IDs containing these fields will appear in an FT search result, with the multiple values being displayed in comma delimited format:</p>

<img src="images/image18.png" alt="">

<p>Representation of multiple values in a custom field allows for grouping of such things as multiple samples or assay values that are necessary for association with a given Registration ID.</p>

<h2>ArxCal Module for Resource Scheduling</h2>

<p>The ArxCal asset-management system lets operations personnel set up a scheduling calendar for shared resources in a facility. Assets that need scheduling could be instruments for analysis, such as Mass-Spec, NMR, or FACS machines, or production equipment like incubators, fermenting columns, or reaction vessels. To onboard an item to the ArxCal system, an Administrator places the equipment into a location in Inventory and sets the equipment's available hours for scheduling:</p>

<img src="images/image19.png" alt="">

<p>Scientists submit requests to reserve the equipment and the requests are either posted immediately or sent through an approval workflow:</p>

<img src="images/image20.png" alt="">

<p>ArxCal can increase the efficiency of one's facility by making scheduling of tasks more visible to everyone, as well as eliminating bottlenecks in analysis and production workflows due to lack of availability of company equipment.</p>

<h2>Mouse-over Display of Project and Notebook Descriptions in Left Navigation Bar</h2>

<p>Notebooks and projects aren't always named in a way that makes intuitive sense to a scientist. A project name for a large pharmaceutical company, for example, may look something like LPC_001234A, where the name of the project doesn't give the scientists a good idea about its contents. In the next update of ArxLab Notebook, mousing over projects or notebooks in the left-side navigation bar will display the description of that item. See the screenshot to the right where the mouse hovers over the autonamed notebook 'DEMO-Internal Testing-1074' to display the description of the notebook.</p>

<img src="images/image21.png" alt="">

<h2 id="tips_and_tricks" class="underline">Tips &amp; Tricks: Opening Multiple Tabs or Windows from Links</h2>

<p>All current web browsers offer the capability to manage embedded links in a web page, but this feature is usually underutilized in web-based systems. Since navigation through the ArxLab Suite is done via live links in web pages, mastering browser navigation can greatly increase one's fluency in the ArxLab system. This article will detail browser features that make it easier for users to manage links in ArxLab, including opening new browser tabs and windows; bookmarking, saving, and copying links; and performing searches on links.</p>

<p>Right-click on any active link to bring up the context menu for the link. The menu gives you the opportunity to select many more actions to take from the link than just going to that page.</p>

<img src="images/image22.png" alt="">

<p>Holding down the *CTRL key and clicking on a link will execute the first item from the context menu: opening the link in a new tab. Holding down 'shift' and clicking will execute the second menu item: opening the link in a new page.</p>

<p>In the example below, the scientist has done a search in FT over registered small molecules. Of the seven hits, there are three that require further investigation. By holding down the *CTRL key and clicking on the Reg_ID links of interest, Joe Chemist can open each of the Registration system records of interest in a new tab.</p>

<img src="images/image23.png" alt="">

<p>Where the *CTRL key opens windows in new tabs, the SHIFT key will open a new browser window.  The Scientist below was viewing a list of recent experiments and wanted to view two of them. Holding down SHIFT and clicking on the experiment links will open each experiment in a new browser window:</p>

<img src="images/image24.png" alt="">

<!-- #include file="../../_inclds/footer-tool.asp"-->