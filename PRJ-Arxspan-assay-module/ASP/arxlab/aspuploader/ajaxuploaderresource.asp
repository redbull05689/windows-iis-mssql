<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%@ Language="VBScript" %><!-- #include file="include_aspuploader.asp" --><% 

Dim uploader
Set uploader=new AspUploader
uploader.ProcessResource()

%>