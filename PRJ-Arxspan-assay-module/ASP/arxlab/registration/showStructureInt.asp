<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="regInt"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
accordServicePath = getCompanySpecificSingleAppConfigSetting("accordServiceEndpointUrl", session("companyId"))
%>
<html>
<head>
<link href="<%=mainCSSPath%>/reg-styles.css?<%=jsRev%>" rel="stylesheet" type="text/css" media="screen">
<link href="<%=mainAppPath%>/js/sweetalert1/sweetalert.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=mainAppPath%>/js/sweetalert1/sweetalert.min.js?<%=jsRev%>"></script>

</head>

<style>
.regIntNVP {
}

.regIntFS {
}

.regIntDeleteForm {
}

.regIntDeleteButtonDiv {
	padding:10px; float:left;
}

.regIntDeleteButton {
}

.regIntOpenButton {
}

.regIntOpenButtonDiv {
	padding:10px; float:left;
}

</style

<body>
<%
regId = request.form("regExperimentName") 'storing the submission Id in this field, it's a hack
expId = request.form("experimentId")
expType = request.form("experimentType")
ownsExp = request.form("regOwnsExp")

Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.Open "GET",accordServicePath&"/getStructureInfo?regId="&regId,True
http.send ""
http.waitForResponse(60)

r = http.responseText
response.write(r)
%>

<script>
function deleteSubmission() {

 swal({
    title: "Are you sure?",
    text: "You will not be able to recover the submission.\nYou will have to re-register!",
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: '#DD6B55',
    confirmButtonText: 'Yes',
    cancelButtonText: "Cancel",
    closeOnConfirm: true,
    closeOnCancel: true
 },
 function(isConfirm){
   if (isConfirm){
		document.getElementById("deleteForm").submit();
    }
  });
}

function openSubmission(URL) {
	window.open(URL);
}

<% If Not ownsExp Then %>
	var x = document.getElementsByClassName("regIntDeleteButtonDiv");
	x[0].style.display = "none";
<% End If %>

</script>
<form id="deleteForm" method="POST" action="<%=mainAppPath%>/registration/deleteStructureInt.asp?regId=<%=regId%>&expId=<%=expId%>&expType=<%=expType%>">
</form>

</body>
</html>