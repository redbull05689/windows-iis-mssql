<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "custom-dropDowns"
subsectionId = "custom-dropDowns"
%>
<!-- #include file="../_inclds/globals.asp"-->

	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	

<%
If session("roleNumber") > 1 And Not session("canEditTemplates") Then
	response.redirect(mainAppPath&"/static/error.asp")
End if
%>

<%
If request.Form("submit")<>"" Then
	Call getconnectedAdm
	name = request.Form("name")
	heading = request.Form("heading")
	If name = "" Then
		errorString = "You must enter a name."
	Else
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id from templateDropDowns WHERE name="&SQLClean(Trim(name),"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
		rec.open strQuery,connAdm,3,3
		If Not rec.eof Then
			errorString = "A drop down with this name already exists."
		End If
	End If
	If errorString = "" Then
		strQuery = "INSERT into templateDropDowns(name,heading,companyId) output inserted.id as newId values("&_
		SQLClean(Trim(name),"T","S") & "," &_
		SQLClean(heading,"T","S") & "," &_
		SQLClean(session("companyId"),"N","S") & ")"
		Set rs = connAdm.execute(strQuery)
		newId = CStr(rs("newId"))
		For i = 1 To 50
			If request.Form("option_"&i) <> "" Then
				strQuery = "INSERT into templateDropDownOptions(parentId,value) values(" &_
					SQLClean(newId,"N","S") & "," &_
					SQLClean(request.Form("option_"&i),"T","S") & ")"
				connAdm.execute(strQuery)
			End if
		next
		Call disconnectAdm
		response.redirect("customDropDowns.asp")
	End if
	Call disconnectAdm
End if
%>

<script type="text/javascript">
	function addOption()
	{
		nextOptionNumber = 0
		for (i=0;i<50 ;i++ )
		{
			try
			{
				if(document.getElementById("option_"+i))
				{
					nextOptionNumber = i + 1;
				}
			}
			catch(err){}
		}
		newTR = document.createElement("tr")
		newTR.setAttribute("id","option_"+nextOptionNumber+"_tr")
		newTD = document.createElement("td")
		newTD.innerHTML = "<table><tbody><tr><td valign='middle'><input style='display:inline;width:120px;' type='text' id='option_"+nextOptionNumber+"' name='option_"+nextOptionNumber+"'></td><td valign='middle'><a href='javascript:void(0);' style='margin-left:3px;' onClick='removeOption("+nextOptionNumber+")'><img width='16' height='16' border='0' src='<%=mainAppPath%>/images/delete.gif'></a></td></tr></tbody></table>"
		newTR.appendChild(newTD)
		el = document.getElementById("addButtonRow")
		el.parentNode.insertBefore(newTR,el)
	}

	function removeOption(number)
	{
		el = document.getElementById("option_"+number+"_tr")
		el.parentNode.removeChild(el)
	}
</script>

<%
If session("roleNumber") <= 1 Or session("canEditTemplates") Then
	canView = true
End if
If canView then
%>

<h1>New Custom Drop Down</h1>
<br/>
<form action="new-customDropDown.asp" method="post">
<table>
<%If errorString <> "" then%>
<tr style="margin-bottom:10px;">
	<td>
		<span style="color:red;font-weight:bold;"><%=errorString%></span>
	</td>
</tr>
<%End if%>
<tr>
	<td style="padding-right:10px;">
		<strong>Drop Down Name:</strong>
	</td>
	<td>
		<input type="text" name="name" id="name"/>
	</td>
</tr>
<tr>
	<td style="padding-right:10px;">
		<strong>Drop Down Label/Heading:</strong>
	</td>
	<td>
		<input type="text" name="heading" id="heading"/>
	</td>
</tr>
<tr>
<td colspan="2">
&nbsp;
</td>
</tr>
<tr>
	<td valign="top">
		<strong>Options:</strong>
	</td>
	<td>
		<table>
			<tr>
				<td>
					<table>
						<tr>
							<td>
								<input type="text" name="option_1" id="option_1" style="width:120px;">
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="addButtonRow">
				<td>
					<a href="javascript:void(0);" onclick="addOption()"><img border="0" src="<%=mainAppPath%>/images/add.gif" width="16" height="16" title="Add Option"/></a>
				</td>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right" style="padding-top:4px;" colspan="2">
		<input type="submit" name="submit" value="Save" style="float:right;padding:2px;width:60px;">
	</td>
</tr>
</table>
</form>
<%else%>
<p>Not Authorized</p>
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%Call disconnect%>