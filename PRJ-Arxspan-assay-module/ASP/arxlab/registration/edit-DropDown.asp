<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
subsectionId = "custom-dropDowns"
%>
<!-- #include file="../_inclds/globals.asp"-->

	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	

<%
If Not session("regRegistrar") Or session("regRegistrarRestricted") Then
	response.redirect(mainAppPath&"/static/error.asp")
End if
%>

<%
ddId = request.querystring("id")
If session("regRegistrar") And not session("regRegistrarRestricted") And (ddId <> "" Or request.Form("submit") <> "" )Then
	Call getconnectedJchemReg
	Set rec=server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM regDropDowns WHERE id="&SQLClean(ddId,"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		heading = rec("heading")
		name = rec("name")
		ddName = name
		canView = true
	End If
	Call disconnectJchemReg
End if
%>

<%
If request.Form("submit")<>"" Then
	Call getconnectedJchemReg
	name = request.Form("name")
	heading = request.Form("heading")
	If name = "" Then
		errorString = "You must enter a name."
	Else
		If Trim(name) <> Trim(ddName) then
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * from regDropDowns WHERE name="&SQLClean(Trim(name),"T","S")
			rec.open strQuery,jchemRegConn,3,3
			If Not rec.eof Then
				errorString = "A drop down with this name already exists."
			End If
			rec.close
			Set rec = Nothing
		End if
	End If
	
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * from regDropDowns WHERE id="&SQLClean(ddId,"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If rec.eof Then
		errorString = "You do not own this drop down."
	End If
	rec.close
	Set rec = nothing

	If errorString = "" Then
		Call getconnectedJchemReg
		strQuery = "UPDATE regDropDowns SET name="&SQLClean(name,"T","S")& ",heading="&SQLClean(heading,"T","S") & " WHERE id="&SQLClean(ddId,"N","S")
		jchemRegConn.execute(strQuery)
		strQuery = "DELETE FROM regDropDownOptions WHERE parentId="&SQLClean(ddId,"N","S")
		jchemRegConn.execute(strQuery)
		For i = 1 To 300
			If request.Form("option_"&i) <> "" Then
				strQuery = "INSERT INTO regDropDownOptions(parentId,value) values(" &_
					SQLClean(ddId,"N","S") & "," &_
					SQLClean(request.Form("option_"&i),"T","S") & ")"
				jchemRegConn.execute(strQuery)
			End if
		next
		Call disconnectJchemReg
		response.redirect("customDropDowns.asp")
	Else
		count = 0
		arrStr = ""
		For i = 1 To 300
			If request.Form("option_"&i) <> "" Then
				count = count + 1
				arrStr = arrStr & request.Form("option_"&i) & "$%^&"
			End if
		Next
		If count >=1 Then
			arrStr = Mid(arrStr,1,Len(arrStr)-4)
		End If
		optionsArr = Split(arrStr,"$%^&")
	End if
	Call disconnectJchemReg
End if
%>

<script type="text/javascript">
	function addOption()
	{
		nextOptionNumber = 0
		for (i=0;i<300 ;i++ )
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
		newDiv = document.createElement("div")
		newDiv.innerHTML = "<table><tr><td valign='middle'><input style='display:inline;width:120px;' type='text' id='option_"+nextOptionNumber+"' name='option_"+nextOptionNumber+"'></td><td valign='middle'><a href='javascript:void(0);' style='margin-left:3px;' onClick='removeOption("+nextOptionNumber+")'><img width='16' height='16' border='0' src='<%=mainAppPath%>/images/delete.gif'></td></tr></table>"
		newTD.appendChild(newDiv)
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
If session("regRegistrar") And not session("regRegistrarRestricted") then
	canView = true
End if
If canView then
%>

<h1>Edit Custom Drop Down</h1>
<br/>
<form action="edit-DropDown.asp?id=<%=ddId%>" method="post">
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
		<input type="text" name="name" id="name" value="<%=name%>"/>
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
		<%If request.Form("submit") <> "" then%>
			<table>
				<%If arrStr <> "" then%>
					<tr><td><table><tr><td><input type="text" name="option_1" id="option_1" style="width:120px;" value="<%=optionsArr(0)%>"></td></tr></table></td></tr>
				<%else%>
					<tr><td><table><tr><td><input type="text" name="option_1" id="option_1" style="width:120px;" ></td></tr></table></td></tr>
				<%End if%>
				<%For i = 1 To UBound(optionsArr)%>
					<tr id="option_<%=i%>_tr"><td><table><tr><td valign='middle'><input style='display:inline;width:120px;' type='text' id='option_<%=i%>' name='option_<%=i%>' value="<%=optionsArr(i)%>"></td><td valign='middle'><a href='javascript:void(0);' style='margin-left:3px;' onClick='removeOption(<%=i%>)'><img width='16' height='16' border='0' src='<%=mainAppPath%>/images/delete.gif'></td></tr></table></a></td></tr>
				<%next%>
				<tr id="addButtonRow">
					<td>
						<a href="javascript:void(0);" onclick="addOption()"><img border="0" src="<%=mainAppPath%>/images/add.gif" width="16" height="16" title="Add Option"/></a>
					</td>
				</tr>
			</table>
		<%else%>
			<table>
				<%
				Call getconnectedJchemReg
				Set rec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM regDropDownOptions WHERE parentId="&SQLClean(ddId,"N","S")
				rec.open strQuery,jchemRegConn,3,3
				If rec.eof Then%>
					<tr><td><table><tr><td><input type="text" name="option_1" id="option_1" style="width:120px;" ></td></tr></table></td></tr>				
				<%else%>
					<tr><td><table><tr><td><input type="text" name="option_1" id="option_1" style="width:120px;" value="<%=rec("value")%>"></td></tr></table></td></tr>
				<%
					rec.moveNext
					count = 1
					Do While Not rec.eof
						count = count + 1
						%>
							<tr id="option_<%=count%>_tr"><td><table><tr><td valign='middle'><input style='display:inline;width:120px;' type='text' id='option_<%=count%>' name='option_<%=count%>' value="<%=rec("value")%>"></td><td valign='middle'><a href='javascript:void(0);' style='margin-left:3px;' onClick='removeOption(<%=count%>)'><img width='16' height='16' border='0' src='<%=mainAppPath%>/images/delete.gif'></td></tr></table></a></td></tr>
						<%
						rec.moveNext
					loop
				End If
				rec.close
				Set rec = nothing
				%>
				<tr id="addButtonRow">
					<td>
						<a href="javascript:void(0);" onclick="addOption()"><img border="0" src="<%=mainAppPath%>/images/add.gif" width="16" height="16" title="Add Option"/></a>
					</td>
				</tr>
			</table>
		<%End if%>
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