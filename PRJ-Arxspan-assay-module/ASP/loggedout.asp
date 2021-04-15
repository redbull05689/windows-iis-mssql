<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
Dim isArxLoginScript
isArxLoginScript = True
session("overrideDB")=""
%>
<%
	sectionID = "home"
	subSectionID=""
	terSectionID=""

	pageTitle = "Arxspan web based electronic lab notebook, cloud-based ELN for scientific collaboration platform."

	metaD="Arxspan is a web based electronic lab notebook company. Arxspan is a cloud-based ELN hosted online ELN application platform for scientific collaboration, internal research management, contract research organization (CRO) and academic scientific collaboration."

	metaKey="cloud based ELN, web based lab notebook, electronic notebook, ELN, e signatures, electronic signatures, chemistry notebook, biology notebook, electronic research notebook, scientific data management, cro data management, cro notebook, cro workflow,  cro notebook, cro Management"

' #################### TO ENABLE MAINTENANCE MODE GOTO APPROX LINE#215 AND CHANGE 1=1  TO 1=2 ###########################

%>

<!-- #include file="arxlab/_inclds/globals.asp"-->
<%
If session("userId") <> "" Then
	session("prevUrl") = ""
End if
%>

<!--#include file="_inclds/header.asp"-->

<%
loginPage = "/login.asp"
if request.querystring("loginUrl")<>"" Then
	loginPage = request.querystring("loginUrl")
End If
%>

<!-- #include virtual="header_bar.asp"-->
<div class="login-page container">
<div class="form">

	<div class="row logoutMessage">
		<div class="col-sm-12">
			<h3>You have been logged out.  </h3><br/><a href="<%=loginPage%>" id="clickLink"><button class="centerButton">CLICK HERE TO SIGN IN</button></a>
		</div>
	</div>
	<div class="bottom row">
		<div class="col-sm-12">
			<p class="loginAccessDisclaimer">Unauthorized access to this system is strictly prohibited. Unauthorized access to this system, and/or unauthorized use of information from this system may result in civil and/or criminal penalties under applicable state and federal laws.</p>
		</div>
	</div>
</div>




<script type="text/javascript">
window.onload = function(){
	document.getElementById("clickLink").focus();
}
</script>






<!--#include file="_inclds/footer.asp"-->
	