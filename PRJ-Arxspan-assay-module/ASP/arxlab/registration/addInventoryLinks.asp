<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("regRoleNumber") <= 20 then
	cdId = request.querystring("cdId")
	Set links = JSON.parse(join(array(request.querystring("links"))))
	Call getconnectedJchemReg
	For Each item in links
		If item.Get("id")<>"" then
			strQuery = "INSERT INTO inventoryLinks(barcode,name,amount,inventoryId,cdId) values("&_
						SQLClean(item.Get("barcode"),"T","S") & "," &_
						SQLClean(item.Get("name"),"T","S") & "," &_
						SQLClean(item.Get("amount"),"T","S") & "," &_
						SQLClean(item.Get("id"),"N","S") & "," &_
						SQLClean(cdId,"N","S") & ")"
			jchemRegConn.execute(strQuery)
		End if
	Next
	Call disconnectJchemReg	
End if
%>