<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_applyChemDrawStyles.asp"-->

<%
'apply styles from one document to another
'On Error Resume Next
templateName = getCompanySpecificSingleAppConfigSetting("blankCdxName", session("companyId"))
Set originCDXML = request("originCDXML")
Set templateCdxml = request("templateCdxml")
response.write applyStyles(originCDXML, templateName, templateCdxml)
'On Error Goto 0
%>
