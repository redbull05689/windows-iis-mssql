<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId = "header-notifications"%>
<!-- #include file="../_inclds/globals.asp"-->
<%
'no longer used
'was used to get the number of notifications a user had for display in the masthead
call getconnected
set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT id FROM notifications WHERE dismissed=0 and userId="&SQLClean(session("userId"),"N","S")
rec.open strQuery,conn,1,1
numNotifications = rec.recordcount
%>
<div style="position:relative;"><span class="textOnImage overlayText" style="top:-2px;margin-left:5px;"><%=numNotifications%></span><a href="<%=mainAppPath%>/dashboard.asp"><img src="<%=mainAppPath%>/images/phone.gif" border="0"></a><%If numNotifications > 0 then%><span style="color:black;font-weight:bold;font-size:10px;margin-left:8px;"><%=newNotificationsLabel%><%End if%></div>
<%
rec.close
Set rec = nothing
%>