<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../arxlab/_inclds/globals.asp"-->
<%
isArxLoginScript = True

dim redirectTo
Select Case whichServer
	' session("SSORedirectURL") = where the C# should send the user when its done
	' redirectTo = where to hit the C#
	Case "DEV"
		session("SSORedirectURL") = "https://dev2.arxspan.com/SSO/saml2/shawnCorp/finalize.asp"
		redirectTo = "https://dev2.arxspan.com/saml/shawnCorp/signPDF/"
	Case "MODEL"
		session("SSORedirectURL") = "https://model.arxspan.com/SSO/saml2/shawnCorp/finalize.asp"
		redirectTo = "https://model.arxspan.com/saml/shawnCorp/signPDF/"
	Case "BETA"
		session("SSORedirectURL") = "https://www.arxspan.com"
		redirectTo = "www.arxspan.com"
	Case "PROD"
		session("SSORedirectURL") = "https://www.arxspan.com"
		redirectTo = "www.arxspan.com"
end select

session("SSOstate") = request.querystring("state")
session("SSOTempKey") = CreateGUID
session("SSOPageKey") = request.querystring("key")
session.Save()

' This function will return a plain GUID, e.g., 47BC69BD-06A5-4617-B730-B644DBCD40A9.
Function CreateGUID
  Dim TypeLib
  Set TypeLib = CreateObject("Scriptlet.TypeLib")
  CreateGUID = Mid(TypeLib.Guid, 2, 36)
End Function


%>
<script type="text/javascript">
	var redirectTo = "<%=redirectTo%>";
	console.log('redirecting to: ' + redirectTo);
	window.location = redirectTo;
</script>