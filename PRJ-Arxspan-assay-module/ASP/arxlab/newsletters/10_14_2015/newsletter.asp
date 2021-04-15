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
    padding-bottom: 37px;
    border-bottom: 1px solid #C7C7C7;
}
.WordSection1 {
    width: 795px;
}
</style>
<h1 class="newsletterSectionHeader" id="feature">Feature of the Month</h1>
<p class="underline">Cell Line Management in ArxLab</p>


<p>Managing cell lines is an important and multi-faceted task for organizations. Each will have a need to track data for multiple purposes, and this data have to be accessed quickly for different stages of a given workflow. Oftentimes an organization has one or more groups that oversee cell line management from intake, culture, derivatization, purification, pooling, assaying, and more. The data can change rapidly and in bulk, necessitating the need for a central, authoritative data repository for information tracking. Furthermore, as one group finishes their work with a cell line and passes it to another group, the experimental results need to be accessed from users both up and down stream, and researchers along the workflow may need to know at what step a cell line is currently.</p>

<p>ArxLab’s Registration, Inventory, and Assay modules allow users to configure and define the cell line metadata being tracked at each step and then make results available to other users at all points in the workflow. Beginning with cell line onboarding, users can register parent objects, whether they be the cell lines themselves, the sources of the cell lines, or the derivatives of the cell lines – or all of the above. To each registration entry, single or multiple batches can be added, allowing users to track the separate instances that a cell line was grown up or derivatives were made. At the same time that metadata is entered into Registration, users can also create containers for each object in Inventory, allowing them to define volumes, storage conditions, location in a lab, and more. Each object can have multiple containers stored in Inventory, so at any point a user can determine how many vials of each cell line the lab currently has on hand.</p>

<p>Along the way, many of these objects will have experimental data that need to be linked, whether they are written-up biology or chemistry experiments performed in ArxLab Notebook, or they are raw or calculated assay data uploaded into the Assay module.  Using the search tool module Filter and Transform (FT), a researcher has the ability to search for a cell line and find all assay results that coincide with it, or to filter the results to only specific assays or data. In this way, the researchers that perform onboarding have the ability to see and track experimental work downstream from them at a click of a button, and any user performing endpoint experiments can easily access the onboarding metadata related to the identity of a cell line. With data updated in real time that is flexible, accessible across modules, searchable and shareable, ArxLab can be configured and deployed for each group’s unique needs and can streamline an organization’s cell line management workflow.</p>

<p>Contact <a href="mailto:support@arxspan.com">support@arxspan.com</a> for more information on deploying a custom cell line management workflow.</p>

<h1 class="newsletterSectionHeader" id="latest_news">Latest News</h1>

<p class="underline">ArxLab FT Enhancements</p>

<p>Arxspan has recently enhanced its ArxLab FT decision support tool by adding the following features:</p>
<ul>
<li>Charting in ArxLab FT - Ability to create new graphs, including scatter plots, bubble plots, and histograms, in two or three dimensions, based on search results from real-time data.</li>
<li>Live Linking of ArxLab FT to Registration and Inventory - Registration and Inventory IDs that are displayed in ArxLab FT search results are clickable fields that allow users to quickly navigate to Registration entry pages and Inventory container displays.</li>
<li>New Saved Search Preferences - ArxLab users can now set the number of results displayed per saved search and searches can be set to auto-run when that search is loaded.</li>
<li>Table View of all ArxLab Data Associated with a Single Registration ID - ArxLab users can search for a single Registration ID and find all information entered in Registration, Assay, or Inventory, including Registration batches and parents, Assay result sets, and Inventory containers.</li>
<li>Selection by Field Group - A quick select feature enables ArxLab users to choose an object (ie. small molecule, protein, etc.), and all fields tracked for that object will be auto-selected as searching parameters in ArxLab FT.</li>
</ul>

<h1 class="newsletterSectionHeader" id="recent_enhancements">Recent Enhancements</h1>

<ul>
<li>Bulk Functions in Inventory (Adding/Importing/Moving/Disposing) - New bulk functions in Inventory allow ArxLab users to add, change or dispose of any number of barcoded containers of material with one click. An unlimited number of identical objects can be added in bulk by selecting the desired location and scanning or entering the barcodes; one barcode will be applied to each individual container. Materials can also be moved in bulk in a similar way: select the new location, and scan or enter in the barcodes of the containers that will be moved. When disposing of multiple containers at one time, Bulk Dispose can be selected, the barcodes of the containers are scanned or entered, and the objects will all be moved into the Disposed location. In addition to these few features, users still have the ability to import samples directly into Inventory containers from Excel spreadsheets.</li>

<li>User Interface Enhancements - ArxLab users will see the following changes in their ArxLab Notebook pages
<ul>
	<li>Language Selections - ArxLab Notebook is available in English, Japanese, and Chinese.  ArxLab users can now instantly toggle between these three languages by clicking on the appropriate flag in the upper right hand corner of ArxLab Notebook.</li>
	<li>Updated layout of Project pages - ArxLab Notebook’s Project pages have a new user interface that highlights a clean, modernized design for viewing subprojects, notebook, experiments, and registered items.</li>
</ul>
</li>

<li>Registration Integration with Inventory - ArxLab Inventory now contains an ID field link that takes the user to the Registration record for that particular substance.  Also, new batches of substances registered within ArxLab Registration can be added to containers in the Inventory module and the field can be auto-populated from Registration.</li>

<li>Improved Assay Search - Search capability in ArxLab Assay has been improved, with real-time searching and sorting of all Assay data as well as customized layout of search results.  Within the search tool, ArxLab Assay users can search and filter parameters, perform basic mathematical calculations, visualize chemical structures, create customizable graphs, generate 2D and 3D plotting, perform structure-activity relationship analyses, export tables to Microsoft Excel, and more.</li>

<li>Improved Reaction Scheme Tracking - ArxLab Notebook now has stoichiometry grid functionality which links all reaction substrates and products to their defined structures that are visually represented in the structure editor.</li>
</ul>

<h1 class="newsletterSectionHeader" id="upcoming_enhancements">Upcoming Enhancements</h1>

<ul>
<li>Plate-Based Workflows - ArxLab users will be able to better manage their plate-based workflows.  Stored plate maps will be incorporated into ArxLab in order to denote the planned placement of compounds, controls, and dilutions; serial dilution descriptions and procedures will be standardized; and generating multiple measurements per well will be possible.</li>

<li>ArxDraw for Molecular Biology - ArxDraw for Molecular Biology is a tool allowing molecular biologists to create, visualize, and share nucleotide sequence files for the purposes of cloning, PCR, sequencing, mutagenesis studies, and more.  ArxDraw users will have the capability to create DNA sequence files from scratch or to import files from GenBank and other sources.  Sequences can be viewed in linear and plasmid form, with full feature representation and a map of restriction sites.  DNA can be searched, open reading frames identified, and primers identified and annotated.  Plasmids can be exported as an image and linear sequences can be exported in GenBank format.  The ArxDraw module is a part of the ArxLab platform and integrates with ArxLab Notebook, allowing molecular biologists to seamlessly document their work in relevant biology experiments.</li>

<li>ArxLab Vivarium Module - ArxLab Vivarium is built to streamline vivarium management and research workflows that require use of live animals.  The information tracked can be defined by users for maximum flexibility and traits can be pre-populated from parent to litters. Major features include:
<ul>
	<li>Manage breeding pairs and breeding cages</li>
	<li>Track litters including birth/wean dates</li>
	<li>Identify using ear punch, tattoo, tag, etc.</li>
	<li>Report genotype, phenotype, and lineage</li>
	<li>Support any type of animal or research model</li>
</ul>
</li>

<li>Advanced Decision Support and Reporting for Inventory - Decision support and reporting capability in ArxLab Inventory will be improved, with real-time searching and sorting of all Inventory data as well as customized layout of search results.  Within the search tool, ArxLab Inventory users can search and filter parameters; search materials on hand by chemical structure, name, or quantity; find storage locations of containers in their lab; generate flammability reports; export tables to Microsoft Excel; and more.</li>

<li>Novel Biological Registration Workflow - Biological registration can be difficult because many biological molecules are large complexes of multiple subunits, with some subunits being biological in nature and some being chemical in nature.  This makes it difficult to create a page that effectively describes the complex as well as the individual subunits.  ArxLab registration provides links in its pages, allowing one registration page to be connected to one, two, or many additional registration pages.  This functionality is useful for registering complexes such as antibody drug conjugates (ADCs).  ADC registration within ArxLab consists of a master registration page for the ADC that contains links to three separate registration pages: an antibody, a small molecule drug compound, and a small molecule linker compound.  Users have the capability to populate the biological (antibody) registration page with biology-centric information, such as amino acid sequence, specificity, immunogen, etc.  Users also have the capability to populate the chemical (drug and linker compounds) registration pages with chemistry-centric information, such as formula, molecular weight, and SMILES string.  The registered ADC compound can be established as unique based upon the identities of these three component subunits, and more descriptive information on the ADC can be entered into its main registration page.</li>
</ul>


<h1 class="newsletterSectionHeader" id="tips_and_tricks">Tips &amp; Tricks</h1>
<p class="underline">Creating and Editing Templates</p>
<p class="imageDescription">Templates are an important feature of the ArxLab Notebook and can be used for repeating oft-used experiments like “Preparation of cell growth medium”, or as a standard form for analytical requests.  In the example screenshot below, the template for HPLC analysis lets the technician paste the bulk of an analytical HPLC protocol into her notebook and then select drop-down choices for solvents and column types:</p>
<img src="images/image1.png" alt="">
<p class="imageDescription">Creating and editing experiment templates recently became enabled on a per-user basis.  Where previously an Administrator on the system had to be the curator of templates, now any line scientist can be granted the ability to create and edit templates:</p>
<img src="images/image2.png" width="700">
<p class="imageDescription">Much of a chemist’s daily notebook entry effort can be spent repeating experimental building blocks, entering and reentering phrases such as “A 500 mL three-necked round bottom flask was charged with 100 mL of ethyl acetate”. A time-saving chemistry template could be created for this action called “Charge vessel”.  The type of vessel, volumes, and solvent can be entered as custom drop-down lists from which the scientist can select the proper values:</p>
<img src="images/image3.png" width="700">
<p class="imageDescription">If a user has permission to edit templates, the template menu will appear in the left-hand navigation bar of the user’s ELN.  To create a new template just click on the ‘New Template’ link (A).  To edit or delete existing templates, click on the pencil or ‘X’ icons (B):</p>
<img src="images/image4.jpg" width="700">
<p class="imageDescription">Inside the template editor, add templates or custom drop-down lists from the drop-down menus:</p>
<img src="images/image5.jpg" width="700">


<p>Contact <a href="mailto:support@arxspan.com">support@arxspan.com</a> for more information and guidance on finding ways to create templates that can make your processes more efficient and productive.</p>

<!-- #include file="../../_inclds/footer-tool.asp"-->