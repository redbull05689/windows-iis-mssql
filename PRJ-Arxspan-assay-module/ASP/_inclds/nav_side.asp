	<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->	
<table class="contentTable" style="min-height:650px;height:650px;">
	<tr>
	<td class="pageNav" valign="top">

	




								
<%If sectionID = "about" Then %>



				<ul id="pageNav">
					<li><a href="/about-arxspan-chemical-informatics.asp">About Arxspan</a>
						<ul>
							<li><a href="/about-arxspan-chemical-informatics.asp" <%If subSectionID = "overview" Then %> class="navSelected"<%End if%>>Overview</a>
<!--							<li><a href="/.asp" <%If subSectionID = "management" Then %> class="navSelected"<%End if%>>Management</a>
							<li><a href="/.asp" <%If subSectionID = "board" Then %> class="navSelected"<%End if%>>Board of Directors</a>
							<li><a href="/.asp" <%If subSectionID = "partners" Then %> class="navSelected"<%End if%>>Partners &amp; Associations</a> -->
						</ul>
					</li>
								
				</ul>



<%elseIf sectionID = "tool" Then %>


<!--#include virtual="/arxlab/_inclds/nav_tool.asp" -->


<%ElseIf sectionID = "monkeyFart" then%>

			<ul>
				<li><a href="#.asp" <% if sectionID = "about" then %> style="background-color:#666666;"<% end if%>>About</a>
					<ul>
						<li><a href="/mental-illness-recovery-about-programs-for-people.asp">Our Mission</a>
					</ul>
				</li>
			</ul>




<%ElseIf sectionID = "products" then%>

			<ul>
				<li><a href="/chemical-informatics-products-and-services.asp" >Products &amp; Services</a>
					<ul>
						<li><a href="/chemical-informatics-products-and-services.asp" <%If subSectionID = "overview" Then %>class="navSelected"<%End if%>>Chemical Informatics Products</a>
						<li><a href="/electronic-notebook-for-research-secure-cro-data-management.asp" <%If subSectionID = "industry" Then %>class="navSelected"<%End if%>>ELN for Research Industry</a></li>
						<li><a href="/electronic-notebook-for-academic-research-student-lab-notebook.asp" <%If subSectionID = "academia" Then %>class="navSelected"<%End if%>>ELN for Academic Researchers and Students</a></li>	
						<li><a href="/contact-arxspan-lab-enotebook-software.asp" <%If subSectionID = "contact"  Then %>class="navSelected"<%End if%>>Information Request</a>
					</ul>
				</li>
			</ul>




<%ElseIf sectionID = "contact" then%>

			<ul>
				<li><a href="/contact-arxspan-lab-enotebook-software.asp" >Contact Us</a>
					<ul>

							
							
							<li><a href="/contact-arxspan-lab-enotebook-software.asp" <%If subSectionID = "contact" Then %> class="navSelected"<%End if%>>Information Request</a>

							<li><a href="/directions.asp" <%If subSectionID = "directions" Then %> class="navSelected"<%End if%>>Directions</a>

					</ul>
				</li>
			</ul>

<%End If %>
					









<br>&nbsp;<br>

	</td>
	<td class="pageContentTD" valign="top">


<div class="pageContent">
