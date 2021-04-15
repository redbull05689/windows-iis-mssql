<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header-frame.asp"-->
<script type="text/javascript" SRC="js/marvin/marvin.js"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript">

chemTable = "<%=request.querystring("chemTable")%>";
chemSearchDbName = "<%=request.querystring("chemSearchDbName")%>"
chemSearchDbName2 = "<%=request.querystring("chemSearchDbName2")%>"
//chemSearchDbName = "parentCompoundId.cd_id";

hasChemdraw().then(function (isInstalled) {
	if (isInstalled) {
		cd_insertObject("chemical/x-mdl-molfile", 200, 200, "mycdx","",false,false);
	} else {
		msketch_name="marvinObject"
		msketch_begin("js/marvin", 300, 300); // arguments: codebase, width, height
		msketch_end();
	}
});
</script>
<br/>
<select id="searchTypeForSearch" name="searchTypeForSearch">
	<option value="SUBSTRUCTURE">Substructure Search</option>
	<option value="DUPLICATE">Exact Search</option>
</select>

<%If session(request.querystring("c")&"Chem") <> "" then%>
	<script type="text/javascript">
		hasChemdraw().then(function (isInstalled) {
			if (isInstalled) {
				window.onload = function () {
					cd_putData("mycdx", "text/xml",<%=session(request.querystring("c") & "Chem") %>)
				}
			}
		});
    </script>
<%End if%>
<!-- #include file="_inclds/footer-frame.asp"-->