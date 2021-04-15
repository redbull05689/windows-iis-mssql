<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!--#include file="../_inclds/validation/functions/sub_ErrorChkText.asp"-->
<!--#include file="../_inclds/common/html/sub_Select_From_Table.asp"-->
<!--#include file="../_inclds/validation/functions/fnc_validate_phoneZipEmail.asp"-->
<!--#include file="../_inclds/validation/functions/fnc_validatePassword.asp"-->
<!--#include file="../_inclds/escape_and_filter/functions/fnc_Date_Add_Zeros.asp"-->
<%
Dim temp()
Dim multis()
ReDim multis(UBound(fields))

Dim cacheInvalidateUrl 
cacheInvalidateUrl = getCompanySpecificSingleAppConfigSetting("configServiceEndpointUrl", session("companyId"))&_
													"/cache/purge/"&session("companyId")&"?inputModel.appName=ELN"


If addItemDivId = "" Then
addItemDivId = "addItemDiv"
End if

Function EscapeQuotes(inStr)
	if isnull(inStr) then
		inStr = ""
	end if
	EscapeQuotes = Replace(inStr,"""","&quot;")
end Function


Function HTMLDecode(sText)
    Dim I
		if isnull(sText) then
			sText = ""
		end if
    sText = Replace(sText, "&quot;", Chr(34))
    sText = Replace(sText, "&lt;"  , Chr(60))
    sText = Replace(sText, "&gt;"  , Chr(62))
    sText = Replace(sText, "&amp;" , Chr(38))
    sText = Replace(sText, "&nbsp;", Chr(32))
    For I = 1 to 255
        sText = Replace(sText, "&#" & I & ";", Chr(I))
    Next
    HTMLDecode = sText
End Function

Set fieldColumns=Server.CreateObject("Scripting.Dictionary")
for i = 0 to ubound(fields)
	if fields(i)(dbName) <> "none" then
		fieldColumns.Add fields(i)(dbName),i
		'response.write( fields(i)(dbName) &"="&i&" " )
	end if
next

for i = 0 to ubound(fields)
	if UBound(fields(i)) = 13 Then
		If fields(i)(sqlType) = "number" then
			lineStr = Join(fields(i),":")&":0"
		Else
			lineStr = Join(fields(i),":")&":"
		End if
		fields(i) = Split(lineStr,":")
	end if
next

%>

<!--<script src="/_inclds/fckeditor/fckeditor.js" type="text/javascript"></script>-->

<script type="text/javascript">

function getNode(text)
{
	document.getElementById("tempDiv").innerHTML = text
	return document.getElementById("tempDiv").getElementsByTagName("*")[0]
}

function getText(xmlNode)
{
	try
	{
		return (new XMLSerializer()).serializeToString(xmlNode).replace(/xmlns=".*?"/,'');
	}
  catch (e) {
      // Internet Explorer.
		return  xmlNode.outerHTML.replace(new RegExp(" selected ","g")," ")
    }
}

function addMulti(firstId,linkEl)
{
	number = parseInt(linkEl.getAttribute("number"))

	newBox = document.getElementById(firstId)
	newId = firstId.replace(/_[0-9]+$/,'') + '_'+number
	newBox = getText(newBox)
	newBox = newBox.replace(new RegExp(firstId,"gi"),newId)
	newBox = newBox.replace(new RegExp("selected=\"selected\"","g"),"")
	newBox = getNode(newBox)
	newBox.selectedIndex = 0

	el = document.getElementById(firstId+"_end")
	el.parentNode.insertBefore(newBox,el)

	//number = el.getAttribute("number")
	//newNumber = (parseInt(number)+1)
	//el.onclick = function(){eval("addPGroup('"+lastId+"','"+newNumber+"')")}
	linkEl.setAttribute("number",number + 1)

}

</script>

<!-- no submit on enter-->
<script language="JavaScript">

function disableEnterKey(e)
{
     var key;     
     if(window.event)
          key = window.event.keyCode; //IE
     else
          key = e.which; //firefox     

     return (key != 13);
}

</script>

<script type="text/javascript">

var getPos = function(owner){
	if(owner == undefined)
	{
		return {top : 0, left:0 , width : 0, height : 0};
	}

	var e = owner;
	var oTop = e.offsetTop;
	var oLeft = e.offsetLeft;
	var oWidth = e.offsetWidth;
	var oHeight = e.offsetHeight;

	while(e = e.offsetParent)
	{
		oTop += e.offsetTop;
		oLeft += e.offsetLeft;
	}
	return [oTop,oLeft]
}


<%
for i = 0 to ubound(fields)
	fieldType = split(fields(i)(formType),"*")(0)
	if fieldType = "date" then
		if fields(i)(searchEnabled) then
			response.write("var cals" & fields(i)(formName) &"= new CalendarPopup();")
		end if
		if fields(i)(addEnabled) then
			response.write("var cala" & fields(i)(formName) &"= new CalendarPopup();")
		end if
		if fields(i)(editEnabled) then
			response.write("var calu" & fields(i)(formName) &"= new CalendarPopup();")
		end if
	end if
next
%>


var plus_image  = new Image(); plus_image.src  = "/arxlab/images/plus.gif";
var minus_image = new Image(); minus_image.src = "/arxlab/images/minus.gif";

var plusHtml  = "<img src='/arxlab/images/plus.gif'>";
var minusHtml = "<img src='/arxlab/images/minus.gif'>";
var editableRowId;
var iconId;
var currentRecord;

function getInternetExplorerVersion() {

    var rv = -1; // Return value assumes failure.

    if (navigator.appName == 'Microsoft Internet Explorer') {

        var ua = navigator.userAgent;

        var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");

        if (re.exec(ua) != null)

            rv = parseFloat(RegExp.$1);

    }

    return rv;

}

function handleClick( recordNum ) 
{
	editableRowId = 'edit-' + recordNum
	iconId = 'icon-' + recordNum + '-img'
	if ( document.getElementById( iconId ).value == 'open' )
	{
		document.getElementById( iconId ).value = 'closed';
		document.getElementById( iconId ).src = plus_image.src;
		if ( navigator.appName == 'Netscape' ) 
		{
			//document.getElementById( editableRowId ).style.visibility = 'collapse';
			document.getElementById( editableRowId ).style.display = 'none';
		}
		else 
		{
		
			//document.getElementById( editableRowId ).style.visibility = 'collapse';
			document.getElementById( editableRowId ).style.display = 'none';
		}
		<%
		for i=0 to ubound(fields)
			fieldType = split(fields(i)(formType),"*")(0)
			if fieldType = "fck" and fields(i)(editEnabled) = "true" then
		%>
				containerNode = document.getElementById( 'u<%=fields(i)(formName)%>-'+recordNum + 'Container')
				for(i=0;i<containerNode.childNodes.length;i++)
				{
					if (containerNode.childNodes[i].id != 'u<%=fields(i)(formName)%>-'+recordNum)
					{
						containerNode.removeChild(containerNode.childNodes[i]);
					}
				}
		<%
			end if
		next
		%>
	}
	else 
	{
		document.getElementById( iconId ).value = 'open';
		document.getElementById( iconId ).src = minus_image.src;
		currentRecord = recordNum;
		if ( navigator.appName == 'Netscape' ) 
		{
			document.getElementById( editableRowId ).style.visibility = 'visible';

			try{
				document.getElementById( editableRowId ).style.display = 'table-row';
			}
			catch(err)
			{
				document.getElementById( editableRowId ).style.display = 'block';
			}
		}
		else
		{
			document.getElementById( editableRowId ).style.visibility = 'visible';
			if(navigator.appName=="Microsoft Internet Explorer")
			{
				if ( getInternetExplorerVersion() >= 8)
				{
					
					document.getElementById( editableRowId ).style.display = 'table-row';
				}
				else
				{
					document.getElementById( editableRowId ).style.display = 'block';
				}
				
			}
			else
			{
				try{
					document.getElementById( editableRowId ).style.display = 'table-row';
				}
				catch(err)
				{
					document.getElementById( editableRowId ).style.display = 'block';			
				}
			}
		}
			<%if editScroll <> "false" then%>
				window.scrollTo(0, getPos(document.getElementById( editableRowId ))[0]-160); 
			<%end if%>
		<%
		for i=0 to ubound(fields)
			fieldType = split(fields(i)(formType),"*")(0)
			if fieldType = "fck" and fields(i)(editEnabled) = "true" then
				args = split(fields(i)(formType),"*")
				fckWidth = args(1)
				fckHeight = args(2)
				toolbarSet = args(3)
		%>
				var oFCKeditor = new FCKeditor( 'u<%=fields(i)(formName)%>-'+recordNum ) ;
				oFCKeditor.BasePath	= "/_inclds/fckeditor/" ;
				oFCKeditor.ToolbarSet = '<%=toolbarSet%>'
				oFCKeditor.Width = <%=fckWidth%>
				oFCKeditor.Height = <%=fckHeight%>
				oFCKeditor.ReplaceTextarea() ;
		<%
			end if
		next
		%>
	}
	return true;
}


function confirmDelete()
{
	var agree = confirm("Are you sure you wish to delete this item?");
	if (agree)
		return true ;
	else
		return false ;
}




function confirmDeleteItem()
{
	var agree = confirm("Are you sure you wish to delete this item?");
	if (agree)
		return true ;
	else
		return false ;
}


function sort(sortStr)
{
	document.getElementById("sortPage").action = document.getElementById("sortPage").action + "so=" + sortStr ;
	document.getElementById("sortPage").submit();
}

function showAdvancedSearch() {
		//document.getElementById("strSearch").innerHTML = " ";
		document.getElementById("advSearch").style.display = "inline";
		document.getElementById("simpleSearch").style.display = "none";
		document.getElementById("strSearch").value = "";
		document.getElementById("searchType").value = "1";
}

function showSimpleSearch() {
		
		document.getElementById("simpleSearch").style.display = "inline";
		document.getElementById("advSearch").style.display = "none";
		document.getElementById("strSearch").value = "";
		document.getElementById("searchType").value = "0";
		<%
		for i = 0 to ubound(fields)
			if fields(i)(searchEnabled) = "true" then
				response.write(vbTab & vbTab & "document.getElementById('" & "s" & fields(i)(formName)& "').value = '';" &vbcrlf)
			end if
		next
		%>
}


function clearSearchFields() {
	if(document.getElementById("searchType").value == 0) {
		document.getElementById("strSearch").value = "";
	}
	if(document.getElementById("searchType").value == 1) {
		<%
		for i = 0 to ubound(fields)
			if fields(i)(searchEnabled) = "true" then
				response.write(vbTab & vbTab & "document.getElementById('" & "s" & fields(i)(formName)& "').value = '';" &vbcrlf)
			end if
		next
		%>
	}
}

function showAdditem() {

	if (document.getElementById("<%=addItemDivId%>").style.display == "inline") {
		document.getElementById("<%=addItemDivId%>").style.display = "none"
		}
	else {
		document.getElementById("<%=addItemDivId%>").style.display = "inline"
		<%
		for i=0 to ubound(fields)
			fieldType = split(fields(i)(formType),"*")(0)
			if fieldType = "fck" and fields(i)(addEnabled) = "true" then
				args = split(fields(i)(formType),"*")
				fckWidth = args(1)
				fckHeight = args(2)
				toolbarSet = args(3)
		%>
				var oFCKeditor = new FCKeditor( 'a<%=fields(i)(formName)%>') ;
				oFCKeditor.BasePath	= "/_inclds/fckeditor/" ;
				oFCKeditor.ToolbarSet = '<%=toolbarSet%>'
				oFCKeditor.Width = <%=fckWidth%>
				oFCKeditor.Height = <%=fckHeight%>
				oFCKeditor.ReplaceTextarea() ;
		<%
			end if
		next
		%>
		}
		
}

function gotoPage(urlLink) {

	if (urlLink != "") {
		window.open(urlLink, target="_top");
		//break;
	}

}

</script>












<%
numListColumns = 1
for i = 0 to ubound(fields)
	if fields(i)(listEnabled) = "true" then
		numListColumns = numListColumns + 1
	end if
Next
If numberRows Then
	numListColumns = numListColumns + 1
End if
Dim formVals()
ReDim formVals(ubound(fields)+1)
%>
<div id="DataTable">
<%

function InvalidateCache
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	data = "{}"
	
	'response.write cacheInvalidateUrl
	http.open "DELETE",cacheInvalidateUrl,True
	http.setRequestHeader "Content-Type","text/plain"
	http.setRequestHeader "Content-Length",Len(data)
	http.setRequestHeader "Authorization", session("jwtToken")
	http.SetTimeouts 120000,120000,120000,120000
	http.send data
end Function

function replaceSpaces(rStr)
	replaceSpaces = replace(rStr," ","-")
end Function

emailDuplicate = false
addError = false
isSupportAccount = false
onlyDuplicateError = true
formError = false
updateError = false
recordAdded = false
recordUpdated = false
if request.form("update")<>"" then
		efields = ""
		updateId = request.form("u"&fields(fieldColumns(handleClickId))(formName))

		for i = 0 to ubound(formVals)
			formVals(i) = ""
		next
		formError = false
		updateError = false
		for i = 0 to ubound(fields)
			fieldType = split(fields(i)(formType),"*")(0)
			fName = fields(i)(formName) & "-" & updateId

			If fieldType = "select" Then
				numSelects = 0
				counter = 1
				Do While request.Form("u"&fName&"_"&counter) <> ""
					counter = counter + 1
					numSelects = numSelects + 1
				Loop
				ReDim temp(numSelects)
				For r = 0 To UBound(temp)
					temp(r) = request.Form("u"&fName&"_"&(r+1))
				Next
				multis(i) = Join(temp,",")
			End if
		
			for j = 0 to ubound(split(fields(i)(validationFunction),"*"))
				If fields(i)(editEnabled) = "true" Then
				select case split(fields(i)(validationFunction),"*")(j)
					case "validateEmail"
						if validateEmail(request.form("u"&fName)) = false then
							formError = true
							updateError = true
							eFields = eFields & "u" & fields(i)(formName) & ","
						end if
					case "validateUSPhone"
						if validateUSPhone(request.form("u"&fName)) = false then
							formError = true
							updateError = true
							eFields = eFields & "u" & fields(i)(formName) & ","
						end if
					case "validateDate"
						if validateDate(request.form("u"&fName)) = false then
							formError = true
							updateError = true
							eFields = eFields & "u" & fields(i)(formName) & ","
						end if
					case "match"
						if notEmpty(request.form("u"&fName)) = false or request.form("u"&fName) <> request.form("u"&fName&"match") then
							formError = true
							updateError = true
							eFields = eFields & "u" & fields(i)(formName) & ","
							eFields = eFields & "u" & fields(i)(formName) & "match,"
						end if
					case "validatePassword"
						if validatePassword(request.form("u"&fName)) <> "valid" then
							formError = true
							updateError = True
							errorStr = validatePassword(request.form("u"&fName))
							eFields = eFields & "u" & fields(i)(formName) & ","
							eFields = eFields & "u" & fields(i)(formName) & "match,"
						end if
					case "notEmpty"
						if notEmpty(request.form("u"&fName)) = false or (request.form("u"&fName) = "-1" and fieldType = "select") then
							formError = true
							updateError = true
							eFields = eFields & "u" & fields(i)(formName) & ","
						end If
					Case "isNumeric"
						If fields(i)(sqlType) = "number" Then
							If Not IsNumeric(request.form("u"&fName)) Then
								formError = true
								updateError = true
								eFields = eFields & "u" & fields(i)(formName) & ","							
							End if
						End if
					case "replaceSpaces"
						formVals(i) = replaceSpaces(request.form("u"&fName))
					case "none"

				end Select
				End if
			next
		next
		if formError = false then
			call getconnectedadm

			Set pre_rs = Server.CreateObject("ADODB.RecordSet")
			preQuery = "SELECT * FROM " & tableName & " WHERE " & updateKey & "=" & SQLClean(request.form("u"&fields(fieldColumns(updateKey))(formName)),"N","S")
			pre_rs.Open preQuery,ConnAdm,3,3 
			Set preUpdate=Server.CreateObject("Scripting.Dictionary")
			Set postUpdate=Server.CreateObject("Scripting.Dictionary")

			strQuery = "UPDATE " & tableName & " SET "
			for i = 0 to ubound(fields)
				if fields(i)(editEnabled) = "true"  and fields(i)(dbName) <> "none" then
					fName = fields(i)(formName) & "-" & updateId
					select case fields(i)(sqlType)
					case "text"
						if formVals(i) = "" then
							strQuery = strQuery & fields(i)(dbName) & "=" & SQLClean(Server.HTMLEncode(request.form("u"&fName)),"T","S") & ","
							preUpdate.Add fields(i)(dbName),trim(pre_rs(fields(i)(dbName)))
							postUpdate.Add fields(i)(dbName),request.form("u"&fName)
						else
							strQuery = strQuery & fields(i)(dbName) & "=" & SQLClean(Server.HTMLEncode(formVals(i)),"T","S") & ","
							preUpdate.Add fields(i)(dbName),trim(pre_rs(fields(i)(dbName)))
							postUpdate.Add fields(i)(dbName),formVals(i)
						end If
					'pw_stuff
					case "password"
						if formVals(i) = "" then
							strQuery = strQuery & fields(i)(dbName) & "=" & SQLClean(Server.HTMLEncode(request.form("u"&fName)),"PW","S") & ","
							preUpdate.Add fields(i)(dbName),trim(pre_rs(fields(i)(dbName)))
							postUpdate.Add fields(i)(dbName),request.form("u"&fName)
						else
							strQuery = strQuery & fields(i)(dbName) & "=" & SQLClean(Server.HTMLEncode(formVals(i)),"PW","S") & ","
							preUpdate.Add fields(i)(dbName),trim(pre_rs(fields(i)(dbName)))
							postUpdate.Add fields(i)(dbName),formVals(i)
						end if
					case "number"
						if formVals(i) = "" then
							strQuery = strQuery & fields(i)(dbName) & "=" & SQLClean(request.form("u"&fName),"N","S") & ","
							preUpdate.Add fields(i)(dbName),trim(pre_rs(fields(i)(dbName)))
							postUpdate.Add fields(i)(dbName),request.form("u"&fName)
						else
							strQuery = strQuery & fields(i)(dbName) & "=" & SQLClean(formVals(i),"N","S") & ","
							preUpdate.Add fields(i)(dbName),trim(pre_rs(fields(i)(dbName)))
							postUpdate.Add fields(i)(dbName),formVals(i)
						end if
					case "fck"
						if formVals(i) = "" then
							strQuery = strQuery & fields(i)(dbName) & "='" & Server.HTMLEncode(Replace(request.form("u"&fName),"'","''")) & "',"
						else
							strQuery = strQuery & fields(i)(dbName) & "='" & Server.HTMLEncode(Replace(formVals(i),"'","''")) & "',"
						end if
					end select
				end if
			next
			strQuery = mid(strQuery,1,len(strQuery)-1)

			select case fields(fieldColumns(updateKey))(sqlType)
			case "number"
				strQuery = strQuery & " WHERE " & updateKey & "=" & SQLClean(request.form("u"&fields(fieldColumns(updateKey))(formName)),"N","S")
			case "text"
				strQuery = strQuery & " WHERE " & updateKey & "=" & SQLClean(request.form("u"&fields(fieldColumns(updateKey))(formName)),"T","S")
			end select
			if globalFilterKey <> "" then
				strQuery = strQuery & " AND " & globalFilterKey & "=" & SQLClean(globalFilterValue,"N","S")
			end if
				'response.write strQuery
				On Error Resume Next
				ConnAdm.Execute strQuery
				If Err.number = 0 Then
					recordUpdated = true
				Else
					recordError = True
				End If

				On Error goto 0		

				'get current file name
				my_array=split(Request.ServerVariables("SCRIPT_NAME"),"/")
				fname=my_array(ubound(my_array))

				For i = 0 To UBound(fields)
					fieldType = split(fields(i)(formType),"*")(0)
					If fieldType = "select" Then
						args = split(fields(i)(formType),"*")
						If UBound(args) = 9 Then
							table = args(7)
							recordId = args(8)
							valueId = args(9)
							multi = Split(multis(i),",")
							strQuery = "DELETE FROM "&table&" WHERE  "&recordId&"="&SQLClean(updateId,"N","S")
							connAdm.execute(strQuery)

							'invalidate company cache if we are updating groups							
							If fname = "groups.asp" Then
								InvalidateCache
							End If

							For j = 0 To UBound(multi)
								If multi(j) <> "-1" And multi(j) <> "" then
									strQuery = "INSERT INTO " & table & "("&recordId&","&valueId&",companyId) values(" &_
									SQLClean(updateId,"N","S") & "," &_
									SQLClean(multi(j),"N","S") & "," &_
									SQLClean(session("companyId"),"N","S") & ")"
									' 9132: check for Violation of UNIQUE KEY constraint
									On Error Resume Next
									connadm.execute(strQuery)
									If Err.number <> 0 Then
										errMsg = err.Description
										If InStr(errMsg, "duplicate key") Then
											errMsg = "Error: Cannot insert duplicate key."
										Else
											errMsg = "There was an error adding the new values. Please try again or contact Arxspan support."
										End If
%>
										<p style="color:red;text-align:left;margin-top:0px;"><%=errMsg%></p>
<%	
									End If
									On Error goto 0		
								End if
							next
							multis(i) = ""
						End if
					End if
				next

				call disconnectadm
				recordUpdated = true
			end if
end if

if request.form("delete")<>"" then
		'make sure this is the right sub
		call getconnectedadm
		
		If subSectionId <> "users" And subSectionId <> "reg-users" And subSectionId <> "admin-users" then
			select case fields(fieldColumns(deleteKey))(sqlType)
				case "number"
					strQuery = "DELETE FROM " & tableName & " WHERE " & fields(fieldColumns(deleteKey))(dbname) & "=" & SQLClean(request.form("u"&fields(fieldColumns(deleteKey))(formName)), "N", "S")
				case "text"
					strQuery = "DELETE FROM " & tableName & " WHERE " & fields(fieldColumns(deleteKey))(dbname) & "=" & SQLClean(request.form("u"&fields(fieldColumns(deleteKey))(formName)), "T", "S")
			end Select
		Else
			select case fields(fieldColumns(deleteKey))(sqlType)
				case "number"
					strQuery = "update " & tableName & " set enabled=0 WHERE " & fields(fieldColumns(deleteKey))(dbname) & "=" & SQLClean(request.form("u"&fields(fieldColumns(deleteKey))(formName)), "N", "S")
				case "text"
					strQuery = "update " & tableName & " set enabled=0 WHERE " & fields(fieldColumns(deleteKey))(dbname) & "=" & SQLClean(request.form("u"&fields(fieldColumns(deleteKey))(formName)), "T", "S")
			end Select
		End if
		if globalFilterKey <> "" then
			strQuery = strQuery & " AND " & globalFilterKey & "=" & SQLClean(globalFilterValue,"N","S")
		end if
		ConnAdm.Execute strQuery
		For i = 0 To UBound(fields)
			fieldType = split(fields(i)(formType),"*")(0)
			If fieldType = "select" Then
				args = split(fields(i)(formType),"*")
				If UBound(args) = 9 Then
					table = args(7)
					recordId = args(8)
					valueId = args(9)
					multi = Split(multis(i),",")
					strQuery = "DELETE FROM "&table&" WHERE  "&recordId&"="&SQLClean(request.form("u"&fields(fieldColumns(deleteKey))(formName)),"N","S")
					connAdm.execute(strQuery)
					multis(i) = ""
				End if
			End if
		next
		call disconnectadm	
end if

if request.form("addItem")<>"" then
		formError = false
		addError = false
		emailDuplicate = false
		onlyDuplicateError = true
		b_isAdminUser = false
		efields = ""

		for i = 0 to ubound(formVals)
			formVals(i) = ""
		next

		for i = 0 to ubound(fields)
			fieldType = split(fields(i)(formType),"*")(0)
			If fieldType = "select" Then
				numSelects = 0
				counter = 1
				Do While request.Form("a"&fields(i)(formName)&"_"&counter) <> ""
					counter = counter + 1
					numSelects = numSelects + 1
				Loop
				ReDim temp(numSelects)
				For r = 0 To UBound(temp)
					temp(r) = request.Form("a"&fields(i)(formName)&"_"&(r+1))
				Next
				multis(i) = Join(temp,",")
			End If
		
        'check email address duplicated or not'
		Call getconnected
		Set rec3 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM users WHERE email="&SQLClean(request.form("a"&fields(i)(formName)),"T","S")
		rec3.open strQuery,connAdm,3,3
		counter = 0
		Do While Not rec3.eof
			counter = counter + 1
			rec3.movenext
		loop
		If counter > 0 Then
			emailDuplicate = true
		End If
		rec3.close
		Set eRec = Nothing
		Call disconnect


			If fields(i)(dbName) = "email" And globalFilterKey<>"" Then
				Call getconnectedadm
				Set eRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM "&tableName&" WHERE email="&SQLClean(request.form("a"&fields(i)(formName)),"T","S")&" AND "&globalFilterKey & "=" & SQLClean(globalFilterValue,"N","S")
				eRec.open strQuery,connAdm,0,-1
				If Not eRec.eof Then
					formError = true
					addError = true
					eFields = eFields & "a" & fields(i)(formName) & ","
				End If
				eRec.close
				Set eRec = Nothing
				Call disconnectAdm
			End if
			for j = 0 to ubound(split(fields(i)(validationFunction),"*"))
				select case split(fields(i)(validationFunction),"*")(j)
					case "validateEmail"
						if validateEmail(request.form("a"&fields(i)(formName))) = false then
							formError = true
							addError = true
							onlyDuplicateError = false
							eFields = eFields & "a" & fields(i)(formName) & ","
						end if
					case "validateUSPhone"
						if validateUSPhone(request.form("a"&fields(i)(formName))) = false then
							formError = true
							addError = true
							onlyDuplicateError = false
							eFields = eFields & "a" & fields(i)(formName) & ","
						end if
					case "validateDate"
						if validateDate(request.form("a"&fields(i)(formName))) = false then
							formError = true
							addError = true
							onlyDuplicateError = false
							eFields = eFields & "a" & fields(i)(formName) & ","
						end if
					case "match"
						if notEmpty(request.form("a"&fields(i)(formName))) = false or request.form("a"&fName) <> request.form("a"&fName&"match") then
							formError = true
							addError = true
							onlyDuplicateError = false
							eFields = eFields & "a" & fields(i)(formName) & ","
							eFields = eFields & "a" & fields(i)(formName) & "match,"
						end If
					case "validatePassword"
						if validatePassword( request.form("a"&fields(i)(formName)) ) <> "valid" then
							formError = true
							addError = True
							onlyDuplicateError = false
							errorStr = validatePassword(request.form("a"&fields(i)(formName)))
							eFields = eFields & "a" & fields(i)(formName) & ","
							eFields = eFields & "a" & fields(i)(formName) & "match,"
						end if
					case "notEmpty"
						if notEmpty(request.form("a"&fields(i)(formName))) = false  or (request.form("a"&fields(i)(formName)) = "-1" and fieldType = "select") then
							formError = true
							addError = true
							onlyDuplicateError = false
							eFields = eFields & "a" & fields(i)(formName) & ","
						end if
					case "replaceSpaces"
						formVals(i) = replaceSpaces(request.form("a"&fields(i)(formName)))
					Case "isNumeric"
						If fields(i)(sqlType) = "number" Then
							If Not IsNumeric(request.form("a"&fields(i)(formName))) Then
								formError = true
								addError = true
								onlyDuplicateError = false
								eFields = eFields & "a" & fields(i)(formName) & ","							
							End if
						End if
					case "none"

				end select
			'if ubound(fields(i)) > 13 then
			'	if fields(i)(defaultValue) <> "" and fields(i)(defaultValue) <> "none" then
			'		formVals(i) = fields(i)(defaultValue)
			'	end if
			'end if
			next
		next


		namesString = "("
		for i = 0 to ubound(fields)
			if (fields(i)(addEnabled) = "true" or fields(i)(addEnabled) = "true*hidden")  and fields(i)(dbName) <> "none" then
				namesString = namesString & fields(i)(dbName) & ","
			end if
		next
		
		if globalFilterKey <> "" then
			namesString = namesString & globalFilterKey & ","
		end if

		if dateCreatedKey <> "none" And dateCreatedKey <> "" then
			namesString = namesString & dateCreatedKey & ","
		end if
		namesString = mid(namesString,1,len(namesString)-1) & ")"
		'response.write(namesString)



		if formError = false then
			Set postUpdate=Server.CreateObject("Scripting.Dictionary")
			selString = ""
			valuesString = "("
			for i = 0 to ubound(fields)
				if (fields(i)(addEnabled) = "true" or fields(i)(addEnabled) = "true*hidden") and fields(i)(dbName) <> "none" then
						select case fields(i)(sqlType)
						case "text"
							if formVals(i) = "" then
								valuesString = valuesString  & SQLClean(Server.HTMLEncode(request.form("a" & fields(i)(formName))),"T","S") & ","
								'QQQ
								If request.form("a" & fields(i)(formName)) <> "" then
									selString = selString & " AND " &  fields(i)(dbname) &"=" & SQLClean(Server.HTMLEncode(request.form("a" & fields(i)(formName))),"T","S")
								End if
								postUpdate.Add fields(i)(dbName),request.form("a" & fields(i)(formName))
							else
								valuesString = valuesString  & SQLClean(Server.HTMLEncode(formVals(i)),"T","S") & ","
								selString = selString & " AND " &  fields(i)(dbname) &"=" & SQLClean(Server.HTMLEncode(formVals(i)),"T","S") 
								postUpdate.Add fields(i)(dbName),formVals(i)
							end if
						'pw_stuff
						case "password"
							if formVals(i) = "" then
								valuesString = valuesString & SQLClean(Server.HTMLEncode(request.form("u"&fName)),"PW","S") & ","
								postUpdate.Add fields(i)(dbName),request.form("u"&fName)
							else
								valueString = valuesString & SQLClean(Server.HTMLEncode(formVals(i)),"PW","S") & ","
								postUpdate.Add fields(i)(dbName),formVals(i)
							end if
						case "number"
							if formVals(i) = "" then
								If (fields(i)(defaultValue) = "" And Not fields(i)(addEnabled) = "true*hidden") Or (fields(i)(defaultValue) <> "" And  request.form("a" & fields(i)(formName)) <> "") then
									valuesString = valuesString  & SQLClean(request.form("a" & fields(i)(formName)),"N","S") & ","
									'QQQ
									If request.form("a" & fields(i)(formName)) <> "" then
										selString = selString & " AND " &  fields(i)(dbname) &"=" & SQLClean(request.form("a" & fields(i)(formName)),"N","S")
									End if
									postUpdate.Add fields(i)(dbName),request.form("a" & fields(i)(formName))
								Else
									valuesString = valuesString  & SQLClean(fields(i)(defaultValue),"N","S") & ","
									selString = selString & " AND " &  fields(i)(dbname) &"=" & SQLClean(fields(i)(defaultValue),"N","S")
									postUpdate.Add fields(i)(dbName),fields(i)(defaultValue)
								End If
							else
								valuesString = valuesString  & SQLClean(formVals(i),"N","S") & ","
								selString = selString & " AND " &  fields(i)(dbname) &"=" & SQLClean(formVals(i),"N","S")
								postUpdate.Add fields(i)(dbName),formVals(i)
							end if
						case "file"
							if formVals(i) = "" then
								valuesString = valuesString  & SQLClean(request.form("a" & fields(i)(formName)),"T","S") & ","
								selString = selString & " AND " &  fields(i)(dbname) &"=" & SQLClean(request.form("a" & fields(i)(formName)),"T","S")
							else
								valuesString = valuesString  & SQLClean(formVals(i),"T","S") & ","
								selString = selString & " AND " &  fields(i)(dbname) &"=" & SQLClean(formVals(i),"T","S")
							end if
						case "fck"
							if formVals(i) = "" then
								valuesString = valuesString  & "'" & Server.HTMLEncode(Replace(request.form("a"&fields(i)(formName)&updateId),"'","''")) & "',"
								postUpdate.Add fields(i)(dbName),request.form("a" & fields(i)(formName)&updateId)
							else
								valuesString = valuesString  & "'" & Server.HTMLEncode(Replace(formVals(i),"'","''")) & "',"
								postUpdate.Add fields(i)(dbName),formVals(i)
							end if
						end select
				end if
			next
			if globalFilterKey <> "" then
				valuesString = valuesString & SQLClean(globalFilterValue,"N","S") & ","
			end if

			if dateCreatedKey <> "none" And dateCreatedKey <> "" then
				valuesString = valuesString & SQLClean(FormatDateTime( now(), 0 ), "T", "S") & ","
			end if
			valuesString = mid(valuesString,1,len(valuesString)-1)
			valuesString=valuesString & ")"
			'response.write(valuesString)
			'response.write(formerror)

			call getconnectedadm
			strQuery = "INSERT into " & tableName & " " & namesString & " output inserted.id as newId  VALUES " & valuesString &""
	
			'response.write "<br><br>" & strQuery
			On Error Resume Next
			Set rs = connAdm.execute(strQuery)
			newUserId = rs("newId")

            subtring = Mid(valuesString, 1, InStrRev(valuesString,",")-1) 
            theid = Mid(subtring,InStrRev(subtring,",")-1,1)
            if theid = "1" then
               b_isAdminUser =  true
            end if

			If Err.number = 0 Then
				recordAdded = True
			Else
				recordError = True
			End If

			Set id_rs = Server.CreateObject("ADODB.RecordSet")
			strQuery =	  "SELECT " & deleteKey & " FROM " & tableName & " WHERE 1=1 " & selString & " ORDER BY "&deleteKey & " DESC"
			id_rs.Open strQuery,ConnAdm,3,3 
			if not id_rs.eof then
				newId = id_rs(deleteKey)
			end if

			If subSectionId = "reg-users" Then
				if recordAdded = true then
					usersTable = getDefaultSingleAppConfigSetting("usersTable")
					strQuery8 = "UPDATE "&usersTable&" SET userAdded="&SQLClean(session("userId"),"N","S")&",roleId=5 WHERE id="&SQLClean(newId,"N","S")
					connAdm.execute(strQuery8)
				End if
			End if
			
			For i = 0 To UBound(fields)
				fieldType = split(fields(i)(formType),"*")(0)
				If fieldType = "select" Then
					args = split(fields(i)(formType),"*")
					If UBound(args) = 9 Then
						table = args(7)
						recordId = args(8)
						valueId = args(9)
						multi = Split(multis(i),",")
						For j = 0 To UBound(multi)
							If multi(j) <> "-1" And multi(j) <> "" then
								strQuery = "INSERT INTO " & table & "("&recordId&","&valueId&",companyId) values(" &_
								SQLClean(newId,"N","S") & "," &_
								SQLClean(multi(j),"N","S") & "," &_
								SQLClean(session("companyId"),"N","S") & ")"
								connadm.execute(strQuery)
							End if
						next
						multis(i) = ""
					End if
				End if
			next

			strQuery2 = "UPDATE USERS SET SERVICESCONNECTIONID = CONVERT(varchar(50),newid()) WHERE ID=" & SQLClean(newId,"N","S")
			connadm.execute(strQuery2)

            rs.close
			set rs = nothing

			call disconnectadm
			On Error goto 0

		end if
end if
%>

<%			

'Dim Encrypt
'Dim FormEnc
'dim searchType
'searchType = 0
    	
    	
					Dim users
					Dim iStart,iOffset,Strquery,dir,iStop,iRowLoop,iRows,iCols
					Dim RS,isprocessed,iPages,filetitle
					Dim changecolor,bgcolor,sortby,sortdir,allowChar
					Dim ID,depNumber,Project,lotNumber,Street,Applicant,OoCORAD,Rec,Extend,PartialCOC,strSearch
					allowedChar = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<>,./?:[]{}\|+-_)(*&^$#@!~` "
					iStart = Request("Start")
					iOffset = Request("Offset")
					
					if Not IsNumeric(iStart) or Len(iStart) = 0 then
						iStart = 0
					else
						iStart = CInt(iStart)
					end if
					
					if Not IsNumeric(iOffset) or Len(iOffset) = 0 then
						iOffset = 15
					else
						iOffset = Cint(iOffset)
					end if
					
					
					call getconnectedadm
					Set rec = Server.CreateObject("ADODB.RecordSet")

					strQuery = "SELECT "
					for i = 0 to ubound(fields)
						if fields(i)(dbName) <> "none" then
							strQuery = strQuery & fields(i)(dbName) & ","
						end if
					Next
					addFields = Split(additionalFields,",")
					for i = 0 to ubound(addFields)
						strQuery = strQuery & addFields(i) & ","
					next					
					strQuery = mid(strQuery,1,len(strQuery)-1)
					strQuery = strQuery & " FROM " & viewName & " WHERE 1=1 "

						for i = 0 to ubound(fields)
							if fields(i)(searchEnabled) = "true" then
								If request("s"&fields(i)(formName)) <>"" then
									if fields(i)(sqlType) = "text" or fields(i)(sqlType) = "file" then 
										strQuery = strQuery & " and "&fields(i)(dbName)&" Like (" &  sqlClean("%"&AllowOnlyChar(request("s"&fields(i)(formName)),allowedChar)&"%","T","S")&")"
									end if

									if fields(i)(sqlType) = "number" then
										recordsFound = False
										searchTranslateExists = False
										if ubound(fields(i)) > 14 then
											if fields(i)(searchTranslate) <> "" then
												searchTranslateExists = True
												tmp = split(fields(i)(searchTranslate),"*")
												translateTable = tmp(0)
												translateField = tmp(1)
												translateId = tmp(2)
												Set trans = Server.CreateObject("ADODB.RecordSet")
												transQuery = "SELECT " & translateId & " FROM " & translateTable & " WHERE " & translateField & "=" &  sqlClean(AllowOnlyChar(request("s"&fields(i)(formName)),allowedChar),"T","S")
												if globalFilterKey <> "" then
													transQuery = transQuery & " AND " & globalFilterKey & "=" & SQLClean(globalFilterValue,"N","S")
												end if
												trans.Open transQuery,ConnAdm,3,3 
												if not trans.eof then
													strQuery = strQuery & " AND ( "
													recordsFound = True
												end if
												do while not trans.eof
													strQuery = strQuery & fields(i)(dbName)&"=" &  sqlClean(AllowOnlyChar(trans(translateId),allowedChar),"N","S") & " OR "
													trans.moveNext
												loop
												if recordsFound = True then
													strQuery = strQuery & "1=2)"
												end if
											end if
										end if
										if recordsFound = False  then
											if searchTranslateExists = True then
												strQuery = strQuery & " and "&fields(i)(dbName)&"=" &  sqlClean(AllowOnlyChar("0",allowedChar),"N","S")
											else
												strQuery = strQuery & " and "&fields(i)(dbName)&"=" &  sqlClean(AllowOnlyChar(request("s"&fields(i)(formName)),allowedChar),"N","S")
											end if 
										end if
									end if
								End if
							end if
						next
						if globalFilterKey <> "" then
							strQuery = strQuery & " AND " & globalFilterKey & "=" & SQLClean(globalFilterValue,"N","S")
						end If
						If viewExtra <> "" Then
							strQuery = strQuery & " AND " & viewExtra
						End if
												
						If request("strSearch")<>"" then
						str = "%" & AllowOnlyChar(request("strSearch"),allowedChar & vbnewline) & "%"
							strQuery = strQuery & " and ("
							for i = 1 to ubound(fields)
								if fields(i)(searchEnabled) = "true" then
									strQuery = strQuery & fields(i)(dbName) & " " & "LIKE('" & str & "') or "
								end if
							next
							strQuery = strQuery & "1=2)"
						End if
						

					select case QSClean(request("d"))
					Case "1"
						sortdir= "ASC"
						curdir="1"
						dir="2"
					Case "2"
						sortdir= "DESC"
						curdir="2"
						dir="1"
					case else
						sortdir= "ASC"
						curdir="1"
						dir="2"
					End Select
					
					
					if request("o") <> "" then
						tmp = request("o")
						sortby = fields(fieldColumns(tmp))(dbName)
						sortby = tmp
					else
						sortby = fields(fieldColumns(defaultSort))(dbName)
					end if
					'response.write(sortby)

					If sortdir<>"" then
						strQuery = strQuery & " order by " & Replace(SQLClean(sortby,"T","S"),"'","") & " " & sortdir
					End If
					'response.write strQuery&"<br>"

					rec.Open strQuery,ConnAdm,3,3 
					
	%>