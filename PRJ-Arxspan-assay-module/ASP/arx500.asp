<%@Language="VBSCRIPT"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/connection.asp"-->
<!-- #include file="arxlab/_inclds/common/functions/fnc_writeToAspErrors.asp"-->

<%
Dim isArxLoginScript
isArxLoginScript = True
On Error Resume Next
Response.Clear
Dim objError
Set objError = Server.GetLastError()
Response.Status = "500 Internal Server Error"

Function SQLClean(ByVal CleanInput,TypeInput,TypeOutput)
   If Isnull(CleanInput) then
	   CleanInput=""
   End if
   Select Case TypeInput
		Case "N"	   
			On Error Resume Next
			If IsNull(CleanInput) Or cleanInput="" Then
				cleanInput = 0
			End if
			if isNumeric(CStr(CleanInput)) then
				SQLClean = CleanInput
			else
				SQLClean = 0
			End If
	   Case "T"
		If CleanInput="''" Then
			SQLClean="''"
		Else
		   CleanInput = Replace (CleanInput,"'","''")
			  SQLClean = "'" & CleanInput &"'"

		End if
   	End Select
End Function 

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">



<%errHTML = "<table width=""800"">"%>
<% If Len(CStr(objError.ASPCode)) > 0 Then %>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "    <th nowrap align=""left"" valign=""top"">IIS Error Number</th>"%>
<%errHTML = errHTML &  "    <td align=""left"" valign=""top"">"&objError.ASPCode&"</td>"%>
<%errHTML = errHTML &  "  </tr>"%>
<% End If %>
<% If Len(CStr(objError.Number)) > 0 Then %>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "    <th nowrap align=""left"" valign=""top"">COM Error Number</th>"%>
<%errHTML = errHTML &  "    <td align=""left"" valign=""top"">"&objError.Number&" (0x" & Hex(objError.Number) & ")"&"</td>"%>
<%errHTML = errHTML &  "  </tr>"%>
<% End If %>
<% If Len(CStr(objError.Source)) > 0 Then %>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "    <th nowrap align=""left"" valign=""top"">Error Source</th>"%>
<%errHTML = errHTML &  "    <td align=""left"" valign=""top"">"&objError.Source&"</td>"%>
<%errHTML = errHTML &  "  </tr>"%>
<% End If %>
<% If Len(CStr(objError.File)) > 0 Then %>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "    <th nowrap align=""left"" valign=""top"">File Name</th>"%>
<%errHTML = errHTML &  "    <td align=""left"" valign=""top"">"&objError.File&"</td>"%>
<%errHTML = errHTML &  "  </tr>"%>
<%scriptName = objError.File%>
<% End If %>
<% If Len(CStr(objError.Line)) > 0 Then %>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "    <th nowrap align=""left"" valign=""top"">Line Number</th>"%>
<%errHTML = errHTML &  "    <td align=""left"" valign=""top"">"&objError.Line&"</td>"%>
<%errHTML = errHTML &  "  </tr>"%>
<%lineNumber = objError.Line%>
<% End If %>
<% If Len(CStr(objError.Column)) > 0 Then %>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "    <th nowrap align=""left"" valign=""top"">Column</th>"%>
<%errHTML = errHTML &  "    <td align=""left"" valign=""top"">"&objError.Column&"</td>"%>
<%errHTML = errHTML &  "  </tr>"%>
<% End If %>
<% If Len(CStr(objError.Description)) > 0 Then %>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "    <th nowrap align=""left"" valign=""top"">Brief Description</th>"%>
<%errHTML = errHTML &  "    <td align=""left"" valign=""top"">"&objError.Description&"</td>"%>
<%errHTML = errHTML &  "  </tr>"%>
<%description = objError.Description%>
<% End If %>
<% If Len(CStr(objError.ASPDescription)) > 0 Then %>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "    <th nowrap align=""left"" valign=""top"">Full Description</th>"%>
<%errHTML = errHTML &  "    <td align=""left"" valign=""top"">"&objError.ASPDescription&"</td>"%>
<%errHTML = errHTML &  "  </tr>"%>
<% End If %>
<% If Len(CStr(objError.Category)) > 0 Then %>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "    <th nowrap align=""left"" valign=""top"">Category</th>"%>
<%errHTML = errHTML &  "    <td align=""left"" valign=""top"">"&objError.Category&"</td>"%>
<%errHTML = errHTML &  "  </tr>"%>
<% End If %>

<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "	<th nowrap align=""left"" valign=""top"">Server Variables</th>"%>
<%errHTML = errHTML &  "	<td align=""left"" valign=""top"">"%>
	<%
	For Each ServerVar In Request.ServerVariables
		If (InStr(ServerVar,"_ALL") + InStr(ServerVar,"ALL_") = 0) then
			tmpValue = Request.ServerVariables(ServerVar)
			errHTML = errHTML &  ServerVar & ": " & tmpValue & "<br />"
		End If
	Next
	%>
<%errHTML = errHTML &  "	</td>"%>
<%errHTML = errHTML &  "</tr>"%>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "	<th nowrap align=""left"" valign=""top"">Session Variables</th>"%>
<%errHTML = errHTML &  "	<td align=""left"" valign=""top"">"%>
	<%
    For Each Item In Session.Contents 
        errHTML = errHTML &  Item & ": " & Session(Item) & "<br/>"
    Next 
	%>
<%errHTML = errHTML &  "</td>"%>
<%errHTML = errHTML &  "</tr>"%>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "	<th nowrap align=""left"" valign=""top"">Query String</th>"%>
<%errHTML = errHTML &  "	<td align=""left"" valign=""top"">"&Server.HTMLEncode(Request.QueryString)&"</td>"%>
<%errHTML = errHTML &  "</tr>"%>
<%errHTML = errHTML &  "<tr>"%>
<%errHTML = errHTML &  "	<th nowrap align=""left"" valign=""top"">Time</th>"%>
<%errHTML = errHTML &  "	<td align=""left"" valign=""top"">"&now&"</td>"%>
<%errHTML = errHTML &  "</tr>"%>
<%errHTML = errHTML & "</table>"%>


<%
errorId = writeToAspErrors(scriptName, description, lineNumber)
axcNum = "AXC-"&  Year(Date) & Right("0" & Month(Date),2) & Right("0" & Day(Date),2) &"-"&errorId
set fs=Server.CreateObject("Scripting.FileSystemObject")
Set tfile=fs.CreateTextFile(errorPath&"\arx"&errorId&".html")
tfile.WriteLine(errHTML)
tfile.close
set tfile=nothing
set fs=nothing	
%>

<html>
<head>
	<title>Arxspan: Server Error 500</title>

<link href="/arxlab/css/styles-tool.css" rel="stylesheet" type="text/css" MEDIA="screen">
</head>

<body>
<div style="width:800px;margin:auto;">
<div class="persNav"><a href="/arxlab/support-request.asp?axcNum=<%=axcNum%>">CONTACT SUPPORT</a></div>
<div class="logoDiv"><a href="/arxlab/dashboard.asp"><img style="height: 100%; width: 75%;" src="/arxlab/images/Arxspan-FullColor-Web.png" alt="logo" border="0"></a></div>

<div style="clear:both;">
<h2 style="line-height:115%">Error 500.</h2>
</div>

<div style="margin-top:20px;">

<p>A software error has occured.  This error has been logged by Arxspan.  If you would like to send us addition details about this error, e.g. what you were doing when it occurred, <a href="/arxlab/support-request.asp?axcNum=<%=axcNum%>">click here</a></p>

<%If session("companyId")="1" Or session("email")="support@arxspan.com" or whichServer="DEV" then%>
<%response.write(errHTML)%>
<%End if%>

<p style="margin-top:40px;">
Unauthorized access to this system is strictly prohibited. Unauthorized access to this system, and/or unauthorized use of information from this system may result in civil and/or criminal penalties under applicable state and federal laws.
</p>

<p style="margin-top:20px;">

&copy;Arxspan. All Rights Reserved. &mdash; 5a Crystal Pond Road, Southborough, MA 01772 &mdash; 617-297-7023
</p>
</div>
</div>
</body>
</html>
