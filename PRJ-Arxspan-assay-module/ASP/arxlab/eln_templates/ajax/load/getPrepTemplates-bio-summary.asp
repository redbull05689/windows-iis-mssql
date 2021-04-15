<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
'Dim Conn
%>
<!-- #include file="../../../_inclds/escape_and_filter/functions/fnc_SQLClean.asp"-->
<!-- #include file="../../../_inclds/__whichServer.asp"-->
<%
Call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT name, html FROM prepTemplatesBioSummary WHERE companyId="&SQLClean(session("companyId"),"N","S")& " ORDER BY name ASC"
rec.open strQuery,conn,3,3
arrStr = "["
counter = 0
Do While Not rec.eof
	arrStr = arrStr & "['"&counter&"','"&Replace(Replace(rec("name"),"'","\'"),vbcrlf,"")&"','"&Replace(Replace(rec("name"),"'","\'"),vbcrlf,"")&"','"&Replace(Replace(rec("html"),"'","\'"),vbcrlf,"")&"']"
	rec.movenext
	counter = counter + 1
	If Not rec.eof Then 
		arrStr = arrStr & ","
	End if
loop
arrStr = arrStr & "]"
response.write(arrStr)
Call disconnect
%>