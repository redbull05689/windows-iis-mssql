	
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!--METADATA TYPE="typelib" UUID="00000205-0000-0010-8000-00AA006D2EA4" NAME="ADODB Type Library" -->
<% 
Dim Conn, ConnCust, ConnAdm

set scriptShell = createobject("WScript.Shell")
whichServer = scriptShell.ExpandEnvironmentStrings("%WHICHSERVER%")
Set scriptShell = Nothing

elnDataBaseName = getElnDataBaseName()
elnDataBaseServerIP = getElnDataBaseServerIp()
elnDataBaseUserNameAdmin = getElnDataBaseAdminUserName()
elnDataBaseUserPasswordAdmin = getElnDataBaseAdminPassword()

Sub getconnectedadm
	Application("ConnAdm") = "Provider=sqloledb;Data Source="&elnDataBaseServerIP&";Initial Catalog="&elnDataBaseName&";User Id="&elnDataBaseUserNameAdmin&";Password="&elnDataBaseUserPasswordAdmin
	Set ConnAdm = Server.CreateObject("ADODB.CONNECTION")
	ConnAdm.Open Application("ConnAdm")
End Sub

Sub disconnectadm
	On Error Resume next
	ConnAdm.close
	Set ConnAdm = Nothing
	On Error goto 0
End Sub


call getconnectedadm
set liRec = server.createObject("ADODB.RecordSet")
strQuery = "SELECT top (1) id FROM PdfProcQueue with (NOLOCK) order by id desc"
liRec.open strQuery,ConnAdm,3,3
if not liRec.eof Then
    response.write(liRec("id"))
    liRec.movenext
end if
call disconnectadm
%>