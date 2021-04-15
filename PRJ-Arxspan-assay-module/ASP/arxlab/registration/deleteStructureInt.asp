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
<link href="<%=mainAppPath%>/js/sweetalert1/sweetalert.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=mainAppPath%>/js/sweetalert1/sweetalert.min.js?<%=jsRev%>"></script>

<style type="text/css">
.regIntFS {
}
.regIntNVP {
}
.regIntDeleteForm {
}
.regIntDeleteButton {
	width:100%;
}
.regIntDeleteButtonDiv {
	padding:10px;
	width:inherit;
}
</style>

</head>

<body>
<%
regId = Request.QueryString("regId")
expId = Request.QueryString("expId")
expType = Request.QueryString("expType")

s = "regId="&regId
Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.Open "POST",accordServicePath&"/deleteStructure",True
http.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
http.send s
http.waitForResponse(60)
%>

<script>

//var lnk = window.parent.document.getElementById(window.parent.document.getElementById("regFieldId").value).cloneNode(true);
//alert(lnk);
//alert(JSON.stringify(window.parent.experimentJSON));
//alert("regId: "+window.parent.experimentJSON[window.parent.document.getElementById("regFieldId").value]);

swal({
    title: "Submission Deleted",
    text: "The submission was successfully deleted.",
    type: "success",
    showCancelButton: false,
 },
 function(isConfirm){
   if (isConfirm){
   		window.parent.document.getElementById(window.parent.document.getElementById("regFieldId").value).value = '';
		window.parent.experimentJSON[window.parent.document.getElementById("regFieldId").value] = '';
		window.parent.hidePopup('regDiv2');
		window.location='<%=mainAppPath%>/static/blank.html'
//		parent.location.href=parent.location.href
		window.parent.unsavedChanges=false;
		window.parent.experimentSubmit(false,false,false);
    }
 });

//alert("asp: <%=accordServicePath%>");
</script>
</body>
</html>