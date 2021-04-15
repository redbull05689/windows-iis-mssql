<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
sectionId = "getAdms"
subsectionId = "getAdms"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "tool"
%>

<%
'get notebook Id it is used everywhere
	Call getconnected

	pageTitle = "Get Admins"
%>
	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->

<%If session("companyId") = "1" then%>
<h1>Company Admins</h1>
<%
Call getconnectedlog
Set rec = server.CreateObject("ADODB.RecordSet")



strQuery = "SELECT users.email, users.companyid from users where (roleid = 1) and (enabled = 1) and companyid not in (select id FROM [companies] where disabled = 1 or datediff(day,getdate(),expirationDate) < 0) and companyid <> 1 and email not in ('support@arxspan.com','jeff.carter@arxspan.com','wuxi@arxspan.com','jim.martin@arxspan.com','josh@ibeam.net','d3demo.com') and email not like '%demo.com' and email not like '%arxspan.com' and email not like '%demotest.com' and email not like '%demo123.com' and email not like '%udemo.edu'" 



%>	
	<table style="table-layout:fixed;width:550px;">
		<tr>
	    <td style="width:550px;word-wrap:break-word;"> 
<%
rec.open strQuery,conn,3,3
Do While Not rec.eof

txt = rec("email")
If (InStrRev(txt,"demo.com")) > 0 Or (InStrRev(txt,"admin.com")) > 0 Or (InStrRev(txt,"admin2.com")) > 0 or (InStrRev(txt,"arxspan.com")) > 0  or (InStrRev(txt,"researcher.com")) > 0  then

 Else 
  response.write(rec("email") & "<br>")			
 End If
 
 
 rec.movenext
Loop
rec.close
Set rec = nothing
%>

amber.cyr@cyteir.com<br>tyler.maclay@cyteir.com<br>cmarkwood@epizyme.com<br>bkozuma@broadinstitute.org<br>support@arxspan.com
	    </td>
		</tr>
		
	</table>


<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->