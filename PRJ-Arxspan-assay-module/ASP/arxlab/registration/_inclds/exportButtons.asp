<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<div>
<div style="float:left;">
<input type="submit" value="Download" onclick="makeCookie(document.getElementById('numExportFields').value);hidePopup('exportFieldsDiv');showPopup('loadingDiv');setTimeout('waitRegExport(\''+document.getElementById('exportFid').value+'\')',2000);" style="padding:3px;">
</div>
<%
    hasExportForAnalysisButton = checkBoolSettingForCompany("canExportFromRegForAnalysis", session("companyId"))
    If hasExportForAnalysisButton then
%>
<div style="float:right;">
<input type="submit" value="Export For Analysis" onclick="posCheck=document.getElementById('positionCheckId').value;if(document.getElementById(posCheck).checked){document.getElementById('forAnalysis').value='true';makeCookie(document.getElementById('numExportFields').value);hidePopup('exportFieldsDiv');showPopup('loadingDiv');setTimeout('waitRegExport(\''+document.getElementById('exportFid').value+'\')',2000);}else{alert('Position must be checked')}" style="padding:3px;">
</div>
<%End if%>
</div>