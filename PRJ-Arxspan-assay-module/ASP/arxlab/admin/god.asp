<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
sectionId = "god"
subsectionId = "god"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "tool"
%>

<%
'get notebook Id it is used everywhere
	Call getconnected

	pageTitle = "God"
%>
	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->

<%If canUseGod then%>
<h1>God Panel</h1>
<%
logViewName = getDefaultSingleAppConfigSetting("logViewName")
usersTable = getDefaultSingleAppConfigSetting("usersTable")
Call getconnectedlog
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM companies WHERE (disabled=0 or disabled is null) and id IN (1,4)"


' USE THIS FOR PROD #########################
'strQuery = "SELECT * FROM companies WHERE (datediff(day,getdate(),expirationDate) > 0) and (disabled=0 or disabled is null) and name NOT LIKE '%demo%' and name NOT LIKE '%delete%' and name NOT LIKE '%test%'"

'strQuery = "SELECT * FROM companies WHERE (datediff(day,getdate(),expirationDate) > 0 or expirationDate is null or expirationDate='1/1/1900') and (disabled=0 or disabled is null) "


rec.open strQuery,conn,3,3
Do While Not rec.eof
%>
	<table>
		<tr>
			<td colspan="2"><h2><%=rec("name")%></h2></td>
		</tr>
		<tr>
			<td>
				Total Users
			</td>
			<td>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT * FROM "&usersTable&" WHERE companyId="&SQLClean(rec("id"),"N","S")
				rec2.open strQuery,conn,1,1
				response.write(rec2.recordcount)
				rec2.close
				Set rec2 = nothing
				%>
			</td>
		</tr>
		<tr>
			<td>
				Enabled Users
			</td>
			<td>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT * FROM "&usersTable&" WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND enabled=1"
				rec2.open strQuery,conn,1,1
				response.write(rec2.recordcount)
				totalUsers = rec2.recordcount
				rec2.close
				Set rec2 = nothing
				%>
			</td>
		</tr>
		<tr>
			<td>
				Read Only Users
			</td>
			<td>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT * FROM usersView WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND enabled=1 and roleNumber=40"
				rec2.open strQuery,conn,1,1
				response.write(rec2.recordcount)
				rec2.close
				Set rec2 = nothing
				%>
			</td>
		</tr>
		<tr>
			<td>
				Experiments
			</td>
			<td>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT * FROM experimentView WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND visible=1"
				rec2.open strQuery,conn,1,1
				response.write("(chemistry: "&rec2.recordcount)
				rec2.close
				Set rec2 = nothing
				%>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT * FROM bioExperimentsView WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND visible=1"
				rec2.open strQuery,conn,1,1
				response.write(", bio: "&rec2.recordcount)
				rec2.close
				Set rec2 = nothing
				%>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT * FROM freeExperimentsView WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND visible=1"
				rec2.open strQuery,conn,1,1
				response.write(", concept: "&rec2.recordcount)
				rec2.close
				Set rec2 = nothing
				%>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT * FROM analExperimentsView WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND visible=1"
				rec2.open strQuery,conn,1,1
				response.write(", anal: "&rec2.recordcount&")")
				rec2.close
				Set rec2 = nothing
				%>
			</td>
		</tr>
		</tr>
		<tr>
			<td>
				Notebooks
			</td>
			<td>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT * FROM notebookView WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND visible=1"
				rec2.open strQuery,conn,1,1
				response.write(rec2.recordcount&"&nbsp")
				rec2.close
				Set rec2 = nothing
				%>
			</td>
		</tr>
	
		<tr>
			<td>
				User Logins/Day (last 30 days)
			</td>
			<td>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT * FROM "&logViewName&" WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND DATEDIFF(d,dateSubmitted,GETDATE()) < 30 AND actionId=10"
				rec2.open strQuery,connLog,1,1
				response.write(FormatNumber(rec2.recordcount/30,1))
				rec2.close
				Set rec2 = nothing
				%>
			</td>
		</tr>

		<tr>
			<td>
				% of enabled users logged in this week
			</td>
			<td>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT distinct userId FROM "&logViewName&" WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND DATEDIFF(d,dateSubmitted,GETDATE()) < 7 AND actionId=10"
				rec2.open strQuery,connLog,1,1
				If totalUsers <> 0 And rec2.recordcount <> 0 then
					response.write(FormatNumber(100*rec2.recordcount/totalUsers,1)&"%")
				Else
					response.write("0%")
				End if
				
				rec2.close
				Set rec2 = nothing
				%>
			</td>
		</tr>



		<tr>
			<td>
				% of enabled users logged in this month
			</td>
			<td>
				<%
				Set rec2 = server.CreateObject("ADODb.RecordSet")
				strQuery = "SELECT distinct userId FROM "&logViewName&" WHERE companyId="&SQLClean(rec("id"),"N","S")& " AND DATEDIFF(d,dateSubmitted,GETDATE()) < 31 AND actionId=10"
				rec2.open strQuery,connLog,1,1
				If totalUsers <> 0 And rec2.recordcount <> 0 then
					response.write(FormatNumber(100*rec2.recordcount/totalUsers,1)&"%")
				Else
					response.write("0%")
				End if
				
				rec2.close
				Set rec2 = nothing
				%>
			</td>
		</tr>
	</table>
<%
	rec.movenext
Loop
rec.close
Set rec = nothing
%>
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->