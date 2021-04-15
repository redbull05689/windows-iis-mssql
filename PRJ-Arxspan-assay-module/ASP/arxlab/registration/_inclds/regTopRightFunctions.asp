<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<form name="linkForm" id="linkForm" method="POST" action="<%=mainAppPath%>/misc/ajax/do/copy.asp" target="submitFrame">
<input type="hidden" name="linkType" value="6">
<input type="hidden" name="linkId" value="<%=theCdId%>">
</form>
<a href="javascript:void(0)" onClick="copyLink('linkForm')" title="Copy Link"><img border="0" src="<%=mainAppPath%>/images/edit-copy.png" class="png" style="position:absolute;right:5px;"></a>
<%
	hasRegPrettyPrint = checkBoolSettingForCompany("allowPrintingFromReg", session("companyId"))
	If hasRegPrettyPrint then
%>
<a href="javascript:void(0)" onClick="$('#regWindow').printElement({
				overrideElementCSS:[
					'<%=mainCSSPath%>/reg-styles.css?<%=jsRev%>',
					'<%=mainCSSPath%>/styles-tool.css?<%=jsRev%>',
					'<%=mainCSSPath%>/reg-print.css?<%=jsRev%>'],
				pageTitle:'ARXSPAN_<%=wholeRegNumber%>'
            });$('.destroyAfterPrint').remove();" style="position:absolute;right:40px;"><img border="0" src="<%=mainAppPath%>/images/print.png" class="png"></a>
<%End if%>