<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function getAttachmentTableFileTypeIcon(exten)
	'return the path of the an icon based on the extension provided
	Select case LCase(exten)
		Case "jpg"
			imgPath = "images/icon-image.png"
		Case "doc"
			imgPath = "images/icon-word.png"
		Case "docx"
			imgPath = "images/icon-word.png"
		Case "pdf"
			imgPath = "images/icon-text.png"
		Case "xls"
			imgPath = "images/icon-excel.png"
		Case "xlsx"
			imgPath = "images/icon-excel.png"
		Case "ppt"
			imgPath = "images/icon-pwrpnt.png"
		Case "pptx"
			imgPath = "images/icon-pwrpnt.png"
		Case Else
			imgPath = "images/icon-text.png"
	End Select
	'set function value to the image/icon path
	getAttachmentTableFileTypeIcon = imgPath
End function
%>