<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/connection.asp"-->
<%isArxLoginScript = True%>
<%
' This expects two query params, an action (SIGN|WITNESS) and a key, the key is a UUID that it uses to make sure that this is the right request and so that the user can not replay the sign request

action = request.querystring("action")

If action = "SIGN" Then
	if checkkeysMatch() Then
		if session("ssoexperimenttype") = "5" then
		%>
			<script type="text/javascript">
				document.cookie = "ssoKey<%=session("SSOPageKey")%>=type5;path=/";
				window.close();
			</script>

		<%
		else
		%>
			<script type="text/javascript">
				document.cookie = "ssoKey<%=session("SSOPageKey")%>=sign;path=/";
				window.close();
			</script>
		<%
		end if
	else
		%>
		<script type="text/javascript">
			alert("Sign Failed. Please try again.");
		</script>
		<%

	end if
	disconnectadm
ElseIf action = "WITNESS" Then
 	if checkkeysMatch() then
		%>
		<script type="text/javascript">
			document.cookie = "ssoKey<%=session("SSOPageKey")%>=witness;path=/";
			window.close();
		</script>
		<%
	end if
End If

'Clear out the Session SSO state Data
Session.Contents.Remove("ssostate")
Session.Contents.Remove("ssoexperimentid")
Session.Contents.Remove("ssoexperimenttype")
Session.Contents.Remove("ssopagekey")
Session.Contents.Remove("ssoredirecturl")
Session.Contents.Remove("ssorequestid")
Session.Contents.Remove("ssorequestrevisionid")

function checkkeysMatch()
	if request.querystring("key") = session("SSOTempKey") and session("SSOTempKey") <> None Then
		checkkeysMatch = true
	else
		checkkeysMatch = false
	end if
	Session.Contents.Remove("ssotempkey")
end function 
%>